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

class IGRoomMessage: Object {
    dynamic var message:            String?
    dynamic var creationTime:       Date?
    dynamic var updateTime:         Date?
    dynamic var authorHash:         String?
    dynamic var authorUser:         IGRegisteredUser? // When sent in a chat/group
    dynamic var authorRoom:         IGRoom?           // When sent in a channel
    dynamic var attachment:         IGFile?
    dynamic var forwardedFrom:      IGRoomMessage?
    dynamic var repliedTo:          IGRoomMessage?
    dynamic var log:                IGRoomMessageLog?
    dynamic var contact:            IGRoomMessageContact?
    dynamic var location:           IGRoomMessageLocation?
    dynamic var id:                 Int64                           = -1
    dynamic var roomId:             Int64                           = -1
    dynamic var primaryKeyId:       String?
    dynamic var messageVersion:     Int64                           = -1
    dynamic var previuosMessageUID: Int64                           = -1
    dynamic var statusVersion:      Int64                           = -1
    dynamic var deleteVersion:      Int64                           = -1
    dynamic var shouldFetchBefore:  Bool                            = false
    dynamic var shouldFetchAfter:   Bool                            = false
    dynamic var isFirstMessage:     Bool                            = false
    dynamic var isLastMessage:      Bool                            = false
    dynamic var isEdited:           Bool                            = false
    dynamic var isDeleted:          Bool                            = false
    dynamic var pendingSend:        Bool                            = false
    dynamic var pendingDelivered:   Bool                            = false
    dynamic var pendingSeen:        Bool                            = false
    dynamic var pendingEdit:        Bool                            = false
    dynamic var pendingDelete:      Bool                            = false
    dynamic var isFromSharedMedia:  Bool                            = false
    dynamic var typeRaw:            IGRoomMessageType.RawValue      = IGRoomMessageType.unknown.rawValue
    dynamic var statusRaw:          IGRoomMessageStatus.RawValue    = IGRoomMessageStatus.unknown.rawValue
    dynamic var temporaryId:        String?
    
    var status: IGRoomMessageStatus {
        get {
            if let s = IGRoomMessageStatus(rawValue: statusRaw) {
                return s
            }
            return .unknown
        }
        set {
            statusRaw = newValue.rawValue
        }
    }
    var type : IGRoomMessageType {
        get {
            if let s = IGRoomMessageType(rawValue: typeRaw) {
                return s
            }
            return .unknown
        }
        set {
            typeRaw = newValue.rawValue
        }
    }
    

    override static func ignoredProperties() -> [String] {
        return ["status", "type"]
    }
    
    override static func primaryKey() -> String {
        return "primaryKeyId"
    }
    
