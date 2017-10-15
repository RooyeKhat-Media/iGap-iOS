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
import IGProtoBuff
import SwiftProtobuf

typealias UploadStartCallback    = (()->())?
typealias UploadProgressCallback = ((Progress)->())?
typealias UploadCompleteCallback = ((IGUploadTask)->())?
typealias UploadFailedCallback   = (()->())?


class IGUploadManager {
    static let sharedManager = IGUploadManager()
    fileprivate var uploadQueue: DispatchQueue
    private var pendingUploads = [IGUploadTask]()
    private var currentUploadingTask: IGUploadTask?
    
    //MARK - Class compressor
    class func compressVideo() {
        
    }
    
    class func compress(image: UIImage) -> UIImage {
        let scale: CGFloat = 0.5
        let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        
        
        UIGraphicsBeginImageContext(newSize)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
        
//        UIGraphicsBeginImageContext(newSize)
//        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
//        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
//        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return scaledImage!
    }

    
    //MARK: - Init
    private init() {
        uploadQueue = DispatchQueue(label: "im.igap.ios.queue.upload")
    }
    
    //MARK: - Public methods
    @discardableResult
    func upload(file: IGFile, start: UploadStartCallback, progress:UploadProgressCallback, completion:UploadCompleteCallback, failure:UploadFailedCallback) -> IGUploadTask{
        let uploadTask = IGUploadTask(file: file, start: start, progress: progress, completion: completion, failure: failure)
        performInUploadQueue {
            self.addToQueue(task: uploadTask)
        }
        
        return uploadTask
    }
    
    //MARK: - Private methods
    private func performInUploadQueue(execute work: @escaping @convention(block) () -> Swift.Void) {
        uploadQueue.async {
            work()
        }
    }
    
    private func addToQueue(task: IGUploadTask) {
        IGAttachmentManager.sharedManager.setProgress(0.0, for: task.file)
        IGAttachmentManager.sharedManager.setStatus(.processingForUpload, for: task.file)
        pendingUploads.append(task)
        startNextTaskIfPossible()
    }
    
    private func removeFromQueueAndStartNext(task: IGUploadTask) {
        if let index = pendingUploads.index(of: task) {
            pendingUploads.remove(at: index)
            performInUploadQueue {
                self.startNextTaskIfPossible()
            }
        }
    }
    
    // MARK: Upload next
    private func startNextTaskIfPossible() {
        if let task = pendingUploads.first {
            if task.status == .waiting {
                task.loadDataAndCalculateHash()
                getUploadOptions(for: task)
            }
        }
    }
    
    
    //Step 1: Get Upload options (initil bytes limit, final bytes limit, max connection)
    private func getUploadOptions(for task: IGUploadTask) {
        DispatchQueue.main.async {
            if let startClousure = task.startCallBack {
                startClousure()
            }
        }
        IGFileUploadOptionRequest.Generator.generate(size: Int64((task.file.data!.count))).success { (protoMessage) in
            switch protoMessage {
            case let fileUploadOptionReponse as IGPFileUploadOptionResponse:
                task.status = .uploading
                let response = IGFileUploadOptionRequest.Handler.interpret(response: fileUploadOptionReponse)
                task.initialBytesLimit = response.initialBytesLimit
                task.finalBytesLimit = response.finalBytesLimit
                self.initializeUplaod(for: task)
            default:
                break
            }
        }.error({ (errorCode, waitTime) in
            task.status = .failed
            self.removeFromQueueAndStartNext(task: task)
            DispatchQueue.main.async {
                if let failureClosure = task.failureCallBack {
                    failureClosure()
                }
            }
        }).send()
    }
    
    //Step 2: Initilize Upload
    private func initializeUplaod(for task: IGUploadTask) {
        let fileData = NSData(data: task.file.data!)
        let initialBytes = fileData.subdata(with: NSMakeRange(0, Int(task.finalBytesLimit!)))
        let size = Int(task.file.data!.count)
        let finalBytes = fileData.subdata(with: NSMakeRange(size - Int(task.finalBytesLimit!), Int(task.finalBytesLimit!)))
        let reqW = IGFileUploadInitRequest.Generator.generate(initialBytes: initialBytes,
                                                              finalBytes: finalBytes ,
                                                              size: Int64(task.file.data!.count),
                                                              hash: task.file.sha256Hash!,
                                                              name: task.file.name!)
        reqW.success { (protoMessage) in
            switch protoMessage {
            case let fileUploadInitReponse as IGPFileUploadInitResponse:
                let response = IGFileUploadInitRequest.Handler.interpret(response: fileUploadInitReponse)
                task.token = response.token
                task.file.token = response.token
                task.progress = response.progress
                IGAttachmentManager.sharedManager.setProgress(response.progress / 100.0, for: task.file)
                IGAttachmentManager.sharedManager.setStatus(.uploading, for: task.file)
                if response.progress == 100 {
                    self.checkStatus(for: task)
                } else {
                    self.uploadAChunk(task: task, offset: response.offset, limit: response.limit)
                }
                print("IGPFileUploadInitResponse \(task.progress)")
            default:
                break
            }
        }.error({ (errorCode, waitTime) in
            task.status = .failed
            self.removeFromQueueAndStartNext(task: task)
            DispatchQueue.main.async {
                if let failureClosure = task.failureCallBack {
                    failureClosure()
                }
            }
        }).send()
    }
    
