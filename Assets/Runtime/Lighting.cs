using System;
using Unity.Collections;
using UnityEngine;
using UnityEngine.Rendering;

public class Lighting
{
    const string bufferName = "Lighting";
    CommandBuffer buffer = new CommandBuffer
    {
        name = bufferName
    };

    static int dirLightCountId = Shader.PropertyToID("_DirectionalLightCount");
    static int dirLightColorsId = Shader.PropertyToID("_DirectionalLightColors");
    static int dirLightDirectionsId = Shader.PropertyToID("_DirectionalLightDirections");


    const int maxDirLightCount = 4;
    static Vector4[] dirLightColors = new Vector4[maxDirLightCount];
    static Vector4[] dirLightDirections = new Vector4[maxDirLightCount];

    public void Setup(ScriptableRenderContext context, CullingResults result)
    {
        buffer.BeginSample(bufferName);
        SetupLights(result);
        buffer.EndSample(bufferName);
        context.ExecuteCommandBuffer(buffer);
        buffer.Clear();
    }

    private void SetupLights(CullingResults result)
    {
        NativeArray<VisibleLight> lightArray = result.visibleLights;
        int count = 0;
        for (int i = 0; i < lightArray.Length; i++)
        {
            VisibleLight light = lightArray[i];
            if (light.lightType == LightType.Directional)
            {
                SetupDirectionalLight(count++, ref light);
                if (count >= maxDirLightCount)
                {
                    break;
                }
            }
        }

        buffer.SetGlobalInt(dirLightCountId, count);
        buffer.SetGlobalVectorArray(dirLightColorsId, dirLightColors);
        buffer.SetGlobalVectorArray(dirLightDirectionsId, dirLightDirections);
    }

    private void SetupDirectionalLight(int index, ref VisibleLight light)
    {
        dirLightColors[index] = light.finalColor;   // finalColor 已包含了灯光强度
        dirLightDirections[index] = -light.localToWorldMatrix.GetColumn(2);

    }
}
