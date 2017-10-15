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

class IGSettingChatFontSizeTableViewController: UITableViewController {
    
    @IBOutlet weak var deviceSettingSwitcher: UISwitch!
    @IBOutlet weak var mediumFontSizeCell: UITableViewCell!
    let greenColor = UIColor.organizationalColor()
    var currentSelectedCellIndexPath : IndexPath?
    override func viewDidLoad() {
        super.viewDidLoad()
        setBarbuttonItem()
        setDefualtFontSize()
        self.tableView.backgroundColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
        deviceSettingSwitcher.addTarget(self, action: #selector(IGSettingChatFontSizeTableViewController.stateChanged), for: UIControlEvents.valueChanged)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        var numberOfSection = 0
        if deviceSettingSwitcher.isOn{
            numberOfSection = 1
        }else{
            numberOfSection = 2
        }
        return numberOfSection
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows : Int = 0
        switch section {
        case 0:
            numberOfRows = 1
        case 1 :
            numberOfRows = 4
        default:
            break
        }
        return numberOfRows
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section != 0 {
            if let currentCell = tableView.cellForRow(at: indexPath){
                currentCell.selectedBackgroundView?.backgroundColor = UIColor.clear
                if currentCell != mediumFontSizeCell {
                    mediumFontSizeCell.accessoryType = .none
                }
                if (currentCell.accessoryType == UITableViewCellAccessoryType.none) {
                    currentCell.accessoryType = UITableViewCellAccessoryType.checkmark
                }else{
                    (currentCell.accessoryType = UITableViewCellAccessoryType.none)
                }
            }
        }
        currentSelectedCellIndexPath  = indexPath
    }
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let currentCell = tableView.cellForRow(at: indexPath)
        if let selectedCell = currentCell {
            if selectedCell.accessoryType == UITableViewCellAccessoryType.checkmark {
                selectedCell.accessoryType = UITableViewCellAccessoryType.none
            }
        }
    }
    func stateChanged(){
        if deviceSettingSwitcher.isOn {
            if let lastSelectedIndexPath = currentSelectedCellIndexPath {
                tableView.deselectRow(at: lastSelectedIndexPath, animated: true)
                let cell = tableView.cellForRow(at: lastSelectedIndexPath)
                cell?.accessoryType = .none
            }
            self.tableView.reloadData()
        }else{
            setDefualtFontSize()
            self.tableView.reloadData()
        }
    }
    func setDefualtFontSize(){
        mediumFontSizeCell.accessoryType = .checkmark
    }
    func setBarbuttonItem(){
        //nextButton
        let doneBtn = UIButton()
        doneBtn.frame = CGRect(x: 8, y: 300, width: 60, height: 0)
        let normalTitleFont = UIFont.systemFont(ofSize: UIFont.buttonFontSize, weight: UIFontWeightSemibold)
        let normalTitleColor = greenColor
        let attrs = [NSFontAttributeName: normalTitleFont, NSForegroundColorAttributeName: normalTitleColor]
        let doneTitle = NSAttributedString(string: "Done", attributes: attrs)
        doneBtn.setAttributedTitle(doneTitle, for: .normal)
        doneBtn.addTarget(self, action: #selector(IGSettingChatFontSizeTableViewController.doneButtonClicked), for: UIControlEvents.touchUpInside)
        let topRightBarbuttonItem = UIBarButtonItem(customView: doneBtn)
        self.navigationItem.rightBarButtonItem = topRightBarbuttonItem
    }
    func doneButtonClicked(){
    }
    
}
