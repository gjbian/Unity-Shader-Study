Shader "Unity Shader/C4/4_BillBoard"
{
	Properties {
		_MainTex ("Main Tex", 2D) = "white" {}
		_Color ("Main Color", COLOR) = (1, 1, 1, 1)
		[MaterialToggle] _FaceCamera ("Face Camera", FLOAT) = 0
	}
	SubShader 
	{

		Tags {
			"Queue" = "Transparent"
			"RenderType" = "Transparent"
			"IgnoreProjector" = "True"
			"DisableBatching" = "True"
		}

		Blend SrcAlpha OneMinusSrcAlpha
		ZWrite Off
		Cull Off
		
		Pass {

			Tags {
				"LightMode" = "ForwardBase" 
			}

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			struct a2v {
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};


			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0; 
			};

			sampler2D _MainTex;
			float4 _Color;
			float _FaceCamera;

			v2f vert(a2v i) {
				v2f o;

				float3 centerPos = float3(0, 0, 0);
				float3 objectSpaceCameraPos = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1.0));

				float3 forward = objectSpaceCameraPos - centerPos;

				forward.y = forward.y * _FaceCamera;
				forward = normalize(forward);

				// float3 upDir = float3(0, 1, 0);
				float3 upDir = abs(forward.y) < 0.99 ? float3(0, 1, 0) : float3(0, 0, 1);
				float3 rightDir = normalize(cross(upDir, forward));
				upDir = normalize(cross(forward, rightDir));

				float3 centerOffset = i.vertex.xyz - centerPos;
				float3 localPos = centerPos + rightDir * centerOffset.x + upDir * centerOffset.y + forward * centerOffset.z;

				o.pos = UnityObjectToClipPos(float4(localPos, 1.0));
				// o.pos = UnityObjectToClipPos(i.vertex);
				o.uv = i.uv;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target {
				fixed4 c = tex2D(_MainTex, i.uv);
				c.rgb *= _Color.rgb;
				return c;
			}

			ENDCG
		}
	}

}
