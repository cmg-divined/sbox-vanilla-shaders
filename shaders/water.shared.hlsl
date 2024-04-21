#ifndef WATER_SHARED_H
#define WATER_SHARED_H

//---------------------------------------------------------------------------------------------
// Ripple
//---------------------------------------------------------------------------------------------
CreateTexture2D( RippleTexture ) < Attribute( "RippleTexture" );	  SrgbRead( true );   AddressU( CLAMP ); AddressV( CLAMP ); >;
float g_flSplashRadius < Attribute( "SplashRadius" ); Default( 512.0f ); >;
float2 g_vSplashViewPosition < Attribute( "SplashViewPosition" );  >;

// Shared constants ------------------------------------------------------------------------------------------------------------------------------------

float g_fWaterHeight < Attribute( "WaterHeight" ); >;

#define DRAG_MULT 0.048
#define ITERATIONS_NORMAL 50

//-------------------------------------------------------------------------------------------------------------------------------------------------------------

// returns float2 with wave height in X and its derivative in Y
float2 WaveDerivates(float2 position, float2 direction, float speed, float frequency, float timeshift)
{
	direction = normalize(direction);
	float x = dot(direction, position) * frequency + timeshift * speed;
	float wave = exp(sin(x) - 1.0);
	float dx = wave * cos(x);
	return float2(wave, -dx);
}

float2 GetWaterFlow()
{
	//Todo: flowmaps
	return 0.0f;
}

float2 SampleSplash( float2 vPos )
{
	float2 vTexCoordSplash = ( ( vPos - g_vSplashViewPosition ) / g_flSplashRadius ) * 0.5f + 0.5f;
	
	// If PS sample a higher quality, bicubic one, else do a bilinear fetch
	#if ( PROGRAM == VFX_PROGRAM_PS )
		float2 vSplashColor = Tex2DBicubic( PassToArgTexture2D( RippleTexture ), vTexCoordSplash, TextureDimensions2D( RippleTexture, 0 ) ).rg;
	#else
		float2 vSplashColor = Tex2DLevel( RippleTexture, vTexCoordSplash, 0 ).rg;
	#endif

	return 1.0 - vSplashColor;
}



float GetWaves(float2 position, int iterations = ITERATIONS_NORMAL, float flTimeShift = 0.0f )
{
  
	//
	// Sample the splash water flow
	//
	float fSplash = 0.0f;

	if( g_bRipples )
		fSplash = ( ( SampleSplash( position ).x * 2.0f ) - 2.0f ) / g_fScale;

	position *= 0.01;
	position += GetWaterFlow();
	float iter = 0.0;

	float phase = g_fPhase;
	float speed = g_fSpeed;
	float weight = g_fWeight;

	float w = 0.0;
	float ws = 0.0;
	[unroll]
	for( int i=0; i<iterations; i++ ) {
		float2 p = float2(sin(iter), cos(iter));
		float2 res = WaveDerivates(position, p, speed, phase, ( g_flTime + flTimeShift ) % 100);
		position += normalize(p) * res.y * weight * DRAG_MULT;
		w += res.x * weight;
		iter += 12.0;
		ws += weight;
		weight = lerp(weight, 0.0, 0.2);
		phase *= 1.18;
		speed *= 1.07;
	}

	 return (w / ws) + fSplash;
}

float3 WaterNormal(float2 p, int iIterations = ITERATIONS_NORMAL, float flTimeShift = 0.0f, bool bReduceHorizonAliasing = false, float fNoL = 1.0f )
{
	//
	// Reduce specular aliasing from horizon line
	//
	if( bReduceHorizonAliasing )
	{
		iIterations = ITERATIONS_NORMAL * saturate( pow( fNoL, 0.15f ) );
		iIterations = max( iIterations, 5 );

		//
		// Makes it so that waves are not fully uniform, eg simulating wind ripples, looks much better
		//
		float l = GetWaves(p * 0.3, 5, g_flTime * -0.5f );
		iIterations = lerp( 5, iIterations, saturate( l ) );
	}



	// https://iquilezles.org/www/articles/normalsSDF/normalsSDF.htm
	const float eps = 0.1; // or some other value
	const float2 h = float2(eps,0);
	return normalize( float3(   ( GetWaves(p+h.xy, iIterations, flTimeShift ) - GetWaves(p-h.xy, iIterations, flTimeShift ) ),
								( GetWaves(p+h.yx, iIterations, flTimeShift ) - GetWaves(p-h.yx, iIterations, flTimeShift ) ),
								h.x / g_fScale ) );
}

// Debug Visualization functions -----------------------------------------------------------------------------------------------------------------------------

float2 DebugSplashUV( float2 vPos )
{
	float2 vTexCoordSplash = ( ( vPos - g_vSplashViewPosition ) / g_flSplashRadius ) * 0.5f + 0.5f;
	float2 vSplashColor = SampleSplash( vPos );
	if( vTexCoordSplash.x > 0 && vTexCoordSplash.x < 1 && vTexCoordSplash.y > 0 && vTexCoordSplash.y < 1 )
		return vSplashColor;
	else
		return 0;
}

float GetWaterVerticalOffset( float2 vPositionWs )
{
	return ( GetWaves( vPositionWs.xy, 20 ) * g_fScale * 6 ) - g_fScale * 3;
}

#endif