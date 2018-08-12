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

class IGGroupCreateRequest : IGRequest {
    class Generator : IGRequest.Generator{
        //action id = 300
        class func generate(name: String, description: String?) -> IGRequestWrapper {
            var groupCreateRequestMessage = IGPGroupCreate()
            groupCreateRequestMessage.igpName = name
            if let description = description {
                groupCreateRequestMessage.igpDescription = description
            }
            return IGRequestWrapper(message: groupCreateRequestMessage, actionID: 300)
        }
    }
    
    class Handler : IGRequest.Handler {
        class func interpret(response responseProtoMessage:IGPGroupCreateResponse) -> (roomID: Int64, invitedLink: String) {
            let roomID = responseProtoMessage.igpRoomID
            let invitedLink = responseProtoMessage.igpInviteLink
            return (roomID: roomID , invitedLink: invitedLink)
        }
        
        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let groupCreateResponse as IGPGroupCreateResponse:
                self.interpret(response: groupCreateResponse)
            default:
                break
            }
        }
    }
}

class IGGroupAddMemberRequest : IGRequest {
    class Generator : IGRequest.Generator{
        //action id = 301
        class func generate(userID: Int64, group: IGRoom) -> IGRequestWrapper {
            var groupAddMemberRequestMessage = IGPGroupAddMember()
            var groupMemberMessage = IGPGroupAddMember.IGPMember()
            groupMemberMessage.igpUserID = userID
            if let lastMessage =  group.lastMessage {
                groupMemberMessage.igpStartMessageID = lastMessage.id
            }
            groupAddMemberRequestMessage.igpRoomID = group.id
            groupAddMemberRequestMessage.igpMember = groupMemberMessage
            return IGRequestWrapper(message: groupAddMemberRequestMessage, actionID: 301)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPGroupAddMemberResponse) -> (userID: Int64, roomID: Int64,role: IGGroupMember.IGRole) {
            let igpUserId = responseProtoMessage.igpUserID
            let igpRoomId = responseProtoMessage.igpRoomID
            let igpRoleInGroup = responseProtoMessage.igpRole
            var roleInGroup: IGGroupMember.IGRole = .member
            switch igpRoleInGroup {
            case .admin:
                roleInGroup = .admin
            case .member:
                roleInGroup = .member
            case .moderator:
                roleInGroup = .moderator
            case .owner:
                roleInGroup = .owner
            default:
                roleInGroup = .member
            }
            IGFactory.shared.addGroupMemberToDatabase(igpUserId, roomID: igpRoomId, memberRole:roleInGroup)
            return(userID: igpUserId, roomID: igpRoomId, role: roleInGroup)
        }
        
        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let groupAddmemberResponse as IGPGroupAddMemberResponse:
                self.interpret(response: groupAddmemberResponse)
            default:
                break
            }
        }
    }
}

class IGGroupAddAdminRequest : IGRequest {
    class Generator : IGRequest.Generator {
        class func generate (roomID: Int64 , memberID: Int64) -> IGRequestWrapper {
            var groupAddAdminRequestMessage = IGPGroupAddAdmin()
            groupAddAdminRequestMessage.igpRoomID = roomID
            groupAddAdminRequestMessage.igpMemberID = memberID
            return IGRequestWrapper(message: groupAddAdminRequestMessage, actionID: 302)
        }
    }
    class Handler : IGRequest.Handler {
        class func interpret(response responseProtoMessage: IGPGroupAddAdminResponse , memberRole : IGGroupMember.IGRole)  {
            let igpRoomId = responseProtoMessage.igpRoomID
            let igpMemberId = responseProtoMessage.igpMemberID
            IGFactory.shared.addGroupMemberToDatabase(igpMemberId, roomID: igpRoomId, memberRole: memberRole)
            
        }
        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let groupAddAdminResponse as IGPGroupAddAdminResponse:
                self.interpret(response: groupAddAdminResponse, memberRole: .admin)
            default:
                break
            }
        }
    }
}

