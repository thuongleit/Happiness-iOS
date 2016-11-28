//
//  ConfettiView.swift
//  Happiness
//
//  Created by Dylan Miller on 11/23/16.
//  Copyright © 2016 Team Happiness. All rights reserved.
//

import UIKit

class ConfettiView: UIView {

    private var emitterLayer: CAEmitterLayer!
    private var isDropping = false
    
    // Pass through touches.
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {

        let hitView = super.hitTest(point, with: event)
        
        if hitView == self {
            
            return nil
        }
        else {
            
            return hitView
        }
    }
    
    // Drop confetti for the specified number of seconds.
    func drop(seconds: Double) {
        
        if !isDropping {
            
            isDropping = true
            start()
            
            let deadlineTime = DispatchTime.now() + .milliseconds(Int(seconds * 1000.0))
            DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                
                self.stop()
                self.isDropping = false
            }
        }
    }

    // Start dropping confetti.
    private func start() {
                
        let happyCell = createEmitterCell(
            image: UIImage(named: UIConstants.ImageName.confettiHappy)!, color: UIColor.white)
        let reallyHappyCell = createEmitterCell(
            image: UIImage(named: UIConstants.ImageName.confettiReallyHappy)!, color: UIColor.white)
        let heartCell = createEmitterCell(
            image: UIImage(named: UIConstants.ImageName.confettiHeart)!, color: UIColor.white)
        
        emitterLayer = CAEmitterLayer()
        emitterLayer.beginTime = CACurrentMediaTime()
        emitterLayer.emitterPosition = CGPoint(x: center.x, y: 0)
        emitterLayer.emitterShape = kCAEmitterLayerLine
        emitterLayer.emitterSize = CGSize(width: frame.size.width, height: 1)
        emitterLayer.emitterCells = [happyCell, reallyHappyCell, heartCell]
        layer.addSublayer(emitterLayer)
    }
    
    // Stop dropping confetti.
    private func stop() {
        
        emitterLayer.birthRate = 0
    }
    
    // Create a CAEmitterCell using the specified image and color.
    private func createEmitterCell(image: UIImage, color: UIColor) -> CAEmitterCell {
        
        let emitterCell = CAEmitterCell()
        emitterCell.birthRate = 30
        emitterCell.lifetime = 5
        emitterCell.lifetimeRange = 0
        emitterCell.color = color.cgColor
        emitterCell.velocity = 400
        emitterCell.velocityRange = 50
        emitterCell.emissionLongitude = CGFloat.pi
        emitterCell.emissionRange = CGFloat.pi / 4
        emitterCell.spin = 2
        emitterCell.spinRange = 3
        emitterCell.scaleRange = 0.5
        emitterCell.scaleSpeed = -0.05
        emitterCell.contents = image.cgImage
        return emitterCell
    }
}
