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

class IGChannelCreateRequest : IGRequest {
    class Generator : IGRequest.Generator {
        class func generate(name: String, description: String?) -> IGRequestWrapper {
            var channelCreateRequestMessage = IGPChannelCreate()
            channelCreateRequestMessage.igpName = name
            if let description = description {
                channelCreateRequestMessage.igpDescription = description
            }
            return IGRequestWrapper(message: channelCreateRequestMessage, actionID: 400)
        }
    }
    class Handler : IGRequest.Handler {
        class func interpret(response responseProtoMessage:IGPChannelCreateResponse) ->(String) {
            
            return responseProtoMessage.igpInviteLink
        }
        
        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let channelCreateResponse as IGPChannelCreateResponse:
                _ = self.interpret(response: channelCreateResponse)
            default:
                break
            }
        }
    }
}

class IGChannelAddMemberRequest : IGRequest {
    class Generator : IGRequest.Generator{
        //action id = 401
        class func generate(userID: Int64, channel: IGRoom) -> IGRequestWrapper {
            var channelAddMemberRequestMessage = IGPChannelAddMember()
            var channelMemberMessage = IGPChannelAddMember.IGPMember()
            channelMemberMessage.igpUserID = userID
            //let memberBuild = try! channelMemberBuilder.build()
            channelAddMemberRequestMessage.igpRoomID = channel.id
            channelAddMemberRequestMessage.igpMember = channelMemberMessage
            return IGRequestWrapper(message: channelAddMemberRequestMessage, actionID: 401)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPChannelAddMemberResponse) -> (userID: Int64, roomID: Int64,role: IGChannelMember.IGRole) {
            let igpUserId = responseProtoMessage.igpUserID
            let igpRoomId = responseProtoMessage.igpRoomID
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
            default:
                break
            }
            IGFactory.shared.addChannelMemberToDatabase(memberId: igpUserId, memberRole: roleInchannel, roomId: igpRoomId)
            return(userID: igpUserId, roomID: igpRoomId, role: roleInchannel)
        }
        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let channelAddmemberResponse as IGPChannelAddMemberResponse:
                self.interpret(response: channelAddmemberResponse)
            default:
                break
            }
        }
    }
}

class IGChannelAddAdminRequest : IGRequest {
    class Generator : IGRequest.Generator {
        class func generate (roomID: Int64 , memberID : Int64) -> IGRequestWrapper {
            var channelAddAdminRequestMessage = IGPChannelAddAdmin()
            channelAddAdminRequestMessage.igpRoomID = roomID
            channelAddAdminRequestMessage.igpMemberID = memberID
            return IGRequestWrapper(message: channelAddAdminRequestMessage, actionID: 402)
        }
    }
    
    class Handler : IGRequest.Handler {
        class func interpret(response responseProtoMessage:IGPChannelAddAdminResponse , memberRole: IGChannelMember.IGRole ) -> (roomId: Int64 , memberId: Int64) {
            let igpRoomID = responseProtoMessage.igpRoomID
            let igpMemberID = responseProtoMessage.igpMemberID
            IGFactory.shared.addChannelMemberToDatabase(memberId: igpMemberID, memberRole: memberRole, roomId: igpRoomID)
            return (roomId: igpRoomID , memberId: igpMemberID)
        }
        override class func handlePush(responseProtoMessage: Message) {
            if let channelAddAdminResponse = responseProtoMessage as? IGPChannelAddAdminResponse {
                interpret(response: channelAddAdminResponse, memberRole: .admin)
            }
        }
    }
    
}

class IGChannelAddModeratorRequest : IGRequest {
    class Generator : IGRequest.Generator {
        class func generate (roomID: Int64 , memberID : Int64) -> IGRequestWrapper {
            var channelAddModeratorRequestMessage = IGPChannelAddModerator()
            channelAddModeratorRequestMessage.igpMemberID = memberID
            channelAddModeratorRequestMessage.igpRoomID = roomID
            return IGRequestWrapper(message: channelAddModeratorRequestMessage, actionID: 403)
        }
    }
    
