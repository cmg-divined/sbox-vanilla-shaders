//=========================================================================================================================
// Optional
//=========================================================================================================================
HEADER
{
    Description = "Glass Shader";
    Version = 3;
}

//=========================================================================================================================
// Optional
//=========================================================================================================================
FEATURES
{
    #include "common/features.hlsl"
    Feature( F_GLASS_QUALITY, 0..1( 0 ="Default Glass ( Refractive, Tinted )", 1 = "Simple Glass ( Faster To Render )" ), "Glass");
    Feature( F_OVERLAY_LAYER, 0..1, "Glass");
}

//=========================================================================================================================
// Optional
//=========================================================================================================================
MODES
{
    VrForward();                                               // Indicates this shader will be used for main rendering
    ToolsVis( S_MODE_TOOLS_VIS );                                // Ability to see in the editor
    ToolsWireframe("vr_tools_wireframe.shader");               // Allows for mat_wireframe to work
    ToolsShadingComplexity("tools_shading_complexity.shader"); // Shows how expensive drawing is in debug view
    Depth( S_MODE_DEPTH );
}

//=========================================================================================================================
COMMON
{
    #include "common/shared.hlsl"
}

//=========================================================================================================================

struct VertexInput
{
    #include "common/vertexinput.hlsl"
};

//=========================================================================================================================

struct PixelInput
{
    #include "common/pixelinput.hlsl"
};

//=========================================================================================================================

VS
{
    #include "common/vertex.hlsl"
    //
    // Main
    //
    PixelInput MainVs(VS_INPUT i)
    {
        PixelInput o = ProcessVertex(i);
        // Add your vertex manipulation functions here
        return FinalizeVertex(o);
    }
}

//=========================================================================================================================

