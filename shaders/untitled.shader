HEADER
{
    Description = "Cel Shader";
    DevShader = true;
}

MODES
{
    Default();
    VrForward();
}

FEATURES
{
    #include "common/features.hlsl"
}

COMMON
{
    #include "common/shared.hlsl"
}

struct VertexInput
{
    float3 vPositionOs : POSITION < Semantic( PosXyz ); >;
    float2 vTexCoord : TEXCOORD0 < Semantic( LowPrecisionUv ); >;
};

struct PixelInput
{
    float2 uv : TEXCOORD0;
};

VS
{
    PixelInput MainVs( VertexInput i )
    {
        PixelInput o;
        o.uv = i.vTexCoord;
        return o;
    }
}

PS
{
    #include "postprocess/common.hlsl"
    #include "postprocess/functions.hlsl"

    CreateTexture2D( g_tColorBuffer ) < Attribute( "ColorBuffer" ); SrgbRead( true ); Filter( MIN_MAG_LINEAR_MIP_POINT ); AddressU( MIRROR ); AddressV( MIRROR ); >;

    float4 FetchSceneColor( float2 vScreenUv )
    {
        return Tex2D( g_tColorBuffer, vScreenUv.xy );
    }

    float4 MainPs( PixelInput i ): SV_Target
    {
        float2 vScreenUv = i.uv;
        float4 vSceneColor = FetchSceneColor( vScreenUv );

        // Cel shading
        float luminance = dot(vSceneColor.rgb, float3(0.2126, 0.7152, 0.0722));
        float3 color = vSceneColor.rgb;
        if (luminance < 0.2) {
            color = float3(0.0, 0.0, 0.0); // Shadows
        } else if (luminance < 0.5) {
            color = float3(0.5, 0.5, 0.5); // Midtones
        } else {
            color = float3(1.0, 1.0, 1.0); // Highlights
        }

        return float4(color, vSceneColor.a);
    }
}