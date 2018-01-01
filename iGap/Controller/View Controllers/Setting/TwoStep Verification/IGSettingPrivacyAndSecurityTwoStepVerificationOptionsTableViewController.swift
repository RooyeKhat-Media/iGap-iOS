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
    var password: String?
    
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
            self.unsetPassword()
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
    
    func unsetPassword(){
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = .indeterminate
        IGUserTwoStepVerificationUnsetPasswordRequest.Generator.generate(password: self.password!).success({ (protoResponse) in
            DispatchQueue.main.async {
                hud.hide(animated: true)
                switch protoResponse {
                case let unsetPassword as IGPUserTwoStepVerificationUnsetPasswordResponse :
                    IGUserTwoStepVerificationUnsetPasswordRequest.Handler.interpret(response: unsetPassword)
                    self.navigationController?.popViewController(animated: true)
                default:
                    break
                }
            }
        }).error ({ (errorCode, waitTime) in
            DispatchQueue.main.async {
                switch errorCode {
                case .timeout:
                    let alert = UIAlertController(title: "Timeout", message: "Please try again later", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                default:
                    break
                }
                hud.hide(animated: true)
            }
        }).send()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? IGSettingPrivacyAndSecurityTwoStepVerificationChangeHintTableViewController {
            destinationVC.password = password
        }
        
        if let destinationVC = segue.destination as? IGSettingPrivacyAndSecurityTwoStepVerificationChangeSecurityQuestionsTableViewController {
            destinationVC.password = password
        }
        
        if let destinationVC = segue.destination as? IGSettingPrivacyAndSecurityTwoStepVerificationChangeEmailTableViewController {
            destinationVC.password = password
        }
    }
}
