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
import RxSwift
import RealmSwift

class IGAttachmentManager: NSObject {
    static let sharedManager = IGAttachmentManager()
//    private var cache: NSCache<NSString, IGFile>
    private var variablesCache: NSCache<NSString, Variable<IGFile>>
    
    private override init() {
//        cache = NSCache()
//        cache.countLimit = 2000
//        cache.name = "im.igap.cache.IGAttachmentManager"
        
        variablesCache = NSCache()
        variablesCache.countLimit = 2000
        variablesCache.name = "im.igap.cache.IGAttachmentManager"
        
        super.init()
    }
    
    
    func add(attachmentRef: ThreadSafeReference<IGFile>) {
        let realm = try! Realm()
        guard let attachment = realm.resolve(attachmentRef) else {
            return // attachment was deleted
        }
        if let primaryKeyId = attachment.primaryKeyId {
            if attachment.status == .unknown {
                if attachment.fileNameOnDisk == nil {
                    attachment.downloadUploadPercent = 0.0
                    attachment.status = .readyToDownload
                } else {
                    attachment.downloadUploadPercent = 1.0
                    attachment.status = .ready
                }
            }
            if variablesCache.object(forKey: primaryKeyId as NSString) == nil {
                variablesCache.setObject(Variable(attachment), forKey: (attachment.primaryKeyId)! as NSString)
            } else {
                print ("found variablesCache \(primaryKeyId)")
            }
        }
    }
    
    func add(attachment: IGFile) {
        if let primaryKeyId = attachment.primaryKeyId {
            if attachment.status == .unknown {
                if attachment.fileNameOnDisk == nil {
                    attachment.downloadUploadPercent = 0.0
                    attachment.status = .readyToDownload
                } else {
                    attachment.downloadUploadPercent = 1.0
                    attachment.status = .ready
                }
            }
            if variablesCache.object(forKey: primaryKeyId as NSString) == nil {
                variablesCache.setObject(Variable(attachment), forKey: (attachment.primaryKeyId)! as NSString)
            } else {
                print ("found variablesCache \(primaryKeyId)")
            }
        }
    }
    
    func getRxVariable(attachmentPrimaryKeyId: String) -> Variable<IGFile>? {
        let file = variablesCache.object(forKey: attachmentPrimaryKeyId as NSString)
        return file
    }
    
    func setProgress(_ progress: Double, for attachment:IGFile) {
        if let variableInCache = variablesCache.object(forKey: attachment.primaryKeyId! as NSString) {
            let attachment = variableInCache.value
            attachment.downloadUploadPercent = progress
            variableInCache.value = attachment
        }
    }
    
    func setStatus(_ status: IGFile.Status, for attachment:IGFile) {
        if let variableInCache = variablesCache.object(forKey: attachment.primaryKeyId! as NSString) {
            let attachment = variableInCache.value
            attachment.status = status
            variableInCache.value = attachment
        }
    }
    
    func saveDataToDisk(attachment: IGFile) -> String? {
        if let writePath = attachment.path() {
            do {
                try attachment.data?.write(to: writePath)
                attachment.fileNameOnDisk = writePath.lastPathComponent
                return writePath.lastPathComponent
            } catch  {
                print("saving downloaded data to disk failed")
                return nil
            }
        }
        return nil
    }
    
    func appendDataToDisk(attachment: IGFile, data: Data) {
        if let outputStream = OutputStream(url: attachment.path()!, append: true) {
            outputStream.open()
            let bytesWritten = outputStream.write(data.bytes, maxLength: data.count)
            if bytesWritten < 0 {
                print("write failure")
            }
            outputStream.close()
        } else {
            print("unable to open file")
        }
    }
}
