HEADER
{
	DevShader = false;
	Description = "Modern Multiblend Shader";
	Version = 1;
}

//=========================================================================================================================

MODES
{
	VrForward();

	Depth( "depth_only.shader" ); 
	Reflection( S_MODE_REFLECTIONS );

	ToolsVis( S_MODE_TOOLS_VIS );
	ToolsWireframe( "vr_tools_wireframe.shader" );
	ToolsShadingComplexity( "tools_shading_complexity.shader" );
}

//=========================================================================================================================

FEATURES
{
    #include "common/features.hlsl"

    // 5 layers puts too much pressure into registers, I'm keeping it to 4 but modders can experiment with it
    Feature( F_MULTIBLEND, 0..3 ( 0="1 Layers", 1="2 Layers", 2="3 Layers", 3="4 Layers", 4="5 Layers" ), "Number Of Blendable Layers" );
	Feature( F_USE_TINT_MASKS_IN_VERTEX_PAINT, 0..1, "Use Tint Masks In Vertex Paint" );
	
	Feature( F_DYNAMIC_REFLECTIONS, 0..1, "Rendering" );
	//Feature( F_TRIPLANAR, 0..1, "Triplanar Mapping" );
}

//=========================================================================================================================

COMMON
{
	#define CUSTOM_MATERIAL_INPUTS
	#include "common/shared.hlsl"
}


//=========================================================================================================================

struct VertexInput
{	
	float4 vColorBlendValues : TEXCOORD4 < Semantic( VertexPaintBlendParams ); >;
	float4 vColorPaintValues : TEXCOORD5 < Semantic( VertexPaintTintColor ); >;
	#include "common/vertexinput.hlsl"
};

//=========================================================================================================================

struct PixelInput
{
	float4 vBlendValues		 : TEXCOORD14;
	float4 vPaintValues		 : TEXCOORD15;
	#include "common/pixelinput.hlsl"
};

//=========================================================================================================================

VS
{
	StaticCombo( S_MULTIBLEND, F_MULTIBLEND, Sys( PC ) );
	
	#include "common/vertex.hlsl"

	BoolAttribute( VertexPaintUI2Layer, F_MULTIBLEND == 1 );
	BoolAttribute( VertexPaintUI3Layer, F_MULTIBLEND == 2 );
	BoolAttribute( VertexPaintUI4Layer, F_MULTIBLEND == 3 );
	BoolAttribute( VertexPaintUI5Layer, F_MULTIBLEND == 4 );
	BoolAttribute( VertexPaintUIPickColor, true );

	//
	// Main
	//
	PS_INPUT MainVs( VS_INPUT i )
	{
		PS_INPUT o = ProcessVertex( i );

		o.vBlendValues = i.vColorBlendValues;
        o.vPaintValues = i.vColorPaintValues;

		// Models don't have vertex paint data, let's avoid painting them black
		[flatten]
		if( o.vPaintValues.w == 0 )
			o.vPaintValues = 1.0f;

		return FinalizeVertex( o );
	}
}

//=========================================================================================================================

