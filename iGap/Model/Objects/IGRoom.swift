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
import UIKit
import IGProtoBuff

class IGRoom: Object {
    enum IGType: Int {
        case chat     = 0
        case group
        case channel
    }
    
    enum IGRoomMute: Int {
        case unmute = 100
        case mute = 101
    }
    
    //properties
    @objc dynamic var id:                 Int64                   = -1
    @objc dynamic var typeRaw:            IGType.RawValue         = IGType.chat.rawValue
    @objc dynamic var title:              String?
    @objc dynamic var initilas:           String?
    @objc dynamic var colorString:        String                  = "FFFFFF"
    @objc dynamic var unreadCount:        Int32                   = 0
    @objc dynamic var isReadOnly:     	  Bool                    = false
    @objc dynamic var isParticipant:  	  Bool                    = false
    @objc dynamic var draft:              IGRoomDraft?
    @objc dynamic var chatRoom:           IGChatRoom?
    @objc dynamic var groupRoom:          IGGroupRoom?
    @objc dynamic var channelRoom:        IGChannelRoom?
    @objc dynamic var lastMessage:        IGRoomMessage?
    @objc dynamic var sortimgTimestamp:   Double                  = 0.0
    @objc dynamic var clearIdString:      String?
    @objc dynamic var muteRoom:           IGRoomMute.RawValue     = IGRoomMute.unmute.rawValue
    @objc dynamic var pinId:              Int64                   = 0
    @objc dynamic var pinMessage:         IGRoomMessage?
    @objc dynamic var deletedPinMessageId:Int64                   = 0
    
    //ignored properties
    var currenctActionsByUsers = Dictionary<String, (IGRegisteredUser, IGClientAction)>() //actorId, action
    
    var type: IGType {
        get {
            if let s = IGType(rawValue: typeRaw) {
                return s
            }
            return .chat
        }
        set {
            typeRaw = newValue.rawValue
        }
    }
    
    var mute: IGRoomMute {
        get {
            if let muteState = IGRoomMute(rawValue: muteRoom) {
                return muteState
            }
            return .unmute
        }
        set {
            muteRoom = newValue.rawValue
        }
    }
    
    var color: UIColor {
        get {
            return UIColor(hexString: colorString)
        }
    }
    var clearId: Int64 {
        get {
            if let clearIdS = clearIdString {
                if let intVal = Int64(clearIdS) {
                    return intVal
                }
                return 0
            }
            return 0
        }
        set {
            clearIdString = "\(newValue)"
        }
    }
    
