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

class IGSettingPrivacy_SecurityTableViewController: UITableViewController , UIGestureRecognizerDelegate {

    @IBOutlet weak var AlloLoginSwitch: UISwitch!
    @IBOutlet weak var whoCanSeeProfilePhotoLabel: UILabel!
    @IBOutlet weak var whoCanAddingMeToChannelLabel: UILabel!
    @IBOutlet weak var numberOfBlockedContacts: UILabel!
    @IBOutlet weak var whoCanSeeLastSeenLabel: UILabel!
    @IBOutlet weak var whoCanAddingToGroupLabel: UILabel!
    var selectedIndexPath : IndexPath!
    var hud = MBProgressHUD()
    var blockedUsers = try! Realm().objects(IGRegisteredUser.self).filter("isBlocked == 1" )
    var notificationToken: NotificationToken?
    var notificationToken2: NotificationToken?
    var userPrivacy = try! Realm().objects(IGUserPrivacy.self).filter("primaryKeyId == 1").first
    var allUserPrivacy = try! Realm().objects(IGUserPrivacy.self).filter("primaryKeyId == 1")
    var avatarUserPrivacy : IGPrivacyLevel?
    var lastSeenUserPrivacy: IGPrivacyLevel?
    var groupInviteUserPrivacy: IGPrivacyLevel?
    var channelInviteUserPrivacy: IGPrivacyLevel?
    override func viewDidLoad() {
        super.viewDidLoad()
        let backImage = UIImage(named: "IG_Settigns_Bg")
        let backgroundImageView = UIImageView(image: backImage)
        self.tableView.backgroundView = backgroundImageView
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: "Privacy & Security")
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        fetchBlockedContactsFromServer()
        let predicate = NSPredicate(format: "isBlocked == 1")
        blockedUsers = try! Realm().objects(IGRegisteredUser.self).filter(predicate)
        numberOfBlockedContacts.text = "\(blockedUsers.count) Contact"
        
        self.notificationToken = blockedUsers.addNotificationBlock { (changes: RealmCollectionChange) in
            switch changes {
            case .initial:
                self.tableView.reloadData()
                break
            case .update(_, let deletions, let insertions, let modifications):
                self.tableView.reloadData()
                
                print("updating members tableV")
                
                self.tableView.reloadData()
                break
            case .error(let err):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(err)")
                break
                
            }
        }
        
        self.notificationToken = allUserPrivacy.addNotificationBlock{ (changes: RealmCollectionChange) in
            switch changes {
            case .initial:
                self.tableView.reloadData()
                break
            case .update(_, let deletions, let insertions, let modifications):
                print("updating members tableV")
                // Query messages have changed, so apply them to the TableView
                self.tableView.reloadData()
                break
            case .error(let err):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(err)")
                break
            }

        }
        
