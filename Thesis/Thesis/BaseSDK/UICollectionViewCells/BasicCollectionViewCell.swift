//
//  BasicCollectionViewCell.swift

//
//  Created by Angel Henderson on 9/5/17.
//  Copyright © 2017 Angel Henderson Holding Corporation. All rights reserved.
//

import UIKit

import Imaginary

extension BasicCollectionViewCell {
    func setup(title:String?, subject:String?, image:UIImage?){cellSetup(title:title, subject:subject, image:image)}
    func setup(title:String?, subject:String?, imageUrl: String?){cellSetup(title: title, subject: subject, imageUrl: imageUrl)}
}

class BasicCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var subjectLabel: UILabel?
    @IBOutlet weak var imageView: UIImageView?
    @IBOutlet weak var bottomView: UIView?
    @IBOutlet weak var containerView: UIView?
    @IBOutlet weak var thinlineView: UIView?
    @IBOutlet weak var timeLabel: UILabel?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        thinlineView?.backgroundColor = .groupTableViewBackground

//        bottomView?.backgroundColor = .secondaryBackgroundColor
//        titleLabel?.textColor = .primaryTextColor
//        subjectLabel?.textColor = .primaryTextColor
//        thinlineView?.backgroundColor = .secondaryBackgroundColor
//        timeLabel?.textColor = .secondaryLabel

    }
    
//    override func prepareForReuse() {
//        //set your cell's state to default here
//        self.titleLabel?.text = ""
//        self.subjectLabel?.text = ""
//
//    }
//    

    @objc func setupNightMode() {

    }
    
    func cellSetup(title: String?, subject: String?){
        if let cellTitle = title {titleLabel?.text = cellTitle}
        if let cellSubject = subject {subjectLabel?.text = cellSubject}
        imageView?.image = UIImage(color: .systemGroupedBackground, size: (self.imageView?.frame.size)!)
    }
    
//    func setup(title: String, subject: String){
//        titleLabel?.text = title
//        subjectLabel?.text = subject
//        imageView?.image = UIImage(color: .groupTableViewBackground, size: (self.imageView?.frame.size)!)
//    }
    
    func cellSetup(title: String?, subject: String?, image:UIImage?){
       // setupNightMode()
        if let cellTitle = title {titleLabel?.text = cellTitle}
        if let cellSubject = subject {subjectLabel?.text = cellSubject}
        if let cellImage = image {imageView?.image = cellImage}
        else {imageView?.image = UIImage(color: .systemGroupedBackground, size: (self.imageView?.frame.size)!)}
    }
    
    func cellSetup(title:String?, subject:String?, imageUrl: String?) {
        //setupNightMode()
        if let cellTitle = title {self.titleLabel?.text = cellTitle}
        if let cellSubject = subject {self.subjectLabel?.text = cellSubject}
        
        //Crashes Here
        if let cellImageUrl = imageUrl {
            if let url = URL(string: cellImageUrl), let size = self.imageView?.frame.size {
                self.imageView?.setImage(url: url, placeholder:  UIImage(color: .systemGroupedBackground, size: size))
            }
        }
            //print(cellImageUrl)
        else {imageView?.image = UIImage(color: .systemGroupedBackground, size: (self.imageView?.frame.size)!)}
    }
    
    func calculatedHeight() -> CGFloat {
        return 250
    }
    
}
