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

class IGGroupCreateRequest : IGRequest {
    class Generator : IGRequest.Generator{
        //action id = 300
        class func generate(name: String, description: String?) -> IGRequestWrapper {
            let groupCreateRequestBuilder = IGPGroupCreate.Builder()
            groupCreateRequestBuilder.setIgpName(name)
            if description != nil {
                groupCreateRequestBuilder.setIgpDescription(description!)
            }
            return IGRequestWrapper(messageBuilder: groupCreateRequestBuilder, actionID: 300)
        }
    }
    
    class Handler : IGRequest.Handler {
        class func interpret(response responseProtoMessage:IGPGroupCreateResponse) -> (roomID: Int64, invitedLink: String) {
            let roomID = responseProtoMessage.igpRoomId
            let invitedLink = responseProtoMessage.igpInviteLink
            return (roomID: roomID , invitedLink: invitedLink)
        }
        
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {
            switch responseProtoMessage {
            case let groupCreateResponse as IGPGroupCreateResponse:
                self.interpret(response: groupCreateResponse)
            default:
                break
            }
        }
        override class func error() {}
        override class func timeout() {}
    }
}

class IGGroupAddMemberRequest : IGRequest {
    class Generator : IGRequest.Generator{
        //action id = 301
        class func generate(userID: Int64, group: IGRoom) -> IGRequestWrapper {
            let groupAddMemberRequestBuilder = IGPGroupAddMember.Builder()
            let groupMemberBuilder = IGPGroupAddMember.IGPMember.Builder()
            groupMemberBuilder.setIgpUserId(userID)
            if group.lastMessage != nil {
                groupMemberBuilder.setIgpStartMessageId((group.lastMessage?.id)!)
            }
            let a = try! groupMemberBuilder.build()
            groupAddMemberRequestBuilder.setIgpRoomId(group.id)
            groupAddMemberRequestBuilder.setIgpMember(a)
            return IGRequestWrapper(messageBuilder: groupAddMemberRequestBuilder, actionID: 301)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPGroupAddMemberResponse) -> (userID: Int64, roomID: Int64,role: IGGroupMember.IGRole) {
            let igpUserId = responseProtoMessage.igpUserId
            let igpRoomId = responseProtoMessage.igpRoomId
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
            }
            IGFactory.shared.addGroupMemberToDatabase( igpUserId, roomID: igpRoomId, memberRole:roleInGroup)
            return(userID: igpUserId, roomID: igpRoomId, role: roleInGroup)
        }
        
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {
            switch responseProtoMessage {
            case let groupAddmemberResponse as IGPGroupAddMemberResponse:
                self.interpret(response: groupAddmemberResponse)
            default:
                break
            }
        }
        override class func error() {}
        override class func timeout() {}
    }
}