    //override
    override static func ignoredProperties() -> [String] {
        return ["currenctActionsByUsers", "color", "type", "clearId"]
    }
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    //initilizer
    convenience init(igpRoom: IGPRoom) {
        self.init()
        self.id = igpRoom.igpID
        switch igpRoom.igpType {
        case .chat:
            self.type = .chat
        case .group:
            self.type = .group
        case .channel:
            self.type = .channel
        default:
            break
        }
        
        switch igpRoom.igpRoomMute {
        case .mute:
            self.mute = .mute
        case .unmute:
            self.mute = .unmute
        default:
            break
        }
        
        self.title = igpRoom.igpTitle
        self.initilas = igpRoom.igpInitials
        self.colorString = igpRoom.igpColor
        self.unreadCount = igpRoom.igpUnreadCount
        if igpRoom.hasIgpLastMessage {
            let predicate = NSPredicate(format: "id = %lld AND roomId = %lld", igpRoom.igpLastMessage.igpMessageID, igpRoom.igpID)
            let realm = try! Realm()
            if let messageInDb = realm.objects(IGRoomMessage.self).filter(predicate).first {
                self.lastMessage = IGRoomMessage(value: messageInDb)
                self.sortimgTimestamp = (messageInDb.creationTime?.timeIntervalSinceReferenceDate)!
            } else {
                
            }
        }
        
        self.pinId = igpRoom.igpPinID
        self.isReadOnly = igpRoom.igpReadOnly
        self.isParticipant = igpRoom.igpIsParticipant
        if igpRoom.hasIgpDraft{
            self.draft = IGRoomDraft(igpDraft: igpRoom.igpDraft, roomId: self.id)
        }
        if igpRoom.hasIgpChatRoomExtra {
            self.chatRoom = IGChatRoom(igpChatRoom: igpRoom.igpChatRoomExtra, id: self.id)
        }
        if igpRoom.hasIgpGroupRoomExtra {
            self.groupRoom = IGGroupRoom(igpGroupRoom: igpRoom.igpGroupRoomExtra, id: self.id)
        }
        if igpRoom.hasIgpChannelRoomExtra {
            self.channelRoom = IGChannelRoom(igpChannelRoom: igpRoom.igpChannelRoomExtra, id: self.id)
        }
        
        self.pinMessage = IGRoomMessage(igpMessage: igpRoom.igpPinnedMessage, roomId: igpRoom.igpID)
    }
    
    
    //detach from current realm
    func detach() -> IGRoom {
        let detachedRoom = IGRoom(value: self)
        
        if let lastMessage = self.lastMessage {
            let detachedMessage = lastMessage.detach()
            detachedRoom.lastMessage = detachedMessage
        }
        if let draft = self.draft {
            let detachedDraft = draft.detach()
            detachedRoom.draft = detachedDraft
        }
        if let chatRoom = self.chatRoom {
            let detachedchatRoom = chatRoom.detach()
            detachedRoom.chatRoom = detachedchatRoom
        }
        if let groupRoom = self.groupRoom {
            let detachedGroupRoom = groupRoom.detach()
            detachedRoom.groupRoom = detachedGroupRoom
        }
        if let channelRoom = self.channelRoom {
            let detachedChannelRoom = channelRoom.detach()
            detachedRoom.channelRoom = detachedChannelRoom
        }
        
        return detachedRoom
    }
}


extension IGRoom {
    func setAction(_ action: IGClientAction, id: Int32) {
        switch self.type {
        case .chat:
            IGChatSetActionRequest.Generator.generate(room: self, action: action, actionId: id).success({ (responseProto) in
                
            }).error({ (errorCode, waitTime) in
                
            }).send()
        case .group:
            IGGroupSetActionRequest.Generator.generate(room: self, action: action, actionId: id).success({ (responseProto) in
                
            }).error({ (errorCode, waitTime) in
                
            }).send()
        case .channel:
            break
        }
    }
    
