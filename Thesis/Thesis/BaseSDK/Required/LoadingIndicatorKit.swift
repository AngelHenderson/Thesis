////  LoadingIndicator.swift

//
//  Created by Angel Henderson on 8/22/17.
//  Copyright © 2017 Angel Henderson. All rights reserved.
//

import Foundation
import BRYXBanner

// MARK: - Feedback Banner (Global)
func showBanner(title: String, subtitle: String) {LoadingIndicatorKit.showBanner(title: title, subtitle: subtitle)}
func showBanner(title: String, subtitle: String, image: UIImage) {LoadingIndicatorKit.showBanner(title: title, subtitle: subtitle, image: image)}
func showBanner(title: String, subtitle: String, image: UIImage, backgroundColor: UIColor) {LoadingIndicatorKit.showBanner(title: title, subtitle: subtitle, image: image, backgroundColor: backgroundColor)}
func showErrorBanner(title: String, subtitle: String) {LoadingIndicatorKit.showErrorBanner(title: title, subtitle: subtitle)}
func showInternetErrorBanner() {LoadingIndicatorKit.showInternetErrorBanner()}
func showJsonErrorBanner() {LoadingIndicatorKit.showJsonErrorBanner()}

// MARK: - Loading Indicator (Global)
func loadingIndicator() {LoadingIndicatorKit.loadingIndicator()}
func loadingIndicator(text: String) {LoadingIndicatorKit.loadingIndicator(text: text)}
func loadingIndicatorFullScreen(text: String) {LoadingIndicatorKit.loadingIndicatorFullScreen(text: text)}
func dismissIndicator() {LoadingIndicatorKit.dismissIndicator()}


// MARK: - Loading Indicator

struct LoadingIndicatorKit{
    
    static func loadingIndicator() {TAOverlay.show(withLabel: "", options: [TAOverlayOptions.allowUserInteraction,TAOverlayOptions.overlayTypeActivityBlur,TAOverlayOptions.overlaySizeRoundedRect])}
    static func loadingIndicator(text: String) {TAOverlay.show(withLabel: text, options: [TAOverlayOptions.allowUserInteraction,TAOverlayOptions.overlayTypeActivityBlur,TAOverlayOptions.overlaySizeRoundedRect])}
    static func loadingIndicatorFullScreen(text: String) {TAOverlay.show(withLabel: text, options: [TAOverlayOptions.allowUserInteraction,TAOverlayOptions.overlayTypeActivityBlur,TAOverlayOptions.overlaySizeFullScreen])}
    static func dismissIndicator() {TAOverlay.hide()}
    
    // MARK: - Feedback Banner
    static func showBanner(title: String, subtitle: String) {
        let banner = Banner(title: title, subtitle: subtitle, image: UIImage.ionicon(with: .checkmark, textColor: .white, size: CGSize(width: 60, height: 60)), backgroundColor: ColorKit.themeColor)
        LoadingIndicatorKit.displayBanner(banner: banner)
    }
    
    static func showBanner(title: String, subtitle: String, image: UIImage) {
        let banner = Banner(title: title, subtitle: subtitle, image: image, backgroundColor: ColorKit.themeColor)
        LoadingIndicatorKit.displayBanner(banner: banner)
    }
    
    static func showBanner(title: String, subtitle: String, image: UIImage, backgroundColor: UIColor) {
        let banner = Banner(title: title, subtitle: subtitle, image: image, backgroundColor: backgroundColor)
        LoadingIndicatorKit.displayBanner(banner: banner)
    }
    
    static func showErrorBanner(title: String, subtitle: String) {
        

        let banner = Banner(title: title, subtitle: subtitle, image:UIImage.ionicon(with: .close, textColor: .white, size: CGSize(width: 60, height: 60)), backgroundColor:ColorKit.errorColor)
        LoadingIndicatorKit.displayBanner(banner: banner)
    }
    
    static func showInternetErrorBanner() {
        let banner = Banner(title: "Requires Internet Connection", subtitle: "", image: UIImage.ionicon(with: .close, textColor: .white, size: CGSize(width: 60, height: 60)), backgroundColor:ColorKit.errorColor)
        LoadingIndicatorKit.displayBanner(banner: banner)
    }
    
    static func showJsonErrorBanner() {
        dismissIndicator()
        let banner = Banner(title: "There was an error retrieving information", subtitle: "", image: UIImage.ionicon(with: .close, textColor: .white, size: CGSize(width: 60, height: 60)), backgroundColor:ColorKit.errorColor)
        LoadingIndicatorKit.displayBanner(banner: banner)
    }
}

private extension LoadingIndicatorKit {
    static func displayBanner(banner:Banner) -> Void {
        banner.springiness = .none
        banner.position = .bottom
        banner.show(duration: 3.0)
    }
}



