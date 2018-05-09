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

class IGSettingChatTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.isUserInteractionEnabled = true
    }
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.isUserInteractionEnabled = true
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows : Int = 0
        switch section {
        case 0 :
            numberOfRows = 1
        case 1 :
            numberOfRows = 4
        case 2 :
            numberOfRows = 4
        case 3 :
            numberOfRows = 1
        case 4 :
            numberOfRows = 2

        default:
            break
        }
        return numberOfRows
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        if indexPath.section == 0 {
//            switch indexPath.row {
//            case 0:
//                performSegue(withIdentifier: "GoToFontSizePage", sender: self)
//            case 1:
//                performSegue(withIdentifier: "GoToStickerPage", sender: self)
//            case 2:
//                performSegue(withIdentifier: "GoToChatWallpaperPage", sender: self)
//            default:
//                break
//            }
//        }
//        if indexPath.section == 1 && indexPath.row == 0 {
//            performSegue(withIdentifier: "GoToCacheSettingsPage", sender: self)
//        }
        if indexPath.section == 0 && indexPath.row == 0 {
            self.tableView.isUserInteractionEnabled = false
            performSegue(withIdentifier: "GoToCacheSettingsPage", sender: self)
        }
        if indexPath.section == 1 || indexPath.section == 2{
            self.tableView.isUserInteractionEnabled = false
            performSegue(withIdentifier: "GoToAutoDownloadTypePage", sender: self)
        }
        if indexPath.section == 4 {
            switch indexPath.row {
            case 0:
                showResetAutoDownloadSettingsAlert()
            case 1:
                showDeleteAllChatsAlert()
            default:
                break
            }
        }
    }
    func showResetAutoDownloadSettingsAlert(){
        
            let resetAutoDownloadAlert = UIAlertController(title: "Are you sure you want to Reset Auto-Download Settings?", message: nil, preferredStyle: IGGlobal.detectAlertStyle())
            let deleteAction = UIAlertAction(title: "Reset", style:.default , handler: {
                (alert: UIAlertAction) -> Void in
            })
            let cancelAction = UIAlertAction(title: "Cancel", style:.cancel , handler: {
                (alert: UIAlertAction) -> Void in
            })
            resetAutoDownloadAlert.addAction(deleteAction)
            resetAutoDownloadAlert.addAction(cancelAction)
            let alertActions = resetAutoDownloadAlert.actions
            for action in alertActions {
                if action.title == "Reset"{
                    let logoutColor = UIColor.red
                    action.setValue(logoutColor, forKey: "titleTextColor")
                }
            }
            resetAutoDownloadAlert.view.tintColor = UIColor.organizationalColor()
            if let popoverController = resetAutoDownloadAlert.popoverPresentationController {
                popoverController.sourceView = self.tableView
                popoverController.sourceRect = CGRect(x: self.tableView.frame.midX-self.tableView.frame.midX/2, y: self.tableView.frame.midX-self.tableView.frame.midX/2, width: self.tableView.frame.midX, height: self.tableView.frame.midY)
                popoverController.permittedArrowDirections = UIPopoverArrowDirection.init(rawValue: 0)
            }
            present(resetAutoDownloadAlert, animated: true, completion: nil)
        }
    func showDeleteAllChatsAlert(){
        let deleteAllChatsAlert = UIAlertController(title: "Are you sure you want to delete all chats?", message: nil, preferredStyle: IGGlobal.detectAlertStyle())
        let deleteAction = UIAlertAction(title: "Delete", style:.default , handler: {
            (alert: UIAlertAction) -> Void in
        })
        let cancelAction = UIAlertAction(title: "Cancel", style:.cancel , handler: {
            (alert: UIAlertAction) -> Void in
        })
        deleteAllChatsAlert.addAction(deleteAction)
        deleteAllChatsAlert.addAction(cancelAction)
        let alertActions = deleteAllChatsAlert.actions
        for action in alertActions {
            if action.title == "Delete"{
                let logoutColor = UIColor.red
                action.setValue(logoutColor, forKey: "titleTextColor")
            }
        }
        deleteAllChatsAlert.view.tintColor = UIColor.organizationalColor()
        if let popoverController = deleteAllChatsAlert.popoverPresentationController {
            popoverController.sourceView = self.tableView
            popoverController.sourceRect = CGRect(x: self.tableView.frame.midX-self.tableView.frame.midX/2, y: self.tableView.frame.midX-self.tableView.frame.midX/2, width: self.tableView.frame.midX, height: self.tableView.frame.midY)
            popoverController.permittedArrowDirections = UIPopoverArrowDirection.init(rawValue: 0)
        }
        present(deleteAllChatsAlert, animated: true, completion: nil)
    }
    
}
