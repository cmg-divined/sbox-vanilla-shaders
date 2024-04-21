// Copyright (c) Valve Corporation. All Rights Reserved.
// Copyright (c) Facepunch. All Rights Reserved.

#ifndef BINDLESS_H
#define BINDLESS_H

#include "descriptor_set_support.fxc"

ExternalDescriptorSet g_globalLateBoundBindlessSet Slot 1;
Texture2D g_bindless_Texture2D[] EXTERNAL_DESC_SET( t, g_globalLateBoundBindlessSet, 16 );
Texture3D g_bindless_Texture3D[] EXTERNAL_DESC_SET( t, g_globalLateBoundBindlessSet, 16 );
TextureCube g_bindless_TextureCube[] EXTERNAL_DESC_SET( t, g_globalLateBoundBindlessSet, 16 );
Texture2DArray g_bindless_Texture2DArray[] EXTERNAL_DESC_SET( t, g_globalLateBoundBindlessSet, 16 );
TextureCubeArray g_bindless_TextureCubeArray[] EXTERNAL_DESC_SET( t, g_globalLateBoundBindlessSet, 16 );

SamplerState g_bindless_Sampler[2048] EXTERNAL_DESC_SET( s, g_globalLateBoundBindlessSet, 15 );
SamplerComparisonState g_bindless_SamplerComparison[2048] EXTERNAL_DESC_SET( s, g_globalLateBoundBindlessSet, 15 );

#define GetBindlessTexture2D( nIndex ) g_bindless_Texture2D[nIndex]
#define GetBindlessTexture3D( nIndex ) g_bindless_Texture3D[nIndex]
#define GetBindlessTextureCube( nIndex ) g_bindless_TextureCube[nIndex]
#define GetBindlessTexture2DArray( nIndex ) g_bindless_Texture2DArray[nIndex]
#define GetBindlessTextureCubeArray( nIndex ) g_bindless_TextureCubeArray[nIndex]
#define GetBindlessSampler( nIndex ) g_bindless_Sampler[nIndex]
#define GetBindlessSamplerComparison( nIndex ) g_bindless_SamplerComparison[nIndex]

#endif /* BINDLESS_H */
