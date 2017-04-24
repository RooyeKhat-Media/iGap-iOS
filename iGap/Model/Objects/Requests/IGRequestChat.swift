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

class IGChatGetRoomRequest : IGRequest {
    class Generator : IGRequest.Generator{
        //action id = 200
        class func generate(peerId: Int64) -> IGRequestWrapper {
            let chatGetRoomRequestBuilder = IGPChatGetRoom.Builder()
            chatGetRoomRequestBuilder.igpPeerId = peerId
            return IGRequestWrapper(messageBuilder: chatGetRoomRequestBuilder, actionID: 200)
        }
    }
    
    class Handler : IGRequest.Handler{
        @discardableResult
        class func interpret(response responseProtoMessage:IGPChatGetRoomResponse) -> Int64 {
            let igpRoom = (responseProtoMessage.igpRoom)!
            IGFactory.shared.saveRoomsToDatabase([igpRoom], ignoreLastMessage: true)
            return igpRoom.igpId
        }
        
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {
            switch responseProtoMessage {
            case let chatGetRoomResponse as IGPChatGetRoomResponse:
                self.interpret(response: chatGetRoomResponse)
                break
            default:
                break
            }
        }
        
        override class func error() {}
        override class func timeout() {}
    }
}


class IGChatSendMessageRequest : IGRequest {
    class Generator : IGRequest.Generator{
        //action id = 201
        
        class func generate(message: IGRoomMessage, room: IGRoom, attachmentToken: String?) -> IGRequestWrapper {
            let sendMessageRequestBuilder = IGPChatSendMessage.Builder()
            if let text = message.message {
                sendMessageRequestBuilder.setIgpMessage(text)
            }
            
            sendMessageRequestBuilder.setIgpRoomId(room.id)
            switch message.type {
            case .text:
                sendMessageRequestBuilder.setIgpMessageType(.text)
            case .image:
                sendMessageRequestBuilder.setIgpMessageType(.image)
            case .imageAndText:
                sendMessageRequestBuilder.setIgpMessageType(.imageText)
            case .video:
                sendMessageRequestBuilder.setIgpMessageType(.video)
            case .videoAndText:
                sendMessageRequestBuilder.setIgpMessageType(.videoText)
            case .audio:
                sendMessageRequestBuilder.setIgpMessageType(.audio)
            case .audioAndText:
                sendMessageRequestBuilder.setIgpMessageType(.audioText)
            case .voice:
                sendMessageRequestBuilder.setIgpMessageType(.voice)
            case .gif:
                sendMessageRequestBuilder.setIgpMessageType(.gif)
            case .file:
                sendMessageRequestBuilder.setIgpMessageType(.file)
            case .fileAndText:
                sendMessageRequestBuilder.setIgpMessageType(.fileText)
            case .location:
                sendMessageRequestBuilder.setIgpMessageType(.location)
            case .log:
                sendMessageRequestBuilder.setIgpMessageType(.log)
            case .contact:
                sendMessageRequestBuilder.setIgpMessageType(.contact)
            case .gifAndText:
                sendMessageRequestBuilder.setIgpMessageType(.gifText)
            default:
                break
            }
            if attachmentToken != nil {
                sendMessageRequestBuilder.setIgpAttachment(attachmentToken!)
            }
            
            if message.repliedTo != nil {
                sendMessageRequestBuilder.igpReplyTo = message.repliedTo!.id
            } else if let forward = message.forwardedFrom {
                let forwardedFrom = IGPRoomMessageForwardFrom.Builder()
                forwardedFrom.setIgpRoomId(forward.roomId)
                forwardedFrom.setIgpMessageId(forward.id)
                try! sendMessageRequestBuilder.igpForwardFrom = forwardedFrom.build()
            }
            
            if let contact = message.contact {
                let igpContact = IGPRoomMessageContact.Builder()
                if let firstName = contact.firstName {
                    igpContact.setIgpFirstName(firstName)
                }
                if let lastName = contact.lastName {
                    igpContact.setIgpLastName(lastName)
                }
                
                var phones = [String]()
                for phone in contact.phones {
                    phones.append(phone.innerString)
                }
                igpContact.setIgpPhone(phones)
                
                var emails = [String]()
                for email in contact.emails {
                    emails.append(email.innerString)
                }
                igpContact.setIgpEmail(emails)
                
                try! sendMessageRequestBuilder.igpContact = igpContact.build()
            }
            
            return IGRequestWrapper(messageBuilder: sendMessageRequestBuilder, actionID: 201)
//            Request request = 1;
//            RoomMessageType message_type = 2;
//            string attachment = 5;
//            RoomMessageLocation location = 6;
//            RoomMessageLog log = 7;
//            RoomMessageContact contact = 8;
//            int64 reply_to = 9;
//            RoomMessageForwardFrom forward_from = 10;
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPChatSendMessageResponse) {
            self.handlePush(responseProtoMessage: responseProtoMessage)
        }
        
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {
            //pushed IGPRoomMessages are handled here
            switch responseProtoMessage {
            case let response as IGPChatSendMessageResponse:
                let messages: [IGPRoomMessage] = [response.igpRoomMessage]
                IGFactory.shared.saveIgpMessagesToDatabase(messages, for: response.igpRoomId, updateLastMessage: true, isFromSharedMedia: false)
            default:
                break
            }
        }
        override class func error() {}
        override class func timeout() {}
    }
}




