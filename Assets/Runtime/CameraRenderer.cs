using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

/// <summary>
/// 相机渲染器
///     大致相当于 URP 的可编程渲染器 
/// </summary>
public partial class CameraRenderer
{
    ScriptableRenderContext context;
    Camera camera;
    string bufferName;
    CommandBuffer buffer;
    CullingResults cullingResults;
    static ShaderTagId unlitShaderTagId = new ShaderTagId("SRPDefaultUnlit");
    static ShaderTagId litShaderTagId = new ShaderTagId("CustomLit");

    Lighting lighting = new Lighting();

    public void Render(ScriptableRenderContext context, Camera camera, bool useDynamicBatching, bool useGPUInstancing)
    {
        this.context = context;
        this.camera = camera;

        //Debug.Log($"camera: {camera.name} type: {camera.cameraType}");

        // 绘制天空盒使用上面专门的方法，但其它命令需要使用 Command Buffer
        buffer = new CommandBuffer();
        buffer.name = bufferName = camera.name;

        PrepareForSceneWindow();
        if (!Cull())
        {
            return;
        }

        Setup();
        lighting.Setup(context, cullingResults);
        DrawVisiableGeometry(useDynamicBatching, useGPUInstancing);
        DrawUnsupportShaders();
        DrawGizmos();
        Submit();
    }

    void Setup()
    {
        // 设置相机的VP矩阵，其包括相机的坐标和朝向（V矩阵）、透视或正交（P矩阵）
        context.SetupCameraProperties(camera);
        CameraClearFlags flags = camera.clearFlags;
        buffer.ClearRenderTarget(
            flags <= CameraClearFlags.Depth,
            flags <= CameraClearFlags.Color,
            flags == CameraClearFlags.Color ? camera.backgroundColor.linear : Color.clear
        );

        buffer.BeginSample(bufferName);
        ExecuteBuffer();
    }

    void DrawVisiableGeometry(bool useDynamicBatching, bool useGPUInstancing)
    {
        //用于确定是正交排序还是基于距离的排序
        SortingSettings sortingSettings = new SortingSettings(camera)
        {
            // 设值 SortingSetting 的 criteria 属性，强制指定渲染顺序
            criteria = SortingCriteria.CommonOpaque
        };
        DrawingSettings drawingSettings = new DrawingSettings(unlitShaderTagId, sortingSettings)
        {
            enableDynamicBatching = useDynamicBatching,
            enableInstancing = useGPUInstancing
        };
        drawingSettings.SetShaderPassName(1, litShaderTagId);

        FilteringSettings filteringSettings = new FilteringSettings(RenderQueueRange.opaque);

        // 先绘制 opaque
        context.DrawRenderers(cullingResults, ref drawingSettings, ref filteringSettings);

        // 再绘制 Skybox，该方法仅使用相机的 clear flag，确定是否绘制天空盒
        context.DrawSkybox(camera);

        // 再绘制 transparent
        sortingSettings.criteria = SortingCriteria.CommonTransparent;
        drawingSettings.sortingSettings = sortingSettings;
        filteringSettings.renderQueueRange = RenderQueueRange.transparent;
        context.DrawRenderers(cullingResults, ref drawingSettings, ref filteringSettings);
    }

    bool Cull()
    {
        if (camera.TryGetCullingParameters(out ScriptableCullingParameters p))
        {
            cullingResults = context.Cull(ref p);
            return true;
        }

        Debug.Log("裁剪失败");
        return false;
    }

    void Submit()
    {
        buffer.EndSample(bufferName);
        ExecuteBuffer();
        context.Submit();
    }

    void ExecuteBuffer()
    {
        context.ExecuteCommandBuffer(buffer);
        buffer.Clear();
    }
}
