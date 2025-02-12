﻿#ifndef CUSTOM_BRDF_INCLUDED
#define CUSTOM_BRDF_INCLUDED

struct BRDF {
	float3 diffuse;
	float3 specular;
	float roughness;
};

#define MIN_REFLECTIVITY 0.04

float OneMinusReflectivity(float metallic) {
	float range = 1.0 - MIN_REFLECTIVITY;
	return (1 - metallic) * range;
}

float GetReflectivity(float metallic) {
	float range = 1.0 - MIN_REFLECTIVITY;
	return metallic * range;
}

BRDF GetBRDF(Surface surface, bool applyAlphaToDiffuse = false) {
	BRDF brdf;

	// 漫反射 = 表面颜色 * （1 - 反射率） 金属度越大，反射率越大
	float oneMinusReflectivity = OneMinusReflectivity(surface.metallic);
	brdf.diffuse = surface.color * oneMinusReflectivity;
	if(applyAlphaToDiffuse){
		brdf.diffuse *= surface.alpha;	
	}

	// 高光 = 插值（0.04，表面颜色，金属度）
	brdf.specular = lerp(MIN_REFLECTIVITY, surface.color, surface.metallic);
	float perceptualRoughness = PerceptualSmoothnessToPerceptualRoughness(surface.smoothness);
	brdf.roughness = PerceptualRoughnessToRoughness(perceptualRoughness);

	return brdf;
}

float SpecularStrength(Surface surface, BRDF brdf, Light light) {
	float3 h = SafeNormalize(light.direction + surface.viewDirection);
	float nh2 = Square(saturate(dot(surface.normal, h)));
	float lh2 = Square(saturate(dot(light.direction, h)));
	float r2 = Square(brdf.roughness);
	float d2 = Square(nh2 * (r2 - 1.0) + 1.00001);
	float normalization = brdf.roughness * 4.0f + 2.0;
	return r2 / (d2 * max(0.1, lh2) * normalization);
}

float3 DirectBRDF(Surface surface, BRDF brdf, Light light) {
	return SpecularStrength(surface, brdf, light) * brdf.specular + brdf.diffuse;
}

#endif