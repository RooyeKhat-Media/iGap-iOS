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

class IGAvatarView: UIView {
    
    private var initialLettersView: UIView?
    private var initialLettersLabel: UILabel?
    var avatarImageView: IGImageView?
    private var gradient: CAGradientLayer?
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    
    private func configure() {
        self.layer.cornerRadius = self.frame.width / 2.0
        self.layer.masksToBounds = true
        
        let subViewsFrame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        self.subviews.forEach {
            $0.removeFromSuperview()
        }
        self.initialLettersView = UIView(frame: subViewsFrame)
        self.avatarImageView = IGImageView(frame: subViewsFrame)
        self.initialLettersLabel = UILabel(frame: subViewsFrame)
        
        self.avatarImageView?.contentMode = .scaleAspectFill
        
        self.addSubview(self.initialLettersView!)
        self.addSubview(self.initialLettersLabel!)
        self.addSubview(self.avatarImageView!)
        
        
        self.initialLettersLabel!.textColor = UIColor.white
        self.initialLettersLabel!.textAlignment = .center
        
        let gradientStartColor = UIColor(red: 139.0/255.0, green: 139.0/255.0, blue: 139.0/255.0, alpha: 1.0)
        self.gradient = CAGradientLayer()
        self.gradient!.frame = subViewsFrame
        self.gradient!.colors = [gradientStartColor.cgColor, UIColor.clear.cgColor]
        self.gradient!.startPoint = CGPoint(x: 1, y: 1)
        self.gradient!.endPoint = CGPoint(x: 0, y: 0)
        self.initialLettersView!.layer.insertSublayer(gradient!, at: 0)
        
        let avatarBorderColor = UIColor(red: 140.0/255.0, green: 140.0/255.0, blue: 140.0/255.0, alpha: 1.0)
        self.layer.borderWidth = 0.5
        self.layer.borderColor = avatarBorderColor.cgColor
    }
    
    
    // MARK: - Public Setters
    func clean() {
        self.avatarImageView!.image = nil
        self.initialLettersLabel!.text = ""
    }
    
    func setUser(_ user: IGRegisteredUser) {
        self.avatarImageView!.image = nil
        self.initialLettersLabel!.text = user.initials
        
        let color = UIColor(hexString: user.color)
        self.initialLettersView!.backgroundColor = color
        
        if let avatar = user.avatar {
            self.avatarImageView!.setImage(avatar: avatar)
        }
        
        if self.frame.size.width < 40 {
            self.initialLettersLabel!.font = UIFont.systemFont(ofSize: 10.0)
        } else if self.frame.size.width < 60 {
            self.initialLettersLabel!.font = UIFont.systemFont(ofSize: 14.0)
        }else {
            self.initialLettersLabel!.font = UIFont.systemFont(ofSize: 17.0)
        }
        
    }
    
    func setRoom(_ room: IGRoom) {
        self.avatarImageView!.image = nil
        self.initialLettersLabel!.text = room.initilas

        let color = UIColor(hexString: room.colorString)
        self.initialLettersView!.backgroundColor = color
        
        switch room.type {
        case .chat:
            if let avatar = room.chatRoom?.peer?.avatar {
                self.avatarImageView!.setImage(avatar: avatar)
                
            }
        case .group:
            if let avatar = room.groupRoom?.avatar {
                self.avatarImageView!.setImage(avatar: avatar)
            }
        case .channel:
            if let avatar = room.channelRoom?.avatar {
                self.avatarImageView!.setImage(avatar: avatar)
            }
        }

    }
    
    func setImage(_ image: UIImage) {
        self.avatarImageView!.image = image
    }
}