class IGGroupAddModeratorRequest: IGRequest {
    class Generator : IGRequest.Generator {
        class func generate (roomID: Int64 , memberID: Int64) -> IGRequestWrapper {
            var groupAddModeratorRequestMessage = IGPGroupAddModerator()
            groupAddModeratorRequestMessage.igpMemberID = memberID
            groupAddModeratorRequestMessage.igpRoomID = roomID
            return IGRequestWrapper(message: groupAddModeratorRequestMessage, actionID: 303)
        }
    }
    class Handler: IGRequest.Handler {
        class func interpret (response responseProtoMessage: IGPGroupAddModeratorResponse , memberRole : IGGroupMember.IGRole) {
            let igpRoomId = responseProtoMessage.igpMemberID
            let igpMemberId = responseProtoMessage.igpRoomID
            IGFactory.shared.addGroupMemberToDatabase(igpMemberId, roomID: igpRoomId, memberRole: memberRole)
            
        }
        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let groupAddModeratorResponse as IGPGroupAddModeratorResponse:
                self.interpret(response: groupAddModeratorResponse, memberRole: .moderator)
            default:
                break
            }
        }
    }
}

class IGGroupClearMessageRequest : IGRequest {
    class Generator : IGRequest.Generator {
        class func generate(group: IGRoom) -> IGRequestWrapper {
            var groupClearMessageRequestMessage = IGPGroupClearMessage()
            if let lastMessageID = group.lastMessage?.id {
                groupClearMessageRequestMessage.igpClearID = lastMessageID
            }
            groupClearMessageRequestMessage.igpRoomID = group.id
            return IGRequestWrapper(message: groupClearMessageRequestMessage, actionID: 304)
        }
    }
    class Handler : IGRequest.Handler {
        class func interpret(response responseProtoMessage:IGPGroupClearMessageResponse) {
            let groupId = responseProtoMessage.igpRoomID
            let clearId = responseProtoMessage.igpClearID
            IGFactory.shared.setClearMessageHistory(groupId, clearID: clearId)
        }
        
        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let response as IGPGroupClearMessageResponse:
                self.interpret(response: response)
                break
            default:
                break
            }
        }
    }
    
}

class IGGroupEditRequest : IGRequest {
    class Generator : IGRequest.Generator {
        class func generate (groupName: String , groupDescription : String?, groupRoomId: Int64) -> IGRequestWrapper {
            var groupEditRequestMessage = IGPGroupEdit()
            groupEditRequestMessage.igpRoomID = groupRoomId
            if let groupDescription = groupDescription {
                groupEditRequestMessage.igpDescription = groupDescription
            }
            groupEditRequestMessage.igpName = groupName
            return IGRequestWrapper(message: groupEditRequestMessage, actionID: 305)
        }
    }
    class Handler : IGRequest.Handler {
        class func interpret(response responseProtoMessage:IGPGroupEditResponse) -> (groupName: String , groupDesc: String , groupId: Int64) {
            let igpRoomName = responseProtoMessage.igpName
            let igpRoomDescription = responseProtoMessage.igpDescription
            let igpRoomId = responseProtoMessage.igpRoomID
            IGFactory.shared.editGroupRooms(roomID: igpRoomId, roomName: igpRoomName, roomDesc: igpRoomDescription)
            return (groupName: igpRoomName , groupDesc: igpRoomDescription , groupId: igpRoomId)
        }
        override class func handlePush (responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let response as IGPGroupEditResponse:
                self.interpret(response: response)
                break
            default:
                break
            }

        }
    }
}

class IGGroupKickAdminRequest: IGRequest {
    class Generator: IGRequest.Generator {
        class func generate(roomID : Int64 , memberID: Int64) -> IGRequestWrapper {
            var groupKickAdminRequestMessage = IGPGroupKickAdmin()
            groupKickAdminRequestMessage.igpRoomID = roomID
            groupKickAdminRequestMessage.igpMemberID = memberID
            return IGRequestWrapper(message: groupKickAdminRequestMessage, actionID: 306)
        }
    }
    class Handler : IGRequest.Handler {
        class func interpret (response responseProtoMessage: IGPGroupKickAdminResponse) {
            let igpRoomId = responseProtoMessage.igpRoomID
            let igpmemberID = responseProtoMessage.igpMemberID
            IGFactory.shared.demoteRoleInGroup(roomId: igpRoomId, memberId: igpmemberID)
            
        }
        override class func handlePush(responseProtoMessage : Message) {
            switch responseProtoMessage {
            case let response as IGPGroupKickAdminResponse:
                self.interpret(response: response)
                break
            default:
                break
            }

        }
    }
}

