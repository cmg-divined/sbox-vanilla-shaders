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

	DynamicCombo( D_TEXTURE_FILTERING, 0..3, Sys( PC ) ); // Anisotropic = 0, Bilinear = 1, Trilinear = 2, Point = 3

	float4 g_vViewport < Source( Viewport ); >; 

	// Texture Samplers ---------------------------------------------------------------------------------------------------------------------------------------
	CreateTexture2D( g_tColor ) < Attribute( "Texture" ); SrgbRead( true ); AddressU( MIRROR ); AddressV( MIRROR ); >;
	float4 g_vInvTextureDim < Source( InvTextureDim ); SourceArg( g_tColor ); >;

	//
	// Filters
	//
	float FilterBrightness< UiType( Slider ); Default( 1.0f ); Attribute( "FilterBrightness" ); >;
	float FilterHueRotate < UiType( Slider ); Default( 0.0f ); Attribute( "FilterHueRotate" ); >;
	float FilterBlur < UiType( Color ); Default( 0 ); Attribute( "FilterBlur" ); >;
	float FilterSaturate< UiType( Slider ); Default( 1.0f ); Attribute( "FilterSaturate" ); >;
	float FilterSepia< UiType( Slider ); Default( 0.0f ); Attribute( "FilterSepia" ); >;
	float FilterInvert< UiType( Slider ); Default( 0.0f ); Attribute( "FilterInvert" ); >;
	float FilterContrast< UiType( Slider ); Default( 1.0f ); Attribute( "FilterContrast" ); >;
	float4 FilterTint< UiType( Color ); Default4(1.0f, 1.0f, 1.0f, 1.0f); Attribute("FilterTint"); >;

	//
	// Masking
	//
	CreateTexture2D( g_tMask ) < Attribute( "MaskTexture" ); SrgbRead( true ); AddressU( CLAMP ); AddressV( CLAMP ); BorderColor( float4( 0, 0, 0, 0 ) ); >;
	DynamicCombo( D_MASK_IMAGE, 0..1, Sys( PC ) ); // Use Mask Image = 1
	int MaskMode <Attribute( "MaskMode" );>;
	int MaskRepeat <Attribute( "MaskRepeat" );>;
	int MaskScope <Attribute( "MaskScope" );>; // 0 = Default, 1 = Filter
	float MaskAngle < Default( 0.0 ); Attribute( "MaskAngle" ); >;

	// Texture filtering modes
	#if D_TEXTURE_FILTERING == 0
		SamplerState g_sRepeatSampler < Filter( Anisotropic ); AddressU( WRAP ); AddressV( WRAP ); >;
		SamplerState g_sRepeatXSampler < Filter( Anisotropic ); AddressU( WRAP ); AddressV( CLAMP ); >;
		SamplerState g_sRepeatYSampler < Filter( Anisotropic ); AddressU( CLAMP ); AddressV( WRAP ); >;
		SamplerState g_sClampSampler < Filter( Anisotropic ); AddressU( CLAMP ); AddressV( CLAMP ); >;
		SamplerState g_sBorderSampler < Filter( Anisotropic ); AddressU( BORDER ); AddressV( BORDER ); BorderColor( float4( 0, 0, 0, 0 ) ); >;
	#elif D_TEXTURE_FILTERING == 1
		SamplerState g_sRepeatSampler < Filter( Bilinear ); AddressU( WRAP ); AddressV( WRAP ); >;
		SamplerState g_sRepeatXSampler < Filter( Bilinear ); AddressU( WRAP ); AddressV( CLAMP ); >;
		SamplerState g_sRepeatYSampler < Filter( Bilinear ); AddressU( CLAMP ); AddressV( WRAP ); >;
		SamplerState g_sClampSampler < Filter( Bilinear ); AddressU( CLAMP ); AddressV( CLAMP ); >;
		SamplerState g_sBorderSampler < Filter( Bilinear ); AddressU( BORDER ); AddressV( BORDER ); BorderColor( float4( 0, 0, 0, 0 ) ); >;
	#elif D_TEXTURE_FILTERING == 2
		SamplerState g_sRepeatSampler < Filter( Trilinear ); AddressU( WRAP ); AddressV( WRAP ); >;
		SamplerState g_sRepeatXSampler < Filter( Trilinear ); AddressU( WRAP ); AddressV( CLAMP ); >;
		SamplerState g_sRepeatYSampler < Filter( Trilinear ); AddressU( CLAMP ); AddressV( WRAP ); >;
		SamplerState g_sClampSampler < Filter( Trilinear ); AddressU( CLAMP ); AddressV( CLAMP ); >;
		SamplerState g_sBorderSampler < Filter( Trilinear ); AddressU( BORDER ); AddressV( BORDER ); BorderColor( float4( 0, 0, 0, 0 ) ); >;
	#else
		SamplerState g_sRepeatSampler < Filter( Point ); AddressU( WRAP ); AddressV( WRAP ); >;
		SamplerState g_sRepeatXSampler < Filter( Point ); AddressU( WRAP ); AddressV( CLAMP ); >;
		SamplerState g_sRepeatYSampler < Filter( Point ); AddressU( CLAMP ); AddressV( WRAP ); >;
		SamplerState g_sClampSampler < Filter( Point ); AddressU( CLAMP ); AddressV( CLAMP ); >;
		SamplerState g_sBorderSampler < Filter( Point ); AddressU( BORDER ); AddressV( BORDER ); BorderColor( float4( 0, 0, 0, 0 ) ); >;
	#endif
	float4 MaskPos < Default4( 0.0, 0.0, 500.0, 100.0 ); Attribute( "MaskPos" ); >;

	// Always write rgba
	RenderState( ColorWriteEnable0, RGBA );
	RenderState( FillMode, SOLID );

	// Never cull
	RenderState( CullMode, NONE );

	// No depth
	RenderState( DepthWriteEnable, false );

	// Main ---------------------------------------------------------------------------------------------------------------------------------------------------

	// https://drafts.fxtf.org/filter-effects/#elementdef-fecolormatrix
	float4 DoColorMatrix( float4 color, float4x4 mColorMatrix )
	{
		return saturate(mul(mColorMatrix, color));
	}

	float3 DoColorMatrix( float3 color, float4x4 mColorMatrix )
	{
		return mul(mColorMatrix, float4( color, 1.0f )).rgb;
	}

	float GetLuminance( float3 vColor )
	{
		// Convert to XYZ color space, but only the Y component
		return dot( vColor, float3( 0.2126729f, 0.7151522f, 0.0721750f ) );
	}

	float4 FetchLayeredTexel( float2 uv )
	{
		float4 vColor = Tex2D( g_tColor, uv );

		// Contrast
		vColor.rgb = saturate( (vColor.rgb - 0.5f) * FilterContrast + 0.5f );

		// Sepia
		vColor = DoColorMatrix (
			vColor, 
			float4x4(
				0.393f + 0.607f * (1.0f - FilterSepia), 0.769f - 0.769f * (1.0f - FilterSepia), 0.189f - 0.189f * (1.0f - FilterSepia), 0.0f,
				0.349f - 0.349f * (1.0f - FilterSepia), 0.686f + 0.314f * (1.0f - FilterSepia), 0.168f - 0.168f * (1.0f - FilterSepia), 0.0f,
				0.272f - 0.272f * (1.0f - FilterSepia), 0.534f - 0.534f * (1.0f - FilterSepia), 0.131f + 0.869f * (1.0f - FilterSepia), 0.0f,
				0.0f, 0.0f, 0.0f, 1.0f
			)
		);

		// Invert
		vColor.rgb = lerp( vColor.rgb, 1.0f - vColor.rgb, FilterInvert );

		float3 vHsvColor = RgbToHsv( vColor.rgb );
		vHsvColor.r = frac( vHsvColor.r + ( FilterHueRotate / 360.0f ) );
		vHsvColor.g = lerp( 0.0f, vHsvColor.g, FilterSaturate );
		vHsvColor.b *= FilterBrightness;

		vColor.rgb = HsvToRgb( vHsvColor );

		return vColor * FilterTint;
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

	float2 RotateTexCoord( float2 vTexCoord, float angle, float2 offset = 0.5 )
	{
		float2x2 m = float2x2( cos(angle), -sin(angle), sin(angle), cos(angle) );
		return mul( m, vTexCoord - offset ) + offset ;
	}

	PS_OUTPUT MainPs( PS_INPUT i )
	{
		PS_OUTPUT o;

		UI_CommonProcessing_Pre( i );
		o.vColor = FetchLayeredTexel( i.vTexCoord.xy );

		//
		// Blur
		//
		if ( FilterBlur > 0 ) 
		{
        	o.vColor = DoBlur( o.vColor, i.vTexCoord.xy, FilterBlur * g_vInvTextureDim.xy );
		}

		//
		// Masking
		//
		if ( D_MASK_IMAGE == 1 )
		{
			float2 maskSize = MaskPos.zw;
			float2 vOffset = MaskPos.xy / maskSize;
			
			float2 vUV = -vOffset + ( ( i.vTexCoord.xy ) * ( BoxSize / maskSize ) );
			vUV = RotateTexCoord( vUV, MaskAngle );

			//
			// Sample from mask image
			//
			float4 vMask;

 			// Repeat = 0, RepeatX = 1, RepeatY = 2, NoRepeat = 3, Clamp = 4
			if ( MaskRepeat == 0 )
				vMask = AttributeTex2DS( g_tMask, g_sRepeatSampler, vUV );
			else if ( MaskRepeat == 1 )
				vMask = AttributeTex2DS( g_tMask, g_sRepeatXSampler, vUV );
			else if ( MaskRepeat == 2 )
				vMask = AttributeTex2DS( g_tMask, g_sRepeatYSampler, vUV );
			else if ( MaskRepeat == 3 )
				vMask = AttributeTex2DS( g_tMask, g_sBorderSampler, vUV );
			else
				vMask = AttributeTex2DS( g_tMask, g_sClampSampler, vUV );

			//
			// Figure out what we should use as the mask value
			//
			float mask = 1.0f;
			if ( MaskMode == 0 || MaskMode == 2 ) // MatchSource || Luminance
			{
				// MatchSource todo?
				mask = GetLuminance( vMask.xyz );
			}
			else if ( MaskMode == 1 ) // Alpha
			{
				mask = vMask.a; 
			}

			if ( MaskScope == 0 )
			{
				o.vColor.a *= mask;
			}
			else if ( MaskScope == 1 )
			{
				// Sample from original texture, we're using a mask-scope value of "filter"
				// so we use this for blending
				float4 origColor = Tex2D( g_tColor, i.vTexCoord.xy );
				o.vColor = lerp( origColor, o.vColor, mask );
			}
		}

		return UI_CommonProcessing_Post( i, o );
	}
}
