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

typealias IGErrorWaitTime = Int

enum IGError: String {
    
    case unknownError   = "-1"
    
    //MARK: System
    case badRequest     = "1"
    case loginRequest   = "2"
    case newClient      = "3" //New client connected in this session , so you will be kicked out
    case forbidden      = "4"
    case timeout        = "5"
    case relation       = "6" //For related requests , if one get error , RELATION_ERROR will be sent to others
    case setNickname    = "9"
    //MARK: User
    //in response to 100 (User Register)
    case userRegisterBadPaylaod                 = "100"
    case userRegisterInvalidCountryCode         = "100.1"
    case userRegisterInvalidPhoneNumber         = "100.2"
    case userRegisterInternalServerError        = "101"
    case userRegisterBlockedUser                = "135"
    case userRegisterLockedManyCodeTries        = "136"
    case userRegisterLockedManyResnedRequest    = "137"
    
    //in response to 101 (User Verify)
    case userVerifyBadPayload                   = "102"
    case userVerifyBadPayloadInvalidCode        = "102.1"
    case userVerifyBadPayloadInvalidUsername    = "102.2"
    case userVerifyInternalServerError          = "103"
    case userVerifyUserNotFound                 = "104"
    case userVerifyBlockedUser                  = "105"
    case userVerifyInvalidCode                  = "106"
    case userVerifyExpiredCode                  = "107"
    case userVerifyMaxTryLock                   = "108"    // waitTime
    case userVerifyTwoStepVerificationEnabled   = "184"
    
    //in response to 102 (User Login)
    case userLoginBadPayload                = "109"
    case userLoginBadPayloadInvalidToken    = "109.1"
    case userLoginInternalServerError       = "110"
    case userLoginFaield                    = "111"    // Go to registration page
    case userLoginFaieldUserIsBlocked       = "111.4"
    
    //in response to 103 (User Profile Set Email)
    case userProfileSetEmailBadPayload              = "114"
    case userProfileSetEmailBadPayloadInvalidEmail  = "114.1"
    case userProfileSetEmailInternalServerError     = "115"
    
    //in response to 104 (User Profile Set Gender)
    case userProfileSetGenderBadPayload                 = "116"
    case userProfileSetGenderBadPayloadInvalidGender    = "116.1"
    case userProfileSetGenderInternalServerError        = "117"
    
    //in response to 105 (User Profile Set Nickname)
    case userProfileSetNicknameBadPayload                   = "112"
    case userProfileSetNicknameBadPayloadInvalidNickname    = "112.1"
    case userProfileSetNicknameInternalServerError          = "113"

    //in response to 106 (User Contact Import)
    case userContactImportBadPayload                    = "118"
    case userContactImportBadPayloadInvalidPhone        = "118.1"
    case userContactImportBadPayloadInvalidFirstName    = "118.2"
    case userContactImportBadPayloadInvalidLastName     = "118.3"
    case userContactImportBadPayloadInvalidForce        = "118.4"
    case userContactImportInternalServerError           = "119"
    
    //in response to 107 (User Contact Get List)
    case userContactGetListBadPayload           = "120"
    case userContactGetListInternalServerError  = "121"

    //in response to 108 (User Contact Delete)
    case userContactDeleteBadPayload                = "122"
    case userContactDeleteBadPayloadInvalidPhone    = "122.1"
    case userContactDeleteInternalServerError       = "123"
    
    //in response to 109 (User Contact Edit)
    case userContactEditBadPayload                  = "124"
    case userContactEditBadPayloadInvalidPhone      = "124.1"
    case userContactEditBadPayloadInvalidFirstName  = "124.2"
    case userContactEditBadPayloadInvalidLastName   = "124.3"
    case userContactEditBadPayloadInvalidForce      = "124.4"
    case userContactEditInternalServerError         = "125"
    
    //in response to 110 (User Profile Get Email)
    case userProfileGetEmailBadPayload          = "128"
    case userProfileGetEmailInternalServerError = "129"
    
