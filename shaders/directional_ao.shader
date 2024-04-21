HEADER
{
	DevShader = true;
	Description = "Directional Soft Shadows";
	Version = 1;
}

//=========================================================================================================================

MODES
{
	Default();
}

//=========================================================================================================================

FEATURES
{
}

//=========================================================================================================================

COMMON
{
	#include "system.fxc" // This should always be the first include in COMMON
	#include "vr_common.fxc" 

	#define AOPROXY_SHAPE_CAPSULE 0
	#define AOPROXY_SHAPE_BOX 1
	#define AOPROXY_SHAPE_CYLINDER 2

	//-----------------------------------------------------------------------------------------------------------------
	//
	// Constant Buffers
	//
	//-----------------------------------------------------------------------------------------------------------------

	cbuffer AoProxyConstantBuffer_t
	{
		#define AOPROXY_MAX_INSTANCES 20
		#define AOPROXY_MAX_PROXIES 108

		// Per-instance
		float4 g_vMinBounds[AOPROXY_MAX_INSTANCES];
		float4 g_vMaxBounds[AOPROXY_MAX_INSTANCES];
		float4 g_vAoProxyParams[AOPROXY_MAX_INSTANCES]; // x = fade strength
		int4 g_nProxyCounts[AOPROXY_MAX_INSTANCES]; // x = start capsule, y = start box, z = start cylinder, w = end

		// Per-proxy
		float4x3 g_matWorldToProxy[AOPROXY_MAX_PROXIES];
		float4 g_vProxyScale[AOPROXY_MAX_PROXIES]; // For capsules: x - length, y - radius
	};
}

//=========================================================================================================================

struct VS_INPUT
{
	float3 vPositionOs			: POSITION	< Semantic( PosXyz ); >;
	uint nInstanceTransformID	: TEXCOORD13 < Semantic( InstanceTransformUv ); >;
	uint nInstanceID			: SV_InstanceID < Semantic( None ); >;
};

//=========================================================================================================================

struct PS_INPUT
{
	float4 vWorldToBoxOffsetAndFade	: TEXCOORD0;
	float3 vWorldToBoxScale			: TEXCOORD1;
	float3 vCameraToPositionRayWs	: TEXCOORD4;

	nointerpolation uint4 nProxyIndices : TEXCOORD5;

	// VS only
	#if ( PROGRAM == VFX_PROGRAM_VS )
		float4 vPositionPs		: SV_Position;
	#endif

	// PS only
	#if ( ( PROGRAM == VFX_PROGRAM_PS ) )
		float4 vPositionSs		: SV_Position;
	#endif
};

//=========================================================================================================================

VS
{
	//-----------------------------------------------------------------------------------------------------------------
	//
	// Includes
	//
	//-----------------------------------------------------------------------------------------------------------------

	#include "sheet_sampling.fxc"
	#include "instancing.fxc"
	#include "vr_lighting.fxc"

	//-----------------------------------------------------------------------------------------------------------------
	//
	// Combos 
	//
	//-----------------------------------------------------------------------------------------------------------------

	DynamicComboRule( Allow0( D_SKINNING ) );
	DynamicCombo( D_BAKED_LIGHTING_FROM_PROBE, 0..1, Sys( ALL ) );
	
	//-----------------------------------------------------------------------------------------------------------------
	//
	// Main
	//
	//-----------------------------------------------------------------------------------------------------------------

	PS_INPUT MainVs( VS_INPUT i )
	{
		PS_INPUT o;

		uint nInstanceID = i.nInstanceID;

		float3 vMinBounds = g_vMinBounds[nInstanceID].xyz;
		float3 vMaxBounds = g_vMaxBounds[nInstanceID].xyz;

		float3 vVertexPosWs = lerp( vMinBounds.xyz, vMaxBounds.xyz, 2.0 * i.vPositionOs.xyz );
		o.vPositionPs.xyzw = Position3WsToPs( vVertexPosWs.xyz );
		o.vCameraToPositionRayWs.xyz = CalculateCameraToPositionRayWs( vVertexPosWs.xyz );

		// Assuming no rotation
		o.vWorldToBoxScale.xyz = float3( 2.0, 2.0, 2.0 ) / ( vMaxBounds.xyz - vMinBounds.xyz );
		o.vWorldToBoxOffsetAndFade.xyz = -0.5 * ( vMinBounds.xyz + vMaxBounds.xyz ) * o.vWorldToBoxScale.xyz;
		o.vWorldToBoxOffsetAndFade.w = g_vAoProxyParams[nInstanceID].x;

		// Proxy array indices
		o.nProxyIndices = g_nProxyCounts[nInstanceID];

		return o;
	}
}

