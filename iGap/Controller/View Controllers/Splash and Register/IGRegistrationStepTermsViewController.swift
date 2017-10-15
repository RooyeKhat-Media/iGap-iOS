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
import MBProgressHUD
import IGProtoBuff

class IGRegistrationStepTermsViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navItem = self.navigationItem as! IGNavigationItem
        navItem.addModalViewItems(leftItemText: nil, rightItemText: "Done", title: "Terms")
        navItem.rightViewContainer?.addAction {
            self.dismiss(animated: true) {
                
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = .indeterminate
        IGInfoPageRequest.Generator.generate(pageID: "TOS").success { (responseProto) in
            DispatchQueue.main.async {
                switch responseProto {
                case let pageInfoResponse as IGPInfoPageResponse:
                    let body = IGInfoPageRequest.Handler.interpret(response: pageInfoResponse)
                    let htmlString = "<font face='IRANSans' size='3'>" + body
                    self.webView.loadHTMLString(htmlString, baseURL: nil)
                default:
                    break
                }
                hud.hide(animated: true)
            }
        }.error { (errorCode, waitTime) in
            DispatchQueue.main.async {
                hud.hide(animated: true)
            }
        }.send()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