class IGGroupAddAdminRequest : IGRequest {
    class Generator : IGRequest.Generator {
        class func generate (roomID: Int64 , memberID: Int64) -> IGRequestWrapper{
            let groupAddAdminRequestBuilder = IGPGroupAddAdmin.Builder()
            groupAddAdminRequestBuilder.setIgpRoomId(roomID)
            groupAddAdminRequestBuilder.setIgpMemberId(memberID)
            return IGRequestWrapper(messageBuilder: groupAddAdminRequestBuilder, actionID: 302)
        }
    }
    class Handler : IGRequest.Handler {
        class func interpret(response responseProtoMessage: IGPGroupAddAdminResponse , memberRole : IGGroupMember.IGRole)  {
            let igpRoomId = responseProtoMessage.igpRoomId
            let igpMemberId = responseProtoMessage.igpMemberId
            IGFactory.shared.addGroupMemberToDatabase(igpMemberId, roomID: igpRoomId, memberRole: memberRole)
            
        }
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {
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
            let groupAddModeratorRequestBuilder = IGPGroupAddModerator.Builder()
            groupAddModeratorRequestBuilder.setIgpMemberId(memberID)
            groupAddModeratorRequestBuilder.setIgpRoomId(roomID)
            return IGRequestWrapper(messageBuilder: groupAddModeratorRequestBuilder, actionID: 303)
        }
    }
    class Handler: IGRequest.Handler {
        class func interpret (response responseProtoMessage: IGPGroupAddModeratorResponse , memberRole : IGGroupMember.IGRole) {
            let igpRoomId = responseProtoMessage.igpMemberId
            let igpMemberId = responseProtoMessage.igpRoomId
            IGFactory.shared.addGroupMemberToDatabase(igpMemberId, roomID: igpRoomId, memberRole: memberRole)
            
        }
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {
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
            let groupClearMessageRequestBuilder = IGPGroupClearMessage.Builder()
            if let lastMessageID = group.lastMessage?.id {
            groupClearMessageRequestBuilder.setIgpClearId(lastMessageID)
            }
            groupClearMessageRequestBuilder.setIgpRoomId(group.id)
            return IGRequestWrapper(messageBuilder: groupClearMessageRequestBuilder, actionID: 304)
        }
    }
    class Handler : IGRequest.Handler {
        class func interpret(response responseProtoMessage:IGPGroupClearMessageResponse) {
            let groupId = responseProtoMessage.igpRoomId
            let clearId = responseProtoMessage.igpClearId
            IGFactory.shared.setClearMessageHistory(groupId, clearID: clearId)
        }
        
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {
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
            let groupEditRequestBuilder = IGPGroupEdit.Builder()
            groupEditRequestBuilder.setIgpRoomId(groupRoomId)
            if groupDescription != nil {
            groupEditRequestBuilder.setIgpDescription(groupDescription!)
            }
            groupEditRequestBuilder.setIgpName(groupName)
            return IGRequestWrapper(messageBuilder: groupEditRequestBuilder, actionID: 305)
        }
    }
    class Handler : IGRequest.Handler {
        class func interpret(response responseProtoMessage:IGPGroupEditResponse) -> (groupName: String , groupDesc: String , groupId: Int64) {
            let igpRoomName = responseProtoMessage.igpName
            let igpRoomDescription = responseProtoMessage.igpDescription
            let igpRoomId = responseProtoMessage.igpRoomId
            IGFactory.shared.editGroupRooms(roomID: igpRoomId, roomName: igpRoomName, roomDesc: igpRoomDescription)
            return (groupName: igpRoomName , groupDesc: igpRoomDescription , groupId: igpRoomId)
        }
        override class func handlePush (responseProtoMessage: GeneratedResponseMessage) {
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
            let groupKickAdminRequestBuilder = IGPGroupKickAdmin.Builder()
            groupKickAdminRequestBuilder.setIgpRoomId(roomID)
            groupKickAdminRequestBuilder.setIgpMemberId(memberID)
            return IGRequestWrapper(messageBuilder: groupKickAdminRequestBuilder, actionID: 306)
        }
    }
    class Handler : IGRequest.Handler {
        class func interpret (response responseProtoMessage: IGPGroupKickAdminResponse) {
            let igpRoomId = responseProtoMessage.igpRoomId
            let igpmemberID = responseProtoMessage.igpMemberId
            IGFactory.shared.demoateRoleInGroup(roomId: igpRoomId, memberId: igpmemberID)
            
        }
        override class func handlePush(responseProtoMessage : GeneratedResponseMessage) {
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
            let groupKickMemberRequestBuilder = IGPGroupKickMember.Builder()
            groupKickMemberRequestBuilder.setIgpMemberId(memberId)
            groupKickMemberRequestBuilder.setIgpRoomId(roomId)
            return IGRequestWrapper(messageBuilder: groupKickMemberRequestBuilder, actionID: 307)
        }
    }
    class Handler : IGRequest.Handler {
        class func interpret(response responseProtoMessage: IGPGroupKickMemberResponse) {
            let igpRoomId = responseProtoMessage.igpRoomId
            let igpMemberId = responseProtoMessage.igpMemberId
            IGFactory.shared.kickGroupMembersFromDataBase(roomId: igpRoomId, memberId: igpMemberId)
            
        }
        override class func handlePush(responseProtoMessage : GeneratedResponseMessage) {
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
            let groupKickModeratorRequesrBuilder = IGPGroupKickModerator.Builder()
            groupKickModeratorRequesrBuilder.setIgpRoomId(roomId)
            groupKickModeratorRequesrBuilder.setIgpMemberId(memberId)
            return IGRequestWrapper(messageBuilder: groupKickModeratorRequesrBuilder, actionID: 308)
        }
    }
    class Handler: IGRequest.Handler {
        class func interpret (response responseProtoMessage : IGPGroupKickModeratorResponse) {
            let igpRoomId = responseProtoMessage.igpRoomId
            let igpMemberId = responseProtoMessage.igpMemberId
            IGFactory.shared.demoateRoleInGroup(roomId: igpRoomId, memberId: igpMemberId)
            
        }
        override class func handlePush(responseProtoMessage : GeneratedResponseMessage) {
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
            let groupLeftrequestBuilder = IGPGroupLeft.Builder()
            groupLeftrequestBuilder.setIgpRoomId(room.id)
            return IGRequestWrapper(messageBuilder: groupLeftrequestBuilder, actionID: 309)
        }
    }
    class Handler : IGRequest.Handler {
        class func interpret(response responseProtoMessage : IGPGroupLeftResponse) {
            let igpRoomId = responseProtoMessage.igpRoomId
            IGFactory.shared.leftRoomInDatabase(roomID: igpRoomId)
            
        }
        override class func handlePush(responseProtoMessage : GeneratedResponseMessage) {
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
            let sendMessageRequestBuilder = IGPGroupSendMessage.Builder()
            if let text = message.message {
                sendMessageRequestBuilder.setIgpMessage(text)
            }
            
            sendMessageRequestBuilder.setIgpRoomId(room.id)
            sendMessageRequestBuilder.setIgpMessageType(message.type.toIGP())
    
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
            
            return IGRequestWrapper(messageBuilder: sendMessageRequestBuilder, actionID: 310)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPGroupSendMessageResponse) {
            self.handlePush(responseProtoMessage: responseProtoMessage)
        }
        
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {
            //pushed IGPRoomMessages are handled here
            switch responseProtoMessage {
            case let response as IGPGroupSendMessageResponse:
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




class IGGroupUpdateStatusRequest : IGRequest {
    class Generator : IGRequest.Generator{
        //action id = 311
        class func generate(roomID: Int64, messageID: Int64, status: IGRoomMessageStatus) -> IGRequestWrapper {
            let updateMessageStatusBuilder = IGPGroupUpdateStatus.Builder()
            updateMessageStatusBuilder.setIgpMessageId(messageID)
            updateMessageStatusBuilder.setIgpRoomId(roomID)
            switch status {
            case .delivered:
                updateMessageStatusBuilder.setIgpStatus(.delivered)
            case .seen:
                updateMessageStatusBuilder.setIgpStatus(.seen)
            default:
                break
            }
            return IGRequestWrapper(messageBuilder: updateMessageStatusBuilder, actionID: 311)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response:IGPGroupUpdateStatusResponse) {
            IGFactory.shared.updateMessageStatus(response.igpMessageId, roomID: response.igpRoomId, status: response.igpStatus, statusVersion: response.igpStatusVersion)
        }
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {
            switch responseProtoMessage {
            case let response as IGPGroupUpdateStatusResponse:
                self.interpret(response: response)
            default:
                break
            }
        }
        override class func error() {}
        override class func timeout() {}
    }
}



class IGGroupAvatarAddRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate (attachment: String , roomID: Int64) -> IGRequestWrapper{
            let groupAddAvatarBuilder = IGPGroupAvatarAdd.Builder()
            groupAddAvatarBuilder.setIgpRoomId(roomID)
            groupAddAvatarBuilder.setIgpAttachment(attachment)
            return IGRequestWrapper(messageBuilder: groupAddAvatarBuilder, actionID: 312)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPGroupAvatarAddResponse) {
            IGFactory.shared.updateGroupAvatar(responseProtoMessage.igpRoomId, igpAvatar: responseProtoMessage.igpAvatar)
        }
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {
            switch responseProtoMessage {
            case let groupAvatarResponse as IGPGroupAvatarAddResponse:
                self.interpret(response: groupAvatarResponse)
            default:
                break
            }
        }
        override class func error() {}
        override class func timeout() {}
    }
}

class IGGroupAvatarDeleteRequest : IGRequest {
    class Generator : IGRequest.Generator{
        //313
        class func generate(avatarId: Int64, roomId: Int64) -> IGRequestWrapper {
            let groupAvatarDeleteRequestBuilder = IGPGroupAvatarDelete.Builder()
            groupAvatarDeleteRequestBuilder.setIgpId(avatarId)
            groupAvatarDeleteRequestBuilder.setIgpRoomId(roomId)
            return IGRequestWrapper(messageBuilder: groupAvatarDeleteRequestBuilder, actionID: 313)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response: IGPGroupAvatarDeleteResponse) {
            let roomId = response.igpRoomId
            let avatarId = response.igpId
            //TODO: take action in IGFactory
        }
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {
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
            let groupAvatarGetListRequestBuilder = IGPGroupAvatarGetList.Builder()
            groupAvatarGetListRequestBuilder.setIgpRoomId(roomId)
            return IGRequestWrapper(messageBuilder: groupAvatarGetListRequestBuilder, actionID: 314)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response: IGPGroupAvatarGetListResponse) {
            var avatars = [IGAvatar]()
            for igpAvatar in response.igpAvatar {
                let avatar = IGAvatar(igpAvatar: igpAvatar)
                avatars.append(avatar)
            }
            //TODO: take action
        }
    }
}

class IGGroupUpdateDraftRequest : IGRequest {
    class Generator : IGRequest.Generator{
        //315
        class func generate(draft: IGRoomDraft) -> IGRequestWrapper {
            let groupUpdateDraftRequestBuilder = IGPGroupUpdateDraft.Builder()
            groupUpdateDraftRequestBuilder.setIgpDraft(draft.toIGP())
            groupUpdateDraftRequestBuilder.setIgpRoomId(draft.roomId)
            return IGRequestWrapper(messageBuilder: groupUpdateDraftRequestBuilder, actionID: 315)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response: IGPGroupUpdateDraftResponse) {
            let draft = IGRoomDraft(igpDraft: response.igpDraft, roomId: response.igpRoomId)
            IGFactory.shared.save(draft: draft)
        }
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {
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
            let groupGetDarftRequestBuilder = IGPGroupGetDraft.Builder()
            groupGetDarftRequestBuilder.setIgpRoomId(roomId)
            return IGRequestWrapper(messageBuilder: groupGetDarftRequestBuilder, actionID: 316)
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
        class func generate (room: IGRoom , filterRole: IGRoomFilterRole) -> IGRequestWrapper {
            let groupGetMemberListRequestBuilder = IGPGroupGetMemberList.Builder()
            groupGetMemberListRequestBuilder.setIgpRoomId(room.id)
            switch filterRole {
            case .all :
                groupGetMemberListRequestBuilder.setIgpFilterRole(.all)
            case .admin :
                groupGetMemberListRequestBuilder.setIgpFilterRole(.admin)
            case .member:
                groupGetMemberListRequestBuilder.setIgpFilterRole(.member)
            case .moderator:
                groupGetMemberListRequestBuilder.setIgpFilterRole(.moderator)
            }
            return IGRequestWrapper(messageBuilder: groupGetMemberListRequestBuilder, actionID: 317)
        }
    }
    class Handler: IGRequest.Handler {
        class func interpret(response responseProtoMessage: IGPGroupGetMemberListResponse, roomId: Int64) -> [IGPGroupGetMemberListResponse.IGPMember] {
            let members = responseProtoMessage.igpMember
            IGFactory.shared.saveGroupMemberListToDataBase(members, roomId: roomId)
            return members
        }

        
        override class func handlePush(responseProtoMessage : GeneratedResponseMessage) {

        }
    }
}


class IGGroupDeleteRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate (group : IGRoom) -> IGRequestWrapper {
            let groupDeleteRequestBuilder = IGPGroupDelete.Builder()
            groupDeleteRequestBuilder.setIgpRoomId(group.id)
            
