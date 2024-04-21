//
// Sam: This shader is a dumpster fire from when we didn't had a nice API to iterate on shaders, don't expect good reference from this
// 		This is all being discarded soon in favour to Water2
//

HEADER
{
	Description = "Fancy Water for sbox";
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------------
MODES
{
	VrForward();
	ToolsVis( S_MODE_TOOLS_VIS );
	ToolsWireframe( "vr_tools_wireframe.shader" );
	ToolsShadingComplexity( "tools_shading_complexity.shader" );
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------------
FEATURES
{
	#include "common/features.hlsl"

	//Feature( F_CAUSTICS, 0..1, "Water" ); 		// Real time caustic simulation
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------------
COMMON
{
	#include "common/shared.hlsl"
	#include "water.shared.hlsl"

	//
	// Internal configuration
	//
	#define VS_INPUT_HAS_TANGENT_BASIS 1
	#define PS_INPUT_HAS_TANGENT_BASIS 1

	#define DEPTH_STATE_ALREADY_SET
	#define COLOR_WRITE_ALREADY_SET
	#define BLEND_MODE_ALREADY_SET

	#define USE_CUSTOM_SHADING 1
	
	//
	// Combos
	//
	DynamicCombo( D_UNDERWATER, 0..1, Sys( ALL ) );
	
	#define S_CAUSTICS 1 //, F_CAUSTICS, Sys( ALL ) );

	#define S_FOG_QUALITY 1 // 0.Cheap Fog 1.High Quality Fog
	#define S_FOG_SHADOWS 1

	//
	// Configuration
	//
	#define NO_TESSELATION D_UNDERWATER
	#define DISTANCE_BASED_TESS 1

	//
	// Parameters
	//
	float g_fPhase < Default( 6.0 ); Range( 0.0, 16.0 ); UiGroup( "Water" ); >;
	float g_fSpeed < Default( 2.0 ); Range( 0.0, 16.0 ); UiGroup( "Water" ); >;
	float g_fWeight < Default( 1.0 ); Range( 0.01, 16.0 ); UiGroup( "Water" ); >;
	float g_fScale < Default( 1.0 ); Range( 0.0, 16.0 ); UiGroup( "Water" ); >;
	float g_fAmplitude< Default( 1.0 ); Range( 0.0, 16.0 ); UiGroup( "Water" ); >;
	
	float g_fSurfaceRoughness< Default( 0.04 ); Range( 0.01, 1.0 ); UiGroup( "Water" ); >;
	
	//
	// Fog parameters
	//
	float3 g_vWaterFogColor <  UiType( Color ); Default3( 0.25, 0.3, 0.0 ); /* Thames Green™️ */ UiGroup( "Fog" );>;
	float2 g_vWaterFogDistanceFalloff < Default2( 250.f, 0.1f ); Range2( 10.0f, 0.01f, 5000.0f, 1.0f ); UiGroup( "Fog" ); >;
	
	// Attributes over dynamic combos
	bool g_bRipples< Attribute("Ripples"); Default(1); >;
	bool g_bRefraction< Attribute("Refraction"); Default(1); >;
	bool g_bReflection< Attribute("Reflection"); Default(1); >;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------------

struct VertexInput
{
	#include "common/vertexinput.hlsl"
};

struct HullInput
{
	#include "common/pixelinput.hlsl"
};

struct HullOutput
{
	#include "common/pixelinput.hlsl"
};

struct HullPatchConstants
{
	float Edge[3] : SV_TessFactor;
	float Inside : SV_InsideTessFactor;
};

struct DomainInput
{
	#include "common/pixelinput.hlsl"
};

struct PixelInput
{
	#include "common/pixelinput.hlsl"
#if ( PROGRAM == VFX_PROGRAM_PS ) 
	bool face : SV_IsFrontFace;
#endif
};

//-------------------------------------------------------------------------------------------------------------------------------------------------------------
VS
{
	#include "common/vertex.hlsl"

	PixelInput MainVs( VertexInput i )
	{
		PixelInput o = ProcessVertex( i );

		return o;
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------------
PS
{
	//
	// Combos
	//
	DynamicCombo( D_VIEW_INTERSECTING_WATER, 0..1, Sys( ALL ) ); // Todo: Underwater refraction

	//
	// Includes
	//
	#include "common/pixel.hlsl"


	// -------------------------------------------------------------------------------------------------------------------------------------------------------------

	//
	// Parameters
	//
	#if D_UNDERWATER
		RenderState( CullMode, BACK );
		
		RenderState( DepthEnable, false );
		RenderState( DepthWriteEnable, false );
	#else

		RenderState( CullMode, D_VIEW_INTERSECTING_WATER ? NONE : BACK );
		
		RenderState( DepthEnable, !D_VIEW_INTERSECTING_WATER );
	#endif

	float4 g_vViewport < Source( Viewport ); >;

	BoolAttribute( bWantsFBCopyTexture, true );
    BoolAttribute( translucent, true );

    CreateTexture2D( g_tFrameBufferCopyTexture ) < Attribute( "FrameBufferCopyTexture" ); SrgbRead( true ); Filter( MIN_MAG_MIP_LINEAR ); AddressU( CLAMP ); AddressV( CLAMP ); >;
    CreateTexture2DMS( g_tSceneDepth )           < Attribute( "DepthBuffer" );  		  SrgbRead( false ); Filter( POINT );               AddressU( MIRROR );     AddressV( MIRROR ); >;

	// -------------------------------------------------------------------------------------------------------------------------------------------------------------

	struct FogParams_t
	{
		float fFogDistance;
		float fFogFalloff;
		float3 vFogColor;
	};


	FogParams_t SetupFog()
	{
		FogParams_t o;
		
		o.vFogColor = g_vWaterFogColor * 0.1f;
		
		o.fFogDistance = g_vWaterFogDistanceFalloff.x;
		o.fFogFalloff = g_vWaterFogDistanceFalloff.y;

		return o;
	}

	// -------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	struct WaterInput
	{
		float2 vPositionUv;
		float3 vPositionWs;
		float3 vNormal;
		float3 vViewRayWs;

		float3 vRefractionRayWs;
		float3 vRefractionPosWs;
		float2 vRefractionUv;

		float fDepthSample;
		float fDepthSampleRefraction;

		float fRayDistance;
		float fVerticalDistance;

		float3 vSeamlessEntry;
	};

	// -------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	float3 EnvBRDFApprox (float3 specColor, float roughness, float ndv)
	{
		const float4 c0 = float4(-1, -0.0275, -0.572, 0.022 );
		const float4 c1 = float4(1, 0.0425, 1.0, -0.04 );
		float4 r = roughness * c0 + c1;
		float a004 = min( r.x * r.x, exp2( -9.28 * ndv ) ) * r.x + r.y;
		float2 AB = float2( -1.04, 1.04 ) * a004 + r.zw;
		return specColor * AB.x + AB.y;
	}

	//
	// Sample direct lighting from the sun on a given point
	//
	float SampleLightDirect( float3 vPosWs)
	{
		// if CSM
		//{
			//vSample = ComputeSunShadowScalar( vSampleWs );
		//}
		
		//If not CSM
		{
			int4 vLightIndices; 																	// Unused
			float4 vLightScalars; 																	// 3D lightmap for direct light
			SampleLightProbeVolumeIndexedDirectLighting( vLightIndices, vLightScalars, vPosWs ); 	// Sample it

			float fMixedShadows = 1.0f;
			// I am not 100% sure alpha channel is used for sun in every case for the global sunlight
			return vLightScalars.a * fMixedShadows;
		}
		
	}

	// -------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	float FetchDepth( PixelInput i, float2 vPositionUv )
	{
		// Return dummy depth if we don't have refraction enabled
		if( !g_bRefraction )
			return distance( g_vCameraPositionWs, i.vPositionWithOffsetWs.xyz );
		else
			return Tex2DMS( g_tSceneDepth, i.vPositionSs.xy, 0 ).x;
	}
	
	// -------------------------------------------------------------------------------------------------------------------------------------------------------------
	float3 FetchRefraction( WaterInput i )
	{

		//
		// Disable refraction if material wants so
		//
		if( !g_bRefraction )
			return float3(0, 0, 0);

		//
		// Lerp between normal ray and refraction ray in UV space based on seamless entry
		// so that view looks seamless when transitioning to water
		//
		const float2 vPositionUv = lerp( i.vPositionUv, i.vRefractionUv, i.vSeamlessEntry.x );

		return Tex2D( g_tFrameBufferCopyTexture, vPositionUv * g_vFrameBufferCopyInvSizeAndUvScale.zw ).rgb;
	}

	// -------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	//
	// Calculates the refracted angle in world space using the water index of refraction
	//
	float3 GetRefractionRay( WaterInput input )
	{
		const float fIndexOfRefraction = 1.05f;
		return normalize( refract( input.vViewRayWs, input.vNormal, 1.0f/fIndexOfRefraction ) ) * float3( 1, 1, -1 );
	}

	//
	// Transforms the refracted ray from world space to UV space
	//
	float2 GetRefractionUVFromRay( WaterInput input )
	{
		float flRefractScale = sqrt( input.fRayDistance * 2.0f );
		flRefractScale = min( flRefractScale, 512.0f );

		float3 vRefractionPos = input.vPositionWs + input.vRefractionRayWs * flRefractScale;

		// Convert our world space refracted position back into screen space
		float4 vPositionRefractPs = Position3WsToPs( vRefractionPos );
		vPositionRefractPs.xyz /= vPositionRefractPs.w;
		float2 vPositionRefractSs = PsToSs( vPositionRefractPs );
		
		vPositionRefractSs.x = 1.0 - vPositionRefractSs.x;
		return vPositionRefractSs;
	}

	
	// -------------------------------------------------------------------------------------------------------------------------------------------------------------

	//
	// Tiny detail so that water edges and view intersection are seamless
	//	
	float3 GetSeamlessEntry( PixelInput pi, WaterInput wi )
	{
		float fEdgeSeamless = saturate( wi.fRayDistance / 5.0f );
		float fCameraSeamless = saturate( smoothstep( 
			distance( g_vCameraPositionWs, wi.vPositionWs ) , 
			g_flNearPlane, 
			g_flNearPlane + 5 ) );
		
		return float3( min( fEdgeSeamless, fCameraSeamless ), fEdgeSeamless, fCameraSeamless );
	}

	// -------------------------------------------------------------------------------------------------------------------------------------------------------------

	float3 CalculateWorldSpacePosition( float3 vViewRayWs, float fDepth )
	{
		return g_vCameraPositionWs + vViewRayWs * fDepth;
	}

	WaterInput SetupWaterInput( PixelInput i, bool bUnderwater = false )
	{
		WaterInput input;

		input.vPositionUv = CalculateViewportUvFromInvSize( i.vPositionSs.xy - g_vViewportOffset.xy, g_vInvViewportSize.xy );
		input.vPositionWs = bUnderwater ? g_vCameraPositionWs : i.vPositionWithOffsetWs.xyz;
		input.vViewRayWs = CalculatePositionToCameraDirWs( i.vPositionWithOffsetWs );
		
		const float fSurfaceNdotV = dot( float3(0,0,1), input.vViewRayWs );

		input.vNormal = WaterNormal( i.vPositionWithOffsetWs.xy, 2 );

		input.fDepthSample = FetchDepth( i, input.vPositionUv );

		input.vRefractionRayWs = bUnderwater ? input.vViewRayWs : GetRefractionRay( input );
		input.vRefractionPosWs = CalculateWorldSpacePosition( input.vViewRayWs, input.fDepthSample );
	
		// Fetch closest depth sample if underwater, this way we smooth correctly towards edges
		if( bUnderwater && distance(input.vRefractionPosWs, g_vCameraPositionWs) > distance(i.vPositionWithOffsetWs.xyz, g_vCameraPositionWs) )
			input.vRefractionPosWs = i.vPositionWithOffsetWs.xyz;

		input.fRayDistance = length( input.vPositionWs - input.vRefractionPosWs ) ;
		
		input.vRefractionUv = GetRefractionUVFromRay( input );
		
		input.fDepthSampleRefraction = FetchDepth( i, input.vRefractionUv );

		input.vSeamlessEntry = GetSeamlessEntry( i, input );

		// Realign refraction ray
		if( !bUnderwater )
		{
			float fdepth2 = FetchDepth( i, input.vRefractionUv );
			input.vRefractionPosWs = CalculateWorldSpacePosition( input.vRefractionRayWs, fdepth2 );
			//input.fRayDistance = length( input.vPositionWs - input.vRefractionPosWs ) ;
		}

		input.fVerticalDistance = g_fWaterHeight - input.vRefractionPosWs.z;

		// Ugly fog clamp
		//if( bUnderwater )
		{
			FogParams_t fogParameters = SetupFog();
			[flatten]
			if( distance( input.vPositionWs, input.vRefractionPosWs ) > fogParameters.fFogDistance )
				input.vRefractionPosWs = input.vPositionWs - ( normalize(input.vRefractionRayWs) * fogParameters.fFogDistance );

			// Refresh the length of the trce
			input.fRayDistance = distance( input.vPositionWs, input.vRefractionPosWs );
			input.fVerticalDistance = g_fWaterHeight - input.vRefractionPosWs.z;
		}

		

		return input;
	}

	// -------------------------------------------------------------------------------------------------------------------------------------------------------------

	float4 MainOverwater( PixelInput i )
	{
		//
		// Setup input
		//
		WaterInput input = SetupWaterInput( i );

		//
		// Do reflection and refraction
		//
		float3 vRefraction = FetchRefraction( input );

		// Convert legacy WaterInput to Material API
		Material m = Material::Init();
        m.Albedo = 1.0f;
        m.Emission = 0.0f;
        m.Opacity = 1.0f;
        m.TintMask = 1.0f;
        m.Normal = input.vNormal;
        m.Roughness = g_fSurfaceRoughness;
        m.Metalness = 1.0f;
        m.AmbientOcclusion = 1.0f;
        m.Transmission = 0.0f;

		i.vPositionWithOffsetWs -= g_vCameraPositionWs;

		float3 vSurface = ShadingModelStandard::Shade( i, m ).xyz;

		// Shlick approximation
		float flFresnel = pow( 1.0 - saturate( dot( input.vViewRayWs, input.vNormal ) ), 5.0f ); 
		float4 vColor = float4( lerp( vRefraction, vSurface, flFresnel ), 1.0f );

		return vColor;
	}

	bool DepthTest( PixelInput i )
	{
		float fDepth = FetchDepth( i, CalculateViewportUv( i.vPositionSs.xy ) );
		fDepth = RemapValClamped( fDepth, g_flViewportMinZ, g_flViewportMaxZ, 0.0, 1.0 );

		float4 vPosPs = Position3WsToPs( i.vPositionWithOffsetWs );
		float fDepthObj = vPosPs.z / vPosPs.w;

		return fDepth > fDepthObj;
	}

	// -------------------------------------------------------------------------------------------------------------------------------------------------------------

	void PrepareWater( PixelInput i )
	{

	}

	// -------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	//
	// Shader entry point
	//
	float4 MainPs( PixelInput i ) : SV_Target0
	{
		PrepareWater(i);
		//
		// Normal water surface drawing
		//
		return MainOverwater( i );
	}
}

//=========================================================================================================================


