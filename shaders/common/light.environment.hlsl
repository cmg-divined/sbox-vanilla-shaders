#ifndef PIXEL_LIGHTING_ENVMAP_H
#define PIXEL_LIGHTING_ENVMAP_H

//---------------------------------------------------------------------------
class EnvironmentMapLight : Light
{
    uint EnvMapIndex;
    float TargetLuminanceOfCubemap;

    float GetTargetLuminanceOfCubemap( Material m )
    {
        float3 vAmbientCube[6];
		SampleLightProbeVolume( vAmbientCube, Position );
        return RelativeLuminance( SampleIrradiance( vAmbientCube, m.Normal ) );
    }

    float3 GetEnvMapColor( Material m )
    {
        const float flLevel = EnvMapSizeConstants().y * IsotropicRoughnessFromAnisotropicRoughness( m.Roughness * m.Roughness );
        
        float3 vParallaxReflectionCubemapLocal = CalcParallaxReflectionCubemapLocal( Position, m.Normal, EnvMapIndex );
        float3 vNormalWarpWs = normalize( lerp( vParallaxReflectionCubemapLocal.xyz, m.Normal, m.Roughness * m.Roughness ) );
        float3 vCubeMapTexel = SampleEnvironmentMapLevel( vNormalWarpWs.xyz, flLevel, EnvMapIndex );
        vCubeMapTexel *= NormalizeCubeBrightness( EnvMapIndex, m.Normal, m.Roughness, TargetLuminanceOfCubemap );
        
        return vCubeMapTexel;
    }

    float3 GetEnvMapPosition( float3 vPositionWs )
    {
        return mul( float4( vPositionWs + g_vHighPrecisionLightingOffsetWs.xyz, 1.0 ), EnvMapWorldToLocal( EnvMapIndex ) ).xyz;
    }

    float GetEnvMapAttenuation()
    {
        const float flEpisilon = 0.0001f;
        const float3 vEnvMapMin = EnvMapBoxMins( EnvMapIndex ) * flEpisilon;
        const float3 vEnvMapMax = EnvMapBoxMaxs( EnvMapIndex ) * flEpisilon;

        const float flEdgeFeathering = EnvMapFeathering( EnvMapIndex );

        float3 vIntersectA = min( ( Position - vEnvMapMin ), ( vEnvMapMax - Position ) ) ;
        float3 vIntersectB = min( ( Position - vEnvMapMax ), ( vEnvMapMin - Position ) ) ;

        float flDistance = min(
            min( vIntersectA.x, min( vIntersectA.y, vIntersectA.z ) ),
            min( -vIntersectB.x, -min( vIntersectB.y, vIntersectB.z ) )
        );

        return saturate( flDistance * flEdgeFeathering );
    }

    //
    // Main function that fills in the light data for the current light.
    //
    void Init( float3 vPositionWs, float2 vPositionSs, Material m, uint lightIndex )
    {
        // Index of the environment map.
        // Translates from the light index in the global array to the light index in the current tile.
        EnvMapIndex = TranslateEnvMapIndex( lightIndex, GetTileForScreenPosition( vPositionSs ) );

        // Get the position of the cubemap in world space.
        Position = GetEnvMapPosition( vPositionWs );

        // Get the target luminance of the cubemap.
        TargetLuminanceOfCubemap = GetTargetLuminanceOfCubemap( m );

        // Get the cubemap's color and intensity.
        Color = GetEnvMapColor( m );

        // Get the attenuation of the cubemap based on the distance from the current
        // fragment to the envmap in world space, includin feathering.
        Attenuation = GetEnvMapAttenuation();
    }

    //
    // Creates the structure of a environment map from the current pixel input.
    //
    static Light From( float3 vPositionWs, float2 vPositionSs, Material m, uint nLightIndex )
    {
        EnvironmentMapLight light;
        light.Init( vPositionWs, vPositionSs, m, nLightIndex );
        return (Light)light;
    }

    //
    // Number of lights in the current fragment.
    //
    static uint Count( float2 vPositionSs )
    {
	    return GetNumEnvMaps( GetTileForScreenPosition( vPositionSs ) );
    }
};

//---------------------------------------------------------------------------

class AmbientLight : Light
{
    static Light From( float3 vPositionWs, Material m )
    {
        AmbientLight light;

        //
        // Position
        //
        light.Position = vPositionWs + g_vHighPrecisionLightingOffsetWs.xyz;

        //
        // Color
        //
        float3 vAmbientCube[6];
		SampleLightProbeVolume( vAmbientCube, light.Position );
        light.Color = SampleIrradiance( vAmbientCube, m.Normal );

        //
        // Ambient Occlusion, TODO
        //
        light.Visibility = 1.0f;

        return (Light)light;
    }
};

//---------------------------------------------------------------------------
#endif // PIXEL_LIGHTING_DYNAMIC_H