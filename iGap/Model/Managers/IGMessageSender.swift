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

class IGMessageSender {
    static let defaultSender = IGMessageSender()
    fileprivate var plainMessagesQueue: DispatchQueue
    fileprivate var messagesWithAttachmentQueue: DispatchQueue //should wait for download to complete
    fileprivate var plainMessagesArray = [IGMessageSenderTask]()
    fileprivate var messagesWithAttachmentArray = [IGMessageSenderTask]()
    
    private init() {
        plainMessagesQueue = DispatchQueue(label: "im.igap.ios.queue.message.plain")
        messagesWithAttachmentQueue = DispatchQueue(label: "im.igap.ios.queue.message.attachment")
    }
    
    func send(message: IGRoomMessage, to room: IGRoom) {
        let task = IGMessageSenderTask(message: message, room: room)
        if message.attachment != nil {
            addTaskToMessagesWithAttachmentQueue(task)
        } else {
            addTaskToPlainMessagesQueue(task)
        }
    }
    
    //MARK: Queue Handler
    private func addTaskToPlainMessagesQueue(_ task: IGMessageSenderTask) {
        plainMessagesArray.append(task)
        sendNextPlainRequest()
    }
    
    fileprivate func removeTaskFromPlainMessagesQueue(_ task: IGMessageSenderTask) {
        if let index = plainMessagesArray.index(of: task) {
            plainMessagesArray.remove(at: index)
        }
    }
    
    private func addTaskToMessagesWithAttachmentQueue(_ task: IGMessageSenderTask) {
        messagesWithAttachmentArray.append(task)
        uploadAttahcmentForNextRequest()
    }
    
    private func moveMesageFromAttachmentedQueueToPlainQueue(_ task: IGMessageSenderTask) {
        if let index = messagesWithAttachmentArray.index(of: task) {
            messagesWithAttachmentArray.remove(at: index)
            addTaskToPlainMessagesQueue(task)
        }
    }
    
    
    //MARK: Send Next
    private func sendNextPlainRequest() {
        if let nextMessageTask = plainMessagesArray.first {
            switch nextMessageTask.room.type {
            case .chat:
                IGChatSendMessageRequest.Generator.generate(message: nextMessageTask.message, room: nextMessageTask.room, attachmentToken: nextMessageTask.uploadTask?.token).success({ (protoResponse) in
                    //update message to success
                    
                    DispatchQueue.main.async {
                        switch protoResponse {
                        case let response as IGPChatSendMessageResponse:
                            IGFactory.shared.updateSendingMessageStatus(nextMessageTask.message, with: response.igpRoomMessage)
                            break
                        default:
                            break
                        }
                        
                        self.removeTaskFromPlainMessagesQueue(nextMessageTask)
                        self.sendNextPlainRequest()
                    }
                    
                    
                }).error({ (errorCode, waitTime) in
                    DispatchQueue.main.async {
                        //TODO: update message to failed
                        self.removeTaskFromPlainMessagesQueue(nextMessageTask)
                        self.sendNextPlainRequest()
                    }
                    
                }).send()
            case .group:
                IGGroupSendMessageRequest.Generator.generate(message: nextMessageTask.message, room: nextMessageTask.room, attachmentToken: nextMessageTask.uploadTask?.token).success({ (protoResponse) in
                    
                    DispatchQueue.main.async {
                        //update message to success
                        switch protoResponse {
                        case let response as IGPGroupSendMessageResponse:
                            IGFactory.shared.updateSendingMessageStatus(nextMessageTask.message, with: response.igpRoomMessage)
                        default:
                            break
                        }
                        
                        self.removeTaskFromPlainMessagesQueue(nextMessageTask)
                        self.sendNextPlainRequest()
                    }
                }).error({ (errorCode, waitTime) in
                    DispatchQueue.main.async {
                        //TODO: update message to failed
                        self.removeTaskFromPlainMessagesQueue(nextMessageTask)
                        self.sendNextPlainRequest()
                    }
                    
                }).send()
                break
            case .channel:
                IGChannelSendMessageRequest.Generator.generate(message: nextMessageTask.message, room: nextMessageTask.room, attachmentToken: nextMessageTask.uploadTask?.token).success({ (protoResponse) in
                    DispatchQueue.main.async {
                        //update message to success
                        switch protoResponse {
                        case let response as IGPChannelSendMessageResponse:
                            IGFactory.shared.updateSendingMessageStatus(nextMessageTask.message, with: response.igpRoomMessage)
                        default:
                            break
                        }
                        
                        self.removeTaskFromPlainMessagesQueue(nextMessageTask)
                        self.sendNextPlainRequest()
                    }
                }).error({ (errorCode, waitTime) in
                    DispatchQueue.main.async {
                        //TODO: update message to failed
                        self.removeTaskFromPlainMessagesQueue(nextMessageTask)
                        self.sendNextPlainRequest()
                    }
                }).send()
                break
            }
        }
    }
    
