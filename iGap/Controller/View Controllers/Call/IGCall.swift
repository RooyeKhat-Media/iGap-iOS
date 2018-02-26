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

class IGCall: UIViewController {
    
    var userId: Int64!

    @IBAction func btnCall(_ sender: UIButton) {
        AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
            if granted {
                RTCClient.instance.makeOffer(userId: 6818141939)
            } else {
                // TODO Saeed Mozaffari: if not granted close page
            }
        })
    }
    
    @IBAction func btnAnswer(_ sender: UIButton) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        RTCClient.instance.startConnection()
    }
}
