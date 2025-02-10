// 灯光计算
#ifndef CUSTOM_LIGHTING_INCLUDED
#define CUSTOM_LIGHTING_INCLUDED

float3 IncomingLight(Surface surface, Light light)
{
	// saturate 将值限制在 0-1
	return saturate(dot(light.direction, surface.normal) * light.color);
};

float3 GetLighting(Surface surface, BRDF brdf, Light light)
{
	return IncomingLight(surface, light) * DirectBRDF(surface, brdf, light);
};

// 计算光照结果
float3 GetLighting(Surface surface, BRDF brdf)
{
	float3 color = 0.0;
	for(int i = 0; i < GetDirectionLightCount(); i++)
	{
		color += GetLighting(surface, brdf, GetDirectionLight(i));
	}
	return color;
};



#endif