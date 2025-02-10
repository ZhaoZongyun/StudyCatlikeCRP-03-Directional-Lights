Shader "Custom RP/Lit"
{
	Properties
	{
		_BaseMap("Texture", 2D) = "white"{}
		_BaseColor("Color", Color) = (0.5, 0.5, 0.5, 1.0)
		_Metallic("Metallic", Range(0, 1)) = 0.5
		_Smoothness("Smoothness", Range(0, 1)) = 0.5
	}

	Subshader
	{
		Pass
		{
			Tags{"LightMode" = "CustomLit"}

			HLSLPROGRAM
			#pragma target 3.5
			#pragma multi_compile_instancing
			#pragma vertex LitPassVertex
			#pragma fragment LitPassFragment
			#include "LitPass.hlsl"

			ENDHLSL
		}	
	}
}
