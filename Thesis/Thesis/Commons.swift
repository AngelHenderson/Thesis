//
//  Commons.swift
//  Alpha
//
//  Created by Angel Henderson on 11/18/18.

//

import Foundation


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