PS
{
	//
	// Combos
	//
	StaticCombo( S_MULTIBLEND, F_MULTIBLEND, Sys( PC ) );
    StaticCombo( S_USE_TINT_MASKS_IN_VERTEX_PAINT, F_USE_TINT_MASKS_IN_VERTEX_PAINT, Sys( PC ) );
    //StaticCombo( S_TRIPLANAR, F_TRIPLANAR, Sys( PC ) );

	//
	// Includes
	//
	#include "raytracing/reflections.hlsl"
    #include "common/pixel.hlsl"

	#if ( S_MODE_REFLECTIONS )
		#define FinalOutput ReflectionOutput
	#else
		#define FinalOutput float4
	#endif

	//
	// Inputs
	//
		//
		// Material A
		//
		CreateInputTexture2D( TextureColorA,            Srgb,   8, "",                 "_color",  "Material A,10/10", Default3( 1.0, 1.0, 1.0 ) );
		CreateInputTexture2D( TextureNormalA,           Linear, 8, "NormalizeNormals", "_normal", "Material A,10/20", Default3( 0.5, 0.5, 1.0 ) );
		CreateInputTexture2D( TextureRoughnessA,        Linear, 8, "",                 "_rough",  "Material A,10/30", Default( 0.5 ) );
		CreateInputTexture2D( TextureMetalnessA,        Linear, 8, "",                 "_metal",  "Material A,10/40", Default( 1.0 ) );
		CreateInputTexture2D( TextureAmbientOcclusionA, Linear, 8, "",                 "_ao",     "Material A,10/50", Default( 1.0 ) );
		CreateInputTexture2D( TextureBlendMaskA,        Linear, 8, "",                 "_blend",  "Material A,10/60", Default( 1.0 ) );
		CreateInputTexture2D( TextureTintMaskA,         Linear, 8, "",                 "_tint",   "Material A,10/70", Default( 1.0 ) );
		float3 g_flTintColorA < UiType( Color ); Default3( 1.0, 1.0, 1.0 ); UiGroup( "Material A,10/80" ); >;
		float g_flBlendSoftnessA < Default( 0.5 ); Range( 0.1, 1.0 ); UiGroup( "Material A,10/90" ); >;

		#if S_TRIPLANAR
			float g_flTriplanarBlendA < Default( 0.5f ); Range( 0.0f, 1.0f ); UiGroup( "Material A,10/110"); >;
			float2 g_flTriplanarTileA < Default2( 1.0f, 1.0f ); Range2( 0.01f, 0.01f, 10.0f, 10.0f ); UiGroup( "Material A,10/120"); >;
		#endif

		CreateTexture2DWithoutSampler( g_tColorA )  < Channel( RGB,  Box( TextureColorA ), Srgb ); Channel( A, Box( TextureTintMaskA ), Linear ); OutputFormat( BC7 ); SrgbRead( true ); >;
		CreateTexture2DWithoutSampler( g_tNormalA ) < Channel( RGB, Box( TextureNormalA ), Linear ); OutputFormat( DXT5 ); SrgbRead( false ); >;
		CreateTexture2DWithoutSampler( g_tRmaA )    < Channel( R,    Box( TextureRoughnessA ), Linear ); Channel( G, Box( TextureMetalnessA ), Linear ); Channel( B, Box( TextureAmbientOcclusionA ), Linear );  Channel( A, Box( TextureBlendMaskA ), Linear ); OutputFormat( BC7 ); SrgbRead( false ); >;

		TextureAttribute( LightSim_DiffuseAlbedoTexture, g_tColorA );
    	TextureAttribute( RepresentativeTexture, g_tColorA );

	#if S_MULTIBLEND >= 1
		//
		// Material B
		//
		CreateInputTexture2D( TextureColorB,            Srgb,   8, "",                 "_color",  "Material B,10/10", Default3( 1.0, 1.0, 1.0 ) );
		CreateInputTexture2D( TextureNormalB,           Linear, 8, "NormalizeNormals", "_normal", "Material B,10/20", Default3( 0.5, 0.5, 1.0 ) );
		CreateInputTexture2D( TextureRoughnessB,        Linear, 8, "",                 "_rough",  "Material B,10/30", Default( 0.5 ) );
		CreateInputTexture2D( TextureMetalnessB,        Linear, 8, "",                 "_metal",  "Material B,10/40", Default( 1.0 ) );
		CreateInputTexture2D( TextureAmbientOcclusionB, Linear, 8, "",                 "_ao",     "Material B,10/50", Default( 1.0 ) );
		CreateInputTexture2D( TextureBlendMaskB,        Linear, 8, "",                 "_blend",  "Material B,10/60", Default( 1.0 ) );
		CreateInputTexture2D( TextureTintMaskB,         Linear, 8, "",                 "_tint",   "Material B,10/70", Default( 1.0 ) );
		float3 g_flTintColorB < UiType( Color ); Default3( 1.0, 1.0, 1.0 ); UiGroup( "Material B,10/80" ); >;
		float g_flBlendSoftnessB < Default( 0.5 ); Range( 0.1, 1.0 ); UiGroup( "Material B,10/90" ); >;
		float2 g_vTexCoordScale2 < Default2( 1.0, 1.0 ); Range2( 0.0, 0.0, 10.0, 10.0 ); UiGroup( "Material B,10/100" ); >;

		#if S_TRIPLANAR
			float g_flTriplanarBlendB < Default( 0.5f ); Range( 0.0f, 1.0f ); UiGroup( "Material B,10/110"); >;
			float2 g_flTriplanarTileB < Default2( 1.0f, 1.0f ); Range2( 0.01f, 0.01f, 10.0f, 10.0f ); UiGroup( "Material B,10/120"); >;
		#endif

		CreateTexture2DWithoutSampler( g_tColorB )  < Channel( RGB,  Box( TextureColorB ), Srgb ); Channel( A, Box( TextureTintMaskB ), Linear ); OutputFormat( BC7 ); SrgbRead( true ); >;
		CreateTexture2DWithoutSampler( g_tNormalB ) < Channel( RGB, Box( TextureNormalB ), Linear ); OutputFormat( DXT5 ); SrgbRead( false ); >;
		CreateTexture2DWithoutSampler( g_tRmaB )    < Channel( R,    Box( TextureRoughnessB ), Linear ); Channel( G, Box( TextureMetalnessB ), Linear ); Channel( B, Box( TextureAmbientOcclusionB ), Linear );  Channel( A, Box( TextureBlendMaskB ), Linear ); OutputFormat( BC7 ); SrgbRead( false ); >;

	#if S_MULTIBLEND >= 2
		//
		// Material C
		//
		CreateInputTexture2D( TextureColorC,            Srgb,   8, "",                 "_color",  "Material C,10/10", Default3( 1.0, 1.0, 1.0 ) );
		CreateInputTexture2D( TextureNormalC,           Linear, 8, "NormalizeNormals", "_normal", "Material C,10/20", Default3( 0.5, 0.5, 1.0 ) );
		CreateInputTexture2D( TextureRoughnessC,        Linear, 8, "",                 "_rough",  "Material C,10/30", Default( 0.5 ) );
		CreateInputTexture2D( TextureMetalnessC,        Linear, 8, "",                 "_metal",  "Material C,10/40", Default( 1.0 ) );
		CreateInputTexture2D( TextureAmbientOcclusionC, Linear, 8, "",                 "_ao",     "Material C,10/50", Default( 1.0 ) );
		CreateInputTexture2D( TextureBlendMaskC,        Linear, 8, "",                 "_blend",  "Material C,10/60", Default( 1.0 ) );
		CreateInputTexture2D( TextureTintMaskC,         Linear, 8, "",                 "_tint",   "Material C,10/70", Default( 1.0 ) );
		float3 g_flTintColorC < UiType( Color ); Default3( 1.0, 1.0, 1.0 ); UiGroup( "Material C,10/80" ); >;
		float g_flBlendSoftnessC < Default( 0.5 ); Range( 0.1, 1.0 ); UiGroup( "Material C,10/90" ); >;
		float2 g_vTexCoordScale3 < Default2( 1.0, 1.0 ); Range2( 0.0, 0.0, 10.0, 10.0 ); UiGroup( "Material C,10/100" ); >;

		#if S_TRIPLANAR
			float g_flTriplanarBlendC < Default( 0.5f ); Range( 0.0f, 1.0f ); UiGroup( "Material C,10/110"); >;
			float2 g_flTriplanarTileC < Default2( 1.0f, 1.0f ); Range2( 0.01f, 0.01f, 10.0f, 10.0f ); UiGroup( "Material C,10/120"); >;
		#endif

		CreateTexture2DWithoutSampler( g_tColorC )  < Channel( RGB,  Box( TextureColorC ), Srgb ); Channel( A, Box( TextureTintMaskC ), Linear ); OutputFormat( BC7 ); SrgbRead( true ); >;
		CreateTexture2DWithoutSampler( g_tNormalC ) < Channel( RGB, Box( TextureNormalC ), Linear ); OutputFormat( DXT5 ); SrgbRead( false ); >;
		CreateTexture2DWithoutSampler( g_tRmaC )    < Channel( R,    Box( TextureRoughnessC ), Linear ); Channel( G, Box( TextureMetalnessC ), Linear ); Channel( B, Box( TextureAmbientOcclusionC ), Linear );  Channel( A, Box( TextureBlendMaskC ), Linear ); OutputFormat( BC7 ); SrgbRead( false ); >;


	#if S_MULTIBLEND >= 3
		//
		// Material D
		//
		CreateInputTexture2D( TextureColorD,            Srgb,   8, "",                 "_color",  "Material D,10/10", Default3( 1.0, 1.0, 1.0 ) );
		CreateInputTexture2D( TextureNormalD,           Linear, 8, "NormalizeNormals", "_normal", "Material D,10/20", Default3( 0.5, 0.5, 1.0 ) );
		CreateInputTexture2D( TextureRoughnessD,        Linear, 8, "",                 "_rough",  "Material D,10/30", Default( 0.5 ) );
		CreateInputTexture2D( TextureMetalnessD,        Linear, 8, "",                 "_metal",  "Material D,10/40", Default( 1.0 ) );
		CreateInputTexture2D( TextureAmbientOcclusionD, Linear, 8, "",                 "_ao",     "Material D,10/50", Default( 1.0 ) );
		CreateInputTexture2D( TextureBlendMaskD,        Linear, 8, "",                 "_blend",  "Material D,10/60", Default( 1.0 ) );
		CreateInputTexture2D( TextureTintMaskD,         Linear, 8, "",                 "_tint",   "Material D,10/70", Default( 1.0 ) );
		float3 g_flTintColorD < UiType( Color ); Default3( 1.0, 1.0, 1.0 ); UiGroup( "Material D,10/80" ); >;
		float g_flBlendSoftnessD < Default( 0.5 ); Range( 0.1, 1.0 ); UiGroup( "Material D,10/90" ); >;
		float2 g_vTexCoordScale4 < Default2( 1.0, 1.0 ); Range2( 0.0, 0.0, 10.0, 10.0 ); UiGroup( "Material D,10/100" ); >;

		
		#if S_TRIPLANAR
			float g_flTriplanarBlendD < Default( 0.5f ); Range( 0.0f, 1.0f ); UiGroup( "Material D,10/110"); >;
			float2 g_flTriplanarTileD < Default2( 1.0f, 1.0f ); Range2( 0.01f, 0.01f, 10.0f, 10.0f ); UiGroup( "Material D,10/120"); >;
		#endif

		CreateTexture2DWithoutSampler( g_tColorD )  < Channel( RGB,  Box( TextureColorD ), Srgb ); Channel( A, Box( TextureTintMaskD ), Linear ); OutputFormat( BC7 ); SrgbRead( true ); >;
		CreateTexture2DWithoutSampler( g_tNormalD ) < Channel( RGB, Box( TextureNormalD ), Linear ); OutputFormat( DXT5 ); SrgbRead( false ); >;
		CreateTexture2DWithoutSampler( g_tRmaD )    < Channel( R,    Box( TextureRoughnessD ), Linear ); Channel( G, Box( TextureMetalnessD ), Linear ); Channel( B, Box( TextureAmbientOcclusionD ), Linear );  Channel( A, Box( TextureBlendMaskD ), Linear ); OutputFormat( BC7 ); SrgbRead( false ); >;
	#if S_MULTIBLEND >= 4
		//
		// Material E
		//
		CreateInputTexture2D( TextureColorE,            Srgb,   8, "",                 "_color",  "Material E,10/10", Default3( 1.0, 1.0, 1.0 ) );
		CreateInputTexture2D( TextureNormalE,           Linear, 8, "NormalizeNormals", "_normal", "Material E,10/20", Default3( 0.5, 0.5, 1.0 ) );
		CreateInputTexture2D( TextureRoughnessE,        Linear, 8, "",                 "_rough",  "Material E,10/30", Default( 0.5 ) );
		CreateInputTexture2D( TextureMetalnessE,        Linear, 8, "",                 "_metal",  "Material E,10/40", Default( 1.0 ) );
		CreateInputTexture2D( TextureAmbientOcclusionE, Linear, 8, "",                 "_ao",     "Material E,10/50", Default( 1.0 ) );
		CreateInputTexture2D( TextureBlendMaskE,        Linear, 8, "",                 "_blend",  "Material E,10/60", Default( 1.0 ) );
		CreateInputTexture2D( TextureTintMaskE,         Linear, 8, "",                 "_tint",   "Material E,10/70", Default( 1.0 ) );
		float3 g_flTintColorE < UiType( Color ); Default3( 1.0, 1.0, 1.0 ); UiGroup( "Material E,10/80" ); >;
		float g_flBlendSoftnessE < Default( 0.5 ); Range( 0.1, 1.0 ); UiGroup( "Material E,10/90" ); >;
		float2 g_vTexCoordScale5 < Default2( 1.0, 1.0 ); Range2( 0.0, 0.0, 10.0, 10.0 ); UiGroup( "Material E,10/100" ); >;

		
		#if S_TRIPLANAR
			float g_flTriplanarBlendE < Default( 0.5f ); Range( 0.0f, 1.0f ); UiGroup( "Material E,10/110"); >;
			float2 g_flTriplanarTileE < Default2( 1.0f, 1.0f ); Range2( 0.01f, 0.01f, 10.0f, 10.0f ); UiGroup( "Material E,10/120"); >;
		#endif

		CreateTexture2DWithoutSampler( g_tColorE )  < Channel( RGB,  Box( TextureColorE ), Srgb ); Channel( A, Box( TextureTintMaskE ), Linear ); OutputFormat( BC7 ); SrgbRead( true ); >;
		CreateTexture2DWithoutSampler( g_tNormalE ) < Channel( RGB, Box( TextureNormalE ), Linear ); OutputFormat( DXT5 ); SrgbRead( false ); >;
		CreateTexture2DWithoutSampler( g_tRmaE )    < Channel( R,    Box( TextureRoughnessE ), Linear ); Channel( G, Box( TextureMetalnessE ), Linear ); Channel( B, Box( TextureAmbientOcclusionE ), Linear );  Channel( A, Box( TextureBlendMaskE ), Linear ); OutputFormat( BC7 ); SrgbRead( false ); >;

	#endif // 4
	#endif // 3
	#endif // 2
	#endif // 1
	
	#define FETCH_MULTIBLEND( X, S ) \
			MaterialMultiblend::From( i, \
                Tex2DS( g_tColor##X, 	TextureFiltering, i.vTextureCoords.xy * S ), \
                Tex2DS( g_tNormal##X, 	TextureFiltering, i.vTextureCoords.xy * S ), \
                Tex2DS( g_tRma##X, 		TextureFiltering, i.vTextureCoords.xy * S ), \
                g_flTintColor##X \
            )
		
	//
	// Structures
	//
	class MaterialMultiblend : Material
	{
		static Material lerp( Material a, Material b, float fBlendValue, float fBlendMaskB, float fSoftness = 0.5 )
		{
			float fBlendfactor = ComputeBlendWeight( fBlendValue, fSoftness, fBlendMaskB );
			return Material::lerp( a, b, fBlendfactor );
		}

		static Material From( PixelInput i, float4 vColor, float4 vNormalTs, float4 vRMA, float3 vTintColor = float3( 1.0f, 1.0f, 1.0f ), float3 vEmission = float3( 0.0f, 0.0f, 0.0f ) )
		{
			Material p = Material::Init();
			p.Albedo = vColor.rgb;
			p.Normal = TransformNormal( DecodeNormal( vNormalTs.xyz ), i.vNormalWs, i.vTangentUWs, i.vTangentVWs );
			p.Roughness = vRMA.r;
			p.Metalness = vRMA.g;
			p.AmbientOcclusion = vRMA.b;
			p.TintMask = vColor.a;
			p.Opacity = 1.0f;
			p.Emission = vEmission.rgb;
			p.Transmission = 0;

			p.WorldPosition = i.vPositionWithOffsetWs;
			p.WorldPositionWithOffset = i.vPositionWithOffsetWs;
			p.ScreenPosition = i.vPositionSs;
			p.GeometricNormal = i.vNormalWs;
			
			// Do tint
			p.Albedo = ::lerp( p.Albedo.rgb, p.Albedo.rgb * vTintColor, p.TintMask );

			return p;
		}

		static Material From( PixelInput i )
		{
			Material m = FETCH_MULTIBLEND( A, 1.0f );

			#if S_MULTIBLEND >= 1
				if( i.vBlendValues.r > 0.0f )
				{
					float flBlendMaskB = Tex2DS( g_tRmaB, TextureFiltering, i.vTextureCoords.xy ).a;
					m = lerp( m, FETCH_MULTIBLEND( B, g_vTexCoordScale2 ), i.vBlendValues.r, flBlendMaskB, g_flBlendSoftnessB ); 
				}
			#if S_MULTIBLEND >= 2
				if( i.vBlendValues.g > 0.0f )
				{
					float flBlendMaskC = Tex2DS( g_tRmaC, TextureFiltering, i.vTextureCoords.xy ).a;
					m = lerp( m, FETCH_MULTIBLEND( C, g_vTexCoordScale3 ), i.vBlendValues.g, flBlendMaskC, g_flBlendSoftnessC );
				}
			#if S_MULTIBLEND >= 3
				if( i.vBlendValues.b > 0.0f )
				{
					float flBlendMaskD = Tex2DS( g_tRmaD, TextureFiltering, i.vTextureCoords.xy ).a;
					m = lerp( m, FETCH_MULTIBLEND( D, g_vTexCoordScale4 ), i.vBlendValues.b, flBlendMaskD, g_flBlendSoftnessD );
				}
			#if S_MULTIBLEND >= 4
				if( i.vBlendValues.a > 0.0f )
				{
					float flBlendMaskE = Tex2DS( g_tRmaE, TextureFiltering, i.vTextureCoords.xy ).a;
					m = lerp( m, FETCH_MULTIBLEND( E, g_vTexCoordScale5 ), i.vBlendValues.a, flBlendMaskE, g_flBlendSoftnessE );
				}
			#endif // 4
			#endif // 3
			#endif // 2
			#endif // 1

			return m;
		}
	};

	//
	// Main
	//
	FinalOutput MainPs( PixelInput i ) : SV_Target0
	{
		//
		// Set up materials
		//
		Material m = MaterialMultiblend::From( i );

		#if ( S_MODE_REFLECTIONS )
		{
			return Reflections::From( i, m, SampleCountIntersection );
		}
		#else
		{
			//
			// Vertex Painting
			//
			#if( S_USE_TINT_MASKS_IN_VERTEX_PAINT )
			{
				m.Albedo = lerp( m.Albedo.xyz, m.Albedo.xyz * i.vPaintValues.xyz, m.TintMask.x );
			}
			#else
			{
				m.Albedo = m.Albedo.xyz * i.vPaintValues.xyz;
			}
			#endif
			
			//
			// Write to final combiner
			//
			return ShadingModelStandard::Shade( i, m );
		}
		#endif

	}
}