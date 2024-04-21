#ifndef PIXEL_RAYTRACE_SSR_H
#define PIXEL_RAYTRACE_SSR_H
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
	float flDepth = Tex2DLoad( g_tSceneDepth, int3( pixel_coordinate, mip ) ).x;
	flDepth = RemapValClamped( flDepth, g_flViewportMinZ, g_flViewportMaxZ, 0.0, 1.0 );

   return flDepth;
}

// Both are correct
float3 FFX_SSSR_ScreenSpaceToViewSpace(float3 screen_space_position) {
	return  InvProjectPosition( screen_space_position, g_matProjectionToView );
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

TraceResult_t TraceSSRWorldRay( PixelInput i, float3 vReflectWs )
{
	bool bValidHit = false;
	uint nMaxSteps = 64;
	uint nInitialMip = 0;
    bool bMipChain = true;
	const float2 vViewportSize = g_vViewportSize;

	//----------------------------------------------
    float3 vPositionWs = i.vPositionWithOffsetWs.xyz + g_vHighPrecisionLightingOffsetWs.xyz;

	//----------------------------------------------
	// Fetch depth
	// ---------------------------------------------

	// Use depth from our PixelInput
	float4 vPositionPs = Position4WsToPs( float4( vPositionWs, 1.0 ) );
	vPositionPs.z /= vPositionPs.w;

	float2 vUV = i.vPositionSs.xy * g_vInvViewportSize.xy;
    float flDepth = vPositionPs.z;
    float flDepthThickness = 20.0f;

	//---------------------------------------------
	// Build our position in clip space and reflection vector from world space ray
	// ---------------------------------------------

	float4 vPositionCs = float4( vUV.xy, flDepth, 1.0 );
	float3 vReflectCs = ProjectDirection( vPositionWs, vReflectWs, vPositionCs.xyz, g_matWorldToProjection);

	//----------------------------------------------
	// Trace the thing ;)
	// ---------------------------------------------
	float3 hit = FFX_SSSR_HierarchicalRaymarch( vPositionCs.xyz , vReflectCs.xyz, vViewportSize, nInitialMip, nMaxSteps, bMipChain, bValidHit);
	float confidence = bValidHit ? FFX_SSSR_ValidateHit( hit, vUV, vReflectWs, vViewportSize, flDepthThickness ) : 0;

	//----------------------------------------------
	// Composite result
	// ---------------------------------------------
	TraceResult_t result;
	result.vHitCs = hit;
	result.flConfidence = confidence;

	return result;
}

#endif // PIXEL_RAYTRACE_SSR_H