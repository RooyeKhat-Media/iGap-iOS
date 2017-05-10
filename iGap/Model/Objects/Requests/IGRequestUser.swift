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
import UIKit
import IGProtoBuff
import ProtocolBuffers

enum IGVerificationCodeSendMethod {
    case sms
    case igap
    case both
}

//MARK: -
class IGUserRegisterRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(countryCode : String, phoneNumber : Int64) -> IGRequestWrapper{
            let userRegisterRequestBuilder = IGPUserRegister.Builder()
            userRegisterRequestBuilder.igpCountryCode = countryCode
            userRegisterRequestBuilder.igpPhoneNumber = phoneNumber
            return IGRequestWrapper(messageBuilder: userRegisterRequestBuilder, actionID: 100)
        }
    }
    
    class Handler : IGRequest.Handler{
        enum VerificationMethod {
            case sms
            case socket
            case all
        }
        
        class func intrepret(response responseProtoMessage: IGPUserRegisterResponse) -> (username:String, userId:Int64, authorHash: String, verificationMethod: IGVerificationCodeSendMethod, resendDelay:Int32, codeDigitsCount:Int32, codeRegex:String) {
            
            var codeSendMethod : IGVerificationCodeSendMethod
            
            switch responseProtoMessage.igpMethod {
            case .verifyCodeSms:
                codeSendMethod = .sms
            case .verifyCodeSocket:
                codeSendMethod = .igap
            case .verifyCodeSmsSocket:
                codeSendMethod = .both
            }
            
            return (username:           responseProtoMessage.igpUsername,
                    userId:             responseProtoMessage.igpUserId,
                    authorHash:         responseProtoMessage.igpAuthorHash,
                    verificationMethod: codeSendMethod,
                    resendDelay:        responseProtoMessage.igpResendDelay,
                    codeDigitsCount:    responseProtoMessage.igpVerifyCodeDigitCount,
                    codeRegex:          responseProtoMessage.igpVerifyCodeRegex)
            
        }
        
        override class func handle(responseProtoMessage: GeneratedResponseMessage) {}
        override class func error() {}
        override class func timeout() {}
    }
}

//MARK: -
class IGUserVerifyRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(usename: String, code:Int32)  -> IGRequestWrapper {
            let userVerifyRequestBuilder = IGPUserVerify.Builder()
            userVerifyRequestBuilder.setIgpUsername(usename)
            userVerifyRequestBuilder.setIgpCode(code)
            return IGRequestWrapper(messageBuilder: userVerifyRequestBuilder, actionID: 101)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func intrepret(response responseProtoMessage: IGPUserVerifyResponse) -> (token:String, newuser:Bool) {
            return (token : responseProtoMessage.igpToken,
                    newuser : responseProtoMessage.igpNewUser )
        }
        
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {}
        override class func error() {}
        override class func timeout() {}
    }
}

//MARK: -
class IGUserLoginRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(token: String) -> IGRequestWrapper {
            let userLoginRequestBuilder = IGPUserLogin.Builder()
            userLoginRequestBuilder.setIgpToken(token)
            
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                userLoginRequestBuilder.setIgpAppVersion(version)
            } else {
                userLoginRequestBuilder.setIgpAppVersion("0.0.0")
            }
            
            if let buildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? Int {
                userLoginRequestBuilder.setIgpAppBuildVersion(Int32(buildVersion))
            } else {
                userLoginRequestBuilder.setIgpAppBuildVersion(Int32(1))
            }
            
            userLoginRequestBuilder.setIgpPlatform(IGPPlatform.ios)
            userLoginRequestBuilder.setIgpPlatformVersion(UIDevice.current.systemVersion)
            userLoginRequestBuilder.setIgpAppName("iGap iOS")
            userLoginRequestBuilder.setIgpAppId(3)
            
            switch UIDevice.current.userInterfaceIdiom {
            case .pad:
                userLoginRequestBuilder.setIgpDevice(IGPDevice.tablet)
            case.phone:
                userLoginRequestBuilder.setIgpDevice(IGPDevice.mobile)
            default:
                userLoginRequestBuilder.setIgpDevice(IGPDevice.unknownDevice)
            }
            userLoginRequestBuilder.setIgpDeviceName(UIDevice.current.name)
            userLoginRequestBuilder.setIgpLanguage(IGPLanguage.enUs)
            return IGRequestWrapper(messageBuilder: userLoginRequestBuilder, actionID: 102)
        }
    }
    
    class Handler : IGRequest.Handler{
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {}
        override class func error() {}
        override class func timeout() {}
    }
}

