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

class IGChannelCreateRequest : IGRequest {
    class Generator : IGRequest.Generator {
        class func generate(name: String, description: String?) -> IGRequestWrapper {
            let channelCreateRequestBuilder = IGPChannelCreate.Builder()
            channelCreateRequestBuilder.setIgpName(name)
            if description != nil {
                channelCreateRequestBuilder.setIgpDescription(description!)
            }
            return IGRequestWrapper(messageBuilder: channelCreateRequestBuilder, actionID: 400)
        }
    }
    class Handler : IGRequest.Handler {
        class func interpret(response responseProtoMessage:IGPChannelCreateResponse) ->(String) {
            let invitedLink = responseProtoMessage.igpInviteLink
            
            return (invitedLink: invitedLink ) as! (String)
        }
        
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {
            switch responseProtoMessage {
            case let channelCreateResponse as IGPChannelCreateResponse:
                self.interpret(response: channelCreateResponse)
            default:
                break
            }
        }
        override class func error() {}
        override class func timeout() {}
    }
}

class IGChannelAddMemberRequest : IGRequest {
    class Generator : IGRequest.Generator{
        //action id = 401
        class func generate(userID: Int64, channel: IGRoom) -> IGRequestWrapper {
            let channelAddMemberRequestBuilder = IGPChannelAddMember.Builder()
            let channelMemberBuilder = IGPChannelAddMember.IGPMember.Builder()
            channelMemberBuilder.setIgpUserId(userID)
            let memberBuild = try! channelMemberBuilder.build()
            channelAddMemberRequestBuilder.setIgpRoomId(channel.id)
            channelAddMemberRequestBuilder.setIgpMember(memberBuild)
            return IGRequestWrapper(messageBuilder: channelAddMemberRequestBuilder, actionID: 401)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPChannelAddMemberResponse) -> (userID: Int64, roomID: Int64,role: IGChannelMember.IGRole) {
            let igpUserId = responseProtoMessage.igpUserId
            let igpRoomId = responseProtoMessage.igpRoomId
            let igpRoleInchannel = responseProtoMessage.igpRole
            
            var roleInchannel: IGChannelMember.IGRole = .member
            switch igpRoleInchannel {
            case .admin:
                roleInchannel = .admin
            case .member:
                roleInchannel = .member
            case .moderator:
                roleInchannel = .moderator
            case .owner:
                roleInchannel = .owner
            }
            IGFactory.shared.addChannelMemberToDatabase(memberId: igpUserId, memberRole: roleInchannel, roomId: igpRoomId)
            return(userID: igpUserId, roomID: igpRoomId, role: roleInchannel)
        }
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {
            switch responseProtoMessage {
            case let channelAddmemberResponse as IGPChannelAddMemberResponse:
                self.interpret(response: channelAddmemberResponse)
            default:
                break
            }
        }
        override class func error() {}
        override class func timeout() {}
    }
}

class IGChannelAddAdminRequest : IGRequest {
    class Generator : IGRequest.Generator {
        class func generate (roomID: Int64 , memberID : Int64) -> IGRequestWrapper {
            let channelAddAdminRequestBuilder = IGPChannelAddAdmin.Builder()
            channelAddAdminRequestBuilder.setIgpRoomId(roomID)
            channelAddAdminRequestBuilder.setIgpMemberId(memberID)
            return IGRequestWrapper(messageBuilder: channelAddAdminRequestBuilder, actionID: 402)
        }
    }
    
    class Handler : IGRequest.Handler {
        class func interpret(response responseProtoMessage:IGPChannelAddAdminResponse , memberRole: IGChannelMember.IGRole ) -> (roomId: Int64 , memberId: Int64) {
            let igpRoomID = responseProtoMessage.igpRoomId
            let igpMemberID = responseProtoMessage.igpMemberId
            IGFactory.shared.addChannelMemberToDatabase(memberId: igpMemberID, memberRole: memberRole, roomId: igpRoomID)
            return (roomId: igpRoomID , memberId: igpMemberID)
        }
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {
        }
    }
    
}

