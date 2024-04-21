#ifndef COMMON_PIXEL_LIGHTDATA_H
#define COMMON_PIXEL_LIGHTDATA_H

//-----------------------------------------------------------------------------
// Light structure
//-----------------------------------------------------------------------------
struct Light
{
    // The color is an RGB value in the linear sRGB color space.
    float3 Color;

    // The normalized light vector, in world space (direction from the
    // current fragment's position to the light).
    float3 Direction;

    // The position of the light in world space. This value is the same as
    // Direction for directional lights.
    float3 Position;

    // Attenuation of the light based on the distance from the current
    // fragment to the light in world space. This value between 0.0 and 1.0
    // is computed differently for each type of light (it's always 1.0 for
    // directional lights).
    float Attenuation;

    // Visibility factor computed from shadow maps or other occlusion data
    // specific to the light being evaluated. This value is between 0.0 and
    // 1.0.
    float Visibility;
};

#if (PROGRAM == VFX_PROGRAM_PS)
//
// From lightbinner rework we have a single light structure, so 90% of light code doesn't need to be duplicated anymore
//
// We could eventually merge DynamicLight and StaticLight into just Light::From
// But I don't want to break the current code
//
class SharedLight : Light
{
    BinnedLight LightData;

    //
    // Gets the light cookie
    //
    float3 GetLightCookie(float3 vPositionWs)
    {
        [branch]
        if (LightData.HasLightCookie())
        {
            // Light cookie
            float3 vPositionTextureSpace = Position3WsToShadowTextureSpace(vPositionWs.xyz, LightData.WorldToLightCookie);
            float3 vCookieSample = SampleLightCookieTexture(vPositionTextureSpace.xyz).xyz;

            // if ( IsStatic )
            // vCookieSample = normalize(vCookieSample);

            return vCookieSample;
        }

        return 1.0f;
    }

    //
    // Get the light's color and intensity.
    //
    float3 GetLightColor(float3 vPositionWs)
    {
        return LightData.GetColor() * GetLightCookie(vPositionWs);
    }

    //
    // Get the light's direction in world space.
    //
    float3 GetLightDirection(float3 vPositionWs)
    {
        float3 vLightDir = normalize(GetLightPosition() - vPositionWs);
        return vLightDir;
    }

    //
    // Get the position of the light in world space.
    //
    float3 GetLightPosition()
    {
        return LightData.GetPosition();
    }
    // Get the attenuation of the light based on the distance from the current
    // fragment to the light in world space.
    float GetLightAttenuation(float3 vPositionWs)
    {
        const float3 vPositionToLightRayWs = GetLightPosition() - vPositionWs.xyz; // "L"
        const float3 vPositionToLightDirWs = normalize(vPositionToLightRayWs.xyz);
        const float flDistToLightSq = dot( vPositionToLightRayWs.xyz, vPositionToLightRayWs.xyz );

        float flOuterConeCos = LightData.SpotLightInnerOuterConeCosines.y;
        float flConeToDirection = dot(vPositionToLightDirWs.xyz, -LightData.GetDirection()) - flOuterConeCos;
        if ( flConeToDirection <= 0.0 )
        {
            // Outside spotlight cone
            return 0.0f;
        }

        float flSpotAtten = flConeToDirection * LightData.SpotLightInnerOuterConeCosines.z;
        float flLightFalloff = CalculateDistanceFalloff(flDistToLightSq, LightData.FalloffParams.xyzw, 1.0);
        
        float flLightMask = flLightFalloff * flSpotAtten;
        
        return flLightMask;
    }

    //
    // Computes the shadow factor for the current light.
    //
    float DynamicShadows(float3 vPositionWs)
    {
        float flShadowScalar = 1.0;

        [branch]
        if (LightData.HasDynamicShadows())
        {
            [unroll(MAX_SHADOW_FRUSTA_PER_LIGHT)]
            for (uint i = 0; i < LightData.NumShadowFrusta(); i++)
            {
                const float3 vPositionTextureSpace = Position3WsToShadowTextureSpace(vPositionWs.xyz, LightData.WorldToShadow[i]);

                [branch]
                if (InsideShadowRegion(vPositionTextureSpace.xyz, LightData.ShadowBounds[i]))
                {
                    flShadowScalar = ComputeShadow(vPositionTextureSpace.xyz);
                    break;
                }
            }
        }

        return flShadowScalar;
    }

    //
    // Get the visibility factor computed from shadow maps or other occlusion
    // data specific to the light being evaluated.
    //
    float GetLightVisibility(float3 vPositionWs)
    {
        return DynamicShadows(vPositionWs);
    }
};
#endif

//-----------------------------------------------------------------------------
// Includes
//-----------------------------------------------------------------------------

#if (PROGRAM == VFX_PROGRAM_PS)
#include "common/light.dynamic.hlsl"
#include "common/light.environment.hlsl"
#include "common/light.static.hlsl"
#endif

#endif // COMMON_PIXEL_LIGHTDATA_H