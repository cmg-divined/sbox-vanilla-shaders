//
// Geometry clipmap
//

float2 roundToIncrement( float2 value, float increment ) {
    return round( value * ( 1.0f / increment ) ) * increment;
}

//
// Single mesh geometry clipmap approach to terrain rendering
// 1. Translates the mesh to always keep it centered around the camera
// 2. Alters the elevation to conform to the terrain height
//
// positionAndLod comes in increments of 1.0f on x/y and the grid lod on z
//
// Almost everything is from:
// http://casual-effects.blogspot.com/2014/04/fast-terrain-rendering-with-continuous.html
//
float3 Terrain_ClipmapSingleMesh(
    float3 positionAndLod,
    Texture2D tHeightMap,
    float terrainResolution,
    float4x4 invTransform )
{
    float2 texSize = TextureDimensions2D( tHeightMap, 0 );

    // Based on the grid, used for snapping the grid
    float mipUnitsPerHeightmapTexel = terrainResolution * exp2( positionAndLod.z );

    float3 localCameraPos = mul( invTransform, float4( g_vCameraPositionWs, 1.0 ) ).xyz;

    // Translation of the grid at this vertex
    float2 objectToWorld = roundToIncrement( localCameraPos.xy, mipUnitsPerHeightmapTexel );

    float3 worldPosition = float3( positionAndLod.xy * terrainResolution + objectToWorld, 0.0f );

    float2 heightUv = ( worldPosition.xy ) / ( texSize * terrainResolution );

    float flHeight = Tex2DLevelS( g_tHeightMap, g_sBilinearBorder, heightUv, 0 ).r;
    worldPosition.z = flHeight * g_flHeightScale;

    return worldPosition;
}