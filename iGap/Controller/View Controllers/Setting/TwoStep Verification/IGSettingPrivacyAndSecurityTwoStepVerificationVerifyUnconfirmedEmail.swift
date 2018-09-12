//
//  IGSettingPrivacyAndSecurityTwoStepVerificationVerifyUnconfirmedEmail.swift
//  iGap
//
//  Created by MacBook Pro on 1/2/18.
//  Copyright © 2018 RooyeKhat Media. All rights reserved.
//

import UIKit
import MBProgressHUD
import IGProtoBuff

class IGSettingPrivacyAndSecurityTwoStepVerificationVerifyUnconfirmedEmail: UITableViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var edtVerifyCode: UITextField!
    @IBOutlet weak var btnOutletResendCode: UIButton!
    
    var token: String = ""
    var manuallyResendCode = false
    var pageAction: IGTwoStepEmail?
    
    @IBAction func btnResendVerificationCode(_ sender: Any) {
        manuallyResendCode = true
        if self.pageAction == IGTwoStepEmail.verifyEmail {
            self.resendVerifyEmail()
        } else if self.pageAction == IGTwoStepEmail.recoverPassword{
            self.resendRecoveryToken()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        btnOutletResendCode.removeUnderline()
        
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        let navigationItem = self.navigationItem as! IGNavigationItem
        
        if self.pageAction == IGTwoStepEmail.verifyEmail {
            navigationItem.addNavigationViewItems(rightItemText: "Done", title: "Verify Email")
        } else if self.pageAction == IGTwoStepEmail.recoverPassword{
            navigationItem.addNavigationViewItems(rightItemText: "Done", title: "Recover Password")
        }
        
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        navigationItem.rightViewContainer?.addAction {
            
            if self.pageAction == IGTwoStepEmail.verifyEmail {
                self.verifyRecoverEmail()
            } else if self.pageAction == IGTwoStepEmail.recoverPassword{
                self.recoverPassByToken()
            }
        }
        
        if self.pageAction == IGTwoStepEmail.verifyEmail {
            self.resendVerifyEmail()
        } else if self.pageAction == IGTwoStepEmail.recoverPassword{
            btnOutletResendCode.setTitle("Resend Recover Code",for: .normal)
            self.resendRecoveryToken()
        }
    }
    
    func resendVerifyEmail(){
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = .indeterminate
        IGUserTwoStepVerificationResendVerifyEmailRequest.Generator.generate().success({ (protoResponse) in
            
            DispatchQueue.main.async {
                hud.hide(animated: true)
                if ((protoResponse as? IGPUserTwoStepVerificationResendVerifyEmailResponse) != nil) {
                    if self.manuallyResendCode {
                        self.showAlert(title: "Success", message: "Please check your email")
                    }
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
    
    func verifyRecoverEmail(){
        
        if edtVerifyCode.text == nil || edtVerifyCode.text == "" {
            let alert = UIAlertController(title: "Error", message: "Please first enter your code", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = .indeterminate
        IGUserTwoStepVerificationVerifyRecoveryEmailRequest.Generator.generate(token: edtVerifyCode.text!).success({ (protoResponse) in
            
            DispatchQueue.main.async {
                hud.hide(animated: true)
                if ((protoResponse as? IGPUserTwoStepVerificationVerifyRecoveryEmailResponse) != nil) {
                    IGSettingPrivacyAndSecurityTwoStepVerificationOptionsTableViewController.verifiedEmail = true
                    let alert = UIAlertController(title: "Success", message: "Your email successfuly verified", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: { (alert: UIAlertAction!) -> Void in
                        self.navigationController?.popViewController(animated: true)
                    })
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
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
                    
                case .userTwoStepVerificationVerifyRecoveryEmailMaxTryLock:
                    let alert = UIAlertController(title: "Error", message: "Max try lock", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    
                case .userTwoStepVerificationVerifyRecoveryEmailExpiredToken:
                    let alert = UIAlertController(title: "Error", message: "Email expired token", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    
                case .userTwoStepVerificationVerifyRecoveryEmailInvalidToken:
                    let alert = UIAlertController(title: "Error", message: "Email invalid token", preferredStyle: .alert)
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
    
    func resendRecoveryToken(){
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = .indeterminate
        self.tableView.isScrollEnabled = false
        IGUserTwoStepVerificationRequestRecoveryTokenRequest.Generator.generate().success({ (success) in
            DispatchQueue.main.async {
                hud.hide(animated: true)
                if self.manuallyResendCode {
                    self.showAlert(title: "Success", message: "Please check your email")
                }
            }
        }).error({ (errorCode, waitTime) in
            DispatchQueue.main.async {
                hud.hide(animated: true)
                switch errorCode {
                case .timeout:
                    let alert = UIAlertController(title: "Timeout", message: "Please try again later", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    break
                    
                case .userTwoStepVerificationRequestRecoveryTokenNoRecoVeryEmail:
                    self.showAlert(title: "Error", message: "Not Exist Verified Email")
                    break
                    
                case .userTwoStepVerificationRequestRecoveryTokenMaxTryLock:
                    self.showAlert(title: "Error", message: "Recovery Max Try Lock, Please Try Later!")
                    break
                    
                case .userTwoStepVerificationRequestRecoveryTokenForbidden:
                    self.showAlert(title: "Error", message: "Recovery Token Forbidden")
                    break
                    
                default:
                    break
                }
            }
        }).send()
    }
    
    func recoverPassByToken(){
        if edtVerifyCode.text == nil || edtVerifyCode.text == "" {
            let alert = UIAlertController(title: "Error", message: "Please first enter your code", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = .indeterminate
        self.tableView.isScrollEnabled = false
        IGUserTwoStepVerificationRecoverPasswordByTokenRequest.Generator.generate(token: edtVerifyCode.text!).success({ (success) in
            DispatchQueue.main.async {
                hud.hide(animated: true)
                let alert = UIAlertController(title: "Success", message: "Your password removed", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: { (alert: UIAlertAction!) -> Void in
                    self.dismiss(animated: true, completion: nil)
                })
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            }
        }).error({ (errorCode, waitTime) in
            DispatchQueue.main.async {
                hud.hide(animated: true)
                switch errorCode {
                case .timeout:
                    let alert = UIAlertController(title: "Timeout", message: "Please try again later", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    break
                    
                case .userTwoStepVerificationRecoverPasswordByTokenExpiredToken:
                    self.showAlert(title: "Error", message: "Your token is expired")
                    break
                    
                case .userTwoStepVerificationRecoverPasswordByTokenMaxTryLock:
                    self.showAlert(title: "Error", message: "Recovery Max Try Lock, Please Try Later!")
                    break
                    
                case .userTwoStepVerificationRecoverPasswordByTokenInvalidToken:
                    self.showAlert(title: "Error", message: "Your token is invalid")
                    break
                    
                default:
                    break
                }
            }
        }).send()
    }

}
