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

class IGSettingChatClearChacheTableViewController: UITableViewController {
    
    @IBOutlet weak var filesSizeLabel: UILabel!
    @IBOutlet weak var VideosSizeLabel: UILabel!
    @IBOutlet weak var audioAndVoicesSizeLabel: UILabel!
    @IBOutlet weak var imagesAndGIFsSize: UILabel!
    
    var navBarTitle = "Cached Data"
    let greenColor = UIColor.organizationalColor()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupEditBtn()
        self.navigationItem.title = navBarTitle
        self.tableView.backgroundColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows = 0
        switch section {
        case 0:
            numberOfRows = 4
        case 1:
            numberOfRows = 1
        default:
            break
        }
        return numberOfRows
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1  {
            showConfirmDeleteAlertView()
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if tableView.isEditing == true {
            //  label.text = "0"
            doneButtonClicked()
        }
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return true
        }
        return false
    }
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func setupEditBtn(){
        let editBtn = UIButton()
        editBtn.setTitleColor(UIColor.organizationalColor(), for: .normal)
        editBtn.frame = CGRect(x:-100,y: 300, width:70, height: 60)
        //editBtn.backgroundColor = UIColor.red
        editBtn.setTitle(("Edit"), for: UIControlState.normal)
        //editBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 100)
        editBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 0)
        editBtn.contentHorizontalAlignment = .right
        editBtn.addTarget(self, action: #selector(IGSettingContactBlockListTableViewController.editButtonClicked), for: UIControlEvents.touchUpInside)
        let barButtonItem = UIBarButtonItem(customView: editBtn)
        barButtonItem.imageInsets = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 0)
        self.navigationItem.rightBarButtonItem = barButtonItem
    }
    func editButtonClicked(){
        self.tableView.allowsMultipleSelectionDuringEditing = false
        self.tableView.setEditing(true, animated: true)
        let doneBtn = UIButton()
        doneBtn.frame = CGRect(x:8, y:300, width:75, height:0)
        doneBtn.setTitleColor(greenColor, for: .normal)
        doneBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 0)
        let normalTitleColor = greenColor
        let normalTitleFont = UIFont.systemFont(ofSize: UIFont.buttonFontSize, weight: UIFontWeightSemibold)
        let attrs = [NSFontAttributeName: normalTitleFont, NSForegroundColorAttributeName: normalTitleColor]
        let doneTitle = NSAttributedString(string: "Done", attributes: attrs)
        doneBtn.setAttributedTitle(doneTitle, for: .normal)
        doneBtn.addTarget(self, action: #selector(IGSettingContactBlockListTableViewController.doneButtonClicked), for: UIControlEvents.touchUpInside)
        let topRightbarButtonItem = UIBarButtonItem(customView: doneBtn)
        topRightbarButtonItem.imageInsets = UIEdgeInsets(top: 0, left: 75, bottom: 0, right: 0)
        self.navigationItem.rightBarButtonItem = topRightbarButtonItem
    }
    func doneButtonClicked(){
        tableView?.setEditing(false, animated: true)
        setupEditBtn()
    }
    func showConfirmDeleteAlertView(){
        let deleteConfirmAlertView = UIAlertController(title: "Are you sure you want to delete the all data?", message: nil, preferredStyle: IGGlobal.detectAlertStyle())
        let deleteAction = UIAlertAction(title: "Delete", style:.default , handler: {
            (alert: UIAlertAction) -> Void in
        })
        let cancelAction = UIAlertAction(title: "Cancel", style:.cancel , handler: {
            (alert: UIAlertAction) -> Void in
        })
        deleteConfirmAlertView.addAction(deleteAction)
        deleteConfirmAlertView.addAction(cancelAction)
        let alertActions = deleteConfirmAlertView.actions
        for action in alertActions {
            if action.title == "Delete"{
                let logoutColor = UIColor.red
                action.setValue(logoutColor, forKey: "titleTextColor")
            }
        }
        deleteConfirmAlertView.view.tintColor = greenColor
        if let popoverController = deleteConfirmAlertView.popoverPresentationController {
            popoverController.sourceView = self.tableView
            popoverController.sourceRect = CGRect(x: self.tableView.frame.midX-self.tableView.frame.midX/2, y: self.tableView.frame.midX-self.tableView.frame.midX/2, width: self.tableView.frame.midX, height: self.tableView.frame.midY)
            popoverController.permittedArrowDirections = UIPopoverArrowDirection.init(rawValue: 0)
        }
        present(deleteConfirmAlertView, animated: true, completion: nil)
    }
}
