using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RewindParticleSystem : MonoBehaviour
{
    ParticleSystem[] particleSystems;

    float[] simulationTimes;

    public float startTime = 2.0f;
    public float simulationSpeedScale = 1.0f;

    void Initialize()
    {
        particleSystems = GetComponentsInChildren<ParticleSystem>(false);
        simulationTimes = new float[particleSystems.Length];
    }

    void OnEnable()
    {
        if (particleSystems == null)
        {
            Initialize();
        }

        for (int i = 0; i < simulationTimes.Length; i++){
            simulationTimes[i] = 0.0f;
        }
        particleSystems[0].Simulate(startTime, true, false, true);
    }
    void Update()
    {
        particleSystems[0].Stop(true, ParticleSystemStopBehavior.StopEmittingAndClear);
        for (int i = particleSystems.Length - 1; i >= 0; i--)
        {
            bool useAutoRandomSeed = particleSystems[i].useAutoRandomSeed;
            particleSystems[i].useAutoRandomSeed = false;

            particleSystems[i].Play(false);

            float deltaTime = particleSystems[i].main.useUnscaledTime ? Time.unscaledDeltaTime : Time.deltaTime;
            simulationTimes[i] -= (deltaTime * particleSystems[i].main.simulationSpeed) * simulationSpeedScale;

            float currentSimulationTime = startTime + simulationTimes[i];
            particleSystems[i].Simulate(currentSimulationTime, false, false, true);

            particleSystems[i].useAutoRandomSeed = useAutoRandomSeed;

            if (currentSimulationTime < 1e-6)
            {
                particleSystems[i].Play(false);
                particleSystems[i].Stop(false, ParticleSystemStopBehavior.StopEmittingAndClear);
            }
        }
    }

}
