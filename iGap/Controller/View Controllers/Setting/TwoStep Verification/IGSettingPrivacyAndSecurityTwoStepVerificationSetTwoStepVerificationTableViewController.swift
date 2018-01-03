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

class IGSettingPrivacyAndSecurityTwoStepVerificationSetTwoStepVerificationTableViewController: UITableViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var verifyTextField: UITextField!
    @IBOutlet weak var question1TextField: UITextField!
    @IBOutlet weak var answer1TextField: UITextField!
    @IBOutlet weak var question2TextField: UITextField!
    @IBOutlet weak var answer2TextField: UITextField!
    @IBOutlet weak var hintTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    var oldPassword: String = ""
    var email: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: "Done", title: "Change Password")
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        navigationItem.rightViewContainer?.addAction {
            self.setPassword()
        }
    }
    
    func setPassword(){
        
        if passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || verifyTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || question1TextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || answer1TextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || question2TextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || answer2TextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || hintTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            alertController(title: "Error", message: "Please Set All Required Items")
            return
        }
        
        if passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != verifyTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            alertController(title: "Error", message: "Password And Verify Are Not Same")
            return
        }
        
        if passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == hintTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            alertController(title: "Error", message: "Hint Can't Be The Same As Password")
            return
        }
        
        if emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != nil && emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != ""{
            email = (emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines))!
        }
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = .indeterminate
        IGUserTwoStepVerificationSetPasswordRequest.Generator.generate(oldPassword: oldPassword, newPassword: (passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines))!,questionOne: (question1TextField.text?.trimmingCharacters(in: .whitespacesAndNewlines))!,answerOne: (answer1TextField.text?.trimmingCharacters(in: .whitespacesAndNewlines))!,questionTwo: (question2TextField.text?.trimmingCharacters(in: .whitespacesAndNewlines))!,answerTwo: (answer2TextField.text?.trimmingCharacters(in: .whitespacesAndNewlines))!,hint: (hintTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines))!,recoveryEmail: (emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines))!).success({ (protoResponse) in
            DispatchQueue.main.async {
                hud.hide(animated: true)
                switch protoResponse {
                case let unsetPassword as IGPUserTwoStepVerificationSetPasswordResponse :
                    IGUserTwoStepVerificationSetPasswordRequest.Handler.interpret(response: unsetPassword)
                    self.navigationController?.popViewController(animated: true)
                default:
                    break
                }
            }
        }).error ({ (errorCode, waitTime) in
            DispatchQueue.main.async {
                switch errorCode {
                case .timeout:
                    self.alertController(title: "Error", message: "Please try again later")
                    break
                    
                case .userTwoStepVerificationSetPasswordNewPasswordIsInvalid :
                    self.alertController(title: "Error", message: "Password Is Invalid")
                    break
                    
                case .userTwoStepVerificationSetPasswordRecoveryEmailIsNotValid_Minor3 :
                    self.alertController(title: "Error", message: "Email Is Invalid")
                    break
                    
                case .userTwoStepVerificationSetPasswordRecoveryEmailIsNotValid_Minor4 :
                    self.alertController(title: "Error", message: "Email Is Invalid")
                    break
                    
                case .userTwoStepVerificationSetPasswordFirstRecoveryQuestionIsInvalid :
                    self.alertController(title: "Error", message: "First Recovery Question Is Invalid")
                    break

                case .userTwoStepVerificationSetPasswordAnswerOfTheFirstRecoveryQuestionIsInvalid :
                    self.alertController(title: "Error", message: "Answer Of The First Question Is Invalid")
                    break
                    
                case .userTwoStepVerificationSetPasswordSecondRecoveryQuestionIsInvalid :
                    self.alertController(title: "Error", message: "Second Recovery Question Is Invalid")
                    break
                    
                case .userTwoStepVerificationSetPasswordAnswerOfTheSecondRecoveryQuestionIsInvalid :
                    self.alertController(title: "Error", message: "Answer Of The Second Question Is Invalid")
                    break
                    
                case .userTwoStepVerificationSetPasswordHintIsNotValid :
                    self.alertController(title: "Error", message: "Password Hint Is Not Valid")
                    break
                    
                default:
                    break
                }
                hud.hide(animated: true)
            }
        }).send()
    }
    
    func alertController(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}

