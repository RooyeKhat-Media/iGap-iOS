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

class IGSettingPrivacyAndSecurityTwoStepVerificationChangeEmailTableViewController: UITableViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    
    var password: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: "Done", title: "Change Email")
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        navigationItem.rightViewContainer?.addAction {
            self.changeEmail()
        }
    }
    
    func changeEmail(){
        
        if emailTextField.text == "" {
            let alert = UIAlertController(title: "Error", message: "Please Set Your Email!", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = .indeterminate
        IGUserTwoStepVerificationChangeRecoveryEmailRequest.Generator.generate(password: self.password!, email: emailTextField.text!).success({ (protoResponse) in
            DispatchQueue.main.async {
                hud.hide(animated: true)
                if let recoveryEmail = protoResponse as? IGPUserTwoStepVerificationChangeRecoveryEmailResponse {
                    IGSettingPrivacyAndSecurityTwoStepVerificationOptionsTableViewController.unconfirmedEmailPattern = recoveryEmail.igpUnconfirmedEmailPattern
                    self.navigationController?.popViewController(animated: true)
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
                    
                case .userTwoStepVerificationChangeRecoveryEmailMaxTryLock:
                    let alert = UIAlertController(title: "Error", message: "Max Try Lock", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    break
                    
                case .userTwoStepVerificationChangeRecoveryEmailConfirmedBefore:
                    let alert = UIAlertController(title: "Error", message: "Email Confirmed Before", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    break
                    
                case .userTwoStepVerificationChangeRecoveryEmailIsIncorrect_Minor2:
                    let alert = UIAlertController(title: "Error", message: "Email Is Incorrect", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    break
                    
                case .userTwoStepVerificationChangeRecoveryEmailIsIncorrect_Minor3:
                    let alert = UIAlertController(title: "Error", message: "Email Is Incorrect", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    break
                    
                default:
                    break
                }
                hud.hide(animated: true)
            }
        }).send()
    }

}
