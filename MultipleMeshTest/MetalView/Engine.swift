//
//  Engine.swift
//  GiphyStudio
//
//  Created by BYUNGWOOK JEONG on 2022/01/26.
//

import MetalKit

class Engine {
    static var device: MTLDevice!
    static var commandQueue: MTLCommandQueue!
    static var defaultRenderPipelineState: MTLRenderPipelineState!
    static var textureCache: CVMetalTextureCache!
    static var textureLoader: MTKTextureLoader!
    
    // MARK: - Initialize
    
    static func ignite(device: MTLDevice?) {
        // Set MTLDevice
        guard let device = device else {
            fatalError("Engine Error: Device does not exist!")
        }
        
        self.device = device
        
        // Set MTLCommandQueue
        self.commandQueue = device.makeCommandQueue()
        
        // Set MTLRenderPipelineState (Default)
        guard let defaultLibrary = device.makeDefaultLibrary() else {
            fatalError("Engine Error: Cannot create defaultLibaray!")
        }
        
        let defaultVertexProgram = defaultLibrary.makeFunction(name: "default_vertex")
        let defaultFragmentAProgram = defaultLibrary.makeFunction(name: "default_fragment")
        let defaultRenderPipelineDescA = MTLRenderPipelineDescriptor()
        defaultRenderPipelineDescA.vertexFunction = defaultVertexProgram
        defaultRenderPipelineDescA.fragmentFunction = defaultFragmentAProgram
        defaultRenderPipelineDescA.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        // Alpha Blending
        defaultRenderPipelineDescA.colorAttachments[0].isBlendingEnabled = true
        defaultRenderPipelineDescA.colorAttachments[0].rgbBlendOperation = .add
        defaultRenderPipelineDescA.colorAttachments[0].alphaBlendOperation = .add
        defaultRenderPipelineDescA.colorAttachments[0].sourceRGBBlendFactor =  .sourceAlpha
        defaultRenderPipelineDescA.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
        defaultRenderPipelineDescA.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        defaultRenderPipelineDescA.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        //
        
        defaultRenderPipelineDescA.vertexDescriptor = makeTextureVertexDescriptor()
        
        do {
            defaultRenderPipelineState = try device.makeRenderPipelineState(descriptor: defaultRenderPipelineDescA)
        } catch {
            fatalError("Engine Error: Cannot create defaultRenderPipelineState!")
        }
        
        // Set CVMetalTextureCache
        CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, device, nil, &textureCache)
        
        // Set MTKTextureLoader
        textureLoader = MTKTextureLoader(device: device)
    }
    
    // MARK: - Make Texture
    
    static func makeEmptyTexture(_ size: CGSize) -> MTLTexture? {
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm,
                                                                         width: Int(size.width),
                                                                         height: Int(size.height),
                                                                         mipmapped: true)
        textureDescriptor.usage = [.shaderRead, .shaderWrite]
        
        let texture = device.makeTexture(descriptor: textureDescriptor)
        
        return texture
    }
    
    static func makeEmptyTextures(_ size: CGSize, length: Int) -> MTLTexture? {
        let textureDescriptor = MTLTextureDescriptor()
        textureDescriptor.textureType = .type2DArray
        textureDescriptor.pixelFormat = .bgra8Unorm
        textureDescriptor.width = Int(size.width)
        textureDescriptor.height = Int(size.height)
        textureDescriptor.arrayLength = length
        
        let textures = device.makeTexture(descriptor: textureDescriptor)
        
        return textures
    }
    
    static func makeTexture(image: UIImage) -> MTLTexture {
        let textureLoader = MTKTextureLoader(device: device)
        let texture = try! textureLoader.newTexture(cgImage: image.cgImage!, options: [.SRGB: false])
        
        return texture
    }
    
    static func makeTexture(pixelBuffer: CVPixelBuffer?) -> MTLTexture? {
        guard let pixelBuffer = pixelBuffer else { return nil }
        
        let w = CVPixelBufferGetWidth(pixelBuffer)
        let h = CVPixelBufferGetHeight(pixelBuffer)
        
        var cvMetalTexture: CVMetalTexture?
        CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCache, pixelBuffer, nil, .bgra8Unorm, w, h, 0, &cvMetalTexture)
        
        guard let unwrappedCVMetalTexture = cvMetalTexture else { return nil }
        
        return CVMetalTextureGetTexture(unwrappedCVMetalTexture)
    }
    
    static func makeTexture(cgImage: CGImage?) -> MTLTexture? {
        let texture = try! textureLoader.newTexture(cgImage: cgImage!, options: [.SRGB: false])
        
        return texture
    }
    
    static func makeTexture(imageName: String, imageType: String) -> MTLTexture? {
        var texture: MTLTexture?
        
        if let textureURL = Bundle.main.url(forResource: imageName, withExtension: imageType) {
            texture = try! textureLoader.newTexture(URL: textureURL, options: [.SRGB: false])
        }
        
        return texture
    }
    
    // MARK: - Make Vertex Buffer
    
    static func makeVertexBuffer(_ textureVertexArray: [TextureVertex]) -> MTLBuffer? {
        let textureVertexArrayLength = MemoryLayout<TextureVertex>.stride * textureVertexArray.count
        let vertexBuffer = device.makeBuffer(bytes: textureVertexArray, length: textureVertexArrayLength, options: [])
        
        return vertexBuffer
    }
    
    // MARK: - Make Vertex / Index Descriptor
    
    static func makeTextureVertexDescriptor() -> MTLVertexDescriptor {
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float2
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.attributes[1].format = .float2
        vertexDescriptor.attributes[1].offset = MemoryLayout<SIMD2<Float>>.stride
        vertexDescriptor.attributes[1].bufferIndex = 0
        vertexDescriptor.layouts[0].stride = MemoryLayout<TextureVertex>.stride
        
        return vertexDescriptor
    }
    
    static func makeIndexBuffer() -> MTLBuffer {
        let indexArray: [UInt16] = [
            0, 1, 3, 3, 1, 2
        ]
        let indexArrayLength = MemoryLayout<UInt16>.stride * indexArray.count
        let indexBuffer = device.makeBuffer(bytes: indexArray, length: indexArrayLength, options: [])
        
        return indexBuffer!
    }
    
    // MARK: - Make Render Pass Descriptor
    
    static func makeFirstRenderPassDescriptor(drawable: CAMetalDrawable) -> MTLRenderPassDescriptor {
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 1, green: 1, blue: 1, alpha: 1)
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        
        return renderPassDescriptor
    }
    
    static func makeAfterRenderPassDescriptor(drawable: CAMetalDrawable) -> MTLRenderPassDescriptor {
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].loadAction = .load
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        
        return renderPassDescriptor
    }
}
