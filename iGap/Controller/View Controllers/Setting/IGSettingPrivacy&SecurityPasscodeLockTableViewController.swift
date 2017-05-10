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

class IGSettingPrivacy_SecurityPasscodeLockTableViewController: UITableViewController {
    @IBOutlet weak var turnPasscodeOnLable: UILabel!
    @IBOutlet weak var autoLockCell: UITableViewCell!
    @IBOutlet weak var changePasscodeCell: UITableViewCell!
    @IBOutlet weak var autoLockAfterTimeLabel: UILabel!
    
    var loadItForSecendTime : Bool = false
    var index : Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        let backImage = UIImage(named: "IG_Settigns_Bg")
        let backgroundImageView = UIImageView(image: backImage)
        self.tableView.backgroundView = backgroundImageView
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: "Passcode Lock")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.isUserInteractionEnabled = true

    }
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.isUserInteractionEnabled = true

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if loadItForSecendTime == false {
        return 1
        }else{
            return 2
        }
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows = 0
        if loadItForSecendTime == false {
        numberOfRows = 1
        }else{
            switch section {
            case 0:
                numberOfRows = 2
            case 1:
                numberOfRows = 1
            default:
                break
            }
        }
        return numberOfRows
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                index = indexPath.row
            case 1:
                index = indexPath.row
            default:
                break
            }
            self.tableView.isUserInteractionEnabled = false
            self.performSegue(withIdentifier: "EnterPassCode", sender: self)
        }
        if loadItForSecendTime == true{
            if indexPath.section == 1 {
                let settingStoryBoard = UIStoryboard(name: "IGSettingStoryboard", bundle: nil)
                let AutoLockedTableViewcontroller = settingStoryBoard.instantiateViewController(withIdentifier: "CheckmarkOntheLeftTable") as! IGSettingHaveCheckmarkOntheLeftTableViewController
                AutoLockedTableViewcontroller.navBarTitle = "Auto-Lock"
//                AutoLockedTableViewcontroller.items = ["Disable","If away for 1min","If away for 5 min","If away for 1 hour"]
            navigationController?.pushViewController(AutoLockedTableViewcontroller, animated: true)
        }
      }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination =
            segue.destination as? IGSettingPrivacy_SecurityEnterPasscodeLockViewController {
            if let rowNumber = index {
            switch rowNumber {
            case 0:
                destination.isTurnOnPassCode = true
            case 1:
                destination.isChangePasswordMode = true 
            default:
                break
               }
            }
        }
    }
    @IBAction func goBackToPasscodeTableView(seque:UIStoryboardSegue){
        turnPasscodeOnLable.text = "Turn Passcode Off"
        changePasscodeCell.isHidden = false
        autoLockCell.isHidden = false
        tableView.reloadData()
        tableView.reloadInputViews()
    }
}
