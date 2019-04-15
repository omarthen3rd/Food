//
//  Extensions.swift
//  RandomRecipe
//
//  Created by Omar Abbasi on 2019-04-14.
//  Copyright © 2019 Omar Abbasi. All rights reserved.
//

import UIKit

extension NSMutableAttributedString {
    
    func setFontForText(_ textToFind: String, _ font: UIFont) {
        
        let range = self.mutableString.range(of: textToFind, options: .caseInsensitive)
        if range.location != NSNotFound {
            let attrs = [NSAttributedString.Key.font : font]
            addAttributes(attrs, range: range)
        }
        
    }
    
    func setBoldForRange(_ range: NSRange, with size: CGFloat) {
        if range.location != NSNotFound {
            let attrs = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: size, weight: UIFont.Weight.semibold)]
            addAttributes(attrs, range: range)
        }
    }
    
    func setColorForRange(_ range: NSRange, with color: UIColor) {
        if range.location != NSNotFound {
            addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        }
    }
    
    func setColorForText(_ textToFind: String, with color: UIColor) {
        let range = self.mutableString.range(of: textToFind, options: .caseInsensitive)
        if range.location != NSNotFound {
            addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        }
    }
    
    func setBoldForText(_ textToFind: String) {
        let range = self.mutableString.range(of: textToFind, options: .caseInsensitive)
        if range.location != NSNotFound {
            let attrs = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 19, weight: UIFont.Weight.semibold)]
            addAttributes(attrs, range: range)
        }
        
    }
    
    func setSizeForText(_ textToFind: String, with size: CGFloat) {
        let range = self.mutableString.range(of: textToFind, options: .caseInsensitive)
        if range.location != NSNotFound {
            let attrs = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: size)]
            addAttributes(attrs, range: range)
        }
        
    }
    
}

extension UIImage {
    
    var averageColor: UIColor? {
        guard let inputImage = self.ciImage ?? CIImage(image: self) else { return nil }
        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: CIVector(cgRect: inputImage.extent)])
            else { return nil }
        guard let outputImage = filter.outputImage else { return nil }
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [CIContextOption.workingColorSpace : kCFNull])
        let outputImageRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: outputImageRect, format: CIFormat.RGBA8, colorSpace: nil)
        
        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
    }
    
}
