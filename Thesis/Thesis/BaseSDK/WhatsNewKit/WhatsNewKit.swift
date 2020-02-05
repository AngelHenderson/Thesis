//
//  WhatsNewKit.swift
//
//  Created by Angel Henderson on 9/26/18.

//

import Foundation
import WhatsNewKit

struct WhatsNewKit {
    static var whatsNewViewController = WhatsNewViewController(whatsNew: Default)
    
     static var Default = WhatsNew(
        // The Title
        title: "What's New",
        // The features you want to showcase
        items: [
            WhatsNew.Item(
                title: "Bug Fixes",
                subtitle: "Bug Fixes and performance improvements",
                image: UIImage.ionicon(with: .bug, textColor: ColorKit.themeColor, size: CGSize(width: 50, height: 50))
            )
        ]
    )
    
    
}

