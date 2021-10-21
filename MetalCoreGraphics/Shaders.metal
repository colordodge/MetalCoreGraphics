//
//  Shaders.metal
//  MetalCoreGraphics
//
//  Created by Andrey Volodin on 04.03.2018.
//  Copyright © 2019 Andrey Volodin. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct MTLTextureViewVertexOut {
    float4 position [[ position ]];
    float2 uv;
};

struct FragmentUniforms {
    float kNumSections;
    float vigIntensity;
    float vigExtent;
    float time;
};


float2 kaleidoscope(float2 pos, float sections) {
    
    const float PI = 3.141592658;
    const float TAU = 2.0 * PI;
    
    // Convert to polar coordinates.
    float2 shiftUV = pos - 0.5;
    float radius = sqrt(dot(shiftUV, shiftUV));
    float angle = atan2(shiftUV.y, shiftUV.x);
    
    // Calculate segment angle amount.
    float segmentAngle = TAU / sections;
    
    // Calculate which segment this angle is in.
    angle -= segmentAngle * floor(angle / segmentAngle);
    
    // Each segment contains one reflection.
    angle = min(angle, segmentAngle - angle);
    
    
    // Convert back to UV coordinates.
    float2 uv = float2(cos(angle), sin(angle)) * radius + 0.5f;
    
    // Reflect outside the inner circle boundary.
    uv = max(min(uv, 2.0 - uv), -uv);
    
    return uv;
}



vertex MTLTextureViewVertexOut vertexFunc(uint vid [[vertex_id]]) {
    MTLTextureViewVertexOut out;
    
    const float2 vertices[] = { float2(-1.0f, 1.0f), float2(-1.0f, -1.0f),
        float2(1.0f, 1.0f), float2(1.0f, -1.0f)
    };
    
    out.position = float4(vertices[vid], 0.0, 1.0);
    float2 uv = vertices[vid];
    uv.y = -uv.y;
    out.uv = fma(uv, 0.5f, 0.5f);
    
    return out;
}

fragment half4 fragmentFunc(MTLTextureViewVertexOut in [[stage_in]],
                            constant FragmentUniforms &uniforms [[buffer(0)]],
                            texture2d<half, access::sample> canvas [[texture(0)]])
{
    constexpr sampler s(coord::normalized,
                        address::clamp_to_zero,
                        filter::linear);
    
    float2 pos = in.uv;
    pos = kaleidoscope(pos, uniforms.kNumSections);
   
    half4 outColor = canvas.sample(s, pos);
    
    
    
    
    
    float2 uv = in.uv;
    
    uv *=  1.0 - uv.yx;   //vec2(1.0)- uv.yx; -> 1.-u.yx; Thanks FabriceNeyret !
    
    float vig = uv.x*uv.y * uniforms.vigIntensity; // multiply with sth for intensity
    
    vig = pow(vig, uniforms.vigExtent); // change pow for modifying the extend of the  vignette
    
    
    outColor *= vig;
    
    
    return outColor;
}

