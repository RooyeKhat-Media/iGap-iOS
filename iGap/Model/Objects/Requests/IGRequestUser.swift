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
import SwiftProtobuf

enum IGVerificationCodeSendMethod {
    case sms
    case igap
    case both
}

//MARK: -
class IGUserRegisterRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(countryCode : String, phoneNumber : Int64) -> IGRequestWrapper {
            var userRegisterRequestMessage = IGPUserRegister()
            userRegisterRequestMessage.igpCountryCode = countryCode
            userRegisterRequestMessage.igpPhoneNumber = phoneNumber
            return IGRequestWrapper(message: userRegisterRequestMessage, actionID: 100)
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
            case .UNRECOGNIZED(_):
                codeSendMethod = .sms
            }
            
            return (username:           responseProtoMessage.igpUsername,
                    userId:             responseProtoMessage.igpUserID,
                    authorHash:         responseProtoMessage.igpAuthorHash,
                    verificationMethod: codeSendMethod,
                    resendDelay:        responseProtoMessage.igpResendDelay,
                    codeDigitsCount:    responseProtoMessage.igpVerifyCodeDigitCount,
                    codeRegex:          responseProtoMessage.igpVerifyCodeRegex)
            
        }
        
        override class func handle(responseProtoMessage: Message) {}
    }
}

//MARK: -
class IGUserVerifyRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(usename: String, code:Int32)  -> IGRequestWrapper {
            var userVerifyRequestMessage = IGPUserVerify()
            userVerifyRequestMessage.igpUsername = usename
            userVerifyRequestMessage.igpCode = code
            return IGRequestWrapper(message: userVerifyRequestMessage, actionID: 101)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func intrepret(response responseProtoMessage: IGPUserVerifyResponse) -> (token:String, newuser:Bool) {
            return (token : responseProtoMessage.igpToken,
                    newuser : responseProtoMessage.igpNewUser )
        }
        
        override class func handlePush(responseProtoMessage: Message) {}
    }
}

//MARK: -
class IGUserLoginRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(token: String) -> IGRequestWrapper {
            var userLoginRequestMessage = IGPUserLogin()
            userLoginRequestMessage.igpToken = token
            
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                userLoginRequestMessage.igpAppVersion = version
            } else {
                userLoginRequestMessage.igpAppVersion = "0.0.0"
            }
            
            if let buildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? Int {
                userLoginRequestMessage.igpAppBuildVersion = Int32(buildVersion)
            } else {
                userLoginRequestMessage.igpAppBuildVersion = Int32(1)
            }
            
            userLoginRequestMessage.igpPlatform = IGPPlatform.ios
            userLoginRequestMessage.igpPlatformVersion = UIDevice.current.systemVersion
            userLoginRequestMessage.igpAppName = "iGap iOS"
            userLoginRequestMessage.igpAppID = 3
            
            switch UIDevice.current.userInterfaceIdiom {
            case .pad:
                userLoginRequestMessage.igpDevice = IGPDevice.tablet
            case.phone:
                userLoginRequestMessage.igpDevice = IGPDevice.mobile
            default:
                userLoginRequestMessage.igpDevice = IGPDevice.unknownDevice
            }
            userLoginRequestMessage.igpDeviceName = UIDevice.current.name
            userLoginRequestMessage.igpLanguage = IGPLanguage.enUs
            return IGRequestWrapper(message: userLoginRequestMessage, actionID: 102)
        }
    }
    
    class Handler : IGRequest.Handler{
        override class func handlePush(responseProtoMessage: Message) {}
    }
}

//MARK: -
class IGUserProfileSetEmailRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(userEmail: String) -> IGRequestWrapper {
            var setEmailRequestMessage = IGPUserProfileSetEmail()
            setEmailRequestMessage.igpEmail = userEmail
            return IGRequestWrapper(message: setEmailRequestMessage, actionID: 103)
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
        
        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let setEmailProtoResponse as IGPUserProfileSetEmailResponse:
                self.interpret(response: setEmailProtoResponse)
            default:
                break
            }
        }
        
    }
}

//MARK: -
class IGUserProfileSetGenderRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(gender: IGPGender) -> IGRequestWrapper {
            var setGenderRequestMessage = IGPUserProfileSetGender()
            setGenderRequestMessage.igpGender = gender
            return IGRequestWrapper(message: setGenderRequestMessage, actionID: 104)
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

        override class func handlePush(responseProtoMessage: Message) {
            
        }
    }
}

