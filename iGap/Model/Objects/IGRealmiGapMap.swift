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

class IGRealmMapNearbyDistance: Object {
    
    @objc dynamic var id                 : Int64 = 0
    @objc dynamic var distance           : Int32 = 0
    @objc dynamic var hasComment         : Bool = true
    @objc dynamic var comment            : String = "Receiving status..."
    
    convenience init(nearbyDistance: IGPGeoGetNearbyDistanceResponse.IGPResult) {
        self.init()
        
        self.id = nearbyDistance.igpUserID
        self.distance = nearbyDistance.igpDistance
        self.hasComment = nearbyDistance.igpHasComment
    }
    
    override static func primaryKey() -> String {
        return "id"
    }
}
