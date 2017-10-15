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
import IGProtoBuff

class IGAccountTableViewController: UITableViewController , UINavigationControllerDelegate , UIGestureRecognizerDelegate  {
    
    @IBOutlet weak var emailIndicator: UIActivityIndicatorView!
    @IBOutlet weak var phoneNumberEntryLabel: UILabel!
    @IBOutlet weak var nicknameEntryLabel: UILabel!
    @IBOutlet weak var usernameEntryLabel: UILabel!
    @IBOutlet weak var emailEntryLabel: UILabel!
    @IBOutlet weak var selfDestructionLabel: UILabel!
    
    var currentUser: IGRegisteredUser!
    var notificationToken: NotificationToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Account"
        self.tableView.backgroundColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
        showAccountDetail()
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: "Account")
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.isUserInteractionEnabled = true
        changeBackButtonItemPosition()
        if currentUser.email == nil {
            getUserEmail()
        } else {
            self.emailIndicator.stopAnimating()
            self.emailIndicator.hidesWhenStopped = true
        }
        if currentUser.selfRemove == -1 {
            getSelfRemove()
        }
    }
    
    //MARK: Account details
    func showAccountDetail(){
        let currentUserId = IGAppManager.sharedManager.userID()
        let realm = try! Realm()
        let predicate = NSPredicate(format: "id = %lld", currentUserId!)
        currentUser = realm.objects(IGRegisteredUser.self).filter(predicate).first!
        self.updateUI()
        notificationToken = currentUser.addNotificationBlock({ (changes: ObjectChange) in
            switch changes {
            case .change(_):
                self.updateUI()
            default:
                break
            }
            
        })
    }
    
    func updateUI() {
        nicknameEntryLabel.text = currentUser.displayName
        usernameEntryLabel.text = currentUser.username
        emailEntryLabel.text = currentUser.email
        phoneNumberEntryLabel.text = "\(currentUser.phone)"
        
        
        if currentUser.selfRemove == -1 {
            selfDestructionLabel.text = ""
        } else if currentUser.selfRemove == 12 {
            selfDestructionLabel.text = "1 year"
        } else if currentUser.selfRemove == 1 {
            selfDestructionLabel.text = "\(currentUser.selfRemove)" + " month"
        } else {
            selfDestructionLabel.text = "\(currentUser.selfRemove)" + " months"
        }
    }
    

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 3
        case 2 :
            return 2
        case 3 :
            return 1
            default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            self.tableView.isUserInteractionEnabled = false
            performSegue(withIdentifier: "GoToNicknamePage", sender: self)
        }
//        if indexPath.section == 1 && indexPath.row == 0 {
   //     self.tableView.isUserInteractionEnabled = false

//            performSegue(withIdentifier: "GoToPhoneNumberPage", sender: self)
//        }
        if indexPath.section == 1 && indexPath.row == 1 {
            self.tableView.isUserInteractionEnabled = false
            performSegue(withIdentifier: "GoToUsernamePage", sender: self)
        }
        if indexPath.section == 1 && indexPath.row == 2 {
            self.tableView.isUserInteractionEnabled = false
            performSegue(withIdentifier: "GoToEmailPage", sender: self)
        }
        if indexPath.section == 2 && indexPath.row == 0 {
            self.tableView.isUserInteractionEnabled = false
            performSegue(withIdentifier: "GoToDeleteAccountPage", sender: self)
        }
        if indexPath.section == 2 && indexPath.row == 1 {
            self.tableView.isUserInteractionEnabled = false
            performSegue(withIdentifier: "GoToSelfDestructionTimePage", sender: self)
        }
        if indexPath.section == 3 && indexPath.row == 0 {
           showLogoutActionSheet()
        }
    }
        func showLogoutActionSheet(){
            let logoutConfirmAlertView = UIAlertController(title: "Are you sure you want to Log out?", message: nil, preferredStyle: .actionSheet)
            let logoutAction = UIAlertAction(title: "Log out", style:.default , handler: {
                (alert: UIAlertAction) -> Void in
                self.dismiss(animated: true, completion: {
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.logoutAndShowRegisterViewController()
                    IGWebSocketManager.sharedManager.closeConnection()
                })

            })
            let cancelAction = UIAlertAction(title: "Cancel", style:.cancel , handler: {
                (alert: UIAlertAction) -> Void in
            })
            logoutConfirmAlertView.addAction(logoutAction)
            logoutConfirmAlertView.addAction(cancelAction)
            let alertActions = logoutConfirmAlertView.actions
            for action in alertActions {
                if action.title == "Log out"{
                    let logoutColor = UIColor.red
                    action.setValue(logoutColor, forKey: "titleTextColor")
                }
            }
            logoutConfirmAlertView.view.tintColor = UIColor.organizationalColor()
            if let popoverController = logoutConfirmAlertView.popoverPresentationController {
                popoverController.sourceView = self.tableView
                popoverController.sourceRect = CGRect(x: self.tableView.frame.midX-self.tableView.frame.midX/2, y: self.tableView.frame.midX-self.tableView.frame.midX/2, width: self.tableView.frame.midX, height: self.tableView.frame.midY)
                popoverController.permittedArrowDirections = UIPopoverArrowDirection.init(rawValue: 0)
            }
            present(logoutConfirmAlertView, animated: true, completion: nil)
    }
    
    func changeBackButtonItemPosition(){
        let customView = UIView(frame: CGRect(x: 10, y: 0, width: 100, height: 64))
        customView.backgroundColor = UIColor.red
        let backItem = UIBarButtonItem(customView: customView)
        backItem.title = "Back"
        backItem.tintColor = UIColor.organizationalColor()
        navigationItem.backBarButtonItem = backItem
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let selfDestructionVC = segue.destination as? IGSettingHaveCheckmarkOntheLeftTableViewController {
            selfDestructionVC.items = [1, 3, 6, 12]
            selfDestructionVC.mode = "Self-Destruction"
            
        }
    }
    
    @IBAction func goBackToMainList(seque:UIStoryboardSegue){
        self.tableView.beginUpdates()
        showAccountDetail()
        self.tableView.endUpdates()
        
    }
    
    func getUserEmail() {
        self.emailIndicator.startAnimating()
        IGUserProfileGetEmailRequest.Generator.generate().success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let getUserEmailResponse as IGPUserProfileGetEmailResponse:
                    let userEmail = IGUserProfileGetEmailRequest.Handler.interpret(response: getUserEmailResponse)
                    self.emailEntryLabel.text = userEmail
                    self.emailIndicator.stopAnimating()
                    self.emailIndicator.hidesWhenStopped = true
                default:
                    break
                }
            }
        }).error ({ (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Timeout", message: "Could not fetch your email address.\nPlease try again later", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.emailIndicator.stopAnimating()
                    self.emailIndicator.hidesWhenStopped = true
                    self.present(alert, animated: true, completion: nil)
                }
            default:
                break
            }
            
        }).send()
    }
    
    func getSelfRemove() {
        IGUserProfileGetSelfRemoveRequest.Generator.generate().success({ (protoResponse) in
            switch protoResponse {
            case let response as IGPUserProfileGetSelfRemoveResponse:
                IGUserProfileGetSelfRemoveRequest.Handler.interpret(response: response)
            default:
                break
            }
        }).error ({ (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Timeout", message: "Could not fetch self destruction time.\nPlease try again later", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.emailIndicator.stopAnimating()
                    self.emailIndicator.hidesWhenStopped = true
                    self.present(alert, animated: true, completion: nil)
                }
            default:
                break
            }
            
        }).send()
    }
    
}
