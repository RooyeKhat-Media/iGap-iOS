/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the RooyeKhat Media Company - www.RooyeKhat.co
 * All rights reserved.
 */

import RealmSwift
import Foundation
import IGProtoBuff

class IGChannelMember: Object {
    
    enum IGRole: Int {
        case member = 0
        case moderator
        case admin
        case owner
    }

    dynamic var primaryKeyId: String         = ""    // user_id + _ + room_id
    dynamic var roomID: Int64                        = -1
    dynamic var userID: Int64                        = -1
    dynamic var roleRaw: IGRole.RawValue  = IGRole.member.rawValue
    dynamic var user: IGRegisteredUser?
    
    var role: IGRole {
        get {
            if let s = IGRole(rawValue: roleRaw) {
                return s
            }
            return .member
        }
        set {
            roleRaw = newValue.rawValue
        }
    }

    
    override static func primaryKey() -> String {
        return "primaryKeyId"
    }
    override static func ignoredProperties() -> [String] {
        return ["role"]
    }

    
    
    
    convenience init(igpMember: IGPChannelGetMemberListResponse.IGPMember, roomId: Int64) {
        self.init()
        self.userID = igpMember.igpUserId
        self.roomID = roomId
        self.primaryKeyId = "\(Int(igpMember.igpUserId))" + "_" + "\(Int(roomId))"
        if igpMember.hasIgpRole == true {
            switch igpMember.igpRole {
            case .admin:
                self.role = .admin
            case .member:
                self.role = .member
            case .moderator:
                self.role = .moderator
            case .owner:
                self.role = .owner
            default:
                break
            }
            
        }
        
    }
    convenience init(userID : Int64 , role : IGRole) {
        self.init()
        self.userID = userID
        self.role = role
        
    }
}

class IGChannelRoom: Object {
    enum IGType: Int {
        case privateRoom = 0
        case publicRoom
    }
    
    //MARK: properties
    dynamic var id:                         Int64                           = -1
    dynamic var typeRaw:                    IGType.RawValue                 = IGType.privateRoom.rawValue
    dynamic var roleRaw:                    IGChannelMember.IGRole.RawValue = IGChannelMember.IGRole.member.rawValue
    dynamic var filterRole:                 IGRoomFilterRole.RawValue       = IGRoomFilterRole.all.rawValue
    dynamic var participantCount:           Int32                           = 0
    dynamic var participantCountText:       String                          = ""
    dynamic var roomDescription:            String                          = ""
    dynamic var avatarCount:                Int32                           = 0
    dynamic var avatar:                     IGAvatar?
    dynamic var privateExtra:               IGChannelPrivateExtra?
    dynamic var publicExtra:                IGChannelPublicExtra?
    dynamic var isSignature:                Bool                            = false
    //MARK: ignored properties
    var type: IGType {
        get {
            if let s = IGType(rawValue: typeRaw) {
                return s
            }
            return .privateRoom
        }
        set {
            typeRaw = newValue.rawValue
        }
    }
    
    var role: IGChannelMember.IGRole {
        get {
            if let s = IGChannelMember.IGRole(rawValue: roleRaw) {
                return s
            }
            return .member
        }
        set {
            roleRaw = newValue.rawValue
        }
    }

    //MARK: override
    override static func ignoredProperties() -> [String] {
        return ["type", "role"]
    }
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    //MARK: init
    convenience init(igpChannelRoom: IGPChannelRoom, id: Int64) {
        self.init()
        self.id = id
        switch igpChannelRoom.igpType {
        case .privateRoom:
            self.type = .privateRoom
        case .publicRoom:
            self.type = .publicRoom
        }
        switch igpChannelRoom.igpRole {
        case .member:
            self.role = .member
        case .moderator:
            self.role = .moderator
        case .admin:
            self.role = .admin
        case .owner:
            self.role = .owner
        }
        self.participantCount = igpChannelRoom.igpParticipantsCount
        self.participantCountText = igpChannelRoom.igpParticipantsCountLabel
        self.roomDescription = igpChannelRoom.igpDescription
        self.avatarCount = igpChannelRoom.igpAvatarCount
        if igpChannelRoom.hasIgpAvatar{
            self.avatar = IGAvatar(igpAvatar: igpChannelRoom.igpAvatar)
        }
        if igpChannelRoom.hasIgpPrivateExtra {
            self.privateExtra = IGChannelPrivateExtra(igpPrivateExtra: igpChannelRoom.igpPrivateExtra, id: id)
        }
        if igpChannelRoom.hasIgpPublicExtra{
            self.publicExtra = IGChannelPublicExtra(igpPublicExtra: igpChannelRoom.igpPublicExtra, id: id)
        }
    }
    
    
    //detach from current realm
    func detach() -> IGChannelRoom {
        let detachedChannelRoom = IGChannelRoom(value: self)
        
        if let avatar = self.avatar {
            let detachedAvatar = avatar.detach()
            detachedChannelRoom.avatar = detachedAvatar
        }
        if let privateExtra = self.privateExtra {
            let detachedPrivateExtra = privateExtra.detach()
            detachedChannelRoom.privateExtra = detachedPrivateExtra
        }
        if let publicExtra = self.publicExtra {
            let detachedPublicExtra = publicExtra.detach()
            detachedChannelRoom.publicExtra = detachedPublicExtra
        }
        
        return detachedChannelRoom
    }

}


class IGChannelPrivateExtra: Object {
    dynamic var id:             Int64   = -1
    dynamic var inviteLink:     String  = ""
    dynamic var inviteToken:    String  = ""
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    convenience init(igpPrivateExtra: IGPChannelRoom.IGPPrivateExtra, id: Int64) {
        self.init()
        self.id = id
        self.inviteLink = igpPrivateExtra.igpInviteLink
        self.inviteToken = igpPrivateExtra.igpInviteToken
    }
    
    //detach from current realm
    func detach() -> IGChannelPrivateExtra {
        return IGChannelPrivateExtra(value: self)
    }
}

class IGChannelPublicExtra: Object {
    dynamic var id:         Int64   = -1
    dynamic var username:   String  = ""
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    convenience init(igpPublicExtra: IGPChannelRoom.IGPPublicExtra, id: Int64) {
        self.init()
        self.id = id
        self.username = igpPublicExtra.igpUsername
    }
    
    convenience init(id: Int64, username: String) {
        self.init()
        self.id = id
        self.username = username
    }
    
    //detach from current realm
    func detach() -> IGChannelPublicExtra {
        return IGChannelPublicExtra(value: self)
    }
}
