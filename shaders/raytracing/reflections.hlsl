#ifndef REFLECTIONS_H
#define REFLECTIONS_H
//
// Hints to the layer system that we want to use a high quality reflection pass
// F_DYNAMIC_REFLECTIONS must be defined either as a feature or as a compile-time define
//
BoolAttribute( UsesDynamicReflections, ( F_DYNAMIC_REFLECTIONS > 0 ) ? true : false );

//
// Hints to the compositor that we want to composite with the high quality reflection pass
//
#define USES_DYNAMIC_REFLECTIONS 1

StaticCombo( S_MODE_REFLECTIONS, 0..1, Sys(ALL) );

#include "encoded_normals.fxc" // for EncodeNormal2D
#include "vr_lighting.fxc"     // for Bluenoise and Dither Params
#include "vr_tools_vis.fxc"     //Bullshit
#include "common/classes/Depth.hlsl"

#include "common/material.hlsl"


#if ( S_MODE_REFLECTIONS > 0 )
    //
    // Render state
    //
    RenderState(DepthBias, -500);
    RenderState(SlopeScaleDepthBias, -0.95);
    RenderState(DepthBiasClamp, -0.5);
    RenderState(ColorWriteEnable0, RGBA);
#endif

    //
    // Samplers
    //
    CreateTexture2D(g_tPrevFrameTexture) < Attribute("PrevFrameTexture"); SrgbRead(false); Filter(MIN_MAG_MIP_POINT); AddressU(CLAMP); AddressV(CLAMP); > ;

    int SampleCountIntersection < Attribute("SampleCountIntersection"); Default(1); > ;
    int ReflectionDownsampleRatio < Attribute("ReflectionDownsampleRatio"); Default(0); > ; // Denominator of how much smaller the output buffer is than the hierarchical depth buffer, 0 means same size, 1 means half size, 2 means quarter size, etc.

    //-------------------------------------------------------------------------------------------------
    // GGX importance sampling function
    float3 ReferenceImportanceSampleGGX(float2 Xi, float roughness, float3 N)
    {
        float a = roughness * roughness;

        float phi = 2.0 * 3.141592 * Xi.x;
        float cosTheta = sqrt((1.0 - Xi.y) / (1.0 + (a * a - 1.0) * Xi.y));
        float sinTheta = sqrt(1.0 - cosTheta * cosTheta);

        float3 H;
        H.x = sinTheta * cos(phi);
        H.y = sinTheta * sin(phi);
        H.z = cosTheta;

        // Tangent space to world space
        float3 upVector = abs(N.z) < 0.999 ? float3(0, 0, 1) : float3(1, 0, 0);
        float3 T = normalize(cross(upVector, N));
        float3 B = cross(N, T);

        float3 sampleDirection = H.x * T + H.y * B + H.z * N;

        if ( any(isnan(sampleDirection) ) )
            return N;

        return normalize(sampleDirection);
    }
    //-------------------------------------------------------------------------------------------------


    // Transforms origin to uv space
    // Mat must be able to transform origin from its current space into clip space.
    float3 ProjectPosition(float3 origin, float4x4 mat) {
        float4 projected = Position4WsToPs( float4( origin, 1.0 ) );
        projected.xyz /= projected.w;
        projected.xy = 0.5 * projected.xy + 0.5;
        projected.y = (1 - projected.y);
        return projected.xyz;
    }

    // Origin and direction must be in the same space and mat must be able to transform from that space into clip space.
    float3 ProjectDirection(float3 origin, float3 direction, float3 screen_space_origin, float4x4 mat) {
        float3 offsetted = ProjectPosition(origin + direction, mat);
        return offsetted  - screen_space_origin;
    }

    // Mat must be able to transform origin from texture space to a linear space.
    float3 InvProjectPosition(float3 coord, float4x4 mat) {
        coord.y = (1 - coord.y);
        coord.xy = 2 * coord.xy - 1;
        float4 projected = mul(mat, float4(coord, 1));
        projected.xyz /= projected.w;
        return projected.xyz;
    }

    float FFX_SSSR_LoadDepth(int2 pixel_coordinate, int mip)
    {
        float flDepth = mip == 0 ? Tex2DLoad( g_tDepthChain, int3( pixel_coordinate, mip + ReflectionDownsampleRatio ) ).y : Tex2DLoad( g_tDepthChain, int3( pixel_coordinate, mip + ReflectionDownsampleRatio ) ).x;
        flDepth = RemapValClamped( flDepth, g_flViewportMinZ, g_flViewportMaxZ, 0.0, 1.0 );
        return flDepth;
    }

    float3 ScreenSpaceToWorldSpace(float3 screen_space_position) {
        return InvProjectPosition(screen_space_position, g_matProjectionToWorld );
    }

    #include "common/thirdparty/ffx_sssr.hlsl"

    // ------------------ SSSR ------------------

    struct TraceResult_t
    {
        float3 vHitCs; 		// Hit position in clip space
        float flConfidence;	// Confidence of the hit
    };


    struct ReflectionOutput
    {
        float4 vReflectionColor : SV_Target0;
        float4 vReflectionGBuffer : SV_Target1; //
    };

    class Reflections
    {
        //-------------------------------------------------------------------------------------------------
        // Traces a single world-space ray in screen-space and returns the hit position and confidence
        //-------------------------------------------------------------------------------------------------
        static TraceResult_t WorldTrace(PixelInput i, float3 vReflectWs)
        {
            bool bValidHit = false;
            uint nMaxSteps = 48;
            uint nInitialMip = 0;
            bool bMipChain = true;
            bool bBackTracing = true;
            const float2 vViewportSize = g_vViewportSize;

            //----------------------------------------------
            float3 vPositionWs = i.vPositionWithOffsetWs.xyz + g_vHighPrecisionLightingOffsetWs.xyz;

            //----------------------------------------------
            // Fetch depth
            // ---------------------------------------------

            // Use depth from our PixelInput
            float4 vPositionPs = Position4WsToPs(float4(vPositionWs, 1.0));
            vPositionPs.z /= vPositionPs.w;

            float2 vUV = i.vPositionSs.xy * g_vInvViewportSize.xy;
            float flDepth = vPositionPs.z;
            float flDepthThickness = 20.0f;

            //---------------------------------------------
            // Build our position in clip space and reflection vector from world space ray
            // ---------------------------------------------

            float4 vPositionCs = float4(vUV.xy, flDepth, 1.0);
            float3 vReflectCs = ProjectDirection(vPositionWs, vReflectWs, vPositionCs.xyz, g_matWorldToProjection);

            //----------------------------------------------
            // Trace the thing ;)
            // ---------------------------------------------
            float3 hit = FFX_SSSR_HierarchicalRaymarch(vPositionCs.xyz, vReflectCs.xyz, vViewportSize, nInitialMip, nMaxSteps, bMipChain, bBackTracing, bValidHit);
            float confidence = bValidHit ? FFX_SSSR_ValidateHit(hit, vUV, vReflectWs, vViewportSize, flDepthThickness) : 0;

            //----------------------------------------------
            // Composite result
            // ---------------------------------------------
            TraceResult_t result;
            result.vHitCs = hit;
            result.flConfidence = confidence;

            return result;
        }

        //-------------------------------------------------------------------------------------------------
        // Traces a screen space reflection and returns the color and gbuffer data for the denoiser
        //-------------------------------------------------------------------------------------------------
        static ReflectionOutput From( PixelInput i, Material material, uint nSamplesPerPixel = -1 )
        {
            if( nSamplesPerPixel == -1 )
            {
                nSamplesPerPixel = SampleCountIntersection;
            }

            ReflectionOutput o;

            #if ( USES_DYNAMIC_REFLECTIONS == 0 )
            {
                o.vReflectionColor = float4(1, 0, 0, 1);
                o.vReflectionGBuffer = 0;
                return o;
            }
            #endif

            //----------------------------------------------
            // Fetch stuff
            // ---------------------------------------------
            const float3 vPositionWs = i.vPositionWithOffsetWs.xyz + g_vHighPrecisionLightingOffsetWs.xyz;
            const float3 vRayWs = CalculateCameraToPositionDirWs( vPositionWs );

            //----------------------------------------------

            float3 vColor = 0;
            float flConfidence = 0;
            uint nValidSamples = 0;
            float flHitLength = 0;

            float InvSampleCount = 1.0 / nSamplesPerPixel;

            //----------------------------------------------
            [loop]
            for ( uint k = 0; k < nSamplesPerPixel; k++ )
            {
                //----------------------------------------------
                // Get noise value
                // ---------------------------------------------
                float2 vDitherCoord = mad( i.vPositionSs.xy + (k * 50), ( 1.0f / 256.0f ), g_vRandomFloats.xy );
                float3 vNoise = AttributeTex2DS(g_tBlueNoise, g_sPointWrap, vDitherCoord.xy).rgb;

                // Randomize dir by roughness
                float3 H = ReferenceImportanceSampleGGX(vNoise.rg, material.Roughness, material.Normal);

                float3 vReflectWs = reflect(vRayWs, H);

                //----------------------------------------------
                // Trace reflection
                // ---------------------------------------------
                TraceResult_t trace = WorldTrace(i, vReflectWs);

                //----------------------------------------------
                // Reproject
                // ---------------------------------------------
                float3 vHitWs = ScreenSpaceToWorldSpace(trace.vHitCs.xyz) + g_vCameraPositionWs.xyz;
                flHitLength = distance(vPositionWs, vHitWs); // Used for contact hardening

                int2 vLastFramePositionHitSs = ReprojectFromLastFrameSs(vHitWs).xy - 0.5f;
                vLastFramePositionHitSs = clamp(vLastFramePositionHitSs, 0, TextureDimensions2D(g_tPrevFrameTexture, 0).xy - 1); // Clamp to avoid out of bounds, allows us to reconstruct better

                //----------------------------------------------
                // Fetch and accumulate color and confidence
                // ---------------------------------------------
                bool bValidSample = (trace.flConfidence > 0.0);

                vColor += Tex2DLoad( g_tPrevFrameTexture, uint3( vLastFramePositionHitSs, 0) ).rgb * bValidSample;
                flConfidence += bValidSample * InvSampleCount;

                nValidSamples += bValidSample;
            }
            vColor /= max( nValidSamples, 1 );

            //----------------------------------------------
            // Output
            //----------------------------------------------
            o.vReflectionColor = float4( max( vColor, 0 ), flConfidence );
            o.vReflectionGBuffer = float4( Vector3WsToVs( material.Normal ).xy, flHitLength, material.Roughness );

            return o;
        }
    };

#endif // REFLECTIONS_H