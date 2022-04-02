Shader "Hidden/Yetman/PostProcess/GradientFog"
{
    HLSLINCLUDE
    #include "Packages/com.yetman.render-pipelines.universal.postprocess/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
    



    // The value from the depth buffer must be remapped from [0,1]
    // to [-1,1] before computing view space position 
    float ConvertZBufferToDeviceDepth(float z){
        #if UNITY_REVERSED_Z
            return 1 -  z;
        #else
            return z - 1;
        #endif 
    }

    float4 GradientFogFragmentProgram(PostProcessVaryings input) : SV_Target
    {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
        float2 uv = UnityStereoTransformScreenSpaceTex(input.texcoord);

        uint2 positionSS = uv * _ScreenSize.xy;

        float depth = LoadSceneDepth(positionSS);

        #if AFTER_TRANSPARENT_ON
        // If the fog is applied after the transparent pass,
        // the depth is sampled from both the opaque and transparent depth textures
        // and the nearest depth is selected.
        // TODO: This can be optimized to read from one texture if the scene transparent depth includes the opaque depth 
        float transparentDepth = LoadSceneTransparentDepth(positionSS);
            #if UNITY_REVERSED_Z
                depth = max(depth, transparentDepth);
            #else
                depth = min(depth, transparentDepth);
            #endif
        #endif

        float deviceDepth = ConvertZBufferToDeviceDepth(depth);
        return 1 - deviceDepth;
    }
    ENDHLSL

    SubShader
    {
        Cull Off ZWrite Off ZTest Always
        Pass
        {
            HLSLPROGRAM

            #pragma vertex FullScreenTrianglePostProcessVertexProgram
            #pragma fragment GradientFogFragmentProgram
            ENDHLSL
        }
    }
    Fallback Off
}