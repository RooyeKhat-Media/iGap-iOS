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
import SwiftProtobuf
import IGProtoBuff
import MBProgressHUD

class IGSettingPrivacyAndSecurityTwoStepVerificationOptionsTableViewController: UITableViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var unverifiedEmailContainerView: UIView!
    @IBOutlet weak var unverifiedEmailAddressLabel: IGLabel!
    
    var twoStepVerification: IGTwoStepVerification?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: "", title: "Options")
        navigationItem.navigationController = self.navigationController as? IGNavigationController
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            //remove password
        } else if indexPath.row == 1 {
            self.performSegue(withIdentifier: "showChangePassword", sender: self)
        } else if indexPath.row == 2 {
            self.performSegue(withIdentifier: "showChangeHint", sender: self)
        } else if indexPath.row == 3 {
            self.performSegue(withIdentifier: "showChangeSecurityQuestions", sender: self)
        } else if indexPath.row == 4 {
            self.performSegue(withIdentifier: "showChangeEmail", sender: self)
        }
    }

    @IBAction func didTapOnResentVerifyCodeButton(_ sender: UIButton) {
        
    }
}
