//
//  BasicCollectionReusableView.swift

//
//  Created by Angel Henderson on 10/1/17.
//  Copyright © 2017 Angel Henderson Holding Corporation. All rights reserved.
//

import UIKit


extension BasicCollectionReusableView {
    func setup(title: String?, subject: String?) {viewSetup(title: title, subject: subject)}
}

class BasicCollectionReusableView: UICollectionReusableView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel?.textColor = .primaryTextColor
    }
    
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var subjectLabel: UILabel?
    func viewSetup(title: String?, subject: String?) {
        titleLabel?.text = title
        subjectLabel?.text = subject
    }
}