class IGChannelAddModeratorRequest : IGRequest {
    class Generator : IGRequest.Generator {
        class func generate (roomID: Int64 , memberID : Int64) -> IGRequestWrapper {
            let channelAddModeratorRequestBuilder = IGPChannelAddModerator.Builder()
            channelAddModeratorRequestBuilder.setIgpMemberId(memberID)
            channelAddModeratorRequestBuilder.setIgpRoomId(roomID)
            return IGRequestWrapper(messageBuilder: channelAddModeratorRequestBuilder, actionID: 403)
        }
    }
    
    class Handler : IGRequest.Handler {
        class func interpret(response responseProtoMessage: IGPChannelAddModeratorResponse , memberRole : IGChannelMember.IGRole) -> (roomId: Int64 , memberId: Int64) {
            let roomID = responseProtoMessage.igpRoomId
            let memberID = responseProtoMessage.igpMemberId
            IGFactory.shared.addChannelMemberToDatabase(memberId: memberID, memberRole: memberRole, roomId: roomID)
            return (roomId: roomID , memberId: memberID)
        }
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {
        }
    }
}

class IGChannelDeleteRequest: IGRequest {
    class Generator : IGRequest.Generator {
        class func generate(roomID : Int64) -> IGRequestWrapper {
            let channelDeleteRequestBuilder = IGPChannelDelete.Builder()
            channelDeleteRequestBuilder.setIgpRoomId(roomID)
            return IGRequestWrapper(messageBuilder: channelDeleteRequestBuilder, actionID: 404)
        }
    }
    class Handler : IGRequest.Handler {
        class func interpret(response responseProtoMessage: IGPChannelDeleteResponse) -> Int64 {
            let igpRoomId = responseProtoMessage.igpRoomId
            return igpRoomId
        }
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {
        }
    }
}

class IGChannelEditRequest : IGRequest {
    class Generator : IGRequest.Generator {
        class func generate (roomId: Int64 , channelName: String , description: String?) -> IGRequestWrapper {
            let channelEditRequestBuilder = IGPChannelEdit.Builder()
            channelEditRequestBuilder.setIgpName(channelName)
            channelEditRequestBuilder.setIgpRoomId(roomId)
            if description != nil {
            channelEditRequestBuilder.setIgpDescription(description!)
            }
            return IGRequestWrapper(messageBuilder: channelEditRequestBuilder, actionID: 405)
        }
    }
    class Handler : IGRequest.Handler {
        class func interpret(response responseProtoMessage:IGPChannelEditResponse) -> (channelName: String , description : String) {
            let roomID = responseProtoMessage.igpRoomId
            let channelName = responseProtoMessage.igpName
            let channelDescription = responseProtoMessage.igpDescription
            
            IGFactory.shared.editChannelRooms(roomID: roomID, roomName: channelName, roomDescription: channelDescription)
            return (channelName: channelName , description: channelDescription)
        }
         override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {
            switch responseProtoMessage {
            case let channelEditResponse as IGPChannelEditResponse:
                self.interpret(response: channelEditResponse)
            default:
                break
            }

        }
    }
}
class IGChannelKickAdminRequest : IGRequest {
    class Generator: IGRequest.Generator {
        class func generate(roomId: Int64 , memberId: Int64) -> IGRequestWrapper {
            let channelKickAdminRequestBuilder = IGPChannelKickAdmin.Builder()
            channelKickAdminRequestBuilder.setIgpRoomId(roomId)
            channelKickAdminRequestBuilder.setIgpMemberId(memberId)
            return IGRequestWrapper(messageBuilder: channelKickAdminRequestBuilder, actionID: 406)
        }
    }
    class Handler : IGRequest.Handler {
        class func interpret (response responseProtoMessage:IGPChannelKickAdminResponse) -> (roomId: Int64 , memberId: Int64) {
            let igpMemberId = responseProtoMessage.igpMemberId
            let igpRoomId = responseProtoMessage.igpRoomId
            IGFactory.shared.demoatRoleInChannel(roomId: igpRoomId, memberId: igpMemberId)
            return (roomId: igpRoomId , memberId: igpMemberId)
            
        }
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {
            switch responseProtoMessage {
            case let channelKickAdminResoponse as IGPChannelKickAdminResponse:
                self.interpret(response: channelKickAdminResoponse)
            default:
                break
            }
        }
    }
}


