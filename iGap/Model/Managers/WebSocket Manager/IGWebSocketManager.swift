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
import ProtocolBuffers
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
    
    fileprivate var connectionTimeoutTimer = Timer() //use this to handle timeout on connecting
    fileprivate var connectionProblemTimer = Timer() //use this to detect failure on websocket after connection
    fileprivate var pongTimer = Timer()              //use this to detect failure in receiving ping response
    
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
                
                let abstractPayload = try requestW.message.build()
                let payloadData  = abstractPayload.data()
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
    
    public func closeConnection(reconnect: Bool) {
        self.socket.disconnect()
        self.removeTimeout()
        if reconnect {
            self.connectAndAddTimeoutHandler()
        }
    }
    
    public func setConnectionSecure() {
        isConnectionSecured = true
        socket.shouldMask = false
        IGAppManager.sharedManager.setNetworkConnectionStatus(.connected)
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
        self.addTimeout()
    }
    
    
    fileprivate func inerpretAndTakeAction(receivedData: Data) {
        websocketReceiveQueue.async {
            var convertedData = NSData(data: receivedData)
            if self.isConnectionSecured {
                convertedData = NSData(data: IGSecurityManager.sharedManager.decrypt(encryptedData: receivedData))
            }
            IGRequestManager.sharedManager.didReceive(decryptedData: convertedData)
        }
    }
    
    
    //Timeout
    private func addTimeout() {
        connectionTimeoutTimer = Timer.scheduledTimer(timeInterval: 3.0,
                                                      target:   self,
                                                      selector: #selector(closeConnectionDueToTimeout),
                                                      userInfo: nil,
                                                      repeats:  false)
    }
    
    private func removeTimeout() {
        connectionTimeoutTimer.invalidate()
    }
    
    func closeConnectionDueToTimeout() {
        if !socket.isConnected {// && shouldTimeOut {
            self.socket.disconnect(forceTimeout: 0, closeCode: WebSocket.CloseCode.normal.rawValue)
        }
    }
    
    
    //Network connection problem detection
    //add this after connection stablishment
    fileprivate func resetConnectionProblemDetectorTimer() {
        print(#function)
        removeConnectionProblemDetectorTimer()
        connectionProblemTimer = Timer.scheduledTimer(timeInterval: 60.0,
                                                      target:   self,
                                                      selector: #selector(thereSeemsToBeAProblemWithWebSocket),
                                                      userInfo: nil,
                                                      repeats:  false)
    }
    
    fileprivate func removeConnectionProblemDetectorTimer() {
        connectionProblemTimer.invalidate()
    }
    
    func thereSeemsToBeAProblemWithWebSocket() {
        self.socket.write(ping: Data())
        pongTimer = Timer.scheduledTimer(timeInterval: 3.0,
                                         target:   self,
                                         selector: #selector(didNotReceivePongMessageInTime),
                                         userInfo: nil,
                                         repeats:  false)
    }
    
    func didNotReceivePongMessageInTime() {
        pongTimer.invalidate()
        self.socket.disconnect(forceTimeout: 0, closeCode: WebSocket.CloseCode.normal.rawValue)
    }
    
}

//MARK: - WebSocketDelegate
extension IGWebSocketManager: WebSocketDelegate {
    func websocketDidConnect(socket: WebSocket) {
        print("Websocket Connected")
        connectionTimeoutTimer.invalidate()
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
        pongTimer.invalidate()
        resetConnectionProblemDetectorTimer()
    }
}




