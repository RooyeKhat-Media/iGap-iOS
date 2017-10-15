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

class IGConnectionSecuringRequest : IGRequest {
    class Generator : IGRequest.Generator{
        
    }
    
    class Handler : IGRequest.Handler{
        override class func handle(responseProtoMessage: Message) {
            
        }
        
        override class func handlePush(responseProtoMessage: Message) {
            let connectionSecuringResponseMessage = responseProtoMessage as! IGPConnectionSecuringResponse
            let sessionPublicKey = connectionSecuringResponseMessage.igpPublicKey
            let symmetricKeyLength = Int(connectionSecuringResponseMessage.igpSymmetricKeyLength)
            let secondaryChunkSize = Int(connectionSecuringResponseMessage.igpSecondaryChunkSize)


            IGSecurityManager.sharedManager.setConnecitonPublicKey(sessionPublicKey)
            IGWebSocketManager.sharedManager.connectionProblemTimerDelay = Double(connectionSecuringResponseMessage.igpHeartbeatInterval+5)
            
            let generatedEncryptedSymmetricKeyData = IGSecurityManager.sharedManager.generateEncryptedSymmetricKeyData(length: symmetricKeyLength,secondaryChunkSize:secondaryChunkSize)
            
            
            var connectionSecuringResponseRequest = IGPConnectionSymmetricKey()
            connectionSecuringResponseRequest.igpSymmetricKey = generatedEncryptedSymmetricKeyData
            connectionSecuringResponseRequest.igpVersion = 2
            
            let requestWrapper : IGRequestWrapper = IGRequestWrapper(message: connectionSecuringResponseRequest, actionID: 2)
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
        override class func handlePush(responseProtoMessage: Message) {
            let symmetricKeyResponseMessage = responseProtoMessage as! IGPConnectionSymmetricKeyResponse
            if(symmetricKeyResponseMessage.igpSecurityIssue){
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Security Issue", message: "Securing the connection is not possible at the moment!", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)

                }
            }else {
                //TODO: check if is accepted
                let symmetricIVSize = Int(symmetricKeyResponseMessage.igpSymmetricIvSize)
                let symmetricMethod = symmetricKeyResponseMessage.igpSymmetricMethod

                IGSecurityManager.sharedManager.setSymmetricIVSize(symmetricIVSize)
                IGSecurityManager.sharedManager.setEncryptionMethod(symmetricMethod)

                IGWebSocketManager.sharedManager.setConnectionSecure()
                //login if possible
                IGAppManager.sharedManager.login()
            }
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
            var heartbeatRequestMessage = IGPHeartbeat()
            return IGRequestWrapper(message: heartbeatRequestMessage, actionID: 3)
        }
    }
    
    class Handler : IGRequest.Handler{
        override class func handlePush(responseProtoMessage: Message) {
            let reqW = IGHeartBeatRequest.Generator.generate()
            IGRequestManager.sharedManager.addRequestIDAndSend(requestWrappers: reqW)
        }
        
        override class func error() {
            
        }
        
        override class func timeout() {
            
        }
    }
}

