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
import IGProtoBuff
import SwiftProtobuf

class IGQrCodeNewDeviceRequest : IGRequest {
    class Generator : IGRequest.Generator{
        //action id = 802
        class func generate() -> IGRequestWrapper {
            var qrNewDeviceRequestMessage = IGPQrCodeNewDevice()
            qrNewDeviceRequestMessage.igpAppID = 3
            switch UIDevice.current.userInterfaceIdiom {
            case .pad:
                qrNewDeviceRequestMessage.igpDevice = IGPDevice.tablet
            case.phone:
                qrNewDeviceRequestMessage.igpDevice = IGPDevice.mobile
            default:
                qrNewDeviceRequestMessage.igpDevice = IGPDevice.unknownDevice
            }
            qrNewDeviceRequestMessage.igpAppName = "iGap iOS"

            qrNewDeviceRequestMessage.igpPlatform = IGPPlatform.ios
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                qrNewDeviceRequestMessage.igpAppVersion = version
            } else {
                qrNewDeviceRequestMessage.igpAppVersion = "0.0.0"
            }
            qrNewDeviceRequestMessage.igpDeviceName = UIDevice.current.name
            if let buildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? Int {
                qrNewDeviceRequestMessage.igpAppBuildVersion = Int32(buildVersion)
            } else {
                qrNewDeviceRequestMessage.igpAppBuildVersion = 1
            }
            
            qrNewDeviceRequestMessage.igpPlatformVersion = UIDevice.current.systemVersion
            
            return IGRequestWrapper(message: qrNewDeviceRequestMessage, actionID: 802)
        }
    }
    
    class Handler : IGRequest.Handler{
        @discardableResult
        class func interpret(response responseProtoMessage:IGPQrCodeNewDeviceResponse) -> (Int32, Data) {
            let expirationTime = responseProtoMessage.igpExpireTime - responseProtoMessage.igpResponse.igpTimestamp
            return (expirationTime, responseProtoMessage.igpQrCodeImage)
        }
        
        override class func handlePush(responseProtoMessage: Message) {}
        
    }
}
