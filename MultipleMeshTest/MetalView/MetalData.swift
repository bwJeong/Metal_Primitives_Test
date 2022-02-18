//
//  Metadata.swift
//  MultipleMeshTest
//
//  Created by BYUNGWOOK JEONG on 2022/02/16.
//

import CoreGraphics
import MetalKit

class MetalData {
    static let shared = MetalData()
    
    var viewHalfSize: SIMD2<Float> = SIMD2<Float>(0, 0)
    
    var index: Int = 0
    var textures: [MTLTexture] = []
    
    // Transform
    var translations: [SIMD2<Float>] = []
    var scales: [Float] = []
    var rotations: [Float] = []
    
    // Gesture
    var activeGestureRecognizers: Set<UIGestureRecognizer> = []
    var selectedIndex: Int = -1
    
    private init() {}
    
    func addTexture(texture: MTLTexture) {
        textures.append(texture)
        translations.append(SIMD2<Float>(0, 0))
        scales.append(0)
        rotations.append(0)
        
        index += 1
    }
    
    // MARK: - Gesture
    
    private func translationMatrix(_ translation: SIMD2<Float>) -> float3x3 {
        let tx = translation.x;
        let ty = translation.y;
        let transformMatrix = float3x3(SIMD3<Float>(  1,   0, 0),
                                       SIMD3<Float>(  0,   1, 0),
                                       SIMD3<Float>(-tx, -ty, 1));
        
        return transformMatrix;
    }
    
    private func scaleMatrix(_ scale: Float) -> float3x3 {
        let s = 1 / scale;
        let transformMatrix = float3x3(SIMD3<Float>(s, 0, 0),
                                       SIMD3<Float>(0, s, 0),
                                       SIMD3<Float>(0, 0, 1));
        
        return transformMatrix;
    }
    
    private func rotationMatrix(_ radian: Float) -> float3x3 {
        let rad = radian;
        let transformMatrix = float3x3(SIMD3<Float>(cos(rad), -sin(rad), 0),
                                       SIMD3<Float>(sin(rad),  cos(rad), 0),
                                       SIMD3<Float>(       0,         0, 1));
        
        return transformMatrix;
    }
    
//    private func scaleTextureHalfSize(index: Int) -> SIMD2<Float> {
//        let textureHalfSize = SIMD2<Float>(Float(contents[index].size.width) / 2,
//                                           Float(contents[index].size.height) / 2)
//        let maxHalfSize = SIMD2<Float>(Float(viewSize.width), Float(viewSize.height)) / 2
//
//        if textureHalfSize.x < maxHalfSize.x && textureHalfSize.y < maxHalfSize.y {
//            return textureHalfSize
//        }
//
//        var scaledTextureHalfSize: SIMD2<Float>
//        let textureRatio = textureHalfSize.x / textureHalfSize.y
//        let viewRatio = maxHalfSize.x / maxHalfSize.y
//
//        if textureRatio > viewRatio {
//            scaledTextureHalfSize = textureHalfSize / textureHalfSize.x * maxHalfSize.x
//        } else {
//            scaledTextureHalfSize = textureHalfSize / textureHalfSize.y * maxHalfSize.y
//        }
//
//        return scaledTextureHalfSize
//    }
//
//    func isInsideContentArea(index: Int, location: CGPoint) -> Bool {
//        let pixelCoord = SIMD3<Float>(Float(location.x), Float(location.y), 1)
//        let scaledTextureHalfSize = scaleTextureHalfSize(index: index)
//        let transform = (rotationMatrix(rotations[index]) *
//                         scaleMatrix(scales[index]) *
//                         translationMatrix(textureCoords[index]))
//        let topLine = SIMD3<Float>(0, 1, scaledTextureHalfSize.y) * transform
//        let bottomLine = SIMD3<Float>(0, 1, -scaledTextureHalfSize.y) * transform
//        let leftLine = SIMD3<Float>(1, 0, scaledTextureHalfSize.x) * transform
//        let rightLine = SIMD3<Float>(1, 0, -scaledTextureHalfSize.x) * transform
//        let isInside = (dot(topLine, pixelCoord) > 0 &&
//                        dot(bottomLine, pixelCoord) < 0 &&
//                        dot(leftLine, pixelCoord) > 0 &&
//                        dot(rightLine, pixelCoord) < 0)
//
//        if isInside {
//            selectedTextureIndex = index
//
//            return true
//        }
//
//        return false
//    }
}