//MARK: -
class IGUserProfileSetNicknameRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(nickname: String) -> IGRequestWrapper {
            var setNicknameRequestMessage = IGPUserProfileSetNickname()
            setNicknameRequestMessage.igpNickname = nickname
            return IGRequestWrapper(message: setNicknameRequestMessage, actionID: 105)
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
        
        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let setNicknameProtoResponse as IGPUserProfileSetNicknameResponse:
                self.interpret(response: setNicknameProtoResponse)
            default:
                break
            }
            
        }
    }
}

//MARK:
class IGUserContactsImportRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(contacts: [IGContact], force: Bool = false) -> IGRequestWrapper {
            var contactsImportRequestMessage = IGPUserContactsImport()
            var igpContacts = Array<IGPUserContactsImport.IGPContact>()
            for contact in contacts {
                var igpContact = IGPUserContactsImport.IGPContact()
                if let firstName = contact.firstName {
                    igpContact.igpFirstName = firstName
                }
                if let lastName = contact.lastName {
                    igpContact.igpLastName = lastName
                }
                igpContact.igpPhone = contact.phoneNumber!
                igpContact.igpClientID = contact.phoneNumber!
                igpContacts.append(igpContact)
            }
            contactsImportRequestMessage.igpContacts = igpContacts
            //TODO: pass force value here
            contactsImportRequestMessage.igpForce = force
            return IGRequestWrapper(message: contactsImportRequestMessage, actionID: 106)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage: IGPUserContactsImportResponse) {
            let registredContacts = responseProtoMessage.igpRegisteredContacts
            IGFactory.shared.addRegistredContacts(registredContacts)
        }
        override class func handlePush(responseProtoMessage: Message) {}
    }
}

//MARK: -
class IGUserContactsGetListRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate() -> IGRequestWrapper {
            let contactsImportRequestMessage = IGPUserContactsGetList()
            return IGRequestWrapper(message: contactsImportRequestMessage, actionID: 107)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage: IGPUserContactsGetListResponse) {
            let registredUsers = responseProtoMessage.igpRegisteredUser
            IGFactory.shared.saveRegistredContactsUsers(registredUsers)
        }
        override class func handlePush(responseProtoMessage: Message) {}
    }
}

//MARK: -
class IGUserContactsDeleteRequest : IGRequest {
    class Generator : IGRequest.Generator{
        
    }
    
    class Handler : IGRequest.Handler{
        override class func handlePush(responseProtoMessage: Message) {}
    }
}

//MARK: -
class IGUserContactsEditRequest : IGRequest {
    class Generator : IGRequest.Generator{
        
    }
    
    class Handler : IGRequest.Handler{
        override class func handlePush(responseProtoMessage: Message) {}
    }
}

//MARK: -
class IGUserProfileGetEmailRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate() -> IGRequestWrapper {
            let getUserEmailRequestMessage = IGPUserProfileGetEmail()
            return IGRequestWrapper(message: getUserEmailRequestMessage, actionID: 110)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage: IGPUserProfileGetEmailResponse) -> String {
            let userId = IGAppManager.sharedManager.userID()
            let userEmail: String = responseProtoMessage.igpEmail
            IGFactory.shared.updateUserEmail(userId!, email: userEmail)
            return userEmail
        }
        override class func handlePush(responseProtoMessage: Message) {}
    }
}

//MARK: -
class IGUserProfileGetGenderRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate() -> IGRequestWrapper {
        let getGenderRequestMessage = IGPUserProfileGetGender()
            return IGRequestWrapper(message: getGenderRequestMessage, actionID : 111)
            
        }
        
    }
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage: IGPUserProfileGetGenderResponse) -> IGPGender {
            let userId = IGAppManager.sharedManager.userID()
            let userGender = responseProtoMessage.igpGender
            IGFactory.shared.updateProfileGender(userId!, igpGender: userGender)
            return userGender
        }
        override class func handlePush(responseProtoMessage: Message) {}
    }
}

//MARK: -
class IGUserProfileGetNicknameRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate() -> IGRequestWrapper {
            let getUserNicknameRequestMessage = IGPUserProfileGetNickname()
            return IGRequestWrapper(message: getUserNicknameRequestMessage, actionID: 112)
        }
    }
        

    
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPUserProfileGetNicknameResponse) ->String {
            let userId = IGAppManager.sharedManager.userID()
            let userNickname = responseProtoMessage.igpNickname
            IGFactory.shared.updateUserNickname(userId!, nickname: userNickname)
            return userNickname
        }
        override class func handlePush(responseProtoMessage: Message) {}
    }
}

//MARK: -
class IGUserUsernameToIdRequest : IGRequest {
    class Generator : IGRequest.Generator{
        
    }
    
