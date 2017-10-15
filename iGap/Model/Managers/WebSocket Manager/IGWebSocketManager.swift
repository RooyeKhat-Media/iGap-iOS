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
//import Starscream
import SwiftProtobuf
import Reachability.Swift

var insecureMehotdsActionID : [Int] = [2]


class IGWebSocketManager: NSObject {
    static let sharedManager = IGWebSocketManager()
    
    private let reachability = Reachability()!
    private let socket = WebSocket(url: URL(string: "wss://secure.igap.net/hybrid/")!)
//    private let socket = WebSocket(url: URL(string: "ws://10.10.10.102:6708")!)
    fileprivate var isConnectionSecured : Bool = false
    fileprivate var websocketSendQueue = DispatchQueue(label: "im.igap.ios.queue.ws.send")
    fileprivate var websocketReceiveQueue = DispatchQueue(label: "im.igap.ios.queue.ws.receive")
    
    fileprivate var connectionProblemTimer = Timer() //use this to detect failure on websocket after connection
    var connectionProblemTimerDelay = 3.0;

    private override init() {
        super.init()
        socket.delegate = self
        socket.pongDelegate = self
        IGAppManager.sharedManager.setNetworkConnectionStatus(.connecting)
        self.connectIfPossible()
    }
    
    //MARK: Public methods
    public func send(requestW: IGRequestWrapper) {
        websocketSendQueue.async {
            do {
                print ("✧ \(NSDate.timeIntervalSinceReferenceDate) ----- ~~~~~~~~ Sending: \(requestW.actionId)")
                var messageData = Data()
                let payloadData = try requestW.message.serializedData()
                let actionIdData = Data(bytes: &requestW.actionId, count: 2)
                messageData.append(actionIdData)
                messageData.append(payloadData)
                
                if self.isConnectionSecured {
                    messageData = IGSecurityManager.sharedManager.encryptAndAddIV(payload: messageData)
                } else if !insecureMehotdsActionID.contains(requestW.actionId){
                    //if the connection is not secure && this request MUST be sent securely -> drop this request
                    return
                }

                self.socket.write(data: messageData)
            } catch {
                
            }
        }
        
       
    }
    
    public func closeConnection() {
        self.socket.disconnect()
    }
    
    public func setConnectionSecure() {
        isConnectionSecured = true
        socket.shouldMask = false
        IGAppManager.sharedManager.setNetworkConnectionStatus(.connected)
    }

    public func isSecureConnection()->Bool{
        return isConnectionSecured;
    }
    
    
    //MARK: Private methods
    private func connectIfPossible() {
        reachability.whenReachable = { reachability in
            // this is called on a background thread
            IGAppManager.sharedManager.setNetworkConnectionStatus(.connecting)
            IGAppManager.sharedManager.isUserLoggedIn.value = false
            if reachability.isReachableViaWiFi {
                print("Reachable via WiFi")
            } else {
                print("Reachable via Cellular")
            }
            self.connectAndAddTimeoutHandler()
        }
        reachability.whenUnreachable = { reachability in
            // this is called on a background thread
            print ("Network Unreachable")
            IGAppManager.sharedManager.setNetworkConnectionStatus(.waitingForNetwork)
            IGAppManager.sharedManager.isUserLoggedIn.value = false
            self.socket.disconnect(forceTimeout:0)
        }
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    fileprivate func connectAndAddTimeoutHandler() {
        IGAppManager.sharedManager.setNetworkConnectionStatus(.connecting)
        self.socket.connect()
        connectionProblemTimerDelay=3.0;
        self.resetConnectionProblemDetectorTimer()
    }
    
    
    fileprivate func inerpretAndTakeAction(receivedData: Data) {
        websocketReceiveQueue.async {
            var convertedData = NSData(data: receivedData)
            if self.isConnectionSecured {
                let decryptedData = IGSecurityManager.sharedManager.decrypt(encryptedData: receivedData)
                if decryptedData==nil{
                    return
                }
                convertedData = NSData(data: decryptedData!)
            }
            IGRequestManager.sharedManager.didReceive(decryptedData: convertedData)
        }
    }
    
    //Network connection problem detection
    //add this after connection stablishment
    fileprivate func resetConnectionProblemDetectorTimer() {
        print(#function)
        removeConnectionProblemDetectorTimer()
        connectionProblemTimer = Timer.scheduledTimer(timeInterval: connectionProblemTimerDelay,
                                                      target:   self,
                                                      selector: #selector(thereSeemsToBeAProblemWithWebSocket),
                                                      userInfo: nil,
                                                      repeats:  false)
    }
    
    fileprivate func removeConnectionProblemDetectorTimer() {
        connectionProblemTimer.invalidate()
    }
    
    func thereSeemsToBeAProblemWithWebSocket() {
        self.socket.disconnect(forceTimeout:1)
    }
    
}

//MARK: - WebSocketDelegate
extension IGWebSocketManager: WebSocketDelegate {
    func websocketDidConnect(socket: WebSocket) {
        isConnectionSecured = false
        socket.shouldMask = true
        print("Websocket Connected")
        resetConnectionProblemDetectorTimer()
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        isConnectionSecured = false
        removeConnectionProblemDetectorTimer()
        let deadlineTime = DispatchTime.now() + .seconds(3)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            self.connectAndAddTimeoutHandler()
        }
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        resetConnectionProblemDetectorTimer()
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: Data) {
        resetConnectionProblemDetectorTimer()
        inerpretAndTakeAction(receivedData: data)
    }
}

extension IGWebSocketManager : WebSocketPongDelegate{
    func websocketDidReceivePong(socket: WebSocket, data: Data?) {
        resetConnectionProblemDetectorTimer()
    }
}