class IGChatUpdateStatusRequest : IGRequest {
    class Generator : IGRequest.Generator{
        //action id = 202
        class func generate(roomID: Int64, messageID: Int64, status: IGRoomMessageStatus) -> IGRequestWrapper {
            let updateMessageStatusBuilder = IGPChatUpdateStatus.Builder()
            updateMessageStatusBuilder.setIgpMessageId(messageID)
            updateMessageStatusBuilder.setIgpRoomId(roomID)
            switch status {
            case .delivered:
                updateMessageStatusBuilder.setIgpStatus(.delivered)
            case .seen:
                updateMessageStatusBuilder.setIgpStatus(.seen)
            case .sent:
                updateMessageStatusBuilder.setIgpStatus(.sent)
            default:
                break
            }
            return IGRequestWrapper(messageBuilder: updateMessageStatusBuilder, actionID: 202)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response:IGPChatUpdateStatusResponse) {
            IGFactory.shared.updateMessageStatus(response.igpMessageId, roomID: response.igpRoomId, status: response.igpStatus, statusVersion: response.igpStatusVersion)
        }
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {
            switch responseProtoMessage {
            case let response as IGPChatUpdateStatusResponse:
                self.interpret(response: response)
            default:
                break
            }
        }
        override class func error() {}
        override class func timeout() {}
    }
}

class IGChatEditMessageRequest : IGRequest {
    class Generator : IGRequest.Generator{
        //action id = 203
        class func generate(message: IGRoomMessage, newText: String, room: IGRoom) -> IGRequestWrapper {
            let editMessageRequestBuilder = IGPChatEditMessage.Builder()
            editMessageRequestBuilder.setIgpMessageId(message.id)
            editMessageRequestBuilder.setIgpMessage(newText)
            editMessageRequestBuilder.setIgpRoomId(room.id)
            return IGRequestWrapper(messageBuilder: editMessageRequestBuilder, actionID: 203)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:GeneratedResponseMessage) {
            self.handlePush(responseProtoMessage: responseProtoMessage)
        }
        
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {
            switch responseProtoMessage {
            case let response as IGPChatEditMessageResponse:
                let type = IGRoomMessageType.unknown.fromIGP(response.igpMessageType)
                IGFactory.shared.editMessage(response.igpMessageId, roomID: response.igpRoomId, message: response.igpMessage, messageType: type, messageVersion: response.igpMessageVersion)
            default:
                break
            }
        }
        override class func error() {}
        override class func timeout() {}
    }
}

class IGChatDeleteMessageRequest : IGRequest {
    class Generator : IGRequest.Generator{
        //action id = 204
        class func generate(message: IGRoomMessage, room: IGRoom) -> IGRequestWrapper {
            let deleteMessageRequestBuilder = IGPChatDeleteMessage.Builder()
            deleteMessageRequestBuilder.setIgpMessageId(message.id)
            deleteMessageRequestBuilder.setIgpRoomId(room.id)
            return IGRequestWrapper(messageBuilder: deleteMessageRequestBuilder, actionID: 204)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response: IGPChatDeleteMessageResponse) {
            IGFactory.shared.setMessageDeleted(response.igpMessageId, roomID: response.igpRoomId, deleteVersion: response.igpDeleteVersion)
        }
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {
            switch responseProtoMessage {
            case let response as IGPChatDeleteMessageResponse:
                self.interpret(response: response)
            default:
                break
            }
        }
        override class func error() {}
        override class func timeout() {}
    }
}
class IGChatClearMessageRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(room: IGRoom ) -> IGRequestWrapper {
            let clearMessageRequestBuilder = IGPGroupClearMessage.Builder()
            clearMessageRequestBuilder.setIgpRoomId(room.id)
            if let lastMessageID = room.lastMessage?.id {
            clearMessageRequestBuilder.setIgpClearId(lastMessageID)
            }
            return IGRequestWrapper(messageBuilder: clearMessageRequestBuilder, actionID: 205)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPChatClearMessageResponse) {
            let roomId = responseProtoMessage.igpRoomId
            let clearId = responseProtoMessage.igpClearId
            IGFactory.shared.setClearMessageHistory(roomId, clearID: clearId)
        }
        
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {
            switch responseProtoMessage {
            case let clearHistoryProtoResponse as IGPChatClearMessageResponse:
                self.interpret(response: clearHistoryProtoResponse)
            default:
                break
            }

        }
        override class func error() {}
        override class func timeout() {}
    }
}

