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

class ContactCell: AbstractCell {
    
    @IBOutlet var mainBubbleView: UIView!
    @IBOutlet weak var mainBubbleViewWidth: NSLayoutConstraint!
    
    var contactTop: Constraint!
    
    var nameLabel: UILabel?
    var phonesLabel: UILabel?
    var emailsLabel: UILabel?
    var avatarImageView: UIImageView?
    var phoneImageView: UIImageView?
    var emailImageView: UIImageView?
    
    class func nib() -> UINib {
        return UINib(nibName: "ContactCell", bundle: Bundle(for: self))
    }
    
    class func cellReuseIdentifier() -> String {
        return NSStringFromClass(self)
    }
    
    override func setMessage(_ message: IGRoomMessage, isIncommingMessage: Bool, shouldShowAvatar: Bool, messageSizes: RoomMessageCalculatedSize, isPreviousMessageFromSameSender: Bool, isNextMessageFromSameSender: Bool) {
        initializeView()
        super.setMessage(message, isIncommingMessage: isIncommingMessage, shouldShowAvatar: shouldShowAvatar, messageSizes: messageSizes, isPreviousMessageFromSameSender: isPreviousMessageFromSameSender, isNextMessageFromSameSender: isNextMessageFromSameSender)
        makeContact()
        setContact()
    }
    
    private func initializeView(){
        /********** view **********/
        mainBubbleViewAbs = mainBubbleView
        mainBubbleViewWidthAbs = mainBubbleViewWidth
    }
    
    private func hasEmail() -> Bool{
        return (finalRoomMessage.contact?.emails.count)! > 0
    }
    
    private func setContact(){
        
        let contact: IGRoomMessageContact = finalRoomMessage.contact!
        
        if isIncommingMessage {
            if hasEmail() {
                addEmailView()
                emailImageView?.image = UIImage(named: "IG_Message_Cell_Contact_Email_Incomming")
                emailsLabel?.textColor = UIColor(red: 106.0/255.0, green: 106.0/255.0, blue: 106.0/255.0, alpha: 1.0)
            } else {
                removeEmailView()
            }
            avatarImageView?.image = UIImage(named: "IG_Message_Cell_Contact_Generic_Avatar_Incomming")
            phoneImageView?.image = UIImage(named: "IG_Message_Cell_Contact_Phone_Incomming")
            nameLabel?.textColor = UIColor(red: 85.0/255.0, green: 85.0/255.0, blue: 85.0/255.0, alpha: 1.0)
            phonesLabel?.textColor = UIColor(red: 106.0/255.0, green: 106.0/255.0, blue: 106.0/255.0, alpha: 1.0)
        } else {
            if hasEmail() {
                addEmailView()
                emailImageView?.image = UIImage(named: "IG_Message_Cell_Contact_Email_Outgoing")
                emailsLabel?.textColor = UIColor(red: 106.0/255.0, green: 106.0/255.0, blue: 106.0/255.0, alpha: 1.0)
            } else {
                removeEmailView()
            }
            avatarImageView?.image = UIImage(named: "IG_Message_Cell_Contact_Generic_Avatar_Outgoing")
            phoneImageView?.image = UIImage(named: "IG_Message_Cell_Contact_Phone_Outgoing")
            nameLabel?.textColor = UIColor(red: 85.0/255.0, green: 85.0/255.0, blue: 85.0/255.0, alpha: 1.0)
            phonesLabel?.textColor = UIColor(red: 106.0/255.0, green: 106.0/255.0, blue: 106.0/255.0, alpha: 1.0)
        }
        
        let firstName = contact.firstName == nil ? "" : contact.firstName! + " "
        let lastName = contact.lastName == nil ? "" : contact.lastName!
        self.nameLabel?.text = String(format: "%@%@", firstName, lastName)
        
        self.phonesLabel!.text = ""
        for phone in contact.phones {
            self.phonesLabel!.text = self.phonesLabel!.text! + phone.innerString + "\n"
        }
        
        if hasEmail() {
            self.emailsLabel!.text = ""
            for email in contact.emails {
                self.emailsLabel!.text = self.emailsLabel!.text! + email.innerString + "\n"
            }
        }
    }
    
