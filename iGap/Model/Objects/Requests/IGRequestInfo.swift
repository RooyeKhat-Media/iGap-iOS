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

class IGInfoLocationRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate() -> IGRequestWrapper{
            let locationInfoRequestBuilder = IGPInfoLocation.Builder()
            return IGRequestWrapper(messageBuilder: locationInfoRequestBuilder, actionID: 500)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPInfoLocationResponse ) -> IGCountryInfo {
            let country = IGCountryInfo()
            country.countryISO = responseProtoMessage.igpIsoCode
            country.countryCode = responseProtoMessage.igpCallingCode
            country.countryName = responseProtoMessage.igpName
            country.codePattern = responseProtoMessage.igpPattern
            country.codeRegex = responseProtoMessage.igpRegex
            country.codePatternMask = responseProtoMessage.igpPattern
            
            return country
            
        }
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {}
        override class func error() {}
        override class func timeout() {}
    }
}

//MARK: -
class IGInfoCountryRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(countryCode : String) -> IGRequestWrapper{
            let countryInfoRequestBuilder = IGPInfoCountry.Builder()
            countryInfoRequestBuilder.setIgpIsoCode(countryCode)
            return IGRequestWrapper(messageBuilder: countryInfoRequestBuilder, actionID: 501)
        }
    }
    
    class Handler : IGRequest.Handler{
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {}
        override class func error() {}
        override class func timeout() {}
    }
}

//MARK: -
class IGInfoTimeRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate() -> IGRequestWrapper{
            let timeInfoRequestBuilder = IGPInfoTime.Builder()
            return IGRequestWrapper(messageBuilder: timeInfoRequestBuilder, actionID: 502)
        }
    }
    
    class Handler : IGRequest.Handler{
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {}
        override class func error() {}
        override class func timeout() {}
    }
}

//MARK: -
class IGInfoPageRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(pageID: String) -> IGRequestWrapper{
            let pageInfoRequestBuilder = IGPInfoPage.Builder()
            pageInfoRequestBuilder.setIgpId(pageID)
            return IGRequestWrapper(messageBuilder: pageInfoRequestBuilder, actionID: 503)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPInfoPageResponse) -> String {
            return responseProtoMessage.igpBody
        }
        
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {}
        override class func error() {}
        override class func timeout() {}
    }
}

