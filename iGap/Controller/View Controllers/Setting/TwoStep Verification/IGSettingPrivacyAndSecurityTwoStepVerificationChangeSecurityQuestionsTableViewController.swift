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

class IGSettingPrivacyAndSecurityTwoStepVerificationChangeSecurityQuestionsTableViewController: UITableViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var question1TextField: UITextField!
    @IBOutlet weak var answer1TextField: UITextField!
    @IBOutlet weak var question2TextField: UITextField!
    @IBOutlet weak var answer2TextField: UITextField!
    
    var password: String?
    var questionOne: String?
    var questionTwo: String?
    var pageAction: IGTwoStepQuestion = IGTwoStepQuestion.changeRecoveryQuestion
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        let navigationItem = self.navigationItem as! IGNavigationItem
        
        if self.pageAction == IGTwoStepQuestion.changeRecoveryQuestion {
            navigationItem.addNavigationViewItems(rightItemText: "Done", title: "Change Recovery Question")
        } else if self.pageAction == IGTwoStepQuestion.questionRecoveryPassword {
            navigationItem.addNavigationViewItems(rightItemText: "Done", title: "Recover Password")
        }
        
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        navigationItem.rightViewContainer?.addAction {
            if self.pageAction == IGTwoStepQuestion.changeRecoveryQuestion {
                self.changeRecoveryQuestion()
            } else if self.pageAction == IGTwoStepQuestion.questionRecoveryPassword {
                self.recoveryPassword()
            }
        }
        
        if self.pageAction == IGTwoStepQuestion.questionRecoveryPassword {
            question1TextField.text = questionOne
            question2TextField.text = questionTwo
        }
    }
    
    func changeRecoveryQuestion(){
        if !isComplete() {
            return
        }
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = .indeterminate
        IGUserTwoStepVerificationChangeRecoveryQuestionRequest.Generator.generate(password: self.password!, questionOne: question1TextField.text!, answerOne: answer1TextField.text!, questionTwo: question2TextField.text!, answerTwo: answer2TextField.text!).success({ (protoResponse) in
            DispatchQueue.main.async {
                hud.hide(animated: true)
                if ((protoResponse as? IGPUserTwoStepVerificationChangeRecoveryQuestionResponse) != nil) {
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
                    break
                case .userTwoStepVerificationChangeRecoveryQuestionMaxTryLock:
                    let alert = UIAlertController(title: "Error", message: "Max Try Lock", preferredStyle: .alert)
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
    
    func recoveryPassword(){
        if !isComplete(){
            return
        }
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = .indeterminate
        IGUserTwoStepVerificationRecoverPasswordByAnswersRequest.Generator.generate(answerOne: answer1TextField.text!, answerTwo: answer2TextField.text!).success({ (protoResponse) in
            DispatchQueue.main.async {
                hud.hide(animated: true)
                let alert = UIAlertController(title: "Success", message: "Your password removed", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: { (alert: UIAlertAction!) -> Void in
                    self.dismiss(animated: true, completion: nil)
                })
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            }
        }).error ({ (errorCode, waitTime) in
            DispatchQueue.main.async {
                switch errorCode {
                case .timeout:
                    self.showAlert(title: "Timeout", message: "Please try again later")
                    break
                    
                case .userTwoStepVerificationRecoverPasswordByAnswersMaxTryLock:
                    self.showAlert(title: "Error", message: "Max Try Lock")
                    break
               
                case .userTwoStepVerificationRecoverPasswordByAnswersInvalidAnswers:
                    self.showAlert(title: "Error", message: "Invalid Answers")
                    break
                    
                case .userTwoStepVerificationRecoverPasswordByAnswersForbidden:
                    self.showAlert(title: "Error", message: "Recover By Answers Is Forbidden")
                    break
                    
                default:
                    break
                }
                hud.hide(animated: true)
            }
        }).send()
    }
    
    private func isComplete() -> Bool {
        if question1TextField.text == "" || question2TextField.text == "" || answer1TextField.text == "" || answer2TextField.text == "" {
            let alert = UIAlertController(title: "Error", message: "Please Complete All Sections", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            return false
        }
        return true
    }
}
