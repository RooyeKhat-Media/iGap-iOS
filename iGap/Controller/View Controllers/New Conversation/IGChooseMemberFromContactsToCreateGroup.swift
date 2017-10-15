/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the RooyeKhat Media Company - www.RooyeKhat.co
 * All rights reserved.
 */

import Foundation
import UIKit
import Contacts
class IGChooseMemberFromContactsToCreateGroup: UITableViewController , UISearchResultsUpdating //, UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout  {
{
    class User:NSObject {
        let name:String!
        var section :Int?
        init(name:String){
            self.name = name
        }
        
    }
    class Section  {
        var users:[User] = []
        func addUser(_ user:User){
            self.users.append(user)
            
        }
        
    }
    var bottomView : UIView?
//    var collectionView : UICollectionView?{
//        didSet{
//            collectionView?.register(IGChooseMemberToCreateGroupBottomViewCollectionViewCell.self, forCellWithReuseIdentifier: "CollectionCell")
//            collectionView?.dataSource = self
//            collectionView?.delegate = self
//        }
//    }

    let greenColor = UIColor.organizationalColor()
    var contactStore = CNContactStore()
    var contacts = [CNContact]()
    var contactSections : [Section]?
    let collation = UILocalizedIndexedCollation.current()
    var filteredTableData = [CNContact]()
    var resultSearchController = UISearchController()
    var segmentControl : UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bottomView = UIView(frame: CGRect(x: self.tableView.frame.maxX, y: 70, width: tableView.frame.width, height: 80))
        self.tableView.addSubview(bottomView!)
        fetchContacts()
        setupSearchBar()
        setBarbuttonItem()
        self.tableView.allowsMultipleSelection = true
        self.tableView.allowsMultipleSelectionDuringEditing = true
        self.tableView.setEditing(true, animated: true)
        self.tableView.sectionIndexBackgroundColor = UIColor.clear
        bottomView?.backgroundColor = UIColor.yellow

    }
        
    func setBarbuttonItem(){
        //cancelButton
        self.tableView.allowsMultipleSelectionDuringEditing = true
        let cancelBtn = UIButton()
        cancelBtn.frame = CGRect(x: 8, y: 300, width: 60, height: 0)
        
        cancelBtn.setTitle("Next", for: UIControlState.normal)
        cancelBtn.setTitleColor(greenColor, for: .normal)
        cancelBtn.addTarget(self, action: #selector(IGChooseMemberFromContactsToCreateGroup.nextButtonClicked), for: UIControlEvents.touchUpInside)
        let topRightbarButtonItem = UIBarButtonItem(customView: cancelBtn)
        self.navigationItem.rightBarButtonItem = topRightbarButtonItem
        
        
        
    }
    
    
    func nextButtonClicked(){
        
        
        
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
        
        // Reload the table
        self.tableView.reloadData()
    }
    
    var sections : [Section]{
        if self.contactSections != nil {
            return self.contactSections!
        }
        let users :[User] = contacts.map{ name in
            let user = User(name: name.givenName + name.familyName )
            
            user.section = self.collation.section(for: user, collationStringSelector: #selector(getter: User.name))
            return user
        }
        var sections = [Section]()
        for i in 0..<self.collation.sectionIndexTitles.count{
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
    
    
    func fetchContacts(){
        let keys = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName)]
        
        let request = CNContactFetchRequest(keysToFetch: keys)
        
        do {
            try self.contactStore.enumerateContacts(with: request) {
                (contact, stop) in
                // Array containing all unified contacts from everywhere
                self.contacts.append(contact)
            }
        }
        catch {
            print("unable to fetch contacts")
        }
        print(self.contacts.count)
        tableView.reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if (self.resultSearchController.isActive) {
            return 1
        }else{
            
            return self.sections.count
        }
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if (self.resultSearchController.isActive) {
            return self.filteredTableData.count
        }else{
            return self.sections[section].users.count
            
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        let contactsCell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath) as! IGChooseContactToAddNewGroupTableViewCell
        if (self.resultSearchController.isActive) {
            contactsCell.contactNameLabel?.text = filteredTableData[indexPath.row].givenName + filteredTableData[indexPath.row].familyName
            
            
        }else{
            let user = self.sections[indexPath.section].users[indexPath.row]
            contactsCell.contactNameLabel.text = user.name
        }
        
        
        cell = contactsCell
        
        return cell
    }
    override func tableView(_ tableView: UITableView,
                            titleForHeaderInSection section: Int)
        -> String {
            
            
            tableView.headerView(forSection: section)?.backgroundColor = UIColor.red
            if !self.sections[section].users.isEmpty {
                return self.collation.sectionTitles[section]
            }else{
                
                return ""
            }
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.collation.sectionIndexTitles
    }
    
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        
        return self.collation.section(forSectionIndexTitle: index)
    }
    
    func predicateForContacts(matchingName name: String) -> NSPredicate{
        
        return predicateForContacts(matchingName: self.resultSearchController.searchBar.text!)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filteredTableData.removeAll(keepingCapacity: false)
        let predicate = CNContact.predicateForContacts(matchingName: searchController.searchBar.text!)
        let keyToFetch = [CNContactFamilyNameKey,CNContactGivenNameKey]
        
        do {
            
            let resualtContacts =  try self.contactStore.unifiedContacts(matching: predicate, keysToFetch: keyToFetch as [CNKeyDescriptor])
            
            filteredTableData = resualtContacts
            
        } catch {
            print("Handle error")
        }
        
        self.tableView.reloadData()
        
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if resultSearchController.isActive == false {
            if tableView.isEditing == true{
//                collectionView = UICollectionView(frame: <#T##CGRect#>, collectionViewLayout: <#T##UICollectionViewLayout#>)
                tableView.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0)
                
                
                
            }
            
        }
    }
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if resultSearchController.isActive == false {
            if tableView.isEditing == true{
                tableView.reloadData()
      }
    }
  }
}
