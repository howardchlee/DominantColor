//
//  ViewController.swift
//  DominantColors
//
//  Created by Howard Lee on 6/7/16.
//  Copyright © 2016 hulu. All rights reserved.
//

import UIKit

let maxDomColor:Int = 5
let colorBlockSize: Int = 32

public class ColorBlock: NSObject {
    let r: Int
    let g: Int
    let b: Int
    var count: Int = 0
    
    init(r: Int, g: Int, b: Int) {
        self.r = r
        self.g = g
        self.b = b
    }
    
    
    func isEqualToColorBlock(other:ColorBlock) -> Bool {
        return r == other.r && g == other.g && b == other.b
    }
    
    var represetativeColor : UIColor {

        let rf = CGFloat(r * colorBlockSize + colorBlockSize/2)
        let gf = CGFloat(g * colorBlockSize + colorBlockSize/2)
        let bf = CGFloat(b * colorBlockSize + colorBlockSize/2)
        return UIColor(red: rf/255.0, green: gf/255.0, blue: bf/255.0, alpha: 1)
    }
    
    override public var description: String {
        return "r: \(r), g: \(g), b:\(b), count:\(count)"
    }
    
}

class ViewController: UIViewController {

    var colorMap: [ColorBlock] = []

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var color1: UIView!
    @IBOutlet weak var color2: UIView!
    @IBOutlet weak var color3: UIView!
    @IBOutlet weak var color4: UIView!

    @IBOutlet weak var fileButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var trashButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        cameraButton.enabled = (UIImagePickerController.isSourceTypeAvailable(.Camera))

        scrollView.minimumZoomScale = 0.5
        scrollView.maximumZoomScale = 6.0
        scrollView.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        calculateDominantColors()
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }

    @IBAction func selectImage(sender: AnyObject) {
        var type: UIImagePickerControllerSourceType = .PhotoLibrary
        if sender as! NSObject == cameraButton {
            type = .Camera
        }
        
        if UIImagePickerController.isSourceTypeAvailable(type) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = type
            imagePicker.allowsEditing = true
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func recalculateColors(sender: AnyObject) {
        calculateDominantColors()
    }

    @IBAction func clearImage(sender: AnyObject) {
        imageView.image = nil
        color1.backgroundColor = UIColor.clearColor()
        color2.backgroundColor = UIColor.clearColor()
        color3.backgroundColor = UIColor.clearColor()
        color4.backgroundColor = UIColor.clearColor()
        trashButton.enabled = false
    }

    func calculateDominantColors() {
        //guard let image = imageView.image else { return }
        
        UIGraphicsBeginImageContextWithOptions(scrollView.bounds.size, true, 1)
        let offsetRect = CGRect(x: 0, y: 0, width: scrollView.bounds.size.width, height: scrollView.bounds.size.height)
        scrollView.drawViewHierarchyInRect(offsetRect, afterScreenUpdates: true)
        let image:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
    
        // Clear out color map
        colorMap = []
        let nBlocks = 256 / colorBlockSize
        for r in 0..<nBlocks {
            for g in 0..<nBlocks {
                for b in 0..<nBlocks {
                    colorMap.append(ColorBlock(r: r, g: g, b: b))
                }
            }
        }
        var dominantColors: [ColorBlock] = []

        let pixelData = CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage))
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        let height = Int(image.size.height)
        let width = Int(image.size.width)

        for y in 0 ..< height {
            for x in 0 ..< width {
                let pixelIndex: Int = ((Int(image.size.width) * y) + x) * 4
                let r = Int(data[pixelIndex+2] / UInt8(colorBlockSize))
                let g = Int(data[pixelIndex+1] / UInt8(colorBlockSize))
                let b = Int(data[pixelIndex] / UInt8(colorBlockSize))
                
                let index = r * nBlocks * nBlocks + g * nBlocks + b
                colorMap[index].count += 1
                
                var alreadyExist = false
                var needSort = false
                for i in 0..<dominantColors.count {
                    if dominantColors[i].isEqualToColorBlock(colorMap[index]) {
                        alreadyExist = true
                        needSort = true
                        break
                    }
                }
                
                if (!alreadyExist) {
                    if (dominantColors.count < maxDomColor) {
                        dominantColors.append(colorMap[index])
                        needSort = true
                    } else if (colorMap[index].count > dominantColors[maxDomColor-1].count) {
                        dominantColors[maxDomColor-1] = colorMap[index]
                        needSort = true
                    }
                }
                
                if needSort {
                    dominantColors = dominantColors.sort({ (a, b) -> Bool in
                        return a.count > b.count
                    })
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue()) { [weak self] in
            if dominantColors.count > 0 {
                self?.color1.backgroundColor = dominantColors[0].represetativeColor
            }
            if dominantColors.count > 1 {
                self?.color2.backgroundColor = dominantColors[1].represetativeColor
            }
            if dominantColors.count > 2 {
                self?.color3.backgroundColor = dominantColors[2].represetativeColor
            }
            if dominantColors.count > 3 {
                self?.color4.backgroundColor = dominantColors[3].represetativeColor
            }
        }
    }
    
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imageView.image = image
        
        trashButton.enabled = (imageView.image != nil)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension ViewController: UIScrollViewDelegate {
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

