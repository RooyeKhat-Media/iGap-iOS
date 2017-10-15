/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the RooyeKhat Media Company - www.RooyeKhat.co
 * All rights reserved.
 */

import RealmSwift
import Foundation
import IGProtoBuff

class IGSessionInfo: Object {
    @objc dynamic  private var id: Int     = 1
    @objc dynamic  var loginToken: String?
    @objc dynamic  var username:   String?
    @objc dynamic  var userID:     Int64   = -1
    @objc dynamic  var nickname:   String?
    @objc dynamic  var authorHash: String?
    
    override static func primaryKey() -> String {
        return "id"
    }
}

class IGSession: Object {
    
    var sessionId:          Int64                 = -1
    var appID:              Int32                 = -1
    var appBuildVersion:    Int32                 = -1
    var createTime:         Int32                 = -1
    var activeTime:         Int32                 = -1
    var appName:            String                = ""
    var country:            String                = ""
    var appVersion:         String                = ""
    var ip:                 String                = ""
    var isCurrent:          Bool                  = false
    var platform:           IGPlatform?
    var device:             IGDevice?
    var language:           IGLanguage?
    
    convenience init(igpSession: IGPUserSessionGetActiveListResponse.IGPSession) {
        self.init()
        self.sessionId = igpSession.igpSessionID
        self.appID = igpSession.igpAppID
        self.appBuildVersion = igpSession.igpAppBuildVersion
        self.createTime = igpSession.igpCreateTime
        self.activeTime = igpSession.igpActiveTime
        self.appName = igpSession.igpAppName
        self.country = igpSession.igpCountry
        self.appVersion = igpSession.igpAppVersion
        self.ip = igpSession.igpIp
        self.isCurrent = igpSession.igpCurrent
        
        switch igpSession.igpPlatform {
        case .android:
            self.platform = .android
        case .blackBerry:
            self.platform = .blackberry
        case .ios:
            self.platform = .iOS
        case .linux:
            self.platform = .linux
        case .macOs:
            self.platform = .macOS
        case .unknownPlatform:
            self.platform = .unknown
        case .windows:
            self.platform = .windows
        case .UNRECOGNIZED(_):
            self.platform = .unknown
        }
        
        switch igpSession.igpDevice {
        case .mobile:
            self.device = .mobile
        case .pc:
            self.device = .desktop
        case .tablet:
            self.device = .tablet
        case .unknownDevice:
            self.device = .unknown
        case .UNRECOGNIZED(_):
            self.device = .unknown
        }
        switch igpSession.igpLanguage {
        case .enUs:
            self.language = .en_us
        case .faIr:
            self.language = .fa_ir
        case .UNRECOGNIZED(_):
            self.language = .en_us
        }
        
    }
}