class IGChannelKickMemberRequest: IGRequest {
    class Generator : IGRequest.Generator {
        class func generate (roomID: Int64 , memberID: Int64) -> IGRequestWrapper {
            let channelKickMemberRequestBuilder = IGPChannelKickMember.Builder()
            channelKickMemberRequestBuilder.setIgpRoomId(roomID)
            channelKickMemberRequestBuilder.setIgpMemberId(memberID)
            return IGRequestWrapper(messageBuilder: channelKickMemberRequestBuilder, actionID: 407)
        }
    }
    class Handler : IGRequest.Handler {
        class func interpret (response responseProtoMessage:IGPChannelKickMemberResponse) -> (roomId: Int64 , memberId: Int64) {
            let igpRoomId = responseProtoMessage.igpRoomId
            let igpMemberId = responseProtoMessage.igpMemberId
            IGFactory.shared.kickChannelMemberFromDataBase(roomId: igpRoomId, memberId: igpMemberId)
            return(roomId: igpRoomId , memberId: igpMemberId)
        }
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {
            switch responseProtoMessage {
            case let channelKickMemberResoponse as IGPChannelKickMemberResponse:
                self.interpret(response: channelKickMemberResoponse)
            default:
                break
            }
        }
    }
}

class IGChannelKickModeratorRequest : IGRequest {
    class Generator : IGRequest.Generator {
        class func generate(roomID: Int64 , memberID : Int64) -> IGRequestWrapper {
            let channelKickModeratorRequestBuilder = IGPChannelKickModerator.Builder()
            channelKickModeratorRequestBuilder.setIgpMemberId(memberID)
            channelKickModeratorRequestBuilder.setIgpRoomId(roomID)
            return IGRequestWrapper(messageBuilder: channelKickModeratorRequestBuilder, actionID: 408)
        }
    }
    class Handler : IGRequest.Handler {
        class func interpret(response responseProtoMessage:IGPChannelKickModeratorResponse) {
            let igpMemberId = responseProtoMessage.igpMemberId
            let igpRoomId = responseProtoMessage.igpRoomId
            IGFactory.shared.demoatRoleInChannel(roomId: igpRoomId, memberId: igpMemberId)
        }
        
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {
            switch responseProtoMessage {
            case let channelKickModeratorResoponse as IGPChannelKickModeratorResponse:
                self.interpret(response: channelKickModeratorResoponse)
            default:
                break
            }
        }
    }
}

class IGChannelLeftRequest : IGRequest {
    class Generator: IGRequest.Generator {
        class func generate (room: IGRoom) -> IGRequestWrapper {
            let channelLeftRequestBuilder = IGPChannelLeft.Builder()
            channelLeftRequestBuilder.setIgpRoomId(room.id)
            return IGRequestWrapper(messageBuilder: channelLeftRequestBuilder, actionID: 409)
        }
    }
    class Handler : IGRequest.Handler {
        class func interpret(response responseProtoMessage:IGPChannelLeftResponse) {
            let igpRoomId = responseProtoMessage.igpMemberId
            IGFactory.shared.leftRoomInDatabase(roomID: igpRoomId)
        }
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {
            switch responseProtoMessage {
            case let channelLeftResoponse as IGPChannelLeftResponse:
                self.interpret(response: channelLeftResoponse)
            default:
                break
            }
        }
    }
}

class IGChannelSendMessageRequest: IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(message: IGRoomMessage, room: IGRoom, attachmentToken: String?) -> IGRequestWrapper {
            let channelSendMessageRequestBuilder = IGPChannelSendMessage.Builder()
            if let text = message.message {
                channelSendMessageRequestBuilder.setIgpMessage(text)
            }
            
            channelSendMessageRequestBuilder.setIgpRoomId(room.id)
            channelSendMessageRequestBuilder.setIgpMessageType(message.type.toIGP())
            
            if attachmentToken != nil {
                channelSendMessageRequestBuilder.setIgpAttachment(attachmentToken!)
            }
            
            if message.repliedTo != nil {
                channelSendMessageRequestBuilder.igpReplyTo = message.repliedTo!.id
            } else if let forward = message.forwardedFrom {
                let forwardedFrom = IGPRoomMessageForwardFrom.Builder()
                forwardedFrom.setIgpRoomId(forward.roomId)
                forwardedFrom.setIgpMessageId(forward.id)
                try! channelSendMessageRequestBuilder.igpForwardFrom = forwardedFrom.build()
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
                
                try! channelSendMessageRequestBuilder.igpContact = igpContact.build()
            }
            
