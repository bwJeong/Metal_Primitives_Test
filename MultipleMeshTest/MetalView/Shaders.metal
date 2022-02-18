//
//  Shaders.metal
//  MultipleMeshTest
//
//  Created by BYUNGWOOK JEONG on 2022/02/16.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float2 vertexCoord [[ attribute(0) ]];
    float2 textureCoord [[ attribute(1) ]];
};

struct VertexOut {
    float4 position [[ position ]];
    float2 textureCoord [[ attribute(1) ]];
};

vertex VertexOut default_vertex(VertexIn in [[ stage_in ]],
                                constant float2 &viewHalfSize [[ buffer(1) ]],
                                constant float2 &translation [[ buffer(2) ]],
                                constant float &scale [[ buffer(3) ]],
                                constant float &rotation [[ buffer(4) ]]) {
    VertexOut out;
    
    float2 normalizedTranslation = float2(translation.x, -translation.y) / viewHalfSize;
    float2 transformed = in.vertexCoord + normalizedTranslation;
    
    out.position = float4(transformed.x, transformed.y, 0, 1);
    out.textureCoord = in.textureCoord;
    
    return out;
}

fragment half4 default_fragment(VertexOut in [[ stage_in ]],
                                texture2d<float> texture [[ texture(0) ]]) {
    constexpr sampler linearSampler(min_filter::linear, mag_filter::linear);
    
    float4 color = texture.sample(linearSampler, in.textureCoord);
    
    return half4(color);
}
