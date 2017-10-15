/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the RooyeKhat Media Company - www.RooyeKhat.co
 * All rights reserved.
 */

import RealmSwift
import Foundation
import IGProtoBuff

class IGRoomMessageContact: Object {
    @objc dynamic var id:         String?
    @objc dynamic var firstName:  String?
    @objc dynamic var lastName:   String?
    @objc dynamic var nickname:   String?
    let phones:     List<IGRealmString>    = List<IGRealmString>()
    let emails:     List<IGRealmString>    = List<IGRealmString>()
    
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    convenience init(igpRoomMessageContact: IGPRoomMessageContact, for message: IGRoomMessage) {
        self.init()
        self.id = message.primaryKeyId
        
        if igpRoomMessageContact.igpFirstName != "" {
            self.firstName = igpRoomMessageContact.igpFirstName
        }
        if igpRoomMessageContact.igpLastName != "" {
            self.lastName = igpRoomMessageContact.igpLastName
        }
        if igpRoomMessageContact.igpNickname != "" {
            self.nickname = igpRoomMessageContact.igpNickname
        }
        for phone in igpRoomMessageContact.igpPhone {
            let predicate = NSPredicate(format: "innerString = %@", phone)
            let realm = try! Realm()
            if let phoneInDb = realm.objects(IGRealmString.self).filter(predicate).first {
                self.phones.append(phoneInDb)
            } else {
                let phoneString = IGRealmString(string: phone)
                self.phones.append(phoneString)
            }
        }
        for email in igpRoomMessageContact.igpEmail {
            let predicate = NSPredicate(format: "innerString = %@", email)
            let realm = try! Realm()
            if let emailInDb = realm.objects(IGRealmString.self).filter(predicate).first {
                self.emails.append(emailInDb)
            } else {
                let emailString = IGRealmString(string: email)
                self.emails.append(emailString)
            }
        }
    }
    
    convenience init(message: IGRoomMessage, firstName: String?, lastName: String?, phones: [String]?, emails:[String]?) {
        self.init()
        self.id = message.primaryKeyId
        self.firstName = firstName
        self.lastName = lastName
        
        phones?.forEach{
            let predicate = NSPredicate(format: "innerString = %@", $0)
            let realm = try! Realm()
            if let phoneInDb = realm.objects(IGRealmString.self).filter(predicate).first {
                self.phones.append(phoneInDb)
            } else {
                let phoneString = IGRealmString(string: $0)
                self.phones.append(phoneString)
            }
        }
        
        
        emails?.forEach{
            let predicate = NSPredicate(format: "innerString = %@", $0)
            let realm = try! Realm()
            if let emailInDb = realm.objects(IGRealmString.self).filter(predicate).first {
                self.emails.append(emailInDb)
            } else {
                let emailString = IGRealmString(string: $0)
                self.emails.append(emailString)
            }
        }
    }
    
    
    
    //detach from current realm
    func detach() -> IGRoomMessageContact {
        let detachedRoomMessageContact = IGRoomMessageContact(value: self)
//        let phones = List<IGRealmString>(value: self.phones)
//            let detachedPhones = phones
//            //detachedRoomMessageLog.targetUser = detachedUser
//        }
        return detachedRoomMessageContact
    }
    
}
