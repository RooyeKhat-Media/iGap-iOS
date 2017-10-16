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

//MARK: -
class IGSignalingGetConfigurationRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(userEmail: String) -> IGRequestWrapper {
            let getConfigurationRequestMessage = IGPSignalingGetConfiguration()
            return IGRequestWrapper(message: getConfigurationRequestMessage, actionID: 900)
        }
    }

    class Handler : IGRequest.Handler{
        class func interpret(response reponseProtoMessage:IGPSignalingGetConfigurationResponse) {
        }

        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let getConfigurationProtoResponse as IGPSignalingGetConfigurationResponse:
                self.interpret(response: getConfigurationProtoResponse)
            default:
                break
            }
        }

    }
}

//MARK: -
class IGSignalingOfferRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(calledUserId: Int64,type: IGPSignalingOffer.IGPType,callerSdp : String) -> IGRequestWrapper {
            var offerRequestMessage = IGPSignalingOffer()
            offerRequestMessage.igpCalledUserID = calledUserId
            offerRequestMessage.igpType = type
            offerRequestMessage.igpCallerSdp = callerSdp
            return IGRequestWrapper(message: offerRequestMessage, actionID: 901)
        }
    }

    class Handler : IGRequest.Handler{
        class func interpret(response reponseProtoMessage:IGPSignalingOfferResponse) {
        }

        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let offerProtoResponse as IGPSignalingOfferResponse:
                self.interpret(response: offerProtoResponse)
            default:
                break
            }
        }

    }
}

//MARK: -
class IGSignalingRingingRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(userEmail: String) -> IGRequestWrapper {
            var ringingRequestMessage = IGPSignalingRinging()
            return IGRequestWrapper(message: ringingRequestMessage, actionID: 902)
        }
    }

    class Handler : IGRequest.Handler{
        class func interpret(response reponseProtoMessage:IGPSignalingRingingResponse)  {

        }

        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let ringingProtoResponse as IGPSignalingRingingResponse:
                self.interpret(response: ringingProtoResponse)
            default:
                break
            }
        }

    }
}

//MARK: -
class IGSignalingAcceptRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(calledSdp: String) -> IGRequestWrapper {
            var acceptRequestMessage = IGPSignalingAccept()
            acceptRequestMessage.igpCalledSdp = calledSdp
            return IGRequestWrapper(message: acceptRequestMessage, actionID: 903)
        }
    }

    class Handler : IGRequest.Handler{
        class func interpret(response reponseProtoMessage:IGPSignalingAcceptResponse)  {

        }

        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let acceptProtoResponse as IGPSignalingAcceptResponse:
                self.interpret(response: acceptProtoResponse)
            default:
                break
            }
        }

    }
}

//MARK: -
class IGSignalingCandidateRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(candidate: String,sdpMId: String,sdpMLineIndex: Int32) -> IGRequestWrapper {
            var candidateRequestMessage = IGPSignalingCandidate()
            candidateRequestMessage.igpCandidate = candidate
            candidateRequestMessage.igpSdpMID = sdpMId
            candidateRequestMessage.igpSdpMLineIndex = sdpMLineIndex
            return IGRequestWrapper(message: candidateRequestMessage, actionID: 904)
        }
    }

    class Handler : IGRequest.Handler{
        class func interpret(response reponseProtoMessage:IGPSignalingCandidateResponse)  {

        }

        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let candidateProtoResponse as IGPSignalingCandidateResponse:
                self.interpret(response: candidateProtoResponse)
            default:
                break
            }
        }

    }
}

//MARK: -
class IGSignalingLeaveRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(userEmail: String) -> IGRequestWrapper {
            var leaveRequestMessage = IGPSignalingLeave()
            return IGRequestWrapper(message: leaveRequestMessage, actionID: 905)
        }
    }

    class Handler : IGRequest.Handler{
        class func interpret(response reponseProtoMessage:IGPSignalingLeaveResponse)  {

        }

        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let leaveProtoResponse as IGPSignalingLeaveResponse:
                self.interpret(response: leaveProtoResponse)
            default:
                break
            }
        }

    }
}

//MARK: -
class IGSignalingSessionHoldRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(hold: Bool) -> IGRequestWrapper {
            var sessionHoldRequestMessage = IGPSignalingSessionHold()
            sessionHoldRequestMessage.igpHold = hold
            return IGRequestWrapper(message: sessionHoldRequestMessage, actionID: 906)
        }
    }

    class Handler : IGRequest.Handler{
        class func interpret(response reponseProtoMessage:IGPSignalingSessionHoldResponse)  {

        }

        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let sessionHoldProtoResponse as IGPSignalingSessionHoldResponse:
                self.interpret(response: sessionHoldProtoResponse)
            default:
                break
            }
        }

    }
}

//MARK: -
class IGSignalingGetLogRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate() -> IGRequestWrapper {
            var getLogRequestMessage = IGPSignalingGetLog()
            return IGRequestWrapper(message: getLogRequestMessage, actionID: 907)
        }
    }

    class Handler : IGRequest.Handler{
        class func interpret(response reponseProtoMessage:IGPSignalingGetLogResponse)  {

        }

        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let getLogProtoResponse as IGPSignalingGetLogResponse:
                self.interpret(response: getLogProtoResponse)
            default:
                break
            }
        }

    }
}

//MARK: -
class IGSignalingClearLogRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(clearId: Int64) -> IGRequestWrapper {
            var clearLogRequestMessage = IGPSignalingClearLog()
            clearLogRequestMessage.igpClearID = clearId
            return IGRequestWrapper(message: clearLogRequestMessage, actionID: 908)
        }
    }

    class Handler : IGRequest.Handler{
        class func interpret(response reponseProtoMessage:IGPSignalingClearLogResponse)  {

        }

        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let clearLogProtoResponse as IGPSignalingClearLogResponse:
                self.interpret(response: clearLogProtoResponse)
            default:
                break
            }
        }

    }
}

//MARK: -
class IGSignalingRateRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(id: Int64,rate: Int32,reason: String) -> IGRequestWrapper {
            var rateRequestMessage = IGPSignalingRate()
            rateRequestMessage.igpID = id
            rateRequestMessage.igpRate = rate
            rateRequestMessage.igpReason = reason
            return IGRequestWrapper(message: rateRequestMessage, actionID: 909)
        }
    }

    class Handler : IGRequest.Handler{
        class func interpret(response reponseProtoMessage:IGPSignalingRateResponse)  {

        }

        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let rateProtoResponse as IGPSignalingRateResponse:
                self.interpret(response: rateProtoResponse)
            default:
                break
            }
        }

    }
}