            return IGRequestWrapper(messageBuilder: groupDeleteRequestBuilder, actionID: 318)
        }
    }
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPGroupDeleteResponse){
            let groupID = responseProtoMessage.igpRoomId
            IGFactory.shared.setDeleteRoom(roomID: groupID)
        }
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {
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
            let groupSetActionRequstBuilder = IGPGroupSetAction.Builder()
            groupSetActionRequstBuilder.setIgpRoomId(room.id)
            groupSetActionRequstBuilder.setIgpAction(action.toIGP())
            groupSetActionRequstBuilder.setIgpActionId(actionId)
            return IGRequestWrapper(messageBuilder: groupSetActionRequstBuilder, actionID: 319)
        }
    }
    
    class Handler : IGRequest.Handler{
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {
            switch responseProtoMessage {
            case let response as IGPGroupSetActionResponse:
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

class IGGroupDeleteMessageRequest : IGRequest {
    class Generator : IGRequest.Generator{
        //320
        class func generate(message: IGRoomMessage, room: IGRoom) -> IGRequestWrapper {
            let groupDeleteMessageRequestBuilder = IGPGroupDeleteMessage.Builder()
            groupDeleteMessageRequestBuilder.setIgpMessageId(message.id)
            groupDeleteMessageRequestBuilder.setIgpRoomId(room.id)
            return IGRequestWrapper(messageBuilder: groupDeleteMessageRequestBuilder, actionID: 320)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response: IGPGroupDeleteMessageResponse) {
            IGFactory.shared.setMessageDeleted(response.igpMessageId, roomID: response.igpRoomId, deleteVersion: response.igpDeleteVersion)
        }
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {
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
            let groupCheckusernameRequestBuilder = IGPGroupCheckUsername.Builder()
            groupCheckusernameRequestBuilder.setIgpRoomId(roomId)
            groupCheckusernameRequestBuilder.setIgpUsername(username)
            return IGRequestWrapper(messageBuilder: groupCheckusernameRequestBuilder, actionID: 321)
        }
    }
    class Handler: IGRequest.Handler {
        class func interpret(response responseProtoMessage: IGPGroupCheckUsernameResponse) ->             IGCheckUsernameStatus {
                let igpUsernameStatus = responseProtoMessage.igpStatus
                var usernameStatus : IGCheckUsernameStatus
                switch igpUsernameStatus {
                case .available:
                    usernameStatus = .available
                case .invalid:
                    usernameStatus = .invalid
                case .taken:
                    usernameStatus = .taken
                default:
                    usernameStatus = .invalid
                    break
                }
                return usernameStatus
            }
        
        override class func handlePush(responseProtoMessage : GeneratedResponseMessage) {
            
        }
    }
}

class IGGroupUpdateUsernameRequest : IGRequest {
    class Generator : IGRequest.Generator {
        class func generate(roomID: Int64 , userName: String) -> IGRequestWrapper {
            let groupUpdateUserNameRequestBuilder = IGPGroupUpdateUsername.Builder()
            groupUpdateUserNameRequestBuilder.setIgpUsername(userName)
            groupUpdateUserNameRequestBuilder.setIgpRoomId(roomID)
            return IGRequestWrapper(messageBuilder: groupUpdateUserNameRequestBuilder, actionID: 322)
        }
    }
    class Handler: IGRequest.Handler {
        class func interpret(response responseProtoMessage: IGPGroupUpdateUsernameResponse) -> (userName : String , roomID : Int64) {
            let igpRoomId = responseProtoMessage.igpRoomId
            let igpUsername = responseProtoMessage.igpUsername
            IGFactory.shared.updateGroupUsername(igpUsername, roomId: igpRoomId)
            return (userName : igpUsername , roomID : igpRoomId)
            
        }
        override class func handlePush(responseProtoMessage : GeneratedResponseMessage) {
            switch responseProtoMessage {
            case let response as IGPGroupUpdateUsernameResponse:
                self.interpret(response: response)
                break
            default:
                break
            }

        }
        
    }
}

class IGGroupRemoveUsernameRequest: IGRequest {
    class Generator: IGRequest.Generator {
        class func generate(roomId: Int64) -> IGRequestWrapper {
            let groupRemoveUsernameRequestBuilder = IGPGroupRemoveUsername.Builder()
            groupRemoveUsernameRequestBuilder.setIgpRoomId(roomId)
            
            return IGRequestWrapper(messageBuilder: groupRemoveUsernameRequestBuilder, actionID: 323)
        }
    }
    class Handler : IGRequest.Handler {
        class func interpret( response responseProtoMessage : IGPGroupRemoveUsernameResponse) -> Int64 {
            let igpRoomId = responseProtoMessage.igpRoomId
            IGFactory.shared.removeGroupUserName (igpRoomId )
            return igpRoomId
        }
        override class func handlePush(responseProtoMessage : GeneratedResponseMessage) {
            switch responseProtoMessage {
            case let response as IGPGroupRemoveUsernameResponse:
                self.interpret(response: response)
                break
            default:
                break
            }

        }

    }
}

class IGGroupRevokLinkRequest: IGRequest {
    class Generator: IGRequest.Generator {
        class func generate(roomID: Int64) -> IGRequestWrapper {
            let groupRevokLinkRequestBuilder = IGPGroupRevokeLink.Builder()
            groupRevokLinkRequestBuilder.setIgpRoomId(roomID)
            return IGRequestWrapper(messageBuilder: groupRevokLinkRequestBuilder, actionID: 324)
        }
    }
    class Handler: IGRequest.Handler {
        class func interpret( response responseProtoMessage : IGPGroupRevokeLinkResponse) ->(roomId: Int64 , invitedLink: String , InvitedToken: String){
            let roomID = responseProtoMessage.igpRoomId
            let invitedLink = responseProtoMessage.igpInviteLink
            let invitedToken = responseProtoMessage.igpInviteToken
            IGFactory.shared.revokePrivateRoomLink(roomId: roomID , invitedLink: invitedLink , invitedToken: invitedToken)
            return (roomId: roomID , invitedLink: invitedLink , InvitedToken: invitedToken)
        }
        override class func handlePush(responseProtoMessage : GeneratedResponseMessage) {
            switch responseProtoMessage {
            case let response as IGPGroupRevokeLinkResponse:
                self.interpret(response: response)
                break
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
            let groupEditMessageRequestBuilder = IGPGroupEditMessage.Builder()
            groupEditMessageRequestBuilder.setIgpMessage(newText)
            groupEditMessageRequestBuilder.setIgpMessageId(message.id)
            groupEditMessageRequestBuilder.setIgpRoomId(room.id)
            return IGRequestWrapper(messageBuilder: groupEditMessageRequestBuilder, actionID: 325)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response: IGPGroupEditMessageResponse) {
            IGFactory.shared.editMessage(response.igpMessageId, roomID: response.igpRoomId, message: response.igpMessage, messageType: IGRoomMessageType.unknown.fromIGP(response.igpMessageType), messageVersion: response.igpMessageVersion)
        }
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {
            switch responseProtoMessage {
            case let response as IGPGroupEditMessageResponse:
                self.interpret(response: response)
            default:
                break
            }
        }
    }
}
