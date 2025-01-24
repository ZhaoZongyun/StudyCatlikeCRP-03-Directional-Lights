// 灯光计算
#ifndef CUSTOM_LIGHTING_INCLUDED
#define CUSTOM_LIGHTING_INCLUDED

struct DirectionLight
{
	float3 color;
	float3 direction;
};

DirectionLight GetDirectionLight()
{
	DirectionLight light;
	light.color = _DirectionalLightColor;
	light.direction = _DirectionalLightDirection;
	return light;
};

float3 IncomingLight(Surface surface, DirectionLight light)
{
	return saturate(dot(light.direction, surface.normal) * light.color);
};

float3 GetLighting(Surface surface, DirectionLight light)
{
	return IncomingLight(surface, light) * surface.color;
};

float3 GetLighting(Surface surface)
{
	return GetLighting(surface, GetDirectionLight());
};

#endif