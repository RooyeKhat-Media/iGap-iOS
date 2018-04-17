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

class IGGeoGetRegisterStatus : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate() -> IGRequestWrapper {
            return IGRequestWrapper(message: IGPGeoGetRegisterStatus(), actionID: 1000)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response reponseProtoMessage:IGPGeoGetRegisterStatusResponse) {
            reponseProtoMessage.igpEnable
        }
        
        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let getRegisterStatus as IGPGeoGetRegisterStatusResponse:
                self.interpret(response: getRegisterStatus)
            default:
                break
            }
        }
    }
}

class IGGeoRegister : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(enable: Bool) -> IGRequestWrapper {
            var geoRegister = IGPGeoRegister()
            geoRegister.igpEnable = enable
            return IGRequestWrapper(message: geoRegister, actionID: 1001)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response reponseProtoMessage:IGPGeoRegisterResponse) {
            reponseProtoMessage.igpEnable
        }
        
        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let getRegisterStatus as IGPGeoRegisterResponse:
                self.interpret(response: getRegisterStatus)
            default:
                break
            }
        }
    }
}

class IGGeoUpdatePosition : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(lat: Double, lon: Double) -> IGRequestWrapper {
            var geoUpdatePosition = IGPGeoUpdatePosition()
            geoUpdatePosition.igpLat = lat
            geoUpdatePosition.igpLon = lon
            return IGRequestWrapper(message: geoUpdatePosition, actionID: 1002)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response reponseProtoMessage:IGPGeoUpdatePositionResponse) {

        }
        
        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let geoUpdatePosition as IGPGeoUpdatePositionResponse:
                self.interpret(response: geoUpdatePosition)
            default:
                break
            }
        }
    }
}

class IGGeoGetComment : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(userId: Int64) -> IGRequestWrapper {
            var getComment = IGPGeoGetComment()
            getComment.igpUserID = userId
            return IGRequestWrapper(message: getComment, actionID: 1003)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response reponseProtoMessage:IGPGeoGetCommentResponse) {
            reponseProtoMessage.igpComment
        }
        
        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let getComment as IGPGeoGetCommentResponse:
                self.interpret(response: getComment)
            default:
                break
            }
        }
    }
}


class IGGeoUpdateComment : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(comment: String) -> IGRequestWrapper {
            var updateComment = IGPGeoUpdateComment()
            updateComment.igpComment = comment
            return IGRequestWrapper(message: updateComment, actionID: 1004)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response reponseProtoMessage:IGPGeoUpdateCommentResponse) {
            reponseProtoMessage.igpComment
        }
        
        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let updateComment as IGPGeoUpdateCommentResponse:
                self.interpret(response: updateComment)
            default:
                break
            }
        }
    }
}

class IGGeoGetNearbyDistance : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(lat: Double, lon: Double) -> IGRequestWrapper {
            var nearbyDistance = IGPGeoGetNearbyDistance()
            nearbyDistance.igpLat = lat
            nearbyDistance.igpLon = lon
            return IGRequestWrapper(message: nearbyDistance, actionID: 1005)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response reponseProtoMessage:IGPGeoGetNearbyDistanceResponse) {
            for nearbyDistance in reponseProtoMessage.igpResult {
                IGFactory.shared.setMapNearbyUsersDistance(nearbyDistance: nearbyDistance)
            }
        }
        
        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let nearbyDistance as IGPGeoGetNearbyDistanceResponse:
                self.interpret(response: nearbyDistance)
            default:
                break
            }
        }
    }
}

class IGGeoGetCoordinateDistance : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(lat: Double, lon: Double) -> IGRequestWrapper {
            var nearbyCoordinate = IGPGeoGetNearbyCoordinate()
            nearbyCoordinate.igpLat = lat
            nearbyCoordinate.igpLon = lon
            return IGRequestWrapper(message: nearbyCoordinate, actionID: 1006)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response reponseProtoMessage:IGPGeoGetNearbyCoordinateResponse) {
            for result in reponseProtoMessage.igpResult {
                result.igpUserID
                result.igpHasComment
                result.igpLat
                result.igpLon
            }
        }
        
        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let nearbyDistance as IGPGeoGetNearbyCoordinateResponse:
                self.interpret(response: nearbyDistance)
            default:
                break
            }
        }
    }
}

class IGGeoGetConfiguration : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(lat: Double, lon: Double) -> IGRequestWrapper {
            return IGRequestWrapper(message: IGPGeoGetConfiguration(), actionID: 1007)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response reponseProtoMessage:IGPGeoGetConfigurationResponse) {
            for result in reponseProtoMessage.igpTileServer {
                result.igpBaseURL
            }
            reponseProtoMessage.igpCacheID
        }
        
        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let nearbyDistance as IGPGeoGetConfigurationResponse:
                self.interpret(response: nearbyDistance)
            default:
                break
            }
        }
    }
}

