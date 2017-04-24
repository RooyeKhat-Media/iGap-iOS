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

class IGClientActionManager: NSObject {
    static let shared = IGClientActionManager()
    var actions = Dictionary<String, Int32>() //Key=>file.primaryKeyId , value => clientAction.id
    //MARK: - Private
    private override init() {
        super.init()
    }
    
    private func generateId() -> Int32 {
        let range = (20_000_000, 89_999_999)
        return Int32(arc4random_uniform(UInt32(range.1 - range.0))) + Int32(range.0)
    }
    
    //MARK: - typing
    func sendTyping(for room: IGRoom) {
        room.setAction(.typing, id: 10_000_001)
    }
    func cancelTying(for room: IGRoom) {
        room.setAction(.cancel, id: 10_000_001)
    }
    
    //MARK: - capturing image
    func sendCapturingImage(for room: IGRoom) {
        room.setAction(.capturingImage, id: 10_000_002)
    }
    func cancelCapturingImage(for room: IGRoom) {
        room.setAction(.cancel, id: 10_000_002)
    }
    
    //MARK: - sending image
    func sendSendingImage(file: IGFile, for room: IGRoom) {
        let id = self.generateId()
        actions[file.primaryKeyId!] = id
        room.setAction(.sendingImage, id: id)
    }
    func cancelSendingImage(file: IGFile, for room: IGRoom) {
        if let id = actions[file.primaryKeyId!] {
            room.setAction(.cancel, id: id)
        }
    }
    
    //MARK: - capturing video
    func sendCapturingVideo(for room: IGRoom) {
        room.setAction(.capturingVideo, id: 10_000_003)
    }
    func cancelCapturingVideo(for room: IGRoom) {
        room.setAction(.cancel, id: 10_000_003)
    }
    
    //MARK: - sending video
    func sendSendingVideo(file: IGFile, for room: IGRoom) {
        let id = self.generateId()
        actions[file.primaryKeyId!] = id
        room.setAction(.sendingVideo, id: id)
    }
    func cancelSendingVideo(file: IGFile, for room: IGRoom) {
        if let id = actions[file.primaryKeyId!] {
            room.setAction(.cancel, id: id)
        }
    }
    
    //MARK: - sending gif
    func sendSendingGif(file: IGFile, for room: IGRoom) {
        let id = self.generateId()
        actions[file.primaryKeyId!] = id
        room.setAction(.sendingGif, id: id)
    }
    func cancelSendingGif(file: IGFile, for room: IGRoom) {
        if let id = actions[file.primaryKeyId!] {
            room.setAction(.cancel, id: id)
        }
    }
    
    //MARK: - sending audio
    func sendSendingAudio(file: IGFile, for room: IGRoom) {
        let id = self.generateId()
        actions[file.primaryKeyId!] = id
        room.setAction(.sendingAudio, id: id)
    }
    func cancelSendingAudio(file: IGFile, for room: IGRoom) {
        if let id = actions[file.primaryKeyId!] {
            room.setAction(.cancel, id: id)
        }
    }
    
    //MARK: - recording voice
    func sendRecordingVoice(for room: IGRoom) {
        room.setAction(.recordingVoice, id: 10_000_004)
    }
    func sendCancelRecoringVoice(for room: IGRoom) {
        room.setAction(.cancel, id: 10_000_004)
    }
    
    //MARK: - sending voice
    func sendSendingVoice(file: IGFile, for room: IGRoom) {
        let id = self.generateId()
        actions[file.primaryKeyId!] = id
        room.setAction(.sendingVoice, id: id)
    }
    func cancelSendingVoice(file: IGFile, for room: IGRoom) {
        if let id = actions[file.primaryKeyId!] {
            room.setAction(.cancel, id: id)
        }
    }
    
    //MARK: - sending document
    func sendSendingDocument(file: IGFile, for room: IGRoom) {
        let id = self.generateId()
        actions[file.primaryKeyId!] = id
        room.setAction(.sendingDocument, id: id)
    }
    func cancelSendingDocument(file: IGFile, for room: IGRoom) {
        if let id = actions[file.primaryKeyId!] {
            room.setAction(.cancel, id: id)
        }
    }
    
    //MARK: - sending file
    func sendSendingFile(file: IGFile, for room: IGRoom) {
        let id = self.generateId()
        actions[file.primaryKeyId!] = id
        room.setAction(.sendingFile, id: id)
    }
    func cancelSendingFile(file: IGFile, for room: IGRoom) {
        if let id = actions[file.primaryKeyId!] {
            room.setAction(.cancel, id: id)
        }
    }
    
    //MARK: - sending location
    func sendSendingLocation(for room: IGRoom) {
        room.setAction(.sendingLocation, id: 10_000_005)
    }
    func cancelSendingLocation(for room: IGRoom) {
        room.setAction(.cancel, id: 10_000_005)
    }

    //MARK: - choosing contact
    func sendChoosingContact(for room: IGRoom) {
        room.setAction(.choosingContact, id: 10_000_006)
    }
    func cancelChoosingContact(for room: IGRoom) {
        room.setAction(.cancel, id: 10_000_006)
    }
    
    //MARK: - painting
    func sendPainting(for room: IGRoom) {
        room.setAction(.painting, id: 10_000_007)
    }
    func cancelPainting(for room: IGRoom) {
        room.setAction(.cancel, id: 10_000_007)
    }
}
