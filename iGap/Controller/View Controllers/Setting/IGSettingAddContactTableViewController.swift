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

class IGSettingAddContactTableViewController: UITableViewController {

    let borderName = CALayer()
    let width = CGFloat(0.5)
    let greenColor = UIColor.organizationalColor()
    let tableviewBackgroundColor = UIColor(red: 239/255, green: 238/255, blue: 246/255, alpha: 1)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupHeaderView()
        setupDoneBarButton()
        tableView.backgroundColor = tableviewBackgroundColor
    }
       func doneButtonClicked(){
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func setupHeaderView(){
        //headerView
        let headerViewSize = CGRect(x: 0, y: 0, width: tableView.frame.width, height: tableView.frame.height / 2.43)
        let headerView = UIView(frame: headerViewSize)
        headerView.backgroundColor = UIColor.white
        tableView.tableHeaderView = headerView
        //contactImage
        let addContactImageView = UIImageView()
        let imageHeightAndWidth : CGFloat = 90
        addContactImageView.frame = CGRect(x: headerViewSize.midX - (imageHeightAndWidth / 2), y: (tableView.frame.width / 8.11), width: imageHeightAndWidth , height: imageHeightAndWidth)
        addContactImageView.image = UIImage(named: "userProfile")
        //ContactNameTextField
        let contactNameTextField = UITextField()
        let textfieldHeight : CGFloat = 30
        let textfieldwidth : CGFloat = 160
        contactNameTextField.frame = CGRect(x: headerView.frame.midX - (textfieldwidth / 2), y: addContactImageView.frame.maxY + (textfieldHeight / 2) , width: textfieldwidth, height: textfieldHeight)
        contactNameTextField.borderStyle = .none
        contactNameTextField.textAlignment = .center
        contactNameTextField.placeholder = "Contact Name"
        contactNameTextField.font = UIFont.systemFont(ofSize: 18)
        contactNameTextField.becomeFirstResponder()
        //bottomBorderOfTextField
        borderName.borderColor = greenColor.cgColor
        borderName.frame = CGRect(x: 0, y: contactNameTextField.frame.size.height - width, width:  contactNameTextField.frame.size.width, height: contactNameTextField.frame.size.height)
        borderName.borderWidth = width
        contactNameTextField.layer.addSublayer(borderName)
        contactNameTextField.layer.masksToBounds = true
        headerView.addSubview(addContactImageView)
        headerView.addSubview(contactNameTextField)
    }
    func setupDoneBarButton(){
        let doneBtn = UIButton()
        doneBtn.frame = CGRect(x: 8, y: 300, width: 60, height: 0)
        let normalTitleFont = UIFont.systemFont(ofSize: UIFont.buttonFontSize, weight: UIFontWeightSemibold)
        let normalTitleColor = greenColor
        let attrs = [NSFontAttributeName: normalTitleFont, NSForegroundColorAttributeName: normalTitleColor]
        let doneTitle = NSAttributedString(string: "Done", attributes: attrs)
        doneBtn.setAttributedTitle(doneTitle, for: .normal)
        doneBtn.addTarget(self, action: #selector(IGSettingAddContactTableViewController.doneButtonClicked), for: UIControlEvents.touchUpInside)
        let topRightBarbuttonItem = UIBarButtonItem(customView: doneBtn)
        self.navigationItem.rightBarButtonItem = topRightBarbuttonItem
    }

}
