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
import RxSwift
import RealmSwift

class IGRoomManager: NSObject {
    static let shared = IGRoomManager()
    private var variablesCache: NSCache<NSString, Variable<IGRoom>>
    
    private override init() {
        variablesCache = NSCache()
        variablesCache.countLimit = 2000
        variablesCache.name = "im.igap.cache.IGRoomManager"
        
        super.init()
    }
    
    func set(_ action: IGClientAction, for roomRef: ThreadSafeReference<IGRoom>, from userRef: ThreadSafeReference<IGRegisteredUser>) {
        DispatchQueue.main.async {
            let realm = try! Realm()
            if let room = realm.resolve(roomRef), let user = realm.resolve(userRef) {
                if self.variablesCache.object(forKey: "\(room.id)" as NSString) == nil {
                    self.variablesCache.setObject(Variable(room), forKey: "\(room.id)" as NSString)
                }
                
                if let roomVariableInCache = self.variablesCache.object(forKey: "\(room.id)" as NSString) {
                    let room = roomVariableInCache.value
                    if action == .cancel {
                        if room.currenctActionsByUsers.keys.contains("\(user.id)") {
                           room.currenctActionsByUsers["\(user.id)"] = nil
                        }
                    } else {
                        room.currenctActionsByUsers["\(user.id)"] = (user, action)
                    }
                    roomVariableInCache.value = room
                }
            }
        }
    }
    
    
    func varible(for room:IGRoom) -> Variable<IGRoom>? {
        if self.variablesCache.object(forKey: "\(room.id)" as NSString) == nil {
            self.variablesCache.setObject(Variable(room), forKey: "\(room.id)" as NSString)
        }
        return variablesCache.object(forKey: "\(room.id)" as NSString)
    }
}
