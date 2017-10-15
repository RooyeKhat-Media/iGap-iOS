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

class IGGroupAdminListTableViewCell: UITableViewCell {

    @IBOutlet weak var groupAdminLastRecentlyLabel: UILabel!
    @IBOutlet weak var groupAdminNameLabel: UILabel!
    @IBOutlet weak var groupAdminAvatarView: IGAvatarView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setUser(_ member: IGGroupMember) {
        if let memberUserDetail = member.user {
            groupAdminNameLabel.text = memberUserDetail.displayName
            groupAdminAvatarView.setUser(memberUserDetail)
            switch memberUserDetail.lastSeenStatus {
            case .exactly:
                if let lastSeenTime = memberUserDetail.lastSeen {
                    groupAdminLastRecentlyLabel.text = "\(lastSeenTime.humanReadableForLastSeen())"
                }
                break
            case .lastMonth:
                groupAdminLastRecentlyLabel.text = "Last month"
                break
            case .lastWeek:
                groupAdminLastRecentlyLabel.text = "Last week"
                break
            case .longTimeAgo:
                groupAdminLastRecentlyLabel.text = "Last seen a long time ago"
                break
            case .online:
                groupAdminLastRecentlyLabel.text = "Online"
                break
            case .recently:
                groupAdminLastRecentlyLabel.text = "Last seen recently"
                break
            case .support:
                groupAdminLastRecentlyLabel.text = "iGap Support"
                break
            case .serviceNotification:
                groupAdminLastRecentlyLabel.text = "Service Notification"
                break
            }
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                self.setUser(member)
//            }

            
        }
    }

}