    class Handler : IGRequest.Handler{
        override class func handlePush(responseProtoMessage: Message) {}
    }
}

//MARK: -
class IGUserAvatarAddRequest : IGRequest {
    class Generator : IGRequest.Generator{
        //114
        class func generate(token: String) -> IGRequestWrapper {
            var userAvatarAddRequestMessage = IGPUserAvatarAdd()
            userAvatarAddRequestMessage.igpAttachment = token
            return IGRequestWrapper(message: userAvatarAddRequestMessage, actionID: 114)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage: IGPUserAvatarAddResponse) {
            let currentUserId = IGAppManager.sharedManager.userID()
            IGFactory.shared.updateUserAvatar(currentUserId!, igpAvatar: responseProtoMessage.igpAvatar)
        }
        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let response as IGPUserAvatarAddResponse:
                self.interpret(response: response)
            default:
                break
            }
        }
    }
}


//MARK: -
class IGUserAvatarDeleteRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(avatarID: Int64) ->IGRequestWrapper {
            var userAvatarDeleteRequestMessage = IGPUserAvatarDelete()
            userAvatarDeleteRequestMessage.igpID = avatarID
            return IGRequestWrapper(message: userAvatarDeleteRequestMessage, actionID: 115)
        }
        
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPUserAvatarDeleteResponse) {
            
        }

        override class func handlePush(responseProtoMessage: Message) {}
    }
}

//MARK: -
class IGUserAvatarGetListRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(userId: Int64) -> IGRequestWrapper {
            var userAvatarGetListRequestMessage = IGPUserAvatarGetList()
            userAvatarGetListRequestMessage.igpUserID = userId
            return IGRequestWrapper(message: userAvatarGetListRequestMessage, actionID: 116)
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
        override class func handlePush(responseProtoMessage: Message) {}
    }
}

//MARK: -
class IGUserInfoRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(userID: Int64) -> IGRequestWrapper {
            var userInfoRequestMessage = IGPUserInfo()
            userInfoRequestMessage.igpUserID = userID
            return IGRequestWrapper(message: userInfoRequestMessage, actionID: 117)
            
        }
    }
    
    class Handler : IGRequest.Handler{
        
        override class func handlePush(responseProtoMessage: Message) {}
    }
}

//MARK: -
class IGUserGetDeleteTokenRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate() -> IGRequestWrapper {
            let userDeleteTokenRequestMessage = IGPUserGetDeleteToken()
            return IGRequestWrapper(message: userDeleteTokenRequestMessage, actionID: 118)
            
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPUserGetDeleteTokenResponse) -> (resendDelay: Int32, codeDigitsLenght: String, tokenRegex: String) {
                   return (resendDelay: responseProtoMessage.igpResendDelay,
                           codeDigitsLenght: responseProtoMessage.igpTokenLength,
                           tokenRegex: responseProtoMessage.igpTokenRegex)
        }
        override class func handlePush(responseProtoMessage: Message) {}
    }
}

//MARK: -
class IGUserDeleteRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(token: String , reasen: IGPUserDelete.IGPReason) -> IGRequestWrapper {
            var userDeleteRequestMessage = IGPUserDelete()
            userDeleteRequestMessage.igpToken = token
            userDeleteRequestMessage.igpReason = reasen
            return IGRequestWrapper(message: userDeleteRequestMessage, actionID: 119)
        }
        
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPUserDeleteResponse)  {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.logoutAndShowRegisterViewController()
        }
        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let userDeleteProtoResponse as IGPUserDeleteResponse:
                self.interpret(response: userDeleteProtoResponse)
            default:
                break
            }

        }
    }
}

//MARK: -
class IGUserProfileSetSelfRemoveRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(selfRemove: Int32) -> IGRequestWrapper {
            var userprofileSetSelfRemove = IGPUserProfileSetSelfRemove()
            userprofileSetSelfRemove.igpSelfRemove = selfRemove
            return IGRequestWrapper(message: userprofileSetSelfRemove, actionID: 120)
        }
        
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPUserProfileSetSelfRemoveResponse){
            let currentUserId = IGAppManager.sharedManager.userID()
            let setSelfRemove : Int32 = responseProtoMessage.igpSelfRemove
            IGFactory.shared.updateUserSelfRemove(currentUserId!,selfRemove: setSelfRemove)
        }
        
        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let response as IGPUserProfileSetSelfRemoveResponse:
                self.interpret(response: response)
            default:
                break
            }
        }
    }
}

