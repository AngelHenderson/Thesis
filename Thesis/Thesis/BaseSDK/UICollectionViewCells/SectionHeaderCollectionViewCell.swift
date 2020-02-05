//
//  SectionHeaderCollectionViewCell.swift

//
//  Created by Angel Henderson on 9/2/17.
//  Copyright © 2017 Angel Henderson. All rights reserved.
//

import UIKit


extension SectionHeaderCollectionViewCell {
    func setup(title: String) -> SectionHeaderCollectionViewCell{return headerSetup(title: title)}
}

class SectionHeaderCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var button: UIButton?
    
    func headerSetup(title: String) -> SectionHeaderCollectionViewCell {
        titleLabel?.text = title
        return self
    }
}
