Shader "Kurong/GPU Particle Force Field Unlit"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ForceFieldRadius("Force Field Radius", Float) = 4.0
        _ForceFieldPosition("Force Field Position", Vector) = (0.0, 0.0, 0.0, 0.0)
        [HDR] _ColourA("Color A", Color) = (0.0, 0.0, 0.0, 0.0)
        [HDR] _ColourB("Color B", Color) = (1.0, 1.0, 1.0, 1.0)
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
            float4 _ColourA;
            float4 _ColourB;

            float4 GetParticleOffset(float3 particleCenter)
            {
                float distanceToParticle = distance(particleCenter, _ForceFieldPosition);
                float forceFieldRadiusAbs = abs(_ForceFieldRadius);
            
                float3 directionToParticle = normalize(particleCenter - _ForceFieldPosition);
            
                float distanceToForceFieldRadius = forceFieldRadiusAbs - distanceToParticle;
                distanceToForceFieldRadius = max(distanceToForceFieldRadius, 0.0);
            
                distanceToForceFieldRadius *= sign(_ForceFieldRadius);
            
                float4 particleOffset;
            
                particleOffset.xyz = directionToParticle * distanceToForceFieldRadius;
                particleOffset.w = distanceToForceFieldRadius / (_ForceFieldRadius + 0.0001); 
            
                return particleOffset;
            }

            v2f vert (appdata v)
            {
                v2f o;
                float3 particleCenter = float3(v.tc0.zw, v.tc1.x);
 
                float3 vertexOffset = GetParticleOffset(particleCenter);
            
                v.vertex.xyz += vertexOffset;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.tc0.xy = TRANSFORM_TEX(v.tc0, _MainTex);
                o.tc0.zw = v.tc0.zw;
				o.tc1 = v.tc1;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.tc0);
                float3 particleCenter = float3(i.tc0.zw, i.tc1.x);
                float particleOffsetNormalizedLength = GetParticleOffset(particleCenter).w;
            
                col = lerp(col * _ColourA, col * _ColourB, particleOffsetNormalizedLength);

                col*=col.a;
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
