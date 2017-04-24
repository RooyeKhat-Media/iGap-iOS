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
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
                let selectedTitleFont = UIFont.systemFont(ofSize: 9, weight: UIFontWeightBold)
                let selectedTitleColor = UIColor.organizationalColor()
                item.setTitleTextAttributes([NSFontAttributeName: selectedTitleFont, NSForegroundColorAttributeName: selectedTitleColor], for: UIControlState.normal)
            }else{
                let normalTitleFont = UIFont.systemFont(ofSize: 9, weight: UIFontWeightRegular)
                let normalTitleColor = UIColor(red: 136.0/255.0, green: 136.0/255.0, blue: 136.0/255.0, alpha: 136.0/255.0)
                item.setTitleTextAttributes([NSFontAttributeName: normalTitleFont, NSForegroundColorAttributeName: normalTitleColor], for: UIControlState.normal)
            }
        }
        
    }
}
