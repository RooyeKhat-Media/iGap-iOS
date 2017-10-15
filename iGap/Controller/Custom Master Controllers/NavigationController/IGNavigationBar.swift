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
        self.tintColor = UIColor.white
        self.isTranslucent = false
        //self.barStyle = .black
        self.barTintColor = UIColor.organizationalColor()
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
        
//        super.layoutSubviews()
//
//        frame = CGRect(x: frame.origin.x, y:  0, width: frame.size.width, height: 56.0)
//
//        // title position (statusbar height / 2)
//        setTitleVerticalPositionAdjustment(-10, for: UIBarMetrics.default)
//
//        for subview in self.subviews {
//            var stringFromClass = NSStringFromClass(subview.classForCoder)
//            if stringFromClass.contains("BarBackground") {
//                subview.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 56.0)
//                subview.backgroundColor = .yellow
//
//            }
//
//            stringFromClass = NSStringFromClass(subview.classForCoder)
//            if stringFromClass.contains("BarContent") {
//
//                subview.frame = CGRect(x: subview.frame.origin.x, y: 20, width: subview.frame.width, height: 56.0)
//
//                subview.backgroundColor = UIColor(red: 20/255, green: 20/255, blue: 20/255, alpha: 0.4)
//
//            }
//        }
    }
    
//    override func sizeThatFits(_ size: CGSize) -> CGSize {
//        let newSize :CGSize = CGSize(width: UIScreen.main.bounds.width, height: 156)
//        return newSize
//    }
}
