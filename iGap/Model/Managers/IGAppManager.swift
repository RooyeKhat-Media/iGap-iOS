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
import FirebaseInstanceID

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
    static var connectionStatusStatic: IGAppManager.ConnectionStatus?
    var isUserLoggedIn:   Variable<Bool>
    var isTryingToLoginUser: Bool = false
    var currentMessagesNotificationToekn: NotificationToken?
    
    private var _loginToken: String?
    private var _username: String?
    private var _userID: Int64?
    private var _authorHash: String?
    private var _nickname: String?
    private var _mapEnable: Bool = false
    private var _mplActive: Bool = false
    
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
            
            let room = realm.objects(IGFile.self)
            let room1 = realm.objects(IGUserPrivacy.self)
            let room2 = realm.objects(IGAvatar.self)
            let room4 = realm.objects(IGRoom.self)
            let room5 = realm.objects(IGChatRoom.self)
            let room6 = realm.objects(IGGroupRoom.self)
            let room7 = realm.objects(IGChannelRoom.self)
            let room8 = realm.objects(IGRoomDraft.self)
            let room9 = realm.objects(IGRoomMessage.self)
            let room10 = realm.objects(IGRoomMessageLocation.self)
            let room11 = realm.objects(IGRoomMessageLog.self)
            let room12 = realm.objects(IGRoomMessageContact.self)
            let room13 = realm.objects(IGSignaling.self)
            let room14 = realm.objects(IGSessionInfo.self)
            let room16 = realm.objects(IGRegisteredUser.self)
            let room17 = realm.objects(IGContact.self)
            let room20 = realm.objects(IGRealmClientSearchUsername.self)
            
            realm.delete(room)
            realm.delete(room1)
            realm.delete(room2)
            realm.delete(room4)
            realm.delete(room5)
            realm.delete(room6)
            realm.delete(room7)
            realm.delete(room8)
            realm.delete(room9)
            realm.delete(room10)
            realm.delete(room11)
            realm.delete(room12)
            realm.delete(room13)
            realm.delete(room14)
            realm.delete(room16)
            realm.delete(room17)
            realm.delete(room20)
        }
        _loginToken = nil
        _username = nil
        _userID = nil
        _authorHash = nil
        _nickname = nil
        _mapEnable = false
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
    
    public func mapEnable() -> Bool {
        return _mapEnable
    }
    
    public func setMapEnable(enable: Bool) {
        _mapEnable = enable
    }
    
    public func mplActive() -> Bool {
        return _mplActive
    }
    
    public func setMplActive(enable: Bool) {
        _mplActive = enable
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
                            IGUserLoginRequest.Handler.intrepret(response: (responseProto as? IGPUserLoginResponse)!)
                            IGContactManager.sharedManager.manageContact()
                            self.setUserLoginSuccessful()
                            self.setUserUpdateStatus(status: .online)
                            self.getSignalingConfiguration(force: true)
                            self.getGeoRegisterStatus()
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
                DispatchQueue.main.async {
                    // no token or no author hash
                    self.isTryingToLoginUser = false
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.showLoginFaieldAlert()
                }
            }
            
        }
        
    }
    
    public func getGeoRegisterStatus(){
        IGGeoGetRegisterStatus.Generator.generate().success({ (responseProto) in
            DispatchQueue.main.async {
                if let geoStatus = responseProto as? IGPGeoGetRegisterStatusResponse {
                    self._mapEnable = geoStatus.igpEnable
                }
            }
        }).error({ (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                self.getGeoRegisterStatus()
            default:
                break
            }
        }).send()
    }
    
}
