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

class IGSettingPrivacyAndSecurityActiveSessionMoreDetailsTableViewController: UITableViewController, UIGestureRecognizerDelegate {
    
    var selectedSession: IGSession?
    @IBOutlet weak var platformSelectedSessionLabel: UILabel!
    @IBOutlet weak var appVersionSelectedSessionLabel: UILabel!
    @IBOutlet weak var countrySelectedSessionLabel: UILabel!
    @IBOutlet weak var createdTimeSelectedSessionLabel: UILabel!
    @IBOutlet weak var lastActivationSelectedSessionLabel: UILabel!
    @IBOutlet weak var ipSelectedSessionLabel: UILabel!
    @IBOutlet weak var SessionInfoCell: UITableViewCell!
    @IBOutlet weak var SelectedSessionDeviceModelLabel: UILabel!
    @IBOutlet weak var selectedSessionImageview: UIImageView!
    var hud = MBProgressHUD()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
        SessionInfoCell.selectionStyle = UITableViewCellSelectionStyle.none
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: "Active Sessions")
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        showContentCell()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            showConfirmDeleteAlertView()
                }
   }
    func showConfirmDeleteAlertView(){
        let deleteConfirmAlertView = UIAlertController(title: "Are you sure you want to terminate this device?", message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Terminate", style:.default , handler: {
            (alert: UIAlertAction) -> Void in
            if let thisSession = self.selectedSession {
                if thisSession.isCurrent == false {
                    self.terminateSession()
                }else{
                    self.logOutCurrentSession()
                }
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style:.cancel , handler: {
            (alert: UIAlertAction) -> Void in
        })
        deleteConfirmAlertView.addAction(deleteAction)
        deleteConfirmAlertView.addAction(cancelAction)
        let alertActions = deleteConfirmAlertView.actions
        for action in alertActions {
            if action.title == "Terminate"{
                let logoutColor = UIColor.red
                action.setValue(logoutColor, forKey: "titleTextColor")
            }
        }
        deleteConfirmAlertView.view.tintColor = UIColor.organizationalColor()
        if let popoverController = deleteConfirmAlertView.popoverPresentationController {
            popoverController.sourceView = self.tableView
            popoverController.sourceRect = CGRect(x: self.tableView.frame.midX-self.tableView.frame.midX/2, y: self.tableView.frame.midX-self.tableView.frame.midX/2, width: self.tableView.frame.midX, height: self.tableView.frame.midY)
            popoverController.permittedArrowDirections = UIPopoverArrowDirection.init(rawValue: 0)
        }
        present(deleteConfirmAlertView, animated: true, completion: nil)
    }
    func showContentCell(){
        if let thisSession = selectedSession {
            switch thisSession.platform! {
            case .android :
                platformSelectedSessionLabel.text = "Platform: Android"
                selectedSessionImageview.image = UIImage(named:"IG_Settings_Active_Sessions_Device_Android")
            case .iOS :
                platformSelectedSessionLabel.text = "Platform: iOS"
                selectedSessionImageview.image = UIImage(named:"IG_Settings_Active_Sessions_Device_iPhone")
            case .macOS :
                platformSelectedSessionLabel.text = "Platform: macOS"
                selectedSessionImageview.image = UIImage(named:"IG_Settings_Active_Sessions_Device_Mac")
            case .windows :
                platformSelectedSessionLabel.text = "Platform: windows"
                selectedSessionImageview.image = UIImage(named:"IG_Settings_Active_Sessions_Device_Windows")
            case .linux :
                platformSelectedSessionLabel.text = "Platform: linux"
                selectedSessionImageview.image = UIImage(named:"IG_Settings_Active_Sessions_Device_Linux")
            case .blackberry :
                platformSelectedSessionLabel.text = "Platform: blackberry"
                selectedSessionImageview.image = UIImage(named:"IG_Settings_Active_Sessions_Device_Android")
            default:
                break
            }
            switch thisSession.device! {
            case .mobile:
                SelectedSessionDeviceModelLabel.text = "Mobile"
            case .desktop:
                SelectedSessionDeviceModelLabel.text = "Desktop"
            case .tablet:
                SelectedSessionDeviceModelLabel.text = "Tablet"
            case .unknown:
                SelectedSessionDeviceModelLabel.text = "Unknown"
            }        
            appVersionSelectedSessionLabel.text = "App Version: \(thisSession.appVersion)"
            countrySelectedSessionLabel.text = "Country: \(thisSession.country)"
            let creationDateString = Date(timeIntervalSince1970: TimeInterval(thisSession.createTime)).completeHumanReadableTime()
            createdTimeSelectedSessionLabel.text = "Session initiated at: " + creationDateString
            let lastActiveDateString = Date(timeIntervalSince1970: TimeInterval(thisSession.activeTime)).completeHumanReadableTime()
            lastActivationSelectedSessionLabel.text = "Last active at: " + lastActiveDateString
            ipSelectedSessionLabel.text = "IP: \(thisSession.ip)"
        }
    }
    
    func terminateSession() {
        self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.hud.mode = .indeterminate
        if let thisSession = selectedSession {
            IGUserSessionTerminateRequest.Generator.generate(sessionId: thisSession.sessionId).success({
                (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let terminateSessionProtoResponse as IGPUserSessionTerminateResponse:
                        IGUserSessionTerminateRequest.Handler.interpret(response: terminateSessionProtoResponse)
                        self.hud.hide(animated: true)
                    default:
                        break
                    }
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
                    break
                }

            }).send()
            
        }
    }
    
    func logOutCurrentSession(){
        self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.hud.mode = .indeterminate
            IGUserSessionLogoutRequest.Generator.genarete().success({
                (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let logoutSessionProtoResponse as IGPUserSessionLogoutResponse:
                        IGUserSessionLogoutRequest.Handler.interpret(response: logoutSessionProtoResponse)
                    default:
                        break
                    }
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
                    break
                }

            }).send()
    }

}
