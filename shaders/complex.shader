//=================================================================================================
// Reconstructed with Source 2 Viewer 9.1.0.0 - https://valveresourceformat.github.io
//=================================================================================================
HEADER
{
    Description = "VR uber shader with lots of configurability";
    DevShader = false;
    Version = 6;
}
MODES
{
    VrForward();
    Depth("depth_only.shader");
    ToolsVis(S_MODE_TOOLS_VIS);
    ToolsWireframe("vr_tools_wireframe.shader");
    ToolsShadingComplexity("tools_shading_complexity.shader");
    Reflection(S_MODE_REFLECTIONS);
}

FEATURES
{
    Feature( F_DO_NOT_CAST_SHADOWS, 0..1, "Rendering" );
    Feature( F_RENDER_BACKFACES, 0..1, "Rendering" );
    Feature( F_MORPH_SUPPORTED, 0..1, "Animation" );
    Feature( F_DISABLE_Z_BUFFERING, 0..1, "Z-Buffering" );
    Feature( F_DISABLE_Z_PREPASS, 0..1, "Z-Buffering" );
    Feature( F_ALPHA_TEST, 0..1, "Translucent" );
    Feature( F_TRANSLUCENT, 0..1, "Translucent" );
    Feature( F_ADDITIVE_BLEND, 0..1, "Translucent" );
    Feature( F_TINT_MASK, 0..1, "Color" );
    Feature( F_SPECULAR, 0..1, "PBR" );
    Feature( F_ANISOTROPIC_GLOSS, 0..1, "PBR" );
    Feature( F_RETRO_REFLECTIVE, 0..1, "PBR" );
    Feature( F_SCALE_NORMAL_MAP, 0..1, "Normal" );
    Feature( F_SPECULAR_CUBE_MAP_ANISOTROPIC_WARP, 0..1, "PBR" );
    Feature( F_ENABLE_NORMAL_SELF_SHADOW, 0..1, "Normal" );
    Feature( F_USE_BENT_NORMALS, 0..1, "Normal" );
    Feature( F_SELF_ILLUM, 0..1, "PBR" );
    Feature( F_DETAIL_TEXTURE, 0..4 (0="None", 1="Mod2X", 2="Overlay", 3="Normals", 4="Overlay and Normals"), "Detail Texture" );
    Feature( F_METALNESS_TEXTURE, 0..1, "PBR" );
    Feature( F_SECONDARY_UV, 0..1, "Secondary UV" );
    Feature( F_OVERLAY, 0..1, "Overlay" );
    Feature( F_TEXTURE_ANIMATION, 0..1, "Animation" );
    Feature( F_TEXTURE_ANIMATION_MODE, 0..2 (0="Sequential", 1="Random", 2="Scripted"), "Animation" );
    Feature( F_DIFFUSE_WRAP, 0..1, "PBR" );
    Feature( F_TRANSMISSIVE_BACKFACE_NDOTL, 0..1, "PBR" );
    Feature( F_CLOTH_SHADING, 0..1, "PBR" );
    Feature( F_PARALLAX_OCCLUSION, 0..1, "Rendering" );
    Feature( F_DYNAMIC_REFLECTIONS, 0..1, "Rendering" );
    FeatureRule( Allow1( F_ALPHA_TEST, F_TRANSLUCENT ), "Translucent and Alpha Test are not compatible" );
    FeatureRule( Requires1( F_ADDITIVE_BLEND, F_TRANSLUCENT ), "Requires translucency" );
    FeatureRule( Allow1( F_TRANSLUCENT, F_DO_NOT_CAST_SHADOWS ), "Translucent and Do Not Cast Shadows are not compatible" );
    FeatureRule( Requires1( F_ANISOTROPIC_GLOSS, F_SPECULAR ), "Requires Specular" );
    FeatureRule( Allow1( F_ANISOTROPIC_GLOSS, F_ADDITIVE_BLEND ), "Anisotropic Gloss and Additive Blend are incompatible" );
    FeatureRule( Requires1( F_RETRO_REFLECTIVE, F_SPECULAR ), "Requires Specular" );
    FeatureRule( Allow1( F_RETRO_REFLECTIVE, F_ANISOTROPIC_GLOSS ), "Retro Reflective and Anisotropic Gloss are not compatible" );
    FeatureRule( Allow1( F_RETRO_REFLECTIVE, F_ALPHA_TEST ), "Retro Reflective and Alpha Test are not compatible" );
    FeatureRule( Allow1( F_RETRO_REFLECTIVE, F_TRANSLUCENT ), "Retro Reflective and Translucent are not compatible" );
    FeatureRule( Allow1( F_RETRO_REFLECTIVE, F_TINT_MASK ), "Retro Reflective and Tint Mask are not compatible" );
    FeatureRule( Allow1( F_RETRO_REFLECTIVE, F_ADDITIVE_BLEND ), "Retro Reflective and Additive Blend are incompatible" );
    FeatureRule( Allow1( F_SCALE_NORMAL_MAP, F_ALPHA_TEST ), "Scale normals and Alpha Test are not compatible" );
    FeatureRule( Allow1( F_SCALE_NORMAL_MAP, F_TRANSLUCENT ), "Scale normals and Translucent are not compatible" );
    FeatureRule( Allow1( F_SCALE_NORMAL_MAP, F_ANISOTROPIC_GLOSS ), "Scale normals and Anisotropic Gloss are not compatible" );
    FeatureRule( Allow1( F_RETRO_REFLECTIVE, F_SCALE_NORMAL_MAP ), "Retro Reflective and Scale normals are not compatible" );
    FeatureRule( Allow1( F_SCALE_NORMAL_MAP, F_ADDITIVE_BLEND ), "Scale Normal Map and Additive Blend are incompatible" );
    FeatureRule( Requires1( F_SCALE_NORMAL_MAP, F_SPECULAR ), "Requires Specular" );
    FeatureRule( Requires1( F_SPECULAR_CUBE_MAP_ANISOTROPIC_WARP, F_ANISOTROPIC_GLOSS ), "Requires Anisotropic Gloss" );
    FeatureRule( Requires1( F_ENABLE_NORMAL_SELF_SHADOW, F_SPECULAR ), "Requires Specular" );
    FeatureRule( Allow1( F_ENABLE_NORMAL_SELF_SHADOW, F_ADDITIVE_BLEND ), "Enable Normal Self Shadow and Additive Blend are incompatible" );
    FeatureRule( Requires1( F_USE_BENT_NORMALS, F_SPECULAR ), "Requires Specular" );
    FeatureRule( Allow1( F_USE_BENT_NORMALS, F_TRANSLUCENT ), "Bent Normals and Alpha Test are not compatible" );
    FeatureRule( Allow1( F_USE_BENT_NORMALS, F_TINT_MASK ), "Bent Normals and Tint Mask are not compatible" );
    FeatureRule( Allow1( F_USE_BENT_NORMALS, F_RETRO_REFLECTIVE ), "Bent Normals and Retro Reflective are not compatible" );
    FeatureRule( Allow1( F_USE_BENT_NORMALS, F_ADDITIVE_BLEND ), "Use Bent Normals and Additive Blend are incompatible" );
    FeatureRule( Allow1( F_USE_BENT_NORMALS, F_SCALE_NORMAL_MAP ), "Use Bent Normals and Scaled Normal Maps are Incompatible" );
    FeatureRule( Allow1( F_SELF_ILLUM, F_RETRO_REFLECTIVE ), "Self Illum and Retro Reflective are not compatible" );
    FeatureRule( Allow1( F_DETAIL_TEXTURE, F_SELF_ILLUM ), "Detail Texture and Self Illum are not compatible" );
    FeatureRule( Allow1( F_DETAIL_TEXTURE, F_ANISOTROPIC_GLOSS ), "Detail Texture and Anisotropic Gloss are not compatible" );
    FeatureRule( Allow1( F_DETAIL_TEXTURE, F_RETRO_REFLECTIVE ), "Detail Texture and Retro Reflective are not compatible" );
    FeatureRule( Allow1( F_DETAIL_TEXTURE, F_ADDITIVE_BLEND ), "Detail Texture and Additive Blend are not compatible" );
    FeatureRule( Requires1( F_METALNESS_TEXTURE, F_SPECULAR ), "Requires Specular" );
    FeatureRule( Allow1( F_METALNESS_TEXTURE, F_ADDITIVE_BLEND ), "Metalness Texture and Additive Blend are not compatible" );
    FeatureRule( Allow1( F_SECONDARY_UV, F_RETRO_REFLECTIVE ), "Secondary UV and Retro Reflective are not compatible" );
    FeatureRule( Allow1( F_SECONDARY_UV, F_ENABLE_NORMAL_SELF_SHADOW ), "Secondary UV and Normal Self Shadow are not compatible" );
    FeatureRule( Allow1( F_SECONDARY_UV, F_USE_BENT_NORMALS ), "Secondary UV and Use Bent Normals are not compatible" );
    FeatureRule( Allow1( F_SECONDARY_UV, F_SCALE_NORMAL_MAP ), "Secondary UV and Scale normals are not compatible" );
    FeatureRule( Requires1( F_OVERLAY, F_TRANSLUCENT ), "Overlay requires translucent" );
    FeatureRule( Allow1( F_OVERLAY, F_DO_NOT_CAST_SHADOWS ), "Overlay and Do Not Cast Shadow Only are not compatible" );
    FeatureRule( Allow1( F_OVERLAY, F_RENDER_BACKFACES ), "Overlay and render backfaces are not compatible" );
    FeatureRule( Allow1( F_OVERLAY, F_ALPHA_TEST ), "Overlay and alpha test are not compatible" );
    FeatureRule( Allow1( F_OVERLAY, F_TINT_MASK ), "Overlay and tint mask are not compatible" );
    FeatureRule( Allow1( F_OVERLAY, F_ANISOTROPIC_GLOSS ), "Overlay and anisotropic gloss are not compatible" );
    FeatureRule( Allow1( F_OVERLAY, F_RETRO_REFLECTIVE ), "Overlay and retro reflective are not compatible" );
    FeatureRule( Allow1( F_OVERLAY, F_USE_BENT_NORMALS ), "Overlay and bent normals are not compatible" );
    FeatureRule( Allow1( F_OVERLAY, F_SECONDARY_UV ), "Overlay and secondary UV are not compatible" );
    FeatureRule( Allow1( F_OVERLAY, F_METALNESS_TEXTURE ), "Overlay and secondary UV are not compatible" );
    FeatureRule( Allow1( F_OVERLAY, F_USE_BENT_NORMALS ), "Overlay and Bent Normals are not compatible" );
    FeatureRule( Allow1( F_OVERLAY, F_SCALE_NORMAL_MAP ), "Overlay and Scale normals are not compatible" );
    FeatureRule( Requires1( F_TEXTURE_ANIMATION_MODE, F_TEXTURE_ANIMATION == 1 ), "Texture Animation Mode requires Texture Animation On" );
    FeatureRule( Allow1( F_DIFFUSE_WRAP, F_RETRO_REFLECTIVE ), "Diffuse wrap and Retro Reflective are not compatible" );
    FeatureRule( Allow1( F_DIFFUSE_WRAP, F_SCALE_NORMAL_MAP ), "Diffuse wrap and Scale Normal Map are not compatible" );
    FeatureRule( Allow1( F_DIFFUSE_WRAP, F_DETAIL_TEXTURE ), "Diffuse wrap and Detail Texture are not compatible" );
    FeatureRule( Allow1( F_DIFFUSE_WRAP, F_OVERLAY ), "Diffuse wrap and Overlay are not compatible" );
    FeatureRule( Allow1( F_DIFFUSE_WRAP, F_ADDITIVE_BLEND ), "Diffuse wrap and Additive Blend are not compatible" );
    FeatureRule( Allow1( F_TRANSMISSIVE_BACKFACE_NDOTL, F_DIFFUSE_WRAP ), "Transmissive Backface Ndotl and Unlit are not compatible" );
    FeatureRule( Allow1( F_TRANSMISSIVE_BACKFACE_NDOTL, F_RETRO_REFLECTIVE ), "Transmissive Backface Ndotl and Retro Reflective are not compatible" );
    FeatureRule( Allow1( F_TRANSMISSIVE_BACKFACE_NDOTL, F_SCALE_NORMAL_MAP ), "Transmissive Backface Ndotl and Scale Normal Map are not compatible" );
    FeatureRule( Allow1( F_TRANSMISSIVE_BACKFACE_NDOTL, F_DETAIL_TEXTURE ), "Transmissive Backface Ndotl and Detail Texture are not compatible" );
    FeatureRule( Allow1( F_TRANSMISSIVE_BACKFACE_NDOTL, F_OVERLAY ), "Transmissive Backface Ndotl and Overlay are not compatible" );
    FeatureRule( Allow1( F_TRANSMISSIVE_BACKFACE_NDOTL, F_ADDITIVE_BLEND ), "Transmissive Backface Ndotl and Additive Blend are not compatible" );
    FeatureRule( Requires1( F_CLOTH_SHADING, F_SPECULAR ), "Requires Specular" );
    FeatureRule( Allow1( F_CLOTH_SHADING, F_ANISOTROPIC_GLOSS ), "Cloth Shading and Anisotropic Gloss are not compatible" );
    FeatureRule( Allow1( F_CLOTH_SHADING, F_RETRO_REFLECTIVE ), "Cloth Shading and Retro Reflective are not compatible" );
    FeatureRule( Allow1( F_CLOTH_SHADING, F_METALNESS_TEXTURE ), "Cloth Shading and Metalness Texture are not compatible" );
    FeatureRule( Allow1( F_CLOTH_SHADING, F_SCALE_NORMAL_MAP ), "Cloth Shading and Scale Normal Map are not compatible" );
    FeatureRule( Allow1( F_CLOTH_SHADING, F_DIFFUSE_WRAP ), "Cloth Shading and Diffuse Wrap are not compatible" );
    FeatureRule( Requires1( F_DYNAMIC_REFLECTIONS, F_SPECULAR ), "Requires Specular" );
}

