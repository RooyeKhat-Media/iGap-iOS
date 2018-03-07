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

class IGSignaling: Object {
    
    var voiceCalling:          Bool                  = true
    var videoCalling:          Bool                  = true
    var secretChat:            Bool                  = true
    var screenSharing:         Bool                  = true
    var iceServer = List<IGIceServer>()
    
    
    convenience init(signalingConfiguration: IGPSignalingGetConfigurationResponse) {
        self.init()
        
        self.voiceCalling = signalingConfiguration.igpVoiceCalling
        self.videoCalling = signalingConfiguration.igpVideoCalling
        self.secretChat = signalingConfiguration.igpSecretChat
        self.screenSharing = signalingConfiguration.igpScreenSharing
        
        for iceServer in signalingConfiguration.igpIceServer {
            self.iceServer.append(IGIceServer(iceServer: iceServer))
        }
    }
}

class IGIceServer: Object {
    
    var url        = ""
    var credential = ""
    var username   = ""

    convenience init(iceServer: IGPSignalingGetConfigurationResponse.IGPIceServer) {
        self.init()
        self.url = iceServer.igpURL
        self.credential = iceServer.igpCredential
        self.username = iceServer.igpUsername
    }
}

class IGRealmCallLog: Object {
    
    @objc dynamic var id                 : Int64 = 0
    @objc dynamic var signalingOfferType : IGPSignalingOffer.IGPType.RawValue = 0
    @objc dynamic var status             : Int = 0
    @objc dynamic var registeredUser     : IGRegisteredUser!
    @objc dynamic var offerTime          : Date!
    @objc dynamic var duration           : Int32 = 0
    
    convenience init(signalingLog: IGPSignalingGetLogResponse.IGPSignalingLog) {
        self.init()
        
        self.id = signalingLog.igpID
        self.signalingOfferType = signalingLog.igpType.rawValue
        self.status = signalingLog.igpStatus.rawValue
        self.offerTime = Date(timeIntervalSince1970: TimeInterval(signalingLog.igpOfferTime))
        self.duration = signalingLog.igpDuration
        
        let predicate = NSPredicate(format: "id = %lld", signalingLog.igpPeer.igpID)
        let realm = try! Realm()
        if let userInDb = realm.objects(IGRegisteredUser.self).filter(predicate).first {
            self.registeredUser = userInDb
        } else {
            self.registeredUser = IGRegisteredUser(igpUser: signalingLog.igpPeer)
        }
    }
    
    override static func primaryKey() -> String {
        return "id"
    }
}