//MARK: -
class IGUserProfileGetSelfRemoveRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate() -> IGRequestWrapper {
           let getSelfRemoveRequestMessage = IGPUserProfileGetSelfRemove()
            return IGRequestWrapper(message : getSelfRemoveRequestMessage, actionID: 121)
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
            var usernameRequestMessage = IGPUserProfileCheckUsername()
            usernameRequestMessage.igpUsername = username
            return IGRequestWrapper(message: usernameRequestMessage, actionID: 122)
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
            default:
                usernameStatus = .available
            }
            return usernameStatus
        }
    }
}

//MARK: -
class IGUserProfileUpdateUsernameRequest : IGRequest {
        class Generator : IGRequest.Generator{
            class func generate(username: String) -> IGRequestWrapper {
                var usernameRequestMessage = IGPUserProfileUpdateUsername()
                usernameRequestMessage.igpUsername = username
                return IGRequestWrapper(message: usernameRequestMessage, actionID: 123)
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
        
        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let updateUsernameProfile as IGPUserProfileUpdateUsernameResponse:
                self.interpret(response: updateUsernameProfile)
            default:
                break
            }
        }
    }
}

//MARK: -
class IGUserUpdateStatusRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(userStatus: IGRegisteredUser.IGLastSeenStatus ) -> IGRequestWrapper {
            var userUpdateStatusRequestMessage = IGPUserUpdateStatus()
            switch userStatus {
            case .online:
                  userUpdateStatusRequestMessage.igpStatus = .online
            case .exactly:
                userUpdateStatusRequestMessage.igpStatus = .offline
            default:
                break
            }
            
         return IGRequestWrapper(message: userUpdateStatusRequestMessage, actionID: 124)
        }
        
    }
    
    class Handler : IGRequest.Handler{
         class func interpret(response responseProtoMessage: IGPUserUpdateStatusResponse) {
            let igpStatus = responseProtoMessage.igpStatus
            let userID = responseProtoMessage.igpUserID
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
        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let protoMessage as IGPUserUpdateStatusResponse:
                self.interpret(response: protoMessage)
            default:
                break
            }
        }
    }
}
//MARK: -
class IGUserSessionGetActiveListRequest : IGRequest {
    class Generator: IGRequest.Generator {
        class func generate() -> IGRequestWrapper {
            let activeSessionList = IGPUserSessionGetActiveList()
            return IGRequestWrapper(message: activeSessionList, actionID: 125)
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
        override class func handlePush(responseProtoMessage: Message) {}
    }
}
//MARK: -
class IGUserSessionTerminateRequest : IGRequest {
    class Generator: IGRequest.Generator {
        class func generate(sessionId: Int64) -> IGRequestWrapper {
            var userSessionRequestMessage = IGPUserSessionTerminate()
            userSessionRequestMessage.igpSessionID = sessionId
            return IGRequestWrapper(message: userSessionRequestMessage, actionID: 126)
        }
        
        
    }
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage: IGPUserSessionTerminateResponse){}
        override class func handlePush(responseProtoMessage:Message) {}//
    }
}

//MARK: -
class IGUserSessionLogoutRequest : IGRequest {
    class Generator: IGRequest.Generator {
        class func genarete() -> IGRequestWrapper {
            let userSessionLogoutRequestMessage = IGPUserSessionLogout()
            return IGRequestWrapper(message: userSessionLogoutRequestMessage, actionID: 127)
        }
        
    }
    class Handler : IGRequest.Handler {
        class func interpret(response responseProtoMessage: IGPUserSessionLogoutResponse){
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.logoutAndShowRegisterViewController()
        }
        override class func handlePush(responseProtoMessage:Message) {}
        
    }
}

//MARK: -
class IGUserContactsBlockRequest : IGRequest {
    class Generator: IGRequest.Generator {
        class func generate(blockedUserId: Int64 ) ->IGRequestWrapper {
            var userContactsBlockRequestMessage = IGPUserContactsBlock()
            userContactsBlockRequestMessage.igpUserID = blockedUserId
            return IGRequestWrapper(message: userContactsBlockRequestMessage, actionID: 128)
        }
    }
    class Handler : IGRequest.Handler {
        class func interpret(response responseProtoMessage: IGPUserContactsBlockResponse) -> Int64 {
            let blockedUserId = responseProtoMessage.igpUserID
            IGFactory.shared.updateBlockedUser(blockedUserId, blocked: true)
            return blockedUserId
            
        }
        override class func handlePush(responseProtoMessage:Message) {
            switch responseProtoMessage {
            case let userContactBlockedProtoResponse as IGPUserContactsBlockResponse:
                self.interpret(response: userContactBlockedProtoResponse)
            default:
                break
            }
        }
    }
}