COMMON
{
    #include "system.fxc"
    
    cbuffer PerViewConstantBuffer_t
    {
        float4x4 g_matWorldToProjection;
        float4x4 g_matProjectionToWorld;
        float4x4 g_matWorldToView;
        float4x4 g_matViewToProjection;
        float4 g_vInvProjRow3;
        float4 g_vClipPlane0;
        float g_flToneMapScalarLinear;
        float g_flLightMapScalar;
        float g_flEnvMapScalar;
        float g_flToneMapScalarGamma;
        float3 g_vCameraPositionWs;
        float g_flViewportMinZ;
        float3 g_vCameraDirWs;
        float g_flViewportMaxZ;
        float3 g_vCameraUpDirWs;
        float g_flTime;
        float3 g_vDepthPsToVsConversion;
        float g_flNearPlane;
        float g_flFarPlane;
        float g_flLightBinnerFarPlane;
        float2 g_vInvViewportSize;
        float2 g_vViewportToGBufferRatio;
        float2 g_vMorphTextureAtlasSize;
        float4 g_vInvGBufferSize;
        float2 g_vViewportOffset;
        float2 g_vViewportSize;
        float2 g_vRenderTargetSize;
        float g_flFogBlendToBackground;
        float g_flHenyeyGreensteinCoeff;
        float3 g_vFogColor;
        float g_flNegFogStartOverFogRange;
        float g_flInvFogRange;
        float g_flFogMaxDensity;
        float g_flFogExponent;
        float g_flMod2xIdentity;
        bool2 g_bRoughnessParams;
        bool g_bStereoEnabled;
        float g_flStereoCameraIndex;
        float3 g_vMiddleEyePositionWs;
        float g_flPad2;
        float4x4 g_matUnusedMultiview1[2];
        float4 g_vUnusedMultiview2[2];
        float4 g_vFrameBufferCopyInvSizeAndUvScale;
        float4 g_vCameraAngles;
        float4 g_vWorldToCameraOffset;
        float4 g_vUnusedMultiview3[2];
        float4 g_vPerViewConstantExtraData0;
        float4 g_vPerViewConstantExtraData1;
        float4 g_vPerViewConstantExtraData2;
        float4 g_vPerViewConstantExtraData3;
        float4x4 g_matPrevProjectionToWorld;
        float4x4 g_matViewToScreen;
        float4x4 g_matProjectionToView;
        float4x4 g_matCurrFrameViewToPrevFrameProj;
        float4 g_vRandomFloats;
    };
    
    cbuffer PerViewConstantBufferVR_t
    {
        bool4 g_bFogTypeEnabled;
        bool4 g_bOtherFxEnabled;
        float4 g_vAoProxyDownres;
        float4 g_vXenAnimation;
        float4 g_vWindDirection;
        float4 g_vWindStrengthFreqMulHighStrength;
        float4 g_vInteractionProjectionOrigin;
        float4 g_vInteractionVolumeInvExtents;
        float4 g_vInteractionTriggerVolumeInvMins;
        float4 g_vInteractionTriggerVolumeWorldToVolumeScale;
        float4 g_vGradientFogBiasAndScale;
        float4 m_vGradientFogExponents;
        float4 g_vGradientFogColor_Opacity;
        float4 g_vGradientFogCullingParams;
        float4 g_vCubeFog_Offset_Scale_Bias_Exponent;
        float4 g_vCubeFog_Height_Offset_Scale_Exponent_Log2Mip;
        float4x4 g_matvCubeFogSkyWsToOs;
        float4 g_vCubeFogCullingParams;
        float4 g_vSphericalVignetteBiasAndScale;
        float4 g_vSphericalVignetteOrigin_Exponent;
        float4 g_vSphericalVignetteColor_Opacity;
        float4 g_vVolFog_VolumeScale_Shift_Near_Range;
        float4 g_vVolFogDitherScaleBias;
        float4 g_vVolFogPostWorldToFrustumScale;
        float4 g_vVolFogPostWorldToFrustumBias;
        float4x4 g_mVolFogFromWorld[2];
        float4 g_vHighPrecisionLightingOffsetWs;
    };
    
    struct VS_INPUT
    {
        float4 vPerVertexLighting         : COLOR1         < Semantic( PerVertexLighting ); >;         // D_BAKED_LIGHTING_FROM_VERTEX_STREAM=1
        float4 vBlendIndices              : BLENDINDICES0  < Semantic( BlendIndices ); >;              // D_SKINNING=1
        float4 vBlendWeight               : BLENDWEIGHT0   < Semantic( BlendWeight ); >;               // D_SKINNING=1
        float4 vNormalOs                  : NORMAL0        < Semantic( OptionallyCompressedTangentFrame ); >;
        float2 vTexCoord2                 : TEXCOORD1      < Semantic( LowPrecisionUv1 ); >;           // S_SECONDARY_UV=1
        uint4  nVertexIndex               : TEXCOORD14     < Semantic( MorphIndex ); >;                // D_MORPH=1
        float2 vLightmapUV                : TEXCOORD3      < Semantic( LightmapUV ); >;                // D_BAKED_LIGHTING_FROM_LIGHTMAP=1
        float3 vPositionOs                : POSITION0      < Semantic( PosXyz ); >;                   
        float4 vTangentUOs_flTangentVSign : TANGENT0       < Semantic( TangentU_SignV ); >;            // D_COMPRESSED_NORMALS_AND_TANGENTS=0
        float2 vTexCoord                  : TEXCOORD0      < Semantic( LowPrecisionUv ); >;           
        float2 nInstanceTransformID       : TEXCOORD13     < Semantic( InstanceTransformUv ); >;      
    };
}