    private func uploadAttahcmentForNextRequest() {
        if let nextMessageToUpload = messagesWithAttachmentArray.first {
            let nextMessageUploadTask = IGUploadManager.sharedManager.upload(file: nextMessageToUpload.message.attachment!, start: {
                self.fileUploadStarted(nextMessageToUpload)
            }, progress: { (progress) in
                
            }, completion: { (uploadTask) in
                self.fileUploadEnded(nextMessageToUpload)
                for task in self.messagesWithAttachmentArray {
                    if task.uploadTask == uploadTask {
                        self.moveMesageFromAttachmentedQueueToPlainQueue(task)
                    }
                }
            }, failure: { 
                //TODO: check what will happen if upload failes.
                self.fileUploadEnded(nextMessageToUpload)
            })
            nextMessageToUpload.uploadTask = nextMessageUploadTask
        }
    }
    
    
    
    private func fileUploadStarted(_ task: IGMessageSenderTask) {
        switch task.message.type {
        case .image, .imageAndText:
            IGClientActionManager.shared.sendSendingImage(file: task.message.attachment!, for: task.room)
            break
        case .video, .videoAndText:
            IGClientActionManager.shared.sendSendingVideo(file: task.message.attachment!, for: task.room)
            break
        case .audio, .audioAndText:
            IGClientActionManager.shared.sendSendingAudio(file: task.message.attachment!, for: task.room)
            break
        case .voice:
            IGClientActionManager.shared.sendSendingVoice(file: task.message.attachment!, for: task.room)
            break
        case .file, .fileAndText:
            IGClientActionManager.shared.sendSendingFile(file: task.message.attachment!, for: task.room)
            break
        case .gif, .gifAndText:
            IGClientActionManager.shared.sendSendingGif(file: task.message.attachment!, for: task.room)
            break
        default:
            break
        }
    }
    
    private func fileUploadEnded(_ task: IGMessageSenderTask) {
        switch task.message.type {
        case .image, .imageAndText:
            IGClientActionManager.shared.cancelSendingImage(file: task.message.attachment!, for: task.room)
            break
        case .video, .videoAndText:
            IGClientActionManager.shared.cancelSendingVideo(file: task.message.attachment!, for: task.room)
            break
        case .audio, .audioAndText:
            IGClientActionManager.shared.cancelSendingAudio(file: task.message.attachment!, for: task.room)
            break
        case .voice:
            IGClientActionManager.shared.cancelSendingVoice(file: task.message.attachment!, for: task.room)
            break
        case .file, .fileAndText:
            IGClientActionManager.shared.cancelSendingFile(file: task.message.attachment!, for: task.room)
            break
        case .gif, .gifAndText:
            IGClientActionManager.shared.cancelSendingGif(file: task.message.attachment!, for: task.room)
            break
        default:
            break
        }
    }

}


//MARK: -
class IGMessageSenderTask: NSObject{
    var message: IGRoomMessage
    var room: IGRoom
    var uploadTask: IGUploadTask?
    
    init(message: IGRoomMessage, room: IGRoom) {
        self.message = message
        self.room = room
        super.init()
    }
}