        if let avatarPrivacy = userPrivacy?.avatar {
            avatarUserPrivacy = avatarPrivacy
            switch  avatarPrivacy{
            case .allowAll:
                whoCanSeeProfilePhotoLabel.text = "Everybody"
                break
            case .allowContacts:
                whoCanSeeProfilePhotoLabel.text = "My Contacts"
                break
            case .denyAll:
                whoCanSeeProfilePhotoLabel.text = "Nobody"
                break
            }
        }
        if let userStatePrivacy = userPrivacy?.userStatus {
            lastSeenUserPrivacy = userStatePrivacy
            switch userStatePrivacy {
            case .allowAll:
                whoCanSeeLastSeenLabel.text = "Everybody"
                break
            case .allowContacts:
                whoCanSeeLastSeenLabel.text = "My Contacts"
                break
            case .denyAll:
                whoCanSeeLastSeenLabel.text = "Nobody"
                break
            }
        }
        if let channelInvitePrivacy = userPrivacy?.channelInvite {
            channelInviteUserPrivacy = channelInvitePrivacy
            switch channelInvitePrivacy {
                
            case .allowAll:
                whoCanAddingMeToChannelLabel.text = "Everybody"
                break
            case .allowContacts:
                whoCanAddingMeToChannelLabel.text = "My Contacts"
                break
            case .denyAll:
                whoCanAddingMeToChannelLabel.text = "Nobody"
                break
            }
        }
        if let groupInvitePrivacy = userPrivacy?.groupInvite {
            groupInviteUserPrivacy = groupInvitePrivacy
            switch groupInvitePrivacy {
            case .allowAll:
                whoCanAddingToGroupLabel.text = "Everybody"
                break
            case .allowContacts:
                whoCanAddingToGroupLabel.text = "My Contacts"
                break
            case .denyAll:
                whoCanAddingToGroupLabel.text = "Nobody"
                break

            }
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.isUserInteractionEnabled = true
        fetchBlockedContactsFromServer()
        numberOfBlockedContacts.text = "\(blockedUsers.count) Contact "
        if let avatarPrivacy = userPrivacy?.avatar {
            avatarUserPrivacy = avatarPrivacy
            switch  avatarPrivacy{
            case .allowAll:
                whoCanSeeProfilePhotoLabel.text = "Everybody"
                break
            case .allowContacts:
                whoCanSeeProfilePhotoLabel.text = "My Contacts"
                break
            case .denyAll:
                whoCanSeeProfilePhotoLabel.text = "Nobody"
                break
            }
        }
        if let userStatePrivacy = userPrivacy?.userStatus {
            lastSeenUserPrivacy = userStatePrivacy
            switch userStatePrivacy {
            case .allowAll:
                whoCanSeeLastSeenLabel.text = "Everybody"
                break
            case .allowContacts:
                whoCanSeeLastSeenLabel.text = "My Contacts"
                break
            case .denyAll:
                whoCanSeeLastSeenLabel.text = "Nobody"
                break
            }
        }
        if let channelInvitePrivacy = userPrivacy?.channelInvite {
            channelInviteUserPrivacy = channelInvitePrivacy
            switch channelInvitePrivacy {
                
            case .allowAll:
                whoCanAddingMeToChannelLabel.text = "Everybody"
                break
            case .allowContacts:
                whoCanAddingMeToChannelLabel.text = "My Contacts"
                break
            case .denyAll:
                whoCanAddingMeToChannelLabel.text = "Nobody"
                break
            }
        }
        if let groupInvitePrivacy = userPrivacy?.groupInvite {
            groupInviteUserPrivacy = groupInvitePrivacy
            switch groupInvitePrivacy {
            case .allowAll:
                whoCanAddingToGroupLabel.text = "Everybody"
                break
            case .allowContacts:
                whoCanAddingToGroupLabel.text = "My Contacts"
                break
            case .denyAll:
                whoCanAddingToGroupLabel.text = "Nobody"
                break
                
            }
        }
    }    
        func fetchBlockedContactsFromServer(){
        IGUserContactsGetBlockedListRequest.Generator.generate().success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let getBlockedListProtoResponse as IGPUserContactsGetBlockedListResponse:
                    IGUserContactsGetBlockedListRequest.Handler.interpret(response: getBlockedListProtoResponse)
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows : Int = 0
        switch section {
        case 0:
            numberOfRows = 5
        case 1:
            numberOfRows = 1
        default:
            break
        }
        return numberOfRows
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
         if indexPath.section == 0 && indexPath.row == 0 {
            self.tableView.isUserInteractionEnabled = false
            performSegue(withIdentifier: "GoToBlockListPageFromPrivacyAndSecurity", sender: self)
            //selectedIndexPath = indexPath
         }
        if indexPath.section == 0 && indexPath.row != 0 {
            self.tableView.isUserInteractionEnabled = false
            performSegue(withIdentifier: "GoToWhoCanSeeYourPrivacyAndPolicyPage", sender: self)
        }
        
        if indexPath.section == 1 {
            switch indexPath.row {
            case 1 :
                self.tableView.isUserInteractionEnabled = false
                performSegue(withIdentifier: "GoToPassCodeLockSettingsPage", sender: self)
            case 2 :
                self.tableView.isUserInteractionEnabled = false
                performSegue(withIdentifier: "GoToTwoStepVerificationPage", sender: self)
            case 0 :
                self.tableView.isUserInteractionEnabled = false
                performSegue(withIdentifier: "GoToActiveSessionListPage", sender: self)
                default:
                break
            }
        }
        //selectedIndexPath = indexPath
    }
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
         var footerText = ""
        if section == 1 {
             footerText = ""
            //"Switch this on to use the PC and iPad version of iGap, and to login to other iGap web and mobile services."
        }
        return footerText
    }
    @IBAction func goBackToPrivacyAndSecurityList(seque:UIStoryboardSegue){
        numberOfBlockedContacts.text = "\(blockedUsers.count) Contact "
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let whoCanSeeYourPrivacyAndSetting = segue.destination as? IGPrivacyAndSecurityWhoCanSeeTableViewController {
            if selectedIndexPath.section == 0 {
                switch selectedIndexPath.row {
                case 1:
                    whoCanSeeYourPrivacyAndSetting.headerText = "Who can see my Profile Photo"
                    whoCanSeeYourPrivacyAndSetting.mode = "Profile Photo"
                    whoCanSeeYourPrivacyAndSetting.privacyType = .avatar
                    whoCanSeeYourPrivacyAndSetting.privacyLevel = avatarUserPrivacy
                    
                case 2:
                    whoCanSeeYourPrivacyAndSetting.headerText = "Who can see my Last Seen"
                    whoCanSeeYourPrivacyAndSetting.lastSeenFooterText = "If you don't share your Last Seen , you won't be able to see people's Last Seen "
                    whoCanSeeYourPrivacyAndSetting.mode = "Last Seen"
                    whoCanSeeYourPrivacyAndSetting.privacyType = .userStatus
                    whoCanSeeYourPrivacyAndSetting.privacyLevel = lastSeenUserPrivacy
                case 3:
                    whoCanSeeYourPrivacyAndSetting.headerText = "Who can adding me to Groups"
                    whoCanSeeYourPrivacyAndSetting.mode = "Adding me to Groups"
                    whoCanSeeYourPrivacyAndSetting.privacyType = .groupInvite
                    whoCanSeeYourPrivacyAndSetting.privacyLevel = groupInviteUserPrivacy
                case 4:
                    whoCanSeeYourPrivacyAndSetting.headerText = "Who can adding me to Channels"
                    whoCanSeeYourPrivacyAndSetting.mode = "Adding me to Channels"
                    whoCanSeeYourPrivacyAndSetting.privacyType = .channelInvite
                    whoCanSeeYourPrivacyAndSetting.privacyLevel = channelInviteUserPrivacy
                default:
                break
                }
            }
        }
    }
}
