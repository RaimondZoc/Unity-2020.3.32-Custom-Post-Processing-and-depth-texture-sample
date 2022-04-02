#ifndef CAMERA_DEPTH_TEXTURE
#define CAMERA_DEPTH_TEXTURE

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
 
// The vertex function input
struct Attributes {
    float3 positionOS  : POSITION; // Vertex position in object space
    //float3 positionWS  : TEXCOORD0; // Vertex position in object space
    //float4 positionCS  : POSITION; // Vertex position in object space
    float3 normalOS     : NORMAL; // Vertex normal vector in object space
    float4 tangentOS    : TANGENT; // Vertex tangent vector in object space (plus bitangent sign)
    float2 uv           : TEXCOORD1; // Vertex uv
};

// Vertex function output and geometry function input
struct VertexOutput {
    //float3 positionOS   : POSITION; // Position in clip space
    //float3 positionWS   : TEXCOORD0; // Position in clip space
    //float3 positionVS   : TEXCOORD3; // Position in clip space
    float4 screenPos   : TEXCOORD4; // Position in clip space
    float4 positionCS   : SV_POSITION; // Position in clip space
    //float3 normalWS     : TEXCOORD1; // Normal vector in world space
    //float2 uv           : TEXCOORD2; // UV, no scaling applied
};


float4 _Color;
TEXTURE2D(_MainTexture); SAMPLER(sampler_MainTexture);
//SAMPLER(_CameraDepthTexture);

float4 _MainTexture_ST;

float LinearDepthToNonLinear(float linear01Depth, float4 zBufferParam){
	// Inverse of Linear01Depth
	return (1.0 - (linear01Depth * zBufferParam.y)) / (linear01Depth * zBufferParam.x);
}

float EyeDepthToNonLinear(float eyeDepth, float4 zBufferParam){
	// Inverse of LinearEyeDepth
	return (1.0 - (eyeDepth * zBufferParam.w)) / (eyeDepth * zBufferParam.z);
}

// VertexOutput Vertex(Attributes input) {
//     VertexOutput OUT;

//     //output.positionCS = TransformObjectToHClip(input.position);
//     float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
//     float3 positionVS = TransformWorldToView(positionWS);
//     float4 positionCS = TransformWorldToHClip(positionWS);

//     OUT.positionVS = positionVS; // (TEXCOORD1 or whatever, any unused will do)
//     OUT.positionCS = positionCS; // (SV_POSITION)
//     OUT.screenPos = ComputeScreenPos(positionCS); // (TEXCOORD2)

//     VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS); 
//     OUT.normalWS = normalInput.normalWS;
//     OUT.uv = TRANSFORM_TEX(input.uv, _MainTexture);
//     return OUT; 
// }
VertexOutput Vertex(Attributes IN) {
    VertexOutput OUT;

    float4 positionCS = TransformObjectToHClip(IN.positionOS.xyz);
    OUT.positionCS = positionCS;
    OUT.screenPos = ComputeScreenPos(positionCS);
    return OUT; 
}


// float4 Fragment(VertexOutput IN) :  SV_Target
// {
//     //index vertex = id triunghi * 3 +0, +1, +2
//     float4 pixelColor = SAMPLE_TEXTURE2D(_MainTexture, sampler_MainTexture, IN.uv);
//     //return pixelColor * _Color;
//     float fragmentEyeDepth = -IN.positionVS.z;
    
//     // float rawDepth = SampleSceneDepth(IN.screenPos.xy / IN.screenPos.w);
//     // float orthoLinearDepth = _ProjectionParams.x > 0 ? rawDepth : 1-rawDepth;
//      float sceneEyeDepth = lerp(_ProjectionParams.y, _ProjectionParams.z, orthoLinearDepth);
//     // float t =cos((IN.uv.y - _Time.y*0.3)*TAU*5)*0.5+0.5;
//     // return t;

//     float depthDifferenceExample = 1 - saturate((sceneEyeDepth - fragmentEyeDepth) * 1);
//     return depthDifferenceExample;
// }

float4 Fragment(VertexOutput IN) :  SV_Target
{
    float rawDepth = SampleSceneDepth(IN.screenPos.xy / IN.screenPos.w);
    float sceneEyeDepth = LinearEyeDepth(rawDepth, _ZBufferParams);

    //float fragmentEyeDepth = -IN.positionVS.z;

    float orthoLinearDepth = _ProjectionParams.x > 0 ? rawDepth : 1-rawDepth;
    float orthoEyeDepth = lerp(_ProjectionParams.y, _ProjectionParams.z, orthoLinearDepth);   
    
    //float depthDifferenceExample = 1 - saturate((sceneEyeDepth - fragmentEyeDepth) * 1);    
    //return depthDifferenceExample;
    return float4(1,0,0,0);
}

// float4 Fragment(VertexOutput IN) :  SV_Target
// {
//       float4 pixelColor = SAMPLE_TEXTURE2D(_MainTexture, sampler_MainTexture, IN.uv);
//       return (1,0,0);
// }
#endif