class IGGroupKickMemberRequest: IGRequest {
    class Generator: IGRequest.Generator {
        class func generate(memberId: Int64 , roomId: Int64) -> IGRequestWrapper {
            var groupKickMemberRequestMessage = IGPGroupKickMember()
            groupKickMemberRequestMessage.igpMemberID = memberId
            groupKickMemberRequestMessage.igpRoomID = roomId
            return IGRequestWrapper(message: groupKickMemberRequestMessage, actionID: 307)
        }
    }
    class Handler : IGRequest.Handler {
        class func interpret(response responseProtoMessage: IGPGroupKickMemberResponse) {
            let igpRoomId = responseProtoMessage.igpRoomID
            let igpMemberId = responseProtoMessage.igpMemberID
            IGFactory.shared.kickGroupMembersFromDatabase(roomId: igpRoomId, memberId: igpMemberId)
            
        }
        override class func handlePush(responseProtoMessage : Message) {
            switch responseProtoMessage {
            case let response as IGPGroupKickMemberResponse:
                self.interpret(response: response)
                break
            default:
                break
            }

        }
    }
}

class IGGroupKickModeratorRequest : IGRequest {
    class Generator: IGRequest.Generator {
        class func generate (memberId: Int64 , roomId: Int64) -> IGRequestWrapper {
            var groupKickModeratorRequesrMessage = IGPGroupKickModerator()
            groupKickModeratorRequesrMessage.igpRoomID = roomId
            groupKickModeratorRequesrMessage.igpMemberID = memberId
            return IGRequestWrapper(message: groupKickModeratorRequesrMessage, actionID: 308)
        }
    }
    class Handler: IGRequest.Handler {
        class func interpret (response responseProtoMessage : IGPGroupKickModeratorResponse) {
            let igpRoomId = responseProtoMessage.igpRoomID
            let igpMemberId = responseProtoMessage.igpMemberID
            IGFactory.shared.demoteRoleInGroup(roomId: igpRoomId, memberId: igpMemberId)
            
        }
        override class func handlePush(responseProtoMessage : Message) {
            switch responseProtoMessage {
            case let response as IGPGroupKickModeratorResponse:
                self.interpret(response: response)
                break
            default:
                break
            }

        }
    }
}

class IGGroupLeftRequest : IGRequest {
    class Generator: IGRequest.Generator {
        class func generate(room: IGRoom) -> IGRequestWrapper {
            var groupLeftrequestMessage = IGPGroupLeft()
            groupLeftrequestMessage.igpRoomID = room.id
            return IGRequestWrapper(message: groupLeftrequestMessage, actionID: 309)
        }
    }
    class Handler : IGRequest.Handler {
        class func interpret(response responseProtoMessage : IGPGroupLeftResponse) {
            IGFactory.shared.leftRoomInDatabase(roomID: responseProtoMessage.igpRoomID, memberId: responseProtoMessage.igpMemberID)
        }
        override class func handlePush(responseProtoMessage : Message) {
            switch responseProtoMessage {
            case let response as IGPGroupLeftResponse:
                self.interpret(response: response)
                break
            default:
                break
            }

        }
    }
}

class IGGroupSendMessageRequest : IGRequest {
    class Generator : IGRequest.Generator {
        //action id = 310
        class func generate(message: IGRoomMessage, room: IGRoom, attachmentToken: String?) -> IGRequestWrapper {
            var sendMessageRequestMessage = IGPGroupSendMessage()
            if let text = message.message {
                sendMessageRequestMessage.igpMessage = text
            }
            
            sendMessageRequestMessage.igpRoomID = room.id
            sendMessageRequestMessage.igpMessageType = message.type.toIGP()
    
            if let attachmentToken = attachmentToken {
                sendMessageRequestMessage.igpAttachment = attachmentToken
            }
            
