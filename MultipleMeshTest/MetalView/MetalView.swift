//
//  MetalView.swift
//  GiphyStudio
//
//  Created by BYUNGWOOK JEONG on 2022/01/25.
//

import SwiftUI
import MetalKit

struct MetalView: UIViewRepresentable {
    let mtkView = MTKView()
    
    func makeUIView(context: Context) -> MTKView {
        mtkView.colorPixelFormat = .bgra8Unorm
        mtkView.framebufferOnly = false
        mtkView.preferredFramesPerSecond = 60
        mtkView.delegate = context.coordinator
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.tapGesture(_:)))
        tapGestureRecognizer.delegate = context.coordinator
        mtkView.addGestureRecognizer(tapGestureRecognizer)
        
//        let panGestureRecognizer = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.panGesture(_:)))
//        panGestureRecognizer.delegate = context.coordinator
//        mtkView.addGestureRecognizer(panGestureRecognizer)
        
//        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleGesture(_:)))
//        pinchGestureRecognizer.delegate = context.coordinator
//        mtkView.addGestureRecognizer(pinchGestureRecognizer)
//
//        let rotationGestureRecognizer = UIRotationGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleGesture(_:)))
//        rotationGestureRecognizer.delegate = context.coordinator
//        mtkView.addGestureRecognizer(rotationGestureRecognizer)
        
        return mtkView
    }
    
    func updateUIView(_ uiView: MTKView, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MTKViewDelegate {
        var parent: MetalView
        
        init(_ parent: MetalView) {
            self.parent = parent
            
            let device = MTLCreateSystemDefaultDevice()
            parent.mtkView.device = device
            Engine.ignite(device: device)
            
            // Test
            let texture_0 = Engine.makeTexture(imageName: "picture", imageType: "png")!
            let texture_1 = Engine.makeTexture(imageName: "bike", imageType: "png")!
            
            MetalData.shared.addTexture(texture: texture_0)
            MetalData.shared.addTexture(texture: texture_1)
            //
        }
        
        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
            MetalData.shared.viewHalfSize = SIMD2<Float>(Float(size.width), Float(size.height)) / 2
        }
        
        func draw(in view: MTKView) {
            guard let drawable = view.currentDrawable else { return }
            
            let commandBuffer = Engine.commandQueue.makeCommandBuffer()
            
            for (index, texture) in MetalData.shared.textures.enumerated() {
                let renderCommandEncoder = commandBuffer?.makeRenderCommandEncoder(
                    descriptor: index == 0 ? Engine.makeFirstRenderPassDescriptor(drawable: drawable): Engine.makeAfterRenderPassDescriptor(drawable: drawable)
                )
                renderCommandEncoder?.setRenderPipelineState(Engine.defaultRenderPipelineState)
                let textureSize = CGSize(width: texture.width, height: texture.height)
                renderCommandEncoder?.setVertexBuffer(Engine.makeVertexBuffer(makeTextureVertexArray(textureSize: textureSize)), offset: 0, index: 0)
                renderCommandEncoder?.setVertexBytes(&MetalData.shared.viewHalfSize, length: MemoryLayout<SIMD2<Float>>.stride, index: 1)
                renderCommandEncoder?.setVertexBytes(&MetalData.shared.translations[index], length: MemoryLayout<SIMD2<Float>>.stride, index: 2)
                renderCommandEncoder?.setVertexBytes(&MetalData.shared.scales[index], length: MemoryLayout<Float>.stride, index: 3)
                renderCommandEncoder?.setVertexBytes(&MetalData.shared.rotations[index], length: MemoryLayout<Float>.stride, index: 4)
                renderCommandEncoder?.setFragmentTexture(texture, index: 0)
                renderCommandEncoder?.drawIndexedPrimitives(type: .triangle,
                                                            indexCount: 6,
                                                            indexType: .uint16,
                                                            indexBuffer: Engine.makeIndexBuffer(),
                                                            indexBufferOffset: 0)
                renderCommandEncoder?.endEncoding()
            }
            
            commandBuffer?.present(drawable)
            commandBuffer?.commit()
        }
        
        func makeTextureVertexArray(textureSize: CGSize) -> [TextureVertex] {
            let viewHalfSize = MetalData.shared.viewHalfSize
            let viewAspectRatio = Float(viewHalfSize.y / viewHalfSize.x)
            let textureAspectRatio = Float(textureSize.height / textureSize.width)
            
            var vertexCoordX: Float = 1.0
            var vertexCoordY: Float = 1.0
            
            // Aspect Fit
            if viewAspectRatio > textureAspectRatio {
                vertexCoordY /= viewAspectRatio
                vertexCoordY *= textureAspectRatio
            } else {
                vertexCoordX *= viewAspectRatio
                vertexCoordX /= textureAspectRatio
            }
            //
                        
            let textureVertexArray = [
                TextureVertex(vertexCoord: SIMD2<Float>(-vertexCoordX, vertexCoordY), textureCoord: SIMD2<Float>(0, 0)),
                TextureVertex(vertexCoord: SIMD2<Float>(-vertexCoordX, -vertexCoordY), textureCoord: SIMD2<Float>(0, 1)),
                TextureVertex(vertexCoord: SIMD2<Float>(vertexCoordX, -vertexCoordY), textureCoord: SIMD2<Float>(1, 1)),
                TextureVertex(vertexCoord: SIMD2<Float>(vertexCoordX, vertexCoordY), textureCoord: SIMD2<Float>(1, 0))
            ]
            
            return textureVertexArray
        }
    }
}
