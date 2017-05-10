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

class IGGroupInfoMemberListTableViewCell: UITableViewCell {

    @IBOutlet weak var groupMemberRecentlyStatus: UILabel!
    @IBOutlet weak var groupMemberAvatarView: IGAvatarView!
    @IBOutlet weak var groupMemberRoleInGroupLabel: UILabel!
    @IBOutlet weak var groupMemberNameLabel: UILabel!
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
            groupMemberNameLabel.text = memberUserDetail.displayName
            groupMemberAvatarView.setUser(memberUserDetail)
            if member.role == .admin {
                groupMemberRoleInGroupLabel.isHidden = false
                groupMemberRoleInGroupLabel.text = "(Admin)"
            }
            if member.role == .moderator {
                groupMemberRoleInGroupLabel.isHidden = false
                groupMemberRoleInGroupLabel.text = "(Moderator)"
            }
            if member.role == .owner {
                groupMemberRoleInGroupLabel.isHidden = false
                groupMemberRoleInGroupLabel.text = "(Owner)"
            }
            if member.role == .member {
                groupMemberRoleInGroupLabel.isHidden = true
            }
            switch memberUserDetail.lastSeenStatus {
            case .exactly:
                if let lastSeenTime = memberUserDetail.lastSeen {
                    groupMemberRecentlyStatus.text = "\(lastSeenTime.humanReadableForLastSeen())"
                }
                break
            case .lastMonth:
                groupMemberRecentlyStatus.text = "Last month"
                break
            case .lastWeek:
                groupMemberRecentlyStatus.text = "Last week"
                break
            case .longTimeAgo:
                groupMemberRecentlyStatus.text = "Last seen a long time ago"
                break
            case .online:
                groupMemberRecentlyStatus.text = "Online"
                break
            case .recently:
                groupMemberRecentlyStatus.text = "Last seen recently"
                break
            case .support:
                groupMemberRecentlyStatus.text = "iGap Support"
                break
            case .serviceNotification:
                groupMemberRecentlyStatus.text = "Service Notification"
                break
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 60.0) {
                self.setUser(member)
            }

        }
    }


}
