#ifndef PIXEL_LIGHTING_STATIC_H
#define PIXEL_LIGHTING_STATIC_H

//-----------------------------------------------------------------------------
// Lightmapped Probe lights
//
// These are lightmapped surfaces that incide with stationary lighting.
// Can have dynamic shadows.
//-----------------------------------------------------------------------------
class ProbeLight : SharedLight
{
    //
    // Main function that fills in the light data for the current light.
    //
    void Init(float3 vPositionWs, uint nLightIndex, float lightStrength )
    {
        LightData = BakedIndexedLightConstantByIndex( nLightIndex );

        // Get the light's color and intensity.
        Color = GetLightColor( vPositionWs );

        // Get the light's direction in world space.
        Direction = GetLightDirection( vPositionWs );

        // Get the position of the light in world space.
        Position = GetLightPosition();

        // Get the attenuation of the light based on the distance from the current
        // fragment to the light in world space.
        Attenuation = lightStrength * lightStrength;

        // Get the visibility factor computed from shadow maps or other occlusion
        // data specific to the light being evaluated.
        Visibility = GetLightVisibility( vPositionWs );
    }

    //
    // Creates the structure of a static probe light from the current pixel input.
    //
    static Light From( float3 vPositionWs, uint nLightIndex )
    {
		int4 vLightIndices;
		float4 vLightStrengths;
        SampleLightProbeVolumeIndexedDirectLighting( vLightIndices, vLightStrengths, vPositionWs + g_vHighPrecisionLightingOffsetWs.xyz );

        ProbeLight light;
        light.Init( vPositionWs, vLightIndices[ nLightIndex ], vLightStrengths[nLightIndex] );
        return (Light)light;
    }
};

//-----------------------------------------------------------------------------
// Direct lightmapped light
//-----------------------------------------------------------------------------
class LightmappedLight : ProbeLight
{
#if ( D_BAKED_LIGHTING_FROM_LIGHTMAP )

    static int4 GetLightmappedLightIndices( float2 vLightmapUV )
    {
        float3 vLightmapUVW = float3( vLightmapUV.xy, 0 );
		float4 vLightIndexFloats = Tex2DArrayS( LightMap( 0 ), g_sPointClamp, vLightmapUVW ).rgba;

        int4 vLightIndices = int4( vLightIndexFloats.xyzw * 255 );
        return vLightIndices;
    }
    
    static float4 GetLightmappedLightStrengths( float2 vLightmapUV )
    {
        float3 vLightmapUVW = float3( vLightmapUV.xy, 0 );
		float4 vLightStrengths = Tex2DArrayS( LightMap( 1 ), g_sTrilinearClamp, vLightmapUVW ).rgba;
        return vLightStrengths;
    }
    
    //
    // Creates the structure of a lightmapped light from the current pixel input.
    //
    static Light From( float3 vPositionWs, float2 vLightmapUV, uint nLightIndex )
    {
        // Translated light index from the lightmap to the global light index.
        int nLightmappedIndex = GetLightmappedLightIndices( vLightmapUV )[nLightIndex];
        // Get the light strength from the lightmap.
        float fLightStrength = GetLightmappedLightStrengths( vLightmapUV )[nLightIndex];

        LightmappedLight light;
        light.Init( vPositionWs, nLightmappedIndex, fLightStrength );
        return (Light)light;
    }
#endif
};

//-----------------------------------------------------------------------------
// Indexed static lights
//-----------------------------------------------------------------------------
class StaticLight : Light
{
    //
    // Creates the structure of a static light from the current pixel input.
    //
    static Light From( float3 vPositionWs, float2 vLightmapUV, uint nLightIndex )
    {
        #if ( D_BAKED_LIGHTING_FROM_LIGHTMAP )
            return LightmappedLight::From( vPositionWs, vLightmapUV, nLightIndex );
        #else // #elif ( D_BAKED_LIGHTING_FROM_PROBE )
            return ProbeLight::From( vPositionWs, nLightIndex );
        #endif

        // Todo: Assume "Vertex Stream" lights? when ex. out of bounds or procedural? 
        // Could just take the sunlight and use it as a directional light.
        // How would we deal when there's no sun?
    }
   
    static uint Count()
    {
        // Todo: Count the number of lights in the lightmap.
        return 4;
    }
};

#endif // PIXEL_LIGHTING_STATIC_H