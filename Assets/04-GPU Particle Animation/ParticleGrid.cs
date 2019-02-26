using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ParticleGrid : MonoBehaviour
{
    ParticleSystem particleSystem;
    public Vector3 bounds = new Vector3(25.0f, 25.0f, 25.0f);
    public Vector3Int resolution = new Vector3Int(10, 10, 10);

    void OnEnable()
    {
        particleSystem = GetComponent<ParticleSystem>();
        Vector3 scale;
        Vector3 boundsHalf = bounds / 2.0f;
        scale.x = bounds.x / resolution.x;
        scale.y = bounds.y / resolution.y;
        scale.z = bounds.z / resolution.z;
        ParticleSystem.EmitParams ep = new ParticleSystem.EmitParams();
        for(int i = 0; i < resolution.x; i++)
        {
            for (int j = 0; j < resolution.y; j++)
            {
                for (int k = 0; k < resolution.z; k++)
                {
                    Vector3 pos = new Vector3(i * scale.x - boundsHalf.x, j * scale.y - boundsHalf.y,
                        k * scale.z - boundsHalf.z);
                    ep.position = pos;
                    particleSystem.Emit(ep, 1);
                }
            }
        }
    }
}
