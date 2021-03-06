//
//  MessageCenterResetPrompt.swift

//
//  Created by Angel Henderson on 8/17/18.

//

import UIKit

class MessageCenterResetPrompt: SingleChoiceWithImageViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        //First Button Tap
        firstButton?.onTap {
            self.dismiss(animated: true, completion: {
                CommonKit.notificationPost(name: "resetMessages")
            })
        }
    }

}