//MARK: -
class IGUserProfileSetEmailRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(userEmail: String) -> IGRequestWrapper {
            let setEmailRequestBuilder = IGPUserProfileSetEmail.Builder()
            setEmailRequestBuilder.setIgpEmail(userEmail)
            return IGRequestWrapper(messageBuilder: setEmailRequestBuilder, actionID: 103)
        }
    }
    
    class Handler : IGRequest.Handler{
        @discardableResult
        class func interpret(response reponseProtoMessage:IGPUserProfileSetEmailResponse) -> String {
            let userId = IGAppManager.sharedManager.userID()
            let email: String = reponseProtoMessage.igpEmail
            IGFactory.shared.updateUserEmail(userId!, email: email)
            return email
        }
        
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {
            switch responseProtoMessage {
            case let setEmailProtoResponse as IGPUserProfileSetEmailResponse:
                self.interpret(response: setEmailProtoResponse)
            default:
                break
            }
        }
        
        override class func error() {}
        override class func timeout() {}
    }
}

//MARK: -
class IGUserProfileSetGenderRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(gender: IGPGender) -> IGRequestWrapper {
            let setGenderRequestBuilder = IGPUserProfileSetGender.Builder()
            setGenderRequestBuilder.setIgpGender(gender)
            return IGRequestWrapper(messageBuilder: setGenderRequestBuilder, actionID: 104)
        }
    }
    
    class Handler : IGRequest.Handler{
        @discardableResult
        class func interpret(response reponseProtoMessage:IGPUserProfileSetGenderResponse) ->
            IGPGender {
                let userId = IGAppManager.sharedManager.userID()
                let gender: IGPGender = reponseProtoMessage.igpGender
                IGFactory.shared.updateProfileGender(userId!, igpGender: gender)
                return gender
        }

        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {
            
        }
        override class func error() {}
        override class func timeout() {}
    }
}

//MARK: -
class IGUserProfileSetNicknameRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(nickname: String) -> IGRequestWrapper {
            let setNicknameRequestBuilder = IGPUserProfileSetNickname.Builder()
            setNicknameRequestBuilder.setIgpNickname(nickname)
            return IGRequestWrapper(messageBuilder: setNicknameRequestBuilder, actionID: 105)
        }
    }
    
    class Handler : IGRequest.Handler{
        @discardableResult
        class func interpret(response responseProtoMessage:IGPUserProfileSetNicknameResponse) -> String{
            let currentUserId = IGAppManager.sharedManager.userID()
            let nickname : String = responseProtoMessage.igpNickname
            IGFactory.shared.updateUserNickname(currentUserId!, nickname: nickname)
            return nickname
        }
        
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {
            switch responseProtoMessage {
            case let setNicknameProtoResponse as IGPUserProfileSetNicknameResponse:
                self.interpret(response: setNicknameProtoResponse)
            default:
                break
            }
            
        }
        override class func error() {}
        override class func timeout() {}
    }
}

//MARK:
class IGUserContactsImportRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(contacts: [IGContact]) -> IGRequestWrapper {
            let contactsImportRequestBuilder = IGPUserContactsImport.Builder()
            var igpContacts = Array<IGPUserContactsImport.IGPContact>()
            for contact in contacts {
                let igpContact = IGPUserContactsImport.IGPContact.Builder()
                if contact.firstName != nil {
                    igpContact.setIgpFirstName(contact.firstName!)
                }
                if contact.lastName != nil {
                    igpContact.setIgpLastName(contact.lastName!)
                }
                igpContact.setIgpPhone(contact.phoneNumber!)
                igpContact.setIgpClientId(contact.phoneNumber!)
                try? igpContacts.append(igpContact.build())
            }
            contactsImportRequestBuilder.setIgpContacts(igpContacts)
            contactsImportRequestBuilder.setIgpForce(false)
            return IGRequestWrapper(messageBuilder: contactsImportRequestBuilder, actionID: 106)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage: IGPUserContactsImportResponse) {
            let registredContacts = responseProtoMessage.igpRegisteredContacts
            IGFactory.shared.addRegistredContacts(registredContacts)
        }
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {}
        override class func error() {}
        override class func timeout() {}
    }
}