            if message.repliedTo != nil {
                sendMessageRequestMessage.igpReplyTo = message.repliedTo!.id
            } else if let forward = message.forwardedFrom {
                var forwardedFrom = IGPRoomMessageForwardFrom()
                forwardedFrom.igpRoomID = forward.roomId
                forwardedFrom.igpMessageID = forward.id
                sendMessageRequestMessage.igpForwardFrom = forwardedFrom
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
                
                sendMessageRequestMessage.igpContact = igpContact
            }
            
            if let location = message.location {
                sendMessageRequestMessage.igpLocation.igpLat = location.latitude
                sendMessageRequestMessage.igpLocation.igpLon = location.longitude
            }
            
            return IGRequestWrapper(message: sendMessageRequestMessage, actionID: 310)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPGroupSendMessageResponse) {
            self.handlePush(responseProtoMessage: responseProtoMessage)
        }
        
        override class func handlePush(responseProtoMessage: Message) {
            //pushed IGPRoomMessages are handled here
            switch responseProtoMessage {
            case let response as IGPGroupSendMessageResponse:
                let messages: [IGPRoomMessage] = [response.igpRoomMessage]
                IGFactory.shared.saveIgpMessagesToDatabase(messages, for: response.igpRoomID, updateLastMessage: true , isFromSharedMedia: false, isFromSendMessage: true)
            default:
                break
            }
        }
    }
}

class IGGroupUpdateStatusRequest : IGRequest {
    class Generator : IGRequest.Generator{
        //action id = 311
        class func generate(roomID: Int64, messageID: Int64, status: IGRoomMessageStatus) -> IGRequestWrapper {
            var updateMessageStatusMessage = IGPGroupUpdateStatus()
            updateMessageStatusMessage.igpMessageID = messageID
            updateMessageStatusMessage.igpRoomID = roomID
            switch status {
            case .delivered:
                updateMessageStatusMessage.igpStatus = .delivered
            case .seen:
                updateMessageStatusMessage.igpStatus = .seen
            default:
                break
            }
            return IGRequestWrapper(message: updateMessageStatusMessage, actionID: 311)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response:IGPGroupUpdateStatusResponse) {
            IGFactory.shared.updateMessageStatus(response.igpMessageID, roomID: response.igpRoomID, status: response.igpStatus, statusVersion: response.igpStatusVersion)
        }
        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let response as IGPGroupUpdateStatusResponse:
                self.interpret(response: response)
            default:
                break
            }
        }
    }
}



class IGGroupAvatarAddRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate (attachment: String , roomID: Int64) -> IGRequestWrapper {
            var groupAddAvatarMessage = IGPGroupAvatarAdd()
            groupAddAvatarMessage.igpRoomID = roomID
            groupAddAvatarMessage.igpAttachment = attachment
            return IGRequestWrapper(message: groupAddAvatarMessage, actionID: 312)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPGroupAvatarAddResponse) {
            IGFactory.shared.updateGroupAvatar(responseProtoMessage.igpRoomID, igpAvatar: responseProtoMessage.igpAvatar)
        }
        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let groupAvatarResponse as IGPGroupAvatarAddResponse:
                self.interpret(response: groupAvatarResponse)
            default:
                break
            }
        }
    }
}

class IGGroupAvatarDeleteRequest : IGRequest {
    class Generator : IGRequest.Generator{
        //313
        class func generate(avatarId: Int64, roomId: Int64) -> IGRequestWrapper {
            var groupAvatarDeleteRequestMessage = IGPGroupAvatarDelete()
            groupAvatarDeleteRequestMessage.igpID = avatarId
            groupAvatarDeleteRequestMessage.igpRoomID = roomId
            return IGRequestWrapper(message: groupAvatarDeleteRequestMessage, actionID: 313)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response: IGPGroupAvatarDeleteResponse) {
            let roomId = response.igpRoomID
            let avatarId = response.igpID
            //TODO: take action in IGFactory
        }
        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let response as IGPGroupAvatarDeleteResponse:
                self.interpret(response: response)
            default:
                break
            }
        }
    }
}