class IGUserContactsUnBlockRequest : IGRequest {
    class Generator: IGRequest.Generator {
        class func generate(unBlockedUserId: Int64 ) -> IGRequestWrapper {
            var userContactsUnBlockRequestMessage = IGPUserContactsUnblock()
            userContactsUnBlockRequestMessage.igpUserID = unBlockedUserId
            return IGRequestWrapper(message: userContactsUnBlockRequestMessage, actionID: 129)
        }
    }
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage: IGPUserContactsUnblockResponse) -> Int64 {
            let unBlockedUserId = responseProtoMessage.igpUserID
            IGFactory.shared.updateBlockedUser(unBlockedUserId, blocked: false)
            return unBlockedUserId
            
        }
        override class func handlePush(responseProtoMessage:Message) {
            switch responseProtoMessage {
            case let userContactBlockedProtoResponse as IGPUserContactsUnblockResponse:
                self.interpret(response: userContactBlockedProtoResponse)
            default:
                break
            }
        }
    }
}

//MARK: -
class IGUserContactsGetBlockedListRequest : IGRequest {
    class Generator: IGRequest.Generator {
        class func generate() -> IGRequestWrapper {
            let getBlockedListRequestMessage = IGPUserContactsGetBlockedList()
            return IGRequestWrapper(message: getBlockedListRequestMessage, actionID: 130)
        }
        
    }
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage: IGPUserContactsGetBlockedListResponse) {
            IGFactory.shared.saveBlockedUsers(responseProtoMessage.igpUser)
        }
        override class func handlePush(responseProtoMessage:Message) {}//
    }
}

//MARK: -
class IGUserTwoStepVerificationGetPasswordDetailRequest : IGRequest {
    class Generator: IGRequest.Generator {
        class func generate() -> IGRequestWrapper {
            let getPasswordDetailRequestMessage = IGPUserTwoStepVerificationGetPasswordDetail()
            return IGRequestWrapper(message: getPasswordDetailRequestMessage, actionID: 131)
        }

    }
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage: IGPUserTwoStepVerificationGetPasswordDetailResponse) -> IGTwoStepVerification {
            return IGTwoStepVerification(protoResponse: responseProtoMessage)
        }
    }
}

//MARK: -
class IGUserTwoStepVerificationVerifyPasswordRequest : IGRequest {
    class Generator: IGRequest.Generator {
        class func generate(password:String) -> IGRequestWrapper {
            var verifyPasswordRequestMessage = IGPUserTwoStepVerificationVerifyPassword()
            verifyPasswordRequestMessage.igpPassword = password
            return IGRequestWrapper(message: verifyPasswordRequestMessage, actionID: 132)
        }

    }
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage: IGPUserTwoStepVerificationVerifyPasswordResponse) -> String {
            return responseProtoMessage.igpToken
        }
    }
}

//MARK: -
class IGUserTwoStepVerificationSetPasswordRequest : IGRequest {
    class Generator: IGRequest.Generator {
        class func generate(oldPassword: String, newPassword: String, questionOne: String, answerOne: String, questionTwo: String, answerTwo: String, hint: String, recoveryEmail: String) -> IGRequestWrapper {
            var setPasswordRequestMessage = IGPUserTwoStepVerificationSetPassword()
            setPasswordRequestMessage.igpOldPassword = oldPassword
            setPasswordRequestMessage.igpNewPassword = newPassword
            setPasswordRequestMessage.igpQuestionOne = questionOne
            setPasswordRequestMessage.igpAnswerOne = answerOne
            setPasswordRequestMessage.igpQuestionTwo = questionTwo
            setPasswordRequestMessage.igpAnswerTwo = answerTwo
            setPasswordRequestMessage.igpHint = hint
            setPasswordRequestMessage.igpRecoveryEmail = recoveryEmail
            return IGRequestWrapper(message: setPasswordRequestMessage, actionID: 133)
        }
        
    }
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage: IGPUserTwoStepVerificationSetPasswordResponse) {
            
        }
    }
}

//MARK: -
class IGUserTwoStepVerificationUnsetPasswordRequest : IGRequest {
    class Generator: IGRequest.Generator {
        class func generate(password: String) -> IGRequestWrapper {
            var unsetPasswordRequestMessage = IGPUserTwoStepVerificationUnsetPassword()
            unsetPasswordRequestMessage.igpPassword = password
            return IGRequestWrapper(message: unsetPasswordRequestMessage, actionID: 134)
        }
        
    }
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage: IGPUserTwoStepVerificationUnsetPasswordResponse) {
            //TODO: Complete Me
        }
    }
}

