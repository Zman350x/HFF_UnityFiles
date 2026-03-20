Shader "Custom/ScreenSpaceCover"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ObjectScreenMinX ("Screen Min X", Float) = 0.0
        _ObjectScreenMinY ("Screen Min Y", Float) = 0.0
        _ObjectScreenMaxX ("Screen Max X", Float) = 1.0
        _ObjectScreenMaxY ("Screen Max Y", Float) = 1.0
        _ScaleX ("Scale X", Float) = 1.0
        _ScaleY ("Scale Y", Float) = 1.0
        _IsUnlocked("IsUnlocked", Float) = 1.0
    }

    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
            "Queue"="Geometry"
            "ForceNoShadowCasting"="True"
            "IgnoreProjector"="True"
        }
        ZWrite On Lighting Off Cull Back Blend Off

        Pass
        {
            Tags
            {
                "LightMode"="Always"
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float _ObjectScreenMinX;
            float _ObjectScreenMinY;
            float _ObjectScreenMaxX;
            float _ObjectScreenMaxY;
            float _ScaleX;
            float _ScaleY;
            float _IsUnlocked;

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 pos      : SV_POSITION;
                float4 screenPos : TEXCOORD0;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos       = UnityObjectToClipPos(v.vertex);
                o.screenPos = ComputeScreenPos(o.pos);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // Perspective divide to get viewport [0,1] coordinates
                float2 screenUV = i.screenPos.xy / i.screenPos.w;

                float2 objectUV = (screenUV - float2(_ObjectScreenMinX, _ObjectScreenMinY)) / float2(_ObjectScreenMaxX - _ObjectScreenMinX, _ObjectScreenMaxY - _ObjectScreenMinY);
                float2 uv = (objectUV - 0.5) * float2(_ScaleX, _ScaleY) + 0.5;

                // Discard fragments outside [0,1] so no wrapping/clamping artifacts
                if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0)
                    discard;

                fixed4 col = tex2D(_MainTex, uv);
                col.a = 1.0;

                if (_IsUnlocked == 0)
                {
                    float gray = dot(col.rgb, float3(0.299, 0.587, 0.114));
                    col = fixed4(gray, gray, gray, 1.0);
                }
                return col;
            }
            ENDCG
        }
    }
}
