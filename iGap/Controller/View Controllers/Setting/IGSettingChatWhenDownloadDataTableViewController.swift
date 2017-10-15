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

class IGSettingChatWhenDownloadDataTableViewController: UITableViewController {

    @IBOutlet weak var wiFiCell: UITableViewCell!
    @IBOutlet weak var CellularCell: UITableViewCell!
    @IBOutlet weak var RoamingCell: UITableViewCell!
    @IBOutlet weak var neverCell: UITableViewCell!
    var checked = [false,false,false,false]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows : Int = 0
        if section == 0 {
            numberOfRows = 4
        }
        return numberOfRows
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         if let cell = tableView.cellForRow(at: indexPath) {
        if cell.accessoryType == .checkmark {
            cell.accessoryType = .none
            checked[indexPath.row] = false
        } else {
            cell.accessoryType = .checkmark
            checked[indexPath.row] = true
        }
            if cell == neverCell {
                wiFiCell.accessoryType = .none
                CellularCell.accessoryType = .none
                RoamingCell.accessoryType = .none
                neverCell.accessoryType = .checkmark
            }
            if neverCell.accessoryType == .checkmark {
                wiFiCell.accessoryType = .none
                CellularCell.accessoryType = .none
                RoamingCell.accessoryType = .none
            }
        }
    }
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            if cell == neverCell {
                cell.accessoryType = .none
            }
        }
    }
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.textLabel?.text = "Auto-Downloaded when using" + " Wi-Fi".capitalized
    }
}
