#ifndef LIGHTBINNER_HLSL
#define LIGHTBINNER_HLSL
//-----------------------------------------------------------------------------
// Light Buffer
//-----------------------------------------------------------------------------


#define VIEWLIGHTING_FLAGS_NO_LIGHTMAP_DIRECTIONALITY 0x1  // lightmap disabled
#define VIEWLIGHTING_FLAGS_USE_HBAO 0x2                    // use HBAO instead of AOProxies

#define LIGHT_FLAGS_VISIBLE 0x1                 // visible ( For GPU culling )
#define LIGHT_FLAGS_DIFFUSE_ENABLED 0x2         // diffuse enabled
#define LIGHT_FLAGS_SPECULAR_ENABLED 0x4        // specular enabled
#define LIGHT_FLAGS_TRANSMISSIVE_ENABLED 0x8    // transmissive enabled
#define LIGHT_FLAGS_SHADOW_ENABLED 0x10         // shadow enabled
#define LIGHT_FLAGS_SCREENSPACE_SHADOWS 0x20    // screenspace shadows enabled
#define LIGHT_FLAGS_LIGHT_COOKIE_ENABLED 0x40   // light cookie enabled
#define LIGHT_FLAGS_FRUSTUM_FEATHERING 0x80     // frustum feathering enabled

#define ENVMAP_FLAGS_NO_PARALLAX 0x1         // no parallax

#define LIGHT_SHAPE_SPHERE 		0
#define LIGHT_SHAPE_CAPSULE		1
#define LIGHT_SHAPE_RECTANGLE	2

#define LIGHTCOOKIE_NUM_SLICES 16

// These two max constants are only really useful for tiled rendering, make them
// programatic later when we do dynamic allocation of lights
#define MAX_LIGHTS 2048
#define MAX_ENVMAPS 256

#define MAX_LIGHTS_PER_TILE 64
#define MAX_ENVMAPS_PER_TILE 32

#define MAX_SHADOW_FRUSTA_PER_LIGHT 6

//-----------------------------------------------------------------------------

cbuffer ViewLightingConfig
{
    int4 ViewLightingFlags;
    int4 NumLights;                     // x - num dynamic lights, y - num baked lights, z - num fog lights, w - num envmaps 

    int4 BakedLightIndexMapping[256];   // Remaps baked lights index to the light pool list for fast
                                        // query on the shader, we have a hard limit of 256 baked lights

    float4 Shadow3x3PCFConstants[4]; // float4( 1.0 / 267.0, 7.0 / 267.0, 4.0 / 267.0, 20.0 / 267.0 );
                                     // float4( 33.0 / 267.0, 55.0 / 267.0, -flTexelEpsilon, 0.0 );
                                     // float4( flTwoTexelEpsilon, -flTwoTexelEpsilon, 0.0, flTexelEpsilon );
                                     // float4( flTexelEpsilon, -flTexelEpsilon, flTwoTexelEpsilon, -flTwoTexelEpsilon );

    float4 EnvironmentMapSizeConstants; // x = size, y = log2( size ) - 3, z = log2( size ), all envmaps are the same size, so only one copy of SizeConstants.

    float4 AmbientLightingSH[3]; // 3rd order spherical harmonics for ambient lighting

    #define NumDynamicLights        NumLights.x
    #define NumBakedIndexedLights   NumLights.y
    #define NumEnvironmentMaps      NumLights.z
};

//-----------------------------------------------------------------------------

class BinnedLight
{
    int4 Params;                           // x = num sequential frusta, y = unused, z = flags, w = light type
    float4 Color;                          // w - inverse radius ( Never really used?? )
    float4 FalloffParams;                  // x - Linear falloff, y - quadratic falloff, z - radius squared for culling, w - truncation
    float4 SpotLightInnerOuterConeCosines; // x - inner cone, y - outer cone, z - reciprocal between inner and outer angle, w - Tangent of outer angle
    float4 Shape;                          // xy - size,  zw - unused

    float4x4 LightToWorld;