//=========================================================================================================================

PS
{
	#include "raytracing/sdf.hlsl"
	#include "vr_lighting.fxc"

	// Attributes
	BoolAttribute( decal, true );
	BoolAttribute( ambientocclusionproxy, true );
	CreateTexture2D( g_tSceneDepth ) < Attribute( "SceneDepth" ); SrgbRead( false ); Filter( MIN_MAG_MIP_POINT ); AddressU( CLAMP ); AddressV( CLAMP ); >;

	// Render States
	#define BLEND_MODE_ALREADY_SET
	RenderState( BlendEnable, true );
	RenderState( BlendOp, ADD );
	RenderState( SrcBlend, ZERO );
	RenderState( DstBlend, SRC_COLOR );
	RenderState( BlendOpAlpha, ADD );
	RenderState( SrcBlendAlpha, ZERO );
	RenderState( DstBlendAlpha, SRC_ALPHA );

	#define DEPTH_STATE_ALREADY_SET
	RenderState( CullMode, FRONT );
	RenderState( DepthEnable, true );
	RenderState( DepthWriteEnable, false );
	RenderState( DepthFunc, GREATER );



	//-----------------------------------------------------------------------------------------------------------------
	float CalculateDistanceForShape( float3 vPositionWs, int nStart, int nEnd, int nShape )
	{
		float distance = 99999;
		for ( int j = nStart; j < nEnd; j++ )
		{
			if( nShape == AOPROXY_SHAPE_CAPSULE )
			{
				const float fRadius = g_vProxyScale[j].y;
				const float3 fLength = float3( g_vProxyScale[j].x,0,0);
				float3 p = mul( float4( vPositionWs.xyz, 1.0 ), g_matWorldToProxy[j] ).xyz;
				
				distance = min( distance, sdCapsule( p, -fLength, fLength, fRadius ) );
			}
			else if ( nShape == AOPROXY_SHAPE_BOX )
			{
				float3 p = mul( float4( vPositionWs.xyz, 1.0 ), g_matWorldToProxy[j] ).xyz;
				distance = min( distance, sdBox( p, g_vProxyScale[j].xyz ) );
			}
			else if ( nShape == AOPROXY_SHAPE_CYLINDER )
			{
				float3 p = mul( float4( vPositionWs.xyz, 1.0 ), g_matWorldToProxy[j] ).zxy;
				distance = min( distance, sdCylinder( p,  g_vProxyScale[j].y,  g_vProxyScale[j].x ) );
			}
		}

		return distance;
	}


	//-----------------------------------------------------------------------------------------------------------------
	float Map( float3 vPositionWs, uint4 nProxyIndices )
	{
		float distance = 99999;
		distance = min( distance, CalculateDistanceForShape( vPositionWs.xyz, nProxyIndices.x, nProxyIndices.y, AOPROXY_SHAPE_CAPSULE  ) ); // Capsules
		distance = min( distance, CalculateDistanceForShape( vPositionWs.xyz, nProxyIndices.y, nProxyIndices.z, AOPROXY_SHAPE_BOX  ) ); // Boxes
		distance = min( distance, CalculateDistanceForShape( vPositionWs.xyz, nProxyIndices.z, nProxyIndices.w, AOPROXY_SHAPE_CYLINDER  ) ); // Cylinder

		return distance;
	}

	
	float4 CalculateAmbientLightDirectionSmoothed( float3 vPositionWs )
	{
		//return CalculateAmbientLightDirection( vPositionWs );
		// This sucks, but deriving directionality from the voxel lighting can get noisy if not compiled with full
		float3 vTotalNormals = 0;
		float flTotalWeight = 0;
		float k = 0.0f;
		[unroll]
		for( int x=-1;x<1;x++ )
		{
			[unroll]
			for( int y=-1;y<1;y++ )
			{
				[unroll]
				for( int z=-1;z<1;z++ )
				{
					float4 vNormal = CalculateAmbientLightDirection( vPositionWs + ( ( float3( x , y, z ) + 0.5f ) * 16.0f ) );
					vTotalNormals += vNormal.xyz;
					flTotalWeight += vNormal.w;
					k += 1.0f;
				}
			}
		}
		return float4( normalize( vTotalNormals ), flTotalWeight / k );
	}

	float CalculateDistanceForShapes( PS_INPUT i, float3 vPositionWs, uint4 nProxyIndices )
    {
        const float4 directionAndLength = CalculateAmbientLightDirectionSmoothed(vPositionWs);
        const float3 ro = vPositionWs;
        const float3 rd = directionAndLength.xyz;
		const float flSharpness = 1.0 / max( directionAndLength.w, 0.01f );

		float t = 0.0;
		float dist = Map( ro+t*rd, nProxyIndices );
		float fac = 1.0;

		const int nSteps = 20;

		for (int j=0; j<nSteps; j++) 
		{
			t += max( dist, 0.2f );
			dist = Map(ro + t*rd, nProxyIndices);
			fac = min(fac, dist * flSharpness / t );

            if (dist < -0.35 || t > 100.0)
            {
                break;
			}
		}

        float shadow = RemapValClamped( fac, -0.15, 0.3f, 0.0, 1.0 );
		return shadow;
	}

	//-----------------------------------------------------------------------------------------------------------------
	//
	// Main 
	//
	//-----------------------------------------------------------------------------------------------------------------
	float4 MainPs( PS_INPUT i ) : SV_Target0
	{
		uint4 nProxyIndices = i.nProxyIndices;
		
		int2 vDestPixel = int2( i.vPositionSs.xy );

		float flDepth = Tex2DLoad( g_tSceneDepth, int3( vDestPixel.xy, 0 ) ).x;

		float3 vCameraToPositionRayWs = i.vCameraToPositionRayWs.xyz;
		float3 vPositionWs = CalculateWorldSpacePosition( vCameraToPositionRayWs.xyz, flDepth );
		float3 vPositionDelta = mad( vPositionWs.xyz, i.vWorldToBoxScale.xyz, i.vWorldToBoxOffsetAndFade.xyz );

		// Vignette the effect to avoid hard edges
		float3 vVignette = float3( 1.0, 1.0, 1.0 ) - abs( vPositionDelta );
		float flVignette = saturate( 3.0 * min( vVignette.x, min( vVignette.y, vVignette.z ) ) );

        // Adjust the blending factor to consider the inverse square falloff
        float flVignetteWeight = sqrt( saturate( 2.0f / Map( vPositionWs.xyz, nProxyIndices ) ) ) * flVignette;

        // Don't render if we're outside the box
        clip(flVignetteWeight - 0.01);

        float flShadow = CalculateDistanceForShapes(i, vPositionWs.xyz, nProxyIndices);

        float flResult = lerp(1.0f, flShadow, sqrt( flVignetteWeight ) * i.vWorldToBoxOffsetAndFade.w);

		return float4( flResult, flResult, flResult, 1.0 );
	}
}

//=========================================================================================================================
