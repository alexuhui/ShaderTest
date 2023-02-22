Shader "TA100/Tess"
{
    Properties
    {
        _TessellationUniform("Tessellation Uniform", Range(1,64)) = 1
    }
        SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            //定义Hull Shader
            #pragma hull hullProgram 
            //定义Domain Shader
            #pragma domain ds
            #pragma vertex tessvert
            #pragma fragment frag
            #pragma target 5.0

            #include "UnityCG.cginc"
            //曲面细分的头文件，其中包含很多有用的辅助函数
            #include "Tessellation.cginc"

            struct VertexInput
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 uv : TEXCOORD0;
            };

            struct VertexOutput
            {
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            VertexOutput vert(VertexInput v) //应用在domain函数中，用来进行空间转换
            {
                VertexOutput o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = v.normal;
                o.tangent = v.tangent;
                return o;
            }
            //TESS并不是所有平台都支持，定义一个宏来保证在不支持的硬件上面不会报错
            #ifdef UNITY_CAN_COMPILE_TESSELLATION
                struct TessVertex {
                    float4 vertex : INTERNALTESSPOS;
                    float3 normal : NORMAL;
                    float4 tangent : TANGENT;
                    float2 uv : TEXCOORD0;
                };

                struct OutputPatchConstant { //定义path用于Hull Shader
                    float edge[3] : SV_TESSFACTOR;  //不同的图元结构体也会不同，此处为三角形  //mesh中有一个topology属性可以修改图元
                    float inside : SV_INSIDETESSFACTOR;
                };

                TessVertex tessvert(VertexInput v) { //此处没有进行空间转换，只是把信息传到曲面细分着色器中
                    TessVertex o;
                    v.vertex.z = sin( _Time.x * 100 + v.vertex.x * 0.1) *0.5 ;
                    o.vertex = v.vertex;
                    o.normal = v.normal;
                    o.tangent = v.tangent;
                    o.uv = v.uv;
                    return o;
                }

                float _TessellationUniform;
                OutputPatchConstant hsconst(InputPatch<TessVertex,3> patch) {
                    OutputPatchConstant o;
                    o.edge[0] = _TessellationUniform;
                    o.edge[1] = _TessellationUniform;
                    o.edge[2] = _TessellationUniform;
                    o.inside = _TessellationUniform;
                    return o;
                }

                //定义hull shader函数
                [UNITY_domain("tri")]//确定图元，quad、triangle等
                [UNITY_partitioning("fractional_odd")]//edge的切分规则，equal_spacing,fractional_odd,fractional_even
                [UNITY_outputtopology("triangle_cw")]//输出三角形，按顺时针还是逆时针组装，影响最后显示，正面剔除或背面剔除
                [UNITY_patchconstantfunc("hsconst")]//规定这一个patch的曲面细分的属性，三角形的三个点共用这个函数
                [UNITY_outputcontrolpoints(3)]//定义控制点，不同的图元数量不同，此处为三角形
                TessVertex hullProgram(InputPatch<TessVertex,3> patch,uint id : SV_OutputControlPointID) { //hull函数
                    return patch[id];
                }

                //定义Domian Shader函数
                [UNITY_domain("tri")]//同样需要定义图元
                //进行空间转换,将切线空间下的顶点转换至模型空间
                VertexOutput ds(OutputPatchConstant tessFactors, const OutputPatch<TessVertex,3> patch,float3 bary : SV_DOMAINLOCATION) //bary：重心空间下的顶点位置信息
                {
                    VertexInput v;
                    v.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
                    v.tangent = patch[0].tangent * bary.x + patch[1].tangent * bary.y + patch[2].tangent * bary.z;
                    v.normal = patch[0].normal * bary.x + patch[1].normal * bary.y + patch[2].normal * bary.z;
                    v.uv = patch[0].uv * bary.x + patch[1].uv * bary.y + patch[2].uv * bary.z;
                    VertexOutput o = vert(v);
                    return o;

                }
            #endif

            fixed4 frag(VertexOutput i) : SV_Target
            {
                return float4(1.0,1.0,1.0,1.0);
            }
            ENDCG
        }
}
}