PS
{
    // Combos ----------------------------------------------------------------------------------------------
    StaticCombo( S_CHEAP_GLASS, F_GLASS_QUALITY, Sys( ALL ) );
    StaticCombo( S_OVERLAY_LAYER, F_OVERLAY_LAYER, Sys( ALL ) );
    StaticCombo( S_MODE_DEPTH, 0..1, Sys(ALL) );

    DynamicCombo( D_SKYBOX, 0..1, Sys(PC) );

    // Attributes ------------------------------------------------------------------------------------------

    // Transparency
    #if (S_CHEAP_GLASS)
        #define BLEND_MODE_ALREADY_SET
        RenderState(BlendEnable, true);
        RenderState(SrcBlend, SRC_ALPHA);
        RenderState(DstBlend, INV_SRC_ALPHA);
    #endif

    #include "common/pixel.hlsl"
    #include "common/classes/Depth.hlsl"

    BoolAttribute(bWantsFBCopyTexture, !S_CHEAP_GLASS);
    BoolAttribute(translucent, true);

    CreateTexture2D( g_tFrameBufferCopyTexture ) < Attribute("FrameBufferCopyTexture");   SrgbRead( false ); Filter(MIN_MAG_MIP_LINEAR);    AddressU( MIRROR );     AddressV( MIRROR ); > ;    
    CreateTexture2DMS( g_tSceneDepth )           < Attribute( "DepthBuffer" );            SrgbRead( false ); Filter( POINT );               AddressU( MIRROR );     AddressV( MIRROR ); >;
	
    //
    // Blur and Refraction Settings
    //
    float g_flBlurAmount < Default(0.0f); Range(0.0f, 1.0f); UiGroup("Glass,10/10"); > ;
    float g_flRefractionStrength < Default(1.005); Range(1.0, 1.1); UiGroup("Glass,10/20"); > ;

    //
    // Overlay layer
    //
    #if (S_OVERLAY_LAYER)
        CreateInputTexture2D(TextureColorB, Srgb, 8, "", "_color", "MaterialB,10/10", Default3(1.0, 1.0, 1.0));
        CreateInputTexture2D(TextureNormalB, Linear, 8, "NormalizeNormals", "_normal", "MaterialB,10/20", Default3(0.5, 0.5, 1.0));
        CreateInputTexture2D(TextureRoughnessB, Linear, 8, "", "_rough", "MaterialB,10/30", Default(0.5));
        CreateInputTexture2D(TextureMetalnessB, Linear, 8, "", "_metal", "MaterialB,10/40", Default(1.0));
        CreateInputTexture2D(TextureAmbientOcclusionB, Linear, 8, "", "_ao", "MaterialB,10/50", Default(1.0));
        CreateInputTexture2D(TextureBlendMaskB, Linear, 8, "", "_blend", "MaterialB,10/60", Default(1.0));
        CreateInputTexture2D(TextureTranslucencyB, Linear, 8, "", "_trans", "MaterialB,10/70", Default3(1.0, 1.0, 1.0));
        CreateInputTexture2D(TextureTintMaskB, Linear, 8, "", "_tint", "MaterialB,10/70", Default(1.0));

        float3 g_flTintColorB < UiType(Color); Default3(1.0, 1.0, 1.0); UiGroup("MaterialB,10/90"); > ;

        CreateTexture2DWithoutSampler(g_tColorB) < Channel(RGB, AlphaWeighted(TextureColorB, TextureTranslucency), Srgb); Channel(A, Box(TextureTranslucencyB), Linear); OutputFormat(BC7); SrgbRead(true); > ;
        CreateTexture2DWithoutSampler(g_tNormalB) < Channel(RGB, Box(TextureNormalB), Linear); Channel(A, Box(TextureTintMask), Linear); OutputFormat(DXT5); SrgbRead(false); > ;
        CreateTexture2DWithoutSampler(g_tRmaB) < Channel(R, Box(TextureRoughnessB), Linear); Channel(G, Box(TextureMetalnessB), Linear); Channel(B, Box(TextureAmbientOcclusionB), Linear); Channel(A, Box(TextureBlendMaskB), Linear); OutputFormat(BC7); SrgbRead(false); > ;
    #endif
    
    // Code -----------------------------------------------------------------------------------------------

    //
    // Main
    //
    float4 MainPs(PixelInput i)  : SV_Target0
    {
        Material m = Material::From( i );

        // Shadows
        #if S_MODE_DEPTH
        {
            float flOpacity = CalcBRDFReflectionFactor(dot(-i.vNormalWs.xyz, g_vCameraDirWs.xyz), m.Roughness, 0.04).x;

            flOpacity = pow(flOpacity, 1.0f / 2.0f);
            flOpacity = lerp(flOpacity, 0.75f, sqrt(m.Roughness));       // Glossiness
            flOpacity = lerp(flOpacity, 1.0 - dot(-i.vNormalWs.xyz, g_vCameraDirWs.xyz), ( g_flRefractionStrength - 1.0f ) * 5.0f );       // Refraction
            flOpacity = lerp( 1.0f, flOpacity , ( length(m.Albedo) * 0.5f ) + 0.5f ); // Albedo absorption

            OpaqueFadeDepth(flOpacity, i.vPositionSs.xy);

            return 1;
        }
        #endif

        m.Metalness = 0; // Glass is always non-metallic

        float3 vViewRayWs = normalize(i.vPositionWithOffsetWs.xyz);
        float flNDotV = saturate(dot(-m.Normal, vViewRayWs));
        float3 vEnvBRDF = CalcBRDFReflectionFactor(flNDotV, m.Roughness, 0.04);

        #if !S_CHEAP_GLASS
        {
            float4 vRefractionColor = 0;

            float flDepthPs = Depth::GetNormalized( i.vPositionSs.xy );
            float3 vRefractionWs = RecoverWorldPosFromProjectedDepthAndRay(flDepthPs, normalize(i.vPositionWithOffsetWs.xyz)) - g_vCameraPositionWs;
            float flDistanceVs = distance(i.vPositionWithOffsetWs.xyz, vRefractionWs);

            float3 vRefractRayWs = refract(vViewRayWs, m.Normal, 1.0 / g_flRefractionStrength);
            float3 vRefractWorldPosWs = i.vPositionWithOffsetWs.xyz + vRefractRayWs * flDistanceVs;

            float4 vPositionPs = Position4WsToPs( float4(vRefractWorldPosWs, 0));

            float2 vPositionSs = vPositionPs.xy / vPositionPs.w;
            vPositionSs = vPositionSs * 0.5 + 0.5;

            vPositionSs.y = 1.0 - vPositionSs.y;

            #if D_SKYBOX
            {
                // Todo: Reprojection from world on skybox does wrong transformation, so don't refract there
                vPositionSs = i.vPositionSs.xy * g_vInvViewportSize;
            }
            #endif

            //
            // Color and blur
            //
            {
                float flAmount = g_flBlurAmount * m.Roughness * (1.0 - (1.0 / flDistanceVs));

                // Isotropic blur based on grazing angle
                flAmount /= flNDotV;

                const int nNumMips = 7;

                float2 vUV = float2(vPositionSs) * g_vFrameBufferCopyInvSizeAndUvScale.zw;

                vRefractionColor = Tex2DLevel(g_tFrameBufferCopyTexture, vUV, sqrt(flAmount) * nNumMips);
            }

            // Blend
            {
                m.Emission = lerp( vRefractionColor.xyz, 0.0f, vEnvBRDF );
                m.Emission *= m.Albedo;
                m.Albedo = 0;
            }

            #if S_MODE_TOOLS_VIS
                m.Albedo = m.Emission;
                m.Emission = 0;
            #endif
        }
        #endif

        #if S_OVERLAY_LAYER
        {
            Material materialB = Material::From( i,
                                                 Tex2DS(g_tColorB, TextureFiltering, i.vTextureCoords.xy),
                                                 Tex2DS(g_tNormalB, TextureFiltering, i.vTextureCoords.xy),
                                                 Tex2DS(g_tRmaB, TextureFiltering, i.vTextureCoords.xy),
                                                 g_flTintColorB );

            m = Material::lerp( m, materialB, materialB.Opacity );
        }
        #endif

        return ShadingModelStandard::Shade( i, m );
    }
}
