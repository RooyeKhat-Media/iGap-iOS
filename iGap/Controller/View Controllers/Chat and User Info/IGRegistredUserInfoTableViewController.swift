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
import Contacts
import RealmSwift
import IGProtoBuff
import MBProgressHUD

class IGRegistredUserInfoTableViewController: UITableViewController , UIGestureRecognizerDelegate {

    var user: IGRegisteredUser?
    var previousRoomId: Int64?
    var room: IGRoom?
    var hud = MBProgressHUD()
    
    @IBOutlet weak var avatarView: IGAvatarView!
    @IBOutlet weak var blockContactLabel: UILabel!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if user != nil {
            self.avatarView.setUser(user!)
            self.displayNameLabel.text = user!.displayName
            if let phone = user?.phone {
                if phone == 0 {
                    self.phoneNumberLabel.text = "Hidden"
                } else {
                    self.phoneNumberLabel.text = "\(phone)"
                }
            }
            self.usernameLabel.text = user!.username
        }
        if let selectedUser = user {
        let blockedUserPredicate = NSPredicate(format: "id = %lld", selectedUser.id)
            if let blockedUser = try! Realm().objects(IGRegisteredUser.self).filter(blockedUserPredicate).first {
                print(blockedUser.displayName)
                   if blockedUser.isBlocked == true {
                       blockContactLabel.text = "Unblock Contact"
                   }
            }
        }
        let navigaitonItem = self.navigationItem as! IGNavigationItem
        navigaitonItem.addNavigationViewItems(rightItemText: nil, title: "Contact Info")
        navigaitonItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.isUserInteractionEnabled = true

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        if let room = self.room {
            switch room.type {
            case .chat:
                return 4
            case .group:
                return 2
            case .channel:
                return 2
            }
        }
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3
        case 1:
            if let room = self.room {
                switch room.type {
                case .chat:
                    return 3
                case .group:
                    return 2
                case .channel:
                    return 2
                }
            }
            return 2
        case 2:
            return 1
        case 3:
            return 1
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                createChat()
            case 1:
                if let selectedUser = user {
                    if selectedUser.isBlocked == true {
                        unblockedContact()
                    } else if selectedUser.isBlocked == false {
                        blockedContact()
                    }
                }
            case 2:
                self.tableView.isUserInteractionEnabled = false
                self.performSegue(withIdentifier: "showCreateGroupPage", sender: self)
                
