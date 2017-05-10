//
//  IGPushResponse.swift
//  iGap
//
//  Created by PC on 5/3/17.
//  Copyright © 2017 RooyeKhat Media. All rights reserved.
//

import Foundation
import IGProtoBuff
import ProtocolBuffers


class IGPushUserInfoExpiredRequest : IGRequest {
    class Generator: IGRequest.Generator {
        class func generate() {
            
        }
    }
    
    class Handler : IGRequest.Handler {
        class func interpret( response responseProtoMessage: IGPPushUserInfoExpiredResponse) {
            let userID = responseProtoMessage.igpUserId
            IGFactory.shared.updateUserInfoExpired(userID)
            
        }
        
        override class func handlePush(responseProtoMessage:GeneratedResponseMessage) {
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

