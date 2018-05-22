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
import CryptoSwift
import UIKit
import IGProtoBuff

class IGFileManager {
    
}

class IGFile: Object {
    enum Status {
        case unknown
        
        case readyToDownload
        case downloading
        case processingAfterDownload
        case downloadFailed
        
        case processingForUpload
        case uploading
        case waitingForServerProcess
        case uploadFailed
        
        case ready
    }
    
    enum PlayingStatus {
        case notAvaiable
        case readyToPlay
        case playing
        case paused
    }
    
    enum PreviewType: Int {
        case originalFile = 0
        case smallThumbnail
        case largeThumbnail
        case waveformThumbnail
    }
    
    enum FileType: Int {
        case image = 0
        case gif
        case video
        case audio
        case voice
//        case pdf
//        case document
        case file
    }
    
    enum FileTypeBasedOnNameExtension {
        case generic
        case docx
        case exe
        case pdf
        case txt
    }
    
    
    //properties
    @objc dynamic var primaryKeyId:       String?   //if incomming { primaryKeyId = cacheId } else { primaryKeyId = rand}
    @objc dynamic var cacheID:            String?   //set by server
    @objc dynamic var token:              String?
    @objc dynamic var fileNameOnDisk:     String?
    @objc dynamic var name:               String?
    @objc dynamic var smallThumbnail:     IGFile?
    @objc dynamic var largeThumbnail:     IGFile?
    @objc dynamic var waveformThumbnail:  IGFile?
    @objc dynamic var size:               Int                     = -1     //TODO: change to Int64
    @objc dynamic var width:              Double                  =  0.0
    @objc dynamic var height:             Double                  =  0.0
    @objc dynamic var duration:           Double                  =  0.0
    //@objc dynamic var roomIDs:            [Int64]                 = [-1]
    @objc dynamic var typeRaw:            FileType.RawValue       = FileType.file.rawValue
    @objc dynamic var previewTypeRaw:     PreviewType.RawValue    = PreviewType.originalFile.rawValue
    //ignored properties
    var attachedImage:  UIImage?
    var data:           Data?
    var sha256Hash:     Data?
    var status:         Status                              = .unknown
    var playingStatus:  PlayingStatus                       = .notAvaiable
    var downloadUploadPercent: Double                       = 0.0
    var fileTypeBasedOnNameExtension: FileTypeBasedOnNameExtension {
        get {
            if let name = self.name {
                let fileExtension = (name as NSString).lastPathComponent
                switch fileExtension {
                case "docx":
                    return .docx
                case "exe":
                    return .exe
                case "pdf":
                    return .pdf
                case "txt":
                    return .txt
                default:
                    return .generic
                }
            }
            return .generic
        }
    }
    
    var previewType: PreviewType {
        get {
            if let a = PreviewType(rawValue: previewTypeRaw) {
                return a
            }
            return .originalFile
        }
        set {
            previewTypeRaw = newValue.rawValue
        }
    }
    var type: FileType {
        get {
            if let a = FileType(rawValue: typeRaw) {
                return a
            }
            return .file
        }
        set {
            typeRaw = newValue.rawValue
        }
    }

    override static func indexedProperties() -> [String] {
        return ["cacheID"]
    }
    
    override static func primaryKey() -> String {
        return "primaryKeyId"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["previewType", "type", "attachedImage", "data", "sha256Hash", "status", "playingStatus", "downloadUploadPercent", "fileTypeBasedOnNameExtention"]
    }
    
    convenience init(name: String?) {
        self.init()
        self.name = name
        self.primaryKeyId = IGGlobal.randomString(length: 64)
    }
    
    convenience init(path: URL) {
        self.init()
        self.fileNameOnDisk = path.lastPathComponent
        self.name = path.lastPathComponent
        self.primaryKeyId = IGGlobal.randomString(length: 64)
    }
    
//    convenience init(path: String, name: String, cacheID: String?, token: String = "") {
//        self.init()
//        self.fileNameOnDisk = path.lastPathComponent
//        self.name = name
//        self.cacheID = cacheID
//        self.token = token
//    }
    
    convenience init(igpFile : IGPFile, type: IGFile.FileType) {
        self.init()
        self.token = igpFile.igpToken
        self.name = igpFile.igpName
        self.size = Int(igpFile.igpSize)
        self.cacheID = igpFile.igpCacheID
        self.primaryKeyId = igpFile.igpCacheID
        self.previewType = .originalFile
        self.type = type
        
        
//        if igpFile.hasIgpWidth {}
        self.width = Double(igpFile.igpWidth)
//        if igpFile.hasIgpHeight {}
        self.height = Double(igpFile.igpHeight)
//        if igpFile.hasIgpDuration {}
        self.duration = igpFile.igpDuration
        
        if igpFile.hasIgpSmallThumbnail {
            let predicate = NSPredicate(format: "cacheID = %@", igpFile.igpSmallThumbnail.igpCacheID)
            let realm = try! Realm()
            if let fileInDb = realm.objects(IGFile.self).filter(predicate).first {
                self.smallThumbnail = fileInDb
            } else {
                self.smallThumbnail = IGFile(igpThumbnail: igpFile.igpSmallThumbnail, previewType: .smallThumbnail, token:self.token)
            }
        }
        if igpFile.hasIgpLargeThumbnail {
            let predicate = NSPredicate(format: "cacheID = %@", igpFile.igpLargeThumbnail.igpCacheID)
            let realm = try! Realm()
            if let fileInDb = realm.objects(IGFile.self).filter(predicate).first {
                self.largeThumbnail = fileInDb
            } else {
                self.largeThumbnail = IGFile(igpThumbnail: igpFile.igpLargeThumbnail, previewType: .largeThumbnail, token:self.token)
            }
        }
        if igpFile.hasIgpWaveformThumbnail {
            self.waveformThumbnail = IGFile(igpThumbnail: igpFile.igpWaveformThumbnail, previewType: .waveformThumbnail, token:self.token)
        }
    }
    
