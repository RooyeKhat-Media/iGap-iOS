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
import RealmSwift
import WebRTC

class IGMplGetBillToken : IGRequest {    
    class Generator : IGRequest.Generator{
        class func generate(billId: Int64, payId: Int64) -> IGRequestWrapper {
            var mplGetBillToken = IGPMplGetBillToken()
            mplGetBillToken.igpBillID = billId
            mplGetBillToken.igpPayID = payId
            return IGRequestWrapper(message: mplGetBillToken, actionID: 9100)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response reponseProtoMessage:IGPMplGetBillTokenResponse) {}
        override class func handlePush(responseProtoMessage: Message) {}
    }
}

class IGMplGetTopupToken : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(number: Int64, amount: Int64, type: IGPMplGetTopupToken.IGPType) -> IGRequestWrapper {
            var mplGetTopupToken = IGPMplGetTopupToken()
            mplGetTopupToken.igpChargeMobileNumber = number
            mplGetTopupToken.igpAmount = amount
            mplGetTopupToken.igpType = type
            return IGRequestWrapper(message: mplGetTopupToken, actionID: 9101)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response reponseProtoMessage:IGPMplGetTopupTokenResponse) {}
        override class func handlePush(responseProtoMessage: Message) {}
    }
}

class IGBillInquiryMci : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(mobileNumber: Int64) -> IGRequestWrapper {
            var billInquiryMci = IGPBillInquiryMci()
            billInquiryMci.igpMobileNumber = mobileNumber
            return IGRequestWrapper(message: billInquiryMci, actionID: 9200)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response reponseProtoMessage:IGPBillInquiryMciResponse) {}
        override class func handlePush(responseProtoMessage: Message) {}
    }
}

class IGBillInquiryTelecom : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(provinceCode: Int32, telephoneNumber: Int64) -> IGRequestWrapper {
            var billInquiryTelecom = IGPBillInquiryTelecom()
            billInquiryTelecom.igpProvinceCode = provinceCode
            billInquiryTelecom.igpTelephoneNumber = telephoneNumber
            return IGRequestWrapper(message: billInquiryTelecom, actionID: 9201)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response reponseProtoMessage:IGPBillInquiryMciResponse) {}
        override class func handlePush(responseProtoMessage: Message) {}
    }
}



