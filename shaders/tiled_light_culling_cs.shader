//-------------------------------------------------------------------------------------------------------------------------------------------------------------
HEADER
{
	DevShader = true;
	Description = "Compute Shader for processing light culling by tiles.";
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------------
MODES
{
	Default();
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------------
FEATURES
{
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------------
COMMON
{
	#include "system.fxc" // This should always be the first include in COMMON
    #include "vr_common.fxc"
    
    enum CullingLightJobs
    {
        CULLING_LIGHT_JOB_CULL_LIGHTS, 		// Cull and test visibility dynamic lights
        CULLING_LIGHT_JOB_STATIC_LIGHTS, 	// Test Visibility For Static Lights
        CULLING_LIGHT_JOB_CULL_ENVMAPS, 	// Cull envmaps
        CULLING_LIGHT_JOB_COUNT
    }

    DynamicCombo( D_DEPTH_PREPASS,          0..1, Sys( ALL ) );
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------------
CS
{
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------
    #include "vr_lighting.fxc"
    #include "common/lightbinner.hlsl"

	//-------------------------------------------------------------------------------------------------------------------------------------------------------------
	//
	// System Parameters 
	//
	//-------------------------------------------------------------------------------------------------------------------------------------------------------------
    CreateTexture2D( DepthChainDownsample ) < Attribute( "DepthChainDownsample" ); SrgbRead( false ); Filter( MIN_MAG_MIP_POINT ); AddressU( CLAMP ); AddressV( CLAMP ); >;

    RWStructuredBuffer<uint> LightVisibility < Attribute( "LightVisibility" ); >; // RWBuffer is fucked?
    
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------

    float DepthRelativeToRayCurvature( float flProjectedDepth, float3 rd )
    {
        float flZScale = g_vInvProjRow3.z;
        float flZTran = g_vInvProjRow3.w;

        float flDepthRelativeToRayCurvature = 1.0 / ( ( flProjectedDepth * flZScale + flZTran ) * dot( g_vCameraDirWs.xyz, rd ) );

        return flDepthRelativeToRayCurvature;
    }
    
    float FetchDepthMax( uint2 vPositionSs, float3 rd )
    {        
        #if ( D_DEPTH_PREPASS == 0 )
            return 0;
        #endif

        // Calculate depth
        float flProjectedDepth = Tex2DLoad( DepthChainDownsample, int3( vPositionSs.xy, 5) ).y;

		// Remap depth to viewport depth range
		flProjectedDepth = RemapValClamped( flProjectedDepth, g_flViewportMinZ, g_flViewportMaxZ, 0.0, 1.0 );

        return DepthRelativeToRayCurvature( flProjectedDepth, rd );
    }

    // Modified from Inigo Quilez
    float SphereIntersect( in float3 ro, in float3 rd, in float3 ce, float ra )
    {
        ra *= 1.25;
        float3 oc = ro - ce;
        float b = dot( oc, rd );
        float c = dot( oc, oc ) - ra;
        float h = b*b - c * 0.985;
        if( h< 0 || b > sqrt(h) ) return -1.0; // no intersection
        h = sqrt( h );
        return max( -b-h, 0.1 );
    }

    bool BoxInside( float3 vMin, float3 vMax, float3 vPos )
    {
        return ( vPos.x >= vMin.x && vPos.x <= vMax.x ) &&
               ( vPos.y >= vMin.y && vPos.y <= vMax.y ) &&
               ( vPos.z >= vMin.z && vPos.z <= vMax.z );
    }
    
    // Modified from Inigo Quilez
	float BoxIntersect( in float3 ro, in float3 rd, float3 mins, float3 maxs )
    {
		float3 invR = 1.0 / rd;
		float3 tbot = invR * ( mins - ro );
		float3 ttop = invR * ( maxs - ro );
		float3 tmin = min( ttop, tbot );
		float3 tmax = max( ttop, tbot );
		float near = max( max( tmin.x, tmin.y ), tmin.z );
		float far = min( min( tmax.x, tmax.y ), tmax.z );
		return ( near < far ) ? near : -1.0;
	}

    bool ConeInside( float3 ro, float3 po, float3 pd, float ph, float4 spotLightInnerOuterConeCosines )
    {
        float3 ba = pd * ph;                        // Cone axis vector scaled by height
        float3 oa = ro - po;                        // Vector from cone apex to point ro

        // Check if point is between the cone's apex and its base
        float t = dot(oa, pd) / dot(pd, pd);        // Projection of oa onto pd, normalized by the length of pd squared
        bool withinHeight = (t >= 0.0 && t <= ph);  // t must be between 0 and ph (height of the cone)

        if (!withinHeight)
            return false;  // Point is not within the height limits of the cone

        // Calculate the distance from point ro to the cone's axis
        float3 closestPointOnAxis = po + t * pd;    // Closest point to ro on the cone axis
        float radialDistanceSquared = dot(ro - closestPointOnAxis, ro - closestPointOnAxis);  // Squared distance from ro to the cone's axis

        // Check if the radial distance is within the radius at height t
        float radiusAtHeight = t * spotLightInnerOuterConeCosines.w;  // Radius of the cone at height t
        float maxRadiusSquared = radiusAtHeight * radiusAtHeight;  // Squared radius for comparison

        return (radialDistanceSquared <= maxRadiusSquared);
    }

    float ConeIntersect( in float3  ro, in float3  rd, 
                    in float3  po, in float3  pd, float ph, 
                    float4 spotLightInnerOuterConeCosines  )
    {
        spotLightInnerOuterConeCosines *= 1.25;
        po = po - pd * 10.0f;
        ph += 20.0f;
        
        if( ConeInside( ro, po, pd, ph, spotLightInnerOuterConeCosines ) )
            return 0.1;

        float3  ba = pd * -ph;
        float3  pb = po - ba;
        float3  oa = ro - pb;
        float3  ob = ro - po;
        
        float m0 = dot(ba,ba);
        float m1 = dot(oa,ba);
        float m2 = dot(ob,ba); 
        float m3 = dot(rd,ba);

        // Calculate the height of the cone from the base to the apex
        float cosTheta = spotLightInnerOuterConeCosines.w;
        float h = ph * cosTheta;

        //caps
        if( m1<0.0 ) 
        { 
            if( dot( oa*m3-rd*m1, oa*m3-rd*m1) < (h*h*m3*m3) ) 
                return -m1/m3; 
        }
        
        // body
        float m4 = dot(rd,oa);
        float m5 = dot(oa,oa);
        float hy = m0 + h*h;
        
        float k2 = m0*m0    - m3*m3*hy;
        float k1 = m0*m0*m4 - m1*m3*hy + m0*h*(h*m3*1.0        );
        float k0 = m0*m0*m5 - m1*m1*hy + m0*h*(h*m1*2.0 - m0*h);
        
        float kk = k1*k1 - k2*k0;
        
        float t = ( -k1 - sqrt(kk) ) / k2;

        float y = m1 + t*m3;
        if( y>0.0 && y<m0 ) 
        {
            return t;
        }
        
        return -1.0;
    }

    // -------------------------------------------------------------------------------------------------------------------------------------------------------------

    void SortLights( uint2 vTile, float3 vCameraRayWs, float flDepth, const int2 range, const bool bStore )
    {
        // Reset light count
        uint tileIdxFlattenedLight = GetTileIdFlattened( vTile );
        if( bStore )
            g_TiledLightBuffer[ tileIdxFlattenedLight ] = 0; // Reset light count
        
        const float3 vCameraPos = g_vCameraPositionWs;

        // check every light
        for ( int i = range.x; i < range.y; i++ )
        {
            const BinnedLight light = BinnedLightBuffer[i];

            float flHit = light.IsSpotLight() ?
                ConeIntersect( vCameraPos, vCameraRayWs, light.GetPosition(), light.GetDirection(), 1.0f / light.GetInverseRadius(), light.SpotLightInnerOuterConeCosines ) :
                SphereIntersect( vCameraPos, vCameraRayWs , light.GetPosition() , light.GetRadiusSquared() );

            #if D_DEPTH_PREPASS
                if( flHit > flDepth )
                    continue;
            #endif
            
            if( flHit > 0.0f )
            {
                if( bStore )
                    StoreLight( vTile, i );
                LightVisibility[ i ] = 1;
            }
        }

    }

    void SortEnvMaps( uint2 vTile, float3 vCameraRayWs, float flDepth )
    {
        // Reset envmap count
        uint tileIdxFlattenedCube = GetTileIdFlattenedEnvMap( vTile );
        g_TiledLightBuffer[ tileIdxFlattenedCube ] = 0; // Reset envmap count

        for( int nEnvMap=0; nEnvMap < NumEnvironmentMaps; nEnvMap++ )
        {
            const float k = 1.25;
            const float3 vEnvMapMin = ( EnvMapBoxMins( nEnvMap ) * k ) ;
            const float3 vEnvMapMax = ( EnvMapBoxMaxs( nEnvMap ) * k );

            float3 vCubePositionWs = g_vCameraPositionWs;
            float3 vCubeRotationWs = vCameraRayWs;

            // Transform to envmap space
            {
                vCubePositionWs = mul( float4( vCubePositionWs.xyz, 1.0 ), EnvMapWorldToLocal( nEnvMap ) ).xyz;
		        vCubeRotationWs = mul( float4( vCubeRotationWs.xyz, 0.0 ), EnvMapWorldToLocal( nEnvMap ) ).xyz;
            }

            float flHit = BoxInside( vEnvMapMin, vEnvMapMax, vCubePositionWs ) ? 0.01 :
                          BoxIntersect( vCubePositionWs, vCubeRotationWs, vEnvMapMin, vEnvMapMax );
            
            #if ( D_DEPTH_PREPASS )
                if( flHit > flDepth )
                     continue;
            #endif

            if( flHit > 0 )
                StoreEnvMap( vTile, nEnvMap );
        }
    }

	[numthreads( 1, 1, 3)]
	void MainCs( uint nGroupIndex : SV_GroupIndex, uint3 vThreadId : SV_DispatchThreadID )
	{
        const uint2 vTile = vThreadId.xy;
        const uint vJobId = vThreadId.z;

        // Convert from projected space to world space
        float2 vTexCoord = float2( vTile.x, vTile.y ) / float2( GetNumTiles().xy );
        vTexCoord += 1.0f / float2( GetNumTiles().xy ) * 0.5f;

        float2 vProjCoord = vTexCoord * 2.0f - 1.0f;
        vProjCoord.y = -vProjCoord.y;

        float3 vCameraRayWs = mul( g_matProjectionToWorld, float4( vProjCoord, 1.0f, 1.0f ) ).xyz;
        vCameraRayWs = normalize( vCameraRayWs );

        // Get the furthest depth from the depth buffer for this tile
        float flDepth = FetchDepthMax( vTile.xy, vCameraRayWs );

        // ----------------------------------------------------------------------------------------------------------------------
        [branch]
        if( vJobId == CULLING_LIGHT_JOB_CULL_LIGHTS )
        {
            SortLights( vTile, vCameraRayWs, flDepth, int2( 0, NumDynamicLights ), true );
        }
        else if ( vJobId == CULLING_LIGHT_JOB_STATIC_LIGHTS )
        {
            // Visibility of static lights exclusively, don't store it on tiled buffer
            SortLights( vTile, vCameraRayWs, flDepth, int2( NumDynamicLights, NumDynamicLights + NumBakedIndexedLights ), false );
        }
        else //if ( vJobId == CULLING_LIGHT_JOB_CULL_ENVMAPS )
        {
            SortEnvMaps( vTile, vCameraRayWs, flDepth );
        }
        // ----------------------------------------------------------------------------------------------------------------------
        
    }
}

