Shader "Unlit/RayMarchingTest"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100		

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			// ray marching
			const int max_iterations = 512;
			const float stop_threshold = 0.001;
			const float grad_step = 0.02;
			const float clip_far = 1000.0;

			// math
			const float PI = 3.14159265359;
			const float DEG_TO_RAD = 3.14159265359 / 180.0;

			// iq's distance function
			float sdSphere( fixed3 pos, float r ) {
				return length( pos ) - r;
			}

			float sdBox( fixed3 p, fixed3 b ) {
			  fixed3 d = abs(p) - b;
			  return min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0));
			}

			// get distance in the world
			float dist_field( fixed3 pos ) {
				float v = sdBox( pos, fixed3(0.5, 0.5, 0.5) );
    
				v = max( v, -sdSphere( pos, 0.6 ) );

				return v;
			}

			// get gradient in the world
			fixed3 gradient( fixed3 pos ) {
				const fixed3 dx = fixed3( grad_step, 0.0, 0.0 );
				const fixed3 dy = fixed3( 0.0, grad_step, 0.0 );
				const fixed3 dz = fixed3( 0.0, 0.0, grad_step );
				return normalize (
					fixed3(
						dist_field( pos + dx ) - dist_field( pos - dx ),
						dist_field( pos + dy ) - dist_field( pos - dy ),
						dist_field( pos + dz ) - dist_field( pos - dz )			
					)
				);
			}

			// phong shading
			fixed3 shading( fixed3 v, fixed3 n, fixed3 eye ) {
				// ...add lights here...
	
				float shininess = 16.0;
	
				fixed3 final = fixed3( 0.0,0,0 );
	
				fixed3 ev = normalize( v - eye );
				fixed3 ref_ev = reflect( ev, n );
	
				// light 0
				{
					fixed3 light_pos   = fixed3( 20.0, 20.0, 20.0 );
					fixed3 light_color = fixed3( 1.0, 0.7, 0.7 );
	
					fixed3 vl = normalize( light_pos - v );
	
					float diffuse  = max( 0.0, dot( vl, n ) );
					float specular = max( 0.0, dot( vl, ref_ev ) );
					specular = pow( specular, shininess );
		
					final += light_color * ( diffuse + specular ); 
				}
	
				// light 1
				{
					fixed3 light_pos   = fixed3( -20.0, -20.0, -20.0 );
					fixed3 light_color = fixed3( 0.3, 0.7, 1.0 );
	
					fixed3 vl = normalize( light_pos - v );
	
					float diffuse  = max( 0.0, dot( vl, n ) );
					float specular = max( 0.0, dot( vl, ref_ev ) );
					specular = pow( specular, shininess );
		
					final += light_color * ( diffuse + specular ); 
				}

				return final;
			}

			// ray marching
			float ray_marching( fixed3 origin, fixed3 dir, float start, float end ) {
				float depth = start;
				for ( int i = 0; i < max_iterations; i++ ) {
					fixed3 p = origin + dir * depth;
					float dist = dist_field( p ) / length( gradient( p ) );
					if ( abs( dist ) < stop_threshold ) {
						return depth;
					}
					depth += dist * 0.9;
					if ( depth >= end) {
						return end;
					}
				}
				return end;
			}

			// get ray direction
			fixed3 ray_dir( float fov, fixed2 size, fixed2 pos ) {
				fixed2 xy = pos - size * 0.5;

				float cot_half_fov = tan( ( 90.0 - fov * 0.5 ) * DEG_TO_RAD );	
				float z = size.y * 0.5 * cot_half_fov;
	
				return normalize( fixed3( xy, -z ) );
			}

			// camera rotation : pitch, yaw
			fixed3x3 rotationXY( fixed2 angle ) {
				fixed2 c = cos( angle );
				fixed2 s = sin( angle );
	
				return fixed3x3(
					c.y      ,  0.0, -s.y,
					s.y * s.x,  c.x,  c.y * s.x,
					s.y * c.x, -s.x,  c.y * c.x
				);
			}



			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed2 iResolution = fixed2(1,1)*100;
				fixed2 fragCoord = i.uv*100 ;

				fixed4 fragColor;
				// default ray dir
				fixed3 dir = ray_dir( 45.0, iResolution, fragCoord);
	
				// default ray origin
				fixed3 eye = fixed3( 0.0, 0.0, 2.5 );
	
				// rotate camera
				fixed3x3 rot = rotationXY( ( fixed2(50,50)- iResolution.xy * 0.5 ).yx * fixed2( 0.01, -0.01 ) );
				dir = mul(rot, dir);
				eye = mul(rot, eye);
	
				// ray marching
				float depth = ray_marching( eye, dir, 0.0, clip_far );
				if ( depth >= clip_far ) {
					fragColor = fixed4( 0.3, 0.4, 0.5, 1.0 );
					return fragColor;
				}
	
				// shading
				fixed3 pos = eye + dir * depth;
				fixed3 n = gradient( pos );
				fragColor = fixed4( shading( pos, n, eye ), 1.0 );
				return fragColor;

				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
