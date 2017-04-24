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

class IGRegisteredUser: Object {
    
    enum IGLastSeenStatus: Int {
        case longTimeAgo = 0
        case lastMonth
        case lastWeek
        case online
        case exactly
        case recently
        case support
        case serviceNotification
    }
    
    //properties
    dynamic var id:                 Int64                       = -1
    dynamic var phone:              Int64                       = -1
    dynamic var avatarCount:        Int32                       = 0
    dynamic var selfRemove:         Int32                       = -1
    dynamic var genderRaw:          Int                         = IGGender.unknown.rawValue
    dynamic var cacheID:            String                      = ""
    dynamic var username:           String                      = ""
    dynamic var firstName:          String                      = ""
    dynamic var lastName:           String                      = ""
    dynamic var displayName:        String                      = ""
    dynamic var email:              String?
    dynamic var initials:           String                      = ""
    dynamic var color:              String                      = ""
    dynamic var lastSeen:           Date?
    dynamic var avatar:             IGAvatar?
    dynamic var isDeleted:          Bool                        = false
    dynamic var isMutual:           Bool                        = false //current user have this user in his/her contacts
    dynamic var isInContacts:       Bool                        = false
    dynamic var isBlocked:          Bool                        = false
    dynamic var lastSeenStatusRaw:  IGLastSeenStatus.RawValue   = IGLastSeenStatus.longTimeAgo.rawValue
    //ignored properties
    var lastSeenStatus: IGLastSeenStatus {
        get {
            if let s = IGLastSeenStatus(rawValue: lastSeenStatusRaw) {
                return s
            }
            return .longTimeAgo
        }
        set {
            lastSeenStatusRaw = newValue.rawValue
        }
    }
    var gender: IGGender {
        get {
            if let s = IGGender(rawValue: genderRaw) {
                return s
            }
            return .male
        }
        set {
            genderRaw = newValue.rawValue
        }
    }
    
    //override
    override static func primaryKey() -> String {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["lastSeenStatus"]
    }
    
    //initilizers
    convenience init(id: Int64, cacheID: String) {
        self.init()
        self.id = id
        self.cacheID = cacheID
    }
    
    convenience init(igpAuthor : IGPRoomMessage.IGPAuthor) {
        self.init()
        self.id = igpAuthor.igpUser.igpUserId
        self.cacheID = igpAuthor.igpUser.igpCacheId
    }
    
    convenience init(igpUser: IGPRegisteredUser) {
        self.init()
        self.id = igpUser.igpId
        self.phone = igpUser.igpPhone
        self.avatarCount = igpUser.igpAvatarCount
        self.cacheID = igpUser.igpCacheId
        self.username = igpUser.igpUsername
        self.firstName = igpUser.igpFirstName
        self.lastName = igpUser.igpLastName
        self.displayName = igpUser.igpDisplayName
        self.initials = igpUser.igpInitials
        self.color = igpUser.igpColor
        
        switch igpUser.igpStatus {
        case .longTimeAgo:
            self.lastSeenStatus = .longTimeAgo
            break
        case .lastMonth:
            self.lastSeenStatus = .lastMonth
            break
        case .lastWeek:
            self.lastSeenStatus = .lastWeek
            break
        case .online:
            self.lastSeenStatus = .online
            break
        case .exactly:
            self.lastSeenStatus = .exactly
            break
        case .recently:
            self.lastSeenStatus = .recently
            break
        case .support:
            self.lastSeenStatus = .support
            break
        case .serviceNotifications:
            self.lastSeenStatus = .serviceNotification
            break
        }
        
        self.lastSeen = Date(timeIntervalSince1970: TimeInterval(igpUser.igpLastSeen))
        self.isDeleted = igpUser.igpDeleted
        self.isMutual = igpUser.igpMutual
        if igpUser.hasIgpAvatar{
            self.avatar = IGAvatar(igpAvatar: igpUser.igpAvatar)//.detach()
        }
    }
    
    //detach from current realm
    func detach() -> IGRegisteredUser {
        let detachedUser = IGRegisteredUser(value: self)
        if let avatar = detachedUser.avatar {
            let detachedAvatar = avatar.detach()
            detachedUser.avatar = detachedAvatar
        }
        return detachedUser
    }
    
}


/*
 public fileprivate(set) var igpAvatar:IGPAvatar!
 public fileprivate(set) var hasIgpAvatar:Bool = false
 */
