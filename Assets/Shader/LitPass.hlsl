﻿
// Pass 内的属性连接、顶点函数、片段函数
#ifndef CUSTOM_LIT_PASS_INCLUDE
#define CUSTOM_LIT_PASS_INCLUDE

#include "../ShaderLibrary/Common.hlsl"
#include "../ShaderLibrary/Surface.hlsl"
#include "../ShaderLibrary/Light.hlsl"
#include "../ShaderLibrary/BRDF.hlsl"
#include "../ShaderLibrary/Lighting.hlsl"
#include "../ShaderLibrary/UnityInput.hlsl"

TEXTURE2D(_BaseMap);        // 属性定义，等同于 Texture _BaseMap
SAMPLER(sampler_BaseMap);   // 采样器定义

// 属性定义 _BaseColor
UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
    UNITY_DEFINE_INSTANCED_PROP(float4, _BaseMap_ST)
    UNITY_DEFINE_INSTANCED_PROP(float4, _BaseColor)
    UNITY_DEFINE_INSTANCED_PROP(float, _Cutoff)
    UNITY_DEFINE_INSTANCED_PROP(float, _Metallic)
    UNITY_DEFINE_INSTANCED_PROP(float, _Smoothness)
UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)

struct Attributes {
    float3 positionOS:POSITION;
    float3 normalOS:NORMAL;
    float2 baseUV:TEXCOORD;
    UNITY_VERTEX_INPUT_INSTANCE_ID  // 对象索引
};

struct Varyings {
    float3 positionWS:VAR_POSITION;
    float4 positionCS:SV_POSITION;
    float3 normalWS:VAR_NORMAL;
    float2 baseUV:VAR_BASE_UV;
    UNITY_VERTEX_INPUT_INSTANCE_ID  // 对象索引
};

Varyings LitPassVertex(Attributes input) {
    Varyings output;
    UNITY_SETUP_INSTANCE_ID(input);    // 从input中提取索引，并存储在其它实例化宏所依赖的全局静态变量中
    UNITY_TRANSFER_INSTANCE_ID(input, output);

    float3 positionWS = TransformObjectToWorld(input.positionOS);
    output.positionWS = positionWS;
    output.positionCS = TransformWorldToHClip(positionWS);
    output.normalWS = TransformObjectToWorldNormal(input.normalOS);

    float4 baseST = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _BaseMap_ST);
    output.baseUV = input.baseUV * baseST.xy + baseST.zw;

    return output;
}

float4 LitPassFragment(Varyings input):SV_TARGET {
    UNITY_SETUP_INSTANCE_ID(input);

    float4 baseColor = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _BaseColor);
    float4 mapColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.baseUV);
    float4 base = mapColor * baseColor;
    #if defined(_CLIPPING)
        clip(base.a - UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _Cutoff));
    #endif

    Surface surface;
    surface.normal = normalize(input.normalWS);
    surface.viewDirection = normalize(_WorldSpaceCameraPos - input.positionWS);
    surface.color = base.rgb;
    surface.alpha = base.a;
    surface.metallic = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _Metallic);
    surface.smoothness = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _Smoothness);

    #if defined(_PREMULTIPLY_ALPHA)
        BRDF brdf = GetBRDF(surface, true);
    #else
        BRDF brdf = GetBRDF(surface);
    #endif
    float3 color = GetLighting(surface, brdf);

    return float4(color, surface.alpha);
}

#endif
