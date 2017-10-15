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
            }else {
                self.changedGroupTypeToPrivate()
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
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
        if let groupUserName = groupLinkTextField.text {
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
