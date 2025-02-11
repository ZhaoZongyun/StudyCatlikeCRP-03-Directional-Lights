using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// 绕过 GameObject，直接绘制网格
/// </summary>
public class DrawInstancingMeshLit : MonoBehaviour
{
    static int baseColorId = Shader.PropertyToID("_BaseColor");
    static int metallicId = Shader.PropertyToID("_Metallic");
    static int smoothnessId = Shader.PropertyToID("_Smoothness");
    MaterialPropertyBlock block;

    [SerializeField]
    Mesh mesh = default;

    [SerializeField]
    Material material = default;

    static int mum = 10;

    Matrix4x4[] matrices = new Matrix4x4[mum];
    Vector4[] baseColors = new Vector4[mum];
    float[] metallics = new float[mum];
    float[] smoothness = new float[mum];

    private void Awake()
    {
        for (int i = 0; i < matrices.Length; i++)
        {
            matrices[i] = Matrix4x4.TRS(Random.insideUnitSphere * 10f, Quaternion.identity, Vector3.one);
            baseColors[i] = new Vector4(Random.value, Random.value, Random.value, 1f);
            metallics[i] = Random.value < 0.25f ? 1f : 0f;
            smoothness[i] = Random.Range(0.05f, 0.95f);
        }
    }

    private void Update()
    {
        if (block == null)
        {
            block = new MaterialPropertyBlock();
            block.SetVectorArray(baseColorId, baseColors);
            block.SetFloatArray(metallicId, metallics);
            block.SetFloatArray(smoothnessId, smoothness);
        }

        Graphics.DrawMeshInstanced(mesh, 0, material, matrices, mum, block);
    }
}
