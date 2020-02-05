//
//  MessageCenterTableViewCell.swift

//
//  Created by Angel Henderson on 9/25/17.
//  Copyright © 2017 Angel Henderson Holding Corporation. All rights reserved.
//

import UIKit


class MessageCenterTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var subtitleLabel: UILabel?
    @IBOutlet weak var messageImageView: UIImageView?
    @IBOutlet weak var buttonView: UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel?.textColor = .primaryTextColor
        subtitleLabel?.textColor = .primaryTextColor
        self.contentView.backgroundColor = .primaryBackgroundColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
