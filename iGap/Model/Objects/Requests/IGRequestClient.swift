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
import ProtocolBuffers

class IGClientConditionRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(clientCondition:IGClientCondition) -> IGRequestWrapper {
            let clientConditionRequestBuilder = IGPClientCondition.Builder()
            var rooms = Array<IGPClientCondition.IGPRoom>()
            for ccRoom in clientCondition.rooms {
                let room = IGPClientCondition.IGPRoom.Builder()
                room.setIgpRoomId(ccRoom.id)
                room.setIgpClearId(ccRoom.clearId)
                room.setIgpCacheEndId(ccRoom.cacheEndId)
                room.setIgpCacheStartId(ccRoom.cacheStartId)
                room.setIgpDeleteVersion(ccRoom.deleteVersion)
                room.setIgpStatusVersion(ccRoom.statusVersion)
                room.setIgpMessageVersion(ccRoom.messageVersion)
                //room.setIgpOfflineMute(<#T##value: IGPClientCondition.IGPRoom.IGPOfflineMute##IGPClientCondition.IGPRoom.IGPOfflineMute#>)
                //room.setIgpOfflineSeen(<#T##value: Array<Int64>##Array<Int64>#>)
                //room.setIgpOfflineEdited(<#T##value: Array<IGPClientCondition.IGPRoom.IGPOfflineEdited>##Array<IGPClientCondition.IGPRoom.IGPOfflineEdited>#>)
                //room.setIgpOfflineDeleted(<#T##value: Array<Int64>##Array<Int64>#>)
                let igpRoom = try! room.build()
                rooms.append(igpRoom)
            }
            clientConditionRequestBuilder.setIgpRooms(rooms)
            return IGRequestWrapper(messageBuilder: clientConditionRequestBuilder, actionID: 600)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPClientConditionResponse) {
            
        }
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {}
        override class func error() {}
        override class func timeout() {}
    }
}


class IGClientGetRoomListRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate() -> IGRequestWrapper {
            let clientGetRoomListRequestBuilder = IGPClientGetRoomList.Builder()
            return IGRequestWrapper(messageBuilder: clientGetRoomListRequestBuilder, actionID: 601)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPClientGetRoomListResponse) {
            let igpRooms: Array<IGPRoom> = responseProtoMessage.igpRooms
            IGFactory.shared.saveRoomsToDatabase(igpRooms, ignoreLastMessage: false)
        }
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {}
        override class func error() {}
        override class func timeout() {}
    }
}


class IGClientGetRoomRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(roomId: Int64) -> IGRequestWrapper {
            let clientGetRoomRequestBuilder = IGPClientGetRoom.Builder()
            clientGetRoomRequestBuilder.setIgpRoomId(roomId)
            return IGRequestWrapper(messageBuilder: clientGetRoomRequestBuilder, actionID: 602)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPClientGetRoomResponse) {
            let igpRoom = responseProtoMessage.igpRoom
            if igpRoom?.igpChannelRoomExtra != nil {
                
            }
            IGFactory.shared.saveRoomsToDatabase([igpRoom!], ignoreLastMessage: true)
        }
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {}
        override class func error() {}
        override class func timeout() {}
    }
}


class IGClientGetRoomHistoryRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(roomID: Int64, firstMessageID: Int64?) -> IGRequestWrapper {
            let getRoomHistoryRequestBuilder = IGPClientGetRoomHistory.Builder()
            getRoomHistoryRequestBuilder.setIgpRoomId(roomID)
            if firstMessageID != nil {
                getRoomHistoryRequestBuilder.setIgpFirstMessageId(firstMessageID!)
            } else {
                getRoomHistoryRequestBuilder.setIgpFirstMessageId(Int64(0))
            }
            return IGRequestWrapper(messageBuilder: getRoomHistoryRequestBuilder, actionID: 603)
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
        
        
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {}
        override class func error() {}
        override class func timeout() {}
    }
}
class IGClientSearchRoomHistoryRequest : IGRequest {
    class Generator : IGRequest.Generator {
        class func generate(roomId: Int64, offset : Int32 , filter : IGSharedMediaFilter ) -> IGRequestWrapper {
            let clientSearchRoomHistoryRequestBuilder = IGPClientSearchRoomHistory.Builder()
            clientSearchRoomHistoryRequestBuilder.setIgpRoomId(roomId)
            clientSearchRoomHistoryRequestBuilder.setIgpOffset(offset)
            switch filter {
            case .audio:
                clientSearchRoomHistoryRequestBuilder.setIgpFilter(.audio)
                break
            case .image:
                clientSearchRoomHistoryRequestBuilder.setIgpFilter(.image)
                break
            case .file:
                clientSearchRoomHistoryRequestBuilder.setIgpFilter(.file)
                break
            case .gif:
                clientSearchRoomHistoryRequestBuilder.setIgpFilter(.gif)
                break
            case .url:
                clientSearchRoomHistoryRequestBuilder.setIgpFilter(.url)
                break
            case .video:
                clientSearchRoomHistoryRequestBuilder.setIgpFilter(.video)
                break
            case .voice:
                clientSearchRoomHistoryRequestBuilder.setIgpFilter(.voice)
            }
            return IGRequestWrapper(messageBuilder: clientSearchRoomHistoryRequestBuilder, actionID: 605)
            
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
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {}

        
    }
}
class IGClientResolveUsernameRequest: IGRequest {
    class Generator: IGRequest.Generator {
        class func generate(username: String) -> IGRequestWrapper {
            let clientResolveUsernameRequestBuilder = IGPClientResolveUsername.Builder()
            clientResolveUsernameRequestBuilder.setIgpUsername(username)
            return IGRequestWrapper(messageBuilder: clientResolveUsernameRequestBuilder, actionID: 606)
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
            }
            if responseProtoMessage.hasIgpUser == true {
                igUser = IGRegisteredUser(igpUser: responseProtoMessage.igpUser)
            }
            if responseProtoMessage.hasIgpRoom == true {
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
            let clientCheckInvitedLinkRequest = IGPClientCheckInviteLink.Builder()
            clientCheckInvitedLinkRequest.setIgpInviteToken(invitedToken)
            return IGRequestWrapper(messageBuilder: clientCheckInvitedLinkRequest, actionID: 607)
        }
    }
    class Handler: IGRequest.Handler {
        class func interpret( response responseProtoMessage : IGPClientCheckInviteLinkResponse) -> IGRoom {
            let igpRoom = responseProtoMessage.igpRoom
            let room = IGRoom(igpRoom: igpRoom!)
            return room
        }
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {}
    }
    
}
    


class IGClientJoinByInviteLinkRequest: IGRequest {
    class Generator: IGRequest.Generator {
        class func generate(invitedToken: String) -> IGRequestWrapper {
            let clientJoinByInviteLinkBuilder = IGPClientJoinByInviteLink.Builder()
            clientJoinByInviteLinkBuilder.setIgpInviteToken(invitedToken)
            return IGRequestWrapper(messageBuilder: clientJoinByInviteLinkBuilder, actionID: 608)
        }
    }
    class Handler: IGRequest.Handler {
        class func interpret( response responseProtoMessage : IGPClientJoinByInviteLinkResponse) {
            
        }
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {}
    }
}

class IGClientJoinByUsernameRequest: IGRequest {
    class Generator: IGRequest.Generator {
        class func generate(userName: String) -> IGRequestWrapper {
            let clientJoinByUsernameRequestBuilder = IGPClientJoinByUsername.Builder()
            clientJoinByUsernameRequestBuilder.setIgpUsername(userName)
            return IGRequestWrapper(messageBuilder: clientJoinByUsernameRequestBuilder, actionID: 609)
        }
    }
    class Handler: IGRequest.Handler {
        class func interpret( response responseProtoMessage : IGPClientJoinByUsernameResponse) {
        }
         override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {}
    }
}

class IGClientCountRoomHistoryRequest: IGRequest {
    class Generator: IGRequest.Generator {
        class func generate(roomID: Int64) -> IGRequestWrapper {
            let clientCountRoomHistoryRequestBuilder = IGPClientCountRoomHistory.Builder()
            clientCountRoomHistoryRequestBuilder.setIgpRoomId(roomID)
            return IGRequestWrapper(messageBuilder: clientCountRoomHistoryRequestBuilder, actionID: 613)
            
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
            let urlCount = responseProtoMessage.igpUrl
            
            return (media: mediaCount , image: imageCount , video: videoCount , gif: gifCount , voice: voiceCount , file: fileCount , audio: audioCount, url: urlCount )
            
            
        }
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {}
    }
    
}


