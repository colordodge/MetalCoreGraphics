//
//  ViewController.swift
//  MetalCoreGraphics
//
//  Created by Andrey Volodin on 04/03/2019.
//  Copyright © 2019 Andrey Volodin. All rights reserved.
//

import UIKit
import Alloy
import MetalKit
import MetalPerformanceShaders

// Returns a size of the 'inSize' aligned to 'align' as long as align is a power of 2
func alignUp(size: Int, align: Int) -> Int {
    #if DEBUG
    precondition(((align-1) & align) == 0, "Align must be a power of two")
    #endif

    let alignmentMask = align - 1

    return (size + alignmentMask) & ~alignmentMask
}

struct FragmentUniforms {
    var kNumSections: Float
}

class ViewController: UIViewController {
    
    @IBOutlet weak var metalView: MTKView!

    let metalContext = try! MTLContext(device: Metal.device)
    var cgContext: CGContext?

//    var originalTexture: MTLTexture?
//    var blurredTexture: MTLTexture?
    var canvas: MTLTexture?
    
    var renderState: MTLRenderPipelineState?
//    var fragmentUniformsBuffer: MTLBuffer!
    
    
    var kNumSections: Float = 6.0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        let menu = MenuPageViewController()
        addChild(menu)
        view.addSubview(menu.view)
        menu.didMove(toParent: self)
        
        menu.view.translatesAutoresizingMaskIntoConstraints = false
        menu.view.pinLeading(toView: view, constant: 30)
        menu.view.pinBottom(toView: view, constant: -30)
        menu.view.widthAnchor.constraint(equalToConstant: 400).isActive = true
//        menu.view.heightAnchor.constraint(equalToConstant: 300).isActive = true
        
        
        let numSectionsSlider = Slider(title: "kNumSections", min: 1, max: 24, value: Double(kNumSections), isInt: true)
        numSectionsSlider.onChange = { value in
            self.kNumSections = Float(Int(value))
        }
        
        menu.addComponent(numSectionsSlider)
        
        menu.constrainLastComponent()
        

//        let puppyImage = UIImage(named: "puppy")!

//        self.originalTexture = try? self.metalContext.texture(from: puppyImage.cgImage!, srgb: false)
//        self.blurredTexture = try? self.originalTexture?.matchingTexture(usage: [.shaderRead, .shaderWrite])
//
//        let blurShader = MPSImageGaussianBlur(device: self.metalContext.device,
//                                              sigma: 24.0)
//
//        try! self.metalContext.scheduleAndWait { buffer in
//            blurShader.encode(commandBuffer: buffer,
//                              sourceTexture: self.originalTexture!,
//                              destinationTexture: self.blurredTexture!)
//        }
        
        
        

        let defaultLibrary = try! self.metalContext.library(for: .main)
        let fragment = defaultLibrary.makeFunction(name: "fragmentFunc")
        let vertex = defaultLibrary.makeFunction(name: "vertexFunc")

        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        descriptor.vertexFunction = vertex
        descriptor.fragmentFunction = fragment
        
        
        
//        descriptor.colorAttachments[0].isBlendingEnabled = true
//        descriptor.colorAttachments[0].rgbBlendOperation = .add
//        descriptor.colorAttachments[0].alphaBlendOperation = .add
//        descriptor.colorAttachments[0].sourceRGBBlendFactor = .one
//        descriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
//        descriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
//        descriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        
//        descriptor.colorAttachments[0].isBlendingEnabled = true
//        descriptor.colorAttachments[0].rgbBlendOperation = .add
//        descriptor.colorAttachments[0].alphaBlendOperation = .add
//        descriptor.colorAttachments[0].sourceRGBBlendFactor = .destinationAlpha
//        descriptor.colorAttachments[0].sourceAlphaBlendFactor = .destinationAlpha
//        descriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
//        descriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusBlendAlpha

        self.renderState = try! self.metalContext
                                    .device
                                    .makeRenderPipelineState(descriptor: descriptor)

        self.metalView.depthStencilPixelFormat = .invalid
        self.metalView.device = self.metalContext.device
        self.metalView.delegate = self
        
