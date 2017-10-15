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
import RealmSwift
import MBProgressHUD
import IGProtoBuff

class IGSettingHaveCheckmarkOntheLeftTableViewController: UITableViewController , UIGestureRecognizerDelegate {
    
    var mode = ""
    var destructionTime : Int32 = -1
    var items: [Int32] = []
    var navBarTitle = ""
    var hud = MBProgressHUD()
    var currentUser: IGRegisteredUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let currentUserId = IGAppManager.sharedManager.userID()
        let realm = try! Realm()
        let predicate = NSPredicate(format: "id = %lld", currentUserId!)
        currentUser = realm.objects(IGRegisteredUser.self).filter(predicate).first!
        
        self.navigationItem.title = navBarTitle
        self.tableView.backgroundColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: "Done", title: mode)
        navigationItem.navigationController = self.navigationController as! IGNavigationController
        let navigationController = self.navigationController as? IGNavigationController
        navigationItem.rightViewContainer?.addAction {
            self.doneButtonClicked()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LeftCheckmarkCell", for: indexPath) as! IGSettingHaveCheckmarkOntheLeftTableViewCell
        if mode == "Self-Destruction" {
            if indexPath.row == 0 {
              cell.titleLable.text = "1 month"
            } else {
              cell.titleLable.text = "\(items[indexPath.row])" + " months"
            }
            
            if currentUser.selfRemove == -1 && items[indexPath.row] == 12 {
                cell.accessoryType = .checkmark
                cell.setSelected(true, animated: false)
            } else if items[indexPath.row] == currentUser.selfRemove {
                cell.accessoryType = .checkmark
                cell.setSelected(true, animated: false)
            } else {
                cell.accessoryType = .none
                cell.setSelected(false, animated: false)
            }
                
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        for i in 0..<items.count {
            let a = IndexPath(row: i, section: 0)
            let currentCell = tableView.cellForRow(at: a) as! IGSettingHaveCheckmarkOntheLeftTableViewCell
            if a == indexPath {
                currentCell.accessoryType = .checkmark
            } else {
                currentCell.accessoryType = .none
            }
        }
        destructionTime = items[indexPath.row]
    }
    
    func doneButtonClicked(){
        self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.hud.mode = .indeterminate
        IGUserProfileSetSelfRemoveRequest.Generator.generate(selfRemove: destructionTime).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let setSelfRemoveProtoResponse as IGPUserProfileSetSelfRemoveResponse:
                    IGUserProfileSetSelfRemoveRequest.Handler.interpret(response: setSelfRemoveProtoResponse)
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
                    self.present(alert, animated: true, completion: nil)
                }
            default:
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error", message: "There was an error saving self-destruction time!", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                }
                break
            }
            self.hud.hide(animated: true)
        }).send()
    }
}
