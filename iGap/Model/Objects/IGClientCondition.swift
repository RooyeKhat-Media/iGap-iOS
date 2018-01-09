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
import RealmSwift

class IGClientCondition {
    
    class IGCCRoom {
        struct IGOfflineEdited {
            var id: Int64 = -1
            var message: String = ""
        }
        struct IGOfflineDeleted {
            var id: Int64 = -1
        }
        enum OfflineMute {
            case unchanged
            case muted
            case unmuted
        }
        
        var id: Int64 = -1
        var messageVersion: Int64 = 0 //The biggest message version available in the room
        var statusVersion: Int64 = 0  //The biggest message status available in the room
        var deleteVersion: Int64 = 0  //The biggest delete version available in the room
        var offlineEdited = [IGOfflineEdited]()
        var offlineDeleted = [IGOfflineDeleted]()
        var offlineSeen: Int64 = 0
        var clearId: Int64 = 0
        var cacheStartId: Int64 = 0
        var cacheEndId: Int64 = 0
        var offlineMute: OfflineMute = .unchanged
    }
    
    var rooms = [IGCCRoom]()
    
    
    init() {
        let realm = try! Realm()
        let rooms = realm.objects(IGRoom.self).filter("isParticipant = 1")
        
        for room in rooms {
            // Set messages notification block
            let predicate = NSPredicate(format: "roomId = %lld AND isDeleted == false", room.id)
            let messages = try! Realm().objects(IGRoomMessage.self).filter(predicate).sorted(byKeyPath: "creationTime")
            let ccRoom = IGCCRoom()
            ccRoom.id = room.id
            if let maxMessageVersion: Int64 = messages.max(ofProperty: "messageVersion") {
                ccRoom.messageVersion = max(0,maxMessageVersion)
            }
            if let maxStatusVersion: Int64 = messages.max(ofProperty: "statusVersion") {
                ccRoom.statusVersion = max(0,maxStatusVersion)
            }
            if let maxDeleteVersion: Int64 = messages.max(ofProperty: "deleteVersion") {
                ccRoom.deleteVersion = max(0,maxDeleteVersion)
            }
            
            if let firstMessage = messages.first {
                ccRoom.cacheStartId = max(0,firstMessage.id)
            }
            if let lastMessage = messages.last {
                ccRoom.cacheEndId = max(0,lastMessage.id)
            }
            
            ccRoom.clearId = room.clearId
            
            self.rooms.append(ccRoom)
        }
    }
}
