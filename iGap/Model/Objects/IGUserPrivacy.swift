/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the RooyeKhat Media Company - www.RooyeKhat.co
 * All rights reserved.
 */

import Foundation
import RealmSwift
import CryptoSwift
import UIKit
import IGProtoBuff

class IGUserPrivacy : Object {
    
    dynamic private var primaryKeyId:          Int                          = 1
    dynamic var userStatusRaw:                 IGPrivacyLevel.RawValue      = IGPrivacyLevel.allowAll.rawValue
    dynamic var avatarRaw:                     IGPrivacyLevel.RawValue      = IGPrivacyLevel.allowAll.rawValue
    dynamic var groupInviteRaw:                IGPrivacyLevel.RawValue      = IGPrivacyLevel.allowAll.rawValue
    dynamic var channelInviteRaw:              IGPrivacyLevel.RawValue      = IGPrivacyLevel.allowAll.rawValue
    
    
    var userStatus: IGPrivacyLevel {
        get {
            if let s = IGPrivacyLevel(rawValue: userStatusRaw) {
                return s
            }
            return .allowAll
        }
        set {
            userStatusRaw = newValue.rawValue
        }
    }
    var avatar: IGPrivacyLevel {
        get {
            if let s = IGPrivacyLevel(rawValue: avatarRaw) {
                return s
            }
            return .allowAll
        }
        set {
            avatarRaw = newValue.rawValue
        }

    }
    var groupInvite: IGPrivacyLevel {
        get {
            if let s = IGPrivacyLevel(rawValue: groupInviteRaw) {
                return s
            }
            return .allowAll
        }
        set {
            groupInviteRaw = newValue.rawValue
        }

    }
    var channelInvite: IGPrivacyLevel {
        get {
            if let s = IGPrivacyLevel(rawValue: channelInviteRaw) {
                return s
            }
            return .allowAll
        }
        set {
            channelInviteRaw = newValue.rawValue
        }

    }

    override static func primaryKey() -> String {
        return "primaryKeyId"
    }

    override static func ignoredProperties() -> [String] {
        return ["userStatus", "avatar" , "groupInvite" , "channelInvite" ]
    }
    
//    convenience init(igpPrivacyType: IGPPrivacyType , igpPrivacyLevel: IGPPrivacyLevel) {
//        self.init()
//        switch igpPrivacyType {
//        case .avatar:
//            self.avatar = IGPrivacyLevel.allowAll.fromIGP(igpPrivacyLevel)
//        case .channelInvite:
//            self.channelInvite = IGPrivacyLevel.allowAll.fromIGP(igpPrivacyLevel)
//        case .groupInvite:
//            self.groupInvite = IGPrivacyLevel.allowAll.fromIGP(igpPrivacyLevel)
//        case .userStatus:
//            self.userStatus = IGPrivacyLevel.allowAll.fromIGP(igpPrivacyLevel)
//            
//        }
//        
//    }

}
