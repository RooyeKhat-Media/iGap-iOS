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

class IGNavigationController: UINavigationController ,UINavigationBarDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addShadowToBar()
        self.navigationBar.topItem?.backBarButtonItem?.setTitlePositionAdjustment(UIOffset(horizontal: 0, vertical: 50), for: UIBarMetrics.default)
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        return super.popViewController(animated: animated)
    }
    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        return super.popToRootViewController(animated: animated)
    }
    
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    
    override func viewDidAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .default
        //        self.navigationBar.topItem?.backBarButtonItem?.backButtonTitlePositionAdjustment(for: UIBarMetrics.compactPrompt)
        //        self.navigationBar.topItem?.backBarButtonItem?.backButtonBackgroundVerticalPositionAdjustment(for: UIBarMetrics.compactPrompt)
        //        self.navigationBar.backItem.
        let cancelBtn = UIButton()
        cancelBtn.frame = CGRect(x: 8, y: 0, width: 60, height: 60)
        cancelBtn.backgroundColor = UIColor.yellow
        let topLeftbarButtonItem = UIBarButtonItem(customView: cancelBtn)
        self.navigationBar.topItem?.backBarButtonItem = topLeftbarButtonItem
    }
    
    
    func addShadowToBar() {
        self.navigationBar.layer.shadowColor = UIColor.darkGray.cgColor
        self.navigationBar.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        self.navigationBar.layer.shadowRadius = 4.0
        self.navigationBar.layer.shadowOpacity = 0.35
    }
    
    func setRightBarButtonItem(rightBarButton : UIButton, rightBarButtonImage:UIImage?=nil){
//        if rightBarButtonImage != nil {
//            rightBarButton.setImage(rightBarButtonImage, for: UIControlState.normal)
//            //set frame
            rightBarButton.frame = CGRect(x:0,y: 0,width: 40, height:40)
            roundUserImage(rightBarButton)
//        }else{
//            rightBarButton.setTitle("Done", for: .normal)
//            rightBarButton.setTitleColor(UIColor.red, for: .normal)
//            rightBarButton.frame = CGRect(x:0,y: 0,width: 60, height:60)
//        }
        let barButton = UIBarButtonItem(customView: rightBarButton)
        self.navigationBar.topItem?.rightBarButtonItem = barButton
    }
    
    
    func roundUserImage(_ Button:UIButton){
        Button.layer.borderWidth = 0
        Button.layer.masksToBounds = true
        let borderUserImageColor = UIColor.organizationalColor()
        Button.layer.borderColor = borderUserImageColor.cgColor
        Button.layer.cornerRadius = Button.frame.size.height/2
        Button.clipsToBounds = true
    }
    
    func setTitleView(_ titleView : UIView){
        titleView.backgroundColor = UIColor.yellow
        self.navigationItem.titleView = titleView
        self.navigationBar.topItem?.titleView = titleView
        
        
    }
    
    
    func setCenterView() {
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 45))
        let nameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 21))
        nameLabel.text = "John Smith"
        nameLabel.textAlignment = .center
        nameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        let lastSeenStatusLabel = UILabel(frame: CGRect(x: 0, y: 22, width: 150, height: 21))
        lastSeenStatusLabel.text = "Online"
        lastSeenStatusLabel.textColor = UIColor.organizationalColor()
        lastSeenStatusLabel.textAlignment = .center
        lastSeenStatusLabel.font = UIFont.boldSystemFont(ofSize: 9)
        titleView.addSubview(nameLabel)
        titleView.addSubview(lastSeenStatusLabel)
        self.navigationBar.topItem?.titleView = titleView
    }
    
    func getHightOfNavigationBar()->(CGFloat) {
        let navBarHeight = self.navigationBar.frame.size.height
        return navBarHeight
    }
    
    func connectingTitleView() {
        let connectingTitleView = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 30))
        let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        connectingTitleView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        let textLabel = UILabel(frame: CGRect(x: 30, y: 5, width: 100, height: 21))
        textLabel.text = "Connecting.."
        textLabel.textColor = UIColor.black
        connectingTitleView.addSubview(textLabel)
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        self.navigationBar.topItem?.titleView = connectingTitleView
        
    }
    func updatingTitleView(){
        let updatingTitleView = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 30))
        let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        updatingTitleView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        let textLabel = UILabel(frame: CGRect(x: 30, y: 5, width: 100, height: 21))
        textLabel.text = "Updating.."
        textLabel.textColor = UIColor.black
        updatingTitleView.addSubview(textLabel)
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        self.navigationBar.topItem?.titleView = updatingTitleView
    }

    
    func isTyping(){
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 45))
        let nameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 21))
        nameLabel.text = "John Smith"
        nameLabel.textAlignment = .center
        nameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        let dotsLoader = IGDotActivityIndicator(frame: CGRect(x: 0, y: 0, width: 40, height: 21))
        let isTyping = UITextField(frame: CGRect(x: 20, y: 22, width: 150, height: 21))
        isTyping.text = "is typing"
        isTyping.font = UIFont.systemFont(ofSize: 14)
        //isTyping.textAlignment = .center
        isTyping.leftView = dotsLoader
        isTyping.leftViewMode = UITextFieldViewMode.always
        isTyping.textColor = UIColor.organizationalColor()
        isTyping.isUserInteractionEnabled = false
        titleView.addSubview(nameLabel)
        //titleView.addSubview(dotsLoader)
        titleView.addSubview(isTyping)
        self.navigationBar.topItem?.titleView = titleView
        
        
    }
}
