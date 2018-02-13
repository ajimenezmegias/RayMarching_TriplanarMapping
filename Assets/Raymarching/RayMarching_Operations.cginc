﻿#ifndef RAYMARCHING_OPERATIONS_INCLUDED
#define RAYMARCHING_OPERATIONS_INCLUDED	

float3 TranslatePoint(float3 p, float3 _t)
{
	return p - _t;
}

float3 RotatePoint(float3 _point, float3 angles)
{
	float c = cos(radians(angles.x));
	float s = sin(radians(angles.x));
	float4x4 rotateXMatrix = float4x4(1, 0, 0, 0,
		0, c, -s, 0,
		0, s, c, 0,
		0, 0, 0, 1);

	c = cos(radians(angles.y));
	s = sin(radians(angles.y));
	float4x4 rotateYMatrix = float4x4(c, 0, s, 0,
		0, 1, 0, 0,
		-s, 0, c, 0,
		0, 0, 0, 1);

	c = cos(radians(angles.z));
	s = sin(radians(angles.z));
	float4x4 rotateZMatrix = float4x4(c, -s, 0, 0,
		s, c, 0, 0,
		0, 0, 1, 0,
		0, 0, 0, 1);

	return mul(mul(mul(_point, rotateYMatrix), rotateXMatrix), rotateZMatrix);
}


float3 T_R(float3 _point, float3 _trans, float3 _rot)
{
	return RotatePoint(TranslatePoint(_point, _trans), _rot);
}

RaymarchingOut Union(RaymarchingOut _rmOut1, RaymarchingOut _rmOut2)
{
	RaymarchingOut returnValue;

	returnValue.Distance = min(_rmOut1.Distance, _rmOut2.Distance);
	returnValue.Color = returnValue.Distance == _rmOut1.Distance ? _rmOut1.Color : _rmOut2.Color;
	return returnValue;
}

RaymarchingOut SoftUnion(RaymarchingOut _rmOut1, RaymarchingOut _rmOut2)
{
	RaymarchingOut returnValue;
	float k = 32;
	float res = exp(-k*_rmOut1.Distance) + exp(-k*_rmOut2.Distance);
	returnValue.Distance = -log(max(0.0001, res)) / k;

	if (abs(_rmOut1.Distance - returnValue.Distance) > abs(_rmOut2.Distance - returnValue.Distance)) {
		returnValue.Color = (_rmOut1.Color*(1.0 - _rmOut1.Distance / (_rmOut1.Distance + _rmOut2.Distance))) + (_rmOut2.Color*(_rmOut1.Distance / (_rmOut1.Distance + _rmOut2.Distance)));
	}
	else {
		returnValue.Color = (_rmOut2.Color*(1.0 - _rmOut2.Distance / (_rmOut1.Distance + _rmOut2.Distance))) + (_rmOut1.Color*(_rmOut2.Distance / (_rmOut1.Distance + _rmOut2.Distance)));
	}

	return returnValue;
}

RaymarchingOut Substraction(RaymarchingOut _rmOut1, RaymarchingOut _rmOut2)
{
	RaymarchingOut returnValue;

	returnValue.Distance = max(-_rmOut1.Distance, _rmOut2.Distance);
	returnValue.Color = returnValue.Distance == -_rmOut1.Distance ? _rmOut1.Color : _rmOut2.Color;
	return returnValue;
}

#endif