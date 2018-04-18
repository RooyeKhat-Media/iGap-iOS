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
import SwiftProtobuf
import RealmSwift

class IGMapNearbyDistanceTableViewController: UITableViewController, UIGestureRecognizerDelegate {
    
    var cellIdentifer = IGMapNearbyDistanceCell.cellReuseIdentifier()
    var nearbyDistanceList: Results<IGRealmMapNearbyDistance>!
    var notificationToken: NotificationToken?
    
    var latitude: Double!
    var longitude: Double!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navigaitonItem = self.navigationItem as! IGNavigationItem
        navigaitonItem.addNavigationViewItems(rightItemText: nil, title: "Nearby Distance")
        navigaitonItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        
        let realm = try! Realm()
        let allNearbyUsers = try! Realm().objects(IGRealmMapNearbyDistance.self)
        if !allNearbyUsers.isEmpty {
            try! realm.write {
                realm.delete(allNearbyUsers)
            }
        }
        
        nearbyDistanceList = try! Realm().objects(IGRealmMapNearbyDistance.self)
        
        self.tableView.register(IGMapNearbyDistanceCell.nib(), forCellReuseIdentifier: IGMapNearbyDistanceCell.cellReuseIdentifier())
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
        self.view.backgroundColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
        self.tableView.tableHeaderView?.backgroundColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
        
        self.notificationToken = nearbyDistanceList!.observe { (changes: RealmCollectionChange) in
            switch changes {
                
            case .initial:
                self.tableView.reloadData()
                break
                
            case .update(_, let deletions, let insertions, let modifications):
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) }, with: .none)
                self.tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) }, with: .none)
                self.tableView.reloadRows(at: modifications.map { IndexPath(row: $0, section: 0) }, with: .none)
                self.tableView.endUpdates()
                break
                
            case .error(let err):
                fatalError("\(err)")
                break
            }
        }
        if IGAppManager.sharedManager.isUserLoggiedIn() {
            self.fetchNearbyUsersDistanceList()
        } else {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(self.fetchNearbyUsersDistanceList),
                                                   name: NSNotification.Name(rawValue: kIGUserLoggedInNotificationName),
                                                   object: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.isUserInteractionEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.isUserInteractionEnabled = true
    }
    
    
    @objc private func fetchNearbyUsersDistanceList() {
        IGGeoGetNearbyDistance.Generator.generate(lat: latitude, lon: longitude).success { (responseProtoMessage) in
            DispatchQueue.main.async {
                if let nearbyDistanceResponse = responseProtoMessage as? IGPGeoGetNearbyDistanceResponse {
                    IGGeoGetNearbyDistance.Handler.interpret(response: nearbyDistanceResponse)
                }
            }}.error({ (errorCode, waitTime) in }).send()
    }
    
    func manageOpenChat(userId: Int64){
        let realm = try! Realm()
        let predicate = NSPredicate(format: "chatRoom.peer.id = %lld", userId)
        if let roomInfo = try! realm.objects(IGRoom.self).filter(predicate).first {
            openChat(roomInfo: roomInfo)
        } else {
            IGChatGetRoomRequest.Generator.generate(peerId: userId).success({ (protoResponse) in
                DispatchQueue.main.async {
                    if let chatGetRoomResponse = protoResponse as? IGPChatGetRoomResponse {
                        IGChatGetRoomRequest.Handler.interpret(response: chatGetRoomResponse)
                        self.openChat(roomInfo: IGRoom(igpRoom: chatGetRoomResponse.igpRoom))
                    }
                }
            }).error({ (errorCode, waitTime) in
                switch errorCode {
                case .timeout:
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Timeout", message: "Please try again later for start chat with this user!", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                default:
                    break
                }
                
            }).send()
        }
    }
    
    func openChat(roomInfo: IGRoom){
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let roomVC = storyboard.instantiateViewController(withIdentifier: "messageViewController") as! IGMessageViewController
        roomVC.room = roomInfo
        self.navigationController!.pushViewController(roomVC, animated: true)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nearbyDistanceList!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: IGMapNearbyDistanceCell = self.tableView.dequeueReusableCell(withIdentifier: cellIdentifer) as! IGMapNearbyDistanceCell
        cell.setUserInfo(nearbyDistance : nearbyDistanceList![indexPath.row])
        
        cell.separatorInset = UIEdgeInsets(top: 0, left: 82.0, bottom: 0, right: 0)
        cell.layoutMargins = UIEdgeInsets.zero

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.isUserInteractionEnabled = false
        manageOpenChat(userId: nearbyDistanceList![indexPath.row].id)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 78.0
    }
}