    class Handler : IGRequest.Handler {
        class func interpret(response responseProtoMessage: IGPChannelAddModeratorResponse , memberRole : IGChannelMember.IGRole) -> (roomId: Int64 , memberId: Int64) {
            let roomID = responseProtoMessage.igpRoomID
            let memberID = responseProtoMessage.igpMemberID
            IGFactory.shared.addChannelMemberToDatabase(memberId: memberID, memberRole: memberRole, roomId: roomID)
            return (roomId: roomID , memberId: memberID)
        }
        override class func handlePush(responseProtoMessage: Message) {
            if let channelAddModeratorResponse = responseProtoMessage as? IGPChannelAddModeratorResponse {
                interpret(response: channelAddModeratorResponse, memberRole: .moderator)
            }
        }
    }
}

class IGChannelDeleteRequest: IGRequest {
    class Generator : IGRequest.Generator {
        class func generate(roomID : Int64) -> IGRequestWrapper {
            var channelDeleteRequestMessage = IGPChannelDelete()
            channelDeleteRequestMessage.igpRoomID = roomID
            return IGRequestWrapper(message: channelDeleteRequestMessage, actionID: 404)
        }
    }
    class Handler : IGRequest.Handler {
        class func interpret(response responseProtoMessage: IGPChannelDeleteResponse) -> Int64 {
            let igpRoomId = responseProtoMessage.igpRoomID
            IGFactory.shared.setDeleteRoom(roomID: igpRoomId)
            IGFactory.shared.deleteAllMessages(roomId: igpRoomId)
            return igpRoomId
        }
        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let channelDeleteResponse as IGPChannelDeleteResponse:
                self.interpret(response: channelDeleteResponse)
            default:
                break
            }
        }
    }
}

class IGChannelEditRequest : IGRequest {
    class Generator : IGRequest.Generator {
        class func generate (roomId: Int64 , channelName: String , description: String?) -> IGRequestWrapper {
            var channelEditRequestMessage = IGPChannelEdit()
            channelEditRequestMessage.igpName = channelName
            channelEditRequestMessage.igpRoomID = roomId
            if let description = description {
                channelEditRequestMessage.igpDescription = description
            }
            return IGRequestWrapper(message: channelEditRequestMessage, actionID: 405)
        }
    }
    class Handler : IGRequest.Handler {
        class func interpret(response responseProtoMessage:IGPChannelEditResponse) -> (channelName: String , description : String) {
            let roomID = responseProtoMessage.igpRoomID
            let channelName = responseProtoMessage.igpName
            let channelDescription = responseProtoMessage.igpDescription
            
            IGFactory.shared.editChannelRooms(roomID: roomID, roomName: channelName, roomDescription: channelDescription)
            return (channelName: channelName , description: channelDescription)
        }
         override class func handlePush(responseProtoMessage: Message) {
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
            var channelKickAdminRequestMessage = IGPChannelKickAdmin()
            channelKickAdminRequestMessage.igpRoomID = roomId
            channelKickAdminRequestMessage.igpMemberID = memberId
            return IGRequestWrapper(message: channelKickAdminRequestMessage, actionID: 406)
        }
    }
    class Handler : IGRequest.Handler {
        class func interpret (response responseProtoMessage:IGPChannelKickAdminResponse) -> (roomId: Int64 , memberId: Int64) {
            let igpMemberId = responseProtoMessage.igpMemberID
            let igpRoomId = responseProtoMessage.igpRoomID
            IGFactory.shared.demoteRoleInChannel(roomId: igpRoomId, memberId: igpMemberId)
            return (roomId: igpRoomId , memberId: igpMemberId)
            
        }
        override class func handlePush(responseProtoMessage: Message) {
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
            var channelKickMemberRequestMessage = IGPChannelKickMember()
            channelKickMemberRequestMessage.igpRoomID = roomID
            channelKickMemberRequestMessage.igpMemberID = memberID
            return IGRequestWrapper(message: channelKickMemberRequestMessage, actionID: 407)
        }
    }
    class Handler : IGRequest.Handler {
        class func interpret (response responseProtoMessage:IGPChannelKickMemberResponse) -> (roomId: Int64 , memberId: Int64) {
            let igpRoomId = responseProtoMessage.igpRoomID
            let igpMemberId = responseProtoMessage.igpMemberID
            IGFactory.shared.kickChannelMemberFromDatabase(roomId: igpRoomId, memberId: igpMemberId)
            return(roomId: igpRoomId , memberId: igpMemberId)
        }
        override class func handlePush(responseProtoMessage: Message) {
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
            var channelKickModeratorRequestMessage = IGPChannelKickModerator()
            channelKickModeratorRequestMessage.igpMemberID = memberID
            channelKickModeratorRequestMessage.igpRoomID = roomID
            return IGRequestWrapper(message: channelKickModeratorRequestMessage, actionID: 408)
        }
    }
    class Handler : IGRequest.Handler {
        class func interpret(response responseProtoMessage:IGPChannelKickModeratorResponse) {
            let igpMemberId = responseProtoMessage.igpMemberID
            let igpRoomId = responseProtoMessage.igpRoomID
            IGFactory.shared.demoteRoleInChannel(roomId: igpRoomId, memberId: igpMemberId)
        }
        
