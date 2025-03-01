﻿Shader "Custom RP/Lit"
{
	Properties
	{
		_BaseMap("Texture", 2D) = "white"{}
		_BaseColor("Color", Color) = (0.5, 0.5, 0.5, 1.0)
		_Metallic("Metallic", Range(0, 1)) = 0.5
		_Smoothness("Smoothness", Range(0, 1)) = 0.5
		[Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend("Src Blend", Float) = 1
		[Enum(UnityEngine.Rendering.BlendMode)] _DstBlend("Dst Blend", Float) = 2
		[Enum(Off, 0, On, 1)] _ZWrite("ZWrite", Float) = 1
		[Toggle(_PREMULTIPLY_ALPHA)] _PremultiplyAlpha("Premultiply Alpha", Float) = 0

		[Toggle(_CLIPPING)] _Clipping("Clipping", Float) = 0.2
		[KeywordEnum(Red, Green, Blue)] _ColorMode("Color Mode", Float) = 0
		_Cutoff("Cutoff", Range(0, 1.0)) = 0.5
	}

	Subshader
	{
		Pass
		{
			Tags{"LightMode" = "CustomLit"}

			Blend [_SrcBlend] [_DstBlend]
			ZWrite [_ZWrite]

			HLSLPROGRAM
			#pragma target 3.5
			#pragma shader_feature _CLIPPING
			#pragma shader_feature _PREMULTIPLY_ALPHA
			#pragma multi_compile_instancing
			#pragma vertex LitPassVertex
			#pragma fragment LitPassFragment
			#include "LitPass.hlsl"

			ENDHLSL
		}	
	}
}
