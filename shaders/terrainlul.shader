//
// Simple Terrain shader with 4 layer splat
//

HEADER
{
	Description = "Terrain";
    DevShader = true;
    DebugInfo = false;
}

FEATURES
{
    // gonna go crazy the amount of shit this stuff adds and fails to compile without
    #include "vr_common_features.fxc"
}

MODES
{
    VrForward();
    Depth( S_MODE_DEPTH );
    ToolsVis( S_MODE_TOOLS_VIS );
    ToolsWireframe( S_MODE_TOOLS_WIREFRAME );
}

COMMON
{
    // Opt out of stupid shit
    #define CUSTOM_MATERIAL_INPUTS
    #define CUSTOM_TEXTURE_FILTERING

    #include "common/shared.hlsl"

    CreateTexture2DWithoutSampler( g_tHeightMap ) < Attribute( "HeightMap" ); SrgbRead( false ); >;
    CreateTexture2DWithoutSampler( g_tControlMap ) < Attribute( "ControlMap" ); SrgbRead( false ); >;

    // Used to sample the heightmap
    SamplerState g_sBilinearBorder < Filter( BILINEAR ); AddressU( BORDER ); AddressV( BORDER ); >;

    float4x4 TransformMat < Attribute( "TransformMat" ); >; 
    float4x4 TransformMatInv < Attribute( "TransformMatInv" ); >; 
    float g_flHeightScale < Attribute( "HeightScale" ); Default( 1024.0f ); >;
    float g_flTerrainResolution < Attribute( "TerrainResolution" ); Default( 40.0f ); >;
    int g_nDebugView < Attribute( "DebugView" ); >;
    int g_nPreviewLayer < Attribute( "PreviewLayer" ); >;


    struct TerrainLayer
    {
        float2 a; // int64_t 
        float2 b;
        float2 c;
        float2 d;
        float uvscale;
        float uvrotation;
        float reserved0;
        float reserved1;
        float4 reserved2;
        float4 reserved3;
        float4 reserved4;
        float4 reserved5;
    };

    StructuredBuffer<TerrainLayer> g_TerrainLayers < Attribute( "LayersBuffer" ); >;
}

struct VertexInput
{
	float3 PositionAndLod : POSITION < Semantic( PosXyz ); >;
};

struct PixelInput
{
    float3 LocalPosition : TEXCOORD0;
    float3 WorldPosition : TEXCOORD1;
    uint LodLevel : COLOR0;

    #if ( PROGRAM == VFX_PROGRAM_VS )
        float4 PixelPosition : SV_Position;
    #endif

    #if ( PROGRAM == VFX_PROGRAM_PS )
        float4 ScreenPosition : SV_Position;
    #endif
};

VS
{
    #include "terrain/TerrainClipmap.hlsl"

	PixelInput MainVs( VertexInput i )
	{
        PixelInput o;

        o.LocalPosition = Terrain_ClipmapSingleMesh( i.PositionAndLod, g_tHeightMap, g_flTerrainResolution, TransformMatInv );
        o.WorldPosition = mul( TransformMat, float4( o.LocalPosition, 1.0 ) ).xyz;
        o.PixelPosition = Position3WsToPs( o.WorldPosition.xyz );
        o.LodLevel = i.PositionAndLod.z;

		return o;
	}
}

//=========================================================================================================================