    convenience init(igpMessage: IGPRoomMessage, roomId: Int64, isForward: Bool = false, isReply: Bool = false) {
        self.init()
        self.id = igpMessage.igpMessageId
        if !isForward && !isReply {
            self.roomId = roomId
        }
        self.primaryKeyId = IGRoomMessage.generatePrimaryKey(messageID: igpMessage.igpMessageId, roomID: roomId, isForward: isForward, isReply: isReply)
        self.messageVersion = igpMessage.igpMessageVersion
        self.isDeleted = igpMessage.igpDeleted
        
        if igpMessage.hasIgpStatus {
            switch igpMessage.igpStatus {
            case .failed:
                self.status = .failed
            case .sending:
                self.status = .sending
            case .sent:
                self.status = .sent
            case .delivered:
                self.status = .delivered
            case .seen:
                self.status = .seen
            }
        }
        if igpMessage.hasIgpStatusVersion {
            self.statusVersion = igpMessage.igpStatusVersion
        }
        if igpMessage.hasIgpMessageType {
            self.type = IGRoomMessageType.unknown.fromIGP(igpMessage.igpMessageType)
        }
        if igpMessage.hasIgpMessage {
            self.message = igpMessage.igpMessage
        }
        if igpMessage.hasIgpAttachment {
            let predicate = NSPredicate(format: "cacheID = %@", igpMessage.igpAttachment.igpCacheId)
            let realm = try! Realm()
            if let fileInDb = realm.objects(IGFile.self).filter(predicate).first {
                self.attachment = fileInDb
            } else {
                self.attachment = IGFile(igpFile: igpMessage.igpAttachment, messageType: self.type)
            }
            if self.attachment?.fileNameOnDisk == nil {
                self.attachment!.downloadUploadPercent = 0.0
                self.attachment!.status = .readyToDownload
            } else {
                self.attachment!.downloadUploadPercent = 1.0
                self.attachment!.status = .ready
            }
        }
        if igpMessage.hasIgpAuthor {
            if let author = igpMessage.igpAuthor {
                if author.hasIgpHash {
                    self.authorHash = author.igpHash
                }
                if let authorUser = author.igpUser {
                    //read realm for existing user
                    let predicate = NSPredicate(format: "id = %d", authorUser.igpUserId)
                    let realm = try! Realm()
                    if let userInDb = realm.objects(IGRegisteredUser.self).filter(predicate).first {
                        self.authorUser = userInDb
                        self.authorRoom = nil
                    } else {
                        //if your code reaches here there is something wrong
                        //you MUST fetch all dependecies befor performing any action
                    }
                } else if let authorRoom = author.igpRoom {
                    //read realm for existing room
                    let predicate = NSPredicate(format: "id = %d", authorRoom.igpRoomId)
                    let realm = try! Realm()
                    if let roomInDb = realm.objects(IGRoom.self).filter(predicate).first {
                        self.authorRoom = roomInDb
                        self.authorUser = nil
                    } else {
                        //if your code reaches here there is something wrong
                        //you MUST fetch all dependecies befor performing any action
                    }
                }
            }
        }
        if igpMessage.hasIgpLocation {
            let predicate = NSPredicate(format: "id = %@", self.primaryKeyId!)
            let realm = try! Realm()
            if let locaitonInDb = realm.objects(IGRoomMessageLocation.self).filter(predicate).first {
                self.location = locaitonInDb
            } else {
                self.location = IGRoomMessageLocation(igpRoomMessageLocation: igpMessage.igpLocation, for: self)
            }
        }
        if igpMessage.hasIgpLog {
            //TODO: check if using self.primaryKeyId is good
            //otherwise use a combinatoin of id and room
            let predicate = NSPredicate(format: "id = %@", self.primaryKeyId!)
            let realm = try! Realm()
            if let logInDb = realm.objects(IGRoomMessageLog.self).filter(predicate).first {
                self.log = logInDb
            } else {
                self.log = IGRoomMessageLog(igpRoomMessageLog: igpMessage.igpLog, for: self)
            }
        }
        if igpMessage.hasIgpContact {
            let predicate = NSPredicate(format: "id = %@", self.primaryKeyId!)
            let realm = try! Realm()
            if let contactInDb = realm.objects(IGRoomMessageContact.self).filter(predicate).first {
                self.contact = contactInDb
            } else {
                self.contact = IGRoomMessageContact(igpRoomMessageContact: igpMessage.igpContact, for: self)
            }
        }
        if igpMessage.hasIgpEdited {
            self.isEdited = igpMessage.igpEdited
        }
        if igpMessage.hasIgpCreateTime {
            self.creationTime = Date(timeIntervalSince1970: TimeInterval(igpMessage.igpCreateTime))
        }
        if igpMessage.hasIgpUpdateTime {
            self.updateTime = Date(timeIntervalSince1970: TimeInterval(igpMessage.igpUpdateTime))
        }
        if igpMessage.hasIgpForwardFrom {
            if igpMessage.igpForwardFrom.igpAuthor.hasIgpRoom {
                print("fount that shit")
            }
            self.forwardedFrom = IGRoomMessage(igpMessage: igpMessage.igpForwardFrom, roomId: roomId, isForward: true)
        }
        if igpMessage.hasIgpReplyTo {
            self.repliedTo = IGRoomMessage(igpMessage: igpMessage.igpReplyTo, roomId: roomId, isReply: true)
        }
        if igpMessage.hasIgpPreviousMessageId {
            self.previuosMessageUID = igpMessage.igpPreviousMessageId
        }
    }
    
    //used when sending a message
    convenience init(body: String) {
        self.init()
        self.isDeleted = false
        if body != "" {
            self.message = body
        } else {
            self.message = nil
        }
        self.creationTime = Date()
        self.status = IGRoomMessageStatus.sending
        self.temporaryId = IGGlobal.randomString(length: 64)
        self.primaryKeyId = IGGlobal.randomString(length: 64)
        let predicate = NSPredicate(format: "id = %d", IGAppManager.sharedManager.userID()!)
        let realm = try! Realm()
        if let userInDb = realm.objects(IGRegisteredUser.self).filter(predicate).first {
            self.authorUser = userInDb
        }
        self.authorHash = IGAppManager.sharedManager.authorHash()
    }
    
    class func generatePrimaryKey(messageID: Int64, roomID: Int64, isForward: Bool = false, isReply: Bool = false) -> String {
        var prefix = ""
        if isForward {
            prefix = "F_"
        } else if isReply {
            prefix = "R_"
        }
        return "\(prefix)\(messageID)_\(roomID)"
    }
    
    //detach from current realm
    func detach() -> IGRoomMessage {
        let detachedMessage = IGRoomMessage(value: self)
        
        if let author = self.authorUser {
            let detachedAuthor = author.detach()
            detachedMessage.authorUser = detachedAuthor
        }
        if let author = self.authorRoom {
            let detachedAuthor = author.detach()
            detachedMessage.authorRoom = detachedAuthor
        }
        if let attach = self.attachment {
            let detachedAttachment = attach.detach()
            detachedMessage.attachment = detachedAttachment
        }
        if let forwardedFrom = self.forwardedFrom {
            let detachedForwarded = forwardedFrom.detach()
            detachedMessage.forwardedFrom = detachedForwarded
        }
        if let reply = self.repliedTo {
            let detachedReply = reply.detach()
            detachedMessage.repliedTo = detachedReply
        }
        if let log = self.log {
            let detachedLog = log.detach()
            detachedMessage.log = detachedLog
        }
        if let contact = self.contact {
            let detachedContact = contact.detach()
            detachedMessage.contact = detachedContact
        }
        if let location = self.location {
            let detachedLocation = location.detach()
            detachedMessage.location = detachedLocation
        }
        
        return detachedMessage
    }
}
