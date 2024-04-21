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

	// Texture Samplers ---------------------------------------------------------------------------------------------------------------------------------------
	CreateTexture2D( g_tColor ) < Attribute( "Texture" ); SrgbRead( true ); Default( 1.0 ); AddressU( BORDER ); AddressV( BORDER ); >;
	float4 g_vInvTextureDim < Source( InvTextureDim ); SourceArg( g_tColor ); >;

	//
	// Drop-shadow specifics
	//
	float2 FilterDropShadowOffset < UiType( Slider ); Default2( 0.0f, 0.0f ); Attribute( "FilterDropShadowOffset" ); >;
	float FilterDropShadowBlur < UiType( Slider ); Default( 0.0f ); Attribute( "FilterDropShadowBlur" ); >;
	float4 FilterDropShadowColor < UiType( Color ); Default4( 0.0f, 0.0f, 0.0f, 1.0f ); Attribute( "FilterDropShadowColor" ); >;
	float2 FilterDropShadowScale < UiType( Slider ); Default2( 1.0f, 1.0f ); Attribute( "FilterDropShadowScale" ); >;

	// Always write rgba
	RenderState( ColorWriteEnable0, RGBA );
	RenderState( FillMode, SOLID );

	// Never cull
	RenderState( CullMode, NONE );

	// No depth
	RenderState( DepthWriteEnable, false );

	// Main ---------------------------------------------------------------------------------------------------------------------------------------------------

	float4 FetchLayeredTexel( float2 uv )
	{
		float4 vColor = Tex2D( g_tColor, uv );
		return vColor;
	}

	float4 DoBlur( float4 color, float2 uv, float2 size ) 
	{
		float Pi = M_PI * 2;
		float Directions = 16.0; // BLUR DIRECTIONS (Default 16.0 - More is better but slower)
		float Quality = 4.0; // BLUR QUALITY (Default 4.0 - More is better but slower)
	
		// Blur calculations
		for( float d=0.0; d<Pi; d+=Pi/Directions)
		{
			for(float j=1.0/Quality; j<=1.0; j+=1.0/Quality)
			{
				color += FetchLayeredTexel( uv + float2( cos(d), sin(d) ) * size * j );	
			}
		}
		
		// Output to screen
		color /= Quality * Directions - 15.0;

		return color;
	}

	PS_OUTPUT MainPs( PS_INPUT i )
	{
		PS_OUTPUT o;

		UI_CommonProcessing_Pre( i );

		//
		// Calculate texcoords
		// 
		float2 texCoord = i.vTexCoord.xy;

		// Scale down UVs based on the blur
		if ( FilterDropShadowBlur > 0 )
		{
			float2 scale = FilterDropShadowScale;

			// Center texcoords
			texCoord = texCoord - ( 1.0f - scale ) * 0.5f;
			texCoord = texCoord / scale;
		}
		
		o.vColor = FetchLayeredTexel( texCoord );

		//
		// Drop shadow
		//
		if ( FilterDropShadowBlur > 0 )
		{
			// Sample alpha from g_tColor with offset
			float4 vShadow = FetchLayeredTexel( texCoord - FilterDropShadowOffset * g_vInvTextureDim.xy ).a;
			float4 vShadowColor = FilterDropShadowColor;
			vShadowColor.a *= DoBlur( vShadow, texCoord - FilterDropShadowOffset * g_vInvTextureDim.xy, FilterDropShadowBlur * g_vInvTextureDim.xy ).a;

			// Blend with original color
			o.vColor = vShadowColor;
		}
		
		return UI_CommonProcessing_Post( i, o );
	}
}
