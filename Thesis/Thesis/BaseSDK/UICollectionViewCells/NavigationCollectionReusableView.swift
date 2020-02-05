//
//  NavigationCollectionReusableView.swift

//
//  Created by Angel Henderson on 9/8/17.
//  Copyright © 2017 Angel Henderson Holding Corporation. All rights reserved.
//

import UIKit

import DeckTransition

class NavigationCollectionReusableView: UICollectionReusableView {
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var subjectLabel: UILabel?
    func viewSetup(title: String?, subject: String?) {
        titleLabel?.text = title
        subjectLabel?.text = subject
    }
}