    // Shadow
    float4 ShadowBounds   [ MAX_SHADOW_FRUSTA_PER_LIGHT ];
    float4 ShadowVigniette[ MAX_SHADOW_FRUSTA_PER_LIGHT ];
    float4x4 WorldToShadow[ MAX_SHADOW_FRUSTA_PER_LIGHT ];
    float4 ProjectedShadowDepthToLinearDepth; // Assume all frusta have the same depth range

    float4x4 WorldToLightCookie; // We keep it separate from WorldToLight so that this can be used for cloud layers, etc

	// ---------------------------------

    uint    NumShadowFrusta()      { return Params.x; }
    
	float3 GetPosition() 			{ return LightToWorld[3].xyz; }
	float3 GetDirection() 			{ return LightToWorld[0].xyz; }
	float3 GetDirectionUp() 		{ return LightToWorld[1].xyz; }
	float3 GetColor() 			    { return Color.xyz; }

	float GetLinearFalloff() 		{ return FalloffParams.x; }
	float GetQuadraticFalloff() 	{ return FalloffParams.y; }
	float GetRadiusSquared() 		{ return FalloffParams.z; }
	float GetInverseRadius() 		{ return Color.w; }

	float2 GetShapeSize() 			{ return Shape.xy; }
	uint   GetType() 				{ return Params.z; }

    bool IsSpotLight()              { return ( SpotLightInnerOuterConeCosines.x != 0.0f ); }

	// ---------------------------------

    bool IsVisible()                { return ( Params.z & LIGHT_FLAGS_VISIBLE ) != 0; }
    bool IsDiffuseEnabled()         { return ( Params.z & LIGHT_FLAGS_DIFFUSE_ENABLED ) != 0; }
    bool IsSpecularEnabled()        { return ( Params.z & LIGHT_FLAGS_SPECULAR_ENABLED ) != 0; }
	bool IsTransmissiveEnabled() 	{ return ( Params.z & LIGHT_FLAGS_TRANSMISSIVE_ENABLED ) != 0; }
    bool HasDynamicShadows() 	    { return ( Params.z & LIGHT_FLAGS_SHADOW_ENABLED ) != 0; }
    bool HasLightCookie()           { return ( Params.z & LIGHT_FLAGS_LIGHT_COOKIE_ENABLED ) != 0; }
    bool HasFrustumFeathering()     { return ( Params.z & LIGHT_FLAGS_FRUSTUM_FEATHERING ) != 0; }
};

class BinnedEnvMap
{
    float4x3 WorldToLocal;
    float4 BoxMins;
    float4 BoxMaxs;
    float4 Color; // w - feathering
    float4 NormalizationSH;
    uint4   Attributes; // x = cubemap index, y = flags (future), z = unused, w = unused

    // ---------------------------------

    uint GetCubemapIndex() { return Attributes.x; }
};


//-----------------------------------------------------------------------------

bool IsLightMapDirectionalityDisabled()
{
    return false; //(LightDataFlags.x & LIGHTDATA_FLAGS_NO_LIGHTMAP_DIRECTIONALITY) != 0;
}

//-----------------------------------------------------------------------------

StructuredBuffer<BinnedLight>    BinnedLightBuffer    < Attribute( "BinnedLightBuffer" );  > ;
StructuredBuffer<BinnedEnvMap>   BinnedEnvMapBuffer   < Attribute( "BinnedEnvMapBuffer" ); > ;

BinnedLight DynamicLightConstantByIndex( int index )
{
    return BinnedLightBuffer[ index ];
}

BinnedLight BakedIndexedLightConstantByIndex( int index )
{
    return BinnedLightBuffer[ BakedLightIndexMapping[index].x ];
}

BinnedEnvMap EnvironmentMapConstantByIndex( int index )
{
    return BinnedEnvMapBuffer[ index ];
}

//-----------------------------------------------------------------------------

#include "common/light.tiledrendering.hlsl"

//-----------------------------------------------------------------------------

#endif // LIGHTBINNER_HLSL