//MARK: -
class IGUserContactsGetListRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate() -> IGRequestWrapper {
            let contactsImportRequestBuilder = IGPUserContactsGetList.Builder()
            return IGRequestWrapper(messageBuilder: contactsImportRequestBuilder, actionID: 107)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage: IGPUserContactsGetListResponse) {
            let registredUsers = responseProtoMessage.igpRegisteredUser
            IGFactory.shared.saveRegistredContactsUsers(registredUsers)
        }
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {}
        override class func error() {}
        override class func timeout() {}
    }
}

//MARK: -
class IGUserContactsDeleteRequest : IGRequest {
    class Generator : IGRequest.Generator{
        
    }
    
    class Handler : IGRequest.Handler{
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {}
        override class func error() {}
        override class func timeout() {}
    }
}

//MARK: -
class IGUserContactsEditRequest : IGRequest {
    class Generator : IGRequest.Generator{
        
    }
    
    class Handler : IGRequest.Handler{
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {}
        override class func error() {}
        override class func timeout() {}
    }
}

//MARK: -
class IGUserProfileGetEmailRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate() -> IGRequestWrapper {
            let getUserEmailRequestBuilder = IGPUserProfileGetEmail.Builder()
            return IGRequestWrapper(messageBuilder: getUserEmailRequestBuilder, actionID: 110)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage: IGPUserProfileGetEmailResponse) -> String {
            let userId = IGAppManager.sharedManager.userID()
            let userEmail: String = responseProtoMessage.igpEmail
            IGFactory.shared.updateUserEmail(userId!, email: userEmail)
            return userEmail
        }
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {}
        override class func error() {}
        override class func timeout() {}
    }
}

//MARK: -
class IGUserProfileGetGenderRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate() -> IGRequestWrapper {
        let getGenderRequestBuilder = IGPUserProfileGetGender.Builder()
            return IGRequestWrapper(messageBuilder: getGenderRequestBuilder, actionID : 111)
            
        }
        
    }
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage: IGPUserProfileGetGenderResponse) -> IGPGender {
            let userId = IGAppManager.sharedManager.userID()
            let userGender = responseProtoMessage.igpGender
            IGFactory.shared.updateProfileGender(userId!, igpGender: userGender)
            return userGender
        }
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {}
        override class func error() {}
        override class func timeout() {}
    }
}

//MARK: -
class IGUserProfileGetNicknameRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate() -> IGRequestWrapper {
            let getUserNicknameRequestBuilder = IGPUserProfileGetNickname.Builder()
            return IGRequestWrapper(messageBuilder: getUserNicknameRequestBuilder, actionID: 112)
        }
    }
        

    
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPUserProfileGetNicknameResponse) ->String {
            let userId = IGAppManager.sharedManager.userID()
            let userNickname = responseProtoMessage.igpNickname
            IGFactory.shared.updateUserNickname(userId!, nickname: userNickname)
            return userNickname
        }
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {}
        override class func error() {}
        override class func timeout() {}
    }
}

//MARK: -
class IGUserUsernameToIdRequest : IGRequest {
    class Generator : IGRequest.Generator{
        
    }
    
    class Handler : IGRequest.Handler{
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {}
        override class func error() {}
        override class func timeout() {}
    }
}

//MARK: -
class IGUserAvatarAddRequest : IGRequest {
    class Generator : IGRequest.Generator{
        //114
        class func generate(token: String) -> IGRequestWrapper {
            let userAvatarAddRequestBuilder = IGPUserAvatarAdd.Builder()
            userAvatarAddRequestBuilder.setIgpAttachment(token)
            return IGRequestWrapper(messageBuilder: userAvatarAddRequestBuilder, actionID: 114)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage: IGPUserAvatarAddResponse) {
            let currentUserId = IGAppManager.sharedManager.userID()
            IGFactory.shared.updateUserAvatar(currentUserId!, igpAvatar: responseProtoMessage.igpAvatar)
        }
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {
            switch responseProtoMessage {
            case let response as IGPUserAvatarAddResponse:
                self.interpret(response: response)
            default:
                break
            }
        }
        override class func error() {}
        override class func timeout() {}
    }
}

//MARK: -
class IGUserAvatarDeleteRequest : IGRequest {
    class Generator : IGRequest.Generator{
        
    }
    
