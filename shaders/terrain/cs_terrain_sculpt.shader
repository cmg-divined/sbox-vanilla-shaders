HEADER
{
	DevShader = true;
	Description = "A";
}

MODES
{
	Default();
}

FEATURES
{
}

COMMON
{
	#include "system.fxc" // This should always be the first include in COMMON
}

CS
{
	#include "common.fxc"

    RWTexture2D<float> Heightmap < Attribute( "Heightmap" ); >;
    float2 HeightUV < Attribute( "HeightUV" ); >;
    int BrushSize < Attribute( "BrushSize" ); >;
    float BrushStrength < Attribute( "BrushStrength" ); >;
	Texture2D<float> Brush < Attribute( "Brush" ); >;

    SamplerState g_sBilinearBorder < Filter( BILINEAR ); AddressU( BORDER ); AddressV( BORDER ); >;

	[numthreads( 16, 16, 1 )]
	void MainCs( uint nGroupIndex : SV_GroupIndex, uint3 vThreadId : SV_DispatchThreadID )
	{
        float w, h;
        Heightmap.GetDimensions( w, h );

        int2 texelCenter = int2( float2( w, h ) * HeightUV );
        int2 texelOffset = int2( vThreadId.xy ) - int( BrushSize / 2 );

        int2 texel = texelCenter + texelOffset;
        if ( texel.x < 0 || texel.y < 0 || texel.x >= w || texel.y >= h ) return;

        float2 brushUV = float2( vThreadId.xy ) / BrushSize;
        float brush = Brush.SampleLevel( g_sBilinearBorder, brushUV, 0 );

        float height = Heightmap.Load( texel ).x;
        Heightmap[texel] = height + brush * 0.001f * BrushStrength;
    }
}

