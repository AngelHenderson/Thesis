//
//  ColorExtension.swift
//
//  Created by Angel Henderson on 11/15/19.
//

import Foundation
import UIKit
import AVKit

// Extension for Orientation
extension UIDeviceOrientation {
    var videoOrientation: AVCaptureVideoOrientation? {
        switch self {
        case .portrait: return .portrait
        case .portraitUpsideDown: return .portraitUpsideDown
        case .landscapeLeft: return .landscapeRight
        case .landscapeRight: return .landscapeLeft
        default: return nil
        }
    }
}

extension UIInterfaceOrientation {
    var videoOrientation: AVCaptureVideoOrientation? {
        switch self {
        case .portrait: return .portrait
        case .portraitUpsideDown: return .portraitUpsideDown
        case .landscapeLeft: return .landscapeLeft
        case .landscapeRight: return .landscapeRight
        default: return nil
        }
    }
}

public protocol Reusable: class {
    static var reuseIdentifier: String { get }
}
public extension Reusable {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
extension UICollectionViewCell:Reusable {}

extension Array {
    public subscript(safety index: Int) -> Element? {
        guard index >= 0, index < endIndex else {
            return nil
        }
        return self[index]
    }
}


enum Haptic {
    case impact(style: UIImpactFeedbackGenerator.FeedbackStyle)
    case notification(style: UINotificationFeedbackGenerator.FeedbackType)
    case selection
    
    func impact(){
        switch self {
        case .impact(style: let style):
            let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: style)
            impactFeedbackgenerator.prepare()
            impactFeedbackgenerator.impactOccurred()
        case .notification(style: let style):
            let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
            notificationFeedbackGenerator.notificationOccurred(style)
        default:
            let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
            selectionFeedbackGenerator.selectionChanged()
        }
    }
}



extension UIColor {
    static var dayPrimaryColor = UIColor.white
    static var daySecondaryColor = UIColor(red:0.98, green:0.98, blue:0.98, alpha:1.00)
    static var dayPrimaryTextColor = UIColor.black
    static var daySecondaryTextColor = UIColor.tertiaryLabel
    
    
    static var nightPrimaryColor = #colorLiteral(red: 0.2028945386, green: 0.2080340087, blue: 0.2129025161, alpha: 1)
    static var nightSecondaryColor = #colorLiteral(red: 0.2126652896, green: 0.2234369814, blue: 0.2512944937, alpha: 1)
    static var nightPrimaryTextColor = UIColor.white
    static var nightSecondaryTextColor = UIColor.white
}


extension UIColor {
    static var primaryBackgroundColor: UIColor {
        return UIColor { (traitCollection: UITraitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                return .nightPrimaryColor
            } else {
                return .dayPrimaryColor
            }
        }
    }
    
    static var secondaryBackgroundColor: UIColor {
        return UIColor { (traitCollection: UITraitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                return .nightSecondaryColor
            } else {
                return .daySecondaryColor
            }
        }
    }
    
    static var primaryTextColor: UIColor {
        return UIColor { (traitCollection: UITraitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                return .nightPrimaryTextColor
            } else {
                return .dayPrimaryTextColor
            }
        }
    }
    
    static var secondaryTextColor: UIColor {
        return UIColor { (traitCollection: UITraitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                return .nightSecondaryTextColor
            } else {
                return .daySecondaryTextColor
            }
        }
    }
    
    static var tabColor: UIColor {
        return UIColor { (traitCollection: UITraitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                return .white
            } else {
                return .lightGray
            }
        }
    }
    
    static var borderLineColor: UIColor {
        return UIColor { (traitCollection: UITraitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                return .clear
            } else {
                return .systemGroupedBackground
            }
        }
    }
}


