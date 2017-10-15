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
import MBProgressHUD


class IGNavigationItem: UINavigationItem {
    
    var rightViewContainer:  IGTappableView?
    var centerViewContainer: IGTappableView?
    var leftViewContainer:   IGTappableView?
    var backViewContainer:   IGTappableView?
    var navigationController: IGNavigationController?
    private var centerViewMainLabel: UILabel?
    private var centerViewSubLabel:  UILabel?
    private var typingIndicatorView: IGDotActivityIndicator?
    var isUpdatingUserStatusForAction : Bool = false
    var isProccesing: Bool = true
    var hud = MBProgressHUD()
//    var centerViewSubText:   UITextField?
    
    private var tapOnRightView:  (()->())?
    private var tapOncenterView: (()->())?
    private var tapOnLeftView:   (()->())?
    private var tapOnBackView:   (()->())?
    
    //MARK: - Initilizers
    override init(title: String) {
        super.init(title: title)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    func configure() {
        let rightViewFrame = CGRect(x:0, y:0, width: 40, height:40)
        rightViewContainer = IGTappableView(frame: rightViewFrame)
        rightViewContainer!.backgroundColor = UIColor.clear
        let rightBarButton = UIBarButtonItem(customView: rightViewContainer!)
        self.rightBarButtonItem = rightBarButton
    }
    
    //MARK: - Connecting
    func setNavigationItemForConnecting() {
        setNavigationItemWithCenterActivityIndicator(text: "Connecting")
    }
    
    func setNavigationItemForWaitingForNetwork() {
        setNavigationItemWithCenterActivityIndicator(text: "Waiting for network")
    }

    
    private func setNavigationItemWithCenterActivityIndicator(text: String) {
        self.centerViewContainer?.subviews.forEach { $0.removeFromSuperview() }
        self.centerViewContainer?.removeFromSuperview()
        self.centerViewContainer = IGTappableView(frame: CGRect(x: 0, y: 0, width: 200, height: 45))
        
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17.0, weight: UIFontWeightSemibold)
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.text = text
        centerViewContainer?.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.centerViewContainer!.snp.centerX).offset(14)
            make.centerY.equalTo(self.centerViewContainer!.snp.centerY).offset(-5)
        }
        
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .white)
        centerViewContainer?.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        activityIndicatorView.snp.makeConstraints { (make) in
            make.right.equalTo(label.snp.left).offset(-4)
            make.centerY.equalTo(self.centerViewContainer!.snp.centerY).offset(-5)
            make.width.equalTo(20.0)
            make.height.equalTo(20.0)
        }
        
        self.titleView = centerViewContainer
    
    }
    
    
    //MARK: - Navigation VCs
    func addNavigationViewItems(rightItemText: String?, title: String?) {
        if title != nil {
            addTitleLabel(title: title!)
        }
        if rightItemText != nil {
            addModalViewRightItem(title: rightItemText!)
        }
        addNavigationBackItem()
    }
    
    func addNavigationBackItem() {
        //self.hidesBackButton = true
        let backViewFrame = CGRect(x:0, y:0, width: 50, height:50)
        backViewContainer = IGTappableView(frame: backViewFrame)
        backViewContainer!.backgroundColor = UIColor.clear
        let backArrowImageView = UIImageView(frame: CGRect(x: -10, y: 10, width: 25, height: 25))
        backArrowImageView.image = UIImage(named: "IG_Nav_Bar_BackButton")
        backViewContainer?.addSubview(backArrowImageView)
        let backBarButton = UIBarButtonItem(customView: backViewContainer!)
        self.leftBarButtonItem = backBarButton
        self.title = ""
        backViewContainer?.addAction {
            self.backViewContainer?.isUserInteractionEnabled = false
           _ = self.navigationController?.popViewController(animated: true)
        }        
    }
    
    //MARK: - Modal VCs
    func addModalViewItems(leftItemText: String?, rightItemText: String?, title: String?) {
        self.hidesBackButton = true
        if title != nil {
            addTitleLabel(title: title!)
        }
        if rightItemText != nil{
            addModalViewRightItem(title: rightItemText!)
        }
        if leftItemText != nil{
            addModalViewLeftItem(title: leftItemText!)
        }
    }
    
    private func addTitleLabel(title: String) {
        let height = self.navigationController?.navigationBar.frame.height
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 40))
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 40))
        label.font = UIFont.systemFont(ofSize: 17.0, weight: UIFontWeightBold)
        label.textAlignment = .center
        label.text = title
        label.textColor = UIColor.white
        
        titleView.addSubview(label)
        self.titleView = titleView
    }
    
    private func addModalViewRightItem(title: String) {
        let rightViewFrame = CGRect(x:0, y:0, width: 50, height:40)
        rightViewContainer = IGTappableView(frame: rightViewFrame)
        rightViewContainer!.backgroundColor = UIColor.clear
        let rightBarButton = UIBarButtonItem(customView: rightViewContainer!)
        self.rightBarButtonItem = rightBarButton
        
        let labelFrame = CGRect(x: -40, y: 0, width: 100, height:40)
        let label = UILabel(frame: labelFrame)
        label.textAlignment = .right
        label.text = title
        label.textColor = UIColor.white
        rightViewContainer!.addSubview(label)
    }
    
    private func addModalViewLeftItem(title: String) {
        let leftViewFrame = CGRect(x:0, y:0, width: 50, height:80)
        leftViewContainer = IGTappableView(frame: leftViewFrame)
        leftViewContainer!.backgroundColor = UIColor.clear
        let leftBarButton = UIBarButtonItem(customView: leftViewContainer!)
        self.leftBarButtonItem = leftBarButton
        
        let labelFrame = CGRect(x: -10, y: 20, width: 100, height:31)
        let label = UILabel(frame: labelFrame)
        label.text = title
        label.textColor = UIColor.white
        leftViewContainer!.addSubview(label)
    }
    
    //MARK: - Chat List
    func setChatListsNavigationItems() {
        addSettingButton()
        addComopseButton()
        addiGapLogo()
    }
    
    private func addSettingButton() {
        let leftViewFrame = CGRect(x:0, y:0, width: 50, height:40)
        leftViewContainer = IGTappableView(frame: leftViewFrame)
        leftViewContainer!.backgroundColor = UIColor.clear
        let leftBarButton = UIBarButtonItem(customView: leftViewContainer!)
        self.leftBarButtonItem = leftBarButton
        let settingViewFrame = CGRect(x: -10, y: 5, width: 31, height:31)
        let settingButtonImageView = UIImageView(frame: settingViewFrame)
        settingButtonImageView.image = UIImage(named:"IG_Nav_Bar_Menu")
        settingButtonImageView.tintColor = UIColor.organizationalColor()
        leftViewContainer!.addSubview(settingButtonImageView)
    }
    
    private func addComopseButton() {
        let composeButtonFrame = CGRect(x: 20, y: 5, width: 31, height:31)
        let composeButtonImageView = UIImageView(frame: composeButtonFrame)
        composeButtonImageView.image = UIImage(named:"IG_Nav_Bar_Compose")
        composeButtonImageView.tintColor = UIColor.organizationalColor()
        rightViewContainer!.addSubview(composeButtonImageView)
    }
    
    private func addiGapLogo() {
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: 67, height: 40))
        let logoImageView = UIImageView(frame: CGRect(x: 0, y: 8, width: 67, height: 23))
        logoImageView.image = UIImage(named: "IG_Nav_Bar_Logo")
        logoImageView.contentMode = .scaleAspectFit
        
        titleView.addSubview(logoImageView)
        self.titleView = titleView
    }
    
    //MARK: - Messages View
    func setNavigationBarForRoom(_ room: IGRoom) {
        setRoomAvatar(room)
        setRoomInfo(room)
        addNavigationBackItem()
    }
    
    func updateNavigationBarForRoom(_ room: IGRoom) {
        self.centerViewMainLabel!.text = room.title
        if room.chatRoom?.peer?.id == IGAppManager.sharedManager.userID() {
            //my cloud
            self.centerViewSubLabel!.text = "My Cloud"
            return
        }
        
        if room.currenctActionsByUsers.count != 0 {
            if typingIndicatorView == nil {
                typingIndicatorView = IGDotActivityIndicator()
                self.centerViewContainer!.addSubview(typingIndicatorView!)
                typingIndicatorView!.snp.makeConstraints { (make) in
                    make.right.equalTo(self.centerViewSubLabel!.snp.left)
                    make.centerY.equalTo(self.centerViewSubLabel!.snp.centerY)
                    make.width.equalTo(40)
                }
            }
            
            
            self.centerViewSubLabel!.snp.remakeConstraints { (make) in
                make.top.equalTo(self.centerViewMainLabel!.snp.bottom).offset(3)
                make.centerX.equalTo(self.centerViewContainer!.snp.centerX).offset(20)
            }
                
            self.centerViewSubLabel!.text = room.currentActionString()
        } else {
            
            typingIndicatorView?.removeFromSuperview()
            typingIndicatorView = nil
            self.centerViewSubLabel!.snp.makeConstraints { (make) in
                make.top.equalTo(self.centerViewMainLabel!.snp.bottom).offset(3)
                make.centerX.equalTo(self.centerViewContainer!.snp.centerX)
            }
            if let peer = room.chatRoom?.peer {
                if room.currenctActionsByUsers.first?.value.1 != .typing {
                setLastSeenLabelForUser(peer, room: room)
                }
            } else if let groupRoom = room.groupRoom {
                    
                self.centerViewSubLabel!.text = "\(groupRoom.participantCount) member\(groupRoom.participantCount>1 ? "s" : "")"
            } else if let channelRoom = room.channelRoom {
                self.centerViewSubLabel!.text = "\(channelRoom.participantCount) member\(channelRoom.participantCount>1 ? "s" : "")"
            }
        }
    }
    
    private func initilizeNavigationBarForRoom(_ room: IGRoom) {
        
        
    }
    
    private func setRoomAvatar(_ room: IGRoom) {
        let avatarViewFrame = CGRect(x: 0, y: 0, width: 40, height:40)
        
        let avatarView = IGAvatarView(frame: avatarViewFrame)
        avatarView.setRoom(room)
        rightViewContainer!.addSubview(avatarView)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            self.setRoomAvatar(room)
        }

    }
    
    private func setRoomInfo(_ room: IGRoom) {
        self.centerViewContainer?.subviews.forEach { $0.removeFromSuperview() }
        
        self.centerViewContainer = IGTappableView(frame: CGRect(x: 0, y: 0, width: 200, height: 45))
        
        self.titleView = self.centerViewContainer
//        if (UIScreen.main.bounds.width) == 320.0 {
//            self.centerViewMainLabel = UILabel(frame: CGRect(x: -10, y: 0, width: 200, height: 18))
//        } else {
//            self.centerViewMainLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 18))
//        }
        self.centerViewMainLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 18))
        self.centerViewMainLabel!.text = room.title
        self.centerViewMainLabel!.textColor = UIColor.white
        self.centerViewMainLabel!.textAlignment = .center
        self.centerViewMainLabel!.font = UIFont.igFont(ofSize: 16.0, weight: .bold)//boldSystemFont(ofSize: 16)
        self.centerViewContainer!.addSubview(self.centerViewMainLabel!)
        
        self.centerViewSubLabel = UILabel()//frame: CGRect(x: 0, y: 20, width: 200, height: 16))
        self.centerViewSubLabel!.textColor = UIColor.white
        self.centerViewSubLabel!.textAlignment = .center
        self.centerViewSubLabel!.font = UIFont.igFont(ofSize: 12.0, weight: .regular)//boldSystemFont(ofSize: 12)
        self.centerViewContainer!.addSubview(self.centerViewSubLabel!)
        self.centerViewSubLabel!.snp.makeConstraints { (make) in
            make.top.equalTo(self.centerViewMainLabel!.snp.bottom).offset(3)
            make.centerX.equalTo(self.centerViewContainer!.snp.centerX)
        }
        
        if let peer = room.chatRoom?.peer {
            if room.currenctActionsByUsers.first?.value.1 != .typing {
                setLastSeenLabelForUser(peer , room: room)
            }
        } else if let groupRoom = room.groupRoom {
            self.centerViewSubLabel!.text = "\(groupRoom.participantCount) member\(groupRoom.participantCount>1 ? "s" : "")"
        } else if let channelRoom = room.channelRoom {
            self.centerViewSubLabel!.text = "\(channelRoom.participantCount) member\(channelRoom.participantCount>1 ? "s" : "")"
        }

    }
    
    private func setLastSeenLabelForUser(_ user: IGRegisteredUser , room : IGRoom) {
        if room.currenctActionsByUsers.first?.value.1 != .typing && typingIndicatorView == nil {
        switch user.lastSeenStatus {
        case .longTimeAgo:
            self.centerViewSubLabel!.text = "A long time ago"
            break
        case .lastMonth:
            self.centerViewSubLabel!.text = "Last month"
            break
        case .lastWeek:
            self.centerViewSubLabel!.text = "Last week"
            break
        case .online:
            
            self.centerViewSubLabel!.text = "Online"
            
            break
        case .exactly:
            self.centerViewSubLabel!.text = "\(user.lastSeen!.humanReadableForLastSeen())"
            break
        case .recently:
            self.centerViewSubLabel!.text = "A few seconds ago"
            break
        case .support:
            self.centerViewSubLabel!.text = "iGap Support"
            break
        case .serviceNotification:
            self.centerViewSubLabel!.text = "Service Notification"
            break
        }
          
            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                self.setLastSeenLabelForUser(user , room: room)
            }
        }
    }
    
        
    
    
}
