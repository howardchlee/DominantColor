//
//  GradientTextView.swift
//  ShapeMaskAnimation
//
//  Created by Howard Lee on 6/8/16.
//  Copyright © 2016 Howard Lee. All rights reserved.
//

import UIKit

class GradientTextView: UIView {
    var textMask = CATextLayer()
    var gradientLayer = CAGradientLayer()
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        textMask.contentsScale = UIScreen.mainScreen().scale
        textMask.string = "Hello World!"
        textMask.alignmentMode = kCAAlignmentCenter
        layer.mask = textMask
        
        gradientLayer.colors = [ UIColor.blackColor().CGColor, UIColor.whiteColor().CGColor, UIColor.blackColor().CGColor]
        gradientLayer.locations = [0.0, 0.1, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x:1.0, y:0.5)
        layer.insertSublayer(gradientLayer, above: nil)
        
        let animation = CABasicAnimation(keyPath: "locations")
        animation.toValue = [0.0, 0.9, 1.0]
        animation.duration = 3
        animation.repeatCount = 5
        animation.autoreverses = true
        gradientLayer.addAnimation(animation, forKey: "animateGradient")
        
    }
    
    override func layoutSubviews() {
        textMask.frame = bounds
        gradientLayer.frame = bounds
        super.layoutSubviews()
    }

    /*override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        let currentContext = UIGraphicsGetCurrentContext()
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let color1 = UIColor.blackColor()
        let color2 = UIColor.whiteColor()
        let color3 = UIColor.blackColor()
        
        let colors = [color1.CGColor, color2.CGColor, color3.CGColor]
        
        let locations:[CGFloat] = [0.0, 0.5, 1.0]
        
        let gradient = CGGradientCreateWithColors(colorSpace, colors, locations)
        
        let startPoint = CGPointMake(0, self.bounds.height / 2)
        let endPoint = CGPointMake(self.bounds.width, self.bounds.height / 2)
        
        CGContextDrawLinearGradient(currentContext, gradient, startPoint, endPoint, .DrawsBeforeStartLocation)
    }*/
}