        override class func handlePush(responseProtoMessage: Message) {
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
            var channelLeftRequestMessage = IGPChannelLeft()
            channelLeftRequestMessage.igpRoomID = room.id
            return IGRequestWrapper(message: channelLeftRequestMessage, actionID: 409)
        }
    }
    class Handler : IGRequest.Handler {
        class func interpret(response responseProtoMessage:IGPChannelLeftResponse) {
            IGFactory.shared.leftRoomInDatabase(roomID: responseProtoMessage.igpRoomID, memberId: responseProtoMessage.igpMemberID)
        }
        override class func handlePush(responseProtoMessage: Message) {
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
            var channelSendMessageRequestMessage = IGPChannelSendMessage()
            if let text = message.message {
                channelSendMessageRequestMessage.igpMessage = text
            }
            
            channelSendMessageRequestMessage.igpRoomID = room.id
            channelSendMessageRequestMessage.igpMessageType = message.type.toIGP()
            
            if let attachmentToken = attachmentToken {
                channelSendMessageRequestMessage.igpAttachment = attachmentToken
            }
            
            if let repliedTo = message.repliedTo {
                channelSendMessageRequestMessage.igpReplyTo = repliedTo.id
            } else if let forward = message.forwardedFrom {
                var forwardedFrom = IGPRoomMessageForwardFrom()
                forwardedFrom.igpRoomID = forward.roomId
                forwardedFrom.igpMessageID = forward.id
                channelSendMessageRequestMessage.igpForwardFrom = forwardedFrom
            }
            
            if let contact = message.contact {
                var igpContact = IGPRoomMessageContact()
                if let firstName = contact.firstName {
                    igpContact.igpFirstName = firstName
                }
                if let lastName = contact.lastName {
                    igpContact.igpLastName = lastName
                }
                
                var phones = [String]()
                for phone in contact.phones {
                    phones.append(phone.innerString)
                }
                igpContact.igpPhone = phones
                
                var emails = [String]()
                for email in contact.emails {
                    emails.append(email.innerString)
                }
                igpContact.igpEmail = emails
                
                channelSendMessageRequestMessage.igpContact = igpContact
            }
            
            return IGRequestWrapper(message: channelSendMessageRequestMessage, actionID: 410)
        }
    }
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPChannelSendMessageResponse) {
            self.handlePush(responseProtoMessage: responseProtoMessage)
        }
        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let response as IGPChannelSendMessageResponse:
                let messages: [IGPRoomMessage] = [response.igpRoomMessage]
                IGFactory.shared.saveIgpMessagesToDatabase(messages, for: response.igpRoomID, updateLastMessage: true , isFromSharedMedia: false, isFromSendMessage: true)
            default:
                break
            }
        }
    }
}

