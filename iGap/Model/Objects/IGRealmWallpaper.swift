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

class IGRealmWallpaper: Object {
    
    var file                        : List<IGFile>           = List<IGFile>()
    var color                       : List<IGRealmString>    = List<IGRealmString>()
    @objc dynamic var selectedFile  : NSData!
    
    convenience init(wallpapers: [IGPWallpaper]) {
        self.init()
        
        for wallpaper in wallpapers {
            self.file.append(IGFile(igpFile : wallpaper.igpFile, type: .image))
            self.color.append(IGRealmString(string: wallpaper.igpColor))
        }
    }
}
