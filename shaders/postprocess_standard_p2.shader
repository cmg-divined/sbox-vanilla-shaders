HEADER
{
    Description = "Standard post processing shader, Pass 2";
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
    SamplerState g_sBilinearWrap < Filter( BILINEAR ); AddressU( WRAP ); AddressV( WRAP ); >;
    
    float flBlurSize< Attribute("standard.blur.size"); Default(0.0f); >;
	
    float3 FetchSceneColor( float2 vScreenUv )
    {
       return Tex2D( g_tColorBuffer, vScreenUv.xy ).rgb;
    }

    float3 GaussianBlurEx( float3 vColor, float2 vTexCoords )
    {
        float flRemappedBlurSize = flBlurSize;

        float fl2PI = 6.28318530718f;
        float flDirections = 16.0f;
        float flQuality = 4.0f;
        float flTaps = 1.0f;

        [unroll]
        for( float d=0.0; d<fl2PI; d+=fl2PI/flDirections)
        {
            [unroll]
            for(float j=1.0/flQuality; j<=1.0; j+=1.0/flQuality)
            {
                flTaps += 1;
                vColor += FetchSceneColor( vTexCoords + float2( cos(d), sin(d) ) * lerp(0.0f, 0.02, flRemappedBlurSize) * j );    
            }
        }
        return vColor / flTaps;
    }

    float4 MainPs( PixelInput i ) : SV_Target0
    {
        float2 vScreenUv = i.vPositionSs.xy / g_vRenderTargetSize;

        float3 vFinalColor = FetchSceneColor( vScreenUv ).rgb;
        vFinalColor = GaussianBlurEx( vFinalColor, vScreenUv );

        return float4( vFinalColor, 1.0f );
    }
}
