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
    var vigIntensity: Float
    var vigExtent: Float
    var time: Float
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
    
    
    var kNumSections: Float = 12.0
    var vigIntensity: Float = 15.0
    var vigExtent: Float = 0.25
    var time: Float = 0.0
    var speed: Float = 0.003
    
    var strokeColor = UIColor.systemPink

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        
        let toggle = MenuButton(withAsset: .menuIcon)
        view.addSubview(toggle)
        toggle.pinLeading(toView: view, constant: 30)
        toggle.pinBottom(toView: view, constant: -30)
        
        
        let menu = MenuPageViewController()
        addChild(menu)
        view.addSubview(menu.view)
        menu.didMove(toParent: self)
        
        menu.view.translatesAutoresizingMaskIntoConstraints = false
        menu.view.pinLeading(toView: view, constant: 30)
        menu.view.bottomAnchor.constraint(equalTo: toggle.topAnchor, constant: -10).isActive = true
        menu.view.widthAnchor.constraint(equalToConstant: 400).isActive = true
        menu.view.isHidden = true
        
        
        toggle.tapAction = {
            menu.view.isHidden = !menu.view.isHidden
        }
        
        
        menu.addComponent(Slider(title: "kNumSections", min: 1, max: 24, value: Double(kNumSections), isInt: true, onChange: { value in
            self.kNumSections = Float(Int(value))
        }))
        
        menu.addComponent(Slider(title: "vigIntensity", min: 1, max: 50, value: Double(vigIntensity), isInt: false, onChange: { value in
            self.vigIntensity = Float(value)
        }))
        
        menu.addComponent(Slider(title: "vigExtent", min: 0, max: 5, value: Double(vigExtent), isInt: false, onChange: { value in
            self.vigExtent = Float(value)
        }))
        
        menu.addComponent(Slider(title: "speed", min: 0.001, max: 0.1, value: Double(speed), isInt: false, onChange: { value in
            self.speed = Float(value)
        }))
        
        
        menu.constrainLastComponent()
        

        let defaultLibrary = try! self.metalContext.library(for: .main)
        let fragment = defaultLibrary.makeFunction(name: "fragmentFunc")
        let vertex = defaultLibrary.makeFunction(name: "vertexFunc")

        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        descriptor.vertexFunction = vertex
        descriptor.fragmentFunction = fragment
        


        self.renderState = try! self.metalContext
                                    .device
                                    .makeRenderPipelineState(descriptor: descriptor)

        self.metalView.depthStencilPixelFormat = .invalid
        self.metalView.device = self.metalContext.device
        self.metalView.delegate = self
        
        self.metalView.layer.isOpaque = false
        

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

        let hue = time.truncatingRemainder(dividingBy: 1.0)
        let color = UIColor(hue: CGFloat(hue), saturation: 1.0, brightness: 1.0, alpha: 1.0).cgColor
        self.cgContext?.setStrokeColor(color)
        
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
        
        newPos.x = max(min(newPos.x, 2.0-newPos.x), -newPos.x)
        newPos.y = max(min(newPos.y, 2.0-newPos.y), -newPos.y)
        
        return CGPoint(x: Double(newPos.x), y: Double(newPos.y))
    }
}

extension ViewController: MTKViewDelegate {
    func draw(in view: MTKView) {
        
        time += speed
        
        try? self.metalContext.scheduleAndWait { buffer in
            buffer.render(descriptor: view.currentRenderPassDescriptor!) { encoder in
                encoder.setRenderPipelineState(self.renderState!)
                
                var fragUniforms = FragmentUniforms(kNumSections: self.kNumSections, vigIntensity: self.vigIntensity, vigExtent: self.vigExtent, time: time)
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
