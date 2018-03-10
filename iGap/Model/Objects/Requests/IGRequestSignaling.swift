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

class IGSignalingGetConfigurationRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate() -> IGRequestWrapper {
            return IGRequestWrapper(message: IGPSignalingGetConfiguration(), actionID: 900)
        }
    }

    class Handler : IGRequest.Handler{
        class func interpret(response reponseProtoMessage:IGPSignalingGetConfigurationResponse) {
            IGFactory.shared.setSignalingConfiguration(configuration: reponseProtoMessage)
            for ice in reponseProtoMessage.igpIceServer {
                IGAppManager.iceServersStatic.append(RTCIceServer(urlStrings:[ice.igpURL],username:ice.igpUsername,credential:ice.igpCredential))
            }
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
            IGCall.sendLeaveRequest = true
        }

        override class func handlePush(responseProtoMessage: Message) {
            IGCall.sendLeaveRequest = true
            switch responseProtoMessage {
            case let offerProtoResponse as IGPSignalingOfferResponse:
                RTCClient.getInstance().startConnection()
                RTCClient.getInstance().sendRinging()
                RTCClient.getInstance().createAnswerForOfferReceived(withRemoteSDP: offerProtoResponse.igpCallerSdp)
                
                DispatchQueue.main.async {
                    (UIApplication.shared.delegate as! AppDelegate).showCallPage(userId: offerProtoResponse.igpCallerUserID)
                }
                
                break
            default:
                break
            }
        }
    }
}


class IGSignalingRingingRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate() -> IGRequestWrapper {
            return IGRequestWrapper(message: IGPSignalingRinging(), actionID: 902)
        }
    }

    class Handler : IGRequest.Handler{
        class func interpret(response reponseProtoMessage:IGPSignalingRingingResponse)  {}

        override class func handlePush(responseProtoMessage: Message) {
            guard let delegate = RTCClient.getInstance().callStateDelegate else {
                return
            }
            delegate.onStateChange(state: RTCClientConnectionState.Ringing)
        }
    }
}

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
            IGCall.sendLeaveRequest = true
        }

        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let acceptProtoResponse as IGPSignalingAcceptResponse:
                IGCall.sendLeaveRequest = true
                RTCClient.getInstance().handleAnswerReceived(withRemoteSDP: acceptProtoResponse.igpCalledSdp)
            default:
                break
            }
        }
    }
}


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
        class func interpret(response reponseProtoMessage:IGPSignalingCandidateResponse)  {}

        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let candidateResponse as IGPSignalingCandidateResponse:
                RTCClient.getInstance().addIceCandidate(iceCandidate: RTCIceCandidate(sdp: candidateResponse.igpPeerCandidate,sdpMLineIndex: candidateResponse.igpPeerSdpMLineIndex ,sdpMid: candidateResponse.igpPeerSdpMID))
                break
            default:
                break
            }
        }
    }
}


class IGSignalingLeaveRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate() -> IGRequestWrapper {
            return IGRequestWrapper(message: IGPSignalingLeave(), actionID: 905)
        }
    }

    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPSignalingLeaveResponse)  {
            
            guard let delegate = RTCClient.getInstance().callStateDelegate else {
                return
            }
            
            switch responseProtoMessage.igpType {
                
            case IGPSignalingLeaveResponse.IGPType.accepted:
                delegate.onStateChange(state: RTCClientConnectionState.Accepted)
                break
                
            case IGPSignalingLeaveResponse.IGPType.disconnected:
                delegate.onStateChange(state: RTCClientConnectionState.Disconnected)
                break
                
            case IGPSignalingLeaveResponse.IGPType.finished:
                delegate.onStateChange(state: RTCClientConnectionState.Finished)
                break
                
            case IGPSignalingLeaveResponse.IGPType.missed:
                delegate.onStateChange(state: RTCClientConnectionState.Missed)
                break
                
            case IGPSignalingLeaveResponse.IGPType.notAnswered:
                delegate.onStateChange(state: RTCClientConnectionState.NotAnswered)
                break
                
            case IGPSignalingLeaveResponse.IGPType.rejected:
                delegate.onStateChange(state: RTCClientConnectionState.Rejected)
                break
                
            case IGPSignalingLeaveResponse.IGPType.tooLong:
                delegate.onStateChange(state: RTCClientConnectionState.TooLong)
                break
                
            case IGPSignalingLeaveResponse.IGPType.unavailable:
                delegate.onStateChange(state: RTCClientConnectionState.Unavailable)
                break
                
            default:
                break
            }
            
            RTCClient.getInstance().disconnect()
        }

        override class func handlePush(responseProtoMessage: Message) {
            if let signalingResponse = responseProtoMessage as? IGPSignalingLeaveResponse {
                self.interpret(response: signalingResponse)
            }
        }
    }
}


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


class IGSignalingGetLogRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(offset: Int32, limit: Int32) -> IGRequestWrapper {
            var signalingGetLog = IGPSignalingGetLog()
            var pagination = IGPPagination()
            pagination.igpLimit = limit
            pagination.igpOffset = offset
            signalingGetLog.igpPagination = pagination
            return IGRequestWrapper(message: signalingGetLog, actionID: 907)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response reponseProtoMessage:IGPSignalingGetLogResponse) -> Int {
            
            for callLog in reponseProtoMessage.igpSignalingLog {
                IGFactory.shared.setCallLog(callLog: callLog)
            }
            
            return reponseProtoMessage.igpSignalingLog.count
        }
        
        override class func handlePush(responseProtoMessage: Message) {
            if let callLogResponse = responseProtoMessage as? IGPSignalingGetLogResponse {
                self.interpret(response: callLogResponse)
            }
        }
    }
}


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
            IGFactory.shared.clearCallLog()
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
        class func interpret(response reponseProtoMessage:IGPSignalingRateResponse)  {}

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
