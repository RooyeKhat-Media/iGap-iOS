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
import IGProtoBuff

class IGLookAndFindCell: UITableViewCell {

    @IBOutlet weak var avatarView: IGAvatarView!
    @IBOutlet weak var txtIcon: UILabel!
    @IBOutlet weak var txtResultName: UILabel!
    @IBOutlet weak var txtResultUsername: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    func setSearchResult(result: IGRealmClientSearchUsername){
        
        if result.type == IGPClientSearchUsernameResponse.IGPResult.IGPType.room.rawValue { // room
            setRoom(room: result.room)
        } else { // user
            setUser(user: result.user)
        }
    }
    
    private func setRoom(room: IGRoom){
        txtResultName.text = room.title
        
        if room.type == IGRoom.IGType.group {
            txtResultUsername.text = room.groupRoom?.publicExtra?.username
            txtIcon.text = ""
        } else {
            txtResultUsername.text = room.channelRoom?.publicExtra?.username
            txtIcon.text = ""
        }
        
        avatarView.setRoom(room)
    }
    
    private func setUser(user: IGRegisteredUser){
        txtResultName.text = user.displayName
        txtResultUsername.text = user.username
        txtIcon.text = ""
        
        avatarView.setUser(user)
    }
}
