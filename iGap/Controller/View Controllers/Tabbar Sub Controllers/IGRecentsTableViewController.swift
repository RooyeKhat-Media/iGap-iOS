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
import RxRealm
import RxSwift
import RxCocoa
import IGProtoBuff
import MGSwipeTableCell
import MBProgressHUD

class IGRecentsTableViewController: UITableViewController {
    
    var alreadySavedContacts: Bool = false
    var selectedRoomForSegue : IGRoom?
    var cellIdentifer = IGChatRoomListTableViewCell.cellReuseIdentifier()
    var rooms: Results<IGRoom>? = nil
    var notificationToken: NotificationToken?
    var hud = MBProgressHUD()
    var connectionStatus: IGAppManager.ConnectionStatus?
    var isLoadingMoreRooms: Bool = false
    var numberOfRoomFetchedInLastRequest: Int = -1
    
    private let disposeBag = DisposeBag()
    
    private func updateNavigationBarBasedOnNetworkStatus(_ status: IGAppManager.ConnectionStatus) {
        let navigationItem = self.tabBarController?.navigationItem as! IGNavigationItem
        switch status {
        case .waitingForNetwork:
            navigationItem.setNavigationItemForWaitingForNetwork()
            connectionStatus = .waitingForNetwork
            break
        case .connecting:
            navigationItem.setNavigationItemForConnecting()
            connectionStatus = .connecting
            break
        case .connected:
            connectionStatus = .connected
            self.setDefaultNavigationItem()
            break
        }
    }
    
