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

class IGNavigationBar: UINavigationBar, UINavigationBarDelegate {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.tintColor = UIColor.organizationalColor()
        self.isTranslucent = false
        //self.barStyle = .black
        self.barTintColor = UIColor.white
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        self.layer.shadowRadius = 4.0
        self.layer.shadowOpacity = 0.35
//        self.setBackgroundImage(nil, for: .default)
//        self.shadowImage = nil
//        [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
//        
//        [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    }
        
    override func layoutSubviews() {
        super.layoutSubviews()
        
        for items in self.items! {
            if items.leftBarButtonItems != nil {
            
                for item in items.leftBarButtonItems! {
                    item.setBackgroundVerticalPositionAdjustment(-100, for: .default)
                    item.setBackgroundVerticalPositionAdjustment(-100, for: .compact)
                    item.setBackgroundVerticalPositionAdjustment(-100, for: .compactPrompt)
                    item.setBackgroundVerticalPositionAdjustment(-100, for: .defaultPrompt)
                    item.setTitlePositionAdjustment(UIOffset(horizontal: 100, vertical: -10) , for: .default)
                    item.setTitlePositionAdjustment(UIOffset(horizontal: 100, vertical: -10) , for: .compact)
                    item.setTitlePositionAdjustment(UIOffset(horizontal: 100, vertical: -10) , for: .compactPrompt)
                    item.setTitlePositionAdjustment(UIOffset(horizontal: 100, vertical: -10) , for: .defaultPrompt)
                }
            }
            //barButton.imageInsets = UIEdgeInsetsMake(0.0, -20, 50, 0)
            //item.imageInsets = UIEdgeInsetsMake(0.0, -20, 50, 0)
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let newSize :CGSize = CGSize(width: UIScreen.main.bounds.width, height: 56)
        return newSize
    }
}