//MARK: -
class IGUserTwoStepVerificationCheckPasswordRequest : IGRequest {
    class Generator: IGRequest.Generator {
        class func generate(password: String) -> IGRequestWrapper {
            var checkPasswordRequestMessage = IGPUserTwoStepVerificationCheckPassword()
            checkPasswordRequestMessage.igpPassword = password
            return IGRequestWrapper(message: checkPasswordRequestMessage, identity: "identity", actionID: 135)
        }
        
    }
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage: IGPUserTwoStepVerificationCheckPasswordResponse) {
            //TODO: Complete Me
        }
    }
}

//MARK: -
class IGUserTwoStepVerificationVerifyRecoveryEmailRequest : IGRequest {
    class Generator: IGRequest.Generator {
        class func generate(token: String) -> IGRequestWrapper {
            var verifyRecoveryEmailRequestMessage = IGPUserTwoStepVerificationVerifyRecoveryEmail()
            verifyRecoveryEmailRequestMessage.igpToken = token
            return IGRequestWrapper(message: verifyRecoveryEmailRequestMessage, actionID: 136)
        }
        
    }
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage: IGPUserTwoStepVerificationVerifyRecoveryEmailResponse) {
            //TODO: Complete Me
        }
    }
}

//MARK: -
class IGUserTwoStepVerificationChangeRecoveryEmailRequest : IGRequest {
    class Generator: IGRequest.Generator {
        class func generate(password: String, email: String) -> IGRequestWrapper {
            var changeRecoveryEmailRequestMessage = IGPUserTwoStepVerificationChangeRecoveryEmail()
            changeRecoveryEmailRequestMessage.igpPassword = password
            changeRecoveryEmailRequestMessage.igpEmail = email
            return IGRequestWrapper(message: changeRecoveryEmailRequestMessage, actionID: 137)
        }
        
    }
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage: IGPUserTwoStepVerificationChangeRecoveryEmailResponse) {
            
        }
    }
}

//MARK: -
class IGUserTwoStepVerificationRequestRecoveryTokenRequest : IGRequest {
    class Generator: IGRequest.Generator {
        class func generate() -> IGRequestWrapper {
            var requestRecoveryTokenRequestMessage = IGPUserTwoStepVerificationRequestRecoveryToken()
            return IGRequestWrapper(message: requestRecoveryTokenRequestMessage, actionID: 138)
        }
        
    }
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage: IGPUserTwoStepVerificationRequestRecoveryTokenResponse) {
            //TODO: Complete Me
        }
    }
}

//MARK: -
class IGUserTwoStepVerificationRecoverPasswordByTokenRequest : IGRequest {
    class Generator: IGRequest.Generator {
        class func generate(token: String) -> IGRequestWrapper {
            var recoverPasswordByTokenRequestMessage = IGPUserTwoStepVerificationRecoverPasswordByToken()
            recoverPasswordByTokenRequestMessage.igpToken = token
            return IGRequestWrapper(message: recoverPasswordByTokenRequestMessage, actionID: 139)
        }
        
    }
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage: IGPUserTwoStepVerificationRecoverPasswordByTokenResponse) {
            //TODO: Complete Me
        }
    }
}

//MARK: -
class IGUserTwoStepVerificationRecoverPasswordByAnswersRequest : IGRequest {
    class Generator: IGRequest.Generator {
        class func generate(answerOne: String, answerTwo: String) -> IGRequestWrapper {
            var recoverPasswordByAnswersRequestMessage = IGPUserTwoStepVerificationRecoverPasswordByAnswers()
            recoverPasswordByAnswersRequestMessage.igpAnswerOne = answerOne
            recoverPasswordByAnswersRequestMessage.igpAnswerTwo = answerTwo
            return IGRequestWrapper(message: recoverPasswordByAnswersRequestMessage, actionID: 140)
        }
        
    }
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage: IGPUserTwoStepVerificationRecoverPasswordByAnswersResponse) {
            //TODO: Complete Me
        }
    }
}

