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
import IGProtoBuff
import ProtocolBuffers
import RealmSwift
import RxRealm
import RxSwift
import RxCocoa

class IGChannelsTableViewController: UITableViewController {
    
    var selectedRoomForSegue : IGRoom?
    var cellIdentifer = IGChatRoomListTableViewCell.cellReuseIdentifier()
    var rooms: Results<IGRoom>? = nil
    var notificationToken: NotificationToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let predicate = NSPredicate(format: "typeRaw = %d AND isParticipant = 1", IGRoom.IGType.channel.rawValue)
        rooms = try! Realm().objects(IGRoom.self).filter(predicate).sorted(byKeyPath: "sortimgTimestamp", ascending: false)
        
        
        self.tableView.register(IGChatRoomListTableViewCell.nib(), forCellReuseIdentifier: IGChatRoomListTableViewCell.cellReuseIdentifier())
        
        self.tableView.backgroundColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
        self.view.backgroundColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
        self.tableView.tableHeaderView?.backgroundColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
        
        self.notificationToken = rooms!.addNotificationBlock { (changes: RealmCollectionChange) in
            switch changes {
            case .initial:
                self.tableView.reloadData()
                self.setTabbarBadge()
                break
            case .update(_, let deletions, let insertions, let modifications):
                print("updating channels VC")
                // Query messages have changed, so apply them to the TableView
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) }, with: .none)
                self.tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) }, with: .none)
                self.tableView.reloadRows(at: modifications.map { IndexPath(row: $0, section: 0) }, with: .none)
                self.tableView.endUpdates()
                self.setTabbarBadge()
                break
            case .error(let err):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(err)")
                break
            }
        }
        if IGAppManager.sharedManager.isUserLoggiedIn() {
            self.fetchRoomList()
        } else {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(self.fetchRoomList),
                                                   name: NSNotification.Name(rawValue: kIGUserLoggedInNotificationName),
                                                   object: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.setTabbarHidden(false, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: Room List actions
    @objc private func fetchRoomList() {
        IGClientGetRoomListRequest.Generator.generate().success { (responseProtoMessage) in
            DispatchQueue.main.async {
                switch responseProtoMessage {
                case let response as IGPClientGetRoomListResponse:
                    IGClientGetRoomListRequest.Handler.interpret(response: response)
                default:
                    break;
                }
            }
            }.error({ (errorCode, waitTime) in
                
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
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRoomForSegue = rooms![indexPath.row]
        performSegue(withIdentifier: "showRoomMessages", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showRoomMessages") {
            let destination = segue.destination as! IGMessageViewController
            destination.room = selectedRoomForSegue
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 78.0
    }
    
    //MARK: - Tabbar badge
    func setTabbarBadge() {
//        var unreadCount = 0
//        rooms.forEach{unreadCount += Int($0.unreadCount)}
//        if unreadCount == 0 {
//            self.tabBarController?.tabBar.items?[3].badgeValue = nil
//        } else {
//            self.tabBarController?.tabBar.items?[3].badgeValue = "\(unreadCount)"
//        }
    }
}
