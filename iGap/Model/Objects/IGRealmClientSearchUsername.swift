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

class IGRealmClientSearchUsername: Object {
    
    @objc dynamic var room        : IGRoom!
    @objc dynamic var user        : IGRegisteredUser!
    @objc dynamic var type        : IGPClientSearchUsernameResponse.IGPResult.IGPType.RawValue = 0
    
    convenience init(searchUsernameResult: IGPClientSearchUsernameResponse.IGPResult) {
        self.init()
        
        self.room = setRoom(room: searchUsernameResult.igpRoom)
        self.user = setUser(user: searchUsernameResult.igpUser)
        self.type = searchUsernameResult.igpType.rawValue
    }
    
    convenience init(room: IGRoom) {
        self.init()
        self.room = room
        self.user = nil
        self.type = IGPClientSearchUsernameResponse.IGPResult.IGPType.room.rawValue
    }
    
    convenience init(room: IGRoom, user: IGRegisteredUser) {
        self.init()
        self.room = room
        self.user = user
        self.type = IGPClientSearchUsernameResponse.IGPResult.IGPType.user.rawValue
    }
    
    public func setRoom(room: IGPRoom) -> IGRoom{
        let predicate = NSPredicate(format: "id = %lld", room.igpID)
        let realm = try! Realm()
        if let room = realm.objects(IGRoom.self).filter(predicate).first {
            return room
        } else {
            return IGRoom(igpRoom: room)
        }
    }
    
    public func setUser(user: IGPRegisteredUser) -> IGRegisteredUser{
        let predicate = NSPredicate(format: "id = %lld", user.igpID)
        let realm = try! Realm()
        if let userInDb = realm.objects(IGRegisteredUser.self).filter(predicate).first {
            return userInDb
        } else {
            return IGRegisteredUser(igpUser: user)
        }
    }
}
