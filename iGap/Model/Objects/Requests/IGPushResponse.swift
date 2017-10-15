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


class IGPushLoginTokenRequest : IGRequest {
    class Handler : IGRequest.Handler {
        class func interpret( response responseProtoMessage: IGPPushLoginTokenResponse) {
            let userID = responseProtoMessage.igpUserID
            let token = responseProtoMessage.igpToken
            let username = responseProtoMessage.igpUsername
            let authorHash = responseProtoMessage.igpAuthorHash
            
            let notificatinUserInfo = ["userID": userID,
                                       "token": token,
                                       "username": username,
                                       "authorHash": authorHash] as [String : Any]
            
            let notification = Notification(name: IGNotificationPushLoginToken.name, object: nil, userInfo: notificatinUserInfo)
            NotificationCenter.default.post(notification)
        }
        
        override class func handlePush(responseProtoMessage:Message) {
            switch responseProtoMessage {
            case let pushLoginTokenResponse as IGPPushLoginTokenResponse:
                self.interpret(response: pushLoginTokenResponse)
                break
            default:
                break
            }
        }
    }
}


class IGPushTwoStepVerificationRequest : IGRequest {
    class Handler : IGRequest.Handler {
        class func interpret( response responseProtoMessage: IGPPushTwoStepVerificationResponse) {
            let userID = responseProtoMessage.igpUserID
            let username = responseProtoMessage.igpUsername
            let authorHash = responseProtoMessage.igpAuthorHash
            
            let notificatinUserInfo = ["userID": userID,
                                       "username": username,
                                       "authorHash": authorHash] as [String : Any]
            
            let notification = Notification(name: IGNotificationPushTwoStepVerification.name, object: nil, userInfo: notificatinUserInfo)
            NotificationCenter.default.post(notification)
        }
        
        override class func handlePush(responseProtoMessage:Message) {
            switch responseProtoMessage {
            case let pushTwoStepVerificationResponse as IGPPushTwoStepVerificationResponse:
                self.interpret(response: pushTwoStepVerificationResponse)
                break
            default:
                break
            }
        }
    }
}

class IGPushUserInfoExpiredRequest : IGRequest {
    class Handler : IGRequest.Handler {
        class func interpret( response responseProtoMessage: IGPPushUserInfoExpiredResponse) {
            let userID = responseProtoMessage.igpUserID
            IGFactory.shared.updateUserInfoExpired(userID)
            
        }
        
        override class func handlePush(responseProtoMessage:Message) {
            switch responseProtoMessage {
            case let pushUserInfoExpireResponse as IGPPushUserInfoExpiredResponse:
                self.interpret(response: pushUserInfoExpireResponse)
                break
            default:
                break
            }

        }
    }
}

class IGPushRateSignalingRequest : IGRequest {
    class Handler : IGRequest.Handler {
        class func interpret( response responseProtoMessage: IGPPushRateSignalingResponse) {

        }

        override class func handlePush(responseProtoMessage:Message) {
            switch responseProtoMessage {
            case let pushRateSignalingResponse as IGPPushRateSignalingResponse:
                self.interpret(response: pushRateSignalingResponse)
                break
            default:
                break
            }

        }
    }
}

