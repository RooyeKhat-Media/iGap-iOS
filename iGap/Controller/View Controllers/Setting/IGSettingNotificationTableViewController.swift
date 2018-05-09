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

class IGSettingNotificationTableViewController: UITableViewController {

    @IBOutlet weak var doNotDistrubSwitch: UISwitch!
    @IBOutlet weak var alertSwitcher: UISwitch!
    @IBOutlet weak var messagePreviewSwitch: UISwitch!
    @IBOutlet weak var soundLabel: UILabel!
    @IBOutlet weak var groupNotificationsAlertSwitch: UISwitch!
    @IBOutlet weak var groupNotificationsMessagePreviewSwitch: UISwitch!
    @IBOutlet weak var contactJoinediGapSwitch: UISwitch!
    @IBOutlet weak var inAppPreviewSwitch: UISwitch!
    @IBOutlet weak var inAppVibrateSwitch: UISwitch!
    @IBOutlet weak var inAppSoundsSwitch: UISwitch!
    @IBOutlet weak var groupNotificationSoundLabel: UILabel!
    
    let greenColor = UIColor.organizationalColor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
        doNotDistrubSwitch.addTarget(self, action: #selector(IGSettingNotificationTableViewController.stateChanged), for: UIControlEvents.valueChanged)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        var numberOfSections = 0
        if doNotDistrubSwitch.isOn {
            numberOfSections = 1
        }else{
            numberOfSections = 6
        }
        return numberOfSections
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows : Int = 0
        switch section {
        case 0:
            numberOfRows = 1
            break
        case 1:
            numberOfRows = 3
            break
        case 2:
            numberOfRows = 3
        case 3:
            numberOfRows = 3
        case 4:
            numberOfRows = 1
        case 5:
            numberOfRows = 1
        default:
            break
        }
        return numberOfRows
    }
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 5 {
            showConfirmDeleteAlertView()
        }
    }
    func stateChanged(){
        if doNotDistrubSwitch.isOn {
            self.tableView.reloadData()
            } else {
            self.tableView.reloadData()
            }
        }
    func showConfirmDeleteAlertView(){
        let deleteConfirmAlertView = UIAlertController(title: "Undo all custom notification settings for all your chats, groups and channels", message: nil, preferredStyle: IGGlobal.detectAlertStyle())
        let deleteAction = UIAlertAction(title: "Reset All Notifications", style:.default , handler: {
            (alert: UIAlertAction) -> Void in
        })
        let cancelAction = UIAlertAction(title: "Cancel", style:.cancel , handler: {
            (alert: UIAlertAction) -> Void in
        })
        deleteConfirmAlertView.addAction(deleteAction)
        deleteConfirmAlertView.addAction(cancelAction)
        let alertActions = deleteConfirmAlertView.actions
        for action in alertActions {
            if action.title == "Reset All Notifications"{
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
