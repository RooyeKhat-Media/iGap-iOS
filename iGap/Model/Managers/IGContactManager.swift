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
    private var contactStore = CNContactStore()
    private var contacts = [IGContact]()
    private override init() {
        super.init()
    }
    
    func savePhoneContactsToDatabase() {
        
//        self.contactStore.requestAccessForEntityType(CNEntityType.Contacts, completionHandler: { (access, accessError) -> Void in
//            if access {
//                completionHandler(accessGranted: access)
//            }
//            else {
//                if authorizationStatus == CNAuthorizationStatus.Denied {
//                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                        let message = "\(accessError!.localizedDescription)\n\nPlease allow the app to access your contacts through the Settings."
//                        self.showMessage(message)
//                    })
//                }
//            }
//        })
        
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
            }
        }
        
        IGFactory.shared.saveContactsToDatabase(contacts)
    }
    
    
    
    func sendContactsToServer() {
        IGUserContactsImportRequest.Generator.generate(contacts: contacts).success { (protoResponse) in
            switch protoResponse {
            case let contactImportResponse as IGPUserContactsImportResponse:
                IGUserContactsImportRequest.Handler.interpret(response: contactImportResponse)
                break
            default:
                break
            }
            self.getContactListFromServer()
        }.error { (errorCode, waitTime) in

        }.send()
    }
    
    
    
    func getContactListFromServer() {
        IGUserContactsGetListRequest.Generator.generate().success { (protoResponse) in
            switch protoResponse {
            case let contactGetListResponse as IGPUserContactsGetListResponse:
                IGUserContactsGetListRequest.Handler.interpret(response: contactGetListResponse)
                break
            default:
                break
            }
        }.error { (errorCode, waitTime) in
            
        }.send()
    }
    
}