    //in response to 111 (User Profile Get Gender)
    case userProfileGetGenderBadPayload             = "130"
    case userProfileGetGenderInternalServerError    = "131"
    
    //in response to 112 (User Profile Get Nickname)
    case userProfileGetNicknameBadPayload           = "126"
    case userProfileGetNicknameInternalServerError  = "127"

    //in response to 113 (User Username To ID)
    case userUsernameToIdBadPayload                 = "132"
    case userUsernameToIdInternalServerError        = "133"
    case userUsernameToIdNotFound                   = "134"
    case userUsernameToIdNotFoundInvalidUsername    = "134.1"

    
    case userGetDeleteTokenLockedManyTries      = "153.1"
    case userDeleteTokenInvalidCode             = "156.1"
    case userProfileUpdateUsernameIsInvaild = "164.2"
    case userProfileUpdateUsernameHasAlreadyBeenTaken = "164.3"
    case userProfileUpdateLock                  = "175.2"

    case groupUpdateUsernameIsInvalid = "366.2"
    case groupUpdateUsernameHasAlreadyBeenTakenByAnotherUser = "366.3"
    case groupUpdateUsernameMoreThanTheAllowedUsernmaeHaveBeenSelectedByYou = "366.4"
    case groupUpdateUsernameLock = "368"
    case groupUpdateUsernameForbidden = "369"
    
    case channelUpdateUsernameIsInvalid = "455.2"
    case channelUpdateUsernameHasAlreadyBeenTakenByAnotherUser = "455.3"
    case channelUpdateUsernameMoreThanTheAllowedUsernmaeHaveBeenSelectedByYou = "455.4"
    case channelUpdateUsernameLock = "457"
    case channelUpdateUsernameForbidden = "458"
    
    case clientRoomReportDescriptionIsInvalid = "657.4"
    case clientRoomReportReportedBefore = "658"
    case clientRoomReportForbidden = "659"
    
    case userReportDescriptionIsInvalid = "10165"
    case userReportReportedBefore = "10167"
    case userReportForbidden = "10168"
    
    //in response to ... (User Two-Step Verification Get Password Deyails)
    case userTwoStepVerificationGetPasswordDetailsBadPayload = "185"
    case userTwoStepVerificationGetPasswordDetailsInternalServerError = "186"
    case userTwoStepVerificationGetPasswordDetailsForbidden = "187"
    case userTwoStepVerificationGetPasswordDetailsNoPassword = "188"
    
    //in response to ... (User Two-Step Verification Check Password)
    case userTwoStepVerificationCheckPasswordBadPayload = "10103"
    case userTwoStepVerificationCheckPasswordInternalServerError = "10104"
    case userTwoStepVerificationCheckPasswordInvalidPassword = "10105"
    case userTwoStepVerificationCheckPasswordMaxTryLock = "10106"
    case userTwoStepVerificationCheckPasswordNoPassword = "10107"
    
    case userTwoStepVerificationVerifyRecoveryEmailMaxTryLock = "10110"
    case userTwoStepVerificationVerifyRecoveryEmailExpiredToken = "10111"
    case userTwoStepVerificationVerifyRecoveryEmailInvalidToken = "10113"
    
    case userTwoStepVerificationChangeRecoveryEmailIsIncorrect_Minor2 = "10114.2"
    case userTwoStepVerificationChangeRecoveryEmailIsIncorrect_Minor3 = "10114.3"
    case userTwoStepVerificationChangeRecoveryEmailMaxTryLock = "10116"
    case userTwoStepVerificationChangeRecoveryEmailConfirmedBefore = "10119"
    
    case userTwoStepVerificationRequestRecoveryTokenNoRecoVeryEmail = "10123"
    case userTwoStepVerificationRequestRecoveryTokenMaxTryLock = "10124"
    case userTwoStepVerificationRequestRecoveryTokenForbidden = "10154"
    