            return IGRequestWrapper(messageBuilder: channelSendMessageRequestBuilder, actionID: 410)
        }
    }
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPChannelSendMessageResponse) {
            self.handlePush(responseProtoMessage: responseProtoMessage)
        }
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {
            switch responseProtoMessage {
            case let response as IGPChannelSendMessageResponse:
                let messages: [IGPRoomMessage] = [response.igpRoomMessage]
                IGFactory.shared.saveIgpMessagesToDatabase(messages, for: response.igpRoomId, updateLastMessage: true , isFromSharedMedia: false)
            default:
                break
            }
        }
        override class func error() {}
        override class func timeout() {}
    }
}

class IGChannelAddAvatarRequest: IGRequest {
    class Generator : IGRequest.Generator{
        class func generate (attachment: String , roomID: Int64) -> IGRequestWrapper{
            let channelAddAvatarBuilder = IGPChannelAvatarAdd.Builder()
            channelAddAvatarBuilder.setIgpRoomId(roomID)
            channelAddAvatarBuilder.setIgpAttachment(attachment)
            return IGRequestWrapper(messageBuilder: channelAddAvatarBuilder, actionID: 412)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPChannelAvatarAddResponse) {
            IGFactory.shared.updateChannelAvatar(responseProtoMessage.igpRoomId, igpAvatar: responseProtoMessage.igpAvatar)
        }
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {
            switch responseProtoMessage {
            case let channelAvatarResponse as IGPChannelAvatarAddResponse:
                self.interpret(response: channelAvatarResponse)
            default:
                break
            }
        }
        override class func error() {}
        override class func timeout() {}
    }
}


class IGChannelUpdateDraftRequest: IGRequest {
    class Generator : IGRequest.Generator {
        class func generate(draft: IGRoomDraft) -> IGRequestWrapper {
            let igpChannelUpdateDraftBuilder = IGPChannelUpdateDraft.Builder()
            igpChannelUpdateDraftBuilder.setIgpDraft(draft.toIGP())
            igpChannelUpdateDraftBuilder.setIgpRoomId(draft.roomId)
            return IGRequestWrapper(messageBuilder: igpChannelUpdateDraftBuilder, actionID: 415)
        }
    }
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPChannelUpdateDraftResponse) {
            let draft = IGRoomDraft(igpDraft: responseProtoMessage.igpDraft, roomId: responseProtoMessage.igpRoomId)
            IGFactory.shared.save(draft: draft)
        }
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {
            switch responseProtoMessage {
            case let response as IGPChannelUpdateDraftResponse:
                self.interpret(response: response)
            default:
                break
            }
        }
    }
}

class IGChannelGetDraftRequest: IGRequest {
    class Generator : IGRequest.Generator {
        class Generator : IGRequest.Generator{
            class func generate(roomId: Int64) -> IGRequestWrapper {
                let igpChannelGetDraftBuilder = IGPChannelGetDraft.Builder()
                igpChannelGetDraftBuilder.setIgpRoomId(roomId)
                return IGRequestWrapper(messageBuilder: igpChannelGetDraftBuilder, actionID: 416)
            }
        }
    }
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPChannelGetDraftResponse, roomId: Int64) {
            let draft = IGRoomDraft(igpDraft: responseProtoMessage.igpDraft, roomId: roomId)
            IGFactory.shared.save(draft: draft)
        }
    }
}

class IGChannelGetMemberListRequest: IGRequest {
    class Generator : IGRequest.Generator {
        class func generate(room: IGRoom , filterRole: IGRoomFilterRole) -> IGRequestWrapper{
            let channelGetMemberRequestBuilder = IGPChannelGetMemberList.Builder()
            channelGetMemberRequestBuilder.setIgpRoomId(room.id)
            switch filterRole {
            case .all :
                channelGetMemberRequestBuilder.setIgpFilterRole(.all)
            case .admin :
                channelGetMemberRequestBuilder.setIgpFilterRole(.admin)
            case .member:
                 channelGetMemberRequestBuilder.setIgpFilterRole(.member)
            case .moderator:
                 channelGetMemberRequestBuilder.setIgpFilterRole(.moderator)
            }
            return IGRequestWrapper(messageBuilder: channelGetMemberRequestBuilder, actionID: 417)
        }
    }
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPChannelGetMemberListResponse, roomId: Int64) -> [IGPChannelGetMemberListResponse.IGPMember]{
            
            let members = responseProtoMessage.igpMember
            IGFactory.shared.saveChannelMemberListToDataBase(members , roomId: roomId )
            return members
        }
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {
            
        }
    }
    
}

