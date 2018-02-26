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
import RxSwift
import WebRTC

class IGAppManager: NSObject {
    static let sharedManager = IGAppManager()
    internal static var iceServersStatic: [RTCIceServer] = []
    
    enum ConnectionStatus {
        case waitingForNetwork
        case connecting
        case connected
    }
    
    var realm = try! Realm()
    var connectionStatus: Variable<ConnectionStatus>
    var isUserLoggedIn:   Variable<Bool>
    var isTryingToLoginUser: Bool = false
    var currentMessagesNotificationToekn: NotificationToken?
    
    private var _loginToken: String?
    private var _username: String?
    private var _userID: Int64?
    private var _authorHash: String?
    private var _nickname: String?
    
    private override init() {
        connectionStatus = Variable(.waitingForNetwork)
        isUserLoggedIn   = Variable(false)
        super.init()
    }
    
    public func setNetworkConnectionStatus(_ status: ConnectionStatus) {
        self.connectionStatus.value = status
    }
    
    public func setUserUpdateStatus(status: IGRegisteredUser.IGLastSeenStatus) {
            IGUserUpdateStatusRequest.Generator.generate(userStatus: status).success({ (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let userUpdateStatus as IGPUserUpdateStatusResponse:
                        IGUserUpdateStatusRequest.Handler.interpret(response: userUpdateStatus)
                    default:
                        break
                    }
                }
            }).error({ (errorCode, waitTime) in
                switch errorCode {
                    
                default:
                    break
                }
            }).send()
        
    }

    public func clearDataOnLogout() {
        IGDatabaseManager.shared.emptyQueue()
        IGRequestManager.sharedManager.userDidLogout()
        try! realm.write {
            realm.deleteAll()
        }
        _loginToken = nil
        _username = nil
        _userID = nil
        _authorHash = nil
        _nickname = nil
    }
    
    public func isUserPreviouslyLoggedIn() -> Bool {
        if let sessionInto = realm.objects(IGSessionInfo.self).first {
            if sessionInto.loginToken != nil {
                _loginToken = sessionInto.loginToken
                _username = sessionInto.username
                _userID = sessionInto.userID
                _nickname = sessionInto.nickname
                _authorHash = sessionInto.authorHash
                return true
            }
        }
        return false
    }
    
    public func setUserLoginSuccessful() {
        isUserLoggedIn.value = true
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kIGUserLoggedInNotificationName), object: nil)
    }
    
    public func getSignalingConfiguration(force:Bool = false){
        let realm = try! Realm()
        let signalingConfig = try! realm.objects(IGSignaling.self).first
        if signalingConfig == nil || force {
            IGSignalingGetConfigurationRequest.Generator.generate().success({ (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let configurationResponse as IGPSignalingGetConfigurationResponse:
                        IGSignalingGetConfigurationRequest.Handler.interpret(response: configurationResponse)
                    default:
                        break
                    }
                }
            }).error ({ (errorCode, waitTime) in
                switch errorCode {
                case .timeout:
                    self.getSignalingConfiguration()
                    break
                default:
                    break
                }
            }).send()
        }
    }
    
    public func isUserLoggiedIn() -> Bool {
        if isUserLoggedIn.value == true {
        }
        return isUserLoggedIn.value
    }
    
    public func save(token: String?) {
        _loginToken = token
        
        if _username == nil || _username == "" {
            _username = AppDelegate.usernameRegister
        }
        
        if _userID == nil || _userID == 0 {
            _userID = AppDelegate.userIdRegister
        }
        
        if _authorHash == nil || _authorHash == "" {
            _authorHash = AppDelegate.authorHashRegister
        }
        
        if let sessionInto = realm.objects(IGSessionInfo.self).first {
            try! realm.write {
                sessionInto.loginToken = token
                sessionInto.username = _username
                sessionInto.userID = _userID!
                sessionInto.authorHash = _authorHash
            }
        } else {
            let sessionInto = IGSessionInfo()
            sessionInto.loginToken = token
            sessionInto.username = _username
            sessionInto.userID = _userID!
            sessionInto.authorHash = _authorHash
            try! realm.write {
                realm.add(sessionInto, update: true)
            }
        }
    }
    
    public func save(username: String?) {
        AppDelegate.usernameRegister = username
        _username = username
        if let sessionInto = realm.objects(IGSessionInfo.self).first {
            try! realm.write {
                sessionInto.username = username
            }
        } else {
            let sessionInto = IGSessionInfo()
            sessionInto.username = username
            try! realm.write {
                realm.add(sessionInto, update: true)
            }
        }
    }
    
    public func save(userID: Int64?) {
        AppDelegate.userIdRegister = userID
        _userID = userID
        var userId: Int64 = -1
        if userID != nil {
            userId = userID!
        }
        if let sessionInto = realm.objects(IGSessionInfo.self).first {
            try! realm.write {
                sessionInto.userID = userId
            }
        } else {
            let sessionInto = IGSessionInfo()
            sessionInto.userID = userId
            try! realm.write {
                realm.add(sessionInto, update: true)
            }
        }
    }
    
    public func save(authorHash: String?) {
        AppDelegate.authorHashRegister = authorHash
        _authorHash = authorHash
        if let sessionInto = realm.objects(IGSessionInfo.self).first {
            try! realm.write {
                sessionInto.authorHash = authorHash
            }
        } else {
            let sessionInto = IGSessionInfo()
            sessionInto.authorHash = authorHash
            try! realm.write {
                realm.add(sessionInto, update: true)
            }
        }
    }
    
    public func save(nickname: String) {
        _nickname = nickname
    }
    
    public func loginToken() -> String? {
        return _loginToken
    }
    
    public func username() -> String? {
        return _username
    }
    
    public func userID() -> Int64? {
        return _userID
    }
    
    public func authorHash() -> String? {
        return _authorHash
    }
    
    public func nickname() -> String? {
        return _nickname
    }
    
    public func login() {
        if !self.isTryingToLoginUser {
            self.isTryingToLoginUser = true
            if let token = _loginToken, let hash = _authorHash {
                IGUserLoginRequest.Generator.generate(token: token).success({ (responseProto) in
                    DispatchQueue.main.async {
                        self.isTryingToLoginUser = false
                        switch responseProto {
                        case _ as IGPUserLoginResponse:
                            self.setUserLoginSuccessful()
                            self.setUserUpdateStatus(status: .online)
                            self.getSignalingConfiguration(force: true)
                            break
                        default:
                            break
                        }
                    }
                }).error({ (errorCode, waitTime) in
                    self.isTryingToLoginUser = false
                    switch errorCode {
                    case .userLoginFaield, .userLoginFaieldUserIsBlocked:
                        DispatchQueue.main.async {
                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                            appDelegate.showLoginFaieldAlert()
                        }
                    default:
                        break
                    }
                }).send()
            } else {
                // no token or no author hash
                self.isTryingToLoginUser = false
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.showLoginFaieldAlert()
            }
            
        }
        
    }
    
}
