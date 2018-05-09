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
import MBProgressHUD
import IGProtoBuff

class IGSettingChooseContactToAddToBlockListTableViewController: UITableViewController , UISearchResultsUpdating ,UINavigationControllerDelegate , UIGestureRecognizerDelegate {
    
    var chooseBlockContactFromPrivacyandSecurityPage : Bool = true
    class User:NSObject {
        let registredUser: IGRegisteredUser
        let name:String!
        var section :Int?
        init(registredUser: IGRegisteredUser){
            self.registredUser = registredUser
            self.name = registredUser.displayName
        }
    }
    class Section  {
        var users:[User] = []
        func addUser(_ user:User){
            self.users.append(user)
        }
    }
    
    var contacts = try! Realm().objects(IGRegisteredUser.self).filter("isInContacts == 1")
    var contactSections : [Section]?
    let collation = UILocalizedIndexedCollation.current()
    var filteredTableData = [CNContact]()
    var resultSearchController = UISearchController()
    var segmentControl : UISegmentedControl!
    var hud = MBProgressHUD()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        resultSearchController.searchBar.delegate = self
        self.tableView.sectionIndexBackgroundColor = UIColor.clear
        if chooseBlockContactFromPrivacyandSecurityPage == true {
            let centerSegmentView = UIView(frame: CGRect(x: 0, y:-5, width: 145, height: 50))
            segmentControl = UISegmentedControl(items: ["Contacts","Chats"])
            segmentControl.setWidth(70.5, forSegmentAt: 0)
            segmentControl.setWidth(70.5, forSegmentAt: 1)
            segmentControl.selectedSegmentIndex = 0
            segmentControl.backgroundColor = UIColor.white
            segmentControl.tintColor = UIColor.organizationalColor()
            segmentControl.addTarget(self, action: #selector(IGSettingChooseContactToAddToBlockListTableViewController.segmentIndexChanged), for: UIControlEvents.valueChanged)
            //centerSegmentView.addSubview(segmentControl)
            
            let navigationItem = self.navigationItem as! IGNavigationItem
            navigationItem.addNavigationViewItems(rightItemText: "Cancle", title: "Choose Contact")
            //navigationItem.titleView = centerSegmentView
            navigationItem.navigationController = self.navigationController as? IGNavigationController
            let navigationController = self.navigationController as! IGNavigationController
            navigationController.interactivePopGestureRecognizer?.delegate = self
            navigationItem.rightViewContainer?.addAction {
                if self.navigationController is IGNavigationController {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    func segmentIndexChanged(){
        switch segmentControl.selectedSegmentIndex {
        case 0:
            print("contacts")
        case 1:
            print("Chats")
        default:
            break;
        }
    }
    func setBarbuttonItem(){
        //doneButton
        self.tableView.allowsMultipleSelectionDuringEditing = true
        let doneButtonView = UIView(frame: CGRect(x:10, y:0,width: 100,height: 64))
        let doneBtn = UIButton()
        doneBtn.frame = CGRect(x: 38, y: -8 , width: 60, height: 60)
        let normalTitleFont = UIFont.systemFont(ofSize: UIFont.buttonFontSize, weight: UIFontWeightSemibold)
        let normalTitleColor = UIColor.organizationalColor()
        let attrs = [NSFontAttributeName: normalTitleFont, NSForegroundColorAttributeName: normalTitleColor]
        let doneTitle = NSAttributedString(string: "Done", attributes: attrs)
        doneBtn.setAttributedTitle(doneTitle, for: .normal)
        doneBtn.addTarget(self, action: #selector(IGSettingChooseContactToAddToBlockListTableViewController.doneButtonClicked), for: UIControlEvents.touchUpInside)
        doneButtonView.addSubview(doneBtn)
        let topRightbarButtonItem = UIBarButtonItem(customView: doneButtonView)
        self.navigationItem.rightBarButtonItem = topRightbarButtonItem
        if tableView.indexPathsForSelectedRows == nil {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
        //cancel button
        let leftView = UIView(frame: CGRect(x:10, y:0,width: 100,height: 64))
        let cancelBtn = UIButton()
        cancelBtn.frame = CGRect(x: 8, y: -8, width: 60, height: 60)
        cancelBtn.setTitle("Cancel", for: UIControlState.normal)
        cancelBtn.setTitleColor(UIColor.organizationalColor(), for: .normal)
        cancelBtn.addTarget(self, action: #selector(IGSettingChooseContactToAddToBlockListTableViewController.cancelButtonClicked), for: UIControlEvents.touchUpInside)
        leftView.addSubview(cancelBtn)
        let topLeftbarButtonItem = UIBarButtonItem(customView: leftView)
        self.navigationItem.leftBarButtonItem = topLeftbarButtonItem
    }
    func cancelButtonClicked(){
        self.dismiss(animated: true, completion: nil)
    }
    func doneButtonClicked(){
        
    }
    
    func setupSearchBar(){
        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            self.tableView.tableHeaderView = controller.searchBar
            let textFieldInsideSearchBar = controller.searchBar.value(forKey: "searchField") as? UITextField
            textFieldInsideSearchBar?.layer.cornerRadius = 15
            textFieldInsideSearchBar?.clipsToBounds = true
            return controller
        })()
        // Reload the table
        self.tableView.reloadData()
    }
    var sections : [Section]{
        if self.contactSections != nil {
            return self.contactSections!
        }
        let users :[User] = contacts.map{ (registredUser) -> User in
            let user = User(registredUser: registredUser )
            
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
        let contactsCell = tableView.dequeueReusableCell(withIdentifier: "ChooseContactToBlockedCell", for: indexPath) as! IGSettingChooseContactToAddToBlockListTableViewCell
        if (self.resultSearchController.isActive) {
            contactsCell.contactNameLable?.text = filteredTableData[indexPath.row].givenName + filteredTableData[indexPath.row].familyName
        }else{
            let user = self.sections[indexPath.section].users[indexPath.row]
            contactsCell.setUser(user.registredUser)
            
        }
        cell = contactsCell
        return cell
    }
    override func tableView(_ tableView: UITableView,titleForHeaderInSection section: Int) -> String {
        var titleOfHeader = ""
        if resultSearchController.isActive == false {
            tableView.headerView(forSection: section)?.backgroundColor = UIColor.red
            if !self.sections[section].users.isEmpty {
                titleOfHeader =  self.collation.sectionTitles[section]
            }else{
                
                titleOfHeader =  ""
            }
        }
        return titleOfHeader
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
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if resultSearchController.isActive == false {
            // let cell = tableView.cellForRow(at: indexPath)
            let user = self.sections[indexPath.section].users[indexPath.row]
            if let blockedUserId : Int64 = user.registredUser.id {
                showLogoutActionSheet(userID: blockedUserId)
            }
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func blockedSelectedContact(blockedUserId : Int64 ) {
        self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.hud.mode = .indeterminate
        IGUserContactsBlockRequest.Generator.generate(blockedUserId: blockedUserId).success({
            (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let blockedProtoResponse as IGPUserContactsBlockResponse:
                    IGUserContactsBlockRequest.Handler.interpret(response: blockedProtoResponse)
                    self.hud.hide(animated: true)
                default:
                    break
                }
            }
        }).error({ (errorCode, waitTime) in
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
    func showLogoutActionSheet(userID: Int64){
        let blockConfirmAlertView = UIAlertController(title: "Are you sure you want to Block this contact?", message: nil, preferredStyle: IGGlobal.detectAlertStyle())
        let blockAction = UIAlertAction(title: "Block", style:.default , handler: {
            (alert: UIAlertAction) -> Void in
            self.blockedSelectedContact(blockedUserId : userID )
            if self.navigationController is IGNavigationController {
                self.navigationController?.popViewController(animated: true)
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style:.cancel , handler: {
            (alert: UIAlertAction) -> Void in
        })
        blockConfirmAlertView.addAction(blockAction)
        blockConfirmAlertView.addAction(cancelAction)
        let alertActions = blockConfirmAlertView.actions
        for action in alertActions {
            if action.title == "Block"{
                let blockColor = UIColor.red
                action.setValue(blockColor, forKey: "titleTextColor")
            }
        }
        blockConfirmAlertView.view.tintColor = UIColor.organizationalColor()
        if let popoverController = blockConfirmAlertView.popoverPresentationController {
            popoverController.sourceView = self.tableView
            popoverController.sourceRect = CGRect(x: self.tableView.frame.midX-self.tableView.frame.midX/2, y: self.tableView.frame.midX-self.tableView.frame.midX/2, width: self.tableView.frame.midX, height: self.tableView.frame.midY)
            popoverController.permittedArrowDirections = UIPopoverArrowDirection.init(rawValue: 0)
        }
        present(blockConfirmAlertView, animated: true, completion: nil)
    }

}

extension IGSettingChooseContactToAddToBlockListTableViewController : UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        for ob: UIView in ((searchBar.subviews[0] )).subviews {
            if let z = ob as? UIButton {
                let btn: UIButton = z
                btn.setTitleColor(UIColor.organizationalColor(), for: .normal)
            }
        }
    }
    
}

