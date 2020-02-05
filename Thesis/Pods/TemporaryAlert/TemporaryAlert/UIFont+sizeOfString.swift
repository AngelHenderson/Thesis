//
//  UIFont+sizeOfString.swift
//  TemporaryAlert
//
//  Created by Daniel Barros López on 11/24/16.
/*
 MIT License
 
 Copyright (c) 2016 Daniel Barros
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import UIKit


internal extension UIFont {
    
    ///  `maxNumberOfLines` of 0 means no limit.
    func sizeOfString(string: String, withMaximumWidth maxWidth: CGFloat, maximumNumberOfLines: Int = 0) -> CGSize {
        
        func stringBoundingRect(string: String, size: CGSize) -> CGRect {
            return (string as NSString).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [.font: self], context: nil)
        }
        
        let rect: CGRect
        if maximumNumberOfLines == 0 {
            rect = stringBoundingRect(string: string, size: CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude))
        } else {
            let oneLineHeight = stringBoundingRect(string: "One line example", size: CGSize(width: CGFloat.greatestFiniteMagnitude, height: .greatestFiniteMagnitude)).height
            rect = stringBoundingRect(string: string, size: CGSize(width: maxWidth, height: oneLineHeight * CGFloat(maximumNumberOfLines)))
        }
        return CGSize(width: ceil(rect.width), height: ceil(rect.height))
    }
}
