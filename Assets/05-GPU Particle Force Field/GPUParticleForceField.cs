using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class GPUParticleForceField : MonoBehaviour
{
    public Material material;

    void LateUpdate()
    {
        material.SetFloat("_ForceFieldRadius", transform.lossyScale.x / 2.0f);
        material.SetVector("_ForceFieldPosition", transform.position);
    }

    void OnDrawGizmos()
    {
        Gizmos.DrawWireSphere(transform.position, transform.lossyScale.x / 2.0f);
    }
}