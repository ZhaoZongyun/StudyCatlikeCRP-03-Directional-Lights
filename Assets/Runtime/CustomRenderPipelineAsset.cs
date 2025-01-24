using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

/// <summary>
/// 管线资源
/// </summary>
[CreateAssetMenu(menuName = "Rendering/Custom Render Pipeline")]
public class CustomRenderPipelineAsset : RenderPipelineAsset
{
    [SerializeField]
    bool useDynamicBatching = true, useGPUInstancing = true, UseSRPBatcher = true;

    protected override RenderPipeline CreatePipeline()
    {
        Debug.Log("调用 RenderPipelineAsset.CreatePipeline 方法 222");
        var crp = new CustomRenderPipeline(useDynamicBatching, useGPUInstancing, UseSRPBatcher);
        return crp;
    }
}
