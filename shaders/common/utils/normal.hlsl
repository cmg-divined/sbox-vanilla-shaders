#ifndef NORMALS_H
#define NORMALS_H

//-----------------------------------------------------------------------------
// Transform a normal from tangent space to world space
//-----------------------------------------------------------------------------

float3 TransformNormal( float3 vNormalTs, float3 vGeometricNormalWs, float3 vTangentUWs, float3 vTangentVWs )
{
    vTangentUWs = normalize( vTangentUWs.xyz );
    vTangentVWs = normalize( vTangentVWs.xyz );

    // HACK: Tools still generate tangent space the inverted Source1 way where positive y is down. Flipping the normal here to compensate.
    vNormalTs.y = -vNormalTs.y;

    // Transform from tangent space into world space
    return Vec3TsToWsNormalized( vNormalTs.xyz, vGeometricNormalWs, vTangentUWs.xyz, vTangentVWs.xyz );
}

//-----------------------------------------------------------------------------
// Reconstruct normals from world normal, we discard the one from the normal map because
// it's easier as an API to just pass the world normal.
//-----------------------------------------------------------------------------
float3 NormalWorldToTangent( float3 vNormalWs, float3 vGeometricNormalWs, float3 vTangentUWs, float3 vTangentVWs )
{
	#ifdef ENABLE_NORMAL_MAPS
		return Vec3WsToTs( vNormalWs.xyz, vGeometricNormalWs, -vTangentUWs.xyz, -vTangentVWs.xyz ) * float3( 1, -1, 1 );
	#else
		return float3( 0, 0, 1 );
	#endif
}

#endif