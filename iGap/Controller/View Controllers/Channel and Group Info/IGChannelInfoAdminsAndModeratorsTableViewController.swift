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
import ProtocolBuffers
import RealmSwift
import MBProgressHUD
import IGProtoBuff


class IGChannelInfoAdminsAndModeratorsTableViewController: UITableViewController , UIGestureRecognizerDelegate{

    
    @IBOutlet weak var adminsCell: UITableViewCell!
    @IBOutlet weak var channelAdminIndicator: UIActivityIndicatorView!
    @IBOutlet weak var channelModeratorIndicator: UIActivityIndicatorView!
    @IBOutlet weak var moderatorsCell: UITableViewCell!
    @IBOutlet weak var countOfModeratorLabel: UILabel!
    @IBOutlet weak var countOfAdmins: UILabel!
    var room : IGRoom?
    var hud = MBProgressHUD()
    var adminMember = [IGChannelMember]()
    var moderatorMember = [IGChannelMember]()
    var index : Int!
    var myRole : IGChannelMember.IGRole!
    override func viewDidLoad() {
        super.viewDidLoad()
        myRole = room?.channelRoom?.role
        if myRole == .admin {
            adminsCell.isHidden = true
        }
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: "Done", title: "Admins and Moderators")
        navigationItem.navigationController = self.navigationController as! IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        adminMember.removeAll()
        moderatorMember.removeAll()
        fetchAdminChannelMemberFromServer()
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
        if indexPath.row == 0 {
            index = 0
        }
        if indexPath.row == 1 {
            index = 1
        }
        self.tableView.isUserInteractionEnabled = false
        self.performSegue(withIdentifier: "showAdminsOrModeratorDetailTableview", sender: self)
            
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 && indexPath.row == 1 && moderatorsCell.isHidden == true {
            return 0.0
        }
        if indexPath.section == 0 && indexPath.row == 0 && adminsCell.isHidden == true {
            return 0.0
        }
        return 44.0
    }
    
    func fetchAdminChannelMemberFromServer() {
        channelModeratorIndicator.startAnimating()
        channelAdminIndicator.startAnimating()
        IGChannelGetMemberListRequest.Generator.generate(room: room!, filterRole: .all).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let getChannelMemberList as IGPChannelGetMemberListResponse:
                    let igpMembers = IGChannelGetMemberListRequest.Handler.interpret(response: getChannelMemberList, roomId: (self.room?.id)!)
                    for member in igpMembers {
                        let igmember = IGChannelMember(igpMember: member, roomId: (self.room?.id)!)
                        if member.igpRole == .admin {
                            self.adminMember.append(igmember)
                        }
                        if member.igpRole == .moderator {
                           self.moderatorMember.append(igmember)
                        }
                    }
                    print(self.adminMember.count)
                    self.countOfAdmins.text = "\(self.adminMember.count)"
                    self.countOfModeratorLabel.text = "\(self.moderatorMember.count)"
                    self.channelModeratorIndicator.stopAnimating()
                    self.channelAdminIndicator.stopAnimating()
                    self.channelAdminIndicator.hidesWhenStopped = true
                    self.channelModeratorIndicator.hidesWhenStopped = true
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
                    self.channelModeratorIndicator.stopAnimating()
                    self.channelAdminIndicator.stopAnimating()
                    self.channelAdminIndicator.hidesWhenStopped = true
                    self.channelModeratorIndicator.hidesWhenStopped = true
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
        if segue.identifier == "showAdminsOrModeratorDetailTableview" {
            let destination = segue.destination as! IGChannelInfoAdminsListTableViewController
            destination.room = room
            switch index {
            case 0:
                destination.mode = "Admin"
                destination.allMembers = adminMember
                break
            case 1 :
                destination.mode = "Moderator"
                destination.allMembers = moderatorMember
                break
            default:
                break
            }
        }
    }
    

}