    class Handler : IGRequest.Handler{
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {}
        override class func error() {}
        override class func timeout() {}
    }
}

//MARK: -
class IGUserAvatarGetListRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(userId: Int64) -> IGRequestWrapper {
            let userAvatarGetListRequestBuilder = IGPUserAvatarGetList.Builder()
            userAvatarGetListRequestBuilder.setIgpUserId(userId)
            return IGRequestWrapper(messageBuilder: userAvatarGetListRequestBuilder, actionID: 116)
        }
        
    }
    
    class Handler : IGRequest.Handler {
        class func interpret(response responseProtoMessage:IGPUserAvatarGetListResponse , userId: Int64) -> Array<IGAvatar> {
            let igpAvatars = responseProtoMessage.igpAvatar
            var igAvatars : Array<IGAvatar> = []
            for igpAvatar in igpAvatars {
//                IGFactory.shared.updateUserAvatar(userId, igpAvatar: igpAvatar)
                let igavatar = IGAvatar(igpAvatar: igpAvatar)
                igAvatars.append(igavatar)
            }
            return igAvatars
            
        }
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {}
        override class func error() {}
        override class func timeout() {}
    }
}

//MARK: -
class IGUserInfoRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(userID: Int64) -> IGRequestWrapper {
            let userInfoRequestBuilder = IGPUserInfo.Builder()
            userInfoRequestBuilder.setIgpUserId(userID)
            return IGRequestWrapper(messageBuilder: userInfoRequestBuilder, actionID: 117)
            
        }
    }
    
    class Handler : IGRequest.Handler{
        
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {}
        override class func error() {}
        override class func timeout() {}
    }
}

//MARK: -
class IGUserGetDeleteTokenRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate() -> IGRequestWrapper {
            let userDeleteTokenRequestBuilder = IGPUserGetDeleteToken.Builder()
            return IGRequestWrapper(messageBuilder: userDeleteTokenRequestBuilder, actionID: 118)
            
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPUserGetDeleteTokenResponse) -> (resendDelay: Int32, codeDigitsLenght: String, tokenRegex: String) {
                   return (resendDelay: responseProtoMessage.igpResendDelay,
                           codeDigitsLenght: responseProtoMessage.igpTokenLength,
                           tokenRegex: responseProtoMessage.igpTokenRegex)
        }
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {}
        override class func error() {}
        override class func timeout() {}
    }
}

//MARK: -
class IGUserDeleteRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(token: String , reasen: IGPUserDelete.IGPReason) -> IGRequestWrapper {
            let userDeleteRequestBuilder = IGPUserDelete.Builder()
            userDeleteRequestBuilder.setIgpToken(token)
            userDeleteRequestBuilder.setIgpReason(reasen)
            return IGRequestWrapper(messageBuilder: userDeleteRequestBuilder, actionID: 119)
        }
        
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPUserDeleteResponse)  {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.logoutAndShowRegisterViewController()
        }
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {
            switch responseProtoMessage {
            case let userDeleteProtoResponse as IGPUserDeleteResponse:
                self.interpret(response: userDeleteProtoResponse)
            default:
                break
            }

        }
        override class func error() {}
        override class func timeout() {}
    }
}

//MARK: -
class IGUserProfileSetSelfRemoveRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(selfRemove: Int32) -> IGRequestWrapper {
            let userprofileSetSelfRemove = IGPUserProfileSetSelfRemove.Builder()
            userprofileSetSelfRemove.setIgpSelfRemove(selfRemove)
            return IGRequestWrapper(messageBuilder: userprofileSetSelfRemove, actionID: 120)
        }
        
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPUserProfileSetSelfRemoveResponse){
            let currentUserId = IGAppManager.sharedManager.userID()
            let setSelfRemove : Int32 = responseProtoMessage.igpSelfRemove
            IGFactory.shared.updateUserSelfRemove(currentUserId!,selfRemove: setSelfRemove)
        }
        
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {
            switch responseProtoMessage {
            case let response as IGPUserProfileSetSelfRemoveResponse:
                self.interpret(response: response)
            default:
                break
            }
        }
        override class func error() {}
        override class func timeout() {}
    }
}

