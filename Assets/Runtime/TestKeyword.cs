using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TestKeyword : MonoBehaviour
{
    public Material material;

    private void Awake()
    {
        material = GetComponent<MeshRenderer>().sharedMaterial;
    }

    [ContextMenu("EnableKeyword")]
    private void test()
    {
        material.EnableKeyword("_CLIPPING");
    }

    [ContextMenu("DisableKeyword")]
    private void test2()
    {
        material.DisableKeyword("_CLIPPING");
    }
}
