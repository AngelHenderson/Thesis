//
//  SegmentKit.swift

//
//  Created by Angel Henderson on 7/8/18.
//  Copyright © 2018 Angel Henderson. All rights reserved.
//

import Foundation
import UIKit

func segmentControlConfiguration(segment: NLSegmentControl, titles: [String], selectedColor:UIColor, Color: UIColor) -> NLSegmentControl{
    segment.segments = titles
    segment.segmentWidthStyle = .dynamic
    segment.selectionIndicatorHeight = 2.0
    segment.selectionIndicatorColor = ColorKit.themeColor
    segment.selectedTitleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15.0), NSAttributedString.Key.foregroundColor: selectedColor]
    segment.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15.0), NSAttributedString.Key.foregroundColor: Color]
    return segment
}
