#ifndef PIXEL_LIGHTING_DYNAMIC_H
#define PIXEL_LIGHTING_DYNAMIC_H

//---------------------------------------------------------------------------
class DynamicLight : SharedLight
{
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
            
            // For static lights we just add saturation and hue shift to the cookie
            vCookieSample = normalize(vCookieSample);

            return vCookieSample;
        }

        return 1.0f;
    }

    //
    // Main function that fills in the light data for the current light.
    //
    void Init( float4 vPositionSs, float3 vPositionWs, BinnedLight lightData )
    {
        LightData = lightData;
        
        // Get the light's color and intensity.
        Color = GetLightColor( vPositionWs );

        // Get the light's direction in world space.
        Direction = GetLightDirection( vPositionWs );

        // Get the position of the light in world space.
        Position = GetLightPosition();

        // Get the attenuation of the light based on the distance from the current
        // fragment to the light in world space.
        Attenuation = GetLightAttenuation( vPositionWs );

        // Get the visibility factor computed from shadow maps or other occlusion
        // data specific to the light being evaluated.
        Visibility = GetLightVisibility( vPositionWs );
    }

    //
    // Creates the structure of a dynamic light from the current pixel input.
    //
    static Light From( float4 vPositionSs, float3 vPositionWs, uint nLightIndex )
    {
        DynamicLight light;

        // Index of the dynamic light.
        // Translates from the light index in the global array to the light index in the current tile.
        nLightIndex = TranslateLightIndex( nLightIndex, GetTileForScreenPosition(vPositionSs.xy) );

        light.Init( vPositionSs, vPositionWs, DynamicLightConstantByIndex( nLightIndex ) );
        return (Light)light;
    }

    //
    // Number of lights in the current fragment.
    //
    static uint Count( float4 vPositionSs )
    {
	    return GetNumLights( GetTileForScreenPosition( vPositionSs.xy ) );
    }
};

//---------------------------------------------------------------------------
#endif // PIXEL_LIGHTING_DYNAMIC_H