class IGGroupAvatarGetListRequest : IGRequest {
    class Generator : IGRequest.Generator{
        //314
        class func generate(roomId: Int64) -> IGRequestWrapper {
            var groupAvatarGetListRequestMessage = IGPGroupAvatarGetList()
            groupAvatarGetListRequestMessage.igpRoomID = roomId
            return IGRequestWrapper(message: groupAvatarGetListRequestMessage, actionID: 314)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response: IGPGroupAvatarGetListResponse) -> [IGAvatar] {
            var avatars = [IGAvatar]()
            for igpAvatar in response.igpAvatar {
                let avatar = IGAvatar(igpAvatar: igpAvatar)
                avatars.append(avatar)
            }
            return avatars

        }
    }
    
}

class IGGroupUpdateDraftRequest : IGRequest {
    class Generator : IGRequest.Generator{
        //315
        class func generate(draft: IGRoomDraft) -> IGRequestWrapper {
            var groupUpdateDraftRequestMessage = IGPGroupUpdateDraft()
            groupUpdateDraftRequestMessage.igpDraft = draft.toIGP()
            groupUpdateDraftRequestMessage.igpRoomID = draft.roomId
            return IGRequestWrapper(message: groupUpdateDraftRequestMessage, actionID: 315)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response: IGPGroupUpdateDraftResponse) {
            let draft = IGRoomDraft(igpDraft: response.igpDraft, roomId: response.igpRoomID)
            IGFactory.shared.save(draft: draft)
        }
        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let response as IGPGroupUpdateDraftResponse:
                self.interpret(response: response)
            default:
                break
            }
        }
    }
}

class IGGroupGetDraftRequest : IGRequest {
    class Generator : IGRequest.Generator{
        //316
        class func generate(roomId: Int64) -> IGRequestWrapper {
            var groupGetDarftRequestMessage = IGPGroupGetDraft()
            groupGetDarftRequestMessage.igpRoomID = roomId
            return IGRequestWrapper(message: groupGetDarftRequestMessage, actionID: 316)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response: IGPGroupGetDraftResponse, roomId: Int64) {
            let draft = IGRoomDraft(igpDraft: response.igpDraft, roomId: roomId)
            IGFactory.shared.save(draft: draft)
        }
    }
}

class IGGroupGetMemberListRequest : IGRequest {
    class Generator : IGRequest.Generator {
        class func generate (room: IGRoom, offset: Int32, limit: Int32, filterRole: IGRoomFilterRole) -> IGRequestWrapper {
            var groupGetMemberListRequestMessage = IGPGroupGetMemberList()
            groupGetMemberListRequestMessage.igpRoomID = room.id
            switch filterRole {
            case .all :
                groupGetMemberListRequestMessage.igpFilterRole = .all
            case .admin :
                groupGetMemberListRequestMessage.igpFilterRole = .admin
            case .member:
                groupGetMemberListRequestMessage.igpFilterRole = .member
            case .moderator:
                groupGetMemberListRequestMessage.igpFilterRole = .moderator
            }
            var pagination = IGPPagination()
            pagination.igpLimit = limit
            pagination.igpOffset = offset
            groupGetMemberListRequestMessage.igpPagination = pagination
            
            return IGRequestWrapper(message: groupGetMemberListRequestMessage, actionID: 317)
        }
    }
    class Handler: IGRequest.Handler {
        class func interpret(response responseProtoMessage: IGPGroupGetMemberListResponse, roomId: Int64) -> [IGPGroupGetMemberListResponse.IGPMember] {
            let members = responseProtoMessage.igpMember
            IGFactory.shared.saveGroupMemberListToDatabase(members, roomId: roomId)
            return members
        }
        
        override class func handlePush(responseProtoMessage : Message) {

        }
    }
}


class IGGroupDeleteRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate (group : IGRoom) -> IGRequestWrapper {
            var groupDeleteRequestMessage = IGPGroupDelete()
            groupDeleteRequestMessage.igpRoomID = group.id
            return IGRequestWrapper(message: groupDeleteRequestMessage, actionID: 318)
        }
    }
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPGroupDeleteResponse){
            let groupID = responseProtoMessage.igpRoomID
            IGFactory.shared.setDeleteRoom(roomID: groupID)
            IGFactory.shared.deleteAllMessages(roomId: groupID)
        }
        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let response as IGPGroupDeleteResponse:
                self.interpret(response: response)
            default:
                break
            }
        }
    }
}


class IGGroupSetActionRequest : IGRequest {
    class Generator : IGRequest.Generator{
        //319
        class func generate(room: IGRoom, action: IGClientAction, actionId: Int32) -> IGRequestWrapper {
            var groupSetActionRequstMessage = IGPGroupSetAction()
            groupSetActionRequstMessage.igpRoomID = room.id
            groupSetActionRequstMessage.igpAction = action.toIGP()
            groupSetActionRequstMessage.igpActionID = actionId
            return IGRequestWrapper(message: groupSetActionRequstMessage, actionID: 319)
        }
    }
    
    class Handler : IGRequest.Handler{
        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let response as IGPGroupSetActionResponse:
                let action = IGClientAction.cancel.fromIGP(response.igpAction)
                IGFactory.shared.setActionForRoom(action: action, userId: response.igpUserID, roomId: response.igpRoomID)
                break
            default:
                break
            }
        }
    }
}

class IGGroupDeleteMessageRequest : IGRequest {
    class Generator : IGRequest.Generator{
        //320
        class func generate(message: IGRoomMessage, room: IGRoom) -> IGRequestWrapper {
            var groupDeleteMessageRequestMessage = IGPGroupDeleteMessage()
            groupDeleteMessageRequestMessage.igpMessageID = message.id
            groupDeleteMessageRequestMessage.igpRoomID = room.id
            return IGRequestWrapper(message: groupDeleteMessageRequestMessage, actionID: 320)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response: IGPGroupDeleteMessageResponse) {
            IGFactory.shared.setMessageDeleted(response.igpMessageID, roomID: response.igpRoomID, deleteVersion: response.igpDeleteVersion)
        }
        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let response as IGPGroupDeleteMessageResponse:
                self.interpret(response: response)
            default:
                break
            }
        }
    }
}

class IGGroupCheckUsernameRequest : IGRequest {
    class Generator : IGRequest.Generator {
        class func generate(roomId: Int64 , username: String) -> IGRequestWrapper {
            var groupCheckusernameRequestMessage = IGPGroupCheckUsername()
            groupCheckusernameRequestMessage.igpRoomID = roomId
            groupCheckusernameRequestMessage.igpUsername = username
            return IGRequestWrapper(message: groupCheckusernameRequestMessage, actionID: 321)
        }
    }
    class Handler: IGRequest.Handler {
        override class func handlePush(responseProtoMessage : Message) {
            
        }
    }
}

class IGGroupUpdateUsernameRequest : IGRequest {
    class Generator : IGRequest.Generator {
        class func generate(roomID: Int64 , userName: String) -> IGRequestWrapper {
            var groupUpdateUserNameRequestMessage = IGPGroupUpdateUsername()
            groupUpdateUserNameRequestMessage.igpUsername = userName
            groupUpdateUserNameRequestMessage.igpRoomID = roomID
            return IGRequestWrapper(message: groupUpdateUserNameRequestMessage, actionID: 322)
        }
    }
    class Handler: IGRequest.Handler {
        class func interpret(response responseProtoMessage: IGPGroupUpdateUsernameResponse) -> (userName : String , roomID : Int64) {
            let igpRoomId = responseProtoMessage.igpRoomID
            let igpUsername = responseProtoMessage.igpUsername
            IGFactory.shared.updateGroupUsername(igpUsername, roomId: igpRoomId)
            return (userName : igpUsername , roomID : igpRoomId)
            
        }
        override class func handlePush(responseProtoMessage : Message) {
            switch responseProtoMessage {
            case let response as IGPGroupUpdateUsernameResponse:
                self.interpret(response: response)
            default:
                break
            }

        }
        
    }
}

