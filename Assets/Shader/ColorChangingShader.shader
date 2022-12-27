Shader "Custom/ColorChangingShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0

        _Dissolve("Dissolve", 2D) = "white" {}
        _Ramp("Dissolve", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows
        #pragma enable_d3d11_debug_symbols 
        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _Dissolve;
        sampler2D _Ramp;

        struct Input
        {
            float2 uv_MainTex;
            float3 worldPos;
            float2 uv2;
        };

        half _Glossiness;
        half _Metallic;
        float4 _ChangeParams;
        float4 _ChangeTime;
        fixed4 _ChangeColor;
        fixed4 _ChangePrevColor;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            float3 clickCenterWS = _ChangeParams.xyz;
            float3 worldPos = IN.worldPos.xyz;
            float3 sub = worldPos - clickCenterWS;
            float dis = sqrt(dot(sub, sub));

            float duration = (_Time.y - _ChangeTime.y) / _ChangeTime.x;

            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);

            half4 dissolveTex = tex2D(_Dissolve, IN.uv_MainTex * 0.1);

            float clipValue = duration - dis;
            half dissolveValue = saturate((dissolveTex.r - clipValue) / (clipValue + 0.01 - clipValue));
            half4 rampTex = tex2D(_Ramp, dissolveValue);

            fixed4 _Color = lerp(_ChangePrevColor * c, _ChangeColor * c, (dis < duration) * _ChangeParams.w);
            _Color += rampTex;

            o.Albedo = _Color.xyz;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
