HEADER
{
    Description = "Standard post processing shader, Pass 1";
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
    float2 uv : TEXCOORD0;

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
        o.uv = i.vTexCoord;
        return o;
    }
}

PS
{
    #include "postprocess/common.hlsl"
    #include "postprocess/functions.hlsl"
    #include "procedural.hlsl"

    #include "common/classes/Depth.hlsl"

    RenderState( DepthWriteEnable, false );
    RenderState( DepthEnable, false );

    CreateTexture2D( g_tColorBuffer ) < Attribute( "ColorBuffer" );  	SrgbRead( true ); Filter( MIN_MAG_LINEAR_MIP_POINT ); AddressU( MIRROR ); AddressV( MIRROR ); >;
    
    float flCameraFOV< Attribute("CameraFOV"); Default(0); >;

    DynamicCombo( D_CHROMATIC_ABERRATION, 0..1, Sys( PC ) );
    DynamicCombo( D_MOTION_BLUR, 0..1, Sys( PC ) );

    float pixelation < Attribute("standard.pixelate.pixelation"); Default(0); >;

    float3 caAmount< Attribute("standard.chromaticaberration.amount"); Default3(0.004f, 0.006f, 0.0f); >;
    float caScale< Attribute("standard.chromaticaberration.scale"); Default(0.0f);>;

    float flMotionBlurScale< Attribute("standard.motionblur.scale"); Default(0.05f); >;
    int sMotionBlurSamples< Attribute("standard.motionblur.samples"); Default(16); >;

    float sharpen< Attribute("standard.sharpen.strength"); Default(0.0f); >;

    
    float4 ChromaticAberration( float2 vTexCoords )
    {
        float2 offsetScale = (vTexCoords - 0.5) * caScale * 10.0f;

        float4 r = Tex2DS(g_tColorBuffer, g_tColorBuffer_sampler, vTexCoords - (offsetScale * caAmount.r ));
        float4 g = Tex2DS(g_tColorBuffer, g_tColorBuffer_sampler, vTexCoords - (offsetScale * caAmount.g ));
        float4 b = Tex2DS(g_tColorBuffer, g_tColorBuffer_sampler, vTexCoords - (offsetScale * caAmount.b ));

        return float4( r.r, g.g, b.b, r.a + g.a + b.a );
    }

    float4 FetchSceneColor( float2 vScreenUv )
    {
        #if D_CHROMATIC_ABERRATION
            return ChromaticAberration( vScreenUv );
        #else
            return Tex2D( g_tColorBuffer, vScreenUv.xy );
        #endif
    }

    float2 GetCameraVelocityVector(float2 texCoords)
    {
        // Normalize depth to the viewport
        float depth = Depth::GetNormalized(texCoords * g_vViewportSize);

        // Convert texture coordinates to clip space
        float2 clipCoords = (texCoords - 0.5) * 2.0 * float2(1.0, -1.0);

        // Calculate world space position based on the previous projection
        float4 worldPos = mul(g_matProjectionToWorld, float4(clipCoords.xy, depth, 1.0f));
        worldPos.xyz /= worldPos.w;
        worldPos.xyz += g_vCameraPositionWs;

        // Reproject the world space position to screen space in the previous frame
        float3 prevFramePosSs = ReprojectFromLastFrameSs(worldPos);

        // Calculate the velocity vector based on the current projection
        float2 velocityVector = prevFramePosSs * g_vInvViewportSize;

        return velocityVector;
    }

    // This function applies motion blur to the scene.
    float4 MotionBlurEx(float2 texCoords)
    {
        // Get the velocity vector for the current texture coordinates
        float2 velocityVector = GetCameraVelocityVector(texCoords);

        // Initialize the color accumulator
        float4 color = 0.0f;

        // Calculate the inverse of the number of samples for motion blur
        float invSamples = 1.0f / (float)sMotionBlurSamples;

        // Accumulate the color from each sample along the motion blur path
        for(float i = 1; i < sMotionBlurSamples; i++)
        {
            float2 uv = lerp(texCoords, velocityVector, invSamples * i);
            color += FetchSceneColor(uv) * invSamples;
        }

        return color;
    }

    float4 SharpenEx( float4 vColor, float2 vTexCoords, float flStrength )
    {
        float2 vSize = (1.0f / g_vRenderTargetSize);

        float4 vFinalColor = vColor * (1.0f + (4.0f * flStrength));
        vFinalColor += (FetchSceneColor(vTexCoords + float2(vSize.x, 0.0f)) * (-1.0f * flStrength));
        vFinalColor += (FetchSceneColor(vTexCoords + float2(-vSize.x, 0.0f)) * (-1.0f * flStrength));
        vFinalColor += (FetchSceneColor(vTexCoords + float2(0.0f, vSize.y)) * (-1.0f * flStrength));
        vFinalColor += (FetchSceneColor(vTexCoords + float2(0.0f, -vSize.y)) * (-1.0f * flStrength));
        
        return vFinalColor;
    }

    float4 MainPs( PixelInput i ) : SV_Target0
    {
        float4 color = 1;

        float2 vScreenUv = CalculateViewportUv( i.vPositionSs.xy );
        float aspect = g_vRenderTargetSize.y / g_vRenderTargetSize.x;

        if ( pixelation > 0 )
        {
            float resolution = RemapValClamped( pow( pixelation, 0.1 ), 0, 1, g_vRenderTargetSize.x, 32 );
            float2 vPixelCount = float2( resolution, resolution * aspect );
            float2 pixelSize = 1.0f / vPixelCount;
            vScreenUv = floor(vScreenUv * vPixelCount) / vPixelCount;
            vScreenUv += pixelSize * 0.5f; // use center of pixel for sample
        }

        #if D_MOTION_BLUR
            // We can't use our predefined motion blur as we need to account for chromatic aberration
            color = MotionBlurEx( vScreenUv );
        #else
            color = FetchSceneColor( vScreenUv );
        #endif

        if ( sharpen != 0.0f )
        {
            color = SharpenEx( color, vScreenUv, sharpen );
        }

        return color;
    }
}