VS
{
    StaticCombo( S_SPECULAR, F_SPECULAR );
    StaticCombo( S_DETAIL_TEXTURE, F_DETAIL_TEXTURE );
    StaticCombo( S_SECONDARY_UV, F_SECONDARY_UV );
    StaticCombo( S_PARALLAX_OCCLUSION, F_PARALLAX_OCCLUSION );
    StaticCombo( S_TEXTURE_ANIMATION, F_TEXTURE_ANIMATION );
    StaticCombo( S_MODE_TOOLS_VIS, 0..1 );
    StaticCombo( S_MORPH_SUPPORTED, F_MORPH_SUPPORTED );
    DynamicCombo( D_SKINNING, 0..1 );
    DynamicCombo( D_COMPRESSED_NORMALS_AND_TANGENTS, 0..1 );
    DynamicCombo( D_MORPH, 0..1 );
    DynamicCombo( D_ENABLE_USER_CLIP_PLANE, 0..1 );
    DynamicCombo( D_BAKED_LIGHTING_FROM_VERTEX_STREAM, 0..1 );
    DynamicCombo( D_BAKED_LIGHTING_FROM_LIGHTMAP, 0..1 );
    DynamicComboRule( Requires1( D_MORPH, S_MORPH_SUPPORTED ) );
    DynamicComboRule( Allow1( S_MORPH_SUPPORTED, D_BAKED_LIGHTING_FROM_VERTEX_STREAM, D_BAKED_LIGHTING_FROM_LIGHTMAP ) );
    
    cbuffer BakedLightingConstantBuffer_t
    {
        float4 g_vLightmapUvScale;
    };
    
    bool g_bTexCoordScaleByModel < UiType(CheckBox); Expression((g_nScaleTexCoordUByModelScaleAxis!=0) || (g_nScaleTexCoordVByModelScaleAxis!=0)); >;
    StructuredBuffer g_flTransformData < Attribute("g_TransformBuffer"); SrgbRead(false); >;
    int g_nTextureAnimationMode < UiType(Slider); Expression(F_TEXTURE_ANIMATION_MODE); >;
    Texture2D g_tCompositeMorphTextureAtlas < Attribute("CompositeMorphTextureAtlas"); SrgbRead(false); >;
    float2 g_vAnimationInvGrid < UiType(VectorText); Expression(1/g_vAnimationGrid); >;
    float4 g_vClipPlane < Attribute("ClipPlane0"); UiType(VectorText); >;
    float4 g_vDetailTexCoordXform < UiType(VectorText); Expression(v0 = (g_flDetailTexCoordRotation*3.1415927)/180;
        v1 = cos(v0);
        v2 = sin(v0);
        v3 = g_vDetailTexCoordScale;
        v3.xxy*float4(v1,-v2,v2,v1)); >;
    float4 g_vTexCoordScaleByModelU < UiType(VectorText); Expression(float4((g_nScaleTexCoordUByModelScaleAxis==1) || 0,(g_nScaleTexCoordUByModelScaleAxis==2) || 0,(g_nScaleTexCoordUByModelScaleAxis==3) || 0,(g_nScaleTexCoordUByModelScaleAxis==0) || 0)); >;
    float4 g_vTexCoordScaleByModelV < UiType(VectorText); Expression(float4((g_nScaleTexCoordVByModelScaleAxis==1) || 0,(g_nScaleTexCoordVByModelScaleAxis==2) || 0,(g_nScaleTexCoordVByModelScaleAxis==3) || 0,(g_nScaleTexCoordVByModelScaleAxis==0) || 0)); >;
    
    // Detail Texture
    bool g_bUseSecondaryUvForDetailTexture < Default(1); UiType(CheckBox); UiGroup("Detail Texture, 170"); >;
    float2 g_vDetailTexCoordScale < Default2(1, 1); UiType(VectorText); UiGroup("Detail Texture,80/30"); >;
    float g_flDetailTexCoordRotation < Range(0, 360); UiType(Slider); UiGroup("Detail Texture,80/35"); >;
    float2 g_vDetailTexCoordOffset < Range2(-1, -1, 1, 1); UiType(VectorText); UiGroup("Detail Texture,80/40"); Expression(v0 = (g_flDetailTexCoordRotation*3.1415927)/180;
        v1 = cos(v0);
        v2 = sin(v0);
        v3 = g_vDetailTexCoordScale;
        v4 = this;
        (((-.5*v3)*float2(v1-v2,v2+v1))+v4)+.5); >;
    
    // Texture Animation
    int2 g_vAnimationGrid < Default2(1, 1); Range2(1, 1, 64, 64); UiType(VectorText); UiGroup("Texture Animation,12/10"); >;
    int g_nNumAnimationCells < Default(1); Range(1, 4096); UiType(Slider); UiGroup("Texture Animation,12/20"); >;
    float g_flAnimationTimePerFrame < Range(0, 10); UiType(Slider); UiGroup("Texture Animation,12/30"); >;
    float g_flAnimationTimeOffset < Range(0, 1000); UiType(Slider); UiGroup("Texture Animation,12/40"); >;
    float g_flAnimationFrame < Range(0, 4096); UiType(Slider); UiGroup("Texture Animation,12/50"); >;
    
    // Fade
    float g_flFadeExponent < Default(1); Range(1, 16); UiType(Slider); UiGroup("Fade,400/10"); >;
    
    // Parallax
    float g_flHeightMapScale < Range(0, 0.5); UiType(Slider); UiGroup("Parallax"); >;
    
    // Color
    float3 g_vColorTint < Default3(1, 1, 1); UiType(Color); UiGroup("Color,10/20"); Expression(SrgbGammaToLinear(this)); >;
    float g_flModelTintAmount < Default(1); UiType(Slider); UiGroup("Color,10/30"); >;
    
    // Texture Coordinates
    float2 g_vTexCoordScale < Default2(1, 1); Range2(0, 0, 100, 100); UiType(VectorText); UiGroup("Texture Coordinates,80/10"); >;
    float2 g_vTexCoordOffset < Range2(-1, -1, 1, 1); UiType(VectorText); UiGroup("Texture Coordinates/20"); >;
    float2 g_vTexCoordScrollSpeed < Range2(-10, -10, 10, 10); UiType(VectorText); UiGroup("Texture Coordinates/30"); >;
    int g_nScaleTexCoordUByModelScaleAxis < Range(0, 3); UiType(Slider); UiGroup("Texture Coordinates/40"); >;
    int g_nScaleTexCoordVByModelScaleAxis < Range(0, 3); UiType(Slider); UiGroup("Texture Coordinates/50"); >;
    
    // SPIR-V source (4048), SPVC_BACKEND_HLSL reflection with SPIRV-Cross by KhronosGroup
    // Source 2 Viewer 9.1.0.0 - https://valveresourceformat.github.io
    
    cbuffer _1219_3694 : register(b14, space0)
    {
        float2 _3694_m0 : packoffset(c11);
        float2 _3694_m1 : packoffset(c11.z);
        float2 _3694_m2 : packoffset(c12);
        float3 _3694_m3 : packoffset(c16);
        float _3694_m4 : packoffset(c16.w);
        float _3694_m5 : packoffset(c17);
    };
    
    cbuffer _1260_4459 : register(b15, space0)
    {
        column_major float4x4 _4459_m0 : packoffset(c0);
        float _4459_m1 : packoffset(c21.w);
        float4 _4459_m2 : packoffset(c44);
    };
    
    cbuffer _1017_3658 : register(b18, space0)
    {
        float4 _3658_m0 : packoffset(c36);
    };
    
    ByteAddressBuffer _4914 : register(t289, space0);
    
    static float4 gl_Position;
    static float3 _6017;
    static float2 _5759;
    static float4 _5837;
    static float4 _4948;
    static uint _3984;
    static float3 _3486;
    static float3 _3487;
    static float2 _3488;
    static float4 _3490;
    static float3 _3492;
    static float3 _3493;
    
    struct SPIRV_Cross_Input
    {
        float3 _6017 : TEXCOORD0;
        float2 _5759 : TEXCOORD1;
        float4 _5837 : TEXCOORD2;
        float4 _4948 : TEXCOORD3;
        uint _3984 : TEXCOORD4;
    };
    
    struct SPIRV_Cross_Output
    {
        float3 _3486 : TEXCOORD0;
        float3 _3487 : TEXCOORD1;
        float2 _3488 : TEXCOORD2;
        float4 _3490 : TEXCOORD3;
        float3 _3492 : TEXCOORD4;
        float3 _3493 : TEXCOORD5;
        float4 gl_Position : SV_Position;
    };
    
    void vert_main()
    {
        int _13884 = int(_3984 * 4u);
        uint _9613 = uint(_13884);
        float3x4 _15790 = float3x4(asfloat(_4914.Load4(_9613 * 16 + 0)), asfloat(_4914.Load4((_9613 + 1u) * 16 + 0)), asfloat(_4914.Load4((_9613 + 2u) * 16 + 0)));
        uint _11578 = uint(_13884 + 3);
        uint _12145 = asuint(asfloat(_4914.Load4(_11578 * 16 + 0)).y);
        float4 _25139 = float4(float((_12145 >> 16u) & 255u) * 0.0039215688593685626983642578125f, float((_12145 >> 8u) & 255u) * 0.0039215688593685626983642578125f, float((_12145 >> 0u) & 255u) * 0.0039215688593685626983642578125f, asfloat(_4914.Load4(_11578 * 16 + 0)).x);
        float3 _10871 = normalize(mul(_15790, float4(_5837.xyz, 0.0f)));
        float3 _21242 = mul(_15790, float4(_6017, 1.0f));
        float4 _13669 = mul(_4459_m0, float4(_21242, 1.0f) + (_4459_m2 * 1.0f));
        float3 _10810 = mul(_15790, float4(_4948.xyz, 0.0f));
        float3 _24942 = normalize(_10810 - (_10871 * dot(_10810, _10871)));
        float3 _13085 = lerp(1.0f.xxx, _25139.xyz, _3694_m4.xxx).xyz * _3694_m3;
        float4 _12634 = float4(_13085.x, _13085.y, _13085.z, _25139.w);
        _12634.w = pow(asfloat(_4914.Load4(_11578 * 16 + 0)).x, _3694_m5);
        _3486 = _21242 - _3658_m0.xyz;
        _3487 = _10871;
        _3488 = mad(_5759, _3694_m0, _3694_m1) + (_3694_m2 * _4459_m1);
        _3490 = _12634;
        _3492 = _24942;
        _3493 = cross(_10871, _24942) * _4948.w;
        _13669.y = -_13669.y;
        gl_Position = _13669;
    }
    
    SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
    {
        _6017 = stage_input._6017;
        _5759 = stage_input._5759;
        _5837 = stage_input._5837;
        _4948 = stage_input._4948;
        _3984 = stage_input._3984;
        vert_main();
        SPIRV_Cross_Output stage_output;
        stage_output.gl_Position = gl_Position;
        stage_output._3486 = _3486;
        stage_output._3487 = _3487;
        stage_output._3488 = _3488;
        stage_output._3490 = _3490;
        stage_output._3492 = _3492;
        stage_output._3493 = _3493;
        return stage_output;
    }
    
    // ---------  SPIRV -> HLSL end  --------- 
    
    
    
    BoolAttribute(CanBatchWithDynamicShaderConstants, true);
    IntAttribute(TexCoordScaleByModelU, g_nScaleTexCoordUByModelScaleAxis-1);
    IntAttribute(TexCoordScaleByModelV, g_nScaleTexCoordVByModelScaleAxis-1);
    Float3Attribute(LightSim_MaterialTint, g_vColorTint);
    
    #if (S_SPECULAR == 1)
        BoolAttribute(environmentmapped, true);
    #endif
}

