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

class IGSettingContactTableViewCell: UITableViewCell {
    @IBOutlet weak var blockedLabel: UILabel!
    @IBOutlet weak var userAvatarView: IGAvatarView!
    @IBOutlet weak var contactNameLable: UILabel!
    @IBOutlet weak var lastSeenStatusLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        blockedLabel.isHidden = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setUser(_ user: IGRegisteredUser) {
        contactNameLable.text = user.displayName
        userAvatarView.setUser(user)
        if user.isBlocked {
            blockedLabel.isHidden = false
            
        }else if user.isBlocked == false {
            blockedLabel.isHidden = true
        }
        switch user.lastSeenStatus {
        case .exactly:
            if let lastSeenTime = user.lastSeen {
                lastSeenStatusLabel.text = "\(lastSeenTime.humanReadableForLastSeen())"
            }
            break
        case .lastMonth:
            lastSeenStatusLabel.text = "Last month"
            break
        case .lastWeek:
            lastSeenStatusLabel.text = "Last week"
            break
        case .longTimeAgo:
            lastSeenStatusLabel.text = "Last seen a long time ago"
            break
        case .online:
            lastSeenStatusLabel.text = "Online"
            break
        case .recently:
            lastSeenStatusLabel.text = "Last seen recently"
            break
        case .support:
            lastSeenStatusLabel.text = "iGap Support"
            break
        case .serviceNotification:
            lastSeenStatusLabel.text = "Service Notification"
            break
        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            self.setUser(user)
//        }

    }

}
