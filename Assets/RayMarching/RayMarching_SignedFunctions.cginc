#include "./RayMarching_Structs.cginc"

#ifndef RAYMARCHING_SIGNED_FUNCTIONS_INCLUDED
#define RAYMARCHING_SIGNED_FUNCTIONS_INCLUDED	

RaymarchingOut BoxDF(float3 _point, float3  _size)
{
	RaymarchingOut rmOut;
	float3 c = float3(0, 0, 0);

	float x = max(_point.x - c.x - float3(_size.x / 2.0, 0, 0), c.x - _point.x - float3(_size.x / 2.0, 0, 0));
	float y = max(_point.y - c.y - float3(_size.y / 2.0, 0, 0), c.y - _point.y - float3(_size.y / 2.0, 0, 0));
	float z = max(_point.z - c.z - float3(_size.z / 2.0, 0, 0), c.z - _point.z - float3(_size.z / 2.0, 0, 0));

	float d = max(x, max(y, z));
	rmOut.Distance = d;
	return rmOut;
}

RaymarchingOut SphereDF(float3 _point, float _radius)
{
	RaymarchingOut rmOut;
	rmOut.Distance = length(_point) - _radius;
	return rmOut;
}

#endif