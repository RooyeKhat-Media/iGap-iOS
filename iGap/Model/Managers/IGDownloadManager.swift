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
import SwiftProtobuf
import IGProtoBuff
import Digger

typealias DownloadCompleteHandler = ((_ attachment:IGFile)->())?
typealias DownloadFailedHander    = (()->())?


class IGDownloadManager {
    
    //MARK: Initilizers
    static let sharedManager = IGDownloadManager()
    static let defaultChunkSizeForDownload:Int32 = 102400 //1048576 // 1024x1024
    internal static var downloadMap : [String:IGFile] = [:]
    
    private var downloadQueue:  DispatchQueue
    private var thumbnailQueue: DispatchQueue
    
    private var downloadTasks  = [IGDownloadTask]()
    private var thumbnailTasks = [IGDownloadTask]()
    
    private static var downloadTask: IGDownloadTask!
    
    
    init() {
        downloadQueue  = DispatchQueue(label: "im.igap.ios.queue.download.attachments")
        thumbnailQueue = DispatchQueue(label: "im.igap.ios.queue.download.thumbnail")
    }
    
    
    func download(file: IGFile, previewType: IGFile.PreviewType, completion:DownloadCompleteHandler, failure:DownloadFailedHander) {
        
        let downloadTask = IGDownloadTask(file: file, previewType:previewType, completion:completion, failure:failure)
        
        switch previewType {
        case .originalFile:
            downloadQueue.async {
                self.addToDownloadQueue(downloadTask)
            }
        case .smallThumbnail, .largeThumbnail, .waveformThumbnail:
            thumbnailQueue.async {
                self.addToThumbnailQueue(downloadTask)
            }
        }
    }
    
    //MARK: Private methods
    private func addToDownloadQueue(_ task: IGDownloadTask) {
        IGAttachmentManager.sharedManager.setProgress(0.0, for: task.file)
        IGAttachmentManager.sharedManager.setStatus(.downloading, for: task.file)
        downloadTasks.append(task)
        startNextDownloadTaskIfPossible()
    }
    
    private func addToThumbnailQueue(_ task: IGDownloadTask) {
        IGAttachmentManager.sharedManager.setProgress(0.0, for: task.file)
        IGAttachmentManager.sharedManager.setStatus(.downloading, for: task.file)
        thumbnailTasks.append(task)
        startNextThumbnailTaskIfPossible()
    }
    
    private func startNextDownloadTaskIfPossible() {
        if downloadTasks.count > 0 && IGAppManager.sharedManager.isUserLoggiedIn(){
            let firstTaskInQueue = downloadTasks[0]
            if firstTaskInQueue.state == .pending {
                
                if firstTaskInQueue.file.publicUrl != nil && !(firstTaskInQueue.file.publicUrl?.isEmpty)! {
                    downloadCDN(task: firstTaskInQueue)
                } else {
                    downloadProto(task: firstTaskInQueue)
                }
                
            }else if firstTaskInQueue.state == .finished {
                downloadTasks.remove(at: 0)
                startNextDownloadTaskIfPossible()
            }
        }
    }
    
    private func startNextThumbnailTaskIfPossible() {
        if thumbnailTasks.count > 0 && IGAppManager.sharedManager.isUserLoggiedIn(){
            let firstTaskInQueue = thumbnailTasks[0]
            if firstTaskInQueue.state == .pending {
                downloadProto(task: firstTaskInQueue)
            }else if firstTaskInQueue.state == .finished {
                thumbnailTasks.remove(at: 0)
                startNextThumbnailTaskIfPossible()
            }
        }
    }
    
    private func downloadCDN(task downloadTask:IGDownloadTask) {
        
        IGDownloadManager.downloadTask = downloadTask
        let url = downloadTask.file.publicUrl
        
        if  url != nil && !(url?.isEmpty)! {
            
            print("BBB || Start download CDN")
            
            Digger.download(url!).progress({ (progresss) in
                
                print("BBB || percent is \(progresss.fractionCompleted*100)")
                IGAttachmentManager.sharedManager.setProgress(progresss.fractionCompleted, for: downloadTask.file)
                
            }).completion { (result) in
                
                
                switch result {
                case .success(let url):
                    
                    print("BBB || Download Finished :) ")
                    
                    do {
                        let fileManager = FileManager.default
                        let content = try Data(contentsOf: url)
                        fileManager.createFile(atPath: (downloadTask.file.path()?.path)!, contents: content, attributes: nil)
                        
                        IGAttachmentManager.sharedManager.setStatus(.ready, for: downloadTask.file)
                        IGFactory.shared.addNameOnDiskToFile(downloadTask.file, name: (downloadTask.file.path()?.lastPathComponent)!)
                        downloadTask.state = .finished
                        if let success = downloadTask.completionHandler {
                            success(downloadTask.file)
                        }
                        
                    } catch {
                        print("BBB || Error :( ")
                    }
                    
                case .failure(let error):
                    
                    print("BBB || Failure :( => \(error)")
                    
                    IGAttachmentManager.sharedManager.setProgress(0.0, for: downloadTask.file)
                    IGAttachmentManager.sharedManager.setStatus(.readyToDownload, for: downloadTask.file)
                    switch downloadTask.type {
                    case .originalFile:
                        self.startNextDownloadTaskIfPossible()
                    case .smallThumbnail, .largeThumbnail, .waveformThumbnail:
                        self.startNextThumbnailTaskIfPossible()
                    }
                }
                
            }
        }
    }
    
