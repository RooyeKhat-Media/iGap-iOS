/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the RooyeKhat Media Company - www.RooyeKhat.co
 * All rights reserved.
 */

import Foundation
import IGProtoBuff
import SwiftProtobuf

enum IGGender: Int {
    case unknown = 0
    case male
    case female
    
}

enum IGDevice: Int {
    case unknown = 0
    case desktop
    case tablet
    case mobile
}

enum IGPlatform: Int {
    case unknown = 0
    case android
    case iOS
    case macOS
    case windows
    case linux
    case blackberry
}

enum IGLanguage: Int {
    case en_us
    case fa_ir
}


enum IGRoomMessageStatus: Int {
    case unknown = -1
    case failed
    case sending
    case sent
    case delivered
    case seen
    case listened
}

enum IGRoomMessageType: Int {
    case unknown = -1
    case text
    case image
    case imageAndText
    case video
    case videoAndText
    case audio
    case audioAndText
    case voice
    case gif
    case file
    case fileAndText
    case location
    case log
    case contact
    case gifAndText
    
    func toIGP() -> IGPRoomMessageType {
        switch self {
        case .unknown, .text:
            return .text
        case .image:
            return .image
        case .imageAndText:
            return .imageText
        case .video:
            return .video
        case .videoAndText:
            return .videoText
        case .audio:
            return .audio
        case .audioAndText:
            return .audioText
        case .voice:
            return .voice
        case .gif:
            return .gif
        case .file:
            return .file
        case .fileAndText:
            return .fileText
        case .location:
            return .location
        case .log:
            return .log
        case .contact:
            return .contact
        case .gifAndText:
            return .gifText
        }
    }
    
    func fromIGP(_ igpType:IGPRoomMessageType) -> IGRoomMessageType{
        switch igpType {
        case .text:
            return .text
        case .image:
            return .image
        case .imageText:
            return .imageAndText
        case .video:
            return .video
        case .videoText:
            return .videoAndText
        case .audio:
            return .audio
        case .audioText:
            return .audioAndText
        case .voice:
            return .voice
        case .gif:
            return .gif
        case .file:
            return .file
        case .fileText:
            return .fileAndText
        case .location:
            return .location
        case .log:
            return .log
        case .contact:
            return .contact
        case .gifText:
            return .gifAndText
        default:
            return .text
        }
    }
}

enum IGClientAction: Int {
    case cancel
    case typing
    case sendingImage
    case capturingImage
    case sendingVideo
    case capturingVideo
    case sendingAudio
    case recordingVoice
    case sendingVoice
    case sendingDocument
    case sendingGif
    case sendingFile
    case sendingLocation
    case choosingContact
    case painting
    
    func toIGP() -> IGPClientAction {
        switch self {
        case .cancel:
            return .cancel
        case .typing:
            return .typing
        case .sendingImage:
            return .sendingImage
        case .capturingImage:
            return .capturingImage
        case .sendingVideo:
            return .sendingVideo
        case .capturingVideo:
            return .capturingVideo
        case .sendingAudio:
            return .sendingAudio
        case .recordingVoice:
            return .recordingVoice
        case .sendingVoice:
            return .sendingVoice
        case .sendingDocument:
            return .sendingDocument
        case .sendingGif:
            return .sendingGif
        case .sendingFile:
            return .sendingFile
        case .sendingLocation:
            return .sendingLocation
        case .choosingContact:
            return .choosingContact
        case .painting:
            return .painting
        }
    }
    
    func fromIGP(_ igpAction: IGPClientAction) -> IGClientAction {
        switch igpAction {
        case .typing:
            return .typing
        case .cancel:
            return .cancel
        case .sendingImage:
            return .sendingImage
        case .capturingImage:
            return .capturingImage
        case .sendingVideo:
            return .sendingVideo
        case .capturingVideo:
            return .capturingVideo
        case .sendingAudio:
            return .sendingAudio
        case .recordingVoice:
            return .recordingVoice
        case .sendingVoice:
            return .sendingVoice
        case .sendingDocument:
            return .sendingDocument
        case .sendingGif:
            return .sendingGif
        case .sendingFile:
            return .sendingFile
        case .sendingLocation:
            return .sendingLocation
        case .choosingContact:
            return .choosingContact
        case .painting:
            return .painting
        default:
            return .cancel
        }
    }
}

enum IGDeleteReasen: Int {
    case other
    
}

enum IGCheckUsernameStatus: Int {
    case invalid
    case taken
    case available
    case needsValidation
}

enum IGPassCodeViewMode: Int {
    case locked
    case turnOnPassCode
    case changePassCode
}

enum IGRoomFilterRole: Int {
    case all
    case member
    case admin
    case moderator
}

enum IGSharedMediaFilter: Int {
    case image
    case video
    case audio
    case voice
    case gif
    case file
    case url
    
}

enum IGClientResolveUsernameType: Int {
    case user
    case room
}

enum IGPrivacyType: Int {
    case userStatus
    case avatar
    case groupInvite
    case channelInvite
    case voiceCalling
    case videoCalling
    case screenSharing
    case secretChat
}

enum IGPrivacyLevel: Int {
    case allowAll
    case denyAll
    case allowContacts
    
    func fromIGP(_ igpPrivacyLevel: IGPPrivacyLevel) -> IGPrivacyLevel {
        switch igpPrivacyLevel {
        case .allowAll:
            return .allowAll
        case .allowContacts:
            return .allowContacts
        case .denyAll:
            return . denyAll
        default:
            return . denyAll
        }
    }

}

