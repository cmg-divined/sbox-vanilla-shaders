#ifndef DEPTH_HLSL
#define DEPTH_HLSL

//
// garry: I don't want people having to define this shit in their shaeders when it's a backend, built in thing.
//		  My assumption is that if this isn't used, it'll get compiled out and no harm done.
//		  If I broke shaders that DO define this then I fucked it sorry - remove the definition in their file
//		   whtever you do, don't start a fucking DEPTH_TEXTYRE_DEFINED thing
//

// Create a texture without a sampler for the depth chain.
// This texture includes min/max coordinates of the depth in every mip level
CreateTexture2DWithoutSampler( g_tDepthChain ) < Attribute( "DepthChainDownsample" ); SrgbRead( false ); >;

//
// Public Depth API
//
class Depth
{
	// Returns the depth value at the given screen position from the depth.
	static float Get( float2 screenPosition )
	{
		return Tex2DLoad( g_tDepthChain, int3( screenPosition, 0 ) ).r;
	}

	// Normalizes a depth value to the range [0, 1] based on the viewport's min and max Z values.
	static float Normalize( float depth )
	{
		return RemapValClamped( depth, g_flViewportMinZ, g_flViewportMaxZ, 0.0, 1.0 );
	}

	// Returns the normalized depth value at the given screen position.
	static float GetNormalized( float2 screenPosition )
	{
		return Depth::Normalize( Depth::Get( screenPosition ) );
	}

	// Returns the linear depth value at the given screen position.
	static float GetLinear( float2 screenPosition )
	{
		return ConvertDepthPsToVs(Depth::Get(screenPosition) );
	}

	// Returns the world position corresponding to a given depth and direction.
	static float3 WorldPosition( float depth, float3 direction )
	{
		float3 pos = RecoverWorldPosFromProjectedDepthAndRay( Depth::Normalize( depth ), normalize( direction ) ).xyz;
		return pos;
	}

	// Returns the world position corresponding to a given screen position.
	static float3 GetWorldPosition( float2 screenPosition )
	{
		float flDepth = Depth::GetNormalized(screenPosition);

		float3 vRay = float3(screenPosition * g_vInvViewportSize, flDepth);
		vRay.y = 1.0 - vRay.y;
		vRay.xy = 2.0f * vRay.xy - 1.0f;

		float4 vWorldPos = mul(g_matProjectionToWorld, float4(vRay, 1.0f));
		vWorldPos.xyz /= vWorldPos.w;
		
		return vWorldPos.xyz + g_vCameraPositionWs;
	}
};
#endif