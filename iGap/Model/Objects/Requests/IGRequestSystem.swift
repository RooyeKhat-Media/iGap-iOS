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

class IGConnectionSecuringRequest : IGRequest {
    class Generator : IGRequest.Generator{
        
    }
    
    class Handler : IGRequest.Handler{
        override class func handle(responseProtoMessage: GeneratedResponseMessage) {
            
        }
        
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {
            let connectionSecuringResponseMessage = responseProtoMessage as! IGPConnectionSecuringResponse
            let sessionPublicKey = connectionSecuringResponseMessage.igpPublicKey
            let symmetricKeyLength = Int(connectionSecuringResponseMessage.igpSymmetricKeyLength)
            
            IGSecurityManager.sharedManager.setConnecitonPublicKey(sessionPublicKey)
            
            let generatedEncryptedSymmetricKeyData = IGSecurityManager.sharedManager.generateEncryptedSymmetricKeyData(length: symmetricKeyLength)
            
            
            let connectionSecuringResponseRequest = IGPConnectionSymmetricKey.Builder()
            connectionSecuringResponseRequest.setIgpSymmetricKey(generatedEncryptedSymmetricKeyData)
            
            let requestWrapper : IGRequestWrapper = IGRequestWrapper(messageBuilder: connectionSecuringResponseRequest, actionID: 2)
            IGWebSocketManager.sharedManager.send(requestW: requestWrapper)
        }
        
        override class func error() {
            
        }
        
        override class func timeout() {
            
        }
    }
}

//MARK: -
class IGConnectionSymmetricKeyRequest : IGRequest {
    class Generator : IGRequest.Generator{
        
    }
    
    class Handler : IGRequest.Handler{
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {
            let symmetricKeyResponseMessage = responseProtoMessage as! IGPConnectionSymmetricKeyResponse
            //TODO: check if is accepted
            let symmetricIVSize = Int(symmetricKeyResponseMessage.igpSymmetricIvSize)
            let symmetricMethod = symmetricKeyResponseMessage.igpSymmetricMethod
            
            IGSecurityManager.sharedManager.setSymmetricIVSize(symmetricIVSize)
            IGSecurityManager.sharedManager.setEncryptionMethod(symmetricMethod)
            
            IGWebSocketManager.sharedManager.setConnectionSecure()
            //login if possible
            IGAppManager.sharedManager.login()
        }
        
        override class func error() {
            
        }
        
        override class func timeout() {
            
        }
    }
}

//MARK: -
class IGHeartBeatRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate() -> IGRequestWrapper {
            let heartbeatRequestBuilder = IGPHeartbeat.Builder()
            return IGRequestWrapper(messageBuilder: heartbeatRequestBuilder, actionID: 3)
        }
    }
    
    class Handler : IGRequest.Handler{
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {
            let reqW = IGHeartBeatRequest.Generator.generate()
            IGRequestManager.sharedManager.addRequestIDAndSend(requestWrappers: reqW)
        }
        
        override class func error() {
            
        }
        
        override class func timeout() {
            
        }
    }
}

