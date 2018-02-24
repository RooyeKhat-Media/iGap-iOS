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
import MGSwipeTableCell

class IGChannelInfoAdminsListTableViewController: UITableViewController , UIGestureRecognizerDelegate {

    var room : IGRoom?
    var mode : String?
    var allMembers = [IGChannelMember]()
    var adminsRole = IGChannelMember.IGRole.admin.rawValue
    var moderatorRole = IGChannelMember.IGRole.moderator.rawValue
    var notificationToken: NotificationToken?
    var members : Results<IGChannelMember>!
    var predicate : NSPredicate!
    var navigationTitle : String?
    var noDataTitle : String?
    var hud = MBProgressHUD()

    override func viewDidLoad() {
        super.viewDidLoad()
        if mode == "Admin" {
            navigationTitle = "Admins"
            noDataTitle = "This channel has no admin."
            predicate = NSPredicate(format: "roleRaw = %d AND roomID = %lld", adminsRole , (room?.id)!)
            members =  try! Realm().objects(IGChannelMember.self).filter(predicate!)
        }
        if mode == "Moderator" {
            navigationTitle = "Moderators"
            noDataTitle = "This channel has no moderator."
            predicate = NSPredicate(format: "roleRaw = %d AND roomID = %lld", moderatorRole , (room?.id)!)
            members =  try! Realm().objects(IGChannelMember.self).filter(predicate!)
        }
        self.notificationToken = members.observe { (changes: RealmCollectionChange) in
            switch changes {
            case .initial:
                self.tableView.reloadData()
                break
            case .update(_, let _, let _, let _):
                print("updating admins tableV")
                // Query messages have changed, so apply them to the TableView
                self.tableView.reloadData()
                break
            case .error(let err):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(err)")
                break
            }
        }
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: "Add", title: navigationTitle)
        navigationItem.navigationController = self.navigationController as! IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self

        navigationItem.rightViewContainer?.addAction {
            self.performSegue(withIdentifier: "showContactToAdminsOrModerators", sender: self)
        }

    }
    override func viewWillAppear(_ animated: Bool) {
//        if mode == "Admin" {
//            navigationTitle = "Admins"
//            noDataTitle = "This channel has no admin."
//            predicate = NSPredicate(format: "roleRaw = %d", adminsRole)
//            members =  try! Realm().objects(IGChannelMember.self).filter(predicate!)
//        }
//        if mode == "Moderator" {
//            navigationTitle = "Moderators"
//            noDataTitle = "This channel has no moderator."
//            predicate = NSPredicate(format: "roleRaw = %d", moderatorRole)
//            members =  try! Realm().objects(IGChannelMember.self).filter(predicate!)
//        }
//        self.notificationToken = members.addNotificationBlock { (changes: RealmCollectionChange) in
//            switch changes {
//            case .initial:
//                self.tableView.reloadData()
//                break
//            case .update(_, let deletions, let insertions, let modifications):
//                print("updating admins tableV")
//                // Query messages have changed, so apply them to the TableView
//                self.tableView.beginUpdates()
//                self.tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) }, with: .none)
//                self.tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) }, with: .none)
//                self.tableView.reloadRows(at: modifications.map { IndexPath(row: $0, section: 0) }, with: .none)
//                self.tableView.endUpdates()
//                break
//            case .error(let err):
//                // An error occurred while opening the Realm file on the background worker thread
//                fatalError("\(err)")
//                break
//            }
//        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if members.count > 0 {
            self.tableView.backgroundView = nil
            self.tableView.separatorStyle = .singleLine
            return 1
        }
        
        let rect = CGRect(x: 0,y: 0,width: self.tableView.bounds.size.width,height: self.tableView.bounds.size.height)
        let noDataLabel: UILabel = UILabel(frame: rect)
        noDataLabel.text = noDataTitle
        noDataLabel.textColor = UIColor.black
        noDataLabel.textAlignment = NSTextAlignment.center
        self.tableView.backgroundView = noDataLabel
        self.tableView.separatorStyle = .none
        
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return members.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "adminCell", for: indexPath) as! IGChannelInfoAdminsTableViewCell
        cell.setUser(members[indexPath.row])
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        let kickText = "Kick"
        return kickText
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if tableView.isEditing == true {
            print("delete")
            if mode == "Admin" {
                if let adminUserId: Int64 = members[indexPath.row].userID {
                    kickAdmin(adminUserID: adminUserId)
                }
            }
            if mode == "Moderator" {
                if let moderatorUserId: Int64 = members[indexPath.row].userID {
                    kickModerator(moderatorUserId: moderatorUserId)
                }
            }
        }
        
    }
    
    func kickAdmin(adminUserID: Int64) {
        if let channelRoom = room {
            self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            self.hud.mode = .indeterminate
            IGChannelKickAdminRequest.Generator.generate(roomId: channelRoom.id , memberId: adminUserID ).success({ (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let channelKickAdminResponse as IGPChannelKickAdminResponse:
                        IGChannelKickAdminRequest.Handler.interpret( response : channelKickAdminResponse)
                        self.tableView.reloadData()
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
    
    func kickModerator(moderatorUserId: Int64) {
        if let channelRoom = room {
            self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            self.hud.mode = .indeterminate
            IGChannelKickModeratorRequest.Generator.generate(roomID: channelRoom.id, memberID: moderatorUserId).success({ (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let channelKickModeratorResponse as IGPChannelKickModeratorResponse:
                        IGChannelKickModeratorRequest.Handler.interpret( response : channelKickModeratorResponse)
                        self.hud.hide(animated: true)
                        self.tableView.reloadData()

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


    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showContactToAdminsOrModerators" {
            let destination = segue.destination as! IGChooseMemberFromContactToCreateChannelViewController
            destination.mode = mode
            destination.room = room
        }
    }
    

}
