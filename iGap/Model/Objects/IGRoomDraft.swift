//
//  IGMessageViewController.swift
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

class IGRoomDraft: Object {
    dynamic var message: String = ""
    dynamic var replyTo: Int64  = -1
    dynamic var roomId:  Int64  = -1
    
    
    override static func primaryKey() -> String {
        return "roomId"
    }
    
    //init from network response
    convenience init(igpDraft: IGPRoomDraft, roomId: Int64) {
        self.init()
        self.message = igpDraft.igpMessage
        if igpDraft.igpReplyTo != 0 {
            self.replyTo = igpDraft.igpReplyTo
        }
        self.roomId = roomId
    }
    
    //init from within the device (i.e. segue back from messagesCVC)
    convenience init(message: String?, replyTo: Int64?, roomId: Int64) {
        self.init()
        self.message = message != nil ? message! : ""
        self.replyTo = replyTo != nil ? replyTo! : -1
        self.roomId = roomId
    }
        
    func toIGP() -> IGPRoomDraft {
        let roomDraftBuider = IGPRoomDraft.Builder()
        roomDraftBuider.setIgpMessage(self.message)
        if self.replyTo != -1 {
            roomDraftBuider.setIgpReplyTo(self.replyTo)
        }
        return try! roomDraftBuider.build()
    }
    
    //detach from current realm
    func detach() -> IGRoomDraft {
        let detachedDraft = IGRoomDraft(value: self)
        return detachedDraft
    }
}
