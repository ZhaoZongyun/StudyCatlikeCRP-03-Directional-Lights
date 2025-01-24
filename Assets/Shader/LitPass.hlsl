
// Pass 内的属性连接、顶点函数、片段函数
#ifndef CUSTOM_UNLIT_PASS_INCLUDE
#define CUSTOM_UNLIT_PASS_INCLUDE

#include "../ShaderLibrary/Common.hlsl"
#include "../ShaderLibrary/Surface.hlsl"
#include "../ShaderLibrary/Lighting.hlsl"

// 属性定义 _BaseColor
UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
    UNITY_DEFINE_INSTANCED_PROP(float4, _BaseColor)
UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)

struct Attributes {
    float3 positionOS:POSITION;
    float3 normalOS:NORMAL;
    float2 baseUV:TEXCOORD;
    UNITY_VERTEX_INPUT_INSTANCE_ID  // 对象索引
};

struct Varyings {
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
    output.positionCS = TransformWorldToHClip(positionWS);
    output.normalWS = TransformObjectToWorldNormal(input.normalOS);

    return output;
}

float4 LitPassFragment(Varyings input):SV_TARGET {
    UNITY_SETUP_INSTANCE_ID(input);

    float4 baseColor = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _BaseColor);

    Surface surface;
    surface.normal = normalize(input.normalWS);
    surface.color = baseColor;
    surface.alpha = baseColor.a;

    float3 color = GetLighting(surface);

    return float4(color, surface.alpha);
}

#endif
