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
import RealmSwift
import MBProgressHUD
import IGProtoBuff

class IGSettingAccountUsernameTableViewController: UITableViewController , UIGestureRecognizerDelegate{
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusActivityIndicatorView: UIActivityIndicatorView!
    
    var shouldShowStatusCell = false
    var hud = MBProgressHUD()
    var maxLength = 16
    var minLength = 5
    var usernamecurrentStatus : IGCheckUsernameStatus!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField.delegate = self
        statusLabel.text = ""
        statusActivityIndicatorView.isHidden = true
        
        let predicate = NSPredicate(format: "id = %lld", IGAppManager.sharedManager.userID()!)
        if let userInDb = try! Realm().objects(IGRegisteredUser.self).filter(predicate).first {
            usernameTextField.text = userInDb.username
        }
        
        self.tableView.backgroundColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
        
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: "Done", title: "Username")
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        navigationItem.rightViewContainer?.addAction {
            self.didTapOnDoneButton()
        }
        
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    func checkUserName(username: String) {
        if IGGlobal.matches(for: "^[a-zA-Z]{1,}", in: username) {
            statusActivityIndicatorView.isHidden = false
            statusActivityIndicatorView.startAnimating()
            IGUserProfileCheckUsernameRequest.Generator.generate(username: username).success({ (protoResponse) in
                //step 1 : check validity of received data by comparing it to the current text in the textfield
                if username != self.usernameTextField.text {
                    print("response is out of date -> not valid")
                    return
                }
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let checkUsernameRespose as IGPUserProfileCheckUsernameResponse:
                        self.usernamecurrentStatus = IGUserProfileCheckUsernameRequest.Handler.interpret(response: checkUsernameRespose)
                        switch self.usernamecurrentStatus! {
                        case .available:
                            self.statusActivityIndicatorView.isHidden = true
                            self.statusActivityIndicatorView.stopAnimating()
                            self.statusLabel.textColor = UIColor.organizationalColor()
                            self.statusLabel.text = "\(username) is available"
                        case .invalid:
                            self.statusActivityIndicatorView.isHidden = true
                            self.statusActivityIndicatorView.stopAnimating()
                            self.statusLabel.textColor = UIColor.red
                            self.statusLabel.text = "Sorry, this username is invalid."
                        case .taken:
                            self.statusActivityIndicatorView.isHidden = true
                            self.statusActivityIndicatorView.stopAnimating()
                            self.statusLabel.textColor = UIColor.red
                            self.statusLabel.text = "Sorry, this username is already taken"
                        default:
                            break
                        }
                    default:
                        break
                    }
                }
            }).error ({ (errorCode, waitTime) in
                switch errorCode {
                case .timeout:
                    DispatchQueue.main.async {
                        self.statusActivityIndicatorView.isHidden = true
                        self.statusActivityIndicatorView.stopAnimating()
                        self.statusLabel.textColor = UIColor.red
                        self.statusLabel.text = "Timeout in checking validity of selected username"
                    }
                default:
                    break
                }
            }).send()
        } else {
            statusLabel.textColor = UIColor.red
            statusLabel.text = "Username contains invalid characters!"
        }
    }
    
    func didTapOnDoneButton() {
        if usernamecurrentStatus! == .available {
            self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            self.hud.mode = .indeterminate
            if let username = usernameTextField.text {
                IGUserProfileUpdateUsernameRequest.Generator.generate(username: username).success({ (protoResponse) in
                    DispatchQueue.main.async {
                        switch protoResponse {
                        case let setUsernameProtoResponse as IGPUserProfileUpdateUsernameResponse:
                            IGUserProfileUpdateUsernameRequest.Handler.interpret(response: setUsernameProtoResponse)
                            if self.navigationController is IGNavigationController {
                                _ = self.navigationController?.popViewController(animated: true)
                            }
                        default:
                            break
                        }
                        self.hud.hide(animated: true)
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
                            
                        case .userProfileUpdateUsernameIsInvaild:
                            let alert = UIAlertController(title: "Timeout", message: "Username is invalid", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alert.addAction(okAction)
                            self.present(alert, animated: true, completion: nil)
                            break
                            
                        case .userProfileUpdateUsernameHasAlreadyBeenTaken:
                            let alert = UIAlertController(title: "Timeout", message: "Username has already been taken by another user", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alert.addAction(okAction)
                            self.present(alert, animated: true, completion: nil)
                            break
                            
                        case .userProfileUpdateLock:
                            let time = waitTime
                            let remainingMiuntes = time!/60
                            let alert = UIAlertController(title: "Error", message: "You can not change your username because you've recently changed it. waiting for \(remainingMiuntes) minutes", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alert.addAction(okAction)
                            self.present(alert, animated: true,completion: nil)
                            break
                            
                        default:
                            break
                        }
                        
                        self.hud.hide(animated: true)
                    }
                }).send()
            }
        }
    }
}

extension IGSettingAccountUsernameTableViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        statusActivityIndicatorView.isHidden = true
        statusActivityIndicatorView.stopAnimating()
        guard var text = usernameTextField.text else { return true }
        let newLength = text.characters.count + string.characters.count - range.length
        
        if newLength > maxLength {
            statusLabel.text = "Username cannot be more than \(maxLength) characters!"
            statusLabel.textColor = UIColor.red
            usernamecurrentStatus = .invalid
            return false
        } else if newLength < minLength {
            statusLabel.text = "Username must be minimum \(minLength) characters!"
            usernamecurrentStatus = .invalid
            statusLabel.textColor = UIColor.red
        } else {
            let textFieldText: NSString = (textField.text ?? "") as NSString
            let newText = textFieldText.replacingCharacters(in: range, with: string)
            //TODO: add timeout for fast typing
            checkUserName(username: newText)
            statusLabel.text = ""
            statusLabel.textColor = UIColor.black
            usernamecurrentStatus = .needsValidation
        }
        return true
    }
}
