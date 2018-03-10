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
    var callViewContainer:   IGTappableView?
    var returnToCall:        IGTappableView?
    var navigationController: IGNavigationController?
    private var centerViewMainLabel: UILabel?
    private var centerViewSubLabel:  UILabel?
    private var typingIndicatorView: IGDotActivityIndicator?
    var isUpdatingUserStatusForAction : Bool = false
    var isProccesing: Bool = true
    var hud = MBProgressHUD()
    
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
        returnToCallMethod()
    }
    
    //MARK: - Connecting
    func setNavigationItemForConnecting() {
        setNavigationItemWithCenterActivityIndicator(text: "Connecting")
    }
    
    func setNavigationItemForWaitingForNetwork() {
        setNavigationItemWithCenterActivityIndicator(text: "Waiting for network")
    }
    
    private func returnToCallMethod(){
        
        if !IGCall.callPageIsEnable {
            return
        }
        
        self.returnToCall = IGTappableView(frame: CGRect(x: 0, y: 0, width: 140, height: 35))
        self.titleView = self.returnToCall
        
        self.returnToCall?.backgroundColor = UIColor.returnToCall()
        self.returnToCall?.layer.cornerRadius = 15
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17.0, weight: UIFontWeightSemibold)
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.text = "Return To Call"
        self.titleView?.addSubview(label)
        
        self.titleView?.snp.makeConstraints { (make) in
            make.width.equalTo(150)
            make.height.equalTo(30)
        }

        label.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.titleView!.snp.centerX)
            make.centerY.equalTo(self.titleView!.snp.centerY)
        }
        
        self.returnToCall?.addAction {
            if IGCall.staticReturnToCall != nil {
                IGCall.staticReturnToCall.returnToCall()
            }
        }
    }
    
    private func setNavigationItemWithCenterActivityIndicator(text: String) {
        
        if IGCall.callPageIsEnable {
            return
        }
        
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
        let backArrowImageView = UIImageView(frame: CGRect(x: 5, y: 10, width: 25, height: 25))
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
    
    func addCallViewContainer(){
        let rightViewFrame = CGRect(x:0, y:0, width: 50, height:40)
        callViewContainer = IGTappableView(frame: rightViewFrame)
        callViewContainer!.backgroundColor = UIColor.clear
        let rightBarButton = UIBarButtonItem(customView: callViewContainer!)
        self.rightBarButtonItem = rightBarButton
        
        let composeButtonFrame = CGRect(x: 15, y: 2.5, width: 35, height: 35)
        let composeButtonImageView = UIImageView(frame: composeButtonFrame)
        composeButtonImageView.image = UIImage(named:"IG_Tabbar_Call_On")
        composeButtonImageView.tintColor = UIColor.organizationalColor()
        callViewContainer!.addSubview(composeButtonImageView)
    }
    
    private func addTitleLabel(title: String) {
        
        if IGCall.callPageIsEnable {
            return
        }
        
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
    
    public func addModalViewRightItem(title: String, iGapFont: Bool = false) {
        let rightViewFrame = CGRect(x:0, y:0, width: 50, height:40)
        rightViewContainer = IGTappableView(frame: rightViewFrame)
        rightViewContainer!.backgroundColor = UIColor.clear
        let rightBarButton = UIBarButtonItem(customView: rightViewContainer!)
        self.rightBarButtonItem = rightBarButton
        
        var labelFrame: CGRect!
        var label: UILabel!
        if iGapFont {
            labelFrame = CGRect(x: -5.0, y: 0, width: 50, height:40)
            label = UILabel(frame: labelFrame)
            label.font = UIFont.iGapFontico(ofSize: 20.0)
        } else {
            labelFrame = CGRect(x: -40, y: 0, width: 100, height:40)
            label = UILabel(frame: labelFrame)
        }
        label.textAlignment = .right
        label.text = title
        label.textColor = UIColor.white
        rightViewContainer!.addSubview(label)
    }
    
    private func addModalViewLeftItem(title: String) {
        let leftViewFrame = CGRect(x:0, y:0, width: 50, height:40)
        leftViewContainer = IGTappableView(frame: leftViewFrame)
        leftViewContainer!.backgroundColor = UIColor.clear
        let leftBarButton = UIBarButtonItem(customView: leftViewContainer!)
        self.leftBarButtonItem = leftBarButton
        
        let labelFrame = CGRect(x: -10, y: 4.5, width: 100, height:31)
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
        let settingViewFrame = CGRect(x: 3, y: 4.5, width: 31, height:31)
        let settingButtonImageView = UIImageView(frame: settingViewFrame)
        settingButtonImageView.image = UIImage(named:"IG_Nav_Bar_Menu")
        settingButtonImageView.tintColor = UIColor.organizationalColor()
        leftViewContainer!.addSubview(settingButtonImageView)
    }
    
    private func addComopseButton() {
        let composeButtonFrame = CGRect(x: 10, y: 7.5, width: 25, height: 25)
        let composeButtonImageView = UIImageView(frame: composeButtonFrame)
        composeButtonImageView.image = UIImage(named:"IG_Nav_Bar_Plus")
        composeButtonImageView.tintColor = UIColor.organizationalColor()
        rightViewContainer!.addSubview(composeButtonImageView)
    }
    
    private func addiGapLogo() {
        
        if IGCall.callPageIsEnable {
            return
        }
        
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
        
        if IGCall.callPageIsEnable || centerViewMainLabel == nil {
            return
        }
        
        self.centerViewMainLabel!.text = room.title
        
        if isCloud(room: room){
            return
        }
        
        if room.currenctActionsByUsers.count != 0 {
            if typingIndicatorView == nil {
                typingIndicatorView = IGDotActivityIndicator()
                self.centerViewContainer!.addSubview(typingIndicatorView!)
                typingIndicatorView!.snp.makeConstraints { (make) in
                    make.left.equalTo(self.centerViewSubLabel!.snp.right)
                    make.centerY.equalTo(self.centerViewSubLabel!.snp.centerY)
                    make.width.equalTo(40)
                }
            }
            
            self.centerViewSubLabel!.snp.remakeConstraints { (make) in
                make.top.equalTo(self.centerViewMainLabel!.snp.bottom).offset(3)
                make.leading.equalTo(self.centerViewContainer!.snp.leading).offset(5)
            }
            
            self.centerViewSubLabel!.text = room.currentActionString()
        } else {
            
            typingIndicatorView?.removeFromSuperview()
            typingIndicatorView = nil
            self.centerViewSubLabel!.snp.makeConstraints { (make) in
                make.top.equalTo(self.centerViewMainLabel!.snp.bottom).offset(3)
                make.leading.equalTo(self.centerViewContainer!.snp.leading).offset(5)
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
    
    private func initilizeNavigationBarForRoom(_ room: IGRoom) {}
    
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
        
        if IGCall.callPageIsEnable {
            return
        }
        
        var userId: Int64 = 0
        
        if let id = room.chatRoom?.peer?.id {
            userId = id
        }
        
        self.centerViewContainer?.subviews.forEach { $0.removeFromSuperview() }
        self.centerViewContainer = IGTappableView()
        let callView = IGTappableView()
        
        let titleContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 45))

        self.titleView = titleContainerView
        titleContainerView.addSubview(self.centerViewContainer!)
        titleContainerView.addSubview(callView)
        
        callView.snp.makeConstraints { (make) in
            make.top.equalTo(titleContainerView.snp.top)
            make.bottom.equalTo(titleContainerView.snp.bottom)
            make.trailing.equalTo(titleContainerView.snp.trailing)
            make.width.equalTo(50)
        }

        self.centerViewContainer?.snp.makeConstraints { (make) in
            make.top.equalTo(titleContainerView.snp.top)
            make.bottom.equalTo(titleContainerView.snp.bottom)
            make.leading.equalTo(titleContainerView.snp.leading)
            make.trailing.equalTo(callView.snp.leading)
        }
        
        if userId != 0 && userId != IGAppManager.sharedManager.userID() && !room.isReadOnly { // check isReadOnly for iGapMessanger
            let callViewLabel = UILabel()
            callViewLabel.textColor = UIColor.white
            callViewLabel.textAlignment = .center
            callViewLabel.font = UIFont.iGapFontico(ofSize: 18.0)
            callViewLabel.text = ""
            callView.addSubview(callViewLabel)
            callViewLabel.snp.makeConstraints { (make) in
                make.centerX.equalTo(callView.snp.centerX)
                make.centerY.equalTo(callView.snp.centerY)
            }
            
            callView.addAction {
                DispatchQueue.main.async {
                    (UIApplication.shared.delegate as! AppDelegate).showCallPage(userId: userId, isIncommmingCall: false)
                }
            }
        }
        
        self.centerViewMainLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 18))
        self.centerViewMainLabel!.text = room.title
        self.centerViewMainLabel!.textColor = UIColor.white
        self.centerViewMainLabel!.textAlignment = .center
        self.centerViewMainLabel!.font = UIFont.igFont(ofSize: 16.0, weight: .bold)//boldSystemFont(ofSize: 16)
        self.centerViewContainer!.addSubview(self.centerViewMainLabel!)
        self.centerViewMainLabel!.snp.makeConstraints { (make) in
            make.top.equalTo(self.centerViewContainer!.snp.top).offset(0)
            make.leading.equalTo(self.centerViewContainer!.snp.leading).offset(5).priority(.required)
            make.width.lessThanOrEqualToSuperview().offset(-25)
        }
        
        self.centerViewSubLabel = UILabel()//frame: CGRect(x: 0, y: 20, width: 200, height: 16))
        self.centerViewSubLabel!.textColor = UIColor.white
        self.centerViewSubLabel!.textAlignment = .center
        self.centerViewSubLabel!.font = UIFont.igFont(ofSize: 12.0, weight: .regular)//boldSystemFont(ofSize: 12)
        self.centerViewContainer!.addSubview(self.centerViewSubLabel!)
        self.centerViewSubLabel!.snp.makeConstraints { (make) in
            make.top.equalTo(self.centerViewMainLabel!.snp.bottom).offset(3)
            make.leading.equalTo(self.centerViewContainer!.snp.leading).offset(5)
        }
        
        if room.mute == .mute {
            let muteFrame = CGRect(x: 20, y: 5, width: 25, height: 25)
            let imgMute = UIImageView(frame: muteFrame)
            imgMute.image = UIImage(named:"IG_Chat_List_Mute")
            
            imgMute.image = imgMute.image!.withRenderingMode(.alwaysTemplate)
            imgMute.tintColor = UIColor.white
            
            self.centerViewContainer!.addSubview(imgMute)
            imgMute.snp.makeConstraints { (make) in
                make.top.equalTo(self.centerViewMainLabel!.snp.top).offset(3)
                make.right.equalTo(self.centerViewMainLabel!.snp.right).offset(20)
            }
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
        
        if isCloud(room: room){
            return
        }
        
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
    
    
    private func isCloud(room: IGRoom) -> Bool {
        if room.chatRoom?.peer?.id == IGAppManager.sharedManager.userID() {
            self.centerViewSubLabel!.text = "My Cloud"
            return true
        }
        return false
    }
    
}
