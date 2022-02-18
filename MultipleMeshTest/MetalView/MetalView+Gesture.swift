//
//  MetalView+Gesture.swift
//  GiphyStudio
//
//  Created by BYUNGWOOK JEONG on 2022/01/27.
//

import UIKit
import simd

extension MetalView.Coordinator: UIGestureRecognizerDelegate {
    // MARK: - Gesture
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
    
    @objc func tapGesture(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: parent.mtkView)
        let px = Float(location.x * UIScreen.main.scale)
        let py = Float(location.y * UIScreen.main.scale)
    }
    
//    @objc func handleGesture(_ sender: UIGestureRecognizer) {
//        let location = sender.location(in: parent.mtkView)
//        let scaledLocation = CGPoint(x: location.x * UIScreen.main.scale, y: location.y * UIScreen.main.scale)
//
//        switch sender.state {
//        case .began:
//            for i in (0 ..< MetalData.shared.index).reversed() {
//                if TextureManager.shared.isInsideTextureArea(index: i, location: scaledLocation) {
//                    MetalData.shared.activeGestureRecognizers.insert(sender)
//                    
//                    break
//                }
//            }
//        case .ended:
//            TextureManager.shared.activeGestureRecognizers.remove(sender)
//
//            break
//        case .changed:
//            for gestureRecognizer in TextureManager.shared.activeGestureRecognizers {
//                if gestureRecognizer.responds(to: #selector(UIPanGestureRecognizer.translation(in:))) {
//                    translate(gestureRecognizer as! UIPanGestureRecognizer, index: TextureManager.shared.selectedTextureIndex)
//                } else if gestureRecognizer.responds(to: #selector(getter: UIPinchGestureRecognizer.scale)) {
//                    scale(gestureRecognizer as! UIPinchGestureRecognizer, index: TextureManager.shared.selectedTextureIndex)
//                } else if gestureRecognizer.responds(to: #selector(getter: UIRotationGestureRecognizer.rotation)) {
//                    rotate(gestureRecognizer as! UIRotationGestureRecognizer, index: TextureManager.shared.selectedTextureIndex)
//                }
//            }
//
//            break
//        default:
//            break
//        }
//    }
    
    private func translate(_ sender: UIPanGestureRecognizer, index: Int) {
        let translation = sender.translation(in: parent.mtkView)
        let tx = Float(translation.x * UIScreen.main.scale)
        let ty = Float(translation.y * UIScreen.main.scale)

        MetalData.shared.translations[index] += SIMD2<Float>(tx, ty)
        sender.setTranslation(CGPoint.zero, in: parent.mtkView)
    }

    private func scale(_ sender: UIPinchGestureRecognizer, index: Int) {
        let scale = sender.scale

        MetalData.shared.scales[index] *= Float(scale)
        sender.scale = 1
    }

    private func rotate(_ sender: UIRotationGestureRecognizer, index: Int) {
        let rotation = sender.rotation

        MetalData.shared.rotations[index] += Float(rotation)
        sender.rotation = 0
    }
}
