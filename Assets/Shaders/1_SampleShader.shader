Shader "Unity Shader/C1/1_SimpleShader" {
	Properties {
		_MainColor ("main color", COLOR) = (1.0, 1.0, 1.0, 1.0)
	}

	SubShader {
		Pass {
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			fixed4 _MainColor;

			struct v2f {
				float4 position : SV_POSITION;
				float3 worldPos : TEXCOORD0; 
			};

			v2f vert(float4 position:POSITION) {
				v2f output;
				output.position = UnityObjectToClipPos(position);
				output.worldPos = mul(unity_ObjectToWorld, position).xyz;
				return output;
			}

			fixed4 frag(v2f input) : SV_Target {
				// return _MainColor;
				return fixed4(input.worldPos, 1.0) * 2;
			}
			
			ENDCG
		}
	}
}
