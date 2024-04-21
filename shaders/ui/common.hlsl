#include "system.fxc"
#include "vr_common.fxc" 

DynamicCombo( D_WORLDPANEL, 0..1, Sys( PC ) );

//-------------------------------------------------------------------------------------------------------------------------------------------------------------
struct VS_INPUT
{
	float4 vPositionSs					: POSITION < Semantic( PosXyz ); >;
	float4 vColor						: COLOR0 < Semantic( Color ); >;
	float2 vTexCoord					: TEXCOORD0 < Semantic( LowPrecisionUv ); >;
	uint nInstanceTransformID			: TEXCOORD13	< Semantic( InstanceTransformUv ); >;
};

//-------------------------------------------------------------------------------------------------------------------------------------------------------------
struct PS_INPUT
{
	float4 vColor				: COLOR0;
	float4 vTexCoord			: TEXCOORD0;
	float4 vPositionSs			: TEXCOORD1;
	float4 vPositionPanelSpace	: TEXCOORD2;
	float4 vPositionPs			: SV_Position;
};
  