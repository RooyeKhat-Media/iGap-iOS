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

class IGGroupInfoAdminsAndModeratorsListTableViewController: UITableViewController , UIGestureRecognizerDelegate {


    @IBOutlet weak var adminsCell: UITableViewCell!
    @IBOutlet weak var moderatorIndicator: UIActivityIndicatorView!
    @IBOutlet weak var adminsIndicator: UIActivityIndicatorView!
    @IBOutlet weak var groupModeratorsCell: UITableViewCell!
    @IBOutlet weak var groupModeratorsCountLabel: UILabel!
    @IBOutlet weak var groupAdminsCountLabel: UILabel!
    
    var room : IGRoom?
    var hud = MBProgressHUD()
    var adminMember = [IGGroupMember]()
    var moderatorMember = [IGGroupMember]()
    var index : Int!
    var myRole : IGGroupMember.IGRole?
    override func viewDidLoad() {
        super.viewDidLoad()
        myRole = room?.groupRoom?.role
        if myRole == .admin {
            adminsCell.isHidden = true
        }
        
        fetchAdminChannelMemberFromServer()
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: "Done", title: "Admins and Moderators")
        navigationItem.navigationController = self.navigationController as! IGNavigationController
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
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.isUserInteractionEnabled = false
        if indexPath.row == 0 {
            index = 0
        }
        if indexPath.row == 1 {
            index = 1
        }
        self.performSegue(withIdentifier: "showGroupAdminsDetails", sender: self)
        
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 && indexPath.row == 1 && groupModeratorsCell.isHidden == true {
            return 0.0
        }
        if indexPath.section == 0 && indexPath.row == 0 && adminsCell.isHidden == true {
            return 0.0
        }
        return 44.0
    }
    
    func fetchAdminChannelMemberFromServer() {
        moderatorIndicator.startAnimating()
        adminsIndicator.startAnimating()
        IGGroupGetMemberListRequest.Generator.generate(room: room!, offset: Int32(self.adminMember.count + self.moderatorMember.count), limit: 40, filterRole: .all).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let getChannelMemberList as IGPGroupGetMemberListResponse:
                    let igpMembers = IGGroupGetMemberListRequest.Handler.interpret(response: getChannelMemberList, roomId: (self.room?.id)!)
                    for member in igpMembers {
                        let igmember = IGGroupMember(igpMember: member, roomId: (self.room?.id)!)
                        if member.igpRole == .admin {
                            self.adminMember.append(igmember)
                        }
                        if member.igpRole == .moderator {
                            self.moderatorMember.append(igmember)
                        }
                    }
                    print(self.adminMember.count)
                    self.groupAdminsCountLabel.text = "\(self.adminMember.count)"
                    self.groupModeratorsCountLabel.text = "\(self.moderatorMember.count)"
                    self.moderatorIndicator.stopAnimating()
                    self.adminsIndicator.stopAnimating()
                    self.adminsIndicator.hidesWhenStopped = true
                    self.moderatorIndicator.hidesWhenStopped = true
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
                    self.moderatorIndicator.stopAnimating()
                    self.adminsIndicator.stopAnimating()
                    self.adminsIndicator.hidesWhenStopped = true
                    self.moderatorIndicator.hidesWhenStopped = true
                    self.present(alert, animated: true, completion: nil)
                }
            default:
                break
            }
            
        }).send()
        
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showGroupAdminsDetails" {
            let destination = segue.destination as! IGGroupInfoAdminListTableViewController
            destination.room = room
            switch index {
            case 0:
                destination.mode = "Admin"
            case 1 :
                destination.mode = "Moderator"
            default:
                break
            }
        }
    }

}
