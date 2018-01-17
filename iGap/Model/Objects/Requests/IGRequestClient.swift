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
import IGProtoBuff
import SwiftProtobuf

class IGClientConditionRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(clientCondition:IGClientCondition) -> IGRequestWrapper {
            var clientConditionRequestMessage = IGPClientCondition()
            var rooms = Array<IGPClientCondition.IGPRoom>()
            for ccRoom in clientCondition.rooms {
                var room = IGPClientCondition.IGPRoom()
                room.igpRoomID = ccRoom.id
                room.igpClearID = ccRoom.clearId
                room.igpCacheEndID = ccRoom.cacheEndId
                room.igpCacheStartID = ccRoom.cacheStartId
                room.igpDeleteVersion = ccRoom.deleteVersion
                room.igpStatusVersion = ccRoom.statusVersion
                room.igpMessageVersion = ccRoom.messageVersion
                //room.igpOfflineMute(<#T##value: IGPClientCondition.IGPRoom.IGPOfflineMute##IGPClientCondition.IGPRoom.IGPOfflineMute#>)
                //room.igpOfflineSeen(<#T##value: Array<Int64>##Array<Int64>#>)
                //room.igpOfflineEdited(<#T##value: Array<IGPClientCondition.IGPRoom.IGPOfflineEdited>##Array<IGPClientCondition.IGPRoom.IGPOfflineEdited>#>)
                //room.igpOfflineDeleted(<#T##value: Array<Int64>##Array<Int64>#>)
                rooms.append(room)
            }
            clientConditionRequestMessage.igpRooms = rooms
            return IGRequestWrapper(message: clientConditionRequestMessage, actionID: 600)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPClientConditionResponse) {
            
        }
        override class func handlePush(responseProtoMessage: Message) {}
    }
}


class IGClientGetRoomListRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(offset: Int32, limit: Int32) -> IGRequestWrapper {
            var clientGetRoomListRequestMessage = IGPClientGetRoomList()
            var pagination = IGPPagination()
            pagination.igpLimit = limit
            pagination.igpOffset = offset
            clientGetRoomListRequestMessage.igpPagination = pagination
            return IGRequestWrapper(message: clientGetRoomListRequestMessage, actionID: 601)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPClientGetRoomListResponse) -> Int {
            let igpRooms: Array<IGPRoom> = responseProtoMessage.igpRooms
            IGFactory.shared.saveRoomsToDatabase(igpRooms, ignoreLastMessage: false)
            return igpRooms.count
        }
        override class func handlePush(responseProtoMessage: Message) {}
    }
}


class IGClientGetRoomRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(roomId: Int64) -> IGRequestWrapper {
            var clientGetRoomRequestMessage = IGPClientGetRoom()
            clientGetRoomRequestMessage.igpRoomID = roomId
            return IGRequestWrapper(message: clientGetRoomRequestMessage, actionID: 602)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPClientGetRoomResponse) {
            let igpRoom = responseProtoMessage.igpRoom
            
            IGFactory.shared.saveRoomsToDatabase([igpRoom], ignoreLastMessage: true)
        }
        override class func handlePush(responseProtoMessage: Message) {}
    }
}


class IGClientGetRoomHistoryRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(roomID: Int64, firstMessageID: Int64?) -> IGRequestWrapper {
            var getRoomHistoryRequestMessage = IGPClientGetRoomHistory()
            getRoomHistoryRequestMessage.igpRoomID = roomID
            if let firstMessageID = firstMessageID {
                getRoomHistoryRequestMessage.igpFirstMessageID = firstMessageID
            } else {
                getRoomHistoryRequestMessage.igpFirstMessageID = Int64(0)
            }
            return IGRequestWrapper(message: getRoomHistoryRequestMessage, actionID: 603)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPClientGetRoomHistoryResponse, roomId: Int64) { //-> [IGRoomMessage]{
            IGFactory.shared.saveIgpMessagesToDatabase(responseProtoMessage.igpMessage, for: roomId, updateLastMessage: false , isFromSharedMedia: false)
            
//            var messages = [IGRoomMessage]()
//            for igpMessage in responseProtoMessage.igpMessage {
//                if !igpMessage.igpDeleted {
//                    let message = IGRoomMessage(igpMessage: igpMessage)
//                    messages.append(message)
//                }
//            }
//            return messages
        }
        
        
        override class func handlePush(responseProtoMessage: Message) {}
    }
}
class IGClientSearchRoomHistoryRequest : IGRequest {
    class Generator : IGRequest.Generator {
        class func generate(roomId: Int64, offset : Int32 , filter : IGSharedMediaFilter ) -> IGRequestWrapper {
            var clientSearchRoomHistoryRequestMessage = IGPClientSearchRoomHistory()
            clientSearchRoomHistoryRequestMessage.igpRoomID = roomId
            clientSearchRoomHistoryRequestMessage.igpOffset = offset
            switch filter {
            case .audio:
                clientSearchRoomHistoryRequestMessage.igpFilter = .audio
                break
            case .image:
                clientSearchRoomHistoryRequestMessage.igpFilter = .image
                break
            case .file:
                clientSearchRoomHistoryRequestMessage.igpFilter = .file
                break
            case .gif:
                clientSearchRoomHistoryRequestMessage.igpFilter = .gif
                break
            case .url:
                clientSearchRoomHistoryRequestMessage.igpFilter = .url
                break
            case .video:
                clientSearchRoomHistoryRequestMessage.igpFilter = .video
                break
            case .voice:
                clientSearchRoomHistoryRequestMessage.igpFilter = .voice
            }
            return IGRequestWrapper(message: clientSearchRoomHistoryRequestMessage, actionID: 605)
            
        }
    }
    class Handler : IGRequest.Handler {
        class func interpret(response responseProtoMessage:IGPClientSearchRoomHistoryResponse , roomId: Int64) -> (totlaCount: Int32 , NotDeletedCount: Int32 , messages: [IGPRoomMessage] ) {
            let totalCount = responseProtoMessage.igpTotalCount
            let notDeletedCount = responseProtoMessage.igpNotDeletedCount
            let igpMessages = responseProtoMessage.igpResult
            IGFactory.shared.saveIgpMessagesToDatabase(igpMessages, for: roomId, updateLastMessage: false, isFromSharedMedia: true)
            return (totlaCount: totalCount , NotDeletedCount: notDeletedCount , messages: igpMessages)
            
        }
        override class func handlePush(responseProtoMessage: Message) {}

        
    }
}
class IGClientResolveUsernameRequest: IGRequest {
    class Generator: IGRequest.Generator {
        class func generate(username: String) -> IGRequestWrapper {
            var clientResolveUsernameRequestMessage = IGPClientResolveUsername()
            clientResolveUsernameRequestMessage.igpUsername = username
            return IGRequestWrapper(message: clientResolveUsernameRequestMessage, actionID: 606)
        }
    }
    class Handler: IGRequest.Handler {
        class func interpret(response responseProtoMessage: IGPClientResolveUsernameResponse) -> (clientResolveUsernametype : IGClientResolveUsernameType , user: IGRegisteredUser? , room: IGRoom?) {
            var igRoom: IGRoom?
            var igUser: IGRegisteredUser?
            let igpclientUsernameType = responseProtoMessage.igpType
            let userClientType : IGClientResolveUsernameType
            switch igpclientUsernameType {
            case .room:
                userClientType = .room
            case .user:
                userClientType = .user
            case .UNRECOGNIZED(_):
                userClientType = .user
            }
            if responseProtoMessage.hasIgpUser {
                igUser = IGRegisteredUser(igpUser: responseProtoMessage.igpUser)
            }
            if responseProtoMessage.hasIgpRoom {
                igRoom = IGRoom(igpRoom: responseProtoMessage.igpRoom)
                IGFactory.shared.saveRoomToDatabase(responseProtoMessage.igpRoom, isParticipant: nil)
            }
            return (clientResolveUsernametype : userClientType , user: igUser , room: igRoom)
        }
    }
}

class IGClinetCheckInviteLinkRequest: IGRequest {
    class Generator: IGRequest.Generator {
        class func generate(invitedToken: String) -> IGRequestWrapper {
            var clientCheckInvitedLinkRequest = IGPClientCheckInviteLink()
            clientCheckInvitedLinkRequest.igpInviteToken = invitedToken
            return IGRequestWrapper(message: clientCheckInvitedLinkRequest, actionID: 607)
        }
    }
    class Handler: IGRequest.Handler {
        class func interpret( response responseProtoMessage : IGPClientCheckInviteLinkResponse) -> IGRoom {
            let igpRoom = responseProtoMessage.igpRoom
            let room = IGRoom(igpRoom: igpRoom)
            return room
        }
        override class func handlePush(responseProtoMessage: Message) {}
    }
    
}
    


class IGClientJoinByInviteLinkRequest: IGRequest {
    class Generator: IGRequest.Generator {
        class func generate(invitedToken: String) -> IGRequestWrapper {
            var clientJoinByInviteLinkMessage = IGPClientJoinByInviteLink()
            clientJoinByInviteLinkMessage.igpInviteToken = invitedToken
            return IGRequestWrapper(message: clientJoinByInviteLinkMessage, actionID: 608)
        }
    }
    class Handler: IGRequest.Handler {
        class func interpret( response responseProtoMessage : IGPClientJoinByInviteLinkResponse) {
            
        }
        override class func handlePush(responseProtoMessage: Message) {}
    }
}

