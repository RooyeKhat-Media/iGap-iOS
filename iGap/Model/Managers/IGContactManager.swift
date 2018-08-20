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
import Contacts
import IGProtoBuff

class IGContactManager: NSObject {
    static let sharedManager = IGContactManager()
    
    static var importedContact: Bool = false
    private var contactStore = CNContactStore()
    private var contacts = [IGContact]()
    private var contactsStruct = [ContactsStruct]()
    private var contactsStructChunk = [[ContactsStruct]]()
    private var contactIndex = 0
    private var CONTACT_IMPORT_LIMIT = 100
    private override init() {
        super.init()
    }
    
    struct ContactsStruct {
        var phoneNumber: String?
        var firstName: String?
        var lastName: String?
    }
    
    func manageContact() {
        if CNContactStore.authorizationStatus(for: CNEntityType.contacts) == CNAuthorizationStatus.authorized {
            savePhoneContactsToDatabase()
            sendContactsToServer()
        } else {
            getContactListFromServer()
        }
    }
    
    private func savePhoneContactsToDatabase() {
        
        let keys = [CNContactGivenNameKey,
                    CNContactMiddleNameKey,
                    CNContactFamilyNameKey,
                    CNContactEmailAddressesKey,
                    CNContactPhoneNumbersKey,
                    CNContactImageDataAvailableKey,
                    CNContactThumbnailImageDataKey]
        
        // Get all the containers
        var allContainers: [CNContainer] = []
        do {
            allContainers = try contactStore.containers(matching: nil)
        } catch {
            print("Error fetching containers")
        }
        
        var results: [CNContact] = []
        
        // Iterate all containers and append their contacts to our results array
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            
            do {
                let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keys as [CNKeyDescriptor])
                results.append(contentsOf: containerResults)
            } catch {
                print("Error fetching results for container")
            }
        }
        
        for contact in results {
            for phone in contact.phoneNumbers {
                contacts.append(IGContact(phoneNumber: phone.value.stringValue, firstName: contact.givenName, lastName: contact.familyName))
                
                var structContact = ContactsStruct()
                structContact.phoneNumber = phone.value.stringValue
                structContact.firstName = contact.givenName
                structContact.lastName = contact.familyName
                contactsStruct.append(structContact)
            }
        }
        
        IGFactory.shared.saveContactsToDatabase(contacts)
    }
    
   private func sendContactsToServer() {
        contactIndex = 0
        contactsStructChunk = contactsStruct.chunks(CONTACT_IMPORT_LIMIT)
        if contactsStructChunk.count == 0 {
            return
        }
        sendContact(phoneContacts: contactsStructChunk[0])
        contactIndex += 1
    }
    
    private func sendContact(phoneContacts : [ContactsStruct]){
        if IGContactManager.importedContact {
            return
        }
        IGContactManager.importedContact = true
        
        IGUserContactsImportRequest.Generator.generateStruct(contacts: phoneContacts).success ({ (protoResponse) in
            switch protoResponse {
            case let contactImportResponse as IGPUserContactsImportResponse:
                IGUserContactsImportRequest.Handler.interpret(response: contactImportResponse)
                if self.contactIndex < self.contactsStructChunk.count {
                    self.sendContact(phoneContacts: self.contactsStructChunk[self.contactIndex])
                }
                self.contactIndex += 1
                
                break
            default:
                break
            }
            self.getContactListFromServer()
        }).error ({ (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                IGContactManager.importedContact = false
                self.sendContactsToServer()
            default:
                break
            }
        }).send()
    }
    
    
    private func getContactListFromServer() {
        IGUserContactsGetListRequest.Generator.generate().success ({ (protoResponse) in
            switch protoResponse {
            case let contactGetListResponse as IGPUserContactsGetListResponse:
                IGUserContactsGetListRequest.Handler.interpret(response: contactGetListResponse)
                break
            default:
                break
            }
        }).error ({ (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                self.getContactListFromServer()
            default:
                break
            }
        }).send()
    }
}
