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

class IGTabBarController: UITabBarController {
    
    enum CurrentTab {
        case Recent
        case Chat
        case Group
        case Channel
        case Call
    }
    
    internal static var currentTabStatic: CurrentTab = .Recent
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.barTintColor = UIColor.organizationalColor()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        selectedItemTitleMustbeBold()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        selectedItemTitleMustbeBold()
    }
    
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        selectedItemTitleMustbeBold()
    }
    
    func selectedItemTitleMustbeBold(){
        for item in tabBar.items!{
            if tabBar.selectedItem == item {
                setCurrentTab(tag: (tabBar.selectedItem?.tag)!)
                let selectedTitleFont = UIFont.systemFont(ofSize: 9, weight: UIFontWeightBold)
                let selectedTitleColor = UIColor.white
                item.setTitleTextAttributes([NSFontAttributeName: selectedTitleFont, NSForegroundColorAttributeName: selectedTitleColor], for: UIControlState.normal)
            } else {
                let normalTitleFont = UIFont.systemFont(ofSize: 9, weight: UIFontWeightRegular)
                let normalTitleColor = UIColor(red: 176.0/255.0, green: 224.0/255.0, blue: 230.0/255.0, alpha: 1.0)
                item.setTitleTextAttributes([NSFontAttributeName: normalTitleFont, NSForegroundColorAttributeName: normalTitleColor], for: UIControlState.normal)
            }
        }
    }
    
    private func setCurrentTab(tag: Int){
        switch tag {
            
        case 0:
            IGTabBarController.currentTabStatic = .Recent
            return
            
        case 1:
            IGTabBarController.currentTabStatic = .Chat
            return
            
        case 2:
            IGTabBarController.currentTabStatic = .Group
            return
            
        case 3:
            IGTabBarController.currentTabStatic = .Channel
            return
        
        case 4:
            IGTabBarController.currentTabStatic = .Call
            return
            
        default:
            IGTabBarController.currentTabStatic = .Recent
            return
        }
    }
}
