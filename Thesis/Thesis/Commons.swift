//
//  Commons.swift
//  Alpha
//
//  Created by Angel Henderson on 11/18/18.

//

import Foundation


extension UIImage {
    
    var bufferToPixelBuffer: CVPixelBuffer? {
        
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(self.size.width), Int(self.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        
        guard status == kCVReturnSuccess else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
    
    var grayscaledBuffer: CVPixelBuffer? {
        
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(self.size.width), Int(self.size.height), kCVPixelFormatType_OneComponent8, attrs, &pixelBuffer)
        
        guard (status == kCVReturnSuccess) else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let grayColorSpace = CGColorSpaceCreateDeviceGray()
        let context = CGContext(data: pixelData, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: grayColorSpace, bitmapInfo: CGImageAlphaInfo.none.rawValue)
        
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
    
    func resize(size: CGSize) -> UIImage? {
        
        UIGraphicsBeginImageContext(CGSize(width: size.width, height: size.height))
        self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    var grayscaled: UIImage? {
        
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        let context = CGContext(data: nil,
                                width: Int(size.width),
                                height: Int(size.height),
                                bitsPerComponent: 8,
                                bytesPerRow: 0,
                                space: CGColorSpaceCreateDeviceGray(),
                                bitmapInfo: CGImageAlphaInfo.none.rawValue)
        
        guard let ctx = context, let cgImage = cgImage else {
            
            return nil
        }
        
        ctx.draw(cgImage, in: rect)
        
        guard let image = ctx.makeImage() else { return nil }
        
        return UIImage(cgImage: image)
    }
    
    func grayscaledPixels() -> [CGFloat]? {
        
        guard let cgImage = self.cgImage else { return nil }
        
        let size     = self.size
        let dataSize  = size.width * size.height * 4
        var pixelData = [UInt8](repeating: 0, count: Int(dataSize))
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context    = CGContext(data: &pixelData,
                                   width: Int(size.width),
                                   height: Int(size.height),
                                   bitsPerComponent: 8,
                                   bytesPerRow: 4 * Int(size.width),
                                   space: colorSpace,
                                   bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)
        
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        var result: [CGFloat] = []
        
        for i in stride(from: 0, to: pixelData.count, by: 4) {
            
            let val = (CGFloat(pixelData[i]) + CGFloat(pixelData[i+1]) + CGFloat(pixelData[i+2])) / (255.0 * 3.0)
            
            result.append(val)
        }
        
        return result
    }
}


extension String {
    
    func width(withFont font: UIFont) -> CGFloat {
        return ceil(self.size(withAttributes: [.font: font]).width)
    }
    
}

extension UIViewController {
    
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unregisterFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification){
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let newHeight = view.convert(keyboardFrame.cgRectValue, from: nil).size.height - view.layoutMargins.bottom
        keyboardVisibleHeightWillChange(newHeight: newHeight)
    }
    
    @objc private func keyboardWillHide(notification: NSNotification){
        keyboardVisibleHeightWillChange(newHeight: 0)
    }
    
    @objc func keyboardVisibleHeightWillChange(newHeight: CGFloat) {}
    
}

extension UIView {
    
    func shadowDepth() {
        let color = UIColor(red:0.42, green:0.58, blue:0.98, alpha:1.00)
        self.backgroundColor = color
        //self.setTitleColor(.white, for: .normal)
        self.cornerRadius = 8
        //self.titleLabel!.font = UIFont.boldSystemFont(ofSize: 20)
        
        let layer = self.layer
        self.shadowColor = UIColor.black
        self.shadowOffset = CGSize(width: 0, height: 10)
        self.shadowRadius = 6.0
        self.shadowOpacity = 0.3
        
        let shadowWidth = self.bounds.width * 0.9
        let shadowRect = CGRect(x: 0 + (self.bounds.width - shadowWidth) / 2.0, y: 0, width: shadowWidth, height: self.bounds.height)
        layer.shadowPath = UIBezierPath(rect: shadowRect).cgPath
        
        layer.zPosition = 2
    }
}

extension UIButton {
    
    func styleWithFloat() {
        self.layer.cornerRadius = 8
        
        let layer = self.layer
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 10)
        layer.shadowRadius = 6.0
        layer.shadowOpacity = 0.3
        
        let shadowWidth = layer.bounds.width * 0.9
        let shadowRect = CGRect(x: 0 + (layer.bounds.width - shadowWidth) / 2.0, y: 0, width: shadowWidth, height: layer.bounds.height)
        layer.shadowPath = UIBezierPath(rect: shadowRect).cgPath
        
        layer.zPosition = 2
    }
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
}

extension UIImage {
    func rotate(radians: CGFloat) -> UIImage {
        let rotatedSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
            .integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: rotatedSize.width / 2.0,
                                 y: rotatedSize.height / 2.0)
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: radians)
            draw(in: CGRect(x: -origin.x, y: -origin.y,
                            width: size.width, height: size.height))
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return rotatedImage ?? self
        }
        
        return self
    }
}
