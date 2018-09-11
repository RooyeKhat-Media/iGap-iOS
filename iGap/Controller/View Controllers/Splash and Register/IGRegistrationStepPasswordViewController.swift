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
import IGProtoBuff
import SwiftProtobuf
import MBProgressHUD

class IGRegistrationStepPasswordViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var passwordTextField: UITextField!

    var hud = MBProgressHUD()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.passwordTextField.isSecureTextEntry = true
        
        let navigaitonItem = self.navigationItem as! IGNavigationItem
        navigaitonItem.addNavigationViewItems(rightItemText: "Next", title: "Verification Code")
        navigaitonItem.rightViewContainer?.addAction {
            self.nextStep()
        }
        navigaitonItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.passwordTextField.becomeFirstResponder()
        
        IGUserTwoStepVerificationGetPasswordDetailRequest.Generator.generate().success({ (responseProto) in
            DispatchQueue.main.async {
                switch responseProto {
                case let passwordDetailReponse as IGPUserTwoStepVerificationGetPasswordDetailResponse:
                    let interpretedResponse = IGUserTwoStepVerificationGetPasswordDetailRequest.Handler.interpret(response: passwordDetailReponse)
                    if let hint = interpretedResponse.hint {
                        self.passwordTextField.placeholder = hint
                    }
                default:
                    break
                }
            }
        }).error { (errorCode, waitTime) in
            
        }.send()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func nextStep() {
        if passwordTextField.text==nil || passwordTextField.text=="" {
            DispatchQueue.main.async {
                let alertVC = UIAlertController(title: "Error", message: "Please enter your password.", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertVC.addAction(ok)
                self.present(alertVC, animated: true, completion: nil)
            }
            return
        }

        self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.hud.mode = .indeterminate
        
        if let password = passwordTextField.text {
            IGUserTwoStepVerificationVerifyPasswordRequest.Generator.generate(password: password).success({ (verifyPasswordReponse) in
                DispatchQueue.main.async {
                    switch verifyPasswordReponse {
                    case let verifyPasswordReponse as IGPUserTwoStepVerificationVerifyPasswordResponse:
                        let interpretedResponse = IGUserTwoStepVerificationVerifyPasswordRequest.Handler.interpret(response: verifyPasswordReponse)
                        IGAppManager.sharedManager.save(token: interpretedResponse)
                        self.loginUser(token: interpretedResponse)

                    default:
                        break
                    }
                }
            }).error({ (errorCode, waitTime) in
                var errorTitle = ""
                var errorBody = ""
                switch errorCode {
                case .userTwoStepVerificationVerifyPasswordBadPayload :
                    errorTitle = "Error"
                    errorBody = "Invalid payload"
                break
                case .userTwoStepVerificationVerifyPasswordInternalServerError :
                    errorTitle = "Error"
                    errorBody = "Inernal server error. Try agian later and if problem persists contact iGap support."
                    break
                case .userTwoStepVerificationVerifyPasswordMaxTryLock :
                    errorTitle = ""
                    errorBody = "Too many failed password verification attempt."
                break
                case .userTwoStepVerificationVerifyPasswordInvalidPassword :
                    errorTitle = "Invalid Code"
                    errorBody = "The password you entered is not valid. Verify the password and try again."
                    break
                case .timeout:
                    errorTitle = "Timeout"
                    errorBody = "Please try again later."
                    break
                default:
                    errorTitle = "Unknown error"
                    errorBody = "An error occured. Please try again later.\nCode \(errorCode)"
                    break
                }
                if waitTime != nil &&  waitTime != 0 {
                    errorBody += "\nPlease try again in \(waitTime!) seconds."
                }
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: errorTitle, message: errorBody, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.hud.hide(animated: true)
                    self.present(alert, animated: true, completion: nil)
                }

            }).send()
        }
    }

    fileprivate func loginUser(token: String) {
        IGUserLoginRequest.Generator.generate(token: token).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case _ as IGPUserLoginResponse:
                    IGUserLoginRequest.Handler.intrepret(response: (protoResponse as? IGPUserLoginResponse)!)
                    IGAppManager.sharedManager.isUserLoggedIn.value = true

                    IGUserInfoRequest.Generator.generate(userID: IGAppManager.sharedManager.userID()!).success({ (protoResponse) in
                        DispatchQueue.main.async {
                            switch protoResponse {
                            case let userInfoResponse as IGPUserInfoResponse:
                                let igpUser = userInfoResponse.igpUser
                                IGFactory.shared.saveRegistredUsers([igpUser])
                                break
                            default:
                                break
                            }
                            self.hud.hide(animated: true)
                            self.dismiss(animated: true, completion: {
                                IGAppManager.sharedManager.setUserLoginSuccessful()
                            })
                        }
                    }).error({ (errorCode, waitTime) in
                        DispatchQueue.main.async {
                            self.hud.hide(animated: true)
                            let alertVC = UIAlertController(title: "Error", message: "There was an error logging you in. Try again please.", preferredStyle: .alert)
                            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alertVC.addAction(ok)
                            self.present(alertVC, animated: true, completion: nil)
                        }
                    }).send()

                default:
                    break
                }
            }
        }).error({ (errorCode, waitTime) in
            DispatchQueue.main.async {
                self.hud.hide(animated: true)
                let alertVC = UIAlertController(title: "Error", message: "There was an error logging you in. Try again please.", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertVC.addAction(ok)
                self.present(alertVC, animated: true, completion: nil)
            }
        }).send()
    }

}