class IGChatDeleteRequest: IGRequest {
    class Generator : IGRequest.Generator {
        class func generate(room: IGRoom) -> IGRequestWrapper {
            let chatDeleteRequestBuilder = IGPChatDelete.Builder()
            chatDeleteRequestBuilder.setIgpRoomId(room.id)
            return IGRequestWrapper(messageBuilder: chatDeleteRequestBuilder, actionID: 206)
        }
        
    }
    class Handler : IGRequest.Handler {
        class func interpret(response responseProtoMessage:IGPChatDeleteResponse) {
            let roomId = responseProtoMessage.igpRoomId
            IGFactory.shared.setDeleteRoom(roomID : roomId)
        }
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {
            switch responseProtoMessage {
            case let response as IGPChatDeleteResponse:
                self.interpret(response: response)
                break
            default:
                break
            }
        }
        override class func error() {}
        override class func timeout() {}
    }
    
}

class IGChatUpdateDraftRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(draft: IGRoomDraft) -> IGRequestWrapper {
            let igpChatUpdateDraftBuilder = IGPChatUpdateDraft.Builder()
            igpChatUpdateDraftBuilder.setIgpDraft(draft.toIGP())
            igpChatUpdateDraftBuilder.setIgpRoomId(draft.roomId)
            return IGRequestWrapper(messageBuilder: igpChatUpdateDraftBuilder, actionID: 207)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPChatUpdateDraftResponse) {
            let draft = IGRoomDraft(igpDraft: responseProtoMessage.igpDraft, roomId: responseProtoMessage.igpRoomId)
            IGFactory.shared.save(draft: draft)
        }
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {
            switch responseProtoMessage {
            case let response as IGPChatUpdateDraftResponse:
                self.interpret(response: response)
            default:
                break
            }
        }
        override class func error() {}
        override class func timeout() {}
    }
}

class IGChatGetDraftRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(roomId: Int64) -> IGRequestWrapper {
            let igpChatGetDraftBuilder = IGPChatGetDraft.Builder()
            igpChatGetDraftBuilder.setIgpRoomId(roomId)
            return IGRequestWrapper(messageBuilder: igpChatGetDraftBuilder, actionID: 208)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPChatGetDraftResponse, roomId: Int64) {
            let draft = IGRoomDraft(igpDraft: responseProtoMessage.igpDraft, roomId: roomId)
            IGFactory.shared.save(draft: draft)
        }
        override class func error() {}
        override class func timeout() {}
    }
}

class IGChatConvertToGroupRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(roomId: Int64, name: String, description: String) -> IGRequestWrapper {
            let igpChatConvertToGroupRequetBuilder = IGPChatConvertToGroup.Builder()
            igpChatConvertToGroupRequetBuilder.setIgpRoomId(roomId)
            igpChatConvertToGroupRequetBuilder.setIgpName(name)
            igpChatConvertToGroupRequetBuilder.setIgpDescription(description)
            return IGRequestWrapper(messageBuilder: igpChatConvertToGroupRequetBuilder, actionID: 209)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPChatConvertToGroupResponse) ->(roomId: Int64 , groupName: String , groupDescription: String , groupRole: IGGroupMember.IGRole) {
            var IGRole: IGGroupMember.IGRole
            let igpRoomId = responseProtoMessage.igpRoomId
            let igpGroupName = responseProtoMessage.igpName
            let igpGroupDescription = responseProtoMessage.igpDescription
            let igpGroupRole = responseProtoMessage.igpRole
            switch igpGroupRole {
            case .admin:
                IGRole = .admin
            case .member:
                IGRole = .member
            case .moderator:
                IGRole = .moderator
            case .owner:
                IGRole = .owner           
            }
            IGFactory.shared.convertChatToGroup(roomId: igpRoomId, roomName: igpGroupName , roomRole : IGRole , roomDescription: igpGroupDescription )
            return (roomId: igpRoomId , groupName: igpGroupName , groupDescription: igpGroupDescription , groupRole:IGRole)
        }
    
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {}
        override class func error() {}
        override class func timeout() {}
    }
}

class IGChatSetActionRequest : IGRequest {
    class Generator : IGRequest.Generator{
        //action id = 210
        class func generate(room: IGRoom, action: IGClientAction, actionId: Int32) -> IGRequestWrapper {
            let requestBuilder = IGPChatSetAction.Builder()
            requestBuilder.setIgpRoomId(room.id)
            requestBuilder.setIgpAction(action.toIGP())
            requestBuilder.setIgpActionId(actionId)
            return IGRequestWrapper(messageBuilder: requestBuilder, actionID: 210)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPChatSetActionResponse) {
            
        }
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {
            switch responseProtoMessage {
            case let response as IGPChatSetActionResponse:
                let action = IGClientAction.cancel.fromIGP(response.igpAction)
                IGFactory.shared.setActionForRoom(action: action, userId: response.igpUserId, roomId: response.igpRoomId)
                break
            default:
                break
            }
        }
        override class func error() {}
        override class func timeout() {}
    }
}