    private func setDefaultNavigationItem() {
        let navigationItem = self.tabBarController?.navigationItem as! IGNavigationItem
        navigationItem.setChatListsNavigationItems()
        navigationItem.rightViewContainer?.addAction {
            
           // self.performSegue(withIdentifier: "createANewChat", sender: self)
            
            let alertController = UIAlertController(title: "New Message", message: "Which type of conversation would you like to initiate?", preferredStyle: .actionSheet)
            let myCloud = UIAlertAction(title: "My Cloud", style: .default, handler: { (action) in
                if let userId = IGAppManager.sharedManager.userID() {
                    let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                    hud.mode = .indeterminate
                    IGChatGetRoomRequest.Generator.generate(peerId: userId).success({ (protoResponse) in
                        DispatchQueue.main.async {
                            switch protoResponse {
                            case let chatGetRoomResponse as IGPChatGetRoomResponse:
                                let roomId = IGChatGetRoomRequest.Handler.interpret(response: chatGetRoomResponse)
                                //segue to created chat
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kIGNotificationNameDidCreateARoom),
                                                                object: nil,
                                                                userInfo: ["room": roomId])
                                hud.hide(animated: true)
                                break
                            default:
                                break
                            }
                        }
                    }).error({ (errorCode, waitTime) in
                        DispatchQueue.main.async {
                            hud.hide(animated: true)
                            let alertC = UIAlertController(title: "Error", message: "An error occured trying to create a conversation", preferredStyle: .alert)
                            
                            let cancel = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alertC.addAction(cancel)
                            self.present(alertC, animated: true, completion: nil)
                        }
                    }).send()
                }
            })
            let newChat = UIAlertAction(title: "New Conversation", style: .default, handler: { (action) in
                self.performSegue(withIdentifier: "createANewChat", sender: self)
            })
            let newGroup = UIAlertAction(title: "New Group", style: .default, handler: { (action) in
                self.performSegue(withIdentifier: "createANewGroup", sender: self)
            })
            let newChannel = UIAlertAction(title: "New Channel", style: .default, handler: { (action) in
                self.performSegue(withIdentifier: "createANewChannel", sender: self)
            })
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                
            })
            
            alertController.addAction(myCloud)
            alertController.addAction(newChat)
            alertController.addAction(newGroup)
            alertController.addAction(newChannel)
            alertController.addAction(cancel)
            
            self.present(alertController, animated: true, completion: nil)
            
        }
        navigationItem.leftViewContainer?.addAction {
            self.performSegue(withIdentifier: "showSettings", sender: self)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.rooms = try! Realm().objects(IGRoom.self).filter("isParticipant = 1").sorted(byKeyPath: "sortimgTimestamp", ascending: false)
        
        self.tableView.register(IGChatRoomListTableViewCell.nib(), forCellReuseIdentifier: IGChatRoomListTableViewCell.cellReuseIdentifier())
        
        self.tableView.backgroundColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
        self.view.backgroundColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
        self.tableView.tableHeaderView?.backgroundColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
        
        
        setDefaultNavigationItem()
        IGAppManager.sharedManager.connectionStatus.asObservable().subscribe(onNext: { (connectionStatus) in
            DispatchQueue.main.async {
                self.updateNavigationBarBasedOnNetworkStatus(connectionStatus)
            }
        }, onError: { (error) in
            
        }, onCompleted: { 
            
        }, onDisposed: {
            
        }).addDisposableTo(disposeBag)
        
        self.addRoomChangeNotificationBlock()
        
        if IGAppManager.sharedManager.isUserLoggiedIn() {
            self.fetchRoomList()
            self.saveAndSendContacts()
            self.requestToGetUserPrivacy()
        } else {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(self.userDidLogin),
                                                   name: NSNotification.Name(rawValue: kIGUserLoggedInNotificationName),
                                                   object: nil)
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(segueToChatNotificationReceived(_:)),
                                               name: NSNotification.Name(rawValue: kIGNotificationNameDidCreateARoom),
                                               object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.isUserInteractionEnabled = true
        //self.addRoomChangeNotificationBlock()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.isUserInteractionEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.isUserInteractionEnabled = true
        //self.notificationToken?.stop()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: Room List actions
    @objc private func userDidLogin() {
        self.addRoomChangeNotificationBlock()
        self.fetchRoomList()
        self.saveAndSendContacts()
        self.requestToGetUserPrivacy()
    }
    
    private func addRoomChangeNotificationBlock() {
        self.notificationToken?.stop()
        self.notificationToken = rooms!.addNotificationBlock { (changes: RealmCollectionChange) in
            switch changes {
            case .initial:
                self.tableView.reloadData()
                self.setTabbarBadge()
                break
            case .update(_, let deletions, let insertions, let modifications):
                // Query messages have changed, so apply them to the TableView
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) }, with: .none)
                self.tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) }, with: .none)
                self.tableView.reloadRows(at: modifications.map { IndexPath(row: $0, section: 0) }, with: .none)
                self.tableView.endUpdates()
                //                self.tableView.reloadData()
                self.setTabbarBadge()
                break
            case .error(let err):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(err)")
                break
            }
        }
    }
    
    private func sendClientCondition(clientCondition: IGClientCondition) {
        IGClientConditionRequest.Generator.generate(clientCondition: clientCondition).success { (responseProto) in
            
            }.error { (errorCode, waitTime) in
                
            }.send()
    }
    
    @objc private func fetchRoomList() {
        let clientCondition = IGClientCondition()
        isLoadingMoreRooms = true
        IGClientGetRoomListRequest.Generator.generate(offset: 0, limit: 40).success { (responseProtoMessage) in
            self.isLoadingMoreRooms = false
                DispatchQueue.main.async {
                    switch responseProtoMessage {
                    case let response as IGPClientGetRoomListResponse:
                        self.sendClientCondition(clientCondition: clientCondition)
                        self.numberOfRoomFetchedInLastRequest = IGClientGetRoomListRequest.Handler.interpret(response: response)
                    default:
                        break;
                    }
                }
            }.error({ (errorCode, waitTime) in
                
            }).send()
    }
    
    @objc private func saveAndSendContacts() {
        if !alreadySavedContacts {
            let contactManager = IGContactManager.sharedManager
            contactManager.savePhoneContactsToDatabase()
            contactManager.sendContactsToServer()
            alreadySavedContacts = true
        }
    }
    @objc private func requestToGetUserPrivacy() {
        //get user avatar privacy
        IGUserPrivacyGetRuleRequest.Generator.generate(privacyType: .avatar).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let userPrivacyGetRuleResponse as IGPUserPrivacyGetRuleResponse:
                    IGUserPrivacyGetRuleRequest.Handler.interpret(response: userPrivacyGetRuleResponse , privacyType: .avatar)
                default:
                    break
                }
            }
        }).error({ (errorCode, waitTime) in
            
        }).send()
        //get userStatusPrivacy
        IGUserPrivacyGetRuleRequest.Generator.generate(privacyType: .userStatus).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let userPrivacyGetRuleResponse as IGPUserPrivacyGetRuleResponse:
                    IGUserPrivacyGetRuleRequest.Handler.interpret(response: userPrivacyGetRuleResponse, privacyType: .userStatus)
                default:
                    break
                }
            }
        }).error({ (errorCode, waitTime) in
            
        }).send()
        
        //get channelInviteUser Privacy
        IGUserPrivacyGetRuleRequest.Generator.generate(privacyType: .channelInvite).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let userPrivacyGetRuleResponse as IGPUserPrivacyGetRuleResponse:
                    IGUserPrivacyGetRuleRequest.Handler.interpret(response: userPrivacyGetRuleResponse, privacyType: .channelInvite)
                default:
                    break
                }
            }
        }).error({ (errorCode, waitTime) in
            
        }).send()

        //get group Invite user privacy
        IGUserPrivacyGetRuleRequest.Generator.generate(privacyType: .groupInvite).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let userPrivacyGetRuleResponse as IGPUserPrivacyGetRuleResponse:
                    IGUserPrivacyGetRuleRequest.Handler.interpret(response: userPrivacyGetRuleResponse , privacyType: .groupInvite)
                default:
                    break
                }
            }
        }).error({ (errorCode, waitTime) in
            
        }).send()

        
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms!.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: IGChatRoomListTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellIdentifer) as! IGChatRoomListTableViewCell
        cell.setRoom(room: rooms![indexPath.row])
        
        
        
        //configure left buttons