class IGChannelAddAvatarRequest: IGRequest {
    class Generator : IGRequest.Generator{
        class func generate (attachment: String , roomID: Int64) -> IGRequestWrapper {
            var channelAddAvatarMessage = IGPChannelAvatarAdd()
            channelAddAvatarMessage.igpRoomID = roomID
            channelAddAvatarMessage.igpAttachment = attachment
            return IGRequestWrapper(message: channelAddAvatarMessage, actionID: 412)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPChannelAvatarAddResponse) {
            IGFactory.shared.updateChannelAvatar(responseProtoMessage.igpRoomID, igpAvatar: responseProtoMessage.igpAvatar)
        }
        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let channelAvatarResponse as IGPChannelAvatarAddResponse:
                self.interpret(response: channelAvatarResponse)
            default:
                break
            }
        }
    }
}

class IGChannelAvatarDeleteRequest : IGRequest {
    class Generator : IGRequest.Generator{
        //313
        class func generate(avatarId: Int64, roomId: Int64) -> IGRequestWrapper {
            var channelAvatarDeleteRequestMessage = IGPChannelAvatarDelete()
            channelAvatarDeleteRequestMessage.igpID = avatarId
            channelAvatarDeleteRequestMessage.igpRoomID = roomId
            return IGRequestWrapper(message: channelAvatarDeleteRequestMessage, actionID: 413)
        }
    }
    
    class Handler : IGRequest.Handler {
        class func interpret(response: IGPChannelAvatarDeleteResponse) {
            let roomId = response.igpRoomID
            let avatarId = response.igpID
            //TODO: take action in IGFactory
        }
        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let response as IGPChannelAvatarDeleteResponse:
                self.interpret(response: response)
            default:
                break
            }
        }
    }
}


class IGChannelAvatarGetListRequest : IGRequest {
    class Generator : IGRequest.Generator {
        //414
        class func generate(roomId: Int64) -> IGRequestWrapper {
            var channelAvatarGetListRequestMessage = IGPChannelAvatarGetList()
            channelAvatarGetListRequestMessage.igpRoomID = roomId
            return IGRequestWrapper(message: channelAvatarGetListRequestMessage, actionID: 414)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response: IGPChannelAvatarGetListResponse) -> [IGAvatar] {
            var avatars = [IGAvatar]()
            for igpAvatar in response.igpAvatar {
                let avatar = IGAvatar(igpAvatar: igpAvatar)
                avatars.append(avatar)
            }
            return avatars
        }
    }
}


class IGChannelUpdateDraftRequest: IGRequest {
    class Generator : IGRequest.Generator {
        class func generate(draft: IGRoomDraft) -> IGRequestWrapper {
            var igpChannelUpdateDraftMessage = IGPChannelUpdateDraft()
            igpChannelUpdateDraftMessage.igpDraft = draft.toIGP()
            igpChannelUpdateDraftMessage.igpRoomID = draft.roomId
            return IGRequestWrapper(message: igpChannelUpdateDraftMessage, actionID: 415)
        }
    }
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPChannelUpdateDraftResponse) {
            let draft = IGRoomDraft(igpDraft: responseProtoMessage.igpDraft, roomId: responseProtoMessage.igpRoomID)
            IGFactory.shared.save(draft: draft)
        }
        override class func handlePush(responseProtoMessage: Message) {
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
                var igpChannelGetDraftMessage = IGPChannelGetDraft()
                igpChannelGetDraftMessage.igpRoomID = roomId
                return IGRequestWrapper(message: igpChannelGetDraftMessage, actionID: 416)
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
        class func generate(room: IGRoom, offset: Int32, limit: Int32, filterRole: IGRoomFilterRole) -> IGRequestWrapper {
            var channelGetMemberRequestMessage = IGPChannelGetMemberList()
            channelGetMemberRequestMessage.igpRoomID = room.id
            switch filterRole {
            case .all :
                channelGetMemberRequestMessage.igpFilterRole = .all
            case .admin :
                channelGetMemberRequestMessage.igpFilterRole = .admin
            case .member:
                 channelGetMemberRequestMessage.igpFilterRole = .member
            case .moderator:
                 channelGetMemberRequestMessage.igpFilterRole = .moderator
            default:
                break
            }
            var  pagination = IGPPagination()
            pagination.igpLimit = limit
            pagination.igpOffset = offset
            channelGetMemberRequestMessage.igpPagination = pagination
            return IGRequestWrapper(message: channelGetMemberRequestMessage, actionID: 417)
        }
    }
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPChannelGetMemberListResponse, roomId: Int64) -> [IGPChannelGetMemberListResponse.IGPMember] {
            let members = responseProtoMessage.igpMember
            IGFactory.shared.saveChannelMemberListToDatabase(members, roomId: roomId)
            return members
        }
        override class func handlePush(responseProtoMessage: Message) {
            
        }
    }
}


