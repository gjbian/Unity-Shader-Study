Shader "Unity Shader/C2/2_WallDiffuse" {
	Properties {
		_MainColor ("color tint", COLOR) = (1.0, 1.0, 1.0, 1.0)  // 物体的主颜色
		// 2D就是一个二维纹理变量。
		// "white"是纹理的默认值, 表示一张纯白色图片
		_MainTex ("main tex", 2D) = "white" {}
	}
	SubShader {
		Pass {
			CGPROGRAM // CG代码块

			#pragma vertex vert // 声明vert函数为顶点着色器
			#pragma fragment frag // frag为片段着色器

			#include "UnityCG.cginc"
			 // 光照相关头文件，可以帮我们计算入射光线
			#include "Lighting.cginc"

			fixed4 _MainColor;
			// sampler2D是一个二维纹理采样器，采样概念我一会讲讲。
			// sampler2D就是对应上面的2D属性。
			sampler2D _MainTex;
			float4 _MainTex_ST;

			struct a2v {  // 顶点着色器输入结构体
				float4 vertex : POSITION; // 顶点物体空间位置
				float2 texcoord : TEXCOORD0;
				float3 normal : NORMAL;  // 顶点法线
			};

			struct v2f {  // 片段着色器输入结构体
				float4 pos : SV_POSITION; // 顶点裁剪空间位置
				float2 uv : TEXCOORD0;
				float3 worldPos : TEXCOORD1; // 世界空间下的片段位置
				float3 worldNormal : TEXCOORD2; // 世界空间下的法线向量
			};

			v2f vert(a2v v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex); // MVP变换
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);  // 应用上缩放平移
				// o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.worldPos = mul(UNITY_MATRIX_M, v.vertex.xyz);  // 通过模型变换，求出世界空间的顶点位置
				o.worldNormal = UnityObjectToWorldNormal(v.normal); // 求出世界空间的法线位置
				return o;
			}

			fixed4 frag(v2f i) : SV_Target {
				// 把插值结果单位化，注意一定要变成单位向量，否则后面计算会不完整。
				float3 worldNormal = normalize(i.worldNormal);
				// 通过UnityWorldSpaceLightDir求出光照方向
				float3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed4 albedo = tex2D(_MainTex, i.uv);

				// 环境光
				// 内置变量_LightColor0为我们提供了环境光的颜色
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT * albedo.rgb;

				// 漫反射光
				// saturate可以把输入参数截断到[0,1]区间，相当于 min(0, max(1, x))
				float lambert = saturate(dot(worldNormal, worldLightDir));
				// 内置变量_LightColor0为我们提供了光线的颜色
				fixed3 diffuse = _LightColor0.rgb * albedo.rgb * lambert;

				return fixed4(ambient + diffuse, albedo.a); // 输出物体主颜色
			}

			ENDCG
		}
	}

	Fallback "Diffuse"  // 备胎
}