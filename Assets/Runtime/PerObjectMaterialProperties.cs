using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

/// <summary>
/// 逐材质着色器属性
/// </summary>
[DisallowMultipleComponent]
public class PerObjectMaterialProperties : MonoBehaviour
{
    static int baseColorId = Shader.PropertyToID("_BaseColor");
    static int metallicId = Shader.PropertyToID("_Metallic");
    static int smoothnessId = Shader.PropertyToID("_Smoothness");
    static int srcBlendId = Shader.PropertyToID("_SrcBlend");
    static int dstBlendId = Shader.PropertyToID("_DstBlend");
    static int zWriteId = Shader.PropertyToID("_ZWrite");
    static int CutoffId = Shader.PropertyToID("_Cutoff");
    static int baseMapOfffsetId = Shader.PropertyToID("_BaseMap_ST");

    static MaterialPropertyBlock block;

    [SerializeField, Header("PerObject")]
    Color baseColor = new Color(0.5f, 0.5f, 0.5f, 1f);

    [SerializeField, Range(0, 1f), Header("PerObject")]
    float metallic = 0.5f;

    [SerializeField, Range(0, 1f), Header("PerObject")]
    float smoothness = 0.5f;

    [SerializeField, Header("PerObject")]
    UnityEngine.Rendering.BlendMode srcBlend = UnityEngine.Rendering.BlendMode.One;

    [SerializeField, Header("PerObject")]
    UnityEngine.Rendering.BlendMode dstBlend = UnityEngine.Rendering.BlendMode.Zero;

    [SerializeField, Header("PerObject")]
    float zWrite = 1f;

    [SerializeField]
    bool clipping = false;

    [SerializeField, Range(0, 1f), Header("PerObject")]
    float cutoff = 0.5f;

    [SerializeField, Header("PerObject")]
    Vector4 offset = Vector2.zero;

    public Material material;

    private void Awake()
    {
        var renderer = GetComponent<MeshRenderer>();
        material = renderer.sharedMaterial;
        OnValidate();

        if (clipping)
            material.EnableKeyword("_CLIPPING");
        else
            material.DisableKeyword("_CLIPPING");
    }

    private void Update()
    {
        OnValidate();
    }

    private void OnValidate()
    {
        if (block == null)
            block = new MaterialPropertyBlock();

        block.SetColor(baseColorId, baseColor);
        block.SetFloat(metallicId, metallic);
        block.SetFloat(smoothnessId, smoothness);
        block.SetInt(srcBlendId, (int)srcBlend);
        block.SetInt(dstBlendId, (int)dstBlend);
        block.SetFloat(zWriteId, zWrite);

        block.SetFloat(CutoffId, cutoff);
        block.SetVector(baseMapOfffsetId, offset);
        GetComponent<Renderer>().SetPropertyBlock(block);
    }
}