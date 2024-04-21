HEADER
{
	DevShader = true;
	Version = 1;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------------
MODES
{
	ToolsVis();
	VrForward();
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------------
FEATURES
{
	#include "ui/features.hlsl"
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------------
COMMON
{
	#include "ui/common.hlsl"
}
  
//-------------------------------------------------------------------------------------------------------------------------------------------------------------
VS
{
	#include "ui/vertex.hlsl"  
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------------
PS
{
	#include "ui/pixel.hlsl"

	// Texture Samplers ---------------------------------------------------------------------------------------------------------------------------------------
	CreateTexture2D( g_tColor ) < Attribute( "Texture" ); SrgbRead( true ); AddressU( CLAMP ); AddressV( CLAMP ); >;

	// Always write rgba
	RenderState( ColorWriteEnable0, RGBA );
	RenderState( FillMode, SOLID );

	// Never cull
	RenderState( CullMode, NONE );

	// No depth
	RenderState( DepthWriteEnable, false );

	// Main ---------------------------------------------------------------------------------------------------------------------------------------------------

	float2 RotateTexCoord( float2 vTexCoord, float angle, float2 offset = 0.5 )
	{
		float2x2 m = float2x2( cos(angle), -sin(angle), sin(angle), cos(angle) );
		return mul( m, vTexCoord - offset ) + offset ;
	}

	PS_OUTPUT MainPs( PS_INPUT i )
	{
		PS_OUTPUT o;

		UI_CommonProcessing_Pre( i );

		float2 vTexCoord = i.vTexCoord.xy;

		float4 vColor = Tex2D( g_tColor, vTexCoord );
		float flAlphaScale = 1.0f;

		float lum = saturate(dot( float3(0.30, 0.59, 0.11), vColor.rgb ) - 0.2);
		float alpha = vColor.a;
		alpha = pow(alpha, 0.6 + (lum) * 3 );

		vColor.a = alpha * flAlphaScale;

		o.vColor = vColor;
		o.vColor.a *= i.vColor.a;

		return UI_CommonProcessing_Post( i, o );
	}
}
