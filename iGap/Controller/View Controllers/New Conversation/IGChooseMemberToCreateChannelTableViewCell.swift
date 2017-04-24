/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the RooyeKhat Media Company - www.RooyeKhat.co
 * All rights reserved.
 */

import UIKit

class IGChooseMemberToCreateChannelTableViewCell: UITableViewCell {

    @IBOutlet weak var userAvatarView: IGAvatarView!
    @IBOutlet weak var lastSeenStatusLabel: UILabel!
    @IBOutlet weak var contactNameLabel: UILabel!
    var user : IGChooseMemberFromContactToCreateChannelViewController.User!{
        didSet{
            updateUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateUI() {
        contactNameLabel.text = user.registredUser.displayName
        userAvatarView.setUser(user.registredUser)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