    private func makeContact(){
        if avatarImageView == nil {
            avatarImageView = UIImageView()
            mainBubbleViewAbs.addSubview(avatarImageView!)
        }
        
        if nameLabel == nil {
            nameLabel = UILabel()
            nameLabel!.font = UIFont.systemFont(ofSize: 14.0, weight: UIFontWeightSemibold)
            mainBubbleViewAbs.addSubview(nameLabel!)
        }
        
        if phonesLabel == nil {
            phonesLabel = UILabel()
            phonesLabel!.font = UIFont.systemFont(ofSize: 12.0, weight: UIFontWeightMedium)
            phonesLabel!.numberOfLines = 0
            mainBubbleViewAbs.addSubview(phonesLabel!)
        }
        
        if phoneImageView == nil {
            phoneImageView = UIImageView()
            phoneImageView!.contentMode = .scaleAspectFit
            mainBubbleViewAbs.addSubview(phoneImageView!)
        }
        
        avatarImageView!.snp.makeConstraints { (make) in
            
            if contactTop != nil { contactTop.deactivate() }
            
            if isForward {
                contactTop = make.top.equalTo(forwardViewAbs.snp.bottom).offset(8.0).constraint
            } else if isReply {
                contactTop = make.top.equalTo(replyViewAbs.snp.bottom).offset(8.0).constraint
            } else {
                contactTop = make.top.equalTo(mainBubbleViewAbs.snp.top).offset(8.0).constraint
            }
            
            if contactTop != nil { contactTop.activate() }
            
            make.leading.equalTo(mainBubbleViewAbs.snp.leading).offset(12.0)
            make.width.equalTo(42.0)
            make.height.equalTo(42.0)
        }
        
        nameLabel!.snp.makeConstraints { (make) in
            make.left.equalTo(avatarImageView!.snp.right).offset(10)
            make.top.equalTo(avatarImageView!.snp.top)
        }
        
        phonesLabel!.snp.makeConstraints { (make) in
            make.left.equalTo(avatarImageView!.snp.right).offset(22)
            make.top.equalTo(nameLabel!.snp.bottom).offset(2.0)
            make.right.equalTo(mainBubbleViewAbs.snp.right).offset(10)
        }
        
        phoneImageView!.snp.makeConstraints { (make) in
            make.left.equalTo(avatarImageView!.snp.right).offset(10)
            make.top.equalTo(phonesLabel!.snp.top).offset(4.0)
            make.width.equalTo(8.0)
            make.height.equalTo(8.0)
        }
    }
    
    private func addEmailView() {
        if emailImageView == nil {
            emailImageView = UIImageView()
            emailImageView!.contentMode = .scaleAspectFit
            mainBubbleViewAbs.addSubview(emailImageView!)
        }
        
        if emailsLabel == nil {
            emailsLabel = UILabel()
            emailsLabel!.font = UIFont.systemFont(ofSize: 12.0, weight: UIFontWeightMedium)
            emailsLabel!.numberOfLines = 0
            mainBubbleViewAbs.addSubview(emailsLabel!)
        }
        
        emailImageView!.snp.makeConstraints { (make) in
            make.left.equalTo(avatarImageView!.snp.right).offset(10)
            make.top.equalTo(phonesLabel!.snp.bottom).offset(-10)
            make.width.equalTo(8.0)
            make.height.equalTo(8.0)
        }
        
        emailsLabel!.snp.makeConstraints { (make) in
            make.left.equalTo(avatarImageView!.snp.right).offset(22)
            make.top.equalTo(emailImageView!.snp.top).offset(-4.0)
            make.right.equalTo(mainBubbleViewAbs.snp.right).offset(10)
        }
    }
    
    private func removeEmailView(){
        if emailsLabel != nil {
            emailsLabel?.removeFromSuperview()
            emailsLabel = nil
        }
        
        if emailImageView != nil {
            emailImageView?.removeFromSuperview()
            emailImageView = nil
        }
    }
}