    convenience init(igpFile : IGPFile, messageType: IGRoomMessageType) {
        var fileType = IGFile.FileType.file
        
        switch messageType {
        case .audio, .audioAndText:
            fileType = .audio
        case .image, .imageAndText:
            fileType = .image
        case .video, .videoAndText:
            fileType = .video
        case .voice:
            fileType = .voice
        case .gif,.gifAndText:
            fileType = .gif
        default:
            fileType = .file
            break
        }
        
        self.init(igpFile : igpFile, type: fileType)
    }
    
    convenience private init(igpThumbnail: IGPThumbnail, previewType: IGFile.PreviewType, token: String?) {
        self.init()
        self.token = token
        self.size = Int(igpThumbnail.igpSize)
        self.width = Double(igpThumbnail.igpWidth)
        self.height = Double(igpThumbnail.igpHeight)
        self.previewType = previewType
        self.type = .image
        self.cacheID = igpThumbnail.igpCacheID
        self.primaryKeyId = igpThumbnail.igpCacheID
        self.name = cacheID
    }
    
    //detach from current realm
    func detach() -> IGFile {
        let detachedFile = IGFile(value: self)
        
        if let smallThumbnail = self.smallThumbnail {
            let detachedThumbnail = smallThumbnail.detach()
            detachedFile.smallThumbnail = detachedThumbnail
        }
        if let largeThumbnail = self.largeThumbnail {
            let detachedThumbnail = largeThumbnail.detach()
            detachedFile.largeThumbnail = detachedThumbnail
        }
        if let waveformThumbnail = self.waveformThumbnail {
            let detachedThumbnail = waveformThumbnail.detach()
            detachedFile.waveformThumbnail = detachedThumbnail
        }
        
        return detachedFile
    }
    
    
    //other fuctions
    public func loadData() {
        if self.data != nil {
            return
        } else if let filePath = self.path() {
            try? self.data = Data(contentsOf: filePath)
        } else if self.attachedImage != nil {
            self.data = UIImageJPEGRepresentation(self.attachedImage!, 0.7)
        } else {
            //assert(self.data == nil, "file data did not load")
        }
    }
    
    public func calculateHash() {
        if self.data != nil {
            self.sha256Hash = self.sha256(data: data!)
        }
    }
    
    private func sha256(data : Data) -> Data {
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0, CC_LONG(data.count), &hash)
        }
        return Data(bytes: hash)
    }
    
    public func sizeToString() -> String {
        let sizeInByte = self.size
        if sizeInByte == 0 {
            return ""
        } else if sizeInByte < 1024 {
            return "\(sizeInByte) B"
        } else if sizeInByte < 1048576 {
            let size: Double = Double(sizeInByte) / 1024.0
            return String(format: "%.2f KB", size)
        } else if sizeInByte < 1073741824 {
            let size: Double = Double(sizeInByte) / 1048576.0
            return String(format: "%.2f MB", size)
        } else {
            let size: Double = Double(sizeInByte) / 1073741824.0
            return String(format: "%.2f GB", size)
        }
    }
    
    public func path() -> URL? {
        let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        if let fileNameOnDisk = self.fileNameOnDisk {
            return NSURL(fileURLWithPath: documents).appendingPathComponent(fileNameOnDisk)
        } else if let cacheId = self.cacheID, let name = self.name {
            var path = NSURL(fileURLWithPath: documents).appendingPathComponent(cacheId + name)
            if name.getExtension() == "mp3" || name.getExtension() == "ogg" {
                path = path?.deletingPathExtension().appendingPathExtension("m4a")
            }
            return path
        }
        return nil
    }
    
    class func path(fileNameOnDisk: String) -> URL {
        let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return NSURL(fileURLWithPath: documents).appendingPathComponent(fileNameOnDisk)!
    }
}


func == (lhs: IGFile, rhs: IGFile) -> Bool {
    if lhs === rhs {
        return true
    }
    if lhs.cacheID == rhs.cacheID {
        return true
    }
    if (lhs.sha256Hash != nil) && (rhs.sha256Hash != nil) && (lhs.sha256Hash == rhs.sha256Hash) {
        return true
    }
    return false
}


