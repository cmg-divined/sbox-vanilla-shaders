#include "common.fxc"
#include "math_general.fxc"
#include "ui/scissor.hlsl"

// Defines ------------------------------------------------------------------------------------------------------------------------------------------------

#define SUBPIXEL_AA_MAGIC 0.5

// Attributes ---------------------------------------------------------------------------------------------------------------------------------------------
float2 BoxSize < Attribute( "BoxSize" ); >;
float2 BoxPosition < Attribute( "BoxPosition" ); >;

// Render State -------------------------------------------------------------------------------------------------------------------------------------------

// Already set by shared code
// RenderState( DepthEnable, false );

// Main ---------------------------------------------------------------------------------------------------------------------------------------------------
struct PS_OUTPUT
{
    float4 vColor : SV_Target0;
};

void UI_CommonProcessing_Pre( PS_INPUT i )
{
    if ( HasScissoring )
    {
        SoftwareScissoring( i );
    }
}

PS_OUTPUT UI_CommonProcessing_Post( PS_INPUT i, PS_OUTPUT o )
{
    return o;
}


//
// Blend Modes (https://web.dev/learn/css/blend-modes/)
// I only filled in what I needed. A job for someone else - garry
//
DynamicComboFromFeature( D_BLENDMODE, 0..2, F_BLENDMODE, Sys( ALL ) );

// Alpha Blend
#if D_BLENDMODE == 0
    RenderState( BlendEnable, true );
    RenderState( SrcBlend, SRC_ALPHA );
    RenderState( DstBlend, INV_SRC_ALPHA );
    RenderState( BlendOp, ADD );
    RenderState( SrcBlendAlpha, ONE );
    RenderState( DstBlendAlpha, INV_SRC_ALPHA );
    RenderState( BlendOpAlpha, ADD );
// Multiply
#elif D_BLENDMODE == 1
    RenderState( BlendEnable, true );
    RenderState( SrcBlend, DEST_COLOR );
    RenderState( DstBlend, ZERO );
    RenderState( SrcBlendAlpha, ONE );
    RenderState( DstBlendAlpha, ONE );
// Lighten
#elif D_BLENDMODE == 2
    RenderState( BlendEnable, true );
    RenderState( SrcBlend, SRC_ALPHA );
    RenderState( DstBlend, ONE );
    RenderState( SrcBlendAlpha, ONE );
    RenderState( DstBlendAlpha, ONE );
#endif
