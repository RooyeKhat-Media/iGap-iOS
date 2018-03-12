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

class IGLookAndFind: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate , UINavigationControllerDelegate , UIGestureRecognizerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var searchResults: Results<IGRealmClientSearchUsername>!
    var notificationToken: NotificationToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: "Look And Find")
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        
        self.deleteBeforeSearch()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        searchResults = try! Realm().objects(IGRealmClientSearchUsername.self)
        
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
        self.view.backgroundColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
        self.tableView.tableHeaderView?.backgroundColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
        
        self.notificationToken = searchResults!.observe { (changes: RealmCollectionChange) in
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
    }
    
    private func search(query: String){
        IGClientSearchUsernameRequest.Generator.generate(query: query).success { (responseProtoMessage) in
            
            if let searchUsernameResponse = responseProtoMessage as? IGPClientSearchUsernameResponse {
                IGClientSearchUsernameRequest.Handler.interpret(response: searchUsernameResponse)
            }
            
            }.error({ (errorCode, waitTime) in
                
            }).send()
    }
    
    private func deleteBeforeSearch(){
        let realm = try! Realm()
        let searchResults = try! Realm().objects(IGRealmClientSearchUsername.self)
        try! realm.write {
            realm.delete(searchResults)
        }
    }
    
    private func openChatRoom(searchResult: IGRealmClientSearchUsername){
        IGClientSubscribeToRoomRequest.Generator.generate(roomId: searchResult.room.id).success { (responseProtoMessage) in
            DispatchQueue.main.async {
                let room = searchResult.room
                let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let roomVC = storyboard.instantiateViewController(withIdentifier: "messageViewController") as! IGMessageViewController
                roomVC.room = room
                roomVC.openChatFromLink = true
                self.navigationController!.pushViewController(roomVC, animated: true)
            }
            }.error({ (errorCode, waitTime) in
                switch errorCode {
                case .timeout:
                    self.openChatRoom(searchResult: searchResult)
                default:
                    break
                }
            }).send()
        
    }
    
    private func openUserProfile(searchResult: IGRealmClientSearchUsername){
        let user = searchResult.user
        let room = searchResult.room
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "IGRegistredUserInfoTableViewController") as! IGRegistredUserInfoTableViewController
        destinationVC.user = user
        destinationVC.previousRoomId = 0
        destinationVC.room = room
        self.navigationController!.pushViewController(destinationVC, animated: true)
    }
    
    //****************** SearchBar ******************
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {}
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {}
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {}
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if(searchText.count >= 5){
            self.deleteBeforeSearch()
            
            if let text = searchBar.text {
                self.search(query: text)
            }
        }
    }
    
    //****************** tableView ******************
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: IGLookAndFindCell = self.tableView.dequeueReusableCell(withIdentifier: "LookUpSearch", for: indexPath) as! IGLookAndFindCell
        cell.setSearchResult(result: self.searchResults[indexPath.row])
        cell.separatorInset = UIEdgeInsets(top: 0, left: 74.0, bottom: 0, right: 0)
        cell.layoutMargins = UIEdgeInsets.zero
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { // IGRegistredUserInfoTableViewController
        
        let searchResult = self.searchResults![indexPath.row]
        
        if searchResult.type == IGPClientSearchUsernameResponse.IGPResult.IGPType.room.rawValue {
            openChatRoom(searchResult: searchResult)
        } else {
            openUserProfile(searchResult: searchResult)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
}
