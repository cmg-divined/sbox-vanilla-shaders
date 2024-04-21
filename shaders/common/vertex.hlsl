#ifndef COMMON_VERTEX_H
#define COMMON_VERTEX_H

//Includes -----------------------------------------------------------------------------------------------------------------------------------------------
#include "sbox_vertex.fxc"

//-------------------------------------------------------------------------------------------------------------------------------------------------------------
//
// Common Vertex Shader Combos And Attributes
//
//-------------------------------------------------------------------------------------------------------------------------------------------------------------
#ifndef USE_CUSTOM_SHADING
    StaticCombo( S_MODE_TOOLS_VIS, 0..1, Sys( ALL ) );
    DynamicCombo( D_BAKED_LIGHTING_FROM_VERTEX_STREAM, 0..1, Sys( ALL ) );
    DynamicCombo( D_BAKED_LIGHTING_FROM_LIGHTMAP, 0..1, Sys( ALL ) );
    DynamicComboRule( Allow1( S_MORPH_SUPPORTED, D_BAKED_LIGHTING_FROM_VERTEX_STREAM, D_BAKED_LIGHTING_FROM_LIGHTMAP ) );
#endif


#endif // COMMON_VERTEX_H