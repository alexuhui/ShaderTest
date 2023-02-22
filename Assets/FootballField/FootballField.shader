Shader "Unlit/FootballField"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _LineColor("Line Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _LineWidth("Line Width", Range(0.01, 0.1)) = 0.02
        _CircleRadius("Circle Radius", Range(0.1, 0.5)) = 0.2
        _RectHalfSize("Rect Half Size(Small W, Small H, Large W, Large H)", vector) = (0.2, 0.2, 0.4, 0.4)
        _SideX("Left/Right Width", Range(0.1, 0.5)) = 0.2
        _SideY("Top/Bottom Width", Range(0.1, 0.5)) = 0.2
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            half4 _LineColor;
            half _LineWidth;
            half _CircleRadius;
            half4 _RectHalfSize;
            half _SideX;
            half _SideY;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                half2 reverseUV = 1 - i.uv;
                half disPow = reverseUV.x * reverseUV.x + reverseUV.y * reverseUV.y;
                half rPow = _CircleRadius * _CircleRadius;
                half innerR = _CircleRadius - _LineWidth;
                half innerRPow = innerR * innerR;
                half halfLineW = _LineWidth * 0.5;
                if((reverseUV.x > _RectHalfSize.z - _LineWidth && reverseUV.x < _RectHalfSize.z && i.uv.y < _RectHalfSize.w + _SideY
                    || i.uv.y < _RectHalfSize.w + _SideY && i.uv.y > _RectHalfSize.w + _SideY - _LineWidth && reverseUV.x < _RectHalfSize.z

                    || reverseUV.x > _RectHalfSize.x - _LineWidth && reverseUV.x < _RectHalfSize.x && i.uv.y < _RectHalfSize.y + _SideY
                    || i.uv.y < _RectHalfSize.y + _SideY && i.uv.y > _RectHalfSize.y + _SideY - _LineWidth && reverseUV.x < _RectHalfSize.x

                    || reverseUV.y < halfLineW 
                    || (disPow < rPow && disPow > innerRPow)

                    || i.uv.x <  _SideX + _LineWidth
                    || i.uv.y < _SideY + _LineWidth
                    ) 
                    && i.uv.x > _SideX && i.uv.y > _SideY)
                {
                    return _LineColor;
                }

                // sample the texture
                half4 col = tex2D(_MainTex, i.uv);

                return col;
            }
            ENDCG
        }
    }
}
