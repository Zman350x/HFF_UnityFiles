Shader "Custom/ScreenSpaceCover"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _LockTex ("Texture", 2D) = "black" {}
        _MainScaleX ("Scale X", Float) = 1.0
        _MainScaleY ("Scale Y", Float) = 1.0
        _LockScaleX ("Scale X", Float) = 1.0
        _LockScaleY ("Scale Y", Float) = 1.0
        _OutlineWidth ("Outline Width", Float) = 0.05
        [ToggleOff] _IsUnlocked ("IsUnlocked", Float) = 1.0
    }

    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
            "Queue"="Transparent"
            "ForceNoShadowCasting"="True"
            "IgnoreProjector"="True"
        }
        ZWrite On Lighting Off Blend Off

        Pass
        {
            Tags
            {
                "LightMode"="Always"
            }

            Cull Front

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile FOG_EXP2
            #include "UnityCG.cginc"

            float _OutlineWidth;
            float _IsUnlocked;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                UNITY_FOG_COORDS(1)
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex.xyz + v.normal * _OutlineWidth);
                UNITY_TRANSFER_FOG(o, o.pos);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                if (_IsUnlocked > 0.5)
                    discard;

                fixed4 col = fixed4(0.1, 0.1, 0.1, 1.0);
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }

        Pass
        {
            Tags
            {
                "LightMode"="Always"
            }

            Cull Back

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile FOG_EXP2
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            sampler2D _LockTex;
            float _MainScaleX;
            float _MainScaleY;
            float _LockScaleX;
            float _LockScaleY;
            float _IsUnlocked;

            StructuredBuffer<float4> _BoundsBuffer;

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 screenPos : TEXCOORD0;
                UNITY_FOG_COORDS(1)
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.screenPos = ComputeScreenPos(o.pos);
                UNITY_TRANSFER_FOG(o, o.pos);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float2 screenUV = i.screenPos.xy / i.screenPos.w;

                float2 boundsMin = _BoundsBuffer[0].xy;
                float2 boundsMax = _BoundsBuffer[0].zw;
                float2 objectUV = (screenUV - boundsMin) / (boundsMax - boundsMin);
                float2 mainUV = (objectUV - 0.5) * float2(_MainScaleX, _MainScaleY) + 0.5;
                float2 lockUV = (objectUV - 0.5) * float2(_LockScaleX, _LockScaleY) + 0.5;

                if (mainUV.x < 0.0 || mainUV.x > 1.0 || mainUV.y < 0.0 || mainUV.y > 1.0)
                    discard;

                fixed4 col = tex2D(_MainTex, mainUV);

                if (_IsUnlocked < 0.5)
                {
                    float gray = dot(col.rgb, float3(0.299, 0.587, 0.114)) * 0.3;
                    col = fixed4(gray, gray, gray, 1.0);

                    if (lockUV.x >= 0.0 && lockUV.x <= 1.0 && lockUV.y >= 0.0 && lockUV.y <= 1.0 && tex2D(_LockTex, lockUV).r > 0.5)
                        col = fixed4(1.0, 1.0, 1.0, 1.0);
                }

                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
