HEADER
{
	DevShader = true;
	Version = 1;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------------
MODES
{
	Default();
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

	float4 g_vViewport < Source( Viewport ); >;
	float4 g_vInvTextureDim < Source( InvTextureDim ); SourceArg( g_tColor ); >;
	CreateTexture2D( g_tColor ) < Attribute( "Texture" ); SrgbRead( true ); Filter( Anisotropic ); >;

	RenderState( SrgbWriteEnable0, true );
	RenderState( ColorWriteEnable0, RGBA );
	RenderState( FillMode, SOLID );
	RenderState( CullMode, NONE );

	// No depth
	RenderState( DepthEnable, false );
	RenderState( DepthWriteEnable, false );
	
	#define SUBPIXEL_AA_MAGIC 0.5

	PS_OUTPUT MainPs( PS_INPUT i )
	{
		PS_OUTPUT o;
		UI_CommonProcessing_Pre( i );

		float4 vImage = Tex2D( g_tColor, i.vTexCoord.xy );
		o.vColor = vImage * i.vColor.rgba;
		return UI_CommonProcessing_Post( i, o );
	}
}
