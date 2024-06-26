//-------------------------------------------------------------------------------------------------------------------------------------------------------------
HEADER
{
	DevShader = true;
	Description = "Compute Shader for writing lightcookie slices.";
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------------
MODES
{
	Default();
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------------
FEATURES
{
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------------
COMMON
{
	#include "system.fxc" // This should always be the first include in COMMON
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------------
CS
{
	RWTexture3D<float4> g_tLightCookieSheet < Attribute( "LightCookieSheet" ); >;
	CreateTexture2D( g_tCookieTexture ) < Attribute( "CookieTexture" ); SrgbRead( false ); Filter( MIN_MAG_LINEAR_MIP_POINT ); AddressU( CLAMP ); AddressV( CLAMP ); >;
	float g_flCookieSheetSize < Attribute( "CookieSheetSize" ); Default( 1024.0f ); >;
	uint g_iSlice < Attribute( "CookieSlice" ); Default( 0 ); >;

	[numthreads( 8, 8, 1 )]
	void MainCs( uint nGroupIndex : SV_GroupIndex, uint3 vThreadId : SV_DispatchThreadID )
	{
        uint3 vSample = uint3( vThreadId.xy, g_iSlice );

		float2 vTexCoord = vThreadId.xy / g_flCookieSheetSize;

		float4 vColor = Tex2DLevel( g_tCookieTexture, vTexCoord, 0.0 );
		vColor *= vColor.a;
		
        g_tLightCookieSheet[ vSample ] = vColor;
    }
}

