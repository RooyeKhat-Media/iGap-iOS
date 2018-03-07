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
import WebRTC
import IGProtoBuff
import SwiftProtobuf
import RealmSwift

public enum RTCClientState {
    case disconnected
    case connecting
    case connected
}

public protocol RTCClientDelegate: class {
    func rtcClient(client : RTCClient, startCallWithSdp sdp: String)
    func rtcClient(client : RTCClient, didReceiveLocalVideoTrack localVideoTrack: RTCVideoTrack)
    func rtcClient(client : RTCClient, didReceiveRemoteVideoTrack remoteVideoTrack: RTCVideoTrack)
    func rtcClient(client : RTCClient, didReceiveLocalAudioTrack localAudioTrack: RTCAudioTrack)
    func rtcClient(client : RTCClient, didReceiveRemoteAudioTrack remoteAudioTrack: RTCAudioTrack)
    func rtcClient(client : RTCClient, didReceiveError error: Error)
    func rtcClient(client : RTCClient, didChangeConnectionState connectionState: RTCIceConnectionState)
    func rtcClient(client : RTCClient, didChangeState state: RTCClientState)
    func rtcClient(client : RTCClient, didGenerateIceCandidate iceCandidate: RTCIceCandidate)
}

public enum RTCClientConnectionState {
    
    // enums for resolve iceCondidate State
    case New
    case Connecting // was checking before
    case Connected
    case Completed
    case Failed
    case Closed
    case Count
    
    // enums for resolve protoResonse State
    case Accepted
    case Finished
    case Missed
    case NotAnswered
    case Rejected
    case TooLong
    case Unavailable
    
    // enums for resolve protoResonse/iceCondidate State
    case Disconnected
    
    // enums for other state
    case IncommingCall
    case Ringing
    case Dialing
    
    // enums for connection error
    case signalingOfferForbiddenUserIsBlocked
    case signalingOfferForbiddenDialedNumberIsNotActive
    case signalingOfferForbiddenYouAreTalkingWithYourOtherDevices
    case signalingOfferForbiddenTheUserIsInConversation
    case signalingOfferForbiddenIsNotAllowedToCommunicate
}

public extension RTCClientDelegate {
    // add default implementation to extension for optional methods
    func rtcClient(client : RTCClient, didReceiveError error: Error) {
        
    }
    
    func rtcClient(client : RTCClient, didChangeConnectionState connectionState: RTCIceConnectionState) {
        
    }
    
    func rtcClient(client : RTCClient, didChangeState state: RTCClientState) {
        
    }
}

public class RTCClient: NSObject {
    static var instanceValue: RTCClient!
    fileprivate var iceServers: [RTCIceServer] = []
    fileprivate var peerConnection: RTCPeerConnection?
    fileprivate var connectionFactory: RTCPeerConnectionFactory = RTCPeerConnectionFactory()
    fileprivate var remoteIceCandidates: [RTCIceCandidate] = []
    fileprivate var isVideoCall = true
    var callStateDelegate: CallStateObserver!
    static var needNewInstance = true
    
    internal static var mediaStream: RTCMediaStream!
    internal static var offerSdp: RTCSessionDescription!
    
    public weak var delegate: RTCClientDelegate?
    
    fileprivate let audioCallConstraint = RTCMediaConstraints(mandatoryConstraints: ["OfferToReceiveAudio" : "true"],optionalConstraints: nil)
    fileprivate let videoCallConstraint = RTCMediaConstraints(mandatoryConstraints: ["OfferToReceiveAudio" : "true", "OfferToReceiveVideo": "true"],optionalConstraints: nil)
    
    var callConstraint : RTCMediaConstraints {
        return self.isVideoCall ? self.audioCallConstraint : self.videoCallConstraint
    }
    
