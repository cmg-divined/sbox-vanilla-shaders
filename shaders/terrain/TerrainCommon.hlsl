//
// Takes 8 samples
// This is easy for now, an optimization would be to generate this once in a compute shader
// Less texture sampling but higher memory requirements
// This is between -1 and 1;
//
float3 Terrain_Normal( Texture2D HeightMap, float2 uv, out float3 TangentU, out float3 TangentV )
{
    float2 texelSize = 1.0f / (float2)TextureDimensions2D( HeightMap, 0 );

    float tl = abs( Tex2DLevelS( HeightMap, g_sBilinearBorder, uv + texelSize * float2( 1, -1 ), 0 ).r );
    float  l = abs( Tex2DLevelS( HeightMap, g_sBilinearBorder, uv + texelSize * float2( 1,  0 ), 0 ).r );
    float bl = abs( Tex2DLevelS( HeightMap, g_sBilinearBorder, uv + texelSize * float2( 1,  1 ), 0 ).r );
    float  t = abs( Tex2DLevelS( HeightMap, g_sBilinearBorder, uv + texelSize * float2(  0, -1 ), 0 ).r );
    float  b = abs( Tex2DLevelS( HeightMap, g_sBilinearBorder, uv + texelSize * float2(  0,  1 ), 0 ).r );
    float tr = abs( Tex2DLevelS( HeightMap, g_sBilinearBorder, uv + texelSize * float2(  -1, -1 ), 0 ).r );
    float  r = abs( Tex2DLevelS( HeightMap, g_sBilinearBorder, uv + texelSize * float2(  -1,  0 ), 0 ).r );
    float br = abs( Tex2DLevelS( HeightMap, g_sBilinearBorder, uv + texelSize * float2(  -1,  1 ), 0 ).r );

    // Compute dx using Sobel:
    //           -1 0 1 
    //           -2 0 2
    //           -1 0 1
    float dX = tr + 2*r + br -tl - 2*l - bl;

    // Compute dy using Sobel:
    //           -1 -2 -1 
    //            0  0  0
    //            1  2  1
    float dY = bl + 2*b + br -tl - 2*t - tr;

    // this is how i got this number, and it matches up with other objects geo normals
    // size per texel: terrain height ( 20000 ) / height map size ( 513 ) = 39
    // 39 * 2 = 78
    // nonsense
    float normalStrength = 78;
    float3 normal = normalize( float3( dX, dY * -1, 1.0f / normalStrength ) );

    TangentU = normalize( cross( normal, float3( 0, -1, 0 ) ) ); 
    TangentV = normalize( cross( normal, -TangentU ) );

    return normal;
}

//
// Nice box filtered checkboard pattern, useful when you have no textures
//
void Terrain_ProcGrid( in float2 p, out float3 albedo, out float roughness )
{
    p /= 64;

    float2 w = fwidth( p ) + 0.001;
    float2 i = 2.0 * ( abs( frac( ( p - 0.5 * w ) * 0.5 ) - 0.5 ) - abs( frac( ( p + 0.5 * w ) * 0.5 ) - 0.5 ) ) / w;
    float v = ( 0.5 - 0.5 * i.x * i.y );

    albedo = 0.7f + v * 0.3f;
    roughness = 0.8f + ( 1 - v ) * 0.2f;
}

float4 Terrain_Debug( PixelInput i, Material m )
{
    if ( g_nDebugView == 1 )
    {
        float3 hsv = float3( i.LodLevel / 10.0f, 1.0f, 0.8f );
        return float4( SrgbGammaToLinear( HsvToRgb( hsv ) ), 1.0f );
    }

    if ( g_nDebugView == 2 )
    {
        return float4( Tex2DS( g_tControlMap, g_sBilinearBorder, m.TextureCoords ).a, 0.0f, 0.0f, 1.0f );
    }        

    return float4( 0, 0, 0, 1 );
}

// black wireframe if we're looking at lods, otherwise lod color
float4 Terrain_WireframeColor( uint lodLevel )
{       
    return ( g_nDebugView == 1 ) ? float4( 0, 0, 0, 1 ) : float4( SrgbGammaToLinear( HsvToRgb( float3( lodLevel / 10.0f, 0.6f, 1.0f ) ) ), 1.0f );
}