class IGChannelCheckUsernameRequest : IGRequest {
    class Generator : IGRequest.Generator {
        class func generate(roomId: Int64, username: String) -> IGRequestWrapper {
            var checkUsername = IGPChannelCheckUsername()
            checkUsername.igpRoomID = roomId
            checkUsername.igpUsername = username
            return IGRequestWrapper(message: checkUsername, actionID: 418)
        }
    }
    
    class Handler : IGRequest.Handler {
        override class func handlePush(responseProtoMessage: Message) {
            
        }
    }
}


class IGChannelUpdateUsernameRequest : IGRequest {
    class Generator : IGRequest.Generator {
        class func generate(userName: String , room: IGRoom) -> IGRequestWrapper {
            var channelUpdateUsernameRequestMessage = IGPChannelUpdateUsername()
            channelUpdateUsernameRequestMessage.igpRoomID = room.id
            channelUpdateUsernameRequestMessage.igpUsername = userName
            return IGRequestWrapper(message: channelUpdateUsernameRequestMessage, actionID: 419)
        }
        
        class func generate(roomId: Int64 , username: String) -> IGRequestWrapper {
            var channelUpdateUsernameRequestMessage = IGPChannelUpdateUsername()
            channelUpdateUsernameRequestMessage.igpRoomID = roomId
            channelUpdateUsernameRequestMessage.igpUsername = username
            return IGRequestWrapper(message: channelUpdateUsernameRequestMessage, actionID: 419)
        }

    }
    class Handler : IGRequest.Handler {
        class func interpret(response responseProtoMessage:IGPChannelUpdateUsernameResponse) {
            IGFactory.shared.updateChannelUserName(userName: responseProtoMessage.igpUsername, roomID : responseProtoMessage.igpRoomID)
        }
        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let response as IGPChannelUpdateUsernameResponse:
                self.interpret(response: response)
            default:
                break
            }
        }
    }
}

class IGChannelRemoveUsernameRequest: IGRequest {
    class Generator : IGRequest.Generator {
        class func generate(roomID: Int64) -> IGRequestWrapper {
            var channelRemoveUsernameRequestMessage = IGPChannelRemoveUsername()
            channelRemoveUsernameRequestMessage.igpRoomID = roomID
            return IGRequestWrapper(message: channelRemoveUsernameRequestMessage, actionID: 420)
        }
    }
    class Handler : IGRequest.Handler {
        class func interpret(response responseProtoMessage:IGPChannelRemoveUsernameResponse) -> Int64 {
            let igpRoomId = responseProtoMessage.igpRoomID
            IGFactory.shared.romoveChannelUserName(igpRoomId)
            return responseProtoMessage.igpRoomID
        }
        override class func handlePush(responseProtoMessage: Message) {
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
            var channelRevokeLinkRequestMessage = IGPChannelRevokeLink()
            channelRevokeLinkRequestMessage.igpRoomID = roomId
            return IGRequestWrapper(message: channelRevokeLinkRequestMessage, actionID: 421)
        }
    }
    class Handler: IGRequest.Handler {
        class func interpret(response responseProtoMessage: IGPChannelRevokeLinkResponse) ->(roomId: Int64 ,invitedLink: String , invitedToken: String ) {
            let igpRoomId = responseProtoMessage.igpRoomID
            let igpInvitedLink = responseProtoMessage.igpInviteLink
            let igpInvitedToken = responseProtoMessage.igpInviteToken
            IGFactory.shared.revokePrivateRoomLink(roomId: igpRoomId , invitedLink: igpInvitedLink , invitedToken: igpInvitedToken)
            return (roomId: igpRoomId ,invitedLink: igpInvitedLink , invitedToken: igpInvitedToken )
        }
        
