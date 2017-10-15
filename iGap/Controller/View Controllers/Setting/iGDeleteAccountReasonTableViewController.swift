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
import MBProgressHUD
import IGProtoBuff

class IGDeleteAccountReasonTableViewController: UITableViewController , UIGestureRecognizerDelegate {

    var token : String?
    var deleteReasen : IGDeleteReasen?
    @IBOutlet weak var tickImageView: UIImageView!
    @IBOutlet weak var reasenDeleteLabel: UILabel!
    @IBOutlet weak var secondCellTickImageView: UIImageView!
    @IBOutlet weak var thirdCellTickImageView: UIImageView!
    var hud = MBProgressHUD()
    override func viewDidLoad() {
        super.viewDidLoad()
        tickImageView.isHidden = true
        secondCellTickImageView.isHidden = true
        thirdCellTickImageView.isHidden = true
        self.tableView.backgroundColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: "Done", title: "Delete Account")
        
        let navigationController = self.navigationController as! IGNavigationController
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        navigationItem.rightViewContainer?.addAction {
            self.doneButtonClicked()
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        reasenDeleteLabel.text = "Other"
    }
        // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
         tickImageView.isHidden = false
         secondCellTickImageView.isHidden = true
         thirdCellTickImageView.isHidden = true
        case 1:
         tickImageView.isHidden = true
         secondCellTickImageView.isHidden = false
         thirdCellTickImageView.isHidden = true
        case 2:
         tickImageView.isHidden = true
         secondCellTickImageView.isHidden = true
         thirdCellTickImageView.isHidden = false
        default:
            break
        }
    }
        func doneButtonClicked(){
            if let tokenCode = token {
                self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                self.hud.mode = .indeterminate
                    IGUserDeleteRequest.Generator.generate(token: tokenCode , reasen: IGPUserDelete.IGPReason(rawValue: 0)!).success({ (protoResponse) in
                        DispatchQueue.main.async {
                            switch protoResponse {
                            case let deleteUserProtoResponse as IGPUserDeleteResponse:
                                IGUserDeleteRequest.Handler.interpret(response: deleteUserProtoResponse)
                                self.hud.hide(animated: true)
                                if self.navigationController is IGNavigationController {
                                    self.dismiss(animated: true, completion: nil)
                                }
                            default:
                                break
                            }
                        }
                    }).error ({ (errorCode, waitTime) in
                        switch errorCode {
                        case .timeout:
                            DispatchQueue.main.async{
                                let alert = UIAlertController(title:"Timeout", message: "Please try again later", preferredStyle: .alert)
                                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                alert.addAction(okAction)
                                self.hud.hide(animated: true)
                                self.present(alert, animated: true, completion: nil)
                            }
                        case .userDeleteTokenInvalidCode:
                            DispatchQueue.main.async {
                                let alert = UIAlertController(title:"Invalid Code", message: "Please Re-Send correct code", preferredStyle: .alert)
                                let okAction = UIAlertAction(title: "OK", style: .default , handler: {
                                    (alert: UIAlertAction) -> Void in
                                    if self.navigationController is IGNavigationController {
                                        self.navigationController?.popViewController(animated: true)
                                    }

                                })
                                alert.addAction(okAction)
                                self.hud.hide(animated: true)
                                self.present(alert, animated: true, completion: nil)
                                
                            }
                            
                        default:break
                        }
                        
                    }).send()
                }
            }
}
