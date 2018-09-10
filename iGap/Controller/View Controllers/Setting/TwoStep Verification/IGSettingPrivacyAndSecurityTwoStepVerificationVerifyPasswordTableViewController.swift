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

class IGSettingPrivacyAndSecurityTwoStepVerificationVerifyPasswordTableViewController: UITableViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var btnForgetPassword: UIButton!
    
    var twoStepVerification: IGTwoStepVerification?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnForgetPassword.removeUnderline()
        
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: "Verify", title: "Password")
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        navigationItem.rightViewContainer?.addAction {
            self.verifyPassword()
        }
    }

    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if let hint = self.twoStepVerification?.hint {
            return "Hint: \(hint)"
        }
        return ""
    }
    
    var twoStepPassword:String?
    
    
    func verifyPassword() {
        if let password = passwordTextField.text, password != "" {
            self.tableView.isUserInteractionEnabled = false
            self.tableView.isScrollEnabled = false
            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud.mode = .indeterminate
            
            IGUserTwoStepVerificationCheckPasswordRequest.Generator.generate(password: password).successPowerful({ (protoResponse, requestWrapper) in
                DispatchQueue.main.async {
                    if protoResponse is IGPUserTwoStepVerificationCheckPasswordResponse {
                        if let message = requestWrapper.message as? IGPUserTwoStepVerificationCheckPassword {
                            self.twoStepPassword = message.igpPassword
                            self.tableView.isUserInteractionEnabled = true
                            self.tableView.isScrollEnabled = true
                            self.performSegue(withIdentifier: "showTwoStepOptions", sender: self)
                        }
                    } else {
                        self.tableView.isUserInteractionEnabled = true
                        self.tableView.isScrollEnabled = true
                    }
                    hud.hide(animated: true)
                }
            }).error({ (errorCode, waitTime) in
                DispatchQueue.main.async {
                    hud.hide(animated: true)
                    self.tableView.isUserInteractionEnabled = true
                    self.tableView.isScrollEnabled = true
                    switch errorCode {
                    case .userTwoStepVerificationCheckPasswordBadPayload:
                        self.showAlert(title: "Error", message: "Bad Payload")
                    case .userTwoStepVerificationCheckPasswordInternalServerError:
                        self.showAlert(title: "Error", message: "Internal Server Error")
                    case .userTwoStepVerificationCheckPasswordInvalidPassword:
                        self.showAlert(title: "Error", message: "Invalid Password")
                    case .userTwoStepVerificationCheckPasswordMaxTryLock:
                        self.showAlert(title: "Error", message: "Maximum try reached. Please try after \(waitTime!) seconds")
                    case .userTwoStepVerificationCheckPasswordNoPassword:
                        self.showAlert(title: "Error", message: "Password is not set for this account")
                    case.timeout:
                        self.showAlert(title: "Error", message: "Timeout")
                    default:
                        self.showAlert(title: "Error", message: "Unknown Error")
                    }
                }
            }).send()
        }
    }
    
    @IBAction func didTapOnForgotPasswordButton(_ sender: UIButton) {
        let alertVC = UIAlertController(title: "Forgot Password?", message: "Which option do you want to use to change your password?", preferredStyle: IGGlobal.detectAlertStyle())
        
        let email = UIAlertAction(title: "Email", style: .default) { (action) in
            self.performSegue(withIdentifier: "showRecoverByEmail", sender: self)
        }
        let questions = UIAlertAction(title: "Recovery Questions", style: .default) { (action) in
            self.performSegue(withIdentifier: "changePasswordWithQuestions", sender: self)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        if (twoStepVerification?.hasVerifiedEmailAddress)! {
            alertVC.addAction(email)
        }
        alertVC.addAction(questions)
        alertVC.addAction(cancel)
        
        self.present(alertVC, animated: true, completion: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? IGSettingPrivacyAndSecurityTwoStepVerificationOptionsTableViewController {
            destinationVC.twoStepVerification = twoStepVerification
            destinationVC.password = twoStepPassword
        }
        
        if let destinationVC = segue.destination as? IGSettingPrivacyAndSecurityTwoStepVerificationChangeSecurityQuestionsTableViewController {
            destinationVC.password = twoStepPassword
            destinationVC.questionOne = twoStepVerification?.question1
            destinationVC.questionTwo = twoStepVerification?.question2
            destinationVC.pageAction = IGTwoStepQuestion.questionRecoveryPassword
        }
        
        if let destinationVC = segue.destination as? IGSettingPrivacyAndSecurityTwoStepVerificationVerifyUnconfirmedEmail {
            destinationVC.pageAction = IGTwoStepEmail.recoverPassword
        }
    }
}
