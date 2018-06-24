//
//  NotificationService.swift
//  Notification
//
//  Created by MacBook Pro on 6/23/18.
//  Copyright © 2018 RooyeKhat Media. All rights reserved.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        print("QQQ contentHandler: \(contentHandler)")
        print("QQQ request: \(request)")
        
        if let bestAttemptContent = bestAttemptContent {
            // Modify the notification content here...
            
            //bestAttemptContent.title = "New Value"
            //bestAttemptContent.body = "\(bestAttemptContent)"
            //bestAttemptContent.subtitle="x"
            
            print("QQQ bestAttemptContent: \(bestAttemptContent)")
            
            contentHandler(bestAttemptContent)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
