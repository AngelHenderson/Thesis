//
//  AppStoreReviewPrompt.swift

//
//  Created by Angel Henderson on 8/17/18.

//

import UIKit
import StoreKit

class AppStoreReviewPrompt: SingleChoiceWithImageViewController {

    var date: Date?
    var showTitle: String?
    var showId: Int?
    
    override func viewWillAppear(_ animated: Bool) {
        firstButton?.onTap {
            self.dismiss(animated: true, completion: {
                if #available(iOS 10.3, *) {SKStoreReviewController.requestReview()}
                else {openSafari(url: "itms-apps://itunes.apple.com/app/" + AppCoreKit.appID + "?action=write-review")}
            })
        }
    }

}
