//References: 
//https://medium.com/@bgolus/normal-mapping-for-a-triplanar-shader-10bf39dca05a
//http://www.martinpalko.com/triplanar-mapping/

Shader "Custom/TriplanarMapping"
{
	Properties
	{
		_SideTex("Side Texture", 2D) = "white" {}
		_SideBump("Side Bump", 2D) = "bump"{}
		_SideMetallic("Side Metallic", 2D) = "black"{}

		_TopHeightExtrusion("TopHeight Extrusion", Range(0, 0.02)) = 0.02

		_TopTex("Top Texture", 2D) = "white" {}
		_TopBump("Top Bump", 2D) = "bump"{}
		_TopMetallic("Top Metallic", 2D) = "black"{}
	}
		SubShader
	{
		Tags{ "RenderType" = "Opaque" }
		LOD 200

		CGPROGRAM
		#pragma surface surf Standard	 vertex:vert
		#pragma target 3.0

		#define SHAPRNESS 10

		sampler2D _SideTex;
		float4 _SideTex_ST;
		sampler2D _SideBump;
		sampler2D _SideMetallic;

		float _TopHeightExtrusion;

		sampler2D _TopTex;
		float4 _TopTex_ST;
		sampler2D _TopBump;
		sampler2D _TopMetallic;


		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
		};

		void vert(inout appdata_full v, out Input o)
		{
			UNITY_INITIALIZE_OUTPUT(Input, o);

			float3  worldNormal = UnityObjectToWorldNormal(v.normal);

			half3 triblend = pow(worldNormal, SHAPRNESS);
			triblend /= (triblend.x + triblend.y + triblend.z);

			triblend.y = worldNormal.y > 0 ? triblend.y : 0; //To avoid extruding bottom side
			v.vertex.xyz += v.normal*_TopHeightExtrusion*triblend.y;
			//TODO Fix texture stretching when extruding
		}

		float3 RNMBlend(float3 _normal1, float3 _normal2)
		{
			_normal1 += float3(0, 0, 1);
			_normal2 *= float3(-1, -1, 1);
			return _normal1*dot(_normal1, _normal2) / _normal1.z - _normal2;
		}

		void surf(Input IN, inout SurfaceOutputStandard o)
		{
			// work around bug where IN.worldNormal is always (0,0,0)!			
			// https://github.com/bgolus/Normal-Mapping-for-a-Triplanar-Shader/blob/master/TriplanarSurfaceShader.shader#L118
			IN.worldNormal = WorldNormalVector(IN, float3(0, 0, 1));

			half3 triblend = pow(IN.worldNormal, SHAPRNESS);
			triblend /= (triblend.x + triblend.y + triblend.z);

			float2 uvX = IN.worldPos.zy * _SideTex_ST.xy + _SideTex_ST.zy;
			float2 uvY = IN.worldPos.xz * _TopTex_ST.xy + _TopTex_ST.zy;
			float2 uvZ = IN.worldPos.xy * _SideTex_ST.xy + _SideTex_ST.zy;

			//Albedo
			half3 tX = tex2D(_SideTex, uvX);
			half3 tY = IN.worldNormal.y > 0 ? tex2D(_TopTex, uvY) : tex2D(_SideTex, uvY); // we want the bottom of the object to be draw as a "side" instead of "top"
			half3 tZ = tex2D(_SideTex, uvZ);
			o.Albedo = tX * triblend.x + tY * triblend.y + tZ * triblend.z;

			//Normal
			//RNM blend from @bgolus
			half3 absVertNormal = abs(IN.worldNormal);
			half3 normalX = RNMBlend(half3(IN.worldNormal.zy, absVertNormal.x), UnpackNormal(tex2D(_SideBump, uvX)));
			half3 normalY = UnpackNormal(IN.worldNormal.y > 0 ? tex2D(_TopBump, uvY) : tex2D(_SideBump, uvY)); // we want the bottom of the object to be draw as a "side" instead of "top"
			normalY = RNMBlend(half3(IN.worldNormal.xz, absVertNormal.y), normalY);
			half3 normalZ = RNMBlend(half3(IN.worldNormal.xy, absVertNormal.z), UnpackNormal(tex2D(_SideBump, uvZ)));
			o.Normal = normalX * triblend.x + normalY * triblend.y + normalZ * triblend.z;

			//Metallic
			half4 metallicX = tex2D(_SideMetallic, uvX);
			half4 metallicY = IN.worldNormal.y > 0 ? tex2D(_TopMetallic, uvY) : tex2D(_SideMetallic, uvY); // we want the bottom of the object to be draw as a "side" instead of "top"
			half4 metallicZ = tex2D(_SideMetallic, uvZ);
			half4 metallic = metallicX * triblend.x + metallicY * triblend.y + metallicZ * triblend.z;
			o.Metallic = metallic.r;
			o.Smoothness = metallic.a;
		}
		ENDCG
	}
		FallBack "Diffuse"
}
