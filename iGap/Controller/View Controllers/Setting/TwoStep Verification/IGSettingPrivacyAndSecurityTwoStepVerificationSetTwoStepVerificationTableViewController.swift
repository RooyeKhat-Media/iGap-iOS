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
import IGProtoBuff
import MBProgressHUD

class IGSettingPrivacyAndSecurityTwoStepVerificationSetTwoStepVerificationTableViewController: UITableViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var verifyTextField: UITextField!
    @IBOutlet weak var question1TextField: UITextField!
    @IBOutlet weak var answer1TextField: UITextField!
    @IBOutlet weak var question2TextField: UITextField!
    @IBOutlet weak var answer2TextField: UITextField!
    @IBOutlet weak var hintTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
    }
    

    
//    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
//        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
//        header.textLabel?.text = header.textLabel?.text?.capitalized
//        header.textLabel?.textAlignment = .center
//    }
//    
//    func setupNextBarButtonItem(){
//        let doneBtn = UIButton()
//        doneBtn.frame = CGRect(x: 8, y: 300, width: 60, height: 0)
//        let normalTitleFont = UIFont.systemFont(ofSize: UIFont.buttonFontSize, weight: UIFontWeightSemibold)
//        let normalTitleColor = greenColor
//        let attributeText = [NSFontAttributeName: normalTitleFont, NSForegroundColorAttributeName: normalTitleColor]
//        let doneTitle = NSAttributedString(string: "Done", attributes: attributeText)
//        doneBtn.setAttributedTitle(doneTitle, for: .normal)
//        doneBtn.addTarget(self, action: #selector(doneButtonClicked), for: UIControlEvents.touchUpInside)
//        let topRightBarbuttonItem = UIBarButtonItem(customView: doneBtn)
//        self.navigationItem.rightBarButtonItem = topRightBarbuttonItem
//    }
//    
//    func doneButtonClicked(){
//        let alert = UIAlertController(title: "Check Your E-mail", message: "Please check your e-mail and click on the vallidation link to complete Two-Step Verification setup. ", preferredStyle: UIAlertControllerStyle.alert)
//        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
//        alert.view.tintColor = greenColor
//        self.present(alert, animated: true, completion: nil)
//    }

}

