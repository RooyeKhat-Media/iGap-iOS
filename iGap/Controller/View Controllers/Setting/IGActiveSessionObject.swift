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

class IGActiveSessionObject : NSObject{
   convenience init(name: String,status : String) {
    self.init()
        self.activeDeviceName = name
        self.statusSession = status
    }
     var activeDeviceName = ""
     var statusSession = ""
}