    case userTwoStepVerificationRecoverPasswordByTokenMaxTryLock = "10127"
    case userTwoStepVerificationRecoverPasswordByTokenExpiredToken = "10128"
    case userTwoStepVerificationRecoverPasswordByTokenInvalidToken = "10129"

    case userTwoStepVerificationRecoverPasswordByAnswersMaxTryLock = "10133"
    case userTwoStepVerificationRecoverPasswordByAnswersInvalidAnswers = "10134"
    case userTwoStepVerificationRecoverPasswordByAnswersForbidden = "10156"

    case userTwoStepVerificationChangeHintMaxTryLock = "10143"
    case userTwoStepVerificationChangeRecoveryQuestionMaxTryLock = "10138"
    
    case userTwoStepVerificationVerifyPasswordBadPayload = "189"
    case userTwoStepVerificationVerifyPasswordInternalServerError = "190"
    case userTwoStepVerificationVerifyPasswordMaxTryLock = "191"
    case userTwoStepVerificationVerifyPasswordForbidden = "192"
    case userTwoStepVerificationVerifyPasswordNoPassword = "193"
    case userTwoStepVerificationVerifyPasswordInvalidPassword = "194"

    case userTwoStepVerificationSetPasswordNewPasswordIsInvalid = "195.2"
    case userTwoStepVerificationSetPasswordRecoveryEmailIsNotValid_Minor3 = "195.3"
    case userTwoStepVerificationSetPasswordRecoveryEmailIsNotValid_Minor4 = "195.4"
    case userTwoStepVerificationSetPasswordFirstRecoveryQuestionIsInvalid = "195.5"
    case userTwoStepVerificationSetPasswordAnswerOfTheFirstRecoveryQuestionIsInvalid = "195.6"
    case userTwoStepVerificationSetPasswordSecondRecoveryQuestionIsInvalid = "195.7"
    case userTwoStepVerificationSetPasswordAnswerOfTheSecondRecoveryQuestionIsInvalid = "195.8"
    case userTwoStepVerificationSetPasswordHintIsNotValid = "195.9"
    
    case userTwoStepVerificationSetPasswordMaxTryLock = "197"

    case userProfileSetBioBadPayload = "10161"
    
    case canNotAddThisUserAsAdminToGroup        = "323.3"
    case canNotAddThisUserAsModeratorToGroup    = "320.3"
    case canNotAddThisUserAsAdminToChannel      = "423.3"
    case canNotAddThisUserAsModeratorToChannel  = "420.3"
    case clientSearchRoomHistoryNotFound        = "620"
    case clinetJoinByUsernameForbidden          = "637.2"
    
    
    //in response to 603 (Client Get Room History)
    case clinetGetRoomHistoryNoMoreMessage = "617"
    //client Join by InvitedLink
    case clientJoinByInviteLinkForbidden = "632.100"
    case clientJoinByInviteLinkAlreadyJoined = "633.1"
    
}

//MARK: -
class IGErrorRequest : IGRequest {
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPErrorResponse) -> (error: IGError, wait: IGErrorWaitTime) {
            let majorCode: Int              = Int(responseProtoMessage.igpMajorCode)
            let minorCode: Int              = Int(responseProtoMessage.igpMinorCode)
            let waitTime:  IGErrorWaitTime  = IGErrorWaitTime(responseProtoMessage.igpWait)
            let errorCode           = "\(majorCode)"
            let errorCodeWithMinor  = "\(majorCode).\(minorCode)"
            
            var errorCodeEnum: IGError = .unknownError
            
            if let error = IGError(rawValue: errorCodeWithMinor) {
                errorCodeEnum = error
            } else if let error = IGError(rawValue: errorCode) {
                errorCodeEnum = error
            }
            switch errorCodeEnum {
            case .setNickname:
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                if appDelegate.isNeedToSetNickname {
                appDelegate.showRegistrationSetpProfileInfo()
                    
                }
            case .loginRequest:
                let appManager = IGAppManager.sharedManager
                appManager.login()
                
                
            default:
                break
            }

            
            
            
            return (errorCodeEnum, waitTime)
        }
    }
}
