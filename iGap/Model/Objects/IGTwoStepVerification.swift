/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the RooyeKhat Media Company - www.RooyeKhat.co
 * All rights reserved.
 */

import UIKit
import SwiftProtobuf
import IGProtoBuff

class IGTwoStepVerification: NSObject {

    var password: String?
    var question1: String?
    var answer1: String?
    var question2: String?
    var answer2: String?
    var hint: String?
    var email: String?
    var hasVerifiedEmailAddress: Bool?
    var unverifiedEmailPattern: String?
    
    
    init(protoResponse: IGPUserTwoStepVerificationGetPasswordDetailResponse) {
        super.init()
        if protoResponse.igpQuestionOne != "" {
            self.question1 = protoResponse.igpQuestionOne
        }
        if protoResponse.igpQuestionTwo != "" {
            self.question2 = protoResponse.igpQuestionTwo
        }
        if protoResponse.igpHint != "" {
            self.hint = protoResponse.igpHint
        }
        self.hasVerifiedEmailAddress = protoResponse.igpHasConfirmedRecoveryEmail
        if protoResponse.igpUnconfirmedEmailPattern != "" {
            self.unverifiedEmailPattern = protoResponse.igpUnconfirmedEmailPattern
        }
    }
    
}
