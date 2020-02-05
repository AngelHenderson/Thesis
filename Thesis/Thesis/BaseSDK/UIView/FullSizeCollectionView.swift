//
//  FullSizeCollectionView.swift
//  LightSource
//
//  Created by Angel Henderson on 10/16/19.
//  Copyright © 2019 Salem Web Network. All rights reserved.
//

import UIKit

class FullSizeCollectionView: UICollectionView {

    override func reloadData() {
        super.reloadData()
        self.invalidateIntrinsicContentSize()
        self.layoutIfNeeded()
    }
    
    override var intrinsicContentSize: CGSize {
        setNeedsLayout()
        layoutIfNeeded()
        return CGSize(width: contentSize.width, height: contentSize.height)
    }

}