    //Step 3: Upload a chunk of file (repeat this step until finish)
    private func uploadAChunk(task: IGUploadTask, offset: Int64, limit: Int32) {
        let fileData = NSData(data: task.file.data!)
        let bytes = fileData.subdata(with: NSMakeRange(Int(offset), Int(limit)))
        IGFileUploadRequest.Generator.generate(token: task.token!, offset: offset, data: bytes).success { (protoMessage) in
            switch protoMessage {
            case let fileUploadReponse as IGPFileUploadResponse:
                let response = IGFileUploadRequest.Handler.interpret(response: fileUploadReponse)
                let progress = response.progress
                IGAttachmentManager.sharedManager.setProgress(response.progress / 100.0, for: task.file)
                IGAttachmentManager.sharedManager.setStatus(.uploading, for: task.file)
                if (progress == 100) {
                    //check for status
                    self.checkStatus(for: task)
                } else {
                    //upload another chunk
                    self.uploadAChunk(task: task, offset: response.nextOffset, limit: response.nextLimit)
                }
            default:
                break
            }
        }.error({ (errorCode, waitTime) in
            task.status = .failed
            self.removeFromQueueAndStartNext(task: task)
            DispatchQueue.main.async {
                if let failureClosure = task.failureCallBack {
                    failureClosure()
                }
            }
        }).send()
    }
    
    private func uploadNextChunk(task: IGUploadTask, data: NSData, offset: Int64, limit: Int32) {
        
    }
    
    //Step 4: Check for file state
    private func checkStatus(for task: IGUploadTask) {
        IGFileUploadStatusRequest.Generator.generate(token: task.token!).success { (protoMessage) in
            switch protoMessage {
            case let fileUploadStatusResponse as IGPFileUploadStatusResponse:
                let response = IGFileUploadStatusRequest.Handler.interpret(response: fileUploadStatusResponse)
                let retryDelay = response.retryDelay
                let deadlineTime = DispatchTime.now() + Double(retryDelay)/1000.0
                let progress = response.progress
                IGAttachmentManager.sharedManager.setProgress(response.progress / 100.0, for: task.file)
                IGAttachmentManager.sharedManager.setStatus(.uploading, for: task.file)
                DispatchQueue.main.async {
                    if let progress = task.progressCallBack {
                        //progress(progress)
                    }
                }
                switch response.status {
                case .uploading:
                    if progress == 100 {
                        //check again after retry delay
                        self.uploadQueue.asyncAfter(deadline: deadlineTime, execute: {
                            self.checkStatus(for: task)
                        })
                    } else {
                        self.initializeUplaod(for: task)
                    }
                case .processing:
                    //check again after retry delay
                    self.uploadQueue.asyncAfter(deadline: deadlineTime, execute: {
                        self.checkStatus(for: task)
                    })
                    break
                case .processed:
                    //get file info
                    self.getFileInfo(task: task)
                    break
                default:
                    break
                }
            default:
                break
            }
        }.error({ (errorCode, waitTime) in
            task.status = .failed
            self.removeFromQueueAndStartNext(task: task)
            DispatchQueue.main.async {
                if let failureClosure = task.failureCallBack {
                    failureClosure()
                }
            }
        }).send()
    }
    
    //Step 5: get file info (to get cache id)
    private func getFileInfo(task: IGUploadTask) {
        IGFileInfoRequest.Generator.generate(token: task.token!).success { (protoMessage) in
            switch protoMessage {
            case let fileInfoReponse as IGPFileInfoResponse:
                //update file in db
                IGFactory.shared.updateFileInDatabe(task.file, with: fileInfoReponse.igpFile)
                IGAttachmentManager.sharedManager.setProgress(100.0, for: task.file)
                IGAttachmentManager.sharedManager.setStatus(.ready, for: task.file)
                //finish task
                task.status = .finished
                self.removeFromQueueAndStartNext(task: task)
                DispatchQueue.main.async {
                    if let completeClosure = task.successCallBack {
                        completeClosure(task)
                    }
                }
                
            default:
                break
            }
        }.error({ (errorCode, waitTime) in
            task.status = .failed
            self.removeFromQueueAndStartNext(task: task)
            DispatchQueue.main.async {
                if let failureClosure = task.failureCallBack {
                    failureClosure()
                }
            }
        }).send()
    }
}


class IGUploadTask: NSObject{
    enum Status {
        case waiting
        case uploading
        case finished
        case failed
    }
    
    var status = Status.waiting
    var file:IGFile
    var token: String?
    var progress: Double = 0
    var initialBytesLimit : Int32?
    var finalBytesLimit : Int32?
    
    var startCallBack   : UploadStartCallback
    var progressCallBack: UploadProgressCallback
    var successCallBack : UploadCompleteCallback
    var failureCallBack : UploadFailedCallback
    fileprivate init(file:IGFile, start: UploadStartCallback, progress:UploadProgressCallback, completion:UploadCompleteCallback, failure:UploadFailedCallback) {
        //make a copy of file = the file object passed here is a
        //`Realm` object and cannot be accessed form this thread
        self.file = IGFile()
        self.file.cacheID = file.cacheID
        self.file.primaryKeyId = file.primaryKeyId
        self.file.token = file.token
        self.file.size = file.size
        self.file.name = file.name
        self.file.data = file.data
        self.file.type = file.type
        self.file.fileNameOnDisk = file.fileNameOnDisk
        self.file.attachedImage  = file.attachedImage
        self.startCallBack    = start
        self.progressCallBack = progress
        self.successCallBack  = completion
        self.failureCallBack  = failure
        super.init()
    }
    
    fileprivate func loadDataAndCalculateHash() {
        self.file.loadData()
        self.file.calculateHash()
    }
}

func == (lhs: IGUploadTask, rhs: IGUploadTask) -> Bool {
    if (lhs.file == rhs.file) {
        return true
    }
    return false
}

