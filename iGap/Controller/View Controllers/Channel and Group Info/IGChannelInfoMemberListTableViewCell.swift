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

class IGChannelInfoMemberListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var memberUserNameLabel: UILabel!
    @IBOutlet weak var memberAvatarView: IGAvatarView!
    @IBOutlet weak var adminOrModeratorLabel: UILabel!
    @IBOutlet weak var memberRecentlyStatusLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        adminOrModeratorLabel.isHidden = true
        memberRecentlyStatusLabel.textColor = UIColor.organizationalColor()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setUser(_ member: IGChannelMember) {
        if let memberUserDetail = member.user {
            memberUserNameLabel.text = memberUserDetail.displayName
            memberAvatarView.setUser(memberUserDetail)
            if member.role == .admin {
                adminOrModeratorLabel.isHidden = false
                adminOrModeratorLabel.text = "(Admin)"
            }
            if member.role == .moderator {
                adminOrModeratorLabel.isHidden = false
                adminOrModeratorLabel.text = "(Moderator)"
            }
            if member.role == .owner {
                adminOrModeratorLabel.isHidden = false
                adminOrModeratorLabel.text = "(Owner)"
            }
            if member.role == .member {
                adminOrModeratorLabel.isHidden = true
            }
            switch memberUserDetail.lastSeenStatus {
                case .exactly:
                    if let lastSeenTime = memberUserDetail.lastSeen {
                        memberRecentlyStatusLabel.text = "\(lastSeenTime.humanReadableForLastSeen())"
                    }
                    break
                case .lastMonth:
                memberRecentlyStatusLabel.text = "Last month"
                    break
                case .lastWeek:
                 memberRecentlyStatusLabel.text = "Last week"
                    break
                case .longTimeAgo:
                 memberRecentlyStatusLabel.text = "Last seen a long time ago"
                    break
                case .online:
                 memberRecentlyStatusLabel.text = "Online"
                    break
                case .recently:
                 memberRecentlyStatusLabel.text = "Last seen recently"
                    break
                case .support:
                memberRecentlyStatusLabel.text = "iGap Support"
                    break
                case .serviceNotification:
                memberRecentlyStatusLabel.text = "Service Notification"
                    break
            }
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                self.setUser(member)
//            }

            
        }
    }

}
