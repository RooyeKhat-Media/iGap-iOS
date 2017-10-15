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

class IGAvatar: Object{
    //MARK: properties
    @objc dynamic var id:     Int64   = 0
    @objc dynamic var file:   IGFile?
    
    //MARK: override
    override static func primaryKey() -> String {
        return "id"
    }
    
    //MARK: init
    convenience init(igpAvatar: IGPAvatar) {
        self.init()
        self.id = igpAvatar.igpID
        self.file = IGFile(igpFile: igpAvatar.igpFile, type: .image)
    }
    
    //detach from current realm
    func detach() -> IGAvatar {
        let detahcedAvatar = IGAvatar(value: self)
        if let file = detahcedAvatar.file {
            let detachedFile = file.detach()
            detahcedAvatar.file = detachedFile
        }
        return detahcedAvatar
    }
}
