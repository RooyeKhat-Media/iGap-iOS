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
import RealmSwift
import MBProgressHUD
import IGProtoBuff

class IGSetNickNameTableViewController: UITableViewController , UITextFieldDelegate , UIGestureRecognizerDelegate {

    @IBOutlet weak var nickNameTextField: UITextField!
    let greenColor = UIColor.organizationalColor()
    var hud = MBProgressHUD()
    var limitLength = 16
    override func viewDidLoad() {
        super.viewDidLoad()
        nickNameTextField.delegate = self
        self.tableView.backgroundColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: "Done", title: "Nickname")
        navigationItem.navigationController = self.navigationController as! IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        navigationItem.rightViewContainer?.addAction {
            self.doneButtonClicked()
        }
        let currentUserId = IGAppManager.sharedManager.userID()
        let realm = try! Realm()
        let predicate = NSPredicate(format: "id = %lld", currentUserId!)
        if let userInDb = realm.objects(IGRegisteredUser.self).filter(predicate).first {
            nickNameTextField.text = userInDb.displayName
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == " " {
            return false
        }else{
            return true
        }
        guard let text = nickNameTextField.text else { return true }
        let newLength = text.characters.count + string.characters.count - range.length
        if(newLength <= 16) {
            return true
        } else {
            return false
        }
        
    
        let numberOfChar = limitLength - newLength
        return newLength < limitLength
    }
    func getUserNickname(){
        self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.hud.mode = .indeterminate
        IGUserProfileGetNicknameRequest.Generator.generate().success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let getUsernicknameResponse as IGPUserProfileGetNicknameResponse:
                    let nickname = IGUserProfileGetNicknameRequest.Handler.interpret(response: getUsernicknameResponse)
                    self.nickNameTextField.text = nickname
                    self.hud.hide(animated: true)
                    
                default:
                    break
                }
            }
        }).error ({ (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Timeout", message: "Please try again later", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.hud.hide(animated: true)
                    self.present(alert, animated: true, completion: nil)
                }
            default:
                break
            }
            
        }).send()

    }
    
    func doneButtonClicked(){
        if nickNameTextField.text?.isEmpty == true {
            let alert = UIAlertController(title: "Alert", message: "Please fill in the Nickname field. ", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            alert.view.tintColor = UIColor.organizationalColor()
            self.present(alert, animated: true, completion: nil)
        } else {
            self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            self.hud.mode = .indeterminate
            if let userNickname = nickNameTextField.text {
                IGUserProfileSetNicknameRequest.Generator.generate(nickname: userNickname).success({ (protoResponse) in
                    DispatchQueue.main.async {
                        switch protoResponse {
                        case let setNicknameProtoResponse as IGPUserProfileSetNicknameResponse:
                            IGUserProfileSetNicknameRequest.Handler.interpret(response: setNicknameProtoResponse)
                            self.hud.hide(animated: true)
                            if self.navigationController is IGNavigationController {
                                self.navigationController?.popViewController(animated: true)
                            }
                        default:
                            break
                        }
                    }
                }).error ({ (errorCode, waitTime) in
                    switch errorCode {
                    case .timeout:
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "Timeout", message: "Please try again later", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alert.addAction(okAction)
                            self.hud.hide(animated: true)
                            self.present(alert, animated: true, completion: nil)
                        }
                    default:
                        break
                    }
                    
                }).send()
            }
        }
    }

 
}
