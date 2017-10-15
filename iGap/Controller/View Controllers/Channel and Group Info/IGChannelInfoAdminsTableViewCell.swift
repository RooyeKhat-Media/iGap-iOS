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
import MGSwipeTableCell
class IGChannelInfoAdminsTableViewCell: UITableViewCell {

    @IBOutlet weak var adminRecentlyStatusLabel: UILabel!
    
    @IBOutlet weak var adminAvatarView: IGAvatarView!
    @IBOutlet weak var adminUserNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setUser(_ member: IGChannelMember) {
        if let memberUserDetail = member.user {
            adminUserNameLabel.text = memberUserDetail.displayName
            adminAvatarView.setUser(memberUserDetail)
            switch memberUserDetail.lastSeenStatus {
            case .exactly:
                if let lastSeenTime = memberUserDetail.lastSeen {
                    adminRecentlyStatusLabel.text = "\(lastSeenTime.humanReadableForLastSeen())"
                }
                break
            case .lastMonth:
                adminRecentlyStatusLabel.text = "Last month"
                break
            case .lastWeek:
                adminRecentlyStatusLabel.text = "Last week"
                break
            case .longTimeAgo:
                adminRecentlyStatusLabel.text = "Last seen a long time ago"
                break
            case .online:
                adminRecentlyStatusLabel.text = "Online"
                break
            case .recently:
                adminRecentlyStatusLabel.text = "Last seen recently"
                break
            case .support:
                adminRecentlyStatusLabel.text = "iGap Support"
                break
            case .serviceNotification:
                adminRecentlyStatusLabel.text = "Service Notification"
                break
            }
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                self.setUser(member)
//            }

            
        }
    }

}
