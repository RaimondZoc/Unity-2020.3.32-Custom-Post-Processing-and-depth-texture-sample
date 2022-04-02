Shader "Hidden/PostProcess/Grayscale"
{
    HLSLINCLUDE
    #include "Packages/com.yetman.render-pipelines.universal.postprocess/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
    
    TEXTURE2D_X(_MainTex);

    float _Blend;

    // struct Attributes 
    // {
    //     float3 positionOS  : POSITION; // Vertex position in object space
    // };

    // struct VertexOutput 
    // {
    //     float4 screenPos   : TEXCOORD4; // Position in clip space
    //     float4 positionCS   : SV_POSITION; // Position in clip space
    // };

    // VertexOutput Vertex(Attributes IN) 
    // {
    //     VertexOutput OUT;

    //     float4 positionCS = TransformObjectToHClip(IN.positionOS.xyz);
    //     OUT.positionCS = positionCS;
    //     OUT.screenPos = ComputeScreenPos(positionCS);
    //     return OUT; 
    // }

    float LinearDepthToNonLinear(float linear01Depth, float4 zBufferParam)
    {
	// Inverse of Linear01Depth
	    return (1.0 - (linear01Depth * zBufferParam.y)) / (linear01Depth * zBufferParam.x);
    }

    float EyeDepthToNonLinear(float eyeDepth, float4 zBufferParam)
    {
	// Inverse of LinearEyeDepth
    	return (1.0 - (eyeDepth * zBufferParam.w)) / (eyeDepth * zBufferParam.z);
    }

    float4 GrayscaleFragmentProgram(PostProcessVaryings IN) :  SV_Target
    {
	    return float4(1,0,0,1);
    }

    ENDHLSL

    SubShader
    {        
    Tags{"RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "IgnoreProjector" = "True"}
    Tags{"LightMode" = "UniversalForward"}

        Cull Off ZWrite Off ZTest Always
        Pass
        {
            HLSLPROGRAM
            #pragma vertex FullScreenTrianglePostProcessVertexProgram
            #pragma fragment GrayscaleFragmentProgram
            ENDHLSL
        }
    }
    Fallback Off
}