    fileprivate let defaultConnectionConstraint = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: ["DtlsSrtpKeyAgreement": "true"])
    
    fileprivate var mediaConstraint: RTCMediaConstraints {
        let constraints = ["minWidth": "0", "minHeight": "0", "maxWidth" : "480", "maxHeight": "640"]
        return RTCMediaConstraints(mandatoryConstraints: constraints, optionalConstraints: nil)
    }
    
    private var state: RTCClientState = .connecting {
        didSet {
            self.delegate?.rtcClient(client: self, didChangeState: state)
        }
    }
    
    static func getInstance() -> RTCClient{
        if RTCClient.instanceValue == nil {
            instanceValue = RTCClient(iceServers: IGAppManager.iceServersStatic,videoCall: false)
            return instanceValue
        }
        return instanceValue
    }
    
    public override init() {
        super.init()
    }
    
    public convenience init(iceServers: [RTCIceServer], videoCall: Bool = false) {
        self.init()
        self.isVideoCall = videoCall
        
        if iceServers.count == 0 {
            let realm = try! Realm()
            if let signaling = try! realm.objects(IGSignaling.self).first {
                for ice in signaling.iceServer {
                    IGAppManager.iceServersStatic.append(RTCIceServer(urlStrings:[ice.url],username:ice.username,credential:ice.credential))
                }
                
                self.iceServers = IGAppManager.iceServersStatic
                self.configure()
            } else {
                IGSignalingGetConfigurationRequest.Generator.generate().success({ (protoResponse) in
                    
                    if let configurationResponse = protoResponse as? IGPSignalingGetConfigurationResponse {
                        
                        for ice in configurationResponse.igpIceServer {
                            IGAppManager.iceServersStatic.append(RTCIceServer(urlStrings:[ice.igpURL],username:ice.igpUsername,credential:ice.igpCredential))
                        }
                        
                        // TODO - Not Start Call From Here !?
                        self.iceServers = IGAppManager.iceServersStatic
                        self.configure()
                    }
                    
                }).error ({ (errorCode, waitTime) in
                    
                    switch errorCode {
                    case .timeout:
                        break
                    default:
                        break
                    }
                    
                }).send()
            }
        } else {
            self.iceServers = iceServers
            self.configure()
        }
    }
    
    deinit {
        guard let peerConnection = self.peerConnection else {
            return
        }
        if let stream = peerConnection.localStreams.first {
            peerConnection.remove(stream)
        }
    }
    
    func initCallStateObserver(stateDelegate: CallStateObserver){
        callStateDelegate = stateDelegate
    }
    
    public func configure() {
        initialisePeerConnectionFactory()
        initialisePeerConnection()
    }
    
    public func startConnection() {
        guard let peerConnection = self.peerConnection else {
            return
        }
        self.state = .connecting
        
        IGCall.callStateStatic = "Connecting..."
        let localStream = self.localStream()
        peerConnection.add(localStream)
        
        if let localAudioTrack = localStream.audioTracks.first {
            self.delegate?.rtcClient(client: self, didReceiveLocalAudioTrack: localAudioTrack)
        }
        
        //if let localVideoTrack = localStream.videoTracks.first {
        //    self.delegate?.rtcClient(client: self, didReceiveLocalVideoTrack: localVideoTrack)
        //}
    }
    
    public func disconnect() {
        guard let peerConnection = self.peerConnection else {
            return
        }
        peerConnection.close()
        if let stream = peerConnection.localStreams.first {
            peerConnection.remove(stream)
        }
        RTCClient.instanceValue = nil
        self.delegate?.rtcClient(client: self, didChangeState: .disconnected)
    }
    
    public func makeOffer(userId: Int64) {
        guard let peerConnection = self.peerConnection else {
            return
        }
        
        peerConnection.offer(for: self.callConstraint, completionHandler: { [weak self]  (sdp, error) in
            guard let this = self else { return }
            if let error = error {
                this.delegate?.rtcClient(client: this, didReceiveError: error)
            } else {
                RTCClient.offerSdp = sdp //this.handleSdpGenerated(sdpDescription: sdp) //do following action after accept received
                self?.sendOffer(userId: userId, sdp: (sdp?.sdp)!)
            }
        })
    }
    
    public func handleAnswerReceived(withRemoteSDP remoteSdp: String?) {
        
        /* Hint: should set this value after than received called sdp for avoid from send candicate before send accept
         * because candidate will be runned when set local and remote description
         */
        RTCClient.getInstance().handleSdpGenerated(sdpDescription: RTCClient.offerSdp)
        
        guard let remoteSdp = remoteSdp else {
            return
        }
        
        // Add remote description
        let sessionDescription = RTCSessionDescription.init(type: .answer, sdp: remoteSdp)
        self.peerConnection?.setRemoteDescription(sessionDescription, completionHandler: { [weak self] (error) in
            guard let this = self else { return }
            if let error = error {
                this.delegate?.rtcClient(client: this, didReceiveError: error)
            } else {
                this.handleRemoteDescriptionSet()
                this.state = .connecting
            }
        })
    }
    
    public func createAnswerForOfferReceived(withRemoteSDP remoteSdp: String?) {
        guard let remoteSdp = remoteSdp, let peerConnection = self.peerConnection else {
            return
        }
        // Add remote description
        let sessionDescription = RTCSessionDescription(type: .offer, sdp: remoteSdp)
        self.peerConnection?.setRemoteDescription(sessionDescription, completionHandler: { [weak self] (error) in
            guard let this = self else {
                return
            }
            if let error = error {
                this.delegate?.rtcClient(client: this, didReceiveError: error)
            } else {
                this.handleRemoteDescriptionSet()
            }
        })
    }
    
    public func answerCall(){
        self.peerConnection?.answer(for: self.callConstraint, completionHandler: { (sdp, error) in
            if let error = error {
                self.delegate?.rtcClient(client: self, didReceiveError: error)
            } else {
                self.sendAccept(sdp: (sdp?.sdp)!)
                self.handleSdpGenerated(sdpDescription: sdp)
                self.state = .connected
            }
        })
    }
    
    public func addIceCandidate(iceCandidate: RTCIceCandidate) {
        // Set ice candidate after setting remote description
        if self.peerConnection?.remoteDescription != nil {
            self.peerConnection?.add(iceCandidate)
        } else {
            self.remoteIceCandidates.append(iceCandidate)
        }
    }
    
    /*********************************************************/
    /******************* My Proto Requests *******************/
    /*********************************************************/
    
    private func sendOffer(userId: Int64, sdp: String){
        IGSignalingOfferRequest.Generator.generate(calledUserId: userId, type: IGPSignalingOffer.IGPType.voiceCalling,callerSdp: sdp).success({ (protoResponse) in
        }).error ({ (errorCode, waitTime) in
            
            guard let delegate = self.callStateDelegate else {
                return
            }
            
            switch errorCode {
                
            case .timeout:
                self.sendOffer(userId: userId, sdp: sdp)
                break
                
            case .signalingOfferForbiddenUserIsBlocked:
                delegate.onStateChange(state: .signalingOfferForbiddenUserIsBlocked)
                break
                
            case .signalingOfferForbiddenDialedNumberIsNotActive:
                delegate.onStateChange(state: .signalingOfferForbiddenDialedNumberIsNotActive)
                break
                
            case .signalingOfferForbiddenTheUserIsInConversation:
                delegate.onStateChange(state: .signalingOfferForbiddenTheUserIsInConversation)
                break
                
            case .signalingOfferForbiddenYouAreTalkingWithYourOtherDevices:
                delegate.onStateChange(state: .signalingOfferForbiddenYouAreTalkingWithYourOtherDevices)
                break
                
            case .signalingOfferForbiddenIsNotAllowedToCommunicate:
                delegate.onStateChange(state: .signalingOfferForbiddenIsNotAllowedToCommunicate)
                break
                
            default:
                break
            }
        }).send()
    }
    
    public func sendRinging(){
        IGSignalingRingingRequest.Generator.generate().success({ (protoResponse) in
        }).error ({ (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                self.sendRinging()
                break
            default:
                break
            }
        }).send()
    }
    
    public func sendAccept(sdp: String){
        IGSignalingAcceptRequest.Generator.generate(calledSdp: sdp).success({ (protoResponse) in
        }).error ({ (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                self.sendAccept(sdp: sdp)
                break
            default:
                break
            }
        }).send()
    }
    
    public func sendCandidate(candidate: RTCIceCandidate){
        IGSignalingCandidateRequest.Generator.generate(candidate: candidate.sdp , sdpMId:candidate.sdpMid! , sdpMLineIndex:candidate.sdpMLineIndex).success({ (protoResponse) in
        }).error ({ (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                break
            default:
                break
            }
        }).send()
    }
    
    public func sendLeaveCall(){
        IGSignalingLeaveRequest.Generator.generate().success({ (protoResponse) in
        }).error ({ (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                self.sendLeaveCall()
                break
            default:
                break
            }
        }).send()
    }
}

