HEADER
{
    Description = "Standard post processing shader";
    DevShader = true;
}

MODES
{
    Default();
    VrForward();
}

FEATURES
{
}

COMMON
{
    #include "postprocess/shared.hlsl"
}

struct VertexInput
{
    float3 vPositionOs : POSITION < Semantic( PosXyz ); >;
    float2 vTexCoord : TEXCOORD0 < Semantic( LowPrecisionUv ); >;
};

struct PixelInput
{
    float2 vTexCoord : TEXCOORD0;

	// VS only
	#if ( PROGRAM == VFX_PROGRAM_VS )
		float4 vPositionPs		: SV_Position;
	#endif

	// PS only
	#if ( ( PROGRAM == VFX_PROGRAM_PS ) )
		float4 vPositionSs		: SV_Position;
	#endif
};

VS
{
    PixelInput MainVs( VertexInput i )
    {
        PixelInput o;
        
        o.vPositionPs = float4(i.vPositionOs.xy, 0.0f, 1.0f);
        o.vTexCoord = i.vTexCoord;
        return o;
    }
}

PS
{
    #include "postprocess/common.hlsl"
    #include "postprocess/functions.hlsl"
    #include "procedural.hlsl"

    RenderState( DepthWriteEnable, false );
    RenderState( DepthEnable, false );

    CreateTexture2D( g_tColorBuffer ) < Attribute( "ColorBuffer" );  	SrgbRead( true ); Filter( MIN_MAG_LINEAR_MIP_POINT ); AddressU( MIRROR ); AddressV( MIRROR ); >;
    SamplerState g_sBilinearWrap < Filter( POINT ); AddressU( WRAP ); AddressV( WRAP ); >;

    float flCameraFOV< Attribute("CameraFOV"); Default(0); >;

    DynamicCombo( D_FILM_GRAIN, 0..1, Sys( PC ) );

    //
    // Film grain
    //
    float grainIntensity< Attribute("standard.grain.intensity"); >;
    float grainResponse< Attribute("standard.grain.response"); >;
    CreateInputTexture2D( TextureGrain, Linear, 8, "", "_grain", "Grain", Default( 0.0f ) );
    CreateTexture2DWithoutSampler( g_tGrain )< Channel( RGB, Box( TextureGrain ), Linear ); OutputFormat( BC7 ); SrgbRead( false ); >;

    //
    // Vignette
    //
    float4 vVignetteColor< Attribute("standard.vignette.color"); Default4(0.0f,0.0f,0.0f,1.0f); >;
    float flVignetteIntensity< Attribute("standard.vignette.intensity"); Default(0.0f); >;
    float flVignetteSmoothness< Attribute("standard.vignette.smoothness"); Default(1.0f); >;
    float flVignetteRoundness< Attribute("standard.vignette.roundness"); Default(0.2f); >;
    float2 vVignetteCenter< Attribute("standard.vignette.center"); Default2(0.5f, 0.5f); >;

    //
    // Color adjustments
    //
    float flSaturationAmount< Attribute("standard.saturate.amount"); Default(1.0f); >;
    float flHueRotate< Attribute("standard.hue_rotate.angle" ); Default(0.0f); >;
    float flBrightness< Attribute("standard.brightness.multiplier"); Default(1.0f); >;
    float flContrast< Attribute("standard.contrast.contrast"); Default(1.0f); >;

	
    float4 FetchSceneColor( float2 vScreenUv )
    {
        return Tex2D( g_tColorBuffer, vScreenUv.xy );
    }

    float4 Vignette( float4 vColor, float2 vTexCoords, float4 vVignetteColor, float2 vCenter, float flIntensity, float flSmoothness, float flRoundness )
    {
        if ( flIntensity <= 0 ) 
            return vColor;
            
        float2 vDistanceFromCenter = abs( vTexCoords - vCenter ) * flIntensity;

        vDistanceFromCenter.x = lerp( vDistanceFromCenter.x, vDistanceFromCenter.x *  g_vRenderTargetSize.x / g_vRenderTargetSize.y, flRoundness );

        float amount = length( vDistanceFromCenter ) * ( 1 +flIntensity );
        amount = pow( amount, 1 + (1-flSmoothness) * 32.0f );

        vColor.rgb = lerp(vColor.rgb, vVignetteColor.rgb, amount * vVignetteColor.a);
        return vColor;
    }


    float3 FilmGrain( float3 vColor, float3 flSampledGrain, float intensity, float flResponse )
    {
        // Remap grain to a -1 -> 1 range
        flSampledGrain = (flSampledGrain);

        flSampledGrain.rgb = flSampledGrain.r;

        // Grab our luminence and rescale based on response
        float lum = 1 - (GetLuminance( vColor.rgb ) * 3.0f);
        intensity *= saturate( lerp( 1.0f, saturate( lum ), flResponse ) );

        float3 fullGrain = flSampledGrain * 0.4f;

        vColor = lerp( vColor, GetLuminance( vColor.rgb ), intensity );

        return lerp( vColor, fullGrain, intensity );
    }

    float4 MainPs( PixelInput i ) : SV_Target0
    {
        float4 color = 1;
        float2 vScreenUv = i.vPositionSs.xy / g_vRenderTargetSize;

        color = FetchSceneColor( vScreenUv );

        color.rgb = saturate( (color.rgb - 0.5f) * flContrast + 0.5f );
        float3 vHsv = RgbToHsv( color.rgb );

        vHsv.r = (vHsv.r + (flHueRotate / 360.0f)) % 1.0f;
        vHsv.b *= flBrightness;
        vHsv.g *= flSaturationAmount;

        color.rgb = HsvToRgb( vHsv );

        if ( grainIntensity > 0 )
        {
            float aspect = g_vRenderTargetSize.y / g_vRenderTargetSize.x;
            float2 vGrainUvs = TileAndOffsetUv( vScreenUv, float2( 3, 3 * aspect ), float2(frac(g_flTime * 24.042f), frac(g_flTime * 34.054f)) );
            float3 flGrain = Tex2DLevelS( g_tGrain, g_sBilinearWrap, vGrainUvs, 0 ).rgb;
            flGrain += Tex2DLevelS( g_tGrain, g_sBilinearWrap, vGrainUvs * 0.4f, 0 ).rgb;
            flGrain /= 2.0f;
            color.rgb = FilmGrain( color.rgb, flGrain, grainIntensity, grainResponse );
        }

        color = Vignette( color, vScreenUv, vVignetteColor, vVignetteCenter, flVignetteIntensity, flVignetteSmoothness, flVignetteRoundness );

        return color;
    }
}
