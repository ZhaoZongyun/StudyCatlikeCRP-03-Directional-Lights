// 定义表面属性
#ifndef CUSTOM_SURFACE_INCLUDED
#define CUSTOM_SURFACE_INCLUDED
							  
struct Surface
{
	float3 viewDirection;
	float3 normal;
	float3 color;
	float alpha;
	float metallic;
	float smoothness;
};

#endif