public struct ErrorDomain {
    static let videoPermissionDenied = "Video permission denied"
    static let audioPermissionDenied = "Audio permission denied"
}

private extension RTCClient {
    func handleRemoteDescriptionSet() {
        for iceCandidate in self.remoteIceCandidates {
            self.peerConnection?.add(iceCandidate)
        }
        self.remoteIceCandidates = []
    }
    
    // Generate local stream and keep it live and add to new peer connection
    func localStream() -> RTCMediaStream {
        let factory = self.connectionFactory
        let localStream = factory.mediaStream(withStreamId: "RTCmS")
        
        RTCClient.mediaStream = localStream
        
        if self.isVideoCall {
            if !AVCaptureState.isVideoDisabled {
                let videoSource = factory.avFoundationVideoSource(with: self.mediaConstraint)
                let videoTrack = factory.videoTrack(with: videoSource, trackId: "RTCvS0")
                localStream.addVideoTrack(videoTrack)
            } else {
                // show alert for video permission disabled
                let error = NSError.init(domain: ErrorDomain.videoPermissionDenied, code: 0, userInfo: nil)
                self.delegate?.rtcClient(client: self, didReceiveError: error)
            }
        }
        
        if !AVCaptureState.isAudioDisabled {
            let audioTrack = factory.audioTrack(withTrackId: "RTCaS0")
            localStream.addAudioTrack(audioTrack)
        } else {
            // show alert for audio permission disabled
            let error = NSError.init(domain: ErrorDomain.audioPermissionDenied, code: 0, userInfo: nil)
            self.delegate?.rtcClient(client: self, didReceiveError: error)
        }
        return localStream
    }
    