    func currentActionString() -> String {
        if self.currenctActionsByUsers.count == 0 {
            return ""
        }
        
        var string = ""
        var typingUsers          = Array<IGRegisteredUser>()
        var sendingImageUsers    = Array<IGRegisteredUser>()
        var capturingImageUsers  = Array<IGRegisteredUser>()
        var sendingVideoUsers    = Array<IGRegisteredUser>()
        var capturingVideoUsers  = Array<IGRegisteredUser>()
        var sendingAudioUsers    = Array<IGRegisteredUser>()
        var recordingVoiceUsers  = Array<IGRegisteredUser>()
        var sendingVoiceUsers    = Array<IGRegisteredUser>()
        var sendingDocumentUsers = Array<IGRegisteredUser>()
        var sendingGifUsers      = Array<IGRegisteredUser>()
        var sendingFileUsers     = Array<IGRegisteredUser>()
        var sendingLocationUsers = Array<IGRegisteredUser>()
        var choosingContactUsers = Array<IGRegisteredUser>()
        var paintingUsers        = Array<IGRegisteredUser>()
        
        for (_, (user, action)) in self.currenctActionsByUsers {
            switch action {
            case .cancel:
                break
            case .typing:
                typingUsers.append(user)
            case .sendingImage:
                sendingImageUsers.append(user)
            case .capturingImage:
                capturingImageUsers.append(user)
            case .sendingVideo:
                sendingVideoUsers.append(user)
            case .capturingVideo:
                capturingVideoUsers.append(user)
            case .sendingAudio:
                sendingAudioUsers.append(user)
            case .recordingVoice:
                recordingVoiceUsers.append(user)
            case .sendingVoice:
                sendingVoiceUsers.append(user)
            case .sendingDocument:
                sendingDocumentUsers.append(user)
            case .sendingGif:
                sendingGifUsers.append(user)
            case .sendingFile:
                sendingFileUsers.append(user)
            case .sendingLocation:
                sendingLocationUsers.append(user)
            case .choosingContact:
                choosingContactUsers.append(user)
            case .painting:
                paintingUsers.append(user)
            }
        }
        
        if typingUsers.count == 1 {
            string += "\(typingUsers[0].displayName) is typing"
        } else if typingUsers.count == 2{
            string += "\(typingUsers[0].displayName) & \(typingUsers[1].displayName) are typing"
        } else if typingUsers.count > 2 {
            string += "\(typingUsers.count) people are typing"
        }
        
        if sendingImageUsers.count != 0 && string != "" {
            string += ", "
        }
        if sendingImageUsers.count == 1 {
            string += "\(sendingImageUsers[0].displayName) is sending image"
        } else if sendingImageUsers.count == 2{
            string += "\(sendingImageUsers[0].displayName)& \(sendingImageUsers[1].displayName) are sending image"
        } else if sendingImageUsers.count > 2 {
            string += "\(sendingImageUsers.count) people are sending image"
        }
        
        if capturingImageUsers.count != 0 && string != "" {
            string += ", "
        }
        if capturingImageUsers.count == 1 {
            string += "\(capturingImageUsers[0].displayName) is capturing image"
        } else if capturingImageUsers.count == 2{
            string += "\(capturingImageUsers[0].displayName)& \(capturingImageUsers[1].displayName) are capturing image"
        } else if capturingImageUsers.count > 2 {
            string += "\(capturingImageUsers.count) people are capturing image"
        }
        
        if sendingVideoUsers.count != 0 && string != "" {
            string += ", "
        }
        if sendingVideoUsers.count == 1 {
            string += "\(sendingVideoUsers[0].displayName) is sending video"
        } else if sendingVideoUsers.count == 2{
            string += "\(sendingVideoUsers[0].displayName)& \(sendingVideoUsers[1].displayName) are sending video"
        } else if sendingVideoUsers.count > 2 {
            string += "\(sendingVideoUsers.count) people are sending video"
        }
        
        if capturingVideoUsers.count != 0 && string != "" {
            string += ", "
        }
        if capturingVideoUsers.count == 1 {
            string += "\(capturingVideoUsers[0].displayName) is capturing video"
        } else if capturingVideoUsers.count == 2{
            string += "\(capturingVideoUsers[0].displayName)& \(capturingVideoUsers[1].displayName) are capturing video"
        } else if capturingVideoUsers.count > 2 {
            string += "\(capturingVideoUsers.count) people are capturing video"
        }
        
        if sendingAudioUsers.count != 0 && string != "" {
            string += ", "
        }
        if sendingAudioUsers.count == 1 {
            string += "\(sendingAudioUsers[0].displayName) is sending audio"
        } else if sendingAudioUsers.count == 2{
            string += "\(sendingAudioUsers[0].displayName)& \(sendingAudioUsers[1].displayName) are sending audio"
        } else if sendingAudioUsers.count > 2 {
            string += "\(sendingAudioUsers.count) people are sending audio"
        }
        
        if recordingVoiceUsers.count != 0 && string != "" {
            string += ", "
        }
        if recordingVoiceUsers.count == 1 {
            string += "\(recordingVoiceUsers[0].displayName) is recording voice"
        } else if recordingVoiceUsers.count == 2{
            string += "\(recordingVoiceUsers[0].displayName)& \(recordingVoiceUsers[1].displayName) are recording voice"
        } else if recordingVoiceUsers.count > 2 {
            string += "\(recordingVoiceUsers.count) people are recording voice"
        }
        
        if sendingVoiceUsers.count != 0 && string != "" {
            string += ", "
        }
        if sendingVoiceUsers.count == 1 {
            string += "\(sendingVoiceUsers[0].displayName) is sending voice"
        } else if sendingVoiceUsers.count == 2{
            string += "\(sendingVoiceUsers[0].displayName)& \(sendingVoiceUsers[1].displayName) are sending voice"
        } else if sendingVoiceUsers.count > 2 {
            string += "\(sendingVoiceUsers.count) people are sending voice"
        }
        
        if sendingVoiceUsers.count != 0 && string != "" {
            string += ", "
        }
        if sendingDocumentUsers.count == 1 {
            string += "\(sendingDocumentUsers[0].displayName) is sending document"
        } else if sendingDocumentUsers.count == 2{
            string += "\(sendingDocumentUsers[0].displayName)& \(sendingDocumentUsers[1].displayName) are sending document"
        } else if sendingDocumentUsers.count > 2 {
            string += "\(sendingDocumentUsers.count) people are sending document"
        }
        
        if sendingGifUsers.count != 0 && string != "" {
            string += ", "
        }
        if sendingGifUsers.count == 1 {
            string += "\(sendingGifUsers[0].displayName) is sending gif"
        } else if sendingGifUsers.count == 2{
            string += "\(sendingGifUsers[0].displayName)& \(sendingGifUsers[1].displayName) are sending gif"
        } else if sendingGifUsers.count > 2 {
            string += "\(sendingGifUsers.count) people are sending gif"
        }
        
        if sendingFileUsers.count != 0 && string != "" {
            string += ", "
        }
        if sendingFileUsers.count == 1 {
            string += "\(sendingFileUsers[0].displayName) is sending file"
        } else if sendingFileUsers.count == 2{
            string += "\(sendingFileUsers[0].displayName)& \(sendingFileUsers[1].displayName) are sending file"
        } else if sendingFileUsers.count > 2 {
            string += "\(sendingFileUsers.count) people are sending file"
        }
        
        
        if sendingLocationUsers.count != 0 && string != "" {
            string += ", "
        }
        if sendingLocationUsers.count == 1 {
            string += "\(sendingLocationUsers[0].displayName) is sending location"
        } else if sendingLocationUsers.count == 2{
            string += "\(sendingLocationUsers[0].displayName)& \(sendingLocationUsers[1].displayName) are sending location"
        } else if sendingLocationUsers.count > 2 {
            string += "\(sendingLocationUsers.count) people are sending location"
        }
        
        if choosingContactUsers.count != 0 && string != "" {
            string += ", "
        }
        if choosingContactUsers.count == 1 {
            string += "\(choosingContactUsers[0].displayName) is sending contact"
        } else if choosingContactUsers.count == 2{
            string += "\(choosingContactUsers[0].displayName)& \(choosingContactUsers[1].displayName) are sending contact"
        } else if choosingContactUsers.count > 2 {
            string += "\(choosingContactUsers.count) people are sending contact"
        }
        
        if paintingUsers.count != 0 && string != "" {
            string += ", "
        }
        if paintingUsers.count == 1 {
            string += "\(paintingUsers[0].displayName) is painting"
        } else if paintingUsers.count == 2{
            string += "\(paintingUsers[0].displayName)& \(paintingUsers[1].displayName) are painting"
        } else if paintingUsers.count > 2 {
            string += "\(paintingUsers.count) people are painting"
        }
        return string
    }

}



extension IGRoom {
    func saveDraft( _ body: String?, replyToMessage: IGRoomMessage?) {
        let draft = IGRoomDraft(message: body, replyTo: replyToMessage?.id, roomId: self.id)
        IGFactory.shared.save(draft: draft)
        switch self.type {
        case .chat:
            IGChatUpdateDraftRequest.Generator.generate(draft: draft).success({ (responseProto) in
                
            }).error({ (errorCode, waitTime) in
                
            }).send()
        case .group:
            IGGroupUpdateDraftRequest.Generator.generate(draft: draft).success({ (responseProto) in
                
            }).error({ (errorCode, waitTime) in
                
            }).send()
        case .channel:
            IGChannelUpdateDraftRequest.Generator.generate(draft: draft).success({ (responseProto) in
                
            }).error({ (errorCode, waitTime) in
                
            }).send()
        }
    }
}
