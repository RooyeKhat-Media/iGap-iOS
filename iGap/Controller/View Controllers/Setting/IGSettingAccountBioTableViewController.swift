//
//  IGSettingAccountBioTableViewController.swift
//  iGap
//
//  Created by MacBook Pro on 1/13/18.
//  Copyright © 2018 RooyeKhat Media. All rights reserved.
//

import UIKit
import RealmSwift
import MBProgressHUD
import IGProtoBuff

class IGSettingAccountBioTableViewController: UITableViewController , UIGestureRecognizerDelegate{
    
    @IBOutlet weak var bioTextField: UITextField!
    
    var hud = MBProgressHUD()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let predicate = NSPredicate(format: "id = %lld", IGAppManager.sharedManager.userID()!)
        if let userInDb = try! Realm().objects(IGRegisteredUser.self).filter(predicate).first {
            if let bio = userInDb.bio {
                bioTextField.text = bio
            }
        }
        
        self.tableView.backgroundColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
        
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: "Done", title: "Bio")
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        navigationItem.rightViewContainer?.addAction {
            self.didTapOnDoneButton()
        }
        
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    func didTapOnDoneButton() {
        self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.hud.mode = .indeterminate
        if let bio = bioTextField.text {
            IGUserProfileSetBioRequest.Generator.generate(bio: bio).success({ (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let userProfileSetBioResponse as IGPUserProfileSetBioResponse:
                        let bio = IGUserProfileSetBioRequest.Handler.interpret(response: userProfileSetBioResponse)
                        
                        let realm = try! Realm()
                        try! realm.write {
                            let predicate = NSPredicate(format: "id = %lld", IGAppManager.sharedManager.userID()!)
                            if let userRegister = realm.objects(IGRegisteredUser.self).filter(predicate).first {
                                userRegister.bio = bio
                            }
                        }
                        
                        if self.navigationController is IGNavigationController {
                            _ = self.navigationController?.popViewController(animated: true)
                        }
                    default:
                        break
                    }
                    self.hud.hide(animated: true)
                }
                
            }).error ({ (errorCode, waitTime) in
                
                DispatchQueue.main.async {
                    switch errorCode {
                    case .timeout:
                        self.showAlert(title: "Timeout", message: "Please try later!")
                        break
                        
                    case .userProfileSetBioBadPayload:
                        self.showAlert(title: "Error", message: "Your bio is invalid")
                        break
                        
                    default:
                        break
                    }
                    self.hud.hide(animated: true)
                }
                
            }).send()
        }
    }
}