    func initialisePeerConnectionFactory () {
        RTCPeerConnectionFactory.initialize()
        self.connectionFactory = RTCPeerConnectionFactory()
    }
    
    func initialisePeerConnection () {
        let configuration = RTCConfiguration()
        configuration.iceServers = self.iceServers
        self.peerConnection = self.connectionFactory.peerConnection(with: configuration,
                                                                    constraints: self.defaultConnectionConstraint,
                                                                    delegate: self)
    }
    
    func handleSdpGenerated(sdpDescription: RTCSessionDescription?) {
        guard let sdpDescription = sdpDescription  else {
            return
        }
        // set local description
        self.peerConnection?.setLocalDescription(sdpDescription, completionHandler: {[weak self] (error) in
            // issue in setting local description
            guard let this = self, let error = error else { return }
            this.delegate?.rtcClient(client: this, didReceiveError: error)
        })
        //  Signal to server to pass this sdp with for the session call
        self.delegate?.rtcClient(client: self, startCallWithSdp: sdpDescription.sdp)
    }
}

extension RTCClient: RTCPeerConnectionDelegate {
    
    public func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        
    }
    
    public func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        
        if stream.audioTracks.count > 0 {
            self.delegate?.rtcClient(client: self, didReceiveRemoteAudioTrack: stream.audioTracks[0])
        }
        
        //if stream.videoTracks.count > 0 {
        //    self.delegate?.rtcClient(client: self, didReceiveRemoteVideoTrack: stream.videoTracks[0])
        //}
    }
    
    public func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
        
    }
    
    public func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
        
    }
    
    public func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        
        guard let delegate = callStateDelegate else {
            return
        }
        
        switch newState.rawValue {
            
        case 0://RTCIceConnectionStateNew
            break
            
        case 1://RTCIceConnectionStateChecking
            delegate.onStateChange(state: RTCClientConnectionState.Connecting)
            break
            
        case 2://RTCIceConnectionStateConnected
            delegate.onStateChange(state: RTCClientConnectionState.Connected)
            break
            
        case 3://RTCIceConnectionStateCompleted
            delegate.onStateChange(state: RTCClientConnectionState.Connected)
            break
            
        case 4://RTCIceConnectionStateFailed
            delegate.onStateChange(state: RTCClientConnectionState.Failed)
            break
            
        case 5://RTCIceConnectionStateDisconnected
            delegate.onStateChange(state: RTCClientConnectionState.Disconnected)
            break
            
        case 6://RTCIceConnectionStateClosed
            delegate.onStateChange(state: RTCClientConnectionState.Closed)
            break
            
        case 7://RTCIceConnectionStateCount
            break
            
        default:
            break
        }
        
        self.delegate?.rtcClient(client: self, didChangeConnectionState: newState)
    }
    
    public func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
        
    }
    
    public func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        self.delegate?.rtcClient(client: self, didGenerateIceCandidate: candidate)
        sendCandidate(candidate: candidate)
    }
    
    public func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
        
    }
    
    public func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        
    }
}