class IGChannelUpdateUsernameRequest : IGRequest {
    class Generator : IGRequest.Generator {
        class func generate(userName: String , room: IGRoom) -> IGRequestWrapper {
            let channelUpdateUsernameRequestBuilder = IGPChannelUpdateUsername.Builder()
            channelUpdateUsernameRequestBuilder.setIgpRoomId(room.id)
            channelUpdateUsernameRequestBuilder.setIgpUsername(userName)
            return IGRequestWrapper(messageBuilder: channelUpdateUsernameRequestBuilder, actionID: 419)
        }

    }
    class Handler : IGRequest.Handler {
        class func interpret(response responseProtoMessage:IGPChannelUpdateUsernameResponse) {
            IGFactory.shared.updateChannelUserName(userName: responseProtoMessage.igpUsername, roomID : responseProtoMessage.igpRoomId)
        }
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {
            switch responseProtoMessage {
            case let response as IGPChannelUpdateUsernameResponse:
                self.interpret(response: response)
            default:
                break
            }
        }
        
        override class func error() {}
        override class func timeout() {}
    }

}

class IGChannelRemoveUsernameRequest: IGRequest {
    class Generator : IGRequest.Generator {
        class func generate(roomID: Int64) -> IGRequestWrapper {
            let channelRemoveUsernameRequestBuilder = IGPChannelRemoveUsername.Builder()
            channelRemoveUsernameRequestBuilder.setIgpRoomId(roomID)
            return IGRequestWrapper(messageBuilder: channelRemoveUsernameRequestBuilder, actionID: 420)
        }
    }
    class Handler : IGRequest.Handler {
        class func interpret(response responseProtoMessage:IGPChannelRemoveUsernameResponse) -> Int64 {
            let igpRoomId = responseProtoMessage.igpRoomId
            IGFactory.shared.romoveChannelUserName(igpRoomId)
            return responseProtoMessage.igpRoomId
        }
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {
            switch responseProtoMessage {
            case let channelRemoveUserName as IGPChannelRemoveUsernameResponse:
                self.interpret(response: channelRemoveUserName)
            default:
                break
            }
        }
    }
}

class IGChannelRevokeLinkRequest : IGRequest {
    class Generator: IGRequest.Generator {
        class func generate(roomId: Int64 ) -> IGRequestWrapper {
            let channelRevokeLinkRequestBuilder = IGPChannelRevokeLink.Builder()
            channelRevokeLinkRequestBuilder.setIgpRoomId(roomId)
            return IGRequestWrapper(messageBuilder: channelRevokeLinkRequestBuilder, actionID: 421)
        }
    }
    class Handler: IGRequest.Handler {
        class func interpret(response responseProtoMessage: IGPChannelRevokeLinkResponse) ->(roomId: Int64 ,invitedLink: String , invitedToken: String ) {
            let igpRoomId = responseProtoMessage.igpRoomId
            let igpInvitedLink = responseProtoMessage.igpInviteLink
            let igpInvitedToken = responseProtoMessage.igpInviteToken
            IGFactory.shared.revokePrivateRoomLink(roomId: igpRoomId , invitedLink: igpInvitedLink , invitedToken: igpInvitedToken)
            return (roomId: igpRoomId ,invitedLink: igpInvitedLink , invitedToken: igpInvitedToken )
        }
        
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {
            switch responseProtoMessage {
            case let channelRevokeLink as IGPChannelRevokeLinkResponse:
                self.interpret(response: channelRevokeLink)
            default:
                break
            }
        }
    }
}

