﻿Shader "Sample/Raymarching Example Scene"
{
	Properties
	{
		_SpecularPower("Spec. Power", Range(0,100)) = 1
		_Gloss("Gloss", Range(0,10)) = 1
		_Separation("Separation", Range(0,2)) = 1
	}
		SubShader
	{
		Tags
		{
			"DisableBatching" = "True"
		}
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "./RayMarching_Structs.cginc"
			#include "./RayMarching_SignedFunctions.cginc"
			#include "./RayMarching_Utils.cginc"
			#include "./RayMarching_Operations.cginc"

			#define STEPS 200
			#define STEP_SIZE 0.005
			#define MIN_DISTANCE 0.001

			float _SpecularPower;
			float _Gloss;
			float _Separation;

			float3 ObjectPos;
			float3 VertexPos;

			float4 materials[10];

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};			

			struct v2f {
				float4 pos : SV_POSITION;	
				float3 wPos : TEXCOORD1;	
				float4 objPos : TEXCOORD2;
				float3 vPos : TEXCOORD3;
			};

			RaymarchingOut Scene(float3 position)
			{
				RaymarchingOut rmOut;

				float separation = (_Separation*sin(_Time.z + 4.15674));

				float speed = 0.3;
				float3 boxPos = T_R(position, float3(sin(_Time.z)*0.25,0, sin(_Time.z*1.12 + 0.2875)*0.25), float3(speed*sin(_Time.y+0.1) * 360, speed*sin(_Time.y+0.37)*360, speed*sin(_Time.y+0.48) * 360));
				RaymarchingOut _box = sdBox( boxPos, float3(0.3, 0.3, 0.3));
				_box.Color = materials[4];

				RaymarchingOut sphere1 = sphereDistance(position + (separation*float3(1, 0, 0)), 0.1);
				sphere1.Color = materials[0];

				RaymarchingOut sphere2 = sphereDistance(position + (separation*float3(-1, 0, 0)), 0.1);
				sphere2.Color = materials[1];

				RaymarchingOut sphere3 = sphereDistance(position + (separation*float3(0, 0, 1)), 0.1);
				sphere3.Color = materials[2];

				RaymarchingOut sphere4 = sphereDistance(position + (separation*float3(0, 0, -1)), 0.10);
				sphere4.Color = materials[3];

				rmOut = _box;
				rmOut = SoftUnion(sphere4, rmOut);
				rmOut = SoftUnion(sphere3, rmOut);
				rmOut = SoftUnion(sphere2, rmOut);
				rmOut = SoftUnion(sphere1, rmOut);

				return rmOut;
			}

			float3 NormalByGradient(float3 p)
			{
				const float eps = 0.01;

				return normalize
				(float3
					(
						Scene(p - float3(eps, 0, 0)).Distance - Scene(p + float3(eps, 0, 0)).Distance,
						Scene(p - float3(0, eps, 0)).Distance - Scene(p + float3(0, eps, 0)).Distance,
						Scene(p - float3(0, 0, eps)).Distance - Scene(p + float3(0, 0, eps)).Distance
						)
				);
			}	

			fixed4 renderSurface(RaymarchingOut rmOut, float3 _viewDirection)
			{
				return simpleLambert(rmOut.Normal, rmOut.Color, _viewDirection, _SpecularPower, _Gloss);
			}

			RaymarchingOut raymarchHit(float3 direction)
			{

				float3 position = VertexPos;
				position = position - ObjectPos;
				for (int i = 0; i < STEPS; i++)
				{
					// Apply unity's object transform
					float3 transformedPos = mul((float3x3)unity_WorldToObject, position);
					RaymarchingOut rmOut = Scene(transformedPos);
					if (rmOut.Distance < MIN_DISTANCE)
					{
						rmOut.Normal = NormalByGradient(transformedPos);
						return rmOut;
					}
					position += rmOut.Distance * direction;
				}

				RaymarchingOut empty;
				empty.Color = fixed4(0,0,0,0);
				return empty;
			}

			void InitializeMaterials() {

				materials[0] = float4(1, 0, 0, 1);
				materials[1] = float4(1, 1, 0, 1);
				materials[2] = float4(1, 0, 1, 1);
				materials[3] = float4(0.5, 1, 0.2, 1);
				materials[4] = float4(0, 0, 1, 1);
			}

			v2f vert(appdata_full v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.wPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.objPos = mul(unity_ObjectToWorld, float4(0, 0, 0, 1));
				o.vPos = v.vertex;
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				InitializeMaterials();
				ObjectPos = i.objPos;
				VertexPos = i.wPos;
				float3 viewDirection = normalize(i.wPos - _WorldSpaceCameraPos);

				RaymarchingOut rmOut = raymarchHit(viewDirection);
				if (rmOut.Color.a == 0) {
					discard;
				}

				fixed4 col = renderSurface(rmOut,viewDirection);

				return col;

			}
			ENDCG
		}
	}
}