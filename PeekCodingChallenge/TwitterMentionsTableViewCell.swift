//
//  TwitterMentionsTableViewCell.swift
//  PeekCodingChallenge
//
//  Created by Cristián Garay on 5/13/16.
//  Copyright © 2016 Cristian Garay. All rights reserved.
//

import UIKit

class TwitterMentionsTableViewCell: UITableViewCell {
    
    //MARK: - Elements of cell to show twitter data.
    //Image view for user avatar
    @IBOutlet weak var userAvatarImageView: UIImageView!
    //Label to display user name (twitter handle)
    @IBOutlet weak var userNameLabel: UILabel!
    //Label to display tweet
    @IBOutlet weak var tweetLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