class IGChannelUpdateSignatureRequest : IGRequest {
    class Generator: IGRequest.Generator {
        class func generate (roomId: Int64 , signatureStatus: Bool) -> IGRequestWrapper{
            let channelUpdateSignaturerequestBuilder = IGPChannelUpdateSignature.Builder()
            channelUpdateSignaturerequestBuilder.setIgpRoomId(roomId)
            channelUpdateSignaturerequestBuilder.setIgpSignature(signatureStatus)
            return IGRequestWrapper(messageBuilder: channelUpdateSignaturerequestBuilder, actionID: 422)
        }
    }
    class Handler: IGRequest.Handler {
        class func interpret(response responseProtoMessage: IGPChannelUpdateSignatureResponse) -> (roomId: Int64 , signatureStatus: Bool) {
            let igpRoomId = responseProtoMessage.igpRoomId
            let igpSignatureStatus = responseProtoMessage.igpSignature
            IGFactory.shared.updatChannelRoomSignature( igpRoomId , signatureStatus: igpSignatureStatus)
            return (roomId: igpRoomId , signatureStatus: igpSignatureStatus)
        }
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {
            switch responseProtoMessage {
            case let channelUpdateSignature as IGPChannelUpdateSignatureResponse:
                self.interpret(response: channelUpdateSignature)
            default:
                break
            }
        }
    }
}

class IGChannelGetMessagesStatsRequest: IGRequest {
    class Generator: IGRequest.Generator {
        class func generate(messages:Array<IGRoomMessage>, room: IGRoom) -> IGRequestWrapper {
            let channelGetMessagesStatsRequestBuilder = IGPChannelGetMessagesStats.Builder()
            channelGetMessagesStatsRequestBuilder.setIgpRoomId(room.id)
            var messagesIds = [Int64]()
            for message in messages {
                messagesIds.append(message.id)
            }
            channelGetMessagesStatsRequestBuilder.setIgpMessageId(messagesIds)
            return IGRequestWrapper(messageBuilder: channelGetMessagesStatsRequestBuilder, actionID: 423)
        }
    }
    class Handler: IGRequest.Handler {
        class func interpret(response: IGPChannelGetMessagesStatsResponse) {
            let stats = response.igpStats
            //TODO: perform actions
        }
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {
        }
    }
}



class IGChannelEditMessageRequest: IGRequest {
    class Generator: IGRequest.Generator {
        class func generate(message: IGRoomMessage, newText: String, room: IGRoom) -> IGRequestWrapper {
            let channelEditMessageRequestBuilder = IGPChannelEditMessage.Builder()
            channelEditMessageRequestBuilder.setIgpMessageId(message.id)
            channelEditMessageRequestBuilder.setIgpMessage(newText)
            channelEditMessageRequestBuilder.setIgpRoomId(room.id)
            return IGRequestWrapper(messageBuilder: channelEditMessageRequestBuilder, actionID: 425)
        }
    }
    class Handler: IGRequest.Handler {
        class func interpret(response: IGPChannelEditMessageResponse) {
            IGFactory.shared.editMessage(response.igpMessageId, roomID: response.igpRoomId, message: response.igpMessage, messageType: IGRoomMessageType.unknown.fromIGP(response.igpMessageType), messageVersion: response.igpMessageVersion)
        }
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {
            switch responseProtoMessage {
            case let response as IGPChannelEditMessageResponse:
                self.interpret(response: response)
            default:
                break
            }
        }
    }
}


class IGChannelDeleteMessageRequest: IGRequest {
    class Generator: IGRequest.Generator {
        class func generate(message: IGRoomMessage, room: IGRoom) -> IGRequestWrapper {
            let channelDeleteMessageRequestBuilder = IGPChannelDeleteMessage.Builder()
            channelDeleteMessageRequestBuilder.setIgpMessageId(message.id)
            channelDeleteMessageRequestBuilder.setIgpRoomId(room.id)
            return IGRequestWrapper(messageBuilder: channelDeleteMessageRequestBuilder, actionID: 411)
        }
    }
    class Handler: IGRequest.Handler {
        class func interpret(response: IGPChannelDeleteMessageResponse) {
            IGFactory.shared.setMessageDeleted(response.igpMessageId, roomID: response.igpRoomId, deleteVersion: response.igpDeleteVersion)
        }
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {
            switch responseProtoMessage {
            case let response as IGPChannelDeleteMessageResponse:
                self.interpret(response: response)
            default:
                break
            }
        }
    }
}


