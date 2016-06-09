//
//  ViewController.swift
//  ShapeMaskAnimation
//
//  Created by Howard Lee on 6/8/16.
//  Copyright © 2016 Howard Lee. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var shapeLayer: CAShapeLayer = CAShapeLayer()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let width = view.bounds.width
        let height = view.bounds.height
        let initialCircleRadius: CGFloat = 30.0
        let finalCircleRadius: CGFloat = sqrt(width * width + height * height)
        
        let initialCircleRect = CGRect(x: width / 2.0 - initialCircleRadius, y: height / 2.0 - initialCircleRadius, width: initialCircleRadius * 2, height: initialCircleRadius * 2)
        let finalCircleRect = CGRect(x: width / 2 - finalCircleRadius, y: height / 2 - finalCircleRadius, width: finalCircleRadius * 2, height: finalCircleRadius * 2)

        let path = UIBezierPath(ovalInRect: initialCircleRect).CGPath
        let finalPath = UIBezierPath(ovalInRect: finalCircleRect).CGPath
        shapeLayer.path = path
        view.layer.mask = shapeLayer
        
        CATransaction.begin()
        CATransaction.setCompletionBlock { [weak self] in
            self?.view.layer.mask = nil
        }
        let animation = CABasicAnimation(keyPath: "path")
        animation.toValue = finalPath
        animation.duration = 5
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        shapeLayer.addAnimation(animation, forKey: animation.keyPath)
        CATransaction.commit()
    }
}