//        cell.leftButtons = [MGSwipeButton(title: "Mark as read", backgroundColor: UIColor(red: 63.0/255.0, green: 110.0/255.0, blue: 180.0/255.0, alpha: 1) , callback: {
//            (sender: MGSwipeTableCell!) -> Bool in
//            print("Convenience callback for swipe buttons!")
//            
//            let room = self.rooms[indexPath.row]
//            let alertC = UIAlertController(title: "Mark as read", message: "Are you sure you want to mark all the messages in \(room.title!) as read?", preferredStyle: .alert)
//            
//            
//            let yes = UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
//                
//            })
//            let no = UIAlertAction(title: "No", style: .cancel, handler: { (action) in
//                
//            })
//            
//            alertC.addAction(yes)
//            alertC.addAction(no)
//            
//            self.present(alertC, animated: true, completion: {
//                
//            })
//            
//            return true
//        })]
//        cell.leftSwipeSettings.transition = MGSwipeTransition.border
        
        //configure right buttons
        cell.rightButtons =
            [MGSwipeButton(title: "Delete", backgroundColor: UIColor(red: 252.0/255.0, green: 23.0/255.0, blue: 22.0/255.0, alpha: 1), callback: { (sender: MGSwipeTableCell!) -> Bool in
                let room = cell.room!
                //let room = self.rooms![indexPath.row]
                let title = room.title != nil ? room.title! : "Delete"
                let alertC = UIAlertController(title: title, message: "What do you want to do?", preferredStyle: .actionSheet)
                let clear = UIAlertAction(title: "Clear History", style: .default, handler: { (action) in
                    switch room.type{
                    case .chat:
                        if self.connectionStatus == .waitingForNetwork || self.connectionStatus == .connecting {
                            let alert = UIAlertController(title: "Error", message: "No Network Connection", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alert.addAction(okAction)
                            self.present(alert, animated: true, completion: nil)

                        } else {
                        self.clearChatMessageHistory(room: room)
                        }
                    case .group:
                        if self.connectionStatus == .waitingForNetwork || self.connectionStatus == .connecting {
                            let alert = UIAlertController(title: "Error", message: "No Network Connection", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alert.addAction(okAction)
                            self.present(alert, animated: true, completion: nil)

                        } else {
                        self.clearGroupMessageHistory(room: room)
                        }
                    default:
                        break
                    }
                    
                })
                
                let remove = UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
                    switch room.type {
                    case .chat:
                        if self.connectionStatus == .waitingForNetwork || self.connectionStatus == .connecting {
                            let alert = UIAlertController(title: "Error", message: "No Network Connection", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alert.addAction(okAction)
                            self.present(alert, animated: true, completion: nil)
                            
                        } else {
                            self.deleteChat(room: room)
                        }
                        break
                    case .group:
                        if self.connectionStatus == .waitingForNetwork || self.connectionStatus == .connecting {
                            let alert = UIAlertController(title: "Error", message: "No Network Connection", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alert.addAction(okAction)
                            self.present(alert, animated: true, completion: nil)
                            
                        } else {
                            self.deleteGroup(room: room)
                        }
                        break
                    case .channel:
                        if self.connectionStatus == .waitingForNetwork || self.connectionStatus == .connecting {
                            let alert = UIAlertController(title: "Error", message: "No Network Connection", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alert.addAction(okAction)
                            self.present(alert, animated: true, completion: nil)
                        } else {
                            self.deleteChannel(room: room)
                        }
                        break
                    default:
                        break
                    }
                })
                
                
                
                let leave = UIAlertAction(title: "Leave", style: .destructive, handler: { (action) in
                    switch room.type {
                    case .chat:
                        break
                    case .group:
                        if self.connectionStatus == .waitingForNetwork || self.connectionStatus == .connecting {
                            let alert = UIAlertController(title: "Error", message: "No Network Connection", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alert.addAction(okAction)
                            self.present(alert, animated: true, completion: nil)

                            
                        } else {
                        self.leaveGroup(room: room)
                        }
                    case .channel:
                        if self.connectionStatus == .waitingForNetwork || self.connectionStatus == .connecting {
                            let alert = UIAlertController(title: "Error", message: "No Network Connection", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alert.addAction(okAction)
                            self.present(alert, animated: true, completion: nil)

                            
                        } else {
                        self.leaveChannel(room: room)
                        }
                    }
                })
                
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                    
                })
                
                
                if room.type == .chat || room.type == .group {
                    alertC.addAction(clear)
                }
                if room.chatRoom != nil {
                    alertC.addAction(remove)
                } else {
                    if let groupRoom = room.groupRoom {
                        if groupRoom.role == .owner {
                            alertC.addAction(leave)
                            alertC.addAction(remove)
                        } else{
                            alertC.addAction(leave)
                        }
                    } else if let channel = room.channelRoom {
                        if channel.role == .owner {
                            alertC.addAction(remove)
                            alertC.addAction(leave)
                        } else{
                            alertC.addAction(leave)
                        }
                    }
                }
                
                
                alertC.addAction(cancel)
                
                self.present(alertC, animated: true, completion: {
                    
                })
                
                return true
            })]
        cell.rightSwipeSettings.transition = MGSwipeTransition.border
        
        
        cell.leftExpansion.buttonIndex = 0
        cell.leftExpansion.fillOnTrigger = true
        cell.leftExpansion.threshold = 2.0
        
        cell.rightExpansion.buttonIndex = 0
        cell.rightExpansion.fillOnTrigger = true
        cell.rightExpansion.threshold = 1.5
        
        
        cell.separatorInset = UIEdgeInsets(top: 0, left: 82.0, bottom: 0, right: 0)
        cell.layoutMargins = UIEdgeInsets.zero
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRoomForSegue = rooms![indexPath.row]
        self.tableView.isUserInteractionEnabled = false
        performSegue(withIdentifier: "showRoomMessages", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showRoomMessages") {
            let destination = segue.destination as! IGMessageViewController
            destination.room = selectedRoomForSegue
        }
        if segue.identifier == "createANewGroup" {
            let destination = segue.destination as! IGNavigationController
             let chooseContactTv =  destination.topViewController as! IGChooseMemberFromContactsToCreateGroupViewController
                chooseContactTv.mode = "CreateGroup"            
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 78.0
    }
    
    
//    //MARK: - editing
//    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }
//    
//    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
//        //return .delete
//        let more = UITableViewRowAction(style: .normal, title: "More") { action, index in
//            print("more button tapped")
//        }
//        more.backgroundColor = UIColor.lightGray
//        
//        let favorite = UITableViewRowAction(style: .normal, title: "Favorite") { action, index in
//            print("favorite button tapped")
//        }
//        favorite.backgroundColor = UIColor.orange
//        
//        let share = UITableViewRowAction(style: .normal, title: "Share") { action, index in
//            print("share button tapped")
//        }
//        share.backgroundColor = UIColor.blue
//        
//        return [share, favorite, more]
//    }
//    
//    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//        // you need to implement this method too or you can't swipe to display the actions
//    }

    //MARK: - Tabbar badge
    func setTabbarBadge() {
        var unreadCount = 0
        
        unreadCount = rooms!.sum(ofProperty: "unreadCount")
        if unreadCount == 0 {
            self.tabBarController?.tabBar.items?[0].badgeValue = nil
        } else {
            self.tabBarController?.tabBar.items?[0].badgeValue = "\(unreadCount)"
        }
    }
    
    
    
    func segueToChatNotificationReceived(_ aNotification: Notification) {
        if let roomId = aNotification.userInfo?["room"] as? Int64 {
            let predicate = NSPredicate(format: "id = %d", roomId)
            if let room = rooms!.filter(predicate).first {
                selectedRoomForSegue = room
                performSegue(withIdentifier: "showRoomMessages", sender: self)
            } else {
                self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                self.hud.mode = .indeterminate
                IGClientGetRoomRequest.Generator.generate(roomId: roomId).success({ (protoResponse) in
                        DispatchQueue.main.async {
                            switch protoResponse {
                            case let clientGetRoomResponse as IGPClientGetRoomResponse:
                                IGClientGetRoomRequest.Handler.interpret(response: clientGetRoomResponse)
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kIGNotificationNameDidCreateARoom),object: nil,userInfo: ["room": roomId])
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
        } else {
            print("rommID not int64")
        }
    }
}

//MARK:- Room Clear, Delete, Leave
extension IGRecentsTableViewController {
    func clearChatMessageHistory(room: IGRoom) {
        self.hud = MBProgressHUD.showAdded(to: self.view.superview!, animated: true)
        self.hud.mode = .indeterminate
        IGChatClearMessageRequest.Generator.generate(room: room).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let clearChatMessages as IGPChatClearMessageResponse:
                    IGChatClearMessageRequest.Handler.interpret(response: clearChatMessages)
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
    
    func clearGroupMessageHistory(room: IGRoom) {
        self.hud = MBProgressHUD.showAdded(to: self.view.superview!, animated: true)
        self.hud.mode = .indeterminate
        IGGroupClearMessageRequest.Generator.generate(group: room).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let deleteGroupMessageHistory as IGPGroupClearMessageResponse:
                    IGGroupClearMessageRequest.Handler.interpret(response: deleteGroupMessageHistory)
                default:
                    break
                }
                self.hud.hide(animated: true)
            }
        }).error({ (errorCode , waitTime) in
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
    
    func deleteChat(room: IGRoom) {
        self.hud = MBProgressHUD.showAdded(to: self.view.superview!, animated: true)
        self.hud.mode = .indeterminate
        IGChatDeleteRequest.Generator.generate(room: room).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let deleteChat as IGPChatDeleteResponse:
                    IGChatDeleteRequest.Handler.interpret(response: deleteChat)
                default:
                    break
                }
                self.hud.hide(animated: true)
            }
        }).error({ (errorCode , waitTime) in
            DispatchQueue.main.async {
                switch errorCode {
                case .timeout:
                    let alert = UIAlertController(title: "Timeout", message: "Please try again later", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.hud.hide(animated: true)
                    self.present(alert, animated: true, completion: nil)
                default:
                    break
                }
                self.hud.hide(animated: true)
            }
        
        }).send()
    }
    
    func deleteGroup(room: IGRoom) {
        self.hud = MBProgressHUD.showAdded(to: self.view.superview!, animated: true)
        self.hud.mode = .indeterminate
        IGGroupDeleteRequest.Generator.generate(group: room).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let deleteGroup as IGPGroupDeleteResponse:
                    IGGroupDeleteRequest.Handler.interpret(response: deleteGroup)
                default:
                    break
                }
                self.hud.hide(animated: true)
            }
        }).error({ (errorCode , waitTime) in
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
    
    func leaveGroup(room: IGRoom) {
        self.hud = MBProgressHUD.showAdded(to: self.view.superview!, animated: true)
        self.hud.mode = .indeterminate
        IGGroupLeftRequest.Generator.generate(room: room).success{ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let response as IGPGroupLeftResponse:
                    IGGroupLeftRequest.Handler.interpret(response: response)
                default:
                    break
                }
                self.hud.hide(animated: true)
            }
        }.error { (errorCode, waitTime) in
            DispatchQueue.main.async {
                switch errorCode {
                case .timeout:
                    let alert = UIAlertController(title: "Timeout", message: "Please try again later", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                default:
                    let alert = UIAlertController(title: "Error", message: "There was an error leaving this group.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                }
                self.hud.hide(animated: true)
            }
        }.send()
    }
    
    func leaveChannel(room: IGRoom) {
        self.hud = MBProgressHUD.showAdded(to: self.view.superview!, animated: true)
        self.hud.mode = .indeterminate
        IGChannelLeftRequest.Generator.generate(room: room).success { (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let response as IGPChannelLeftResponse:
                    IGChannelLeftRequest.Handler.interpret(response: response)
                default:
                    break
                }
                self.hud.hide(animated: true)
            }
        }.error { (errorCode, waitTime) in
            DispatchQueue.main.async {
                switch errorCode {
                case .timeout:
                    let alert = UIAlertController(title: "Timeout", message: "Please try again later", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                default:
                    let alert = UIAlertController(title: "Error", message: "There was an error leaving this channel.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                }
                self.hud.hide(animated: true)
            }
        }.send()
    }
    
    func deleteChannel(room: IGRoom) {
        self.hud = MBProgressHUD.showAdded(to: self.view.superview!, animated: true)
        self.hud.mode = .indeterminate
        IGChannelDeleteRequest.Generator.generate(roomID: room.id).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let deleteChannel as IGPChannelDeleteResponse:
                    IGChannelDeleteRequest.Handler.interpret(response: deleteChannel)
                default:
                    break
                }
                self.hud.hide(animated: true)
            }
        }).error({ (errorCode , waitTime) in
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
}


extension IGRecentsTableViewController {
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let remaining = scrollView.contentSize.height - (scrollView.frame.size.height + scrollView.contentOffset.y)
        if remaining < 100 {
            self.loadMoreRooms()
        }
    }
}



extension IGRecentsTableViewController {
    func loadMoreRooms() {
        if !isLoadingMoreRooms && numberOfRoomFetchedInLastRequest % 40 == 0 {
            isLoadingMoreRooms = true
            let offset = rooms!.count
            IGClientGetRoomListRequest.Generator.generate(offset: Int32(offset), limit: 40).success { (responseProtoMessage) in
                DispatchQueue.main.async {
                    self.isLoadingMoreRooms = false
                    switch responseProtoMessage {
                    case let response as IGPClientGetRoomListResponse:
                        self.numberOfRoomFetchedInLastRequest = IGClientGetRoomListRequest.Handler.interpret(response: response)
                    default:
                        break;
                    }
                }
            }.error({ (errorCode, waitTime) in
                    
            }).send()
        }
    }
}