    internal static func pauseCDN(token: String){
        if let file = IGDownloadManager.downloadMap[token] {
            DiggerManager.shared.stopTask(for: file.publicUrl!)
        }
        
        IGAttachmentManager.sharedManager.setProgress(0.0, for: downloadTask.file)
        IGAttachmentManager.sharedManager.setStatus(.downloadFailed, for: downloadTask.file)
        IGDownloadManager.downloadMap.removeValue(forKey: token)
    }
    
    private func downloadProto(task downloadTask:IGDownloadTask) {
        
        downloadTask.state = .downloading
        
        print("downloaded so far: \((downloadTask.file.data?.count)!)")
        print("should download: \(downloadTask.file.size)")
        let reqW = IGFileDownloadRequest.Generator.generate(token: downloadTask.file.token!,
                                                            offset: Int64((downloadTask.file.data?.count)!),
                                                            maxChunkSize: IGDownloadManager.defaultChunkSizeForDownload,
                                                            type: downloadTask.type)
        
        reqW.success { (responseProto) in
            switch responseProto {
            case let fileDownloadReponse as IGPFileDownloadResponse:
                let data = IGFileDownloadRequest.Handler.interpret(response: fileDownloadReponse)
                downloadTask.file.data!.append(data)
                
                print("got \(data.count) bytes")
                
                if downloadTask.file.data?.count != downloadTask.file.size {
                    let progress = Progress()
                    progress.totalUnitCount = Int64(downloadTask.file.size)
                    progress.completedUnitCount =  Int64((downloadTask.file.data?.count)!)
                    IGAttachmentManager.sharedManager.setProgress(progress.fractionCompleted, for: downloadTask.file)
                    IGDownloadManager.sharedManager.downloadProto(task: downloadTask)
                } else {
                    print("finished downloading")
                    IGAttachmentManager.sharedManager.setProgress(1.0, for: downloadTask.file)
                    if let fileNameOnDisk = IGAttachmentManager.sharedManager.saveDataToDisk(attachment: downloadTask.file) {
                        print("TTT filename on disk : \(fileNameOnDisk)")
                        IGAttachmentManager.sharedManager.setStatus(.ready, for: downloadTask.file)
                        IGFactory.shared.addNameOnDiskToFile(downloadTask.file, name: fileNameOnDisk)
                        downloadTask.state = .finished
                        if let success = downloadTask.completionHandler {
                            success(downloadTask.file)
                        }
                        switch downloadTask.type {
                        case .originalFile:
                            self.startNextDownloadTaskIfPossible()
                        case .smallThumbnail, .largeThumbnail, .waveformThumbnail:
                            self.startNextThumbnailTaskIfPossible()
                        }
                    } else {
                        //failed saving to disk
                        reqW.error!(.unknownError, nil)
                        IGAttachmentManager.sharedManager.setProgress(0.0, for: downloadTask.file)
                        IGAttachmentManager.sharedManager.setStatus(.readyToDownload, for: downloadTask.file)
                    }
                }
                break
            default:
                break
            }
            }.error({ (errorCode, waitTime) in
                IGAttachmentManager.sharedManager.setProgress(0.0, for: downloadTask.file)
                IGAttachmentManager.sharedManager.setStatus(.readyToDownload, for: downloadTask.file)
                switch downloadTask.type {
                case .originalFile:
                    self.startNextDownloadTaskIfPossible()
                case .smallThumbnail, .largeThumbnail, .waveformThumbnail:
                    self.startNextThumbnailTaskIfPossible()
                }
            }).send()
    }
    
    private func pauseProto(){
        
    }
}


//MARK: - IGDownloadTask
class IGDownloadTask {
    enum State {
        case pending
        case downloading
        case finished
    }
    
    var file: IGFile
    var progress: Double = 0.0
    var completionHandler: DownloadCompleteHandler
    var failureHandler: DownloadFailedHander
    var type: IGFile.PreviewType
    var state = State.pending
    
    init(file: IGFile, previewType: IGFile.PreviewType, completion: DownloadCompleteHandler, failure: DownloadFailedHander) {
        //make a copy of file = the file object passed here is a
        //`Realm` object and cannot be accessed form this thread
        self.file = IGFile()
        self.file.cacheID = file.cacheID
        self.file.primaryKeyId = file.primaryKeyId
        self.file.token = file.token
        self.file.publicUrl = file.publicUrl
        self.file.size = file.size
        self.file.name = file.name
        self.file.data = Data()
        
        self.completionHandler = completion
        self.failureHandler = failure
        self.type = previewType
    }
}



