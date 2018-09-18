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

class IGHelper {
    
    internal static let shareLinkPrefixGroup = "Open this link to join my iGap Group"
    internal static let shareLinkPrefixChannel = "Open this link to join my iGap Channel"
    
    internal static func shareText(message: String, viewController: UIViewController){
        let textToShare = [message]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = viewController.view
        activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook ]
        viewController.present(activityViewController, animated: true, completion: nil)
    }
    
}