            default:
                break
            }
        }
        if indexPath.section == 2 && indexPath.row == 0 {
            showDeleteActionSheet()
        }
        if indexPath.section == 3 && indexPath.row == 0 {
            showClearHistoryActionSheet()
        }
    }
    
    func createChat() {
        if let selectedUser = user {
            let hud = MBProgressHUD.showAdded(to: self.view.superview!, animated: true)
            hud.mode = .indeterminate
            IGChatGetRoomRequest.Generator.generate(peerId: selectedUser.id).success({ (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let chatGetRoomResponse as IGPChatGetRoomResponse:
                        let roomId = IGChatGetRoomRequest.Handler.interpret(response: chatGetRoomResponse)
                        
                        //segue to created chat
                        if roomId == self.previousRoomId {
                            _ = self.navigationController?.popViewController(animated: true)
                        } else {
                            //segue
                            IGClientGetRoomRequest.Generator.generate(roomId: roomId).success({ (protoResponse) in
                                DispatchQueue.main.async {
                                    switch protoResponse {
                                    case let clientGetRoomResponse as IGPClientGetRoomResponse:
                                        IGClientGetRoomRequest.Handler.interpret(response: clientGetRoomResponse)
                                        let room = IGRoom(igpRoom: clientGetRoomResponse.igpRoom)
                                        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                        let roomVC = storyboard.instantiateViewController(withIdentifier: "messageViewController") as! IGMessageViewController
                                        roomVC.room = room
                                        self.navigationController!.pushViewController(roomVC, animated: true)
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
                                    default:
                                        break
                                    }
                                    self.hud.hide(animated: true)
                                }
                            }).send()
                            
                        }
                        hud.hide(animated: true)
                        break
                    default:
                        break
                    }
                }
                
            }).error({ (errorCode, waitTime) in
                hud.hide(animated: true)
                let alertC = UIAlertController(title: "Error", message: "An error occured trying to create a conversation", preferredStyle: .alert)
                
                let cancel = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertC.addAction(cancel)
                self.present(alertC, animated: true, completion: nil)
            }).send()
        }
        
    }
    
    func blockedContact() {
        if let selectedUser = user {
            self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            self.hud.mode = .indeterminate
            IGUserContactsBlockRequest.Generator.generate(blockedUserId: selectedUser.id).success({
                (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let blockedProtoResponse as IGPUserContactsBlockResponse:
                        IGUserContactsBlockRequest.Handler.interpret(response: blockedProtoResponse)
                        self.blockContactLabel.text = "Unblock Contact"
                        self.hud.hide(animated: true)
                    default:
                        break
                    }
                }
            }).error({ (errorCode, waitTime) in
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
    
    func unblockedContact() {
        if let selectedUser = user {
            self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            self.hud.mode = .indeterminate
            IGUserContactsUnBlockRequest.Generator.generate(unBlockedUserId: selectedUser.id).success({
                (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let unBlockedProtoResponse as IGPUserContactsUnblockResponse:
                        _ = IGUserContactsUnBlockRequest.Handler.interpret(response: unBlockedProtoResponse)
                        self.blockContactLabel.text = "Block Contact"
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
    }
    
    func showDeleteActionSheet() {
        let deleteChatConfirmAlertView = UIAlertController(title: "Are you sure you want to Delete this chat?", message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Delete", style:.default , handler: { (alert: UIAlertAction) -> Void in
            if let chatRoom = self.room {
                self.deleteChat(room: chatRoom)
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style:.cancel , handler: {
            (alert: UIAlertAction) -> Void in
        })
        deleteChatConfirmAlertView.addAction(deleteAction)
        deleteChatConfirmAlertView.addAction(cancelAction)
        let alertActions = deleteChatConfirmAlertView.actions
        for action in alertActions {
            if action.title == "Delete"{
                let logoutColor = UIColor.red
                action.setValue(logoutColor, forKey: "titleTextColor")
            }
        }
        deleteChatConfirmAlertView.view.tintColor = UIColor.organizationalColor()
        if let popoverController = deleteChatConfirmAlertView.popoverPresentationController {
            popoverController.sourceView = self.tableView
            popoverController.sourceRect = CGRect(x: self.tableView.frame.midX-self.tableView.frame.midX/2, y: self.tableView.frame.midX-self.tableView.frame.midX/2, width: self.tableView.frame.midX, height: self.tableView.frame.midY)
            popoverController.permittedArrowDirections = UIPopoverArrowDirection.init(rawValue: 0)
        }
        present(deleteChatConfirmAlertView, animated: true, completion: nil)
    }
    
    func deleteChat(room: IGRoom) {
        self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.hud.mode = .indeterminate
        IGChatDeleteRequest.Generator.generate(room: room).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let deleteChat as IGPChatDeleteResponse:
                    IGChatDeleteRequest.Handler.interpret(response: deleteChat)
                    if self.navigationController is IGNavigationController {
                        _ = self.navigationController?.popToRootViewController(animated: true)
                    }
                default:
                    break
                }
                self.hud.hide(animated: true)
            }
        }).error({ (errorCode , waitTime) in
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
                DispatchQueue.main.async {
                    self.hud.hide(animated: true)
                }
                break
            }
            
        }).send()
    }
    
    func showClearHistoryActionSheet() {
        let clearChatConfirmAlertView = UIAlertController(title: "Are you sure you want to clear chat history?", message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Clear", style:.default , handler: {
            (alert: UIAlertAction) -> Void in
            if let chatRoom = self.room {
                self.clearChatMessageHistory(room: chatRoom)
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style:.cancel , handler: {
            (alert: UIAlertAction) -> Void in
        })
        clearChatConfirmAlertView.addAction(deleteAction)
        clearChatConfirmAlertView.addAction(cancelAction)
        let alertActions = clearChatConfirmAlertView.actions
        for action in alertActions {
            if action.title == "Clear"{
                let logoutColor = UIColor.red
                action.setValue(logoutColor, forKey: "titleTextColor")
            }
        }
        clearChatConfirmAlertView.view.tintColor = UIColor.organizationalColor()
        if let popoverController = clearChatConfirmAlertView.popoverPresentationController {
            popoverController.sourceView = self.tableView
            popoverController.sourceRect = CGRect(x: self.tableView.frame.midX-self.tableView.frame.midX/2, y: self.tableView.frame.midX-self.tableView.frame.midX/2, width: self.tableView.frame.midX, height: self.tableView.frame.midY)
            popoverController.permittedArrowDirections = UIPopoverArrowDirection.init(rawValue: 0)
        }
        present(clearChatConfirmAlertView, animated: true, completion: nil)
    }
    
    func clearChatMessageHistory(room: IGRoom) {
        self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.hud.mode = .indeterminate
        IGChatClearMessageRequest.Generator.generate(room: room).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let clearChatMessages as IGPChatClearMessageResponse:
                    IGChatClearMessageRequest.Handler.interpret(response: clearChatMessages)
                    if self.navigationController is IGNavigationController {
                        self.navigationController?.popViewController(animated: true)
                    }
                default:
                    break
                }
                self.hud.hide(animated: true)
            }
        }).error({ (errorCode , waitTime) in
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
                DispatchQueue.main.async {
                    self.hud.hide(animated: true)
                }
                break
            }
            
        }).send()
    }



    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! IGChooseMemberFromContactsToCreateGroupViewController
        destination.mode = "Convert Chat To Group"
        destination.roomID = previousRoomId
    }

}