        override class func handlePush(responseProtoMessage: Message) {
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
        class func generate (roomId: Int64 , signatureStatus: Bool) -> IGRequestWrapper {
            var channelUpdateSignaturerequestMessage = IGPChannelUpdateSignature()
            channelUpdateSignaturerequestMessage.igpRoomID = roomId
            channelUpdateSignaturerequestMessage.igpSignature = signatureStatus
            return IGRequestWrapper(message: channelUpdateSignaturerequestMessage, actionID: 422)
        }
    }
    class Handler: IGRequest.Handler {
        class func interpret(response responseProtoMessage: IGPChannelUpdateSignatureResponse) -> (roomId: Int64 , signatureStatus: Bool) {
            let igpRoomId = responseProtoMessage.igpRoomID
            let igpSignatureStatus = responseProtoMessage.igpSignature
            IGFactory.shared.updatChannelRoomSignature(igpRoomId, signatureStatus: igpSignatureStatus)
            return (roomId: igpRoomId, signatureStatus: igpSignatureStatus)
        }
        override class func handlePush(responseProtoMessage: Message) {
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
            var channelGetMessagesStatsRequestMessage = IGPChannelGetMessagesStats()
            channelGetMessagesStatsRequestMessage.igpRoomID = room.id
            var messagesIds = [Int64]()
            for message in messages {
                messagesIds.append(message.id)
            }
            channelGetMessagesStatsRequestMessage.igpMessageID = messagesIds
            return IGRequestWrapper(message: channelGetMessagesStatsRequestMessage, actionID: 423)
        }
    }
    class Handler: IGRequest.Handler {
        class func interpret(response: IGPChannelGetMessagesStatsResponse) {
            let stats = response.igpStats
            //TODO: perform actions
        }
        override class func handlePush(responseProtoMessage: Message) {
        }
    }
}



class IGChannelEditMessageRequest: IGRequest {
    class Generator: IGRequest.Generator {
        class func generate(message: IGRoomMessage, newText: String, room: IGRoom) -> IGRequestWrapper {
            var channelEditMessageRequestMessage = IGPChannelEditMessage()
            channelEditMessageRequestMessage.igpMessageID = message.id
            channelEditMessageRequestMessage.igpMessage = newText
            channelEditMessageRequestMessage.igpRoomID = room.id
            return IGRequestWrapper(message: channelEditMessageRequestMessage, actionID: 425)
        }
    }
    class Handler: IGRequest.Handler {
        class func interpret(response: IGPChannelEditMessageResponse) {
            IGFactory.shared.editMessage(response.igpMessageID, roomID: response.igpRoomID, message: response.igpMessage, messageType: IGRoomMessageType.unknown.fromIGP(response.igpMessageType), messageVersion: response.igpMessageVersion)
        }
        override class func handlePush(responseProtoMessage: Message) {
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
            var channelDeleteMessageRequestMessage = IGPChannelDeleteMessage()
            channelDeleteMessageRequestMessage.igpMessageID = message.id
            channelDeleteMessageRequestMessage.igpRoomID = room.id
            return IGRequestWrapper(message: channelDeleteMessageRequestMessage, actionID: 411)
        }
    }
    class Handler: IGRequest.Handler {
        class func interpret(response: IGPChannelDeleteMessageResponse) {
            IGFactory.shared.setMessageDeleted(response.igpMessageID, roomID: response.igpRoomID, deleteVersion: response.igpDeleteVersion)
        }
        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let response as IGPChannelDeleteMessageResponse:
                self.interpret(response: response)
            default:
                break
            }
        }
    }
}


