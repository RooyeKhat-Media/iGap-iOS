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

class IGGroupInfoMemberListTableViewController: UITableViewController , UIGestureRecognizerDelegate {

    var allMember = [IGGroupMember]()
    var room : IGRoom?
    var hud = MBProgressHUD()
    var filterRole : IGRoomFilterRole = .all
    var members : Results<IGGroupMember>!
    var notificationToken: NotificationToken?
    var myRole : IGGroupMember.IGRole?
    override func viewDidLoad() {
        super.viewDidLoad()
        myRole = room?.groupRoom?.role
        //fetchGroupMemberFromServer()
        let predicate = NSPredicate(format: "roomID = %lld", (room?.id)!)
         members =  try! Realm().objects(IGGroupMember.self).filter(predicate)
        self.notificationToken = members.addNotificationBlock { (changes: RealmCollectionChange) in
            switch changes {
            case .initial:
                self.tableView.reloadData()
                break
            case .update(_, let deletions, let insertions, let modifications):
                print("updating channels VC")
                // Query messages have changed, so apply them to the TableView
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) }, with: .none)
                self.tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) }, with: .none)
                self.tableView.reloadRows(at: modifications.map { IndexPath(row: $0, section: 0) }, with: .none)
                self.tableView.endUpdates()
                break
            case .error(let err):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(err)")
                break
            }
        }
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: "Add", title: "Members")
        navigationItem.navigationController = self.navigationController as! IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        navigationItem.rightViewContainer?.addAction {
            self.performSegue(withIdentifier: "showContactToAddMember", sender: self)
        }
    }

    override func viewWillAppear(_ animated: Bool) {

        fetchGroupMemberFromServer()

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return members.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let memberCell = tableView.dequeueReusableCell(withIdentifier: "GroupMemberCell", for: indexPath) as! IGGroupInfoMemberListTableViewCell
        memberCell.setUser(members[indexPath.row])
        
        return memberCell
        
    }
   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    }

    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        let kickText = "Kick"
        return kickText
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if tableView.isEditing == true {
            if let selectedMemberId = members[indexPath.row].user?.id {
                self.kickMember(memberUserId: selectedMemberId)
            }
        }
    }
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        var defualtEditingStyle : UITableViewCellEditingStyle = .none
            if room?.groupRoom?.type == .privateRoom {
                if myRole == .admin || myRole == .moderator || myRole == .owner {
                    defualtEditingStyle =  .delete
                } else {
                    defualtEditingStyle =  .none
                }
            } else if room?.groupRoom?.type == .publicRoom {
                if myRole == .admin || myRole == .owner {
                    defualtEditingStyle =  .delete
                } else {
                    defualtEditingStyle =  .none
                }

            }
            
        
        return defualtEditingStyle
    }
    
    func kickMember(memberUserId: Int64) {
        IGGroupKickMemberRequest.Generator.generate(memberId: memberUserId, roomId: (room?.id)!).success({
            (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let kickMemberResponse as IGPGroupKickMemberResponse:
                    IGGroupKickMemberRequest.Handler.interpret(response: kickMemberResponse)
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
    
    
    func fetchGroupMemberFromServer() {
        self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.hud.mode = .indeterminate
        IGGroupGetMemberListRequest.Generator.generate(room: room!, offset: Int32(self.allMember.count), limit: 40, filterRole: filterRole).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let getGroupMemberList as IGPGroupGetMemberListResponse:
                    let igpMembers =  IGGroupGetMemberListRequest.Handler.interpret(response: getGroupMemberList, roomId: (self.room?.id)!)
                        self.hud.hide(animated: true)
                    for member in igpMembers {
                        let igmember = IGGroupMember(igpMember: member, roomId: (self.room?.id)!)
                        self.allMember.append(igmember)
                    }
                    self.hud.hide(animated: true)
                    //self.tableView.reloadData()
                    
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
  
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showContactToAddMember" {
            let destinationTv = segue.destination as! IGChooseMemberFromContactsToCreateGroupViewController
            destinationTv.mode = "Members"
            destinationTv.room = room
        }
        if segue.identifier == "GoToChangeGroupPublicLink" {
            let destination = segue.destination as! IGGroupInfoEditTypeTableViewController
            destination.room = room
        }
    }
}
