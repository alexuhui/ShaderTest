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
            //����Hull Shader
            #pragma hull hullProgram 
            //����Domain Shader
            #pragma domain ds
            #pragma vertex tessvert
            #pragma fragment frag
            #pragma target 5.0

            #include "UnityCG.cginc"
            //����ϸ�ֵ�ͷ�ļ������а����ܶ����õĸ�������
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

            VertexOutput vert(VertexInput v) //Ӧ����domain�����У��������пռ�ת��
            {
                VertexOutput o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = v.normal;
                o.tangent = v.tangent;
                return o;
            }
            //TESS����������ƽ̨��֧�֣�����һ��������֤�ڲ�֧�ֵ�Ӳ�����治�ᱨ��
            #ifdef UNITY_CAN_COMPILE_TESSELLATION
                struct TessVertex {
                    float4 vertex : INTERNALTESSPOS;
                    float3 normal : NORMAL;
                    float4 tangent : TANGENT;
                    float2 uv : TEXCOORD0;
                };

                struct OutputPatchConstant { //����path����Hull Shader
                    float edge[3] : SV_TESSFACTOR;  //��ͬ��ͼԪ�ṹ��Ҳ�᲻ͬ���˴�Ϊ������  //mesh����һ��topology���Կ����޸�ͼԪ
                    float inside : SV_INSIDETESSFACTOR;
                };

                TessVertex tessvert(VertexInput v) { //�˴�û�н��пռ�ת����ֻ�ǰ���Ϣ��������ϸ����ɫ����
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

                //����hull shader����
                [UNITY_domain("tri")]//ȷ��ͼԪ��quad��triangle��
                [UNITY_partitioning("fractional_odd")]//edge���зֹ���equal_spacing,fractional_odd,fractional_even
                [UNITY_outputtopology("triangle_cw")]//��������Σ���˳ʱ�뻹����ʱ����װ��Ӱ�������ʾ�������޳������޳�
                [UNITY_patchconstantfunc("hsconst")]//�涨��һ��patch������ϸ�ֵ����ԣ������ε������㹲���������
                [UNITY_outputcontrolpoints(3)]//������Ƶ㣬��ͬ��ͼԪ������ͬ���˴�Ϊ������
                TessVertex hullProgram(InputPatch<TessVertex,3> patch,uint id : SV_OutputControlPointID) { //hull����
                    return patch[id];
                }

                //����Domian Shader����
                [UNITY_domain("tri")]//ͬ����Ҫ����ͼԪ
                //���пռ�ת��,�����߿ռ��µĶ���ת����ģ�Ϳռ�
                VertexOutput ds(OutputPatchConstant tessFactors, const OutputPatch<TessVertex,3> patch,float3 bary : SV_DOMAINLOCATION) //bary�����Ŀռ��µĶ���λ����Ϣ
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

