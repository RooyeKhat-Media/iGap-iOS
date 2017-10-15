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

class IGSettingAccountPhoneNumberTableViewController: UITableViewController {

    @IBOutlet weak var firstCell: UITableViewCell!
    let greenColor = UIColor.organizationalColor()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.tableView.backgroundColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
        setBarbuttonItems()
    }
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        }
        override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
        }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return CGFloat.leastNormalMagnitude
        }
    func setBarbuttonItems(){
        //donebutton
        let doneBtn = UIButton()
        doneBtn.frame = CGRect(x: 8, y: 300, width: 60, height: 0)
        let normalTitleFont = UIFont.systemFont(ofSize: UIFont.buttonFontSize, weight: UIFontWeightSemibold)
        let normalTitleColor = greenColor
        let attrs = [NSFontAttributeName: normalTitleFont, NSForegroundColorAttributeName: normalTitleColor]
        let doneTitle = NSAttributedString(string: "Done", attributes: attrs)
        doneBtn.setAttributedTitle(doneTitle, for: .normal)
        doneBtn.addTarget(self, action: #selector(IGSettingAccountPhoneNumberTableViewController.doneButtonClicked), for: UIControlEvents.touchUpInside)
        let topRightBarbuttonItem = UIBarButtonItem(customView: doneBtn)
        self.navigationItem.rightBarButtonItem = topRightBarbuttonItem
        }
    func cancelButtonClicked(){
        self.dismiss(animated: true, completion: nil)
        }
    func doneButtonClicked(){}
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        }
    }
