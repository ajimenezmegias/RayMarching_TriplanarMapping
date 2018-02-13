﻿#ifndef RAYMARCHING_UTILS_INCLUDED
#define RAYMARCHING_UTILS_INCLUDED	
fixed4 simpleLambert(fixed3 normal, fixed4 _color, float3 _viewDirection, float _specularPower, float _gloss)
{
	// Apply object transform
	fixed3 lightDir = normalize(mul((float3x3)unity_WorldToObject, _WorldSpaceLightPos0.xyz));	// Light direction
	fixed3 lightCol = _LightColor0.rgb;		// Light color

	fixed NdotL = max(dot(normal, lightDir), 0);
	fixed4 c;

	// Specular
	// Apply object transform
	_viewDirection = mul((float3x3)unity_WorldToObject, _viewDirection);
	fixed3 h = normalize(lightDir + _viewDirection);
	fixed s = pow(dot(normal, h), _specularPower) * _gloss;

	c.rgb = _color* lightCol * NdotL + s;
	c.a = 1;
	return c;
}


#endif