class IGClientJoinByUsernameRequest: IGRequest {
    class Generator: IGRequest.Generator {
        class func generate(userName: String) -> IGRequestWrapper {
            var clientJoinByUsernameRequestMessage = IGPClientJoinByUsername()
            clientJoinByUsernameRequestMessage.igpUsername = userName
            return IGRequestWrapper(message: clientJoinByUsernameRequestMessage, actionID: 609)
        }
    }
    class Handler: IGRequest.Handler {
        class func interpret( response responseProtoMessage : IGPClientJoinByUsernameResponse) {
        }
         override class func handlePush(responseProtoMessage: Message) {}
    }
}

class IGClientCountRoomHistoryRequest: IGRequest {
    class Generator: IGRequest.Generator {
        class func generate(roomID: Int64) -> IGRequestWrapper {
            var clientCountRoomHistoryRequestMessage = IGPClientCountRoomHistory()
            clientCountRoomHistoryRequestMessage.igpRoomID = roomID
            return IGRequestWrapper(message: clientCountRoomHistoryRequestMessage, actionID: 613)
            
        }
    }
    class Handler: IGRequest.Handler {
        class func interpret( response responseProtoMessage : IGPClientCountRoomHistoryResponse) -> (media: Int32 , image: Int32 , video: Int32 , gif: Int32 , voice: Int32 , file: Int32 , audio: Int32, url: Int32 ) {
            let mediaCount = responseProtoMessage.igpMedia
            let imageCount = responseProtoMessage.igpImage
            let videoCount = responseProtoMessage.igpVideo
            let audioCount = responseProtoMessage.igpAudio
            let voiceCount = responseProtoMessage.igpVoice
            let gifCount = responseProtoMessage.igpGif
            let fileCount = responseProtoMessage.igpFile
            let urlCount = responseProtoMessage.igpURL
            
            return (media: mediaCount , image: imageCount , video: videoCount , gif: gifCount , voice: voiceCount , file: fileCount , audio: audioCount, url: urlCount )
            
            
        }
        override class func handlePush(responseProtoMessage: Message) {}
    }
    
}

class IGClientMuteRoomRequest: IGRequest {
    class Generator: IGRequest.Generator {
        class func generate(roomId: Int64, roomMute: IGRoom.IGRoomMute) -> IGRequestWrapper {
            var mute: IGPRoomMute = IGPRoomMute.unmute
            if roomMute == IGRoom.IGRoomMute.mute {
                mute = IGPRoomMute.mute
            }

            var clientMuteRoom = IGPClientMuteRoom()
            clientMuteRoom.igpRoomID = roomId
            clientMuteRoom.igpRoomMute = mute
            return IGRequestWrapper(message: clientMuteRoom, actionID: 614)
        }
    }
    class Handler: IGRequest.Handler {
        class func interpret(response responseProtoMessage: IGPClientMuteRoomResponse) {
            var muteState: IGRoom.IGRoomMute = IGRoom.IGRoomMute.unmute
            if responseProtoMessage.igpRoomMute == IGPRoomMute.mute {
                muteState = .mute
            }
            IGFactory.shared.muteRoom(roomId: responseProtoMessage.igpRoomID, roomMute: muteState)
        }
        
        override class func handlePush(responseProtoMessage: Message) {
            if let message = responseProtoMessage as? IGPClientMuteRoomResponse {
                self.interpret(response: message)
            }
        }
    }
    
}

class IGClientPinRoomRequest: IGRequest {
    class Generator: IGRequest.Generator {
        class func generate(roomId: Int64, pin: Bool) -> IGRequestWrapper {
            var clientPin = IGPClientPinRoom()
            clientPin.igpRoomID = roomId
            clientPin.igpPin = pin
            return IGRequestWrapper(message: clientPin, actionID: 615)
            
        }
    }
    class Handler: IGRequest.Handler {
        class func interpret( response responseProtoMessage : IGPClientPinRoomResponse)  {
            IGFactory.shared.pinRoom(roomId: responseProtoMessage.igpRoomID, pinId: responseProtoMessage.igpPinID)
        }
        override class func handlePush(responseProtoMessage: Message) {
            if let messsage = responseProtoMessage as? IGPClientPinRoomResponse {
                self.interpret(response: messsage)
            }
        }
    }
    
}

class IGClientRoomReportRequest: IGRequest {
    class Generator: IGRequest.Generator {
        class func generate(roomId: Int64, messageId: Int64 = 0 ,reason: IGPClientRoomReport.IGPReason, description: String = "") -> IGRequestWrapper {
            var clientRoomReportResponse = IGPClientRoomReport()
            clientRoomReportResponse.igpRoomID = roomId
            clientRoomReportResponse.igpMessageID = messageId
            clientRoomReportResponse.igpReason = reason
            if reason == IGPClientRoomReport.IGPReason.other {
                clientRoomReportResponse.igpDescription = description
            }
            return IGRequestWrapper(message: clientRoomReportResponse, actionID: 616)
        }
    }
    class Handler: IGRequest.Handler {
        class func interpret( response responseProtoMessage : IGPClientRoomReportResponse) {
        }
        
        override class func handlePush(responseProtoMessage: Message) {
        }
    }
}


