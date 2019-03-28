Shader "Unlit/GPU Particle Force Field Unlit"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ForceFieldRadius("Force Field Radius", Float) = 4.0
        _ForceFieldPosition("Force Field Position", Vector) = (0.0, 0.0, 0.0, 0.0)
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType"="Opaque" }
        LOD 100
        Blend One One // Additive blending.
        ZWrite Off // Depth test off.

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 tc0 : TEXCOORD0;
                float4 tc1 : TEXCOORD1;
            };

            struct v2f
            {
                float4 tc0 : TEXCOORD0;
                float4 tc1 : TEXCOORD1;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _ForceFieldRadius;
            float3 _ForceFieldPosition;

            float3 GetParticleOffset(float3 particleCenter)
            {
                float distanceToParticle = distance(particleCenter, _ForceFieldPosition);
    
                if (distanceToParticle < _ForceFieldRadius)
                {
                    float distanceToForceFieldRadius = _ForceFieldRadius - distanceToParticle;
                    float3 directionToParticle = normalize(particleCenter - _ForceFieldPosition);
                    return directionToParticle * distanceToForceFieldRadius;
                }
                 return 0;
            }

            v2f vert (appdata v)
            {
                v2f o;
                float3 particleCenter = float3(v.tc0.zw, v.tc1.x);
 
                float3 vertexOffset = GetParticleOffset(particleCenter);
            
                v.vertex.xyz += vertexOffset;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.tc0.xy = TRANSFORM_TEX(v.tc0, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.tc0);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
