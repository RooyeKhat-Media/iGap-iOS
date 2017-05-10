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


class IGSettingChatCatchTableViewController: UITableViewController {

    let contactsAndGroup = ["BB Group Chat","AA Channel","john smith"]
    let contactUserImage = ["boy","chat","face.jpg"]
    var timeToKeepMedia : String = "Forever"
    var cachedDataNavBarTitle : String = " "
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backImage = UIImage(named: "IG_Settigns_Bg")
        let backgroundImageView = UIImageView(image: backImage)
        self.tableView.backgroundView = backgroundImageView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.isUserInteractionEnabled = true
    }
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.isUserInteractionEnabled = true

    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRow : Int = 0
        switch section {
        case 0:
            numberOfRow = 1
        case 1:
            numberOfRow = 1
        case 2:
            numberOfRow = contactsAndGroup.count
        default:
            break
        }
        return numberOfRow
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        if indexPath.section == 0 || indexPath.section == 1 {
          let cacheMediaCell  = tableView.dequeueReusableCell(withIdentifier: "SettingCatchMediaCell", for: indexPath) as! IGSettingChatCatchTableViewCell
            if indexPath.section == 0 {
            cacheMediaCell.catchMediaTitle.text = "Keep Media"
            cacheMediaCell.sizeOfCatchFileLable.text = timeToKeepMedia
            }
            if indexPath.section == 1 {
                cacheMediaCell.catchMediaTitle.text = "Catched Data"
            }
            cell = cacheMediaCell
        }else{
            let contactCacheCell = tableView.dequeueReusableCell(withIdentifier: "SettingCatchContactMediaCell", for: indexPath) as! IGSettingChatCatchContactAndGroupsTableViewCell
            contactCacheCell.contactNameLable.text = contactsAndGroup[indexPath.row]
            contactCacheCell.contactImageView.image = UIImage(named:contactUserImage[indexPath.row])
            cell = contactCacheCell
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            self.tableView.isUserInteractionEnabled = false
            performSegue(withIdentifier: "GoToKeepMediaAfterTimePage", sender: self)
        }
        if indexPath.section == 1 && indexPath.row == 0 || indexPath.section == 2{
            self.tableView.isUserInteractionEnabled = false
            performSegue(withIdentifier: "GoToCachedDataItemsPage", sender: self)
            if indexPath.section == 2{
                let currentCell = tableView.cellForRow(at: indexPath) as?IGSettingChatCatchContactAndGroupsTableViewCell
                //print(currentCell?.contactNameLable.text)
                let currentTitle = currentCell?.contactNameLable.text
                cachedDataNavBarTitle = currentTitle!
            }
        }
    }
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        var footerText = ""
        if section == 0 {
         footerText = "All media files will be automatically deleted from this device after the selected period of time to save disk space. These files will stay in the iGap cloud and can be re-downloaded if you need it again."
        }
        if section == 1 {
            footerText = "Cached data is temporarily stored data that can be downloaded again later."
        }
        return footerText
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var headerText = ""
        if section == 2 {
            headerText = "Cached Data"
        }
        return headerText
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let keepMediaVC = segue.destination as? IGSettingHaveCheckmarkOntheLeftTableViewController {
            //keepMediaVC.items = ["1 week","1 months","1 year","Forever"]
        }
        if let cachedDataItemsVC = segue.destination as? IGSettingChatClearChacheTableViewController {
            cachedDataItemsVC.navBarTitle = cachedDataNavBarTitle
        }
    }
}
