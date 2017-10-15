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
import SwiftProtobuf
import RealmSwift
import MBProgressHUD
import IGProtoBuff

class IGPrivacyAndSecurityWhoCanSeeTableViewController: UITableViewController , UIGestureRecognizerDelegate {
    
    var headerText = String()
    var footerText = String()
    var mode: String?
    var lastSeenFooterText = String()
    var selectedIndexPath: IndexPath!
    var lastSelectedIndexPath: IndexPath!
    var privacyType: IGPrivacyType!
    var privacyLevel: IGPrivacyLevel!
    var hud = MBProgressHUD()
    var cell : UITableViewCell!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        navigationItem.addNavigationViewItems(rightItemText: "Done", title: mode)
        navigationItem.rightViewContainer?.addAction {
            self.requestToSetPrivacyRule()
        }
        let everyBodyIndexPath = IndexPath(row: 0, section: 0)
        let myContactsIndexPath = IndexPath(row: 1, section: 0)
        let nobodyIndexPath = IndexPath(row: 2, section: 0)
        switch privacyLevel! {
        case .allowAll:
            tableView.selectRow(at: everyBodyIndexPath, animated: true, scrollPosition: .none)
            cell = tableView.cellForRow(at: everyBodyIndexPath)
            cell.accessoryType = .checkmark
            selectedIndexPath = everyBodyIndexPath
            break
        case .allowContacts:
            tableView.selectRow(at: myContactsIndexPath, animated: true, scrollPosition: .none)
            cell = tableView.cellForRow(at: myContactsIndexPath)
            cell.accessoryType = .checkmark
            selectedIndexPath = myContactsIndexPath
            break
        case .denyAll:
            tableView.selectRow(at: nobodyIndexPath, animated: true, scrollPosition: .none)
            cell = tableView.cellForRow(at: nobodyIndexPath)
            cell.accessoryType = .checkmark
            selectedIndexPath = nobodyIndexPath
        }

    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        var numberOfRows : Int = 0
        switch section {
        case 0:
            numberOfRows = 3
        default:
            break
        }
        return numberOfRows
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headerText
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        for i in 0..<tableView.numberOfRows(inSection: 0) {
            let a = IndexPath(row: i, section: 0)
            selectedIndexPath = indexPath
            let currentCell = tableView.cellForRow(at: a)! as UITableViewCell
            if a == indexPath {
                currentCell.accessoryType = .checkmark
            } else {
                currentCell.accessoryType = .none
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return lastSeenFooterText
    }
    
    func requestToSetPrivacyRule() {
        var privacyLevel = IGPrivacyLevel.denyAll
        switch selectedIndexPath.row {
        case 0:
            privacyLevel = .allowAll
        case 1:
            privacyLevel = .allowContacts
        case 2:
            privacyLevel = .denyAll
        default:
            break
        }
        self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.hud.mode = .indeterminate
        IGUserPrivacySetRuleRequest.Generator.generate(privacyType: privacyType, privacyLevel: privacyLevel).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let userPrivacySetRuleResponse as IGPUserPrivacySetRuleResponse:
                    IGUserPrivacySetRuleRequest.Handler.interpret(response: userPrivacySetRuleResponse)                    
                    if self.navigationController is IGNavigationController {
                        _ = self.navigationController?.popViewController(animated: true)
                    }
                default:
                    break
                }
                self.hud.hide(animated: true)
            }
        }).error ({ (errorCode, waitTime) in
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
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error", message: "There was an error changing privacy settings.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.hud.hide(animated: true)
                    self.present(alert, animated: true, completion: nil)
                }
                break
            }
            
        }).send()
    }
}

