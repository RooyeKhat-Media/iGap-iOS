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

class IGGroupMember: Object {
    
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
    
        
    convenience init(igpMember: IGPGroupGetMemberListResponse.IGPMember, roomId: Int64) {
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
            }
            
        }
        
    }
    convenience init(userID : Int64 , role : IGRole) {
        self.init()
        self.userID = userID
        self.role = role
        
    }
}


class IGGroupRoom: Object {
    enum IGType: Int {
        case privateRoom = 0
        case publicRoom
    }
    enum IGRole: Int {
        case member = 0
        case moderator
        case admin
        case owner
    }

    
    //MARK: properties
    dynamic var id:                         Int64                           = -1
    dynamic var typeRaw:                    IGType.RawValue                 = IGType.privateRoom.rawValue
    dynamic var roleRaw:                    IGGroupMember.IGRole.RawValue     = IGRole.member.rawValue
    dynamic var participantCount:           Int32                           = 0
    dynamic var participantCountText:       String                          = ""
    dynamic var participantCountLimit:      Int32                           = 0
    dynamic var participantCountLimitText:  String                          = ""
    dynamic var roomDescription:            String                          = ""
    dynamic var avatarCount:                Int32                           = 0
    dynamic var avatar:                     IGAvatar?
    dynamic var privateExtra:               IGGroupPrivateExtra?
    dynamic var publicExtra:                IGGroupPublicExtra?
    
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
    var role: IGGroupMember.IGRole {
        get {
            if let s = IGGroupMember.IGRole(rawValue: roleRaw) {
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
    convenience init(igpGroupRoom: IGPGroupRoom, id: Int64) {
        self.init()
        self.id = id
        switch igpGroupRoom.igpType {
        case .privateRoom:
            self.type = .privateRoom
        case .publicRoom:
            self.type = .publicRoom
        }
        switch igpGroupRoom.igpRole {
        case .member:
            self.role = .member
        case .moderator:
            self.role = .moderator
        case .admin:
            self.role = .admin
        case .owner:
            self.role = .owner
        }
        self.participantCount = igpGroupRoom.igpParticipantsCount
        self.participantCountText = igpGroupRoom.igpParticipantsCountLabel
        self.participantCountLimit = igpGroupRoom.igpParticipantsCountLimit
        self.participantCountLimitText = igpGroupRoom.igpParticipantsCountLimitLabel
        self.roomDescription = igpGroupRoom.igpDescription
        self.avatarCount = igpGroupRoom.igpAvatarCount
        if igpGroupRoom.hasIgpAvatar {
            self.avatar = IGAvatar(igpAvatar: igpGroupRoom.igpAvatar)
        }
        if igpGroupRoom.hasIgpPrivateExtra {
            self.privateExtra = IGGroupPrivateExtra(igpPrivateExtra: igpGroupRoom.igpPrivateExtra, id: id)
        }
        if igpGroupRoom.hasIgpPublicExtra {
            self.publicExtra = IGGroupPublicExtra(igpPublicExtra: igpGroupRoom.igpPublicExtra, id: id)
        }
    }
    
    //detach from current realm
    func detach() -> IGGroupRoom {
        let detachedGroupRoom = IGGroupRoom(value: self)
        
        if let avatar = self.avatar {
            let detachedAvatar = avatar.detach()
            detachedGroupRoom.avatar = detachedAvatar
        }
        if let privateExtra = self.privateExtra {
            let detachedPrivateExtra = privateExtra.detach()
            detachedGroupRoom.privateExtra = detachedPrivateExtra
        }
        if let publicExtra = self.publicExtra {
            let detachedPublicExtra = publicExtra.detach()
            detachedGroupRoom.publicExtra = detachedPublicExtra
        }
        //assert(detachedGroupRoom.avatar?.realm == nil, "avatar has realm")
        //assert(detachedGroupRoom.privateExtra?.realm == nil, "detachedGroupRoom.privateExtra has realm")
        //assert(detachedGroupRoom.publicExtra?.realm == nil, "detachedGroupRoom.publicExtra has realm")
        
        return detachedGroupRoom
    }
    
    
}


class IGGroupPrivateExtra: Object {
    dynamic var id:             Int64   = -1
    dynamic var inviteLink:     String  = ""
    dynamic var inviteToken:    String  = ""
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    convenience init(igpPrivateExtra: IGPGroupRoom.IGPPrivateExtra, id: Int64) {
        self.init()
        self.id = id
        self.inviteLink = igpPrivateExtra.igpInviteLink
        self.inviteToken = igpPrivateExtra.igpInviteToken
    }
    
    //detach from current realm
    func detach() -> IGGroupPrivateExtra {
        return IGGroupPrivateExtra(value: self)
    }
}

class IGGroupPublicExtra: Object {
    dynamic var id:         Int64   = -1
    dynamic var username:   String  = ""
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    convenience init(igpPublicExtra: IGPGroupRoom.IGPPublicExtra, id: Int64) {
        self.init()
        self.id = id
        self.username = igpPublicExtra.igpUsername
    }
    
    //detach from current realm
    func detach() -> IGGroupPublicExtra {
        return IGGroupPublicExtra(value: self)
    }
}
