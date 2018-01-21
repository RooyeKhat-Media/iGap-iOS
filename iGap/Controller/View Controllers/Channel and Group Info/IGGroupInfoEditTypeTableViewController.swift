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

class IGGroupInfoEditTypeTableViewController: UITableViewController , UITextFieldDelegate , UIGestureRecognizerDelegate {
    
    @IBOutlet weak var groupPublicCell: UITableViewCell!
    @IBOutlet weak var groupLinkTextField: UITextField!
    @IBOutlet weak var groupPrivateCell: UITableViewCell!
    var publicIndexPath : IndexPath?
    var privateIndexPath : IndexPath?
    var room: IGRoom?
    var hud = MBProgressHUD()
    var userWantsToChangeGroupTypeToPrivate: Bool = false
    var userWantsToChangeGroupTypeToPublic: Bool = false
    
    @IBAction func edtTextChange(_ sender: UITextField) {
        if let text = sender.text {
            if text.count >= 5 {
                checkUsername(username: sender.text!)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        privateIndexPath = IndexPath(row: 1, section: 0)
        publicIndexPath = IndexPath(row: 0, section: 0)
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: "Done", title: "Type")
        navigationItem.navigationController = self.navigationController as! IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        navigationItem.rightViewContainer?.addAction {
            if self.userWantsToChangeGroupTypeToPublic  {
                self.changedGroupTypeToPublic()
            } else if self.userWantsToChangeGroupTypeToPrivate {
                self.changedGroupTypeToPrivate()
            } else {
                //update user name
                if self.room?.groupRoom?.type == .publicRoom {
                    self.changedGroupTypeToPublic()
                }
            }
        }
        if self.room?.groupRoom?.type == .publicRoom {
            tableView.selectRow(at: publicIndexPath, animated: true, scrollPosition: .none)
            let selectedCell = tableView.cellForRow(at: publicIndexPath!)
            selectedCell?.accessoryType = .checkmark
            groupLinkTextField.text = room?.groupRoom?.publicExtra?.username
            
            groupLinkTextField.isUserInteractionEnabled = true
            groupLinkTextField.text = nil
            let groupDefualtName = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: 44))
            groupDefualtName.font = UIFont.systemFont(ofSize: 14)
            groupDefualtName.text = "iGap.net/"
            groupLinkTextField.leftView = groupDefualtName
            groupLinkTextField.leftViewMode = UITextFieldViewMode.always
            groupLinkTextField.placeholder = "yourlink"
            groupLinkTextField.delegate = self
            
            if let username = room?.groupRoom?.publicExtra?.username {
                groupLinkTextField.text = username
            }
            
        }
        if self.room?.groupRoom?.type == .privateRoom {
            tableView.selectRow(at: privateIndexPath, animated: true, scrollPosition: .none)
            let selectedCell = tableView.cellForRow(at: privateIndexPath!)
            selectedCell?.accessoryType = .checkmark
            groupLinkTextField.text = room?.groupRoom?.privateExtra?.inviteLink
            groupLinkTextField.isUserInteractionEnabled = false
        }
    }
    
    func checkUsername(username: String){
        IGGroupCheckUsernameRequest.Generator.generate(roomId:room!.id ,username: username).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let usernameResponse as IGPGroupCheckUsernameResponse :
                    if usernameResponse.igpStatus == IGPGroupCheckUsernameResponse.IGPStatus.available {
                        self.groupLinkTextField.textColor = UIColor.black
                    } else {
                        self.groupLinkTextField.textColor = UIColor.red
                    }
                    break
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
            }
        }).send()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return 1
        default:
            return 0
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if  indexPath.section == 0 {
            if indexPath.row == 0 {
                groupPublicCell.accessoryType = .checkmark
                groupPrivateCell.accessoryType = .none
                privateIndexPath = indexPath
                userWantsToChangeGroupTypeToPublic = true
                groupLinkTextField.isUserInteractionEnabled = true
                groupLinkTextField.text = nil
                let groupDefualtName = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: 44))
                groupDefualtName.font = UIFont.systemFont(ofSize: 14)
                groupDefualtName.text = "iGap.net/"
                groupLinkTextField.leftView = groupDefualtName
                groupLinkTextField.leftViewMode = UITextFieldViewMode.always
                groupLinkTextField.placeholder = "yourlink"
                groupLinkTextField.delegate = self
                
                if let username = room?.groupRoom?.publicExtra?.username {
                    groupLinkTextField.text = username
                }
                
            } else if indexPath.row == 1 {
                groupPublicCell.accessoryType = .none
                groupPrivateCell.accessoryType = .checkmark
                publicIndexPath = indexPath
                userWantsToChangeGroupTypeToPrivate = true
                
                groupLinkTextField.leftView = nil
                if let invitedLink = room?.groupRoom?.privateExtra?.inviteLink {
                    groupLinkTextField.text = invitedLink
                } else {
                    groupLinkTextField.text = "Invite link will be generated ..."
                }
                
                groupLinkTextField.isUserInteractionEnabled = false
                groupLinkTextField.delegate = self
            }
            tableView.reloadData()
        }
    }
    
    func changedGroupTypeToPrivate() {
        if let roomID = room?.id {
            self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            self.hud.mode = .indeterminate
            IGGroupRemoveUsernameRequest.Generator.generate(roomId: roomID).success({ (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let groupRemoveUsernameResponse as IGPGroupRemoveUsernameResponse:
                        IGGroupRemoveUsernameRequest.Handler.interpret(response: groupRemoveUsernameResponse)
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
    
    func changedGroupTypeToPublic(){
        
        if room!.groupRoom!.type == .publicRoom && room?.groupRoom?.publicExtra?.username == groupLinkTextField.text {
            _ = self.navigationController?.popViewController(animated: true)
            return
        }
        
        if let groupUserName = groupLinkTextField.text {
            
            if groupUserName == "" {
                let alert = UIAlertController(title: "Error", message: "Group link cannot be empty", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okAction)
                self.hud.hide(animated: true)
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            if groupUserName.count < 5 {
                let alert = UIAlertController(title: "Error", message: "Enter at least 5 letters", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okAction)
                self.hud.hide(animated: true)
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            self.hud.mode = .indeterminate
            IGGroupUpdateUsernameRequest.Generator.generate(roomID: room!.id ,userName:groupUserName).success({ (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let groupUpdateUserName as IGPGroupUpdateUsernameResponse :
                        IGGroupUpdateUsernameRequest.Handler.interpret(response: groupUpdateUserName)
                        
                        if self.navigationController is IGNavigationController {
                            self.navigationController?.popViewController(animated: true)
                        }
                        
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
                        
                    case .groupUpdateUsernameIsInvalid:
                        let alert = UIAlertController(title: "Error", message: "Username is invalid", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                        break
                        
                    case .groupUpdateUsernameHasAlreadyBeenTakenByAnotherUser:
                        let alert = UIAlertController(title: "Error", message: "Username has already been taken by another user", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                        break
                        
                    case .groupUpdateUsernameMoreThanTheAllowedUsernmaeHaveBeenSelectedByYou:
                        let alert = UIAlertController(title: "Error", message: "More than the allowed usernmae have been selected by you", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                        break
                        
                    case .groupUpdateUsernameForbidden:
                        let alert = UIAlertController(title: "Error", message: "Update username forbidden!", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                        break
                        
                    case .groupUpdateUsernameLock:
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
