#ifndef RAYTRACING_SDF_H
#define RAYTRACING_SDF_H

#include "raytracing/intersection.hlsl" // For IntersectSphere

//
// High quality reflections
//

struct ShapeSettings_t
{
    int nInstancesCount;
    int nShapeCount; //Useful only on C++ side really
    int nUnused1;
    int nUnused2;
};

struct ShapeInstance_t
{
    int nStartEllipsoid;
    int nEndEllipsoid;
    int nEndBox;
    int nEndCylinder;
};

struct ShapeBounds_t
{
    float3 vBoundingCenter;
    float fBoundingRadius;
};

struct ShapeProperties_t
{
    float4x3 matWorldToProxy;
    float3 vProxyScale;
    float fUnused;
};

cbuffer ShapeConstantBuffer_t
{
	#define SHAPE_MAX_INSTANCES 35
	#define SHAPE_MAX_SHAPES 110

	// Per-instance
	ShapeSettings_t shapeSettings;
	ShapeInstance_t shapeInstance[SHAPE_MAX_INSTANCES];
    ShapeBounds_t shapeBounds[SHAPE_MAX_INSTANCES];

	// Per-proxy
	ShapeProperties_t shapeProperties[SHAPE_MAX_SHAPES];
};

//------------------------------------------------------------

// Based off https://iquilezles.org/articles/distfunctions/
float sdBox( float3 p, float3 b )
{
    float3 q = abs(p) - b;
    return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float sdSphere( float3 p, float s )
{
    return length(p)-s;
}

float sdCapsule( float3 p, float3 a, float3 b, float r )
{
  float3 pa = p - a, ba = b - a;
  float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
  return length( pa - ba*h ) - r;
}

float sdCylinder( float3 p, float h, float r )
{
  float2 d = abs(float2(length(p.xz),p.y)) - float2(h,r);
  return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}

//------------------------------------------------------------

float map( float3 vPosWs, int instance = 0 )
{
    uint nEllipsesStart = shapeInstance[instance].nStartEllipsoid;
    uint nBoxesStart = shapeInstance[instance].nEndEllipsoid;
    uint nCylinderStart = shapeInstance[instance].nEndBox;
    uint nCylinderEnd = shapeInstance[instance].nEndCylinder;

    float res = 9999999.0f;
    uint i;

    //Ellipses first
    for ( i = nEllipsesStart; i < nBoxesStart; i++ )
    {
        const float fRadius = shapeProperties[i].vProxyScale.y;
        const float3 fLength = float3( shapeProperties[i].vProxyScale.x,0,0);
        float3 p = mul( float4( vPosWs.xyz, 1.0 ), shapeProperties[i].matWorldToProxy ).xyz;
				
        res = min( res, sdCapsule( p, -fLength, fLength, fRadius ) );
    }
    // Then boxes
    for ( i = nBoxesStart; i < nCylinderStart; i++ )
    {
        float3 p = mul( float4( vPosWs.xyz, 1.0 ), shapeProperties[i].matWorldToProxy ).xyz;
        res = min( res, sdBox( p, shapeProperties[i].vProxyScale.xyz ) );
    }
    // Then Cylinder
    for ( i = nCylinderStart; i < nCylinderEnd; i++ )
    {
        float3 p = mul( float4( vPosWs.xyz, 1.0 ), shapeProperties[i].matWorldToProxy ).zxy;
        res = min( res, sdCylinder( p,  shapeProperties[i].vProxyScale.y,  shapeProperties[i].vProxyScale.x ) );
    }

    return res;
}

// Based off http://iquilezles.org/www/articles/rmshadows/rmshadows.htm
float softshadow( in float3 ro, in float3 rd, float mint, float maxt, float roughness, int instance = 0 )
{
    float res = 1.0;
    float ph = 1e20;

    roughness = pow(roughness, 2.0f);
    float r = 1 / ( max( roughness, 0.001f ) );

    float k = r;

    [loop]
    for( float t=mint; t<maxt; )
    {
        float h = map( ro + rd*t, instance );
        if( h<0.01f )
            return 0.0;
        float y = h*h/(2.0*ph);
        float d = sqrt(h*h-y*y);
        res = min( res, k*d/max(0.0,t-y) );
        h = max( h, 1.5f ); // Minimum travel distance for optimization
        ph = h;
        t += h;
    }
    return res;
}

//------------------------------------------------------------

float TraceSDF( float3 vNormalWs, float flRoughness, float3 vViewRayWs, float3 vPosWs )
{
    // Fetch header here
    float3 vReflectWs = reflect( vViewRayWs, vNormalWs );

    float fMaxDistance = max( lerp( 512.0f, 0.01f, flRoughness ), 0.1f);

    float fReflection = 1.0f;

    [loop]
    for( int iInstance = 0; iInstance < shapeSettings.nInstancesCount; iInstance++ )
    {
        //Do a raytrace check to check for AABB intersection, only do reflection if within bounds
        bool bHit = IntersectSphere( vPosWs, 
                                    vReflectWs, 
                                    shapeBounds[iInstance].vBoundingCenter.xyz, 
                                    shapeBounds[iInstance].fBoundingRadius  ).g > 0.0f;
        
        if( bHit )
            fReflection = min( 
                softshadow( vPosWs , vReflectWs, 1.0f, fMaxDistance, flRoughness, iInstance ), 
                fReflection 
                );

        // Skip the rest of the loop if we are dark enough
        if ( fReflection < 0.01f )
            break;

        // Debug visualization for AABB
        //if( bHit )
        //    fReflection -= 0.3;
    }
    

    return fReflection;
}

#endif //RAYTRACING_SDF_H