//MARK: -
class IGUserProfileGetSelfRemoveRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate() -> IGRequestWrapper {
           let getSelfRemoveRequestBuilder = IGPUserProfileGetSelfRemove.Builder()
            return IGRequestWrapper(messageBuilder : getSelfRemoveRequestBuilder, actionID: 121)
        }
        
    }
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPUserProfileGetSelfRemoveResponse) {
            let currentUserId = IGAppManager.sharedManager.userID()
            let getSelfRemove : Int32 = responseProtoMessage.igpSelfRemove
            IGFactory.shared.updateUserSelfRemove(currentUserId!,selfRemove: getSelfRemove)
        }
    }
}

//MARK: -
class IGUserProfileCheckUsernameRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(username:String) -> IGRequestWrapper {
            let usernameRequestBuilder = IGPUserProfileCheckUsername.Builder()
            usernameRequestBuilder.setIgpUsername(username)
            return IGRequestWrapper(messageBuilder: usernameRequestBuilder, actionID: 122)
        }
        
    }
    
    class Handler : IGRequest.Handler{
        @discardableResult
        class func interpret(response responseProtoMessage:IGPUserProfileCheckUsernameResponse) -> IGCheckUsernameStatus{
            let igpUsernameStatus = responseProtoMessage.igpStatus
            var usernameStatus : IGCheckUsernameStatus
            switch igpUsernameStatus {
            case .available:
                usernameStatus = .available
            case .invalid:
                usernameStatus = .invalid
            case .taken:
                usernameStatus = .taken
            }
            return usernameStatus
        }
    }
}

//MARK: -
class IGUserProfileUpdateUsernameRequest : IGRequest {
        class Generator : IGRequest.Generator{
            class func generate(username: String) -> IGRequestWrapper {
                let usernameRequestBuilder = IGPUserProfileUpdateUsername.Builder()
                usernameRequestBuilder.setIgpUsername(username)
                return IGRequestWrapper(messageBuilder: usernameRequestBuilder, actionID: 123)
            }
        }
    
    
    class Handler : IGRequest.Handler{
        @discardableResult
        class func interpret(response responseProtoMessage:IGPUserProfileUpdateUsernameResponse) -> String{
            let currentUserId = IGAppManager.sharedManager.userID()
            let username : String = responseProtoMessage.igpUsername
            IGFactory.shared.updateProfileUsername(currentUserId!, username: username)
            return username
        }
        
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {
            switch responseProtoMessage {
            case let updateUsernameProfile as IGPUserProfileUpdateUsernameResponse:
                self.interpret(response: updateUsernameProfile)
            default:
                break
            }
        }
        override class func error() {}
        override class func timeout() {}
    }
}

//MARK: -
class IGUserUpdateStatusRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(userStatus: IGRegisteredUser.IGLastSeenStatus ) -> IGRequestWrapper {
            let userUpdateStatusRequestBuilder = IGPUserUpdateStatus.Builder()
            switch userStatus {
            case .online:
                  userUpdateStatusRequestBuilder.setIgpStatus(.online)
            case .exactly:
                userUpdateStatusRequestBuilder.setIgpStatus(.offline)
            default:
                break
            }
            
         return IGRequestWrapper(messageBuilder: userUpdateStatusRequestBuilder, actionID: 124)
        }
        
    }
    
    class Handler : IGRequest.Handler{
         class func interpret(response responseProtoMessage: IGPUserUpdateStatusResponse) {
            let igpStatus = responseProtoMessage.igpStatus
            let userID = responseProtoMessage.igpUserId
            var status = IGRegisteredUser.IGLastSeenStatus.longTimeAgo
            switch igpStatus {
            case .online:
                status = .online
            case .offline:
                status = .exactly
            default:
                break
            }
            IGFactory.shared.updateUserStatus(userID, status: status)

        }
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {
            switch responseProtoMessage {
            case let protoMessage as IGPUserUpdateStatusResponse:
                self.interpret(response: protoMessage)
            default:
                break
            }
        }
        override class func error() {}
        override class func timeout() {}
    }
}
//MARK: -
class IGUserSessionGetActiveListRequest : IGRequest {
    class Generator: IGRequest.Generator {
        class func generate() -> IGRequestWrapper {
            let activeSessionList = IGPUserSessionGetActiveList.Builder()
            return IGRequestWrapper(messageBuilder: activeSessionList, actionID: 125)
        }
        
    }
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage: IGPUserSessionGetActiveListResponse) -> [IGSession] {
            let activeSession = responseProtoMessage.igpSession
            let igSessions = activeSession.map{ (igpSession) -> IGSession in
                return IGSession(igpSession: igpSession)
            }
            return igSessions
        }
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {}
        override class func error() {}
        override class func timeout() {}
    }
}
//MARK: -
class IGUserSessionTerminateRequest : IGRequest {
    class Generator: IGRequest.Generator {
        class func generate(sessionId: Int64) -> IGRequestWrapper {
            let userSessionRequestBuilder = IGPUserSessionTerminate.Builder()
            userSessionRequestBuilder.setIgpSessionId(sessionId)
            return IGRequestWrapper(messageBuilder: userSessionRequestBuilder, actionID: 126)
        }
        
        
    }
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage: IGPUserSessionTerminateResponse){}
        override class func handlePush(responseProtoMessage:GeneratedResponseMessage) {}//
        override class func error() {}
        override class func timeout() {}
    }
}

