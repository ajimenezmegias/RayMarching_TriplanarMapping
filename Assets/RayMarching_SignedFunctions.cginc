#include "./RayMarching_Structs.cginc"

#ifndef RAYMARCHING_SIGNED_FUNCTIONS_INCLUDED
#define RAYMARCHING_SIGNED_FUNCTIONS_INCLUDED	

RaymarchingOut sdBox(float3 p, float3  s)
{

	RaymarchingOut rmOut;

	//float3 c = ObjectPos;
	float3 c = float3(0, 0, 0);

	float x = max(p.x - c.x - float3(s.x / 2.0, 0, 0), c.x - p.x - float3(s.x / 2.0, 0, 0));
	float y = max(p.y - c.y - float3(s.y / 2.0, 0, 0), c.y - p.y - float3(s.y / 2.0, 0, 0));
	float z = max(p.z - c.z - float3(s.z / 2.0, 0, 0), c.z - p.z - float3(s.z / 2.0, 0, 0));

	float d = max(x, max(y, z));
	rmOut.Distance = d;
	return rmOut;
}

RaymarchingOut sphereDistance(float3 p, float _radius)
{
	RaymarchingOut rmOut;
	rmOut.Distance = length(p) - _radius;
	return rmOut;
}

#endif