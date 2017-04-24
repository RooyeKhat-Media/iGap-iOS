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

class IGSettingPrivacyAndSecurityTwoStepVerificationTableViewController: UITableViewController {
    
    let greenColor = UIColor(red: 49.0/255.0, green: 189.0/255.0, blue: 182.0/255.0, alpha: 1)
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNextBarButtonItem()
        let backImage = UIImage(named: "IG_Settigns_Bg")
        let backgroundImageView = UIImageView(image: backImage)
        self.tableView.backgroundView = backgroundImageView
    }
        override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.textLabel?.text = header.textLabel?.text?.capitalized
        header.textLabel?.textAlignment = .center
    }
    
    func setupNextBarButtonItem(){
        let doneBtn = UIButton()
        doneBtn.frame = CGRect(x: 8, y: 300, width: 60, height: 0)
        let normalTitleFont = UIFont.systemFont(ofSize: UIFont.buttonFontSize, weight: UIFontWeightSemibold)
        let normalTitleColor = greenColor
        let attributeText = [NSFontAttributeName: normalTitleFont, NSForegroundColorAttributeName: normalTitleColor]
        let doneTitle = NSAttributedString(string: "Done", attributes: attributeText)
        doneBtn.setAttributedTitle(doneTitle, for: .normal)
        doneBtn.addTarget(self, action: #selector(IGSettingPrivacyAndSecurityTwoStepVerificationTableViewController.doneButtonClicked), for: UIControlEvents.touchUpInside)
        let topRightBarbuttonItem = UIBarButtonItem(customView: doneBtn)
        self.navigationItem.rightBarButtonItem = topRightBarbuttonItem
    }
    func doneButtonClicked(){
        let alert = UIAlertController(title: "Check Your E-mail", message: "Please check your e-mail and click on the vallidation link to complete Two-Step Verification setup. ", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        alert.view.tintColor = greenColor
        self.present(alert, animated: true, completion: nil)
    }

}

