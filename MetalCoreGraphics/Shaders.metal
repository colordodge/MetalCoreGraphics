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

float2 refl(float2 p,float2 o,float2 n) {
    return 2.0*o+2.0*n*dot(p-o,n)-p;
}

//float2 rot(float2 p, float2 o, float a) {
//    float s = sin(a);
//    float c = cos(a);
//    return o + mul((p - o), float2x2(c, -s, s, c));
//}

float2 hex(float2 pos, float scale) {
    float l = sqrt(4.0/3.0);
    // float2 uv = (coo - iResolution.xy*0.5)/min(iResolution.x,iResolution.y);
    float2 uv = pos;
    uv = uv * scale;
    uv.y = abs(fract((uv.y-1.0)*0.5)*2.0-1.0);
    uv.x = fract(uv.x/l/3.0)*l*3.0;
    if(uv.y < 2.0*uv.x/l) uv = refl(uv, float2(0,0), float2(0.5, sqrt(0.75)));
    if(uv.y > 1.0) uv = refl(uv, float2(0.0, 1.0), float2(1.0, 0.0));
    if(uv.y < -2.0*uv.x/l) uv = refl(uv, float2(0,0), float2(-0.5, sqrt(0.75)));
    if(uv.y < 2.0*uv.x/l) uv = refl(uv, float2(0,0), float2(0.5, sqrt(0.75)));
    if(uv.y > 1.0) uv = refl(uv, float2(0.0, 1.0), float2(1.0, 0.0));
    if(uv.y < -2.0*uv.x/l) uv = refl(uv, float2(0,0), float2(-0.5, sqrt(0.75)));
    // uv.x = -uv.x*iChannelResolution[0].y/iChannelResolution[0].x + 0.5;
    //    uv = rot(uv, float2(0.5, 0.5), _HexRotation + _Time*0.01);
    return uv;
}

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
                            texture2d<half, access::sample> canvas [[texture(0)]])
{
    constexpr sampler s(coord::normalized,
                        address::clamp_to_zero,
                        filter::linear);
    
    float2 pos = in.uv;
    pos = kaleidoscope(pos, 6.0f);
   
    half4 outColor = canvas.sample(s, pos);
  
    
    return outColor;
}