//MARK: -
class IGUserTwoStepVerificationChangeRecoveryQuestionRequest : IGRequest {
    class Generator: IGRequest.Generator {
        class func generate(password: String, questionOne: String, answerOne: String, questionTwo: String, answerTwo: String) -> IGRequestWrapper {
            var changeRecoveryQuestionRequestMessage = IGPUserTwoStepVerificationChangeRecoveryQuestion()
            changeRecoveryQuestionRequestMessage.igpQuestionOne = questionOne
            changeRecoveryQuestionRequestMessage.igpAnswerOne = answerOne
            changeRecoveryQuestionRequestMessage.igpQuestionTwo = questionTwo
            changeRecoveryQuestionRequestMessage.igpAnswerTwo = answerTwo
            changeRecoveryQuestionRequestMessage.igpPassword = password
            return IGRequestWrapper(message: changeRecoveryQuestionRequestMessage, actionID: 141)
        }
        
    }
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage: IGPUserTwoStepVerificationChangeRecoveryQuestionResponse) {
            
        }
    }
}

//MARK: -
class IGUserTwoStepVerificationChangehintRequest : IGRequest {
    class Generator: IGRequest.Generator {
        class func generate(hint: String, password: String) -> IGRequestWrapper {
            var changeHintnRequestMessage = IGPUserTwoStepVerificationChangeHint()
            changeHintnRequestMessage.igpHint = hint
            changeHintnRequestMessage.igpPassword = password
            return IGRequestWrapper(message: changeHintnRequestMessage, actionID: 142)
        }
        
    }
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage: IGPUserTwoStepVerificationChangeHintResponse) {
            
        }
    }
}

class IGUserTwoStepVerificationResendVerifyEmailRequest : IGRequest {
    class Generator: IGRequest.Generator {
        class func generate() -> IGRequestWrapper {
            let resendVerifyEmail = IGPUserTwoStepVerificationResendVerifyEmail()
            return IGRequestWrapper(message: resendVerifyEmail, actionID: 146)
        }
        
    }
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage: IGPUserTwoStepVerificationResendVerifyEmailResponse) {
            
        }
    }
}

//MARK: -
class IGUserPrivacyGetRuleRequest: IGRequest {
    class Generator: IGRequest.Generator {
        class func generate(privacyType: IGPrivacyType) -> IGRequestWrapper {
            var userPrivacyGetRuleRequestMessage = IGPUserPrivacyGetRule()
            switch privacyType {
            case .avatar:
                userPrivacyGetRuleRequestMessage.igpType = .avatar
            case .channelInvite:
                userPrivacyGetRuleRequestMessage.igpType = .channelInvite
            case .groupInvite:
                userPrivacyGetRuleRequestMessage.igpType = .groupInvite
            case .userStatus:
                userPrivacyGetRuleRequestMessage.igpType = .userStatus
            case .voiceCalling:
                userPrivacyGetRuleRequestMessage.igpType = .voiceCalling
            case .videoCalling:
                userPrivacyGetRuleRequestMessage.igpType = .videoCalling
            case .screenSharing:
                userPrivacyGetRuleRequestMessage.igpType = .screenSharing
            case .secretChat:
                userPrivacyGetRuleRequestMessage.igpType = .secretChat
            }
            return IGRequestWrapper(message: userPrivacyGetRuleRequestMessage, actionID: 143)
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
            default:
                privacyLevel = .denyAll
            }
            IGFactory.shared.updateUserPrivacy(privacyType , igPrivacyLevel: privacyLevel)
            return privacyLevel
        }
        override class func handlePush(responseProtoMessage:Message) {}

    }
}

//MARK: -
class IGUserPrivacySetRuleRequest: IGRequest {
    class Generator: IGRequest.Generator {
        class func generate( privacyType: IGPrivacyType , privacyLevel: IGPrivacyLevel) -> IGRequestWrapper {
            var userPrivacySetRuleRequestMessage = IGPUserPrivacySetRule()
            
            switch privacyType {
            case .avatar:
                userPrivacySetRuleRequestMessage.igpType = .avatar
            case .channelInvite:
                userPrivacySetRuleRequestMessage.igpType = .channelInvite
            case .groupInvite:
                userPrivacySetRuleRequestMessage.igpType = .groupInvite
            case .userStatus:
                userPrivacySetRuleRequestMessage.igpType = .userStatus
            case .voiceCalling:
                userPrivacySetRuleRequestMessage.igpType = .voiceCalling
            case .videoCalling:
                userPrivacySetRuleRequestMessage.igpType = .videoCalling
            case .screenSharing:
                userPrivacySetRuleRequestMessage.igpType = .screenSharing
            case .secretChat:
                userPrivacySetRuleRequestMessage.igpType = .secretChat
            }
            switch privacyLevel {
            case .allowAll:
                userPrivacySetRuleRequestMessage.igpLevel = .allowAll
            case .allowContacts:
                userPrivacySetRuleRequestMessage.igpLevel = .allowContacts
            case .denyAll:
                userPrivacySetRuleRequestMessage.igpLevel = .denyAll
            }
            return IGRequestWrapper(message: userPrivacySetRuleRequestMessage, actionID: 144)

        }
    }
    class Handler: IGRequest.Handler {
        class func interpret( response responseProtoMessage: IGPUserPrivacySetRuleResponse) {
            var type: IGPrivacyType
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
            case .voiceCalling:
                type = .voiceCalling
            case .videoCalling:
                type = .videoCalling
            case .screenSharing:
                type = .screenSharing
            case .secretChat:
                type = .secretChat
            default:
                type = .avatar
            }
            switch igpPrivacyLevel {
            case .allowAll:
                level = .allowAll
            case .allowContacts:
                level = .allowContacts
            case .denyAll:
                level = .denyAll
            default:
                level = .denyAll
            }
            IGFactory.shared.updateUserPrivacy( type , igPrivacyLevel: level)
        }
        
