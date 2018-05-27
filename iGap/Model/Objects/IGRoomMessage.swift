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
    @objc dynamic var message:            String?
    @objc dynamic var creationTime:       Date?
    @objc dynamic var updateTime:         Date?
    @objc dynamic var authorHash:         String?
    @objc dynamic var authorUser:         IGRegisteredUser? // When sent in a chat/group
    @objc dynamic var authorRoom:         IGRoom?           // When sent in a channel
    @objc dynamic var attachment:         IGFile?
    @objc dynamic var forwardedFrom:      IGRoomMessage?
    @objc dynamic var repliedTo:          IGRoomMessage?
    @objc dynamic var log:                IGRoomMessageLog?
    @objc dynamic var contact:            IGRoomMessageContact?
    @objc dynamic var location:           IGRoomMessageLocation?
    @objc dynamic var id:                 Int64                           = -1
    @objc dynamic var roomId:             Int64                           = -1
    @objc dynamic var primaryKeyId:       String?
    @objc dynamic var messageVersion:     Int64                           = -1
    @objc dynamic var previuosMessageUID: Int64                           = -1
    @objc dynamic var statusVersion:      Int64                           = -1
    @objc dynamic var deleteVersion:      Int64                           = -1
    @objc dynamic var shouldFetchBefore:  Bool                            = false
    @objc dynamic var shouldFetchAfter:   Bool                            = false
    @objc dynamic var isFirstMessage:     Bool                            = false
    @objc dynamic var isLastMessage:      Bool                            = false
    @objc dynamic var isEdited:           Bool                            = false
    @objc dynamic var isDeleted:          Bool                            = false
    @objc dynamic var pendingSend:        Bool                            = false
    @objc dynamic var pendingDelivered:   Bool                            = false
    @objc dynamic var pendingSeen:        Bool                            = false
    @objc dynamic var pendingEdit:        Bool                            = false
    @objc dynamic var pendingDelete:      Bool                            = false
    @objc dynamic var isFromSharedMedia:  Bool                            = false
    @objc dynamic var typeRaw:            IGRoomMessageType.RawValue      = IGRoomMessageType.unknown.rawValue
    @objc dynamic var statusRaw:          IGRoomMessageStatus.RawValue    = IGRoomMessageStatus.unknown.rawValue
    @objc dynamic var temporaryId:        String?
    @objc dynamic var randomId:           Int64                           = -1

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

    override static func indexedProperties() -> [String] {
        return ["roomId","id"]
    }

    override static func ignoredProperties() -> [String] {
        return ["status", "type"]
    }
    
    override static func primaryKey() -> String {
        return "primaryKeyId"
    }
    
    convenience init(igpMessage: IGPRoomMessage, roomId: Int64, isForward: Bool = false, isReply: Bool = false) {
        self.init()
        self.id = igpMessage.igpMessageID
        if !isForward && !isReply {
            self.roomId = roomId
        }
        self.primaryKeyId = IGRoomMessage.generatePrimaryKey(messageID: igpMessage.igpMessageID, roomID: roomId, isForward: isForward, isReply: isReply)
        self.messageVersion = igpMessage.igpMessageVersion
        self.isDeleted = igpMessage.igpDeleted
        
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
        case .listened:
            self.status = .listened
        default:
            self.status = .unknown
        }
        if igpMessage.igpStatusVersion != 0 {
            self.statusVersion = igpMessage.igpStatusVersion
        }
        self.type = IGRoomMessageType.unknown.fromIGP(igpMessage.igpMessageType)
        self.message = igpMessage.igpMessage
        
        if igpMessage.hasIgpAttachment {
            let predicate = NSPredicate(format: "cacheID = %@", igpMessage.igpAttachment.igpCacheID)
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
            let author = igpMessage.igpAuthor
            if author.igpHash != "" {
                self.authorHash = author.igpHash
            }
            
            if author.hasIgpUser {
                let authorUser = author.igpUser
                //read realm for existing user
                let predicate = NSPredicate(format: "id = %lld", authorUser.igpUserID)
                let realm = try! Realm()
                if let userInDb = realm.objects(IGRegisteredUser.self).filter(predicate).first {
                    self.authorUser = userInDb
                    self.authorRoom = nil
                } else {
                    //if your code reaches here there is something wrong
                    //you MUST fetch all dependecies befor performing any action
                    //assertionFailure()
                }
            } else if author.hasIgpRoom {
                let authorRoom = author.igpRoom
                //read realm for existing room
                let predicate = NSPredicate(format: "id = %lld", authorRoom.igpRoomID)
                let realm = try! Realm()
                if let roomInDb = realm.objects(IGRoom.self).filter(predicate).first {
                    self.authorRoom = roomInDb
                    self.authorUser = nil
                } else {
                    //if your code reaches here there is something wrong
                    //you MUST fetch all dependecies befor performing any action
                    //assertionFailure()
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
        self.isEdited = igpMessage.igpEdited
        self.creationTime = Date(timeIntervalSince1970: TimeInterval(igpMessage.igpCreateTime))
        self.updateTime = Date(timeIntervalSince1970: TimeInterval(igpMessage.igpUpdateTime))
        if igpMessage.hasIgpForwardFrom {
            if igpMessage.igpForwardFrom.igpAuthor.hasIgpRoom {
                print("found that")
            }
            self.forwardedFrom = IGRoomMessage(igpMessage: igpMessage.igpForwardFrom, roomId: roomId, isForward: true)
        }
        if igpMessage.hasIgpReplyTo {
            self.repliedTo = IGRoomMessage(igpMessage: igpMessage.igpReplyTo, roomId: roomId, isReply: true)
        }
        if igpMessage.igpPreviousMessageID != 0 {
            self.previuosMessageUID = igpMessage.igpPreviousMessageID
        }
        
        self.randomId = igpMessage.igpRandomID
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
        self.randomId = IGGlobal.randomId()
        let predicate = NSPredicate(format: "id = %lld", IGAppManager.sharedManager.userID()!)
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
    
    internal static func detectPinMessage(message: IGRoomMessage) -> String{
        
        var messageType = message.type
        if let reply = message.repliedTo {
            messageType = reply.type
        }
        let pinText = "is pinned"
        
        if messageType == .text {
            if let reply = message.repliedTo {
                return "'\(reply.message!)' \(pinText)"
            }
            return "'\(message.message!)' \(pinText)"
        } else if messageType == .image || messageType == .imageAndText {
            return "'image' \(pinText)"
        } else if messageType == .video || messageType == .videoAndText {
            return "'video' \(pinText)"
        } else if messageType == .gif || messageType == .gifAndText {
            return "'gif' \(pinText)"
        } else if messageType == .audio || messageType == .audioAndText {
            return "'audio' \(pinText)"
        } else if messageType == .file || messageType == .fileAndText {
            return "'file' \(pinText)"
        } else if messageType == .contact {
            return "'contact' \(pinText)"
        } else if messageType == .voice {
            return "'voice' \(pinText)"
        } else if messageType == .location {
            return "'location' \(pinText)"
        }
        
        return "'unknown' pinned message"
    }
    
    internal static func detectPinMessageProto(message: IGPRoomMessage) -> String{
        
        var messageType = message.igpMessageType
        let pinText = "is pinned"
        
        if message.hasIgpReplyTo {
           messageType = message.igpReplyTo.igpMessageType
        }
        
        if messageType == .text {
            if message.hasIgpReplyTo {
                return "'\(message.igpReplyTo.igpMessage)' \(pinText)"
            }
            return "'\(message.igpMessage)' \(pinText)"
            
        } else if messageType == .image || messageType == .imageText {
            return "'image' \(pinText)"
        } else if messageType == .video || messageType == .videoText {
            return "'video' \(pinText)"
        } else if messageType == .gif || messageType == .gifText {
            return "'gif' \(pinText)"
        } else if messageType == .audio || messageType == .audioText {
            return "'audio' \(pinText)"
        } else if messageType == .file || messageType == .fileText {
            return "'file' \(pinText)"
        } else if messageType == .contact {
            return "'contact' \(pinText)"
        } else if messageType == .voice {
            return "'voice' \(pinText)"
        } else if messageType == .location {
            return "'location' \(pinText)"
        }
        
        return "'unknown' pinned message"
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