PS
{
    StaticCombo( S_SPECULAR, F_SPECULAR );
    StaticCombo( S_DETAIL_TEXTURE, F_DETAIL_TEXTURE );
    StaticCombo( S_SECONDARY_UV, F_SECONDARY_UV );
    StaticCombo( S_PARALLAX_OCCLUSION, F_PARALLAX_OCCLUSION );
    StaticCombo( S_OVERLAY, F_OVERLAY );
    StaticCombo( S_ANISOTROPIC_GLOSS, F_ANISOTROPIC_GLOSS );
    StaticCombo( S_RETRO_REFLECTIVE, F_RETRO_REFLECTIVE );
    StaticCombo( S_ALPHA_TEST, F_ALPHA_TEST );
    StaticCombo( S_TRANSLUCENT, F_TRANSLUCENT );
    StaticCombo( S_ADDITIVE_BLEND, F_ADDITIVE_BLEND );
    StaticCombo( S_SELF_ILLUM, F_SELF_ILLUM );
    StaticCombo( S_TINT_MASK, F_TINT_MASK );
    StaticCombo( S_RENDER_BACKFACES, F_RENDER_BACKFACES );
    StaticCombo( S_ENABLE_NORMAL_SELF_SHADOW, F_ENABLE_NORMAL_SELF_SHADOW );
    StaticCombo( S_USE_BENT_NORMALS, F_USE_BENT_NORMALS );
    StaticCombo( S_SPECULAR_CUBE_MAP_ANISOTROPIC_WARP, F_SPECULAR_CUBE_MAP_ANISOTROPIC_WARP );
    StaticCombo( S_METALNESS_TEXTURE, F_METALNESS_TEXTURE );
    StaticCombo( S_SCALE_NORMAL_MAP, F_SCALE_NORMAL_MAP );
    StaticCombo( S_DIFFUSE_WRAP, F_DIFFUSE_WRAP );
    StaticCombo( S_TRANSMISSIVE_BACKFACE_NDOTL, F_TRANSMISSIVE_BACKFACE_NDOTL );
    StaticCombo( S_CLOTH_SHADING, F_CLOTH_SHADING );
    StaticCombo( S_MODE_REFLECTIONS, 0..1 );
    StaticCombo( S_MODE_TOOLS_VIS, 0..1 );
    StaticComboRule( Allow1( S_ALPHA_TEST, S_TRANSLUCENT ) );
    StaticComboRule( Requires1( S_ADDITIVE_BLEND, S_TRANSLUCENT ) );
    StaticComboRule( Requires1( S_ANISOTROPIC_GLOSS, S_SPECULAR ) );
    StaticComboRule( Allow1( S_ANISOTROPIC_GLOSS, S_ADDITIVE_BLEND ) );
    StaticComboRule( Requires1( S_RETRO_REFLECTIVE, S_SPECULAR ) );
    StaticComboRule( Allow1( S_RETRO_REFLECTIVE, S_ANISOTROPIC_GLOSS ) );
    StaticComboRule( Allow1( S_RETRO_REFLECTIVE, S_ALPHA_TEST ) );
    StaticComboRule( Allow1( S_RETRO_REFLECTIVE, S_TRANSLUCENT ) );
    StaticComboRule( Allow1( S_RETRO_REFLECTIVE, S_TINT_MASK ) );
    StaticComboRule( Allow1( S_RETRO_REFLECTIVE, S_ADDITIVE_BLEND ) );
    StaticComboRule( Allow1( S_SCALE_NORMAL_MAP, S_ALPHA_TEST ) );
    StaticComboRule( Allow1( S_SCALE_NORMAL_MAP, S_TRANSLUCENT ) );
    StaticComboRule( Allow1( S_SCALE_NORMAL_MAP, S_ANISOTROPIC_GLOSS ) );
    StaticComboRule( Allow1( S_RETRO_REFLECTIVE, S_SCALE_NORMAL_MAP ) );
    StaticComboRule( Allow1( S_SCALE_NORMAL_MAP, S_ADDITIVE_BLEND ) );
    StaticComboRule( Requires1( S_SCALE_NORMAL_MAP, S_SPECULAR ) );
    StaticComboRule( Requires1( S_SPECULAR_CUBE_MAP_ANISOTROPIC_WARP, S_ANISOTROPIC_GLOSS ) );
    StaticComboRule( Requires1( S_ENABLE_NORMAL_SELF_SHADOW, S_SPECULAR ) );
    StaticComboRule( Allow1( S_ENABLE_NORMAL_SELF_SHADOW, S_ADDITIVE_BLEND ) );
    StaticComboRule( Requires1( S_USE_BENT_NORMALS, S_SPECULAR ) );
    StaticComboRule( Allow1( S_USE_BENT_NORMALS, S_TRANSLUCENT ) );
    StaticComboRule( Allow1( S_USE_BENT_NORMALS, S_TINT_MASK ) );
    StaticComboRule( Allow1( S_USE_BENT_NORMALS, S_RETRO_REFLECTIVE ) );
    StaticComboRule( Allow1( S_USE_BENT_NORMALS, S_ADDITIVE_BLEND ) );
    StaticComboRule( Allow1( S_USE_BENT_NORMALS, S_SCALE_NORMAL_MAP ) );
    StaticComboRule( Allow1( S_SELF_ILLUM, S_RETRO_REFLECTIVE ) );
    StaticComboRule( Allow1( S_DETAIL_TEXTURE, S_SELF_ILLUM ) );
    StaticComboRule( Allow1( S_DETAIL_TEXTURE, S_ANISOTROPIC_GLOSS ) );
    StaticComboRule( Allow1( S_DETAIL_TEXTURE, S_RETRO_REFLECTIVE ) );
    StaticComboRule( Allow1( S_DETAIL_TEXTURE, S_ADDITIVE_BLEND ) );
    StaticComboRule( Requires1( S_METALNESS_TEXTURE, S_SPECULAR ) );
    StaticComboRule( Allow1( S_METALNESS_TEXTURE, S_ADDITIVE_BLEND ) );
    StaticComboRule( Allow1( S_SECONDARY_UV, S_RETRO_REFLECTIVE ) );
    StaticComboRule( Allow1( S_SECONDARY_UV, S_ENABLE_NORMAL_SELF_SHADOW ) );
    StaticComboRule( Allow1( S_SECONDARY_UV, S_USE_BENT_NORMALS ) );
    StaticComboRule( Allow1( S_SECONDARY_UV, S_SCALE_NORMAL_MAP ) );
    StaticComboRule( Requires1( S_OVERLAY, S_TRANSLUCENT ) );
    StaticComboRule( Allow1( S_OVERLAY, S_RENDER_BACKFACES ) );
    StaticComboRule( Allow1( S_OVERLAY, S_ALPHA_TEST ) );
    StaticComboRule( Allow1( S_OVERLAY, S_TINT_MASK ) );
    StaticComboRule( Allow1( S_OVERLAY, S_ANISOTROPIC_GLOSS ) );
    StaticComboRule( Allow1( S_OVERLAY, S_RETRO_REFLECTIVE ) );
    StaticComboRule( Allow1( S_OVERLAY, S_USE_BENT_NORMALS ) );
    StaticComboRule( Allow1( S_OVERLAY, S_SECONDARY_UV ) );
    StaticComboRule( Allow1( S_OVERLAY, S_METALNESS_TEXTURE ) );
    StaticComboRule( Allow1( S_OVERLAY, S_USE_BENT_NORMALS ) );
    StaticComboRule( Allow1( S_OVERLAY, S_SCALE_NORMAL_MAP ) );
    StaticComboRule( Allow1( S_DIFFUSE_WRAP, S_RETRO_REFLECTIVE ) );
    StaticComboRule( Allow1( S_DIFFUSE_WRAP, S_SCALE_NORMAL_MAP ) );
    StaticComboRule( Allow1( S_DIFFUSE_WRAP, S_DETAIL_TEXTURE ) );
    StaticComboRule( Allow1( S_DIFFUSE_WRAP, S_OVERLAY ) );
    StaticComboRule( Allow1( S_DIFFUSE_WRAP, S_ADDITIVE_BLEND ) );
    StaticComboRule( Allow1( S_TRANSMISSIVE_BACKFACE_NDOTL, S_DIFFUSE_WRAP ) );
    StaticComboRule( Allow1( S_TRANSMISSIVE_BACKFACE_NDOTL, S_RETRO_REFLECTIVE ) );
    StaticComboRule( Allow1( S_TRANSMISSIVE_BACKFACE_NDOTL, S_SCALE_NORMAL_MAP ) );
    StaticComboRule( Allow1( S_TRANSMISSIVE_BACKFACE_NDOTL, S_DETAIL_TEXTURE ) );
    StaticComboRule( Allow1( S_TRANSMISSIVE_BACKFACE_NDOTL, S_OVERLAY ) );
    StaticComboRule( Allow1( S_TRANSMISSIVE_BACKFACE_NDOTL, S_ADDITIVE_BLEND ) );
    StaticComboRule( Requires1( S_CLOTH_SHADING, S_SPECULAR ) );
    StaticComboRule( Allow1( S_CLOTH_SHADING, S_ANISOTROPIC_GLOSS ) );
    StaticComboRule( Allow1( S_CLOTH_SHADING, S_RETRO_REFLECTIVE ) );
    StaticComboRule( Allow1( S_CLOTH_SHADING, S_METALNESS_TEXTURE ) );
    StaticComboRule( Allow1( S_CLOTH_SHADING, S_SCALE_NORMAL_MAP ) );
    StaticComboRule( Allow1( S_CLOTH_SHADING, S_DIFFUSE_WRAP ) );
    DynamicCombo( D_OPAQUE_FADE, 0..1 );
    DynamicCombo( D_BAKED_LIGHTING_FROM_VERTEX_STREAM, 0..1 );
    DynamicCombo( D_BAKED_LIGHTING_FROM_PROBE, 0..1 );
    DynamicCombo( D_BAKED_LIGHTING_FROM_LIGHTMAP, 0..1 );
    DynamicComboRule( Allow1( S_ALPHA_TEST, S_TRANSLUCENT, D_OPAQUE_FADE ) );
    DynamicComboRule( Allow1( D_BAKED_LIGHTING_FROM_PROBE, D_BAKED_LIGHTING_FROM_VERTEX_STREAM, D_BAKED_LIGHTING_FROM_LIGHTMAP ) );
    DynamicComboRule( Allow1( S_USE_BENT_NORMALS, D_BAKED_LIGHTING_FROM_LIGHTMAP, D_BAKED_LIGHTING_FROM_VERTEX_STREAM ) );
    
    cbuffer PerBatchLightProbeVolumeConstantBuffer_t
    {
        float4x3 g_matLightProbeVolumeWorldToLocal;
        float4 g_vLightProbeVolumeLayer0TextureMin;
        float4 g_vLightProbeVolumeLayer0TextureMax;
        float4 g_vLightProbeVolumeColor;
    };
    
    cbuffer ViewLightingConfig
    {
        DWORD4 ViewLightingFlags;
        float4 NumLights;
        DWORD4 BakedLightIndexMapping[256];
        DWORD4 Shadow3x3PCFConstants[4];
        float4 EnvironmentMapSizeConstants;
        bool4 AmbientLightingSH[3];
    };
    
    cbuffer MSAASampleOffsetConstantBuffer_t
    {
        float4 g_vMSAASampleOffsets[16];
        int g_nMSAASampleCount;
    };
    
    RenderState(AlphaToCoverageEnable, 1);
    RenderState(BackStencilFunc, 5);
    StructuredBuffer BinnedEnvMapBuffer < Attribute("BinnedEnvMapBuffer"); SrgbRead(false); >;
    StructuredBuffer BinnedLightBuffer < Attribute("BinnedLightBuffer"); SrgbRead(false); >;
    RenderState(BlendEnable, 1);
    RenderState(ColorWriteEnable0, 7);
    RenderState(DepthEnable, F_DISABLE_Z_BUFFERING ? 0 : 1);
    RenderState(DepthWriteEnable, F_DISABLE_Z_BUFFERING ? 0 : 1);
    RenderState(DstBlend, F_ADDITIVE_BLEND || 5);
    int ReflectionDownsampleRatio < Attribute("ReflectionDownsampleRatio"); UiType(Slider); >;
    int SampleCountIntersection < Default(1); Attribute("SampleCountIntersection"); UiType(Slider); >;
    RenderState(StencilEnable, 1);
    RenderState(StencilFunc, 5);
    RenderState(StencilReadMask, 1);
    RenderState(StencilRef, 3);
    RenderState(StencilWriteMask, 254);
    StructuredBuffer g_TiledLightBuffer < Attribute("g_TiledLightBuffer"); SrgbRead(false); >;
    bool g_bCubemapNormalization < Attribute("g_bCubemapNormalization"); UiType(CheckBox); >;
    bool g_bDisableNormalMapping < Attribute("g_bDisableNormalMapping"); UiType(CheckBox); >;
    bool g_bHighlightDeprecated < Attribute("g_bHighlightDeprecated"); UiType(CheckBox); >;
    bool g_bIsDeprecated < Attribute("bIsDeprecated"); UiType(CheckBox); >;
    bool g_bRenderingToCubemaps < Attribute("g_bRenderingToCubemaps"); UiType(CheckBox); >;
    bool g_bShowLPVVoxels < Attribute("g_bShowLPVVoxels"); UiType(CheckBox); >;
    bool g_bShowLightmapTexels < Attribute("g_bShowLightmapTexels"); UiType(CheckBox); >;
    bool g_bUseTiledRendering < Default(1); Attribute("UseTiledRendering"); UiType(CheckBox); >;
    float g_fInvLightRangeForSelfShadowNormals < UiType(Slider); Expression(1/g_flLightRangeForSelfShadowNormals); >;
    int g_nToolsVisMode < Attribute("g_nToolsVisMode"); UiType(Slider); >;
    Texture2D g_tAmbientOcclusion < Channel(R, Box3(TextureAmbientOcclusion), Linear); OutputFormat(ATI1N); SrgbRead(false); >;
    Texture2D g_tAnisoGloss < Channel(RG, AnisoRoughness_RG(TextureNormal, TextureRoughness), Linear); OutputFormat(ATI2N); SrgbRead(false); >;
    Texture2D g_tBRDFLookup < Attribute("BRDFLookup"); SrgbRead(false); >;
    Texture2D g_tBentNormal < Channel(RG, HemiOctIsoRoughness_RG_B(TextureBentNormal), Linear); OutputFormat(ATI2N); SrgbRead(false); >;
    Texture2D g_tBlueNoise < Attribute("BlueNoise"); SrgbRead(false); >;
    Texture2D g_tColor < Channel(RGB, Box(TextureColor), Srgb); OutputFormat(DXT1); SrgbRead(true); >;
    Texture2D g_tColor < Channel(RGB, Box(TextureColor), Srgb); Channel(A, Box(TextureMetalness), Linear); OutputFormat(BC7); SrgbRead(true); >;
    Texture2D g_tColor < Channel(RGB, AlphaWeighted(TextureColor, TextureTranslucency), Srgb); Channel(A, PreserveCoverage(TextureTranslucency), Linear); OutputFormat(BC7); SrgbRead(true); >;
    Texture2D g_tColor < Channel(RGB, AlphaWeighted(TextureColor, TextureTranslucency), Srgb); Channel(A, Box(TextureTranslucency), Linear); OutputFormat(BC7); SrgbRead(true); >;
    Texture2D g_tDepthChain < Attribute("DepthChainDownsample"); SrgbRead(false); >;
    Texture2D g_tDetail < Channel(RGB, Box(TextureDetail), Linear); OutputFormat(BC7); SrgbRead(false); >;
    Texture2D g_tDetailMask < Channel(R, Box(TextureDetailMask), Linear); OutputFormat(ATI1N); SrgbRead(false); >;
    Texture2D g_tDynamicAmbientOcclusion < Attribute("DynamicAmbientOcclusion"); SrgbRead(false); >;
    Texture2D g_tDynamicAmbientOcclusionDepth < Attribute("DynamicAmbientOcclusionDepth"); SrgbRead(false); >;
    TextureCubeArray g_tEnvironmentMap < Attribute("EnvironmentMap"); SrgbRead(false); >;
    TextureCube g_tFogCubeTexture < Attribute("CubemapFogTexture"); SrgbRead(true); >;
    Texture3D g_tFogVolume < Attribute("FogVolume"); SrgbRead(false); >;
    Texture2D g_tHeight < Channel(R, Box(TextureHeight), Linear); OutputFormat(ATI1N); SrgbRead(false); >;
    Texture3D g_tLightCookieTexture < Attribute("LightCookieTexture"); SrgbRead(true); >;
    Texture3D g_tLightProbeVolumeTexture < Attribute("LightProbeVolumeTexture"); SrgbRead(false); >;
    Texture3D g_tLightProbeVolumeTextureDirectLightIndices < Attribute("LightProbeVolumeTextureDirectLightIndices"); SrgbRead(false); >;
    Texture3D g_tLightProbeVolumeTextureDirectLightScalars < Attribute("LightProbeVolumeTextureDirectLightScalars"); SrgbRead(false); >;
    Texture2DArray g_tLightmap0 < Attribute("direct_light_indices"); SrgbRead(false); >;
    Texture2DArray g_tLightmap1 < Attribute("direct_light_strengths"); SrgbRead(false); >;
    Texture2DArray g_tLightmap2 < Attribute("irradiance"); SrgbRead(false); >;
    Texture2DArray g_tLightmap3 < Attribute("directional_irradiance"); SrgbRead(false); >;
    Texture2DArray g_tLightmap4 < Attribute("debug_chart_color"); SrgbRead(false); >;
    Texture2D g_tMetalness < Channel(G, Box(TextureMetalness), Linear); OutputFormat(DXT1); SrgbRead(false); >;
    Texture2D g_tMetalness < Channel(G, Box(TextureMetalness), Linear); Channel(R, Box(TextureRetroReflectiveMask), Linear); OutputFormat(DXT1); SrgbRead(false); >;
    Texture2D g_tNormal < Channel(RG, HemiOctIsoRoughness_RG_B(TextureNormal, TextureRoughness), Linear); OutputFormat(ATI2N); SrgbRead(false); >;
    Texture2D g_tNormal < Channel(RGBA, HemiOctIsoRoughness_RG_B(TextureNormal, TextureRoughness), Linear); OutputFormat(BC7); SrgbRead(false); >;
    Texture2D g_tNormalDetail < Channel(RG, HemiOctIsoRoughness_RG_B(TextureNormalDetail), Linear); OutputFormat(ATI2N); SrgbRead(false); >;
    Texture2D g_tPrevFrameTexture < Attribute("PrevFrameTexture"); SrgbRead(false); >;
    Texture2D g_tReflectionColor < Attribute("ReflectionTextureColor"); SrgbRead(false); >;
    Texture2D g_tSelfIllumMask < Channel(RGB, Box(TextureSelfIllumMask), Srgb); OutputFormat(DXT1); SrgbRead(true); >;
    Texture2D g_tShadowDepthBufferDepthNoCmp < Attribute("ShadowDepthBufferNoCmp"); SrgbRead(false); >;
    Texture2D g_tTintMask < Channel(R, Box(TextureTintMask), Linear); OutputFormat(ATI1N); SrgbRead(false); >;
    Texture2D g_tTransmissiveColor < Channel(RGB, Box(TextureTransmissiveColor), Srgb); OutputFormat(BC7); SrgbRead(true); >;
    float4 g_vDetailNormalStrengthOffsetScale < UiType(VectorText); Expression(float4(0,0,1-g_flDetailNormalStrength,g_flDetailNormalStrength)); >;
    float4 g_vDiffuseWrapParameters < UiType(VectorText); Expression(float4(g_flDiffuseWrap,g_flDiffuseExponent,1/(1+g_flDiffuseWrap),(1+g_flDiffuseExponent)/(2+(2*g_flDiffuseWrap)))); >;
    float3 g_vFlatOverlayColor < Default2(1, 0); Attribute("FlatOverlayColor"); UiType(VectorText); >;
    float3 g_vSelfIllumTintScaled < UiType(VectorText); Expression((pow(2,g_flSelfIllumBrightness).x*saturate(g_flSelfIllumScale.x))*SrgbGammaToLinear(g_vSelfIllumTint.xyz)); >;
    float4 g_vShaderIDColor < UiType(VectorText); >;
    
    // Ambient Occlusion
    CreateInputTexture2D(TextureAmbientOcclusion, Linear, 8, "", "_ao", "Ambient Occlusion,40/10", Default4(1, 1, 1, 0));
    float g_flAmbientOcclusionDirectDiffuse < UiType(Slider); UiGroup("Ambient Occlusion/20"); >;
    float g_flAmbientOcclusionDirectSpecular < UiType(Slider); UiGroup("Ambient Occlusion/30"); >;
    bool g_bUseSecondaryUvForAmbientOcclusion < Default(1); UiType(CheckBox); UiGroup("Ambient Occlusion/100"); >;
    
    // Normal
    CreateInputTexture2D(TextureNormal, Linear, 8, "NormalizeNormals", "_normal", "Normal,20", Default4(0.5, 0.5, 1, 0));
    float g_flLightRangeForSelfShadowNormals < UiType(Slider); UiGroup("Normal"); >;
    float g_flNormalMapScaleFactor < Default(1); UiType(Slider); UiGroup("Normal"); >;
    CreateInputTexture2D(TextureBentNormal, Linear, 8, "NormalizeNormals", "_bentnormal", "Normal/20", Default4(0.5, 0.5, 1, 0));
    
    // Color
    CreateInputTexture2D(TextureTintMask, Linear, 8, "", "_mask", "Color", Default4(1, 1, 1, 0));
    CreateInputTexture2D(TextureColor, Srgb, 8, "", "_color", "Color/10", Default4(1, 1, 1, 0));
    bool g_bUseSecondaryUvForTintMask < UiType(CheckBox); UiGroup("Color/101"); >;
    
    // Detail Texture
    CreateInputTexture2D(TextureDetail, Linear, 8, "Mod2XCenter", "_detail", "Detail Texture,80/10", Default4(1, 1, 1, 1));
    CreateInputTexture2D(TextureNormalDetail, Linear, 8, "NormalizeNormals", "_normal", "Detail Texture,80/10", Default4(0.5, 0.5, 1, 0));
    float g_flDetailNormalStrength < Default(1); UiType(Slider); UiGroup("Detail Texture,80/15"); >;
    float g_flDetailBlendFactor < Default(1); UiType(Slider); UiGroup("Detail Texture,80/20"); >;
    CreateInputTexture2D(TextureDetailMask, Linear, 8, "", "_detailmask", "Detail Texture,80/40", Default4(1, 1, 1, 1));
    float g_flDetailBlendToFull < UiType(Slider); UiGroup("Detail Texture,80/50"); >;
    bool g_bUseSecondaryUvForDetailMask < Default(1); UiType(CheckBox); UiGroup("Detail Texture/180"); >;
    
    // Parallax
    CreateInputTexture2D(TextureHeight, Linear, 8, "", "_height", "Parallax", Default4(1, 1, 1, 0));
    bool g_bParallaxSecondaryUV < UiType(CheckBox); UiGroup("Parallax"); >;
    int g_nLODThreshold < Default(4); Range(0, 12); UiType(Slider); UiGroup("Parallax"); >;
    int g_nMaxSamples < Default(32); Range(16, 128); UiType(Slider); UiGroup("Parallax"); >;
    int g_nMinSamples < Default(4); Range(8, 64); UiType(Slider); UiGroup("Parallax"); >;
    
    // Metalness
    CreateInputTexture2D(TextureMetalness, Linear, 8, "", "_metal", "Metalness,27/10", Default4(0, 0, 0, 0));
    float g_flMetalness < UiType(Slider); UiGroup("Metalness,27/20"); >;
    
    // Retro-Reflective
    CreateInputTexture2D(TextureRetroReflectiveMask, Linear, 8, "", "_mask", "Retro-Reflective,29/10", Default4(1, 1, 1, 0));
    float g_flRetroReflectivity < Default(1); UiType(Slider); UiGroup("Retro-Reflective,29/20"); >;
    
    // Roughness
    float g_flRoughnessScaleFactor < Default(1); Range(0, 2); UiType(Slider); UiGroup("Roughness"); >;
    CreateInputTexture2D(TextureRoughness, Linear, 8, "Inverse", "_rough", "Roughness,23/10", Default4(0.5, 0.5, 0.5, 0));
    
    // Self Illum
    float g_flSelfIllumBrightness < Range(-10, 10); UiType(Slider); UiGroup("Self Illum"); >;
    CreateInputTexture2D(TextureSelfIllumMask, Srgb, 8, "", "_selfillum", "Self Illum,60/10", Default4(0, 0, 0, 0));
    float3 g_vSelfIllumTint < Default3(1, 1, 1); UiType(Color); UiGroup("Self Illum/20"); >;
    float g_flSelfIllumScale < Default(1); Range(0, 16); UiType(Slider); UiGroup("Self Illum/30"); >;
    float2 g_vSelfIllumScrollSpeed < Range2(-10, -10, 10, 10); UiType(VectorText); UiGroup("Self Illum/40"); >;
    float g_flSelfIllumAlbedoFactor < Default(1); UiType(Slider); UiGroup("Self Illum/50"); >;
    bool g_bUseSecondaryUvForSelfIllum < UiType(CheckBox); UiGroup("Self Illum/100"); >;
    
    // Translucent
    CreateInputTexture2D(TextureTranslucency, Linear, 8, "", "_trans", "Translucent,15", Default4(1, 1, 1, 0));
    float g_flAlphaTestReference < Range(0.01, 0.99); UiType(Slider); UiGroup("Translucent"); >;
    float g_flAntiAliasedEdgeStrength < Default(1); UiType(Slider); UiGroup("Translucent"); >;
    float g_flOpacityScale < Default(1); UiType(Slider); UiGroup("Translucent"); >;
    
    // Transmission
    CreateInputTexture2D(TextureTransmissiveColor, Srgb, 8, "", "_color", "Transmission", Default4(1, 1, 1, 0));
    float g_flDiffuseExponent < Default(1); Range(1, 2); UiType(Slider); UiGroup("Transmission"); >;
    float g_flDiffuseWrap < Default(1); UiType(Slider); UiGroup("Transmission"); >;
    float3 g_vDiffuseWrapColor < Default3(1, 0.5, 0.3); UiType(Color); UiGroup("Transmission"); >;
    
    // Fog
    bool g_bFogEnabled < Default(1); UiType(CheckBox); UiGroup("Fog,300"); >;
    
    #if (S_ANISOTROPIC_GLOSS == 1)
        Texture2D g_tNormal < Channel(RG, HemiOctIsoRoughness_RG_B(TextureNormal, TextureRoughness), Linear); OutputFormat(ATI2N); SrgbRead(false); >;
    #endif
    #if (S_RETRO_REFLECTIVE == 1)
        Texture2D g_tColor < Channel(RGB, Box(TextureColor), Srgb); OutputFormat(DXT1); SrgbRead(true); >;
        Texture2D g_tNormal < Channel(RGBA, HemiOctIsoRoughness_RG_B(TextureNormal, TextureRoughness), Linear); OutputFormat(BC7); SrgbRead(false); >;
    #endif
    #if (S_ALPHA_TEST == 1)
        Texture2D g_tColor < Channel(RGB, AlphaWeighted(TextureColor, TextureTranslucency), Srgb); Channel(A, PreserveCoverage(TextureTranslucency), Linear); OutputFormat(BC7); SrgbRead(true); >;
    #endif
    #if (S_TRANSLUCENT == 1)
        Texture2D g_tColor < Channel(RGB, AlphaWeighted(TextureColor, TextureTranslucency), Srgb); Channel(A, Box(TextureTranslucency), Linear); OutputFormat(BC7); SrgbRead(true); >;
    #endif
    #if (S_OVERLAY == 1)
        Texture2D g_tColor < Channel(RGB, AlphaWeighted(TextureColor, TextureTranslucency), Srgb); Channel(A, Box(TextureTranslucency), Linear); OutputFormat(BC7); SrgbRead(true); >;
        Texture2D g_tNormal < Channel(RGBA, HemiOctIsoRoughness_RG_B(TextureNormal, TextureRoughness), Linear); OutputFormat(BC7); SrgbRead(false); >;
    #endif
    #if (S_ADDITIVE_BLEND == 1)
        Texture2D g_tColor < Channel(RGB, AlphaWeighted(TextureColor, TextureTranslucency), Srgb); Channel(A, Box(TextureTranslucency), Linear); OutputFormat(BC7); SrgbRead(true); >;
        Texture2D g_tNormal < Channel(RGBA, HemiOctIsoRoughness_RG_B(TextureNormal, TextureRoughness), Linear); OutputFormat(BC7); SrgbRead(false); >;
    #endif
    
    // SPIR-V source (23224), SPVC_BACKEND_HLSL reflection with SPIRV-Cross by KhronosGroup
    // Source 2 Viewer 9.1.0.0 - https://valveresourceformat.github.io
    
    struct _2642
    {
        int4 _m0;
        float4 _m1;
        float4 _m2;
        float4 _m3;
        float4 _m4;
        column_major float4x4 _m5;
        float4 _m6[6];
        float4 _m7[6];
        column_major float4x4 _m8[6];
        float4 _m9;
        column_major float4x4 _m10;
    };
    
    static uint _22063;
    static float _19285;
    static float4 _17208;
    
    cbuffer _1065_3694 : register(b0, space0)
    {
        uint _3694_m0 : packoffset(c1);
        uint _3694_m1 : packoffset(c1.y);
        float _3694_m2 : packoffset(c7.y);
        float _3694_m3 : packoffset(c7.z);
        float _3694_m4 : packoffset(c8);
    };
    
    cbuffer _1189_4459 : register(b1, space0)
    {
        float3 _4459_m0 : packoffset(c19);
        float2 _4459_m1 : packoffset(c26);
        float2 _4459_m2 : packoffset(c26.z);
        float4 _4459_m3 : packoffset(c67);
    };
    
    cbuffer _338_3658 : register(b4, space0)
    {
        uint4 _3658_m0 : packoffset(c0);
        uint4 _3658_m1 : packoffset(c1);
        float4 _3658_m2 : packoffset(c2);
        float4 _3658_m3 : packoffset(c10);
        float4 _3658_m4 : packoffset(c11);
        float4 _3658_m5 : packoffset(c12);
        float4 _3658_m6 : packoffset(c13);
        float4 _3658_m7 : packoffset(c14);
        float4 _3658_m8 : packoffset(c15);
        column_major float4x4 _3658_m9 : packoffset(c16);
        float4 _3658_m10 : packoffset(c20);
        float4 _3658_m11 : packoffset(c25);
        float4 _3658_m12 : packoffset(c26);
        float4 _3658_m13 : packoffset(c27);
        column_major float4x4 _3658_m14[2] : packoffset(c28);
        float4 _3658_m15 : packoffset(c36);
    };
    
    cbuffer _1383_3088 : register(b2, space0)
    {
        column_major float4x3 _3088_m0 : packoffset(c0);
        float4 _3088_m1 : packoffset(c3);
        float4 _3088_m2 : packoffset(c4);
        float4 _3088_m3 : packoffset(c5);
    };
    
    cbuffer _2622_4469 : register(b7, space0)
    {
        int4 _4469_m0 : packoffset(c1);
        float4 _4469_m1[4] : packoffset(c258);
        float4 _4469_m2[3] : packoffset(c263);
    };
    
    ByteAddressBuffer _3685 : register(t167, space0);
    ByteAddressBuffer _4755 : register(t169, space0);
    Texture2D<float4> _3927 : register(t163, space0);
    SamplerState _4413 : register(s70, space0);
    Texture3D<float4> _3156 : register(t164, space0);
    SamplerState _3511 : register(s72, space0);
    SamplerState _4258 : register(s74, space0);
    SamplerState _4038 : register(s75, space0);
    SamplerState _3653 : register(s77, space0);
    Texture2D<float4> _5975 : register(t150, space0);
    SamplerComparisonState _4557 : register(s78, space0);
    SamplerState _3720 : register(s80, space0);
    Texture3D<float4> _4209 : register(t155, space0);
    Texture2D<float4> _4205 : register(t171, space0);
    Texture2D<float4> _4305 : register(t158, space0);
    Texture2D<float4> _4573 : register(t159, space0);
    TextureCube<float4> _5741 : register(t162, space0);
    Texture3D<float4> _5948 : register(t161, space0);
    Texture2D<float4> _3383 : register(t175, space0);
    Texture2D<float4> _5435 : register(t177, space0);
    
    static float4 gl_FragCoord;
    static float3 _5759;
    static float3 _5760;
    static float2 _5761;
    static float4 _5763;
    static float3 _5765;
    static float3 _5766;
    static float4 _5482;
    
    struct SPIRV_Cross_Input
    {
        float3 _5759 : TEXCOORD0;
        float3 _5760 : TEXCOORD1;
        float2 _5761 : TEXCOORD2;
        float4 _5763 : TEXCOORD3;
        float3 _5765 : TEXCOORD4;
        float3 _5766 : TEXCOORD5;
        float4 gl_FragCoord : SV_Position;
    };
    
    struct SPIRV_Cross_Output
    {
        float4 _5482 : SV_Target0;
    };
    
    uint2 spvTextureSize(Texture2D<float4> Tex, uint Level, out uint Param)
    {
        uint2 ret;
        Tex.GetDimensions(Level, ret.x, ret.y, Param);
        return ret;
    }
    
    void frag_main()
    {
        float3 _10753 = _5759 + _3658_m15.xyz;
        float4 _19680 = _3927.Sample(_3511, _5761);
        float4 _19068 = _5435.Sample(_4258, _5761);
        float _17476 = _19068.x;
        float4 _19372 = _3383.Sample(_3511, _5761);
        float _16000 = _19372.x;
        float _19720 = _19372.y;
        float _15495 = (_16000 + _19720) - 1.00392162799835205078125f;
        float _12112 = _16000 - _19720;
        float3 _14896 = normalize(float3(_15495, _12112, (1.0f - abs(_15495)) - abs(_12112)));
        float2 _8781 = pow(_19372.zz, _3694_m2.xx);
        float3 _18676 = normalize(((normalize(_5765) * _14896.x) + (normalize(_5766) * (-_14896.y))) + (normalize(_5760) * _14896.z));
        float2 _22221 = gl_FragCoord.xy - _4459_m1;
        uint2 _21311 = uint2(5u, 5u) & uint2(31u, 31u);
        uint2 _9852 = min((uint2(_4459_m2) >> _21311), uint2(128u, 128u));
        uint _19136 = _9852.x;
        uint _16762 = _9852.y;
        uint2 _9187 = min((uint2(_22221) >> _21311), (uint3(_19136, _16762, _22063).xy - uint2(1u, 1u)));
        float3 _9716;
        uint _24878;
        _9716 = 0.0f.xxx;
        _24878 = 0u;
        float3 _12504;
        uint _13530;
        bool _21310;
        [loop]
        for (;;)
        {
            _21310 = _3694_m0 != 0u;
            _13530 = _9187.x + (_9187.y * _19136);
            if (_24878 < (_21310 ? min(_4755.Load(_13530 * 4 + 0), 64u) : uint(_4469_m0.x)))
            {
                uint _16854 = uint(int(_21310 ? _4755.Load(((((_19136 * _16762) * 2u) + (_13530 * 64u)) + _24878) * 4 + 0) : _24878));
                float4x4 _24372 = asfloat(uint4x4(_3685.Load(_16854 * 800 + 80), _3685.Load(_16854 * 800 + 96), _3685.Load(_16854 * 800 + 112), _3685.Load(_16854 * 800 + 128), _3685.Load(_16854 * 800 + 84), _3685.Load(_16854 * 800 + 100), _3685.Load(_16854 * 800 + 116), _3685.Load(_16854 * 800 + 132), _3685.Load(_16854 * 800 + 88), _3685.Load(_16854 * 800 + 104), _3685.Load(_16854 * 800 + 120), _3685.Load(_16854 * 800 + 136), _3685.Load(_16854 * 800 + 92), _3685.Load(_16854 * 800 + 108), _3685.Load(_16854 * 800 + 124), _3685.Load(_16854 * 800 + 140)));
                float4x4 _15564 = asfloat(uint4x4(_3685.Load(_16854 * 800 + 736), _3685.Load(_16854 * 800 + 752), _3685.Load(_16854 * 800 + 768), _3685.Load(_16854 * 800 + 784), _3685.Load(_16854 * 800 + 740), _3685.Load(_16854 * 800 + 756), _3685.Load(_16854 * 800 + 772), _3685.Load(_16854 * 800 + 788), _3685.Load(_16854 * 800 + 744), _3685.Load(_16854 * 800 + 760), _3685.Load(_16854 * 800 + 776), _3685.Load(_16854 * 800 + 792), _3685.Load(_16854 * 800 + 748), _3685.Load(_16854 * 800 + 764), _3685.Load(_16854 * 800 + 780), _3685.Load(_16854 * 800 + 796)));
                do
                {
                    float2 _8545 = ((1.0f.xx - _8781) * 0.800000011920928955078125f) + 0.60000002384185791015625f.xx;
                    float3 _25152 = _24372[3].xyz - _10753;
                    float3 _6512 = normalize(_25152);
                    float _18880 = dot(_25152, _25152);
                    float _9165 = dot(_18676, _6512);
                    if ((_18880 > asfloat(_3685.Load4(_16854 * 800 + 32)).z) && true)
                    {
                        _12504 = _9716;
                        break;
                    }
                    float _20972 = dot(_6512, -_24372[0].xyz) - asfloat(_3685.Load4(_16854 * 800 + 48)).y;
                    if ((_20972 <= 0.0f) && true)
                    {
                        _12504 = _9716;
                        break;
                    }
                    float3 _8789;
                    float _19370;
                    [branch]
                    if ((int4(_3685.Load4(_16854 * 800 + 0)).z & 64) != 0)
                    {
                        float4 _13395 = mul(float4(_10753, 1.0f), _15564);
                        _8789 = asfloat(_3685.Load4(_16854 * 800 + 16)).xyz * _4209.SampleLevel(_3720, _13395.xyz / _13395.w.xxx, 0.0f).xyz;
                        _19370 = 1.0f;
                    }
                    else
                    {
                        _8789 = asfloat(_3685.Load4(_16854 * 800 + 16)).xyz;
                        _19370 = _20972 * asfloat(_3685.Load4(_16854 * 800 + 48)).z;
                    }
                    float _23235 = isnan(1.0f) ? _18880 : (isnan(_18880) ? 1.0f : max(_18880, 1.0f));
                    float _23035;
                    [branch]
                    if ((int4(_3685.Load4(_16854 * 800 + 0)).z & 16) != 0)
                    {
                        float _12503;
                        uint _20138 = 0u;
                        [unroll]
                        for (;;)
                        {
                            if (_20138 < uint(int4(_3685.Load4(_16854 * 800 + 0)).x))
                            {
                                float4x4 _8743 = asfloat(uint4x4(_3685.Load(_16854 * 800 + _20138 * 64 + 336), _3685.Load(_16854 * 800 + _20138 * 64 + 352), _3685.Load(_16854 * 800 + _20138 * 64 + 368), _3685.Load(_16854 * 800 + _20138 * 64 + 384), _3685.Load(_16854 * 800 + _20138 * 64 + 340), _3685.Load(_16854 * 800 + _20138 * 64 + 356), _3685.Load(_16854 * 800 + _20138 * 64 + 372), _3685.Load(_16854 * 800 + _20138 * 64 + 388), _3685.Load(_16854 * 800 + _20138 * 64 + 344), _3685.Load(_16854 * 800 + _20138 * 64 + 360), _3685.Load(_16854 * 800 + _20138 * 64 + 376), _3685.Load(_16854 * 800 + _20138 * 64 + 392), _3685.Load(_16854 * 800 + _20138 * 64 + 348), _3685.Load(_16854 * 800 + _20138 * 64 + 364), _3685.Load(_16854 * 800 + _20138 * 64 + 380), _3685.Load(_16854 * 800 + _20138 * 64 + 396)));
                                float4 _19319 = float4(_10753, 1.0f);
                                float4 _13396 = mul(_19319, _8743);
                                float3 _12890 = _13396.xyz / _13396.w.xxx;
                                float2 _6792 = _4469_m1[3].z.xx;
                                float3 _24451 = step(float3(asfloat(_3685.Load4(_16854 * 800 + _20138 * 16 + 144)).xy + _6792, 0.0f), _12890) * step(_12890, float3(asfloat(_3685.Load4(_16854 * 800 + _20138 * 16 + 144)).zw - _6792, 1.0f));
                                [branch]
                                if (((_24451.x * _24451.y) * _24451.z) != 0.0f)
                                {
                                    float2 _7248;
                                    float2 _15267;
                                    float2 _16061;
                                    float2 _16062;
                                    float2 _16063;
                                    float4 _20581;
                                    float4 _24373;
                                    float4 _25061;
                                    float _19688;
                                    do
                                    {
                                        _15267 = _12890.xy;
                                        float _20954 = clamp(_12890.z - 9.9999999747524270787835121154785e-07f, 0.0f, 1.0f);
                                        _20581 = _4469_m1[0];
                                        _24373 = _4469_m1[1];
                                        _25061 = _4469_m1[2];
                                        _7248 = _4469_m1[3].xx;
                                        _16061 = _4469_m1[3].yx;
                                        _16062 = _4469_m1[3].xy;
                                        _16063 = _4469_m1[3].yy;
                                        float _15396 = dot(float4(_4205.SampleCmpLevelZero(_4557, _15267 + _7248, _20954), _4205.SampleCmpLevelZero(_4557, _15267 + _16061, _20954), _4205.SampleCmpLevelZero(_4557, _15267 + _16062, _20954), _4205.SampleCmpLevelZero(_4557, _15267 + _16063, _20954)), 0.25f.xxxx);
                                        if ((_15396 == 0.0f) || (_15396 == 1.0f))
                                        {
                                            _19688 = _15396;
                                            break;
                                        }
                                        _19688 = mad(_4205.SampleCmpLevelZero(_4557, _15267, _20954), _24373.y, mad(_15396, _20581.w * 4.0f, dot(float4(_4205.SampleCmpLevelZero(_4557, _15267 + _25061.wz, _20954), _4205.SampleCmpLevelZero(_4557, _15267 + _24373.zw, _20954), _4205.SampleCmpLevelZero(_4557, _15267 + _24373.wz, _20954), _4205.SampleCmpLevelZero(_4557, _15267 + _25061.zw, _20954)), _24373.xxxx)));
                                        break;
                                    } while(false);
                                    if ((int4(_3685.Load4(_16854 * 800 + 0)).z & 128) != 0)
                                    {
                                        float2 _22910 = _15267 - asfloat(_3685.Load4(_16854 * 800 + _20138 * 16 + 144)).xy;
                                        float2 _19774 = asfloat(_3685.Load4(_16854 * 800 + _20138 * 16 + 144)).zw - _15267;
                                        bool2 _25263 = isnan(_22910);
                                        bool2 _25264 = isnan(_19774);
                                        float2 _25265 = max(_22910, _19774);
                                        float2 _25266 = float2(_25263.x ? _19774.x : _25265.x, _25263.y ? _19774.y : _25265.y);
                                        float2 _7710 = float2(_25264.x ? _22910.x : _25266.x, _25264.y ? _22910.y : _25266.y);
                                        float _8769 = _7710.x / (asfloat(_3685.Load4(_16854 * 800 + _20138 * 16 + 144)).z - asfloat(_3685.Load4(_16854 * 800 + _20138 * 16 + 144)).x);
                                        float _18208 = _7710.y / (asfloat(_3685.Load4(_16854 * 800 + _20138 * 16 + 144)).w - asfloat(_3685.Load4(_16854 * 800 + _20138 * 16 + 144)).y);
                                        float _23711 = clamp(((isnan(_18208) ? _8769 : (isnan(_8769) ? _18208 : max(_8769, _18208))) - 0.89999997615814208984375f) * 9.9999980926513671875f, 0.0f, 1.0f);
                                        float _12502;
                                        if (_23711 > 0.0f)
                                        {
                                            uint _11704 = _20138 + 1u;
                                            float4x4 _17363 = asfloat(uint4x4(_3685.Load(_16854 * 800 + _11704 * 64 + 336), _3685.Load(_16854 * 800 + _11704 * 64 + 352), _3685.Load(_16854 * 800 + _11704 * 64 + 368), _3685.Load(_16854 * 800 + _11704 * 64 + 384), _3685.Load(_16854 * 800 + _11704 * 64 + 340), _3685.Load(_16854 * 800 + _11704 * 64 + 356), _3685.Load(_16854 * 800 + _11704 * 64 + 372), _3685.Load(_16854 * 800 + _11704 * 64 + 388), _3685.Load(_16854 * 800 + _11704 * 64 + 344), _3685.Load(_16854 * 800 + _11704 * 64 + 360), _3685.Load(_16854 * 800 + _11704 * 64 + 376), _3685.Load(_16854 * 800 + _11704 * 64 + 392), _3685.Load(_16854 * 800 + _11704 * 64 + 348), _3685.Load(_16854 * 800 + _11704 * 64 + 364), _3685.Load(_16854 * 800 + _11704 * 64 + 380), _3685.Load(_16854 * 800 + _11704 * 64 + 396)));
                                            float _7934;
                                            do
                                            {
                                                float4 _7913 = mul(_19319, _17363);
                                                float3 _11760 = _7913.xyz / _7913.w.xxx;
                                                float3 _24452 = step(float3(asfloat(_3685.Load4(_16854 * 800 + _11704 * 16 + 144)).xy + _6792, 0.0f), _11760) * step(_11760, float3(asfloat(_3685.Load4(_16854 * 800 + _11704 * 16 + 144)).zw - _6792, 1.0f));
                                                if (!(((_24452.x * _24452.y) * _24452.z) != 0.0f))
                                                {
                                                    _7934 = 1.0f;
                                                    break;
                                                }
                                                float _12501;
                                                do
                                                {
                                                    float2 _15268 = _11760.xy;
                                                    float _10357 = clamp(_11760.z - 9.9999999747524270787835121154785e-07f, 0.0f, 1.0f);
                                                    float _15397 = dot(float4(_4205.SampleCmpLevelZero(_4557, _15268 + _7248, _10357), _4205.SampleCmpLevelZero(_4557, _15268 + _16061, _10357), _4205.SampleCmpLevelZero(_4557, _15268 + _16062, _10357), _4205.SampleCmpLevelZero(_4557, _15268 + _16063, _10357)), 0.25f.xxxx);
                                                    if ((_15397 == 0.0f) || (_15397 == 1.0f))
                                                    {
                                                        _12501 = _15397;
                                                        break;
                                                    }
                                                    _12501 = mad(_4205.SampleCmpLevelZero(_4557, _15268, _10357), _24373.y, mad(_15397, _20581.w * 4.0f, dot(float4(_4205.SampleCmpLevelZero(_4557, _15268 + _25061.wz, _10357), _4205.SampleCmpLevelZero(_4557, _15268 + _24373.zw, _10357), _4205.SampleCmpLevelZero(_4557, _15268 + _24373.wz, _10357), _4205.SampleCmpLevelZero(_4557, _15268 + _25061.zw, _10357)), _24373.xxxx)));
                                                    break;
                                                } while(false);
                                                _7934 = _12501;
                                                break;
                                            } while(false);
                                            _12502 = lerp(_19688, _7934, _23711);
                                        }
                                        else
                                        {
                                            _12502 = _19688;
                                        }
                                        _12503 = _12502;
                                        break;
                                    }
                                    else
                                    {
                                        _12503 = _19688;
                                        break;
                                    }
                                }
                                _20138++;
                                continue;
                            }
                            else
                            {
                                _12503 = 1.0f;
                                break;
                            }
                        }
                        _23035 = _12503;
                    }
                    else
                    {
                        _23035 = 1.0f;
                    }
                    if (_23035 <= 0.0f)
                    {
                        _12504 = _9716;
                        break;
                    }
                    float3 _9927;
                    if ((int4(_3685.Load4(_16854 * 800 + 0)).z & 2) != 0)
                    {
                        float _19205 = _8545.x + _8545.y;
                        _9927 = (mad(_19205, 0.5f, 1.0f) * 0.5f).xxx * pow(isnan(_9165) ? 0.0f : (isnan(0.0f) ? _9165 : max(0.0f, _9165)), _19205 * 0.5f);
                    }
                    else
                    {
                        _9927 = 0.0f.xxx;
                    }
                    _12504 = mad((_9927 * _23035) * (clamp((1.0f / dot(float2(sqrt(_23235), _23235), asfloat(_3685.Load4(_16854 * 800 + 32)).xy)) - asfloat(_3685.Load4(_16854 * 800 + 32)).w, 0.0f, 1.0f) * _19370), _8789, _9716);
                    break;
                } while(false);
                _9716 = _12504;
                _24878++;
                continue;
            }
            else
            {
                break;
            }
        }
        float _21709;
        if (_3658_m1.x != 0u)
        {
            float3 _6464 = mul(float4(_10753, 1.0f), _3088_m0);
            _6464.z = _6464.z * 0.16666667163372039794921875f;
            float3 _7050 = clamp(_6464, _3088_m1.xyz, _3088_m2.xyz);
            float _16730 = length(_3156.SampleLevel(_4413, _7050 + float3(0.0f, 0.0f, 0.3333333432674407958984375f), 0.0f).xyz * _3088_m3.xyz) - length(_3156.SampleLevel(_4413, _7050 + float3(0.0f, 0.0f, 0.833333313465118408203125f), 0.0f).xyz * _3088_m3.xyz);
            float3 _19904 = float3(length(_3156.SampleLevel(_4413, _7050, 0.0f).xyz * _3088_m3.xyz) - length(_3156.SampleLevel(_4413, _7050 + float3(0.0f, 0.0f, 0.5f), 0.0f).xyz * _3088_m3.xyz), length(_3156.SampleLevel(_4413, _7050 + float3(0.0f, 0.0f, 0.16666667163372039794921875f), 0.0f).xyz * _3088_m3.xyz) - length(_3156.SampleLevel(_4413, _7050 + float3(0.0f, 0.0f, 0.666666686534881591796875f), 0.0f).xyz * _3088_m3.xyz), _16730);
            _19904.z = _16730 + 9.9999997473787516355514526367188e-05f;
            uint _10352_dummy_parameter;
            uint2 _10352 = spvTextureSize(_4573, 0u, _10352_dummy_parameter);
            float2 _17928 = (_22221 * _3658_m2.x) * (1.0f.xx / float2(int2(int(_10352.x), int(_10352.y))));
            float4 _20544 = _4305.GatherRed(_4038, _17928);
            float4 _23546 = abs(_4573.GatherRed(_4038, _17928) - gl_FragCoord.zzzz);
            float _16633 = isnan(_23546.y) ? _23546.x : (isnan(_23546.x) ? _23546.y : min(_23546.x, _23546.y));
            float _17325 = isnan(_23546.z) ? _16633 : (isnan(_16633) ? _23546.z : min(_16633, _23546.z));
            float _13607 = isnan(_23546.y) ? _23546.x : (isnan(_23546.x) ? _23546.y : max(_23546.x, _23546.y));
            float _12628;
            int _24919 = 0;
            [unroll]
            for (;;)
            {
                if (_24919 < 3)
                {
                    uint _6334 = uint(_24919);
                    if (_23546[_6334] == _17325)
                    {
                        _12628 = _20544[_6334];
                        break;
                    }
                    _24919++;
                    continue;
                }
                else
                {
                    _12628 = 1.0f;
                    break;
                }
            }
            float _7935;
            if (((isnan(_23546.z) ? _13607 : (isnan(_13607) ? _23546.z : max(_13607, _23546.z))) - _17325) < 0.00150000001303851604461669921875f)
            {
                _7935 = _4305.SampleLevel(_3720, _17928, 0.0f).x;
            }
            else
            {
                _7935 = _12628;
            }
            _21709 = lerp(_7935, 1.0f, clamp((dot(-float4(normalize(_19904), _19285).xyz, float3(_18676.x, _18676.y, _18676.z)) + 0.5f) * 2.0f, 0.0f, 1.0f));
        }
        else
        {
            _21709 = 1.0f;
        }
        float4 _18533 = float4(_18676, 1.0f);
        float _20992 = isnan(1.0f) ? _17476 : (isnan(_17476) ? 1.0f : min(_17476, 1.0f));
        float3 _7130 = (isnan(_20992) ? _21709 : (isnan(_21709) ? _20992 : min(_21709, _20992))).xxx;
        float4 _23847;
        _23847.w = _5763.w;
        float3 _17386 = mad(_9716, lerp(1.0f.xxx, _7130, _3694_m4.xxx), float3(dot(_4469_m2[0], _18533), dot(_4469_m2[1], _18533), dot(_4469_m2[2], _18533)) * _7130) * ((_19680.xyz * _5763.xyz) * (1.0f - _3694_m3));
        float4 _6805;
        if (_3694_m1 != 0u)
        {
            float _18390;
            float3 _9252 = _10753 - _4459_m0;
            float3 _22821;
            do
            {
                float2 _21493 = _9252.xy;
                _18390 = _10753.z;
                [branch]
                if ((dot(_21493, _21493) > _3658_m6.x) && (_18390 < _3658_m6.y))
                {
                    float2 _21390 = clamp(mad(_3658_m3.zw, float2(length(_21493), _18390), _3658_m3.xy), 0.0f.xx, 1.0f.xx);
                    float _11897 = (pow(_21390.x, _3658_m4.x) * pow(_21390.y, _3658_m4.y)) * _3658_m5.w;
                    _22821 = lerp(_17386.xyz, float4(_3658_m5.xyz, _11897).xyz, _11897.xxx);
                    break;
                }
                _22821 = _17386.xyz;
                break;
            } while(false);
            float3 _22822;
            do
            {
                if ((dot(_9252, _9252) > _3658_m10.x) || (_18390 > _3658_m10.y))
                {
                    float _24361 = mad(length(_9252), _3658_m7.y, _3658_m7.x);
                    float _16820 = pow(isnan(_24361) ? 0.0f : (isnan(0.0f) ? _24361 : max(0.0f, _24361)), _3658_m7.w);
                    float _24362 = mad(_18390, _3658_m8.y, _3658_m8.x);
                    float _12288 = pow(isnan(_24362) ? 0.0f : (isnan(0.0f) ? _24362 : max(0.0f, _24362)), _3658_m8.z);
                    float _8862 = isnan(_12288) ? _16820 : (isnan(_16820) ? _12288 : max(_16820, _12288));
                    float _11906 = clamp(_8862, 0.0f, 1.0f);
                    _22822 = lerp(_22821.xyz, float4(_5741.SampleLevel(_4038, normalize(mul(float4(_9252, 0.0f), _3658_m9).xyz), _3658_m8.w * clamp(mad(-_8862, _3658_m7.z, 1.0f), 0.0f, 1.0f)).xyz, _11906).xyz, _11906.xxx);
                    break;
                }
                _22822 = _22821.xyz;
                break;
            } while(false);
            float3 _22859;
            do
            {
                if (_3658_m0.x != 0u)
                {
                    float4 _21223 = mul(_3658_m14[0], float4(_10753 + mad(_5975.Sample(_3653, mad(gl_FragCoord.xy, 0.00390625f.xx, _4459_m3.xy)).xyz, _3658_m11.xxx, _3658_m11.yyy), 1.0f));
                    float2 _13482 = _21223.xy / _21223.w.xx;
                    float3 _12386 = mad(float4(_13482.x, _13482.y, _21223.z, _21223.w).xyw, _3658_m12.xyz, _3658_m13.xyz);
                    float4 _20711 = float4(_12386.x, _12386.y, _12386.z, _21223.w);
                    float _24860 = _12386.z;
                    _20711.z = sqrt(isnan(_24860) ? 0.0f : (isnan(0.0f) ? _24860 : max(0.0f, _24860)));
                    float4 _19681 = _5948.Sample(_4038, _20711.xyz);
                    _22859 = mad(_22822.xyz, _19681.www, _19681.xyz);
                    break;
                }
                _22859 = _22822.xyz;
                break;
            } while(false);
            _6805 = float4(_22859.x, _22859.y, _22859.z, _23847.w);
        }
        else
        {
            _6805 = float4(_17386.x, _17386.y, _17386.z, _23847.w);
        }
        _5482 = _6805;
    }
    
    SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
    {
        gl_FragCoord = stage_input.gl_FragCoord;
        gl_FragCoord.w = 1.0 / gl_FragCoord.w;
        _5759 = stage_input._5759;
        _5760 = stage_input._5760;
        _5761 = stage_input._5761;
        _5763 = stage_input._5763;
        _5765 = stage_input._5765;
        _5766 = stage_input._5766;
        frag_main();
        SPIRV_Cross_Output stage_output;
        stage_output._5482 = _5482;
        return stage_output;
    }
    
    // ---------  SPIRV -> HLSL end  --------- 
    
    
    
    BoolAttribute(UsesDynamicReflections, (F_DYNAMIC_REFLECTIONS>0) || 0);
    BoolAttribute(NeedsLightProbe, true);
    BoolAttribute(SupportsLightmapping, F_MORPH_SUPPORTED ? 0 : 1);
    BoolAttribute(PerVertexLighting, F_MORPH_SUPPORTED ? 0 : 1);
    BoolAttribute(DoNotCastShadows, F_DO_NOT_CAST_SHADOWS || 0);
    BoolAttribute(SupportsMappingDimensions, true);
    BoolAttribute(renderbackfaces, F_RENDER_BACKFACES || 0);
    TextureAttribute(LightSim_DiffuseAlbedoTexture, g_tColor);
    TextureAttribute(RepresentativeTexture, g_tColor);
    BoolAttribute(overlay, F_OVERLAY || 0);
    
    #if (S_SPECULAR == 1)
        BoolAttribute(environmentmapped, true);
    #endif
    #if (S_DIFFUSE_WRAP == 0)
        TextureAttribute(LightSim_Opacity_A, g_tColor);
    #endif
    #if (S_SCALE_NORMAL_MAP == 0)
        TextureAttribute(LightSim_Opacity_A, g_tColor);
    #endif
    #if (S_ALPHA_TEST == 0)
        TextureAttribute(LightSim_Opacity_A, g_tColor);
        BoolAttribute(translucent, true);
    #endif
    #if (S_METALNESS_TEXTURE == 0)
        TextureAttribute(LightSim_Opacity_A, g_tColor);
    #endif
    #if (S_SPECULAR_CUBE_MAP_ANISOTROPIC_WARP == 0)
        TextureAttribute(LightSim_Opacity_A, g_tColor);
    #endif
    #if (S_ALPHA_TEST == 1)
        TextureAttribute(LightSim_Opacity_A, g_tColor);
        BoolAttribute(alphatest, true);
    #endif
    #if (S_TRANSLUCENT == 1)
        TextureAttribute(LightSim_Opacity_A, g_tColor);
        BoolAttribute(translucent, true);
    #endif
    #if (S_USE_BENT_NORMALS == 0)
        TextureAttribute(LightSim_Opacity_A, g_tColor);
    #endif
    #if (S_ENABLE_NORMAL_SELF_SHADOW == 0)
        TextureAttribute(LightSim_Opacity_A, g_tColor);
    #endif
    #if (S_TINT_MASK == 0)
        TextureAttribute(LightSim_Opacity_A, g_tColor);
    #endif
    #if (S_RENDER_BACKFACES == 1)
        TextureAttribute(LightSim_Opacity_A, g_tColor);
    #endif
    #if (S_RENDER_BACKFACES == 0)
        TextureAttribute(LightSim_TintMaskTextureR, g_tTintMask);
    #endif
    #if (S_SELF_ILLUM == 0)
        TextureAttribute(LightSim_Opacity_A, g_tColor);
    #endif
    #if (S_TINT_MASK == 1)
        TextureAttribute(LightSim_TintMaskTextureR, g_tTintMask);
    #endif
    #if (S_SELF_ILLUM == 1)
        TextureAttribute(LightSim_SelfIllumMaskTexture, g_tSelfIllumMask);
        Float3Attribute(LightSim_SelfIllumTint, g_vSelfIllumTint);
        FloatAttribute(LightSim_SelfIllumScale, g_flSelfIllumScale);
    #endif
    #if (S_ADDITIVE_BLEND == 0)
        TextureAttribute(LightSim_Opacity_A, g_tColor);
    #endif
    #if (S_RETRO_REFLECTIVE == 0)
        TextureAttribute(LightSim_Opacity_A, g_tColor);
    #endif
    #if (S_ANISOTROPIC_GLOSS == 0)
        TextureAttribute(LightSim_Opacity_A, g_tColor);
    #endif
    #if (S_OVERLAY == 0)
        TextureAttribute(LightSim_Opacity_A, g_tColor);
    #endif
    #if (S_PARALLAX_OCCLUSION == 0)
        TextureAttribute(LightSim_Opacity_A, g_tColor);
    #endif
    #if (S_MODE_REFLECTIONS == 0)
        TextureAttribute(LightSim_Opacity_A, g_tColor);
    #endif
    #if (S_MODE_TOOLS_VIS == 0)
        TextureAttribute(LightSim_Opacity_A, g_tColor);
    #endif
    #if (S_PARALLAX_OCCLUSION == 1)
        TextureAttribute(LightSim_Opacity_A, g_tColor);
        BoolAttribute(alphatest, true);
    #endif
    #if (S_ANISOTROPIC_GLOSS == 1)
        BoolAttribute(environmentmapped, true);
    #endif
    #if (S_RETRO_REFLECTIVE == 1)
        BoolAttribute(environmentmapped, true);
    #endif
    #if (S_TRANSMISSIVE_BACKFACE_NDOTL == 0)
        TextureAttribute(LightSim_Opacity_A, g_tColor);
    #endif
    #if (S_TRANSLUCENT == 0)
        TextureAttribute(LightSim_Opacity_A, g_tColor);
        BoolAttribute(alphatest, true);
    #endif
    #if (S_OVERLAY == 1)
        TextureAttribute(LightSim_Opacity_A, g_tColor);
        BoolAttribute(translucent, true);
    #endif
    #if (S_ADDITIVE_BLEND == 1)
        TextureAttribute(LightSim_Opacity_A, g_tColor);
        BoolAttribute(translucent, true);
    #endif
    #if (S_CLOTH_SHADING == 0)
        TextureAttribute(LightSim_Opacity_A, g_tColor);
    #endif
    #if (S_SPECULAR == 0)
        TextureAttribute(LightSim_Opacity_A, g_tColor);
    #endif
}
