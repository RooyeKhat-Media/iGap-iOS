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


class IGCreateNewChatTableViewController: UITableViewController, UISearchResultsUpdating , UIGestureRecognizerDelegate, IGCallFromContactListObserver {
    
    class User: NSObject {
        let registredUser: IGRegisteredUser
        @objc let name: String
        var section :Int?
        init(registredUser: IGRegisteredUser){
            self.registredUser = registredUser
            self.name = registredUser.displayName
        }
    }

    class Section  {
        var users = [User]()
        func addUser(_ user:User){
            self.users.append(user)
        }
    }
    
    @IBOutlet weak var AddContactButton: UIBarButtonItem!
    
    internal static var callDelegate: IGCallFromContactListObserver!
    
    var contacts = try! Realm().objects(IGRegisteredUser.self).filter("isInContacts == 1")
    
    var contactSections: [Section]?
    let collation = UILocalizedIndexedCollation.current()
    var resultSearchController = UISearchController()
    var sections: [Section] {
        if self.contactSections != nil {
            return self.contactSections!
        }
        let users: [User] = contacts.map { (registredUser) -> User in
            let user = User(registredUser: registredUser)
            user.section = self.collation.section(for: user, collationStringSelector: #selector(getter: User.name))
            return user
        }

        var sections = [Section]()
        for i in 0..<self.collation.sectionIndexTitles.count {
            sections.append(Section())
        }
        
        for user in users {
            sections[user.section!].addUser(user)
        }
        
        for section in sections {
            section.users = self.collation.sortedArray(from: section.users, collationStringSelector: #selector(getter: User.name)) as! [User]
        }
        
        self.contactSections = sections
        return self.contactSections!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IGCreateNewChatTableViewController.callDelegate = self
        
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addModalViewItems(leftItemText: "Close", rightItemText: nil, title: "New Conversation")
        navigationItem.navigationController = self.navigationController as! IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        navigationItem.leftViewContainer?.addAction {
            self.dismiss(animated: true, completion: {
                
            })
        }
//        setupSearchBar()
        self.tableView.sectionIndexBackgroundColor = UIColor.clear
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        if (self.resultSearchController.isActive) {
            return 1
        }else{
            return self.sections.count // + 1
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.resultSearchController.isActive) {
            return self.contacts.count
        }else{
            return self.sections[section].users.count
            //TODO: re-enable "Add Contact"
//            if section == 0 {
//                return 1
//            }else{
//                return self.sections[ section - 1 ].users.count
//            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let contactsCell = tableView.dequeueReusableCell(withIdentifier: "ContactsCell", for: indexPath) as! IGContactTableViewCell
        if (self.resultSearchController.isActive) {
            contactsCell.setUser(contacts[indexPath.row])
        }else{
            let user = self.sections[indexPath.section].users[indexPath.row]
            contactsCell.setUser(user.registredUser)
        }
        return contactsCell
        //TODO: re-enable "Add Contact"
//        if !(self.resultSearchController.isActive) && indexPath.section == 0 {
//            let blockListCell  = tableView.dequeueReusableCell(withIdentifier: "AddContactCell", for: indexPath) as! IGAddNewContactTableViewCell
//            //set the data here
//            return blockListCell
//        }else{
//            let contactsCell = tableView.dequeueReusableCell(withIdentifier: "ContactsCell", for: indexPath) as! IGContactTableViewCell
//            if (self.resultSearchController.isActive) {
//                contactsCell.setUser(contacts[indexPath.row])
//            }else{
//                let user = self.sections[indexPath.section - 1 ].users[indexPath.row]
//                contactsCell.setUser(user.registredUser)
//            }
//            return contactsCell
//        }
    }
    
    override func tableView(_ tableView: UITableView,titleForHeaderInSection section: Int)-> String {
        if !self.sections[section].users.isEmpty {
            return self.collation.sectionTitles[section]
        }
        return ""
        //TODO: re-enable "Add Contact"
//        if section == 0 {
//            return "  "
//        }
//        tableView.headerView(forSection: section)?.backgroundColor = UIColor.red
//        if !self.sections[section - 1].users.isEmpty {
//            return self.collation.sectionTitles[section - 1]
//        } else {
//                return ""
//        }
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.collation.sectionIndexTitles
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return self.collation.section(forSectionIndexTitle: index)
        //TODO: re-enable "Add Contact"
//        return self.collation.section(forSectionIndexTitle: index - 1)
    }
    
    func call(user: IGRegisteredUser) {
        self.dismiss(animated: false, completion: {
            DispatchQueue.main.async {
                (UIApplication.shared.delegate as! AppDelegate).showCallPage(userId: user.id, isIncommmingCall: false)
            }
        })
    }
    
    func predicateForContacts(matchingName name: String) -> NSPredicate{
        return predicateForContacts(matchingName: self.resultSearchController.searchBar.text!)
    }
    
    
    func updateSearchResults(for searchController: UISearchController) {
//        filteredTableData.removeAll(keepingCapacity: false)
//        let predicate = CNContact.predicateForContacts(matchingName: searchController.searchBar.text!)
//        let keyToFetch = [CNContactFamilyNameKey,CNContactGivenNameKey]
//            do {
//           let resualtContacts =  try self.contactStore.unifiedContacts(matching: predicate, keysToFetch: keyToFetch as [CNKeyDescriptor])
//            filteredTableData = resualtContacts
//            } catch {
//            print("Handle error")
//         }
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let hud = MBProgressHUD.showAdded(to: self.view.superview!, animated: true)
        hud.mode = .indeterminate
        let user = self.sections[indexPath.section].users[indexPath.row]
        IGChatGetRoomRequest.Generator.generate(peerId: user.registredUser.id).success({ (protoResponse) in
            switch protoResponse {
            case let chatGetRoomResponse as IGPChatGetRoomResponse:
                let roomId = IGChatGetRoomRequest.Handler.interpret(response: chatGetRoomResponse)
                self.dismiss(animated: true, completion: {
                    //segue to created chat
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: kIGNotificationNameDidCreateARoom),
                                                    object: nil,
                                                    userInfo: ["room": roomId])
                })
                hud.hide(animated: true)
                break
            default:
                break
            }
            
        }).error({ (errorCode, waitTime) in
            hud.hide(animated: true)
            let alertC = UIAlertController(title: "Error", message: "An error occured trying to create a conversation", preferredStyle: .alert)
            
            let cancel = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertC.addAction(cancel)
            self.present(alertC, animated: true, completion: nil)
        }).send()
        
//        if resultSearchController.isActive == false {
//            if indexPath.section == 0 && indexPath.row == 0 {
//                
//            } else {
//                let user = self.sections[indexPath.section - 1 ].users[indexPath.row]
//                IGChatGetRoomRequest.Generator.generate(peerId: user.registredUser.id).success({ (protoResponse) in
//                    switch protoResponse {
//                    case let chatGetRoomResponse as IGPChatGetRoomResponse:
//                        let roomId = IGChatGetRoomRequest.Handler.interpret(response: chatGetRoomResponse)
//                        self.dismiss(animated: true, completion: {
//                            //segue to created chat
//                        })
//                        break
//                    default:
//                        break
//                    }
//                    
//                }).error({ (errorCode, waitTime) in
//                    
//                }).send()
//            }
//        }
    }
    
    
    func setupSearchBar(){
        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            self.tableView.tableHeaderView = controller.searchBar
            return controller
        })()
        self.tableView.reloadData()
    }
}