class IGUserSessionLogoutRequest : IGRequest {
    class Generator: IGRequest.Generator {
        class func genarete() -> IGRequestWrapper {
            let userSessionLogoutRequestBuilder = IGPUserSessionLogout.Builder()
            return IGRequestWrapper(messageBuilder: userSessionLogoutRequestBuilder, actionID: 127)
        }
        
    }
    class Handler : IGRequest.Handler {
        class func interpret(response responseProtoMessage: IGPUserSessionLogoutResponse){
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.logoutAndShowRegisterViewController()
        }
        override class func handlePush(responseProtoMessage:GeneratedResponseMessage) {}
        override class func error() {}
        override class func timeout() {}
        
    }
}

//MARK: -
class IGUserContactsBlockRequest : IGRequest {
    class Generator: IGRequest.Generator {
        class func generate(blockedUserId: Int64 ) ->IGRequestWrapper {
            let userContactsBlockRequestBuilder = IGPUserContactsBlock.Builder()
            userContactsBlockRequestBuilder.setIgpUserId(blockedUserId)
            return IGRequestWrapper(messageBuilder: userContactsBlockRequestBuilder, actionID: 128)
        }
    }
    class Handler : IGRequest.Handler {
        class func interpret(response responseProtoMessage: IGPUserContactsBlockResponse) -> Int64 {
            let blockedUserId = responseProtoMessage.igpUserId
            IGFactory.shared.updateBlockedUser(blockedUserId, blocked: true)
            return blockedUserId
            
        }
        override class func handlePush(responseProtoMessage:GeneratedResponseMessage) {
            switch responseProtoMessage {
            case let userContactBlockedProtoResponse as IGPUserContactsBlockResponse:
                self.interpret(response: userContactBlockedProtoResponse)
            default:
                break
            }
        }
        override class func error() {}
        override class func timeout() {}
    }
}

class IGUserContactsUnBlockRequest : IGRequest {
    class Generator: IGRequest.Generator {
        class func generate(unBlockedUserId: Int64 ) -> IGRequestWrapper {
            let userContactsUnBlockRequestBuilder = IGPUserContactsUnblock.Builder()
            userContactsUnBlockRequestBuilder.setIgpUserId(unBlockedUserId)
            return IGRequestWrapper(messageBuilder: userContactsUnBlockRequestBuilder, actionID: 129)
        }
    }
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage: IGPUserContactsUnblockResponse) -> Int64 {
            let unBlockedUserId = responseProtoMessage.igpUserId
            IGFactory.shared.updateBlockedUser(unBlockedUserId, blocked: false)
            return unBlockedUserId
            
        }
        override class func handlePush(responseProtoMessage:GeneratedResponseMessage) {
            switch responseProtoMessage {
            case let userContactBlockedProtoResponse as IGPUserContactsUnblockResponse:
                self.interpret(response: userContactBlockedProtoResponse)
            default:
                break
            }
        }
        override class func error() {}
        override class func timeout() {}
    }
}

//MARK: -
class IGUserContactsGetBlockedListRequest : IGRequest {
    class Generator: IGRequest.Generator {
        class func generate() -> IGRequestWrapper {
            let getBlockedListRequestBuilder = IGPUserContactsGetBlockedList.Builder()
            return IGRequestWrapper(messageBuilder: getBlockedListRequestBuilder, actionID: 130)
        }
        
    }
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage: IGPUserContactsGetBlockedListResponse) {
            IGFactory.shared.saveBlockedUsers(responseProtoMessage.igpUser)
        }
        override class func handlePush(responseProtoMessage:GeneratedResponseMessage) {}//
        override class func error() {}
        override class func timeout() {}
    }
}