class IGGroupRemoveUsernameRequest: IGRequest {
    class Generator: IGRequest.Generator {
        class func generate(roomId: Int64) -> IGRequestWrapper {
            var groupRemoveUsernameRequestMessage = IGPGroupRemoveUsername()
            groupRemoveUsernameRequestMessage.igpRoomID = roomId
            return IGRequestWrapper(message: groupRemoveUsernameRequestMessage, actionID: 323)
        }
    }
    
    class Handler : IGRequest.Handler {
        class func interpret( response responseProtoMessage : IGPGroupRemoveUsernameResponse) -> Int64 {
            let igpRoomId = responseProtoMessage.igpRoomID
            IGFactory.shared.removeGroupUserName (igpRoomId )
            return igpRoomId
        }
        
        override class func handlePush(responseProtoMessage : Message) {
            switch responseProtoMessage {
            case let response as IGPGroupRemoveUsernameResponse:
                self.interpret(response: response)
            default:
                break
            }
        }

    }
}

class IGGroupRevokLinkRequest: IGRequest {
    class Generator: IGRequest.Generator {
        class func generate(roomID: Int64) -> IGRequestWrapper {
            var groupRevokLinkRequestMessage = IGPGroupRevokeLink()
            groupRevokLinkRequestMessage.igpRoomID = roomID
            return IGRequestWrapper(message: groupRevokLinkRequestMessage, actionID: 324)
        }
    }
    
    class Handler: IGRequest.Handler {
        class func interpret( response responseProtoMessage : IGPGroupRevokeLinkResponse) ->(roomId: Int64 , invitedLink: String , InvitedToken: String){
            let roomID = responseProtoMessage.igpRoomID
            let invitedLink = responseProtoMessage.igpInviteLink
            let invitedToken = responseProtoMessage.igpInviteToken
            IGFactory.shared.revokePrivateRoomLink(roomId: roomID , invitedLink: invitedLink , invitedToken: invitedToken)
            return (roomId: roomID , invitedLink: invitedLink , InvitedToken: invitedToken)
        }
        
        override class func handlePush(responseProtoMessage : Message) {
            switch responseProtoMessage {
            case let response as IGPGroupRevokeLinkResponse:
                self.interpret(response: response)
            default:
                break
            }
        }
    }
}


class IGGroupEditMessageRequest : IGRequest {
    class Generator : IGRequest.Generator{
        //325
        class func generate(message: IGRoomMessage, newText: String, room: IGRoom) -> IGRequestWrapper {
            var groupEditMessageRequestMessage = IGPGroupEditMessage()
            groupEditMessageRequestMessage.igpMessage = newText
            groupEditMessageRequestMessage.igpMessageID = message.id
            groupEditMessageRequestMessage.igpRoomID = room.id
            return IGRequestWrapper(message: groupEditMessageRequestMessage, actionID: 325)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response: IGPGroupEditMessageResponse) {
            IGFactory.shared.editMessage(response.igpMessageID, roomID: response.igpRoomID, message: response.igpMessage, messageType: IGRoomMessageType.unknown.fromIGP(response.igpMessageType), messageVersion: response.igpMessageVersion)
        }
        
        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let response as IGPGroupEditMessageResponse:
                self.interpret(response: response)
            default:
                break
            }
        }
    }
}


class IGGroupPinMessageRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(roomId: Int64, messageId: Int64 = 0) -> IGRequestWrapper {
            var groupPinMessage = IGPGroupPinMessage()
            groupPinMessage.igpRoomID = roomId
            groupPinMessage.igpMessageID = messageId
            return IGRequestWrapper(message: groupPinMessage, actionID: 326)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response: IGPGroupPinMessageResponse) {
            IGFactory.shared.saveIgpMessagesToDatabase([response.igpPinnedMessage], for: response.igpRoomID, updateLastMessage: false , isFromSharedMedia: false)
            IGFactory.shared.roomPinMessage(roomId: response.igpRoomID, messageId: response.igpPinnedMessage.igpMessageID)
        }
        
        override class func handlePush(responseProtoMessage: Message) {
            if let groupPinMessage = responseProtoMessage as? IGPGroupPinMessageResponse {
                self.interpret(response: groupPinMessage)
            }
        }
    }
}
