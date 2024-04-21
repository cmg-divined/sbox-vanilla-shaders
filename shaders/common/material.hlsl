#ifndef COMMON_PIXEL_MATERIAL_H
#define COMMON_PIXEL_MATERIAL_H

#include "vr_common_ps_code.fxc"
#include "common/utils/normal.hlsl"

//-----------------------------------------------------------------------------
//
// Material Texture Inputs
//
//-----------------------------------------------------------------------------
#ifndef CUSTOM_MATERIAL_INPUTS
    CreateInputTexture2D(TextureColor, Srgb, 8, "", "_color", "Material,10/10", Default3(1.0, 1.0, 1.0));
    CreateInputTexture2D(TextureNormal, Linear, 8, "NormalizeNormals", "_normal", "Material,10/20", Default3(0.5, 0.5, 1.0));
    CreateInputTexture2D(TextureRoughness, Linear, 8, "", "_rough", "Material,10/30", Default(0.5));
    CreateInputTexture2D(TextureMetalness, Linear, 8, "", "_metal", "Material,10/40", Default(1.0));
    CreateInputTexture2D(TextureAmbientOcclusion, Linear, 8, "", "_ao", "Material,10/50", Default(1.0));
    CreateInputTexture2D(TextureBlendMask, Linear, 8, "", "_blend", "Material,10/60", Default(1.0));
    CreateInputTexture2D(TextureTranslucency, Linear, 8, "", "_trans", "Material,10/70", Default3(1.0, 1.0, 1.0));
    CreateInputTexture2D(TextureTintMask, Linear, 8, "", "_tint", "Material,10/70", Default(1.0));

    float3  g_flTintColor      < Default3( 1.0, 1.0, 1.0);  UiGroup("Material,10/90");  UiType(Color); > ;
    float   g_flSelfIllumScale < Default ( 1.0 );           UiGroup("Material,10/91");  Range(0.0, 16.0); >;

    CreateTexture2DWithoutSampler(g_tColor) < Channel(RGB, AlphaWeighted(TextureColor, TextureTranslucency), Srgb); Channel(A, Box(TextureTranslucency), Linear); OutputFormat(BC7); SrgbRead(true); > ;
    CreateTexture2DWithoutSampler(g_tNormal) < Channel(RGB, Box(TextureNormal), Linear); Channel(A, Box(TextureTintMask), Linear); OutputFormat(DXT5); SrgbRead(false); > ;
    CreateTexture2DWithoutSampler(g_tRma) < Channel(R, Box(TextureRoughness), Linear); Channel(G, Box(TextureMetalness), Linear); Channel(B, Box(TextureAmbientOcclusion), Linear); Channel(A, Box(TextureBlendMask), Linear); OutputFormat(BC7); SrgbRead(false); > ;

    // For VRAD3
    TextureAttribute(LightSim_DiffuseAlbedoTexture, g_tColor);
    TextureAttribute(RepresentativeTexture, g_tColor);
#endif

// Setup a bunch of attributes for vrad

BoolAttribute( SupportsLightmapping, ( F_MORPH_SUPPORTED ) ? false : true );
BoolAttribute( PerVertexLighting, ( F_MORPH_SUPPORTED ) ? false : true );

// Fucking mess
#ifndef SBOX_PIXEL_H
	#if ( S_TRANSLUCENT )
	    BoolAttribute( translucent, true );
	#endif

	#if ( S_ALPHA_TEST )
	    BoolAttribute( alphatest, true );
	#endif
#endif

BoolAttribute( DoNotCastShadows, F_DO_NOT_CAST_SHADOWS ? true : false );
BoolAttribute( SupportsMappingDimensions, true );

BoolAttribute( renderbackfaces, F_RENDER_BACKFACES ? true : false );

/////////////////////////////////////////////////////

#ifndef CUSTOM_TEXTURE_FILTERING
    SamplerState TextureFiltering < Filter((F_TEXTURE_FILTERING == 0 ? ANISOTROPIC : (F_TEXTURE_FILTERING == 1 ? BILINEAR : (F_TEXTURE_FILTERING == 2 ? TRILINEAR : (F_TEXTURE_FILTERING == 3 ? POINT : NEAREST))))); MaxAniso(8); > ;
#endif

// FXC doesn't understand ::
#if ( !defined( DXC ) )
#define ::lerp lerp
#endif

//-----------------------------------------------------------------------------
//
// The Material API is used to define the surface properties of a mesh.
//
// This probably makes more sense if we call it Surface like every other engine
// Especially when we have another concept of Materials too...
//
//-----------------------------------------------------------------------------
class Material
{
    float3 Albedo;
    float  Metalness;
    float  Roughness;
    float3 Emission; // Emissive color
    float3 Normal; // World normal
    float  TintMask;
    float  AmbientOcclusion;
    float3 Transmission; // This should probably be TransmissiveMask
    float Opacity;

    //
    // This stuff is part of what describes a surface too and needed for lighting
    //
    float3 WorldPosition;
	float3 WorldPositionWithOffset; // IDK    
    float4 ScreenPosition; // SV_Position
    float3 GeometricNormal;

