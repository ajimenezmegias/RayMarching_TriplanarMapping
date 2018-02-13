Shader "Custom/TriplanarMapping" {
	Properties{
		_Color("Color", Color) = (1,1,1,1)
		_SideTex("Side Texture", 2D) = "white" {}
		_TopTex("Top Texture", 2D) = "white" {}

	_Glossiness("Smoothness", Range(0,1)) = 0.5
		_Metallic("Metallic", Range(0,1)) = 0.0
	}
		SubShader{
		Tags{ "RenderType" = "Opaque" }
		LOD 200

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
#pragma surface surf Standard fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
#pragma target 3.0

	sampler2D _SideTex;
	float4 _SideTex_ST;

	sampler2D _TopTex;
	float4 _TopTex_ST;

	sampler2D _ZTex;
	float4 _ZTex_ST;


	struct Input {
		float3 worldPos;
		float3 worldNormal;
	};

	half _Glossiness;
	half _Metallic;
	fixed4 _Color;

	// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
	// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
	// #pragma instancing_options assumeuniformscaling
	UNITY_INSTANCING_BUFFER_START(Props)
		// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)

		void surf(Input IN, inout SurfaceOutputStandard o) {


		half3 triblend = saturate(pow(IN.worldNormal, 4));
		triblend /= max(dot(triblend, half3(1, 1, 1)), 0.0001);

		triblend = dot(IN.worldNormal, half3(0, 1, 0)) > 0 ? 0 : 1;

		float2 uvX = IN.worldPos.zy * _SideTex_ST.xy + _SideTex_ST.zy;
		float2 uvY = IN.worldPos.xz * _TopTex_ST.xy + _TopTex_ST.zy;
		float2 uvZ = IN.worldPos.xy * _SideTex_ST.xy + _SideTex_ST.zy;

		uvY += 0.33;
		uvZ += 0.67;


		half3 axisSign = IN.worldNormal < 0 ? -1 : 1;

		uvX.x *= axisSign.x;
		uvY.x *= axisSign.y;
		uvZ.x *= -axisSign.z;


		half3 tX = tex2D(_SideTex, uvX);
		half3 tY = tex2D(_TopTex, uvY);
		half3 tZ = tex2D(_SideTex, uvZ);

		o.Albedo = tX*triblend + tY*(1 - triblend);

		o.Metallic = _Metallic;
		o.Smoothness = _Glossiness;
	}
	ENDCG
	}
		FallBack "Diffuse"
}
