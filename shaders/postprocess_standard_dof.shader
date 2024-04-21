HEADER
{
    Description = "Depth of Field";
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

    float flDOFFocusPlane< Attribute("standard.dof.focusplane"); Default(1.0f); >;
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
    float CalculateProjectionDepthFromViewDepth( float flViewDepth )
    {
        float flZScale = g_vInvProjRow3.z;
        float flZTran = g_vInvProjRow3.w;
        return ( 1.0 / flViewDepth - flZTran ) / flZScale;
    }

    PixelInput MainVs( VertexInput i )
    {
        PixelInput o;
        o.vPositionPs = float4(i.vPositionOs.xyz, 1.0f);
        o.vPositionPs.z = RemapValClamped( CalculateProjectionDepthFromViewDepth( flDOFFocusPlane ), 0.0, 1.0,  g_flViewportMinZ, g_flViewportMaxZ );
        o.vTexCoord = i.vTexCoord;
        return o;
    }
}

PS
{
    #include "postprocess/common.hlsl"
    #include "common/classes/Depth.hlsl"

    #define DOF_PASS_BLUR 0
    #define DOF_PASS_COMBINE_FRONT 1
    #define DOF_PASS_COMBINE_BACK 2

    DynamicCombo( D_DOF_PASS, 0..2, Sys( PC ) );

    // Enable depth write if we are on the combine pass
    #define DEPTH_STATE_ALREADY_SET
    RenderState( DepthWriteEnable, D_DOF_PASS != DOF_PASS_BLUR );
    RenderState( DepthEnable, D_DOF_PASS != DOF_PASS_BLUR );
    
    RenderState( DepthFunc, ( D_DOF_PASS == DOF_PASS_COMBINE_FRONT ) ? GREATER_EQUAL : LESS );

    RenderState( BlendEnable, D_DOF_PASS != DOF_PASS_BLUR );
    RenderState( SrcBlend, SRC_ALPHA );
    RenderState( DstBlend, INV_SRC_ALPHA );

    CreateTexture2D( g_tColorBuffer )   < Attribute( "ColorBuffer" );  	SrgbRead( true ); Filter( MIN_MAG_LINEAR_MIP_POINT ); AddressU( MIRROR ); AddressV( MIRROR ); >;
    CreateTexture2D( g_tBackBlur )      < Attribute( "BackBlur" );  	SrgbRead( true ); Filter( MIN_MAG_LINEAR_MIP_POINT ); AddressU( MIRROR ); AddressV( MIRROR ); >;

    float flDOFRadius                   < Attribute("standard.dof.radius"); Default(0.0f); >;
    int nBlurDownsample                 < Attribute("standard.dof.blurdownscale"); Default(1); >;

    struct PixelOutput
    {
        float4 vColor : SV_Target0;
    };

    static const float GOLDEN_ANGLE = 2.39996323;
    static const float MAX_BLUR_SIZE = 50.0;
    static const float RAD_SCALE = nBlurDownsample; // Smaller = nicer blur, larger = faster

    //---------------------------------------------------------------------------------------------------------------------------------------------------------

	float FetchDepth( float2 vTexCoord, float iIter )
	{
		float flProjectedDepth = Depth::GetNormalized( vTexCoord * g_vRenderTargetSize );

        float flZScale = g_vInvProjRow3.z;
        float flZTran = g_vInvProjRow3.w;

        float flDepthRelativeToRayLength = 1.0 / ( ( flProjectedDepth * flZScale + flZTran ) );

		return flDepthRelativeToRayLength;
	}
    
    //---------------------------------------------------------------------------------------------------------------------------------------------------------

    float3 FetchColor( float2 vTexCoord )
    {
        return clamp( Tex2D( g_tColorBuffer, vTexCoord ).rgb, 0, 255*255);
    }
    
    //---------------------------------------------------------------------------------------------------------------------------------------------------------

    float GetBlurSize(float depth, float focusPoint, float focusScale, float blurSize = MAX_BLUR_SIZE )
	{
		float coc = clamp((1.0 / focusPoint - 1.0 / depth) * focusScale, -1.0, 1.0);
        return coc * blurSize;
	}
    
    static const float focusScale = 10;

    float4 DepthOfField(float2 texCoord, float focusPoint, float blurSize = MAX_BLUR_SIZE )
	{
        float radiusScale = 3;

		float2 vOffset = g_vViewportOffset.xy / ( g_vRenderTargetSize  ); //Our depth buffer doesn't reoffset itself like the MSAA resolver
		float centerDepth = FetchDepth( texCoord.xy + vOffset, 0 );
		float centerSize = abs( GetBlurSize(centerDepth, focusPoint , focusScale, blurSize) );
        centerSize = max( centerSize, sqrt(blurSize) ); // Make sure we evaluate at least this much

		float3 color = FetchColor( texCoord.xy ).rgb;
		float tot = 1.0;

        float radius = radiusScale;
		float iIter = 0;

		[loop]
		for (float ang = 0.0; radius<abs(centerSize); ang += GOLDEN_ANGLE)
		{
			iIter+= 1.0;
			float2 tc = texCoord + float2(cos(ang), sin(ang)) * ( 1.0f / ( g_vRenderTargetSize ) )* radius;
			
            if( tc.x < 0 || tc.x > 1 || tc.y < 0 || tc.y > 1 )
            {
			    radius += radiusScale*4/radius;
                continue;
            }

			float sampleDepth = FetchDepth( tc  + vOffset, ang );
			float sampleSize = GetBlurSize(sampleDepth, focusPoint , focusScale, blurSize );

            // Front samples need less taps
            if( sampleSize < 0 )
            {
			    radius += pow( radiusScale/radius, 1.0 / 4.0 );
            }
            
			float3 sampleColor = FetchColor( tc ).rgb;

			float m = smoothstep(radius-0.5, radius+0.5, abs(sampleSize) );
			color += lerp(color/tot, sampleColor, m);
			tot += 1.0;
			radius += radiusScale/radius;
		}

		return float4( color /= tot, centerSize );
	}

    // --------------------------------------------------------------------------------------------------------------------------------------------------------
    float4 DoFBlurPass( PixelInput i )
    {
        float4 vColor = 1.0f;
        float flFocusPlane = flDOFFocusPlane;

        vColor = DepthOfField( i.vTexCoord, flFocusPlane, flDOFRadius );

        return vColor;
    }
    
    float4 CompositeDoFPass( PixelInput i )
    {
        float4 vColor = 1.0f;
        
        float4 vDoFBackColor =  Tex2DBicubic( PassToArgTexture2D( g_tBackBlur ), i.vTexCoord , TextureDimensions2D( g_tBackBlur, 0 ) ).rgba;

        vColor.rgb = vDoFBackColor.rgb;
        vColor.a = 1; // fixme: alpha to coverage gets fucked by this, do a bloating pass
        
        return vColor;
    }

    // --------------------------------------------------------------------------------------------------------------------------------------------------------
    // Stubbed, was looking shit but all the requirements for it are set
    float4 CompositeDoFPassBack( PixelInput i )
    {
        float4 vColor = CompositeDoFPass(i);

        float flDepth = 0;

        for( int x=-1;x<=1;x++)
        {
            for(int y=-1;y<=1;y++)
            {
                float2 vUVOffset = float2(x,y) / g_vRenderTargetSize;
                flDepth = max( FetchDepth( i.vTexCoord.xy + vUVOffset, 0 ), flDepth );
            }
        }

        float flDoFSize = GetBlurSize(flDepth, flDOFFocusPlane , focusScale, flDOFRadius);

        vColor.a = saturate( ( flDoFSize  )  );

        return vColor;
    }

    float4 CompositeDoFPassFront( PixelInput i )
    {
        float4 vColor = CompositeDoFPass(i);

        float flDepth = 99999;

        for( int x=-1;x<=1;x++)
        {
            for(int y=-1;y<=1;y++)
            {
                float2 vUVOffset = float2(x,y) / g_vRenderTargetSize;
                flDepth = min( FetchDepth( i.vTexCoord.xy + vUVOffset, 0 ), flDepth );
            }
        }

        float flDoFSize = GetBlurSize(flDepth, flDOFFocusPlane , focusScale, flDOFRadius);

        vColor.a = saturate( -( flDoFSize * 0.25f )  );
        
        return vColor;
    }
    // --------------------------------------------------------------------------------------------------------------------------------------------------------

    float4 MainPs( PixelInput i ) : SV_Target0
    {
        #if ( D_DOF_PASS == DOF_PASS_BLUR )
            return DoFBlurPass( i );
        #elif ( D_DOF_PASS == DOF_PASS_COMBINE_FRONT )
            return CompositeDoFPassFront( i );
        #elif ( D_DOF_PASS == DOF_PASS_COMBINE_BACK )
            return CompositeDoFPassBack( i );
        #endif
    }
}
