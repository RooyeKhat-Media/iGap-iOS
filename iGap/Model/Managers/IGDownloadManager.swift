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
    
    private var downloadQueue:  DispatchQueue
    private var thumbnailQueue: DispatchQueue
    
    private var thumbnailTasks = [IGDownloadTask]()
    
    var taskQueueTokenArray : [String] = []
    var dictionaryDownloadTaskMain : [String:IGDownloadTask] = [:]
    var dictionaryDownloadTaskQueue : [String:IGDownloadTask] = [:]
    var dictionaryPauseTask : [String:IGDownloadTask] = [:]
    let DOWNLOAD_LIMIT = 2
    
    
    init() {
        downloadQueue  = DispatchQueue(label: "im.igap.ios.queue.download.attachments")
        thumbnailQueue = DispatchQueue(label: "im.igap.ios.queue.download.thumbnail")
    }
    
    func isDownloading(token: String) -> Bool {
        return (dictionaryDownloadTaskMain[token] != nil || dictionaryDownloadTaskQueue[token] != nil)
    }
    
    func hasDownload() -> Bool {
        return dictionaryDownloadTaskMain.count > 0
    }
    
    func manageDownloadAfterLogin() {
        
        // Auto Retry Downloads
//        dictionaryPauseTask.removeAll()
//        for downloadTask in dictionaryDownloadTaskMain.values {
//            dictionaryDownloadTaskMain.removeValue(forKey: downloadTask.file.token!)
//            manageDownloadQueue(downloadTask)
//        }
        
        
        // Fiale All Downloads
        // Hint : Detect when internet lost, then failed all download tasks
        for downloadTask in dictionaryDownloadTaskMain.values {
            pauseDownload(attachment: downloadTask.file)
        }

        for downloadTask in dictionaryDownloadTaskQueue.values {
            pauseDownload(attachment: downloadTask.file)
        }

        dictionaryPauseTask.removeAll()
    }
    
    func download(file: IGFile, previewType: IGFile.PreviewType, completion:DownloadCompleteHandler, failure:DownloadFailedHander) {
        print("XXXS || Manage Download ;) || Main List Size : \(self.dictionaryDownloadTaskMain.count) || Queue List Size : \(self.dictionaryDownloadTaskQueue.count) || Token Array Size : \(self.taskQueueTokenArray.count)")
        let downloadTask = IGDownloadTask(file: file, previewType:previewType, completion:completion, failure:failure)
        
        switch previewType {
        case .originalFile:
            downloadQueue.async {
                self.manageDownloadQueue(downloadTask)
            }
        case .smallThumbnail, .largeThumbnail, .waveformThumbnail:
            thumbnailQueue.async {
                self.addToThumbnailQueue(downloadTask)
            }
        }
    }
    
    //MARK: Private methods
    private func manageDownloadQueue(_ task: IGDownloadTask) {
        IGAttachmentManager.sharedManager.setProgress(0.0, for: task.file)
        IGAttachmentManager.sharedManager.setStatus(.downloading, for: task.file)
        
        if dictionaryDownloadTaskMain.count >= DOWNLOAD_LIMIT {
            addToWaitingQueue(task)
        } else {
            dictionaryDownloadTaskMain[task.file.token!] = task
            startNextDownloadTaskIfPossible(token: task.file.token)
        }
    }
    
    private func addToWaitingQueue(_ task: IGDownloadTask){
        taskQueueTokenArray.append(task.file.token!)
        dictionaryDownloadTaskQueue[task.file.token!] = task
        print("XXX || waiting queue size : \(dictionaryDownloadTaskQueue.count) || token : \(task.file.token!)")
    }
    
    private func removeFromWaitingQueue(token: String){
        if let index = taskQueueTokenArray.index(of: token) {
            taskQueueTokenArray.remove(at: index)
            dictionaryDownloadTaskQueue.removeValue(forKey: token)
        }
    }
    
    private func hasWaitingQueue() -> Bool {
        if dictionaryDownloadTaskQueue.count > 0 && taskQueueTokenArray.count == dictionaryDownloadTaskQueue.count {
            return true
        }
        return false
    }
    
    private func addToThumbnailQueue(_ task: IGDownloadTask) {
        IGAttachmentManager.sharedManager.setProgress(0.0, for: task.file)
        IGAttachmentManager.sharedManager.setStatus(.downloading, for: task.file)
        thumbnailTasks.append(task)
        startNextThumbnailTaskIfPossible()
    }
    
    private func startNextDownloadTaskIfPossible(token: String? = nil) {
        
        if IGAppManager.sharedManager.isUserLoggiedIn(){
            
            if dictionaryDownloadTaskMain.count == 0 && dictionaryDownloadTaskQueue.count == 0 {
                return
            }
            
            var firstTaskInQueue : IGDownloadTask!
            if token != nil , let task = dictionaryDownloadTaskMain[token!] {
                firstTaskInQueue = task
            } else if hasWaitingQueue() {
                
                let key : String! = taskQueueTokenArray[0]
                let value : IGDownloadTask! = dictionaryDownloadTaskQueue[key]
                
                print("XXX || size : \(dictionaryDownloadTaskQueue.count) || \(key!)")
                
                firstTaskInQueue = value
                dictionaryDownloadTaskMain[key] = value
                removeFromWaitingQueue(token: key)
            }
            
            if firstTaskInQueue == nil {
                return
            }
            
            
            if firstTaskInQueue.state == .pending {
                if firstTaskInQueue.file.publicUrl != nil && !(firstTaskInQueue.file.publicUrl?.isEmpty)! {
                    if dictionaryPauseTask[firstTaskInQueue.file.token!] != nil {
                        dictionaryPauseTask.removeValue(forKey: firstTaskInQueue.file.token!)
                        DiggerManager.shared.startTask(for: firstTaskInQueue.file.publicUrl!)
                        print("XXXR || resume : \(firstTaskInQueue.file.token!)")
                    } else {
                        print("XXXN || new start : \(firstTaskInQueue.file.token!)")
                        downloadCDN(task: firstTaskInQueue)
                    }
                } else {
                    downloadProto(task: firstTaskInQueue)
                }
                
            } else if firstTaskInQueue.state == .finished {
                startNextDownloadTaskIfPossible()
            }
        }
    }
    
    private func startNextThumbnailTaskIfPossible() {
        if thumbnailTasks.count > 0 && IGAppManager.sharedManager.isUserLoggiedIn(){
            let firstTaskInQueue = thumbnailTasks[0]
            if firstTaskInQueue.state == .pending {
                downloadProto(task: firstTaskInQueue)
            } else if firstTaskInQueue.state == .finished {
                thumbnailTasks.remove(at: 0)
                startNextThumbnailTaskIfPossible()
            }
        }
    }
    
    private func downloadCDN(task downloadTask:IGDownloadTask) {
        
        let url = downloadTask.file.publicUrl
        
        if  url != nil && !(url?.isEmpty)! {
            
            print("BBB || Start download CDN")
            
            Digger.download(url!).progress({ (progresss) in
                
                print("BBB || percent is \(progresss.fractionCompleted * 100)")
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
                        
                        if let task = self.dictionaryDownloadTaskMain[downloadTask.file.token!] {
                            self.dictionaryDownloadTaskMain.removeValue(forKey: task.file.token!)
                        }
                        
                        print("XXX || Download Finished :) || Main List Size : \(self.dictionaryDownloadTaskMain.count) || Queue List Size : \(self.dictionaryDownloadTaskQueue.count) || Token Array Size : \(self.taskQueueTokenArray.count)")
                        
                        downloadTask.state = .finished
                        if let success = downloadTask.completionHandler {
                            success(downloadTask.file)
                        }
                        
                        self.startNextDownloadTaskIfPossible()
                        
                    } catch {
                        print("BBB || Error :( ")
                    }
                    
                case .failure(let error):
                    
                    print("BBB || Failure :( => \(error)")
                    
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
    
    private func downloadProto(task downloadTask:IGDownloadTask) {
        
        downloadTask.state = .downloading
        
        let reqW = IGFileDownloadRequest.Generator.generate(token: downloadTask.file.token!,
                                                            offset: Int64((downloadTask.file.data?.count)!),
                                                            maxChunkSize: IGDownloadManager.defaultChunkSizeForDownload,
                                                            type: downloadTask.type)
        
        reqW.success { (responseProto) in
            switch responseProto {
            case let fileDownloadReponse as IGPFileDownloadResponse:
                let data = IGFileDownloadRequest.Handler.interpret(response: fileDownloadReponse)
                downloadTask.file.data!.append(data)
                
                if downloadTask.file.data?.count != downloadTask.file.size { // downloading
                    let progress = Progress()
                    progress.totalUnitCount = Int64(downloadTask.file.size)
                    progress.completedUnitCount =  Int64((downloadTask.file.data?.count)!)
                    IGAttachmentManager.sharedManager.setProgress(progress.fractionCompleted, for: downloadTask.file)
                    IGDownloadManager.sharedManager.downloadProto(task: downloadTask)
                } else { // finished download
                    IGAttachmentManager.sharedManager.setProgress(1.0, for: downloadTask.file)
                    if let fileNameOnDisk = IGAttachmentManager.sharedManager.saveDataToDisk(attachment: downloadTask.file) {
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
    
    func pauseDownload(attachment: IGFile) {
        if attachment.publicUrl != nil && !(attachment.publicUrl?.isEmpty)! {
            pauseCDN(token: attachment.token!)
        } else {
            pauseProto()
        }
    }
    
    private func pauseCDN(token: String) {
        var task : IGDownloadTask! = dictionaryDownloadTaskMain[token]
        if task != nil {
            
            DiggerManager.shared.stopTask(for: task.file.publicUrl!)
            dictionaryPauseTask[token] = task // go to pause dictionary
            dictionaryDownloadTaskMain.removeValue(forKey: token) // remove from main download queue
            
            startNextDownloadTaskIfPossible()
            
        } else {
            task = dictionaryDownloadTaskQueue[token]
            if task == nil {
                return
            }
            
            removeFromWaitingQueue(token: token)
        }
        
        IGAttachmentManager.sharedManager.setProgress(0.0, for: task.file)
        IGAttachmentManager.sharedManager.setStatus(.downloadPause, for: task.file)
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



