//
//  CommonKit.swift
//
//  Created by Angel Henderson on 8/11/17.
//  Copyright © 2018 Angel Henderson. All rights reserved.
//

import Foundation
import Alamofire
import SwifterSwift
import SafariServices
import Alamofire
import TemporaryAlert

// MARK: - Alert
func showSuccessAlert(title: String, subtitle: String) {TemporaryAlert.show(image: .checkmark, title: title, message: subtitle)}
func showTempAlert(title: String, subtitle: String) {TemporaryAlert.show(image: .checkmark, title: title, message: subtitle)}
func showErrorAlert(title: String, subtitle: String) {TemporaryAlert.show(image: .cross, title: title, message: subtitle)}


// MARK: - UserDefaults

//MARK: Set UserDefaults
func setUserDefault(string:String, key:String){UserDefaults.standard.set(string, forKey: key)}
func setUserDefault(bool:Bool, key:String){UserDefaults.standard.set(bool, forKey: key)}
func setUserDefault(int:Int, key:String){UserDefaults.standard.set(int, forKey: key)}
func setUserDefault(float:Float, key:String){UserDefaults.standard.set(float, forKey: key)}
func setUserDefault(object:Any, key:String){UserDefaults.standard.set(object, forKey: key)}

//MARK: Retreive UserDefaults
func getUserDefaultString(key:String) -> String?{ return UserDefaults.standard.string(forKey: key)}
func getUserDefaultBool(key:String) -> Bool?{ return UserDefaults.standard.bool(forKey: key)}
func getUserDefaultInteger(key:String) -> Int?{ return UserDefaults.standard.integer(forKey: key)}
func getUserDefaultFloat(key:String) -> Float?{ return UserDefaults.standard.float(forKey: key)}
func getUserDefaultObject(key:String) -> Any?{ return UserDefaults.standard.object(forKey: key)}

//MARK: Delete UserDefaults
func deleteUserDefault(key:String){UserDefaults.standard.removeObject(forKey: key)}

//MARK: Sync UserDefaults
func syncUserDefault(){UserDefaults.standard.synchronize()}


// MARK: - UIActivityViewController
func presentUIActivityViewController(text: String, frame: CGRect){CommonKit.presentUIActivityViewController(text: text, frame: frame)}
func presentUIActivityViewController(text: String, url: String, frame: CGRect){CommonKit.presentUIActivityViewController(text: text, url: url, frame: frame)}
func presentUIActivityViewController(text: String, image: UIImage, frame: CGRect){CommonKit.presentUIActivityViewController(text: text, image: image, frame: frame)}

// MARK: - Safari
func openSafariViewController(url:String?){CommonKit.openSafariViewController(url:url)}
func openSafari(url:String?){CommonKit.openSafari(url: url)}

// MARK: - Size Class
func cellSizeConfiguration(width:CGFloat, height: CGFloat) -> CGSize {return CommonKit.cellSizeConfiguration(width: width, height: height)}

// MARK: - Navigation Helper
func getCurrentViewController() -> UIViewController? {return CommonKit.getCurrentViewController()}
func getNavigationController() -> UINavigationController? {return CommonKit.getNavigationController()}

// MARK: - Date Conversion
func convertDateFormat(date:String) -> String {return CommonKit.convertDateFormat(date: date)}
func convertDateFormat(date:String, format:String) -> String{return CommonKit.convertDateFormat(date: date, format: format)}


struct CommonKit {
    
    static let iPhoneXWidth: CGFloat = 812
    static let iPhoneXInnerWidth: CGFloat = 724
    
