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

class IGRegistrationStepVerificationCodeViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var retrySendingCodeLabel: UILabel!
    var canRequestNewCode = false
    var phone : String?
    var phoneNumber : String?
    var delayBeforeSendingAgaing : Int32? = 360
    var username : String?
    var userID : Int64?
    var codeDigitsCount : Int32?
    var codeRegex : String?
    var selectedCountry : IGCountryInfo?
    var isUserNew : Bool?
    var verificationMethod : IGVerificationCodeSendMethod?
    var hud = MBProgressHUD()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        codeTextField.delegate = self
        
        let navigaitonItem = self.navigationItem as! IGNavigationItem
        navigaitonItem.addNavigationViewItems(rightItemText: "Next", title: "Verification Code")
        navigaitonItem.rightViewContainer?.addAction {
            self.didTapOnNext()
        }
        navigaitonItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.codeTextField.becomeFirstResponder()
        var varificationMethodString = " via "
        switch verificationMethod! {
        case .sms:
            varificationMethodString += "SMS"
        case .igap:
            varificationMethodString += "iGap"
        case .both:
            varificationMethodString += "SMS and iGap"
        }
        self.titleLabel.text = "Please enter the verification code sent \nto " + phoneNumber! + varificationMethodString
        updateCountDown()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func didTapOnNext() {
        if let code = codeTextField.text {
            if IGGlobal.matches(for: self.codeRegex!, in: code) {
                verifyUser()
            } else {
                let alertVC = UIAlertController(title: "Invalid Code", message: "Please enter a valid code", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    
                })
                
                alertVC.addAction(ok)
                self.present(alertVC, animated: true, completion: {
                    
                })
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    
    func updateCountDown() {
        self.delayBeforeSendingAgaing! -= 1
        if self.delayBeforeSendingAgaing!>0 {
            let fixedText = "Didn't receive the text message?\nPlease wait"
            let remainingSeconds = self.delayBeforeSendingAgaing!%60
            let remainingMiuntes = self.delayBeforeSendingAgaing!/60
            retrySendingCodeLabel.text = "\(fixedText) \(remainingMiuntes):\(remainingSeconds)"
            self.perform(#selector(IGRegistrationStepVerificationCodeViewController.updateCountDown), with: nil, afterDelay: 1.0)
        } else {
            retrySendingCodeLabel.text = "Tap here to resend code"
            let tap = UITapGestureRecognizer(target: self, action: #selector(IGDeleteAccountConfirmationTableViewController.tapFunction))
            retrySendingCodeLabel.isUserInteractionEnabled = true
            retrySendingCodeLabel.addGestureRecognizer(tap)
        }
    }
    
    func tapFunction(sender:UITapGestureRecognizer) {
        getRegisterToken()
    }
    func getRegisterToken(){
        self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.hud.mode = .indeterminate
        let phoneSpaceLess = phone?.replacingOccurrences(of: " ", with: "")
        let reqW = IGUserRegisterRequest.Generator.generate(countryCode: (self.selectedCountry?.countryISO)!,
        phoneNumber: Int64(phoneSpaceLess!)!)
        reqW.success { (responseProto) in
            DispatchQueue.main.async {
                switch responseProto {
                case let userRegisterReponse as IGPUserRegisterResponse:
                    IGUserRegisterRequest.Handler.intrepret(response: userRegisterReponse)
                    self.hud.hide(animated: true)
                default:
                    break
                }
            }
            
            }.error { (errorCode, waitTime) in
                var errorTitle = ""
                var errorBody = ""
                switch errorCode {
                case .userRegisterBadPaylaod:
                    errorTitle = "Error"
                    errorBody = "Invalid data\nCode \(errorCode)"
                    break
                case .userRegisterInvalidCountryCode:
                    errorTitle = "Error"
                    errorBody = "Invalid country"
                    break
                case .userRegisterInvalidPhoneNumber:
                    errorTitle = "Error"
                    errorBody = "Invalid phone number"
                    break
                case .userRegisterInternalServerError:
                    errorTitle = "Error"
                    errorBody = "Internal Server Error"
                    break
                case .userRegisterBlockedUser:
                    errorTitle = "Error"
                    errorBody = "This phone number is blocked"
                    break
                case .userRegisterLockedManyCodeTries:
                    errorTitle = "Error"
                    errorBody = "To many failed code verification attempt."
                    break
                case .userRegisterLockedManyResnedRequest:
                    errorTitle = "Error"
                    errorBody = "To many code sending request."
                    break
                case .timeout:
                    errorTitle = "Timeout"
                    errorBody = "Please try again later"
                    break
                default:
                    errorTitle = "Unknown error"
                    errorBody = "An error occured. Please try again later.\nCode \(errorCode)"
                    break
                }
                
                
                if waitTime != nil  && waitTime! != 0 {
                    errorBody += "\nPlease try again in \(waitTime! ) seconds."
                }
                
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: errorTitle, message: errorBody, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.hud.hide(animated: true)
                    self.present(alert, animated: true, completion: nil)
                }
                
            }.send()
    }
    
    fileprivate func verifyUser() {
        self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.hud.mode = .indeterminate
        if let code = Int32(codeTextField.text!){
            IGUserVerifyRequest.Generator.generate(usename: self.username!, code: code).success({ (responseProto) in
                DispatchQueue.main.async {
                    switch responseProto {
                    case let userVerifyReponse as IGPUserVerifyResponse:
                        let interpretedResponse = IGUserVerifyRequest.Handler.intrepret(response: userVerifyReponse)
                        IGAppManager.sharedManager.save(token: interpretedResponse.token)
                        self.isUserNew = interpretedResponse.newuser
                        self.loginUser(token: interpretedResponse.token)
                    default:
                        break
                    }    
                }
            }).error({ (errorCode, waitTime) in
                if errorCode == .userVerifyTwoStepVerificationEnabled {
                    DispatchQueue.main.async {
                        self.hud.hide(animated: false)
                        self.performSegue(withIdentifier:"twoStepPassword", sender: nil);
                    }
                }else{
                    var errorTitle = ""
                    var errorBody = ""
                    switch errorCode {
                    case .userVerifyBadPayload:
                        errorTitle = "Error"
                        errorBody = "Invalid payload"
                        break
                    case .userVerifyBadPayloadInvalidCode:
                        errorTitle = "Error"
                        errorBody = "The code payload is invalid."
                        break
                    case .userVerifyBadPayloadInvalidUsername:
                        errorTitle = "Error"
                        errorBody = "Username payload is invalid."
                        break
                    case .userVerifyInternalServerError:
                        errorTitle = "Error"
                        errorBody = "Inernal server error. Try agian later and if problem persists contact iGap support."
                        break
                    case .userVerifyUserNotFound:
                        errorTitle = "Error"
                        errorBody = "Could not found the request user. Try agian later and if problem persists contact iGap support."
                        break
                    case .userVerifyBlockedUser:
                        errorTitle = "Error"
                        errorBody = "This use is blocked. You cannot register."
                        break
                    case .userVerifyInvalidCode:
                        errorTitle = "Invalid Code"
                        errorBody = "The code you entred is not valid. Verify the code and try again."
                        break
                    case .userVerifyExpiredCode:
                        errorTitle = "Invalid Code"
                        errorBody = "Code has been expired. Please request a new code."
                        break
                    case .userVerifyMaxTryLock:
                        errorTitle = ""
                        errorBody = "Too many failed code verification attempt."
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
                }
            }).send()
        }
    }
    
    fileprivate func loginUser(token: String) {
        IGUserLoginRequest.Generator.generate(token: token).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case _ as IGPUserLoginResponse:
                    IGAppManager.sharedManager.setUserLoginSuccessful()
                    if self.isUserNew! {
                        self.hud.hide(animated: true)
                        self.performSegue(withIdentifier: "showYourProfile", sender: self)
                    } else {
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
                                IGAppManager.sharedManager.setUserLoginSuccessful()
                                self.dismiss(animated: true, completion: nil)
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

                default:
                    break
                }    
            }
        }).error({ (errorCode, waitTime) in
            
        }).send()
    }
}

extension IGRegistrationStepVerificationCodeViewController : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        if IGGlobal.matches(for: self.codeRegex!, in: textField.text! + string) {
//            self.verifyUser()
//        }
        return true
    }
}