    // baked lighting and/or anisotropic lighting
    float3 TangentNormal;
    float3 WorldTangentU;
    float3 WorldTangentV;    
    float2 LightmapUV; // if D_BAKED_LIGHTING_FROM_LIGHTMAP

    float2 TextureCoords; // if TOOL_VIS

    //
    // Setup default values, could be called InitMaterial()
    //
    static Material Init()
    {
        Material m;

        m.Albedo = float3( 1.0, 1.0, 1.0 );
        m.Metalness = 0.0;
        m.Roughness = 1.0;
        m.Emission = float3( 0.0, 0.0, 0.0 );
        m.Normal = float3( 0.0, 0.0, 1.0 );
        m.TintMask = 1.0;
        m.AmbientOcclusion = 1.0f;
        m.Transmission = float3( 0.0, 0.0, 0.0 );
        m.Opacity = 1;

        m.WorldPosition = float3( 0.0, 0.0, 0.0 );
        m.WorldPositionWithOffset = float3( 0.0, 0.0, 0.0 );
        m.ScreenPosition = float4( 0.0, 0.0, 0.0, 0.0 );
        m.GeometricNormal = float3( 0.0, 0.0, 1.0 );

        m.TangentNormal = float3( 0.0, 0.0, 1.0 );
        m.WorldTangentU = float3( 1.0, 0.0, 0.0 );
        m.WorldTangentV = float3( 0.0, 1.0, 0.0 );
        m.LightmapUV = float2( 0, 0 );

        m.TextureCoords = float2( 0, 0 );

        return m;
    }

    //
    // Some helpers for common PixelInput, should be phased out really
    //

#ifdef COMMON_PS_INPUT_DEFINED

    //-----------------------------------------------------------------------------
    //
    // Create a material structure from inputs
    //
    //-----------------------------------------------------------------------------
    static Material From(   PixelInput i, 
                            float4 vColor, 
                            float4 vNormalTs, 
                            float4 vRMA, 
                            float3 vTintColor = float3( 1.0f, 1.0f, 1.0f ), 
                            float3 vEmission = float3( 0.0f, 0.0f, 0.0f ) )
    {
        Material p = Material::Init();

        p.Albedo = vColor.rgb;
        p.Normal = TransformNormal( DecodeNormal( vNormalTs.xyz ), i.vNormalWs, i.vTangentUWs, i.vTangentVWs );
        p.Roughness = vRMA.r;
        p.Metalness = vRMA.g;
        p.AmbientOcclusion = vRMA.b;
        p.TintMask = vNormalTs.a;   // Tint mask is stored in the alpha channel of the normal map
        p.Opacity = vColor.a;       // Opacity is stored in the alpha channel of the color map
        p.Emission = vEmission.rgb;       
        
        // Do tint
        p.Albedo = ::lerp( p.Albedo.rgb, p.Albedo.rgb * vTintColor, p.TintMask );

        // Seems backwards.. But it's what Valve were doing?
        p.WorldPosition = i.vPositionWithOffsetWs + g_vHighPrecisionLightingOffsetWs.xyz;
        p.WorldPositionWithOffset = i.vPositionWithOffsetWs;
        p.ScreenPosition = i.vPositionSs;

        return p;
    }

    //-----------------------------------------------------------------------------
    //
    // Create a material structure from standard texture inputs
    //
    //-----------------------------------------------------------------------------
#ifndef CUSTOM_MATERIAL_INPUTS
    static Material From( PixelInput i )
    {
        float2 vUV = i.vTextureCoords.xy;
        Material material = Material::From( i,
                                        Tex2DS( g_tColor,   TextureFiltering, vUV  ), 
                                        Tex2DS( g_tNormal,  TextureFiltering, vUV  ), 
                                        Tex2DS( g_tRma,     TextureFiltering, vUV  ), 
                                        g_flTintColor  );

        return material;
    }
#endif

#endif // COMMON_PS_INPUT_DEFINED

    //-----------------------------------------------------------------------------
    //
    // Lerp function for Material
    //
    //-----------------------------------------------------------------------------
    static Material lerp( Material a, Material b, float amount )
    {
        Material o = a;

        o.Albedo = ::lerp( a.Albedo, b.Albedo, amount );
        o.Emission = ::lerp( a.Emission, b.Emission, amount );
        o.Opacity = ::lerp( a.Opacity, b.Opacity, amount );

        o.TintMask = ::lerp( a.TintMask, b.TintMask, amount );

        // no other field is available with the unlit shading model
        o.Normal = ::lerp( a.Normal, b.Normal, amount );
        o.Roughness = ::lerp( a.Roughness, b.Roughness, amount );
        o.Metalness = ::lerp( a.Metalness, b.Metalness, amount );
        o.AmbientOcclusion = ::lerp( a.AmbientOcclusion, b.AmbientOcclusion, amount );

        return o;
    }
};


#endif //COMMON_PIXEL_MATERIAL_H