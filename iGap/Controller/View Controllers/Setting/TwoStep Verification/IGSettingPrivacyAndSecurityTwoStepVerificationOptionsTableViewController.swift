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
    @IBOutlet weak var txtUnconfirmedEmail: IGLabel!
    @IBOutlet weak var btnOutletVerify: UIButton!
    
    internal static var verifiedEmail = false
    internal static var unconfirmedEmailPattern: String?
    
    var twoStepVerification: IGTwoStepVerification?
    var password: String?
    let EMAIL_PREFIX = "You have an unverifies email address:\n"
    
    @IBAction func btnResendVerificationCode(_ sender: Any) {
        self.performSegue(withIdentifier: "showVerifyEmail", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: "", title: "Options")
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        
        if let pattern = twoStepVerification?.unverifiedEmailPattern {
            txtUnconfirmedEmail.text = EMAIL_PREFIX + pattern
        } else {
            txtUnconfirmedEmail.isHidden = true
            btnOutletVerify.isHidden = true
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if IGSettingPrivacyAndSecurityTwoStepVerificationOptionsTableViewController.verifiedEmail {
            IGSettingPrivacyAndSecurityTwoStepVerificationOptionsTableViewController.verifiedEmail = false
            txtUnconfirmedEmail.isHidden = true
            btnOutletVerify.isHidden = true
        }
        
        if IGSettingPrivacyAndSecurityTwoStepVerificationOptionsTableViewController.unconfirmedEmailPattern != nil && IGSettingPrivacyAndSecurityTwoStepVerificationOptionsTableViewController.unconfirmedEmailPattern != "" {
            
            txtUnconfirmedEmail.text = EMAIL_PREFIX + IGSettingPrivacyAndSecurityTwoStepVerificationOptionsTableViewController.unconfirmedEmailPattern!
            txtUnconfirmedEmail.isHidden = false
            btnOutletVerify.isHidden = false
            
            IGSettingPrivacyAndSecurityTwoStepVerificationOptionsTableViewController.unconfirmedEmailPattern = ""
        }
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            self.unsetPassword()
        } else if indexPath.row == 1 {
            self.performSegue(withIdentifier: "ShowSetPassword", sender: self)
        } else if indexPath.row == 2 {
            self.performSegue(withIdentifier: "showChangeHint", sender: self)
        } else if indexPath.row == 3 {
            self.performSegue(withIdentifier: "showChangeSecurityQuestions", sender: self)
        } else if indexPath.row == 4 {
            self.performSegue(withIdentifier: "showChangeEmail", sender: self)
        }
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
            destinationVC.pageAction = IGTwoStepQuestion.changeRecoveryQuestion
        }
        
        if let destinationVC = segue.destination as? IGSettingPrivacyAndSecurityTwoStepVerificationChangeEmailTableViewController {
            destinationVC.password = password
        }
        
        if let destinationVC = segue.destination as? IGSettingPrivacyAndSecurityTwoStepVerificationSetTwoStepVerificationTableViewController {
            destinationVC.oldPassword = password!
        }
        
        if let destinationVC = segue.destination as? IGSettingPrivacyAndSecurityTwoStepVerificationVerifyUnconfirmedEmail {
            destinationVC.pageAction = IGTwoStepEmail.verifyEmail
        }
    }
}