    static func segmentControlConfiguration(segment: NLSegmentControl, titles: [String], selectedColor:UIColor, Color: UIColor) -> NLSegmentControl{
        segment.segments = titles
        segment.segmentWidthStyle = .dynamic
        segment.selectionIndicatorHeight = 2.0
        segment.selectionIndicatorColor = ColorKit.themeColor
        segment.selectedTitleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15.0), NSAttributedString.Key.foregroundColor: selectedColor]
        segment.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15.0), NSAttributedString.Key.foregroundColor: Color]
        return segment
    }


    // MARK: - NSNotificationCenter

    static func notificationSubscribe(name:String, selector: Selector){
        NotificationCenter.default.addObserver(self, selector: selector, name: Notification.Name(rawValue:name), object: nil)
    }
    
    static func notificationPost(name:String){
        print("Post Notification: \(name)")
        NotificationCenter.default.post(name:Notification.Name(rawValue:name), object: nil, userInfo: nil)
    }
    
    // MARK: - UI Functions
    
    static func navigationBarImage() -> UIImageView {
        let image : UIImage = #imageLiteral(resourceName: "Crosscards")
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        return imageView
    }
    
    // MARK: - Size Class
    
    static func cellSizeConfiguration(width:CGFloat, height: CGFloat) -> CGSize {
        var w = width
        
        //print("Name: \(SwifterSwift.deviceName)")
        //print("Model: \(SwifterSwift.deviceModel)")

//        if SwifterSwift.deviceName == "iPhone XR" || SwifterSwift.deviceName == "iPhone XS Max" {
//            w = (896-88)/2.05
//        }
        
        //iPhone X Landscape
        if (w == iPhoneXWidth) {w = iPhoneXInnerWidth/2.05}
            
        //iPhone XS Max and XR Landscape
        else if (w == 896) {w = (896-88)/2.05}
            
        //Includes Landscape Cases (iPhone 4,5,6)
        else if (w <= 1024 && width >= 694 || w == 667 || w == 568 || w == 812) {w = width/2.05}
        else if (w > 1024) {w = width/3.1}

        return CGSize(width: w, height: height)
        
        //414 896
    }
    
    static func cellSizeConfiguration(width:CGFloat) -> Int {
        var w = 1
        if (width == iPhoneXWidth) {w = 2} //iPhone X Landscape
        else if (width == 896) {w = 2} //iPhone XS Max and XR Landscape
        else if (width <= 1024 && width >= 694 || width == 667 || width == 568 || width == 812) {w = 2} //Includes Landscape Cases (iPhone 4,5,6)
        else if (width > 1024) {w = 3}
        else {w = 1}
        return w
    }
    
    // MARK: - Navigation Helper
    
    static func getCurrentViewController() -> UIViewController? {
        if let navigationController = getNavigationController() {
            return navigationController.visibleViewController
        }
        if let rootController = UIApplication.shared.keyWindow?.rootViewController {
            var currentController: UIViewController! = rootController
            while( currentController.presentedViewController != nil ) {
                currentController = currentController.presentedViewController
            }
            return currentController
        }
        return nil
    }
    
    // Returns the navigation controller if it exists
    static func getNavigationController() -> UINavigationController? {
        if let navigationController = UIApplication.shared.keyWindow?.rootViewController{
            return navigationController as? UINavigationController
        }
        return nil
    }
    
    
    // MARK: - UIActivityViewController
    
    static func presentUIActivityViewController(text: String, frame: CGRect){
        let contentToShare = [text] as [Any]
        let activityViewController = VisualActivityViewController(activityItems: contentToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = AppDelegateKit.appDelegate.window?.rootViewController?.view
        activityViewController.popoverPresentationController?.sourceRect = frame
        AppDelegateKit.appDelegate.window?.rootViewController?.present(activityViewController, animated: true, completion: nil)
    }
    
    static func presentUIActivityViewController(text: String, url: String, frame: CGRect){
        if let url = URL(string: url) {
            let contentToShare = [text, url] as [Any]
            let activityViewController = VisualActivityViewController(activityItems: contentToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = AppDelegateKit.appDelegate.window?.rootViewController?.view
            activityViewController.popoverPresentationController?.sourceRect = frame
            AppDelegateKit.appDelegate.window?.rootViewController?.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    static func presentUIActivityViewController(text: String, image: UIImage, frame: CGRect){
        let contentToShare = [text,image] as [Any]
        let activityViewController = VisualActivityViewController(activityItems: contentToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = AppDelegateKit.appDelegate.window?.rootViewController?.view
        activityViewController.popoverPresentationController?.sourceRect = frame
        AppDelegateKit.appDelegate.window?.rootViewController?.present(activityViewController, animated: true, completion: nil)
    }
    
    static func presentUIActivityViewController(text: String, image: UIImage, url: String, frame: CGRect){
        let contentToShare = [text, image, URL(string: url)!] as [Any]
        let activityViewController = VisualActivityViewController(activityItems: contentToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = AppDelegateKit.appDelegate.window?.rootViewController?.view
        activityViewController.popoverPresentationController?.sourceRect = frame
        AppDelegateKit.appDelegate.window?.rootViewController?.present(activityViewController, animated: true, completion: nil)
    }
    
    
    // MARK: - Date Conversion
    
    static func convertDateFormat(date:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let date = dateFormatter.date(from: date)
        return (date?.dateString(ofStyle: .medium) ?? "")
    }
    
    static func convertDateFormat(date:String, format:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let date = dateFormatter.date(from: date)
        return (date?.dateString(ofStyle: .medium) ?? "")
    }
    
    
    
    
    // MARK: - Time Conversion

    static func secondsToHoursMinutesSeconds (seconds : Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let seconds = (seconds % 3600) % 60
        if hours == 0 {return "\(minutes) minutes \(seconds) seconds"}
        else if minutes == 0 {return "\(seconds) seconds"}
        return "\(hours) hours \(minutes) minutes \(seconds) seconds"
    }
    
    static func shortSecondsToHoursMinutesSeconds (seconds : Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let seconds = (seconds % 3600) % 60
        if hours == 0 {return "\(minutes):\(seconds)"}
        else if minutes == 0 {return "0:\(seconds)"}
        return "\(hours):\(minutes):\(seconds)"
    }
    
    static func secondsToHMS (seconds : Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let seconds = (seconds % 3600) % 60
        if hours == 0 {return "\(Int(minutes)):\(Int(seconds))"}
        else if minutes == 0 {return "\(Int(seconds)) seconds"}
        return "\(Int(hours)) hours \(Int(minutes)) minutes \(Int(seconds)) seconds"
    }
    
    
    
    
    
    
    
    
    
//
//
//    func secondsToHoursMinutesSeconds (seconds : Double) -> String {
//        let (hr,  minf) = modf (seconds / 3600)
//        let (min, secf) = modf (60 * minf)
//        return "\(hr):\(min):\(60 * secf)"
//    }

    
    // MARK: - Safari
    
    static func openSafariViewController(url:String?){
        let svc = SFSafariViewController(url: NSURL(string: url!)! as URL)
        AppDelegateKit.appDelegate.window?.rootViewController?.present(svc, animated: true, completion: nil)
        trackEvent(category: "SDK", action: "OpenBrowser", label: url!, value: 1)

    }
    
    static func openSafari(url:String?){
        trackEvent(category: "SDK", action: "OpenBrowser", label: url!, value: 1)
        UIApplication.shared.open(NSURL(string: url!)! as URL, options: [:], completionHandler: nil)
    }
    
}

// MARK: - UIImage

extension UIImage {
    func roundedImageWithBorder(width: CGFloat, color: UIColor) -> UIImage? {
        let square = CGSize(width: min(size.width, size.height) + width * 2, height: min(size.width, size.height) + width * 2)
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: square))
        imageView.contentMode = .center
        imageView.image = self
        imageView.layer.cornerRadius = square.width/2
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = width
        imageView.layer.borderColor = color.cgColor
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
    func cornerRadiusImage() -> UIImage? {
        let square = CGSize(width: min(size.width, size.height), height: min(size.width, size.height))
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: square))
        imageView.contentMode = .center
        imageView.image = self
        imageView.layer.cornerRadius = square.width/8
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 0
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
    func cornerRadiusImageWithBorder(width: CGFloat) -> UIImage? {
        let square = CGSize(width: min(size.width, size.height), height: min(size.width, size.height))
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: square))
        imageView.contentMode = .center
        imageView.image = self
        imageView.layer.cornerRadius = square.width/8
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = width
        imageView.layer.borderColor = ColorKit.themeColor.cgColor
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
    func imageResize (sizeChange:CGSize)-> UIImage{
        
        let hasAlpha = true
        let scale: CGFloat = 0.0 // Use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        self.draw(in: CGRect(origin: CGPoint.zero, size: sizeChange))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage!
    }
    
    
}

// MARK: - UIImage

extension UIImage {
    func tinted(with color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        color.set()
        withRenderingMode(.alwaysTemplate)
            .draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}


// MARK: - Date

extension Date {
    var yesterday: Date {return Calendar.current.date(byAdding: .day, value: -1, to: noon)!}
    var tomorrow: Date {return Calendar.current.date(byAdding: .day, value: 1, to: noon)!}
    var noon: Date {return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!}
    var month: Int {return Calendar.current.component(.month,  from: self)}
    var isLastDayOfMonth: Bool {return tomorrow.month != month}
}

// MARK: - HTML Tags

extension String {
    func deleteHTMLTag() -> String {
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil).htmlEncodedString()
    }
}

extension String {

    func htmlEncodedString() -> String {

        guard let data = self.data(using: .utf8) else {return ""}

        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]

        guard let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
            return ""
        }

        return attributedString.string
    }

}



extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}

extension UILabel {
    func setHTML(html: String) {
        do {
            let attributedString: NSAttributedString = try NSAttributedString(data: html.data(using: .utf8)!, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
            self.attributedText = attributedString.attributedStringWithResizedImages(with: 320)
        } catch {
            self.text = html
        }
    }
    
    func setHTMLBody(html: String) {
        do {
            let modifiedFont = NSString(format:"<span style=\"font-family: Avenir-Book; font-size: 14\">%@</span>" as NSString, html)
            
            let attributedString: NSAttributedString = try NSAttributedString(data:  modifiedFont.data(using: String.Encoding.unicode.rawValue, allowLossyConversion: true)!, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
            
            self.attributedText = attributedString.attributedStringWithResizedImages(with: 320)

        } catch {
            self.text = html
        }
    }
    
    func setHTMLBody(html: String, fontSize: Int) {
        self.text = html

        do {
            let modifiedFont = NSString(format:"<span style=\"font-family: Avenir-Book; font-size: \(fontSize)\">%@</span>" as NSString, html)
            
            if let modified =  modifiedFont.data(using: String.Encoding.unicode.rawValue, allowLossyConversion: true) {
                if let attributedString: NSAttributedString = try? NSAttributedString(data:  modified, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil) {
                    self.attributedText = attributedString.attributedStringWithResizedImages(with: 320)
                }
            }
        } 
    }
}

extension Array {
    func contains<T>(obj: T) -> Bool where T : Equatable {
        return self.filter({$0 as? T == obj}).count > 0
    }
}

extension NSAttributedString {
    func attributedStringWithResizedImages(with maxWidth: CGFloat) -> NSAttributedString {
        let text = NSMutableAttributedString(attributedString: self)
        text.enumerateAttribute(NSAttributedString.Key.attachment, in: NSMakeRange(0, text.length), options: .init(rawValue: 0), using: { (value, range, stop) in
            if let attachement = value as? NSTextAttachment {
                let image = attachement.image(forBounds: attachement.bounds, textContainer: NSTextContainer(), characterIndex: range.location)!
                if image.size.width > maxWidth {
                    let newImage = image.resizeImage(scale: maxWidth/image.size.width)
                    let newAttribut = NSTextAttachment()
                    newAttribut.image = newImage
                    text.addAttribute(NSAttributedString.Key.attachment, value: newAttribut, range: range)
                }
            }
        })
        return text
    }
}

extension UIImage {
    func resizeImage(scale: CGFloat) -> UIImage {
        let newSize = CGSize(width: self.size.width*scale, height: self.size.height*scale)
        let rect = CGRect(origin: CGPoint.zero, size: newSize)

        UIGraphicsBeginImageContext(newSize)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}

public extension UIDevice {
    
    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        func mapToDevice(identifier: String) -> String { // swiftlint:disable:this cyclomatic_complexity
            #if os(iOS)
            switch identifier {
            case "iPod5,1":                                 return "iPod Touch 5"
            case "iPod7,1":                                 return "iPod Touch 6"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
            case "iPhone4,1":                               return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
            case "iPhone7,2":                               return "iPhone 6"
            case "iPhone7,1":                               return "iPhone 6 Plus"
            case "iPhone8,1":                               return "iPhone 6s"
            case "iPhone8,2":                               return "iPhone 6s Plus"
            case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
            case "iPhone8,4":                               return "iPhone SE"
            case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                return "iPhone X"
            case "iPhone11,2":                              return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
            case "iPhone11,8":                              return "iPhone XR"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
            case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
            case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
            case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
            case "iPad6,11", "iPad6,12":                    return "iPad 5"
            case "iPad7,5", "iPad7,6":                      return "iPad 6"
            case "iPad11,4", "iPad11,5":                    return "iPad Air (3rd generation)"
            case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
            case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
            case "iPad11,1", "iPad11,2":                    return "iPad Mini 5"
            case "iPad6,3", "iPad6,4":                      return "iPad Pro (9.7-inch)"
            case "iPad6,7", "iPad6,8":                      return "iPad Pro (12.9-inch)"
            case "iPad7,1", "iPad7,2":                      return "iPad Pro (12.9-inch) (2nd generation)"
            case "iPad7,3", "iPad7,4":                      return "iPad Pro (10.5-inch)"
            case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":return "iPad Pro (11-inch)"
            case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":return "iPad Pro (12.9-inch) (3rd generation)"
            case "AppleTV5,3":                              return "Apple TV"
            case "AppleTV6,2":                              return "Apple TV 4K"
            case "AudioAccessory1,1":                       return "HomePod"
            case "i386", "x86_64":                          return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:                                        return identifier
            }
            #elseif os(tvOS)
            switch identifier {
            case "AppleTV5,3": return "Apple TV 4"
            case "AppleTV6,2": return "Apple TV 4K"
            case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
            default: return identifier
            }
            #endif
        }
        
        return mapToDevice(identifier: identifier)
    }()
    
}


extension UIScrollView {
    /// Sets content offset to the top.
    func resetScrollPositionToTop() {
        self.contentOffset = CGPoint(x: -contentInset.left, y: -contentInset.top)
    }
}


// MARK: - Time Duration

extension Int {
    /// The time parts for this integer represented from total seconds in time.
    /// -- returns: A TimeParts struct that describes the parts of time
    func toTimeParts() -> TimeParts {
        let seconds = self
        var mins = 0
        var secs = seconds
        if seconds >= 60 {
            mins = Int(seconds / 60)
            secs = seconds - (mins * 60)
        }
        return TimeParts(seconds: secs, minutes: mins)
    }
    /// The string representation of the time parts (ex: 07:37)
    func asTimeString() -> String {
        return toTimeParts().description
    }
}

struct TimeParts: CustomStringConvertible {
    var seconds = 0
    var minutes = 0
    /// The string representation of the time parts (ex: 07:37)
    var description: String {
        return NSString(format: "%02d:%02d", minutes, seconds) as String
    }
}

// MARK: - Date Iso8601

extension String {
    var iso8601: Date? {
        return Formatter.iso8601.date(from: self)
    }
}

extension Date {
    var iso8601: String {
        return Formatter.iso8601.string(from: self)
    }
}

extension Formatter {
    static let iso8601 = ISO8601DateFormatter([.withInternetDateTime, .withFractionalSeconds])
}

extension ISO8601DateFormatter {
    convenience init(_ formatOptions: Options, timeZone: TimeZone = TimeZone(secondsFromGMT: 0)!) {
        self.init()
        self.formatOptions = formatOptions
        self.timeZone = timeZone
    }
}

func stringify(json: Any, prettyPrinted: Bool = false) -> String {
    var options: JSONSerialization.WritingOptions = []
    if prettyPrinted {
        options = JSONSerialization.WritingOptions.prettyPrinted
    }
    
    do {
        let data = try JSONSerialization.data(withJSONObject: json, options: options)
        if let string = String(data: data, encoding: String.Encoding.utf8) {
            return string
        }
    } catch {
        print(error)
    }
    
    return ""
}


extension Array {
    func removingDuplicates<T: Hashable>(byKey key: (Element) -> T)  -> [Element] {
        var result = [Element]()
        var seen = Set<T>()
        for value in self {
            if seen.insert(key(value)).inserted {
                result.append(value)
            }
        }
        return result
    }
}
