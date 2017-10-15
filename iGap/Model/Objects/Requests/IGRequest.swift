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
import IGProtoBuff
import SwiftProtobuf

class IGRequest {
    class Generator {
        
    }
    
    class Handler {
        class func handle(responseProtoMessage: Message) {} //I think we can remove this function
        class func handlePush(responseProtoMessage: Message) {}
        class func error() {}
        class func timeout() {}
    }
}
