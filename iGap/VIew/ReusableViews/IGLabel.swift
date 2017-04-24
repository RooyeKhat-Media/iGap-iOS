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
import SnapKit

class IGLabel: UIView {
    
    enum SupplementaryViewType {
        case none
        case typing
        case uploadingFile
    }
    
    enum ContentAlignment {
        case left
        case center
    }
    
    
    private var containerView = UIView()
    private var supplementaryView = UIView()
    private var label = UILabel()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    private func configure() {
        self.subviews.forEach{ $0.removeFromSuperview() }
        
        let subviewsFrames = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        containerView = UIView(frame: subviewsFrames)
        supplementaryView = UIView(frame: subviewsFrames)
        label = UILabel(frame: subviewsFrames)
    }
    
    func setText(_ text: String, type: SupplementaryViewType) {
        label.text = text
        label.textColor = UIColor.organizationalColor()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 12)
        
    }
    
    
}