PS
{
    StaticCombo( S_MODE_TOOLS_WIREFRAME, 0..1, Sys( ALL ) );
    StaticCombo( S_MODE_DEPTH, 0..1, Sys( ALL ) );
    DynamicCombo( D_GRID, 0..1, Sys( ALL ) );    
    DynamicCombo( D_AUTO_SPLAT, 0..1, Sys( ALL ) );    

    #include "common/material.hlsl"
    #include "common/shadingmodel.hlsl"

    #include "terrain/TerrainCommon.hlsl"
    #include "terrain/TerrainNoTile.hlsl"

    // Why not texture arrays? Because they all have to be the same size/format, need to be baked or created at runtime.
    // This is ideal for bindless textures though, so I'll work on those next.
    CreateTexture2DWithoutSampler( g_tAlbedo0 ) < Attribute( "Albedo0" ); SrgbRead( true ); >;
    CreateTexture2DWithoutSampler( g_tAlbedo1 ) < Attribute( "Albedo1" ); SrgbRead( true ); >;
    CreateTexture2DWithoutSampler( g_tAlbedo2 ) < Attribute( "Albedo2" ); SrgbRead( true ); >;
    CreateTexture2DWithoutSampler( g_tAlbedo3 ) < Attribute( "Albedo3" ); SrgbRead( true ); >;
    CreateTexture2DWithoutSampler( g_tNormal0 ) < Attribute( "Normal0" ); SrgbRead( false ); >;
    CreateTexture2DWithoutSampler( g_tNormal1 ) < Attribute( "Normal1" ); SrgbRead( false ); >;
    CreateTexture2DWithoutSampler( g_tNormal2 ) < Attribute( "Normal2" ); SrgbRead( false ); >;
    CreateTexture2DWithoutSampler( g_tNormal3 ) < Attribute( "Normal3" ); SrgbRead( false ); >;

    SamplerState g_sAnisotropic < Filter( ANISOTROPIC ); MaxAniso(8); >;

	#if ( S_MODE_TOOLS_WIREFRAME )
		RenderState( FillMode, WIREFRAME );
		RenderState( SlopeScaleDepthBias, -0.5 ); // Depth bias params tuned for plantation_source2 under DX11
		RenderState( DepthBiasClamp, -0.0005 );
	#endif

    void Terrain_Splat4( in float2 texUV, in float4 control, out float3 albedo, out float3 normal )
    {
        texUV /= 32;

        // it's probably better for paralallism to sample all than if statement
        // this will look better with bindless
        float3 albedo0 = Tex2DS( g_tAlbedo0, g_sAnisotropic, texUV * g_TerrainLayers[0].uvscale );
        float3 albedo1 = Tex2DS( g_tAlbedo1, g_sAnisotropic, texUV * g_TerrainLayers[1].uvscale );
        float3 albedo2 = Tex2DS( g_tAlbedo2, g_sAnisotropic, texUV * g_TerrainLayers[2].uvscale );
        float3 albedo3 = Tex2DS( g_tAlbedo3, g_sAnisotropic, texUV * g_TerrainLayers[3].uvscale );

        float3 norm0 = DecodeNormal( Tex2DS( g_tNormal0, g_sAnisotropic, texUV * g_TerrainLayers[0].uvscale ).rgb ); 
        float3 norm1 = DecodeNormal( Tex2DS( g_tNormal1, g_sAnisotropic, texUV * g_TerrainLayers[1].uvscale ).rgb ); 
        float3 norm2 = DecodeNormal( Tex2DS( g_tNormal2, g_sAnisotropic, texUV * g_TerrainLayers[2].uvscale ).rgb ); 
        float3 norm3 = DecodeNormal( Tex2DS( g_tNormal3, g_sAnisotropic, texUV * g_TerrainLayers[3].uvscale ).rgb ); 

        albedo = albedo0 * control.r + albedo1 * control.g + albedo2 * control.b + albedo3 * control.a;
        normal = norm0 * control.r + norm1 * control.g + norm2 * control.b + norm3 * control.a; // additive?
    }

	//
	// Main
	//
	float4 MainPs( PixelInput i ) : SV_Target0
	{
        float2 texSize = TextureDimensions2D( g_tHeightMap, 0 );
        float2 uv = i.LocalPosition.xy / ( texSize * g_flTerrainResolution );

        // Clip any of the clipmap that exceeds the heightmap bounds
        if ( uv.x < 0.0 || uv.y < 0.0 || uv.x > 1.0 || uv.y > 1.0 )
        {
            clip( -1 );
            return float4( 0, 0, 0, 0 );
        }

        #if ( S_MODE_TOOLS_WIREFRAME )
           return Terrain_WireframeColor( i.LodLevel );
        #endif

        // calculate geometric normal
        float3 tangentU, tangentV;
        float3 geoNormal = Terrain_Normal( g_tHeightMap, uv, tangentU, tangentV );
        geoNormal = mul( TransformMat, float4( geoNormal, 0.0 ) ).xyz;

        float3 albedo = float3( 1, 1, 1 );
        float3 norm = float3( 0, 0, 1 );
        float roughness = 1;

    #if D_GRID
        Terrain_ProcGrid( i.LocalPosition.xy, albedo, roughness );
    #else
        // Not adding up to 1 is invalid, but lets just give everything to the first layer
        float4 control = Tex2DS( g_tControlMap, g_sBilinearBorder, uv );
        float sum = control.x + control.y + control.z + control.w;

        #if D_AUTO_SPLAT
        if ( sum != 1.0f )
        {
            float invsum = 1.0f - sum;
            float slope_weight = saturate( ( geoNormal.z - 0.99 ) * 100 );
            control.x += ( slope_weight ) * invsum;
            control.y += ( 1.0f - slope_weight ) * invsum;
        }
        #else
        // anything unsplatted, defualt to channel 0
        if ( sum != 1.0f ) { control.x += 1.0f - sum; }
        #endif

        Terrain_Splat4( i.LocalPosition.xy, control, albedo, norm );
    #endif

        Material p = Material::Init();
        p.Albedo = albedo;
        p.Normal = TransformNormal( norm, geoNormal, tangentU, tangentV );
        p.Roughness = roughness;
        p.Metalness = 0.0f;
        p.AmbientOcclusion = 1.0f;
        p.TextureCoords = uv;

        p.WorldPosition = i.WorldPosition;
        p.WorldPositionWithOffset = i.WorldPosition - g_vHighPrecisionLightingOffsetWs.xyz;
        p.ScreenPosition = i.ScreenPosition;
        p.GeometricNormal = geoNormal;

        p.WorldTangentU = tangentU;
        p.WorldTangentV = tangentV;

        if ( g_nDebugView != 0 )
        {
            return Terrain_Debug( i, p );
        }

	    return ShadingModelStandard::Shade( p );
	}
}