class IGUserPrivacyGetRuleRequest: IGRequest {
    class Generator: IGRequest.Generator {
        class func generate(privacyType: IGPrivacyType) -> IGRequestWrapper {
            let userPrivacyGetRuleRequestBuilder = IGPUserPrivacyGetRule.Builder()
            switch privacyType {
            case .avatar:
                userPrivacyGetRuleRequestBuilder.igpType = .avatar
            case .channelInvite:
                userPrivacyGetRuleRequestBuilder.igpType = .channelInvite
            case .groupInvite:
                userPrivacyGetRuleRequestBuilder.igpType = .groupInvite
            case .userStatus:
                userPrivacyGetRuleRequestBuilder.igpType = .userStatus
            }
            return IGRequestWrapper(messageBuilder: userPrivacyGetRuleRequestBuilder, actionID: 143)
        }
    }
    class Handler: IGRequest.Handler {
        class func interpret(response responseProtoMessage: IGPUserPrivacyGetRuleResponse , privacyType: IGPrivacyType) -> IGPrivacyLevel {
            let privacyLevel : IGPrivacyLevel
            let igpPrivacyLevel = responseProtoMessage.igpLevel
            switch igpPrivacyLevel {
            case .allowAll:
                privacyLevel = .allowAll
            case .allowContacts:
                privacyLevel = .allowContacts
            case .denyAll:
                privacyLevel = .denyAll
            }
            IGFactory.shared.updateUserPrivacy(privacyType , igPrivacyLevel: privacyLevel)
            return privacyLevel
        }
        override class func handlePush(responseProtoMessage:GeneratedResponseMessage) {}
        override class func error() {}
        override class func timeout() {}

    }
}

class IGUserPrivacySetRuleRequest: IGRequest {
    class Generator: IGRequest.Generator {
        class func generate( privacyType: IGPrivacyType , privacyLevel: IGPrivacyLevel) -> IGRequestWrapper {
            let userPrivacySetRuleRequestBuilder = IGPUserPrivacySetRule.Builder()
            
            switch privacyType {
            case .avatar:
                userPrivacySetRuleRequestBuilder.igpType = .avatar
            case .channelInvite:
                userPrivacySetRuleRequestBuilder.igpType = .channelInvite
            case .groupInvite:
                userPrivacySetRuleRequestBuilder.igpType = .groupInvite
            case .userStatus:
                userPrivacySetRuleRequestBuilder.igpType = .userStatus
            }
            switch privacyLevel {
            case .allowAll:
                userPrivacySetRuleRequestBuilder.igpLevel = .allowAll
            case .allowContacts:
                userPrivacySetRuleRequestBuilder.igpLevel = .allowContacts
            case .denyAll:
                userPrivacySetRuleRequestBuilder.igpLevel = .denyAll
            }
            return IGRequestWrapper(messageBuilder: userPrivacySetRuleRequestBuilder, actionID: 144)

        }
    }
    class Handler: IGRequest.Handler {
        class func interpret( response responseProtoMessage: IGPUserPrivacySetRuleResponse) {
            let type: IGPrivacyType
            let level: IGPrivacyLevel
            let igpPrivacyType = responseProtoMessage.igpType
            let igpPrivacyLevel = responseProtoMessage.igpLevel
            switch igpPrivacyType {
            case .avatar:
                type = .avatar
            case .channelInvite:
                type = .channelInvite
            case .groupInvite:
                type = .groupInvite
            case .userStatus:
                type = .userStatus
            }
            switch igpPrivacyLevel {
            case .allowAll:
                level = .allowAll
            case .allowContacts:
                level = .allowContacts
            case .denyAll:
                level = .denyAll
            }
            IGFactory.shared.updateUserPrivacy( type , igPrivacyLevel: level)
        }
        
        override class func handlePush(responseProtoMessage:GeneratedResponseMessage) {
            switch responseProtoMessage {
            case let userSetPrivacyProtoResponse as IGPUserPrivacySetRuleResponse:
                self.interpret(response: userSetPrivacyProtoResponse)
            default:
                break
            }
        }
        override class func error() {}
        override class func timeout() {}
    }
    
}