        self.metalView.layer.isOpaque = false
        
        
//        var initialFragmentUniforms = FragmentUniforms(kNumSections: 12.0)
//        fragmentUniformsBuffer = self.metalContext.device.makeBuffer(bytes: &initialFragmentUniforms, length: MemoryLayout<FragmentUniforms>.stride, options: [])!
    }

    var lastPoint: CGPoint? = nil

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location = touches.first!.location(in: self.metalView)
        var normalizedLocation = CGPoint(x: location.x / self.metalView.bounds.width,
                                         y: location.y / self.metalView.bounds.height)
        
        normalizedLocation = adjustPoint(normalizedLocation)
        
        let maskLocation = CGPoint(x: normalizedLocation.x * CGFloat(self.cgContext!.width),
                                   y: normalizedLocation.y * CGFloat(self.cgContext!.height))

        self.lastPoint = maskLocation
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location = touches.first!.location(in: self.metalView)
        var normalizedLocation = CGPoint(x: location.x / self.metalView.bounds.width,
                                         y: location.y / self.metalView.bounds.height)
        
        normalizedLocation = adjustPoint(normalizedLocation)
        
        let maskLocation = CGPoint(x: normalizedLocation.x * CGFloat(self.cgContext!.width),
                                   y: normalizedLocation.y * CGFloat(self.cgContext!.height))

        self.cgContext?.move(to: self.lastPoint! )
        self.cgContext?.addLine(to: maskLocation )
        self.cgContext?.strokePath()

        self.lastPoint = maskLocation
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastPoint = nil
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastPoint = nil
    }
    
    func adjustPoint(_ p: CGPoint) -> CGPoint {
        let PI = 3.141592658
        let TAU = PI * 2.0
        let sections = Double(kNumSections)
        
        let shiftUV = Vector2(x: Scalar(p.x), y: Scalar(p.y)) - Vector2(x: 0.5, y: 0.5)
        let radius = sqrt(shiftUV.dot(shiftUV))
        var angle = atan2(shiftUV.y, shiftUV.x)
        
        let segmentAngle = TAU / sections
        angle -= Float(segmentAngle) * floor(angle / Float(segmentAngle))
        angle = min(angle, Float(segmentAngle) - angle)
        
        var newPos = Vector2(x: cos(angle), y: sin(angle))
        newPos.x = newPos.x * radius + 0.5
        newPos.y = newPos.y * radius + 0.5
        
        return CGPoint(x: Double(newPos.x), y: Double(newPos.y))
    }
}

extension ViewController: MTKViewDelegate {
    func draw(in view: MTKView) {
        try? self.metalContext.scheduleAndWait { buffer in
            buffer.render(descriptor: view.currentRenderPassDescriptor!) { encoder in
                encoder.setRenderPipelineState(self.renderState!)
                
                var fragUniforms = FragmentUniforms(kNumSections: self.kNumSections)
                encoder.setFragmentBytes(&fragUniforms, length: MemoryLayout<FragmentUniforms>.size, index: 0)
                
                
                encoder.setFragmentTextures(self.canvas)
                encoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
            }

            buffer.present(view.currentDrawable!)
        }
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        let width = Int(size.width)
        let height = Int(size.height)

        let pixelRowAlignment = self.metalContext.device.minimumTextureBufferAlignment(for: .rgba8Unorm)
        let bytesPerRow = alignUp(size: width, align: pixelRowAlignment) * 4

        let pagesize = Int(getpagesize())
        let allocationSize = alignUp(size: bytesPerRow * height, align: pagesize)
        var data: UnsafeMutableRawPointer? = nil
        let result = posix_memalign(&data, pagesize, allocationSize)
        if result != noErr {
            fatalError("Error during memory allocation")
        }

        let context = CGContext(data: data,
                                width: width,
                                height: height,
                                bitsPerComponent: 8,
                                bytesPerRow: bytesPerRow,
                                space: CGColorSpace(name: CGColorSpace.sRGB)!,
                                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!

        context.scaleBy(x: 1.0, y: -1.0)
        context.translateBy(x: 0, y: -CGFloat(context.height))
        context.setLineJoin(.round)
        context.setLineWidth(3)
//        context.setStrokeColor(gray: 1.0, alpha: 1.0)
        context.setStrokeColor(UIColor.systemPink.cgColor)

        let buffer = self.metalContext
                         .device
                         .makeBuffer(bytesNoCopy: context.data!,
                                     length: allocationSize,
                                     options: .storageModeShared,
                                     deallocator: { pointer, length in free(data) })!

        let textureDescriptor = MTLTextureDescriptor()
        textureDescriptor.pixelFormat = .rgba8Unorm
        textureDescriptor.width = context.width
        textureDescriptor.height = context.height
        textureDescriptor.storageMode = buffer.storageMode
        // we are only going to read from this texture on GPU side
        textureDescriptor.usage = .shaderRead

        self.canvas = buffer.makeTexture(descriptor: textureDescriptor,
                                       offset: 0,
                                       bytesPerRow: context.bytesPerRow)
        self.cgContext = context
    }
}
