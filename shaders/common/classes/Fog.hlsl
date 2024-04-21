#include "vr_lighting.fxc"
#include "volumetric_fog.fxc"
#include "vr_gradient_fog.fxc"
#include "vr_cubemap_fog.fxc"

//
// Public Fog Api.
//
class Fog
{
	static float3 Apply( float3 worldPos, float2 screenPos, float3 color )
	{	
		const float3 vPositionToCameraWs = worldPos.xyz - g_vCameraPositionWs;

		color = ApplyGradientFog(color, worldPos.xyz, vPositionToCameraWs.xyz);
		color = ApplyCubemapFog(color, worldPos.xyz, vPositionToCameraWs.xyz);
		color = ApplyVolumetricFog(color, worldPos.xyz, screenPos.xy);

		return color;
	}

};
