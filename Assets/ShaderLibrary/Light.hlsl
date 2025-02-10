// 场景中的灯光相关属性
#ifndef CUSTOM_LIGHT_INCLUDE
#define CUSTOM_LIGHT_INCLUDE

// 最大平行光数量
#define MAX_DIRECTIONAL_LIGHT_COUNT 4

// 多个方向光属性
CBUFFER_START(_CustomLight)
int _DirectionalLightCount;
float4 _DirectionalLightColors[MAX_DIRECTIONAL_LIGHT_COUNT];
float4 _DirectionalLightDirections[MAX_DIRECTIONAL_LIGHT_COUNT];
CBUFFER_END

int GetDirectionLightCount() {
	return _DirectionalLightCount;
}

// 灯光定义
struct Light
{
	float3 color;
	float3 direction;	// 光照射方向，而不是指向光源
};

// 根据索引获取平行光
Light GetDirectionLight(int index)
{
	Light light;
	light.color = _DirectionalLightColors[index].rgb;
	light.direction = _DirectionalLightDirections[index].xyz;
	return light;
};

#endif