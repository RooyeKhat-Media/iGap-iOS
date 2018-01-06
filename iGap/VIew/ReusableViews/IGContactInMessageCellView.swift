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

class IGContactInMessageCellView: UIView {
    
    var nameLabel: UILabel?
    var phonesLabel: UILabel?
    var emailsLabel: UILabel?
    var avatarImageView: UIImageView?
    var phoneImageView: UIImageView?
    var emailImageView: UIImageView?
    
    //MARK: Class Methods
    class func sizeForContact(_ contact: IGRoomMessageContact) -> CGSize {
        let numberOfInfos = contact.emails.count + contact.phones.count
        let height = numberOfInfos * 15 + 20
        let width = 200
        return CGSize(width: width, height: height)
    }
    
    //MARK: Instance Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    
    func configure() {
        avatarImageView = UIImageView()
        self.addSubview(avatarImageView!)
        avatarImageView!.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.left).offset(12.0)
            make.top.equalTo(self.snp.top).offset(8.0)
            make.width.equalTo(42.0)
            make.height.equalTo(42.0)
        }
        
        nameLabel = UILabel()
        nameLabel!.font = UIFont.systemFont(ofSize: 14.0, weight: UIFontWeightSemibold)
        self.addSubview(nameLabel!)
        nameLabel!.snp.makeConstraints { (make) in
            make.left.equalTo(avatarImageView!.snp.right).offset(10)
            make.top.equalTo(self.snp.top).offset(10.0)
        }

        phonesLabel = UILabel()
        phonesLabel!.font = UIFont.systemFont(ofSize: 12.0, weight: UIFontWeightMedium)
        phonesLabel!.numberOfLines = 0
        self.addSubview(phonesLabel!)
        phonesLabel!.snp.makeConstraints { (make) in
            make.left.equalTo(avatarImageView!.snp.right).offset(22)
            make.top.equalTo(nameLabel!.snp.bottom).offset(2.0)
            make.right.equalTo(self.snp.right).offset(10)
        }
        
        phoneImageView = UIImageView()
        phoneImageView!.contentMode = .scaleAspectFit
        self.addSubview(phoneImageView!)
        phoneImageView!.snp.makeConstraints { (make) in
            make.left.equalTo(avatarImageView!.snp.right).offset(10)
            make.top.equalTo(phonesLabel!.snp.top).offset(4.0)
            make.width.equalTo(8.0)
            make.height.equalTo(8.0)
        }

        
        
//        emailsLabel = UILabel()
//        emailsLabel!.font = UIFont.systemFont(ofSize: 12.0, weight: UIFontWeightMedium)
//        emailsLabel!.numberOfLines = 0
//        self.addSubview(emailsLabel!)
//        emailsLabel!.snp.makeConstraints { (make) in
//            make.left.equalTo(avatarImageView!.snp.right).offset(22)
//            make.top.equalTo(phonesLabel!.snp.bottom).offset(-12.0)
//            make.right.equalTo(self.snp.right).offset(10)
//        }
//
//        emailImageView = UIImageView()
//        emailImageView!.contentMode = .scaleAspectFit
//        self.addSubview(emailImageView!)
//        emailImageView!.snp.makeConstraints { (make) in
//            make.left.equalTo(avatarImageView!.snp.right).offset(10)
//            make.top.equalTo(emailsLabel!.snp.top).offset(4.0)
//            make.width.equalTo(8.0)
//            make.height.equalTo(8.0)
//        }
    }
    
    
    func setContact(_ conatct: IGRoomMessageContact, isIncommingMessage: Bool) {
        if isIncommingMessage {
            avatarImageView?.image = UIImage(named: "IG_Message_Cell_Contact_Generic_Avatar_Incomming")
            phoneImageView?.image = UIImage(named: "IG_Message_Cell_Contact_Phone_Incomming")
            //emailImageView?.image = UIImage(named: "IG_Message_Cell_Contact_Email_Incomming")
            nameLabel?.textColor = UIColor(red: 85.0/255.0, green: 85.0/255.0, blue: 85.0/255.0, alpha: 1.0)
            phonesLabel?.textColor = UIColor(red: 106.0/255.0, green: 106.0/255.0, blue: 106.0/255.0, alpha: 1.0)
            //emailsLabel?.textColor = UIColor(red: 106.0/255.0, green: 106.0/255.0, blue: 106.0/255.0, alpha: 1.0)
        } else {
            avatarImageView?.image = UIImage(named: "IG_Message_Cell_Contact_Generic_Avatar_Outgoing")
            phoneImageView?.image = UIImage(named: "IG_Message_Cell_Contact_Phone_Outgoing")
            //emailImageView?.image = UIImage(named: "IG_Message_Cell_Contact_Email_Outgoing")
            nameLabel?.textColor = UIColor(red: 85.0/255.0, green: 85.0/255.0, blue: 85.0/255.0, alpha: 1.0)
            phonesLabel?.textColor = UIColor(red: 106.0/255.0, green: 106.0/255.0, blue: 106.0/255.0, alpha: 1.0)
            //emailsLabel?.textColor = UIColor(red: 239.0/255.0, green: 239.0/255.0, blue: 239.0/255.0, alpha: 1.0)
        }
        
        let firstName = conatct.firstName == nil ? "" : conatct.firstName! + " "
        let lastName = conatct.lastName == nil ? "" : conatct.lastName!
        self.nameLabel?.text = String(format: "%@%@", firstName, lastName)
        
        self.phonesLabel!.text = ""
        for phone in conatct.phones {
            self.phonesLabel!.text = self.phonesLabel!.text! + phone.innerString + "\n"
        }
        if conatct.phones.count == 0 {
            phoneImageView?.image = nil
        }
//        self.emailsLabel!.text = ""
//        for email in conatct.emails {
//            self.emailsLabel!.text = self.emailsLabel!.text! + email.innerString + "\n"
//        }
//        if conatct.emails.count == 0 {
//            emailImageView?.image = nil
//        }
    }

}