        override class func handlePush(responseProtoMessage:Message) {
            switch responseProtoMessage {
            case let userSetPrivacyProtoResponse as IGPUserPrivacySetRuleResponse:
                self.interpret(response: userSetPrivacyProtoResponse)
            default:
                break
            }
        }
    }
    
}

//MARK: -
class IGUserVerifyNewDeviceRequest: IGRequest {
    class Generator: IGRequest.Generator {
        class func generate(token: String) -> IGRequestWrapper {
            var userVerifyNewDeviceRequestMessage = IGPUserVerifyNewDevice()
            userVerifyNewDeviceRequestMessage.igpToken = token
            return IGRequestWrapper(message: userVerifyNewDeviceRequestMessage, actionID: 145)
        }
    }
    class Handler: IGRequest.Handler {
        class func interpret(response responseProtoMessage: IGPUserVerifyNewDeviceResponse) -> (appName: String, buildVersion: String, appVersion: String, platform: IGPlatform, platformVersion: String, device: IGDevice, devicename: String) {
            return (appName: responseProtoMessage.igpAppName,
                    buildVersion: "\(responseProtoMessage.igpAppBuildVersion)",
                    appVersion: responseProtoMessage.igpAppVersion,
                    platform: IGPlatform(rawValue: Int(responseProtoMessage.igpPlatform.rawValue))!,
                    platformVersion: responseProtoMessage.igpPlatformVersion,
                    device: IGDevice(rawValue: Int(responseProtoMessage.igpDevice.rawValue))!,
                    devicename: responseProtoMessage.igpDeviceName)
        }
    }

}

class IGUserProfileSetBioRequest: IGRequest {
    class Generator: IGRequest.Generator {
        class func generate(bio: String) -> IGRequestWrapper {
            var userProfileSetBio = IGPUserProfileSetBio()
            userProfileSetBio.igpBio = bio
            return IGRequestWrapper(message: userProfileSetBio, actionID: 147)
        }
    }
    
    class Handler: IGRequest.Handler {
        class func interpret(response responseProtoMessage: IGPUserProfileSetBioResponse) {
            IGFactory.shared.updateBio(bio: responseProtoMessage.igpBio)
        }
        
        override class func handlePush(responseProtoMessage: Message) {
            if let response = responseProtoMessage as? IGPUserProfileSetBioResponse {
                self.interpret(response: response)
            }
        }
    }
}

class IGUserProfileGetBioRequest: IGRequest {
    class Generator: IGRequest.Generator {
        class func generate() -> IGRequestWrapper {
            return IGRequestWrapper(message: IGPUserProfileGetBio(), actionID: 148)
        }
    }
    
    class Handler: IGRequest.Handler {
        class func interpret(response responseProtoMessage: IGPUserProfileGetBioResponse) {
            IGFactory.shared.updateBio(bio: responseProtoMessage.igpBio)
        }
        
        override class func handlePush(responseProtoMessage: Message) {
            if let response = responseProtoMessage as? IGPUserProfileGetBioResponse {
                self.interpret(response: response)
            }
        }
    }
}

class IGUserReportRequest: IGRequest {
    class Generator: IGRequest.Generator {
        class func generate(userId: Int64, reason: IGPUserReport.IGPReason, description: String = "") -> IGRequestWrapper {
            var userReport = IGPUserReport()
            userReport.igpUserID = userId
            userReport.igpReason = reason
            userReport.igpDescription = description
            return IGRequestWrapper(message: userReport, actionID: 149)
        }
    }
    
    class Handler: IGRequest.Handler {
        class func interpret(response responseProtoMessage: IGPUserReportResponse) {
            
        }
    }
}
