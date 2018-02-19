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
    var avatarImageView: UIImageView?
    var phoneImageView: UIImageView?
    
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
    
    private func setContact(){
        
        let contact: IGRoomMessageContact = finalRoomMessage.contact!
        
        if isIncommingMessage {
            avatarImageView?.image = UIImage(named: "IG_Message_Cell_Contact_Generic_Avatar_Incomming")
            phoneImageView?.image = UIImage(named: "IG_Message_Cell_Contact_Phone_Incomming")
            nameLabel?.textColor = UIColor(red: 85.0/255.0, green: 85.0/255.0, blue: 85.0/255.0, alpha: 1.0)
            phonesLabel?.textColor = UIColor(red: 106.0/255.0, green: 106.0/255.0, blue: 106.0/255.0, alpha: 1.0)
        } else {
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
}



