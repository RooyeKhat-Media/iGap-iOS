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

enum IGFileUploadingStatus {
    case unknown
    case uploading
    case processing
    case processed
}


class IGFileUploadOptionRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(size: Int64) -> IGRequestWrapper {
            var uploadOptionRequestMessage = IGPFileUploadOption()
            uploadOptionRequestMessage.igpSize = size
            return IGRequestWrapper(message: uploadOptionRequestMessage, actionID: 700)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage: IGPFileUploadOptionResponse) -> (initialBytesLimit: Int32,  finalBytesLimit:Int32) {
            let initialBytesLimit = responseProtoMessage.igpFirstBytesLimit
            let finalBytesLimit = responseProtoMessage.igpLastBytesLimit
            return (initialBytesLimit: initialBytesLimit, finalBytesLimit: finalBytesLimit)
        }
        override class func handlePush(responseProtoMessage: Message) {}
    }
}

//MARK: -
class IGFileUploadInitRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(initialBytes: Data, finalBytes: Data, size: Int64, hash: Data, name: String) -> IGRequestWrapper {
            var uploadInitRequestMessage = IGPFileUploadInit()
            uploadInitRequestMessage.igpFirstBytes = initialBytes
            uploadInitRequestMessage.igpLastBytes = finalBytes
            uploadInitRequestMessage.igpSize = size
            uploadInitRequestMessage.igpFileHash = hash
            uploadInitRequestMessage.igpFileName = name
            return IGRequestWrapper(message: uploadInitRequestMessage, actionID: 701)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage: IGPFileUploadInitResponse) -> (token: String, progress: Double, limit: Int32, offset: Int64) {
            let token : String = responseProtoMessage.igpToken
            let progress : Double = responseProtoMessage.igpProgress
            let limit : Int32 = responseProtoMessage.igpLimit
            let offset : Int64 = responseProtoMessage.igpOffset
            return (token: token, progress: progress, limit: limit, offset: offset)
        }
        
        override class func handlePush(responseProtoMessage: Message) {}
    }
}

//MARK: -
class IGFileUploadRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(token: String, offset: Int64, data: Data) -> IGRequestWrapper {
            var uploadRequestMessage = IGPFileUpload()
            uploadRequestMessage.igpToken = token
            uploadRequestMessage.igpOffset = offset
            uploadRequestMessage.igpBytes = data
            return IGRequestWrapper(message: uploadRequestMessage, actionID: 702)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPFileUploadResponse) -> (progress: Double, nextLimit: Int32, nextOffset: Int64) {
            let progress : Double = responseProtoMessage.igpProgress
            let nextLimit : Int32 = responseProtoMessage.igpNextLimit
            let nextOffset : Int64 = responseProtoMessage.igpNextOffset
            return (progress: progress, nextLimit: nextLimit, nextOffset: nextOffset)
            
        }
        
        override class func handlePush(responseProtoMessage: Message) {}
    }
}

//MARK: -
class IGFileUploadStatusRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(token: String) -> IGRequestWrapper {
            var uploadStatusRequestMessage = IGPFileUploadStatus()
            uploadStatusRequestMessage.igpToken = token
            return IGRequestWrapper(message: uploadStatusRequestMessage, actionID: 703)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPFileUploadStatusResponse) -> (status: IGFileUploadingStatus, progress: Double, retryDelay: Int32) {
            var status: IGFileUploadingStatus
            switch responseProtoMessage.igpStatus {
            case .uploading:
                status = .uploading
            case .processing:
                status = .processing
            case .processed:
                status = .processed
            default:
                status = .unknown
            }
            
            let progress = responseProtoMessage.igpProgress
            let retryDelay = responseProtoMessage.igpRecheckDelayMs
            
            return (status: status, progress: progress, retryDelay: retryDelay)
        }
        
        override class func handlePush(responseProtoMessage: Message) {}
    }
}


//MARK: -
class IGFileInfoRequest: IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(token: String) -> IGRequestWrapper {
            var fileInfoRequestMessage = IGPFileInfo()
            fileInfoRequestMessage.igpToken = token
            return IGRequestWrapper(message: fileInfoRequestMessage, actionID: 704)
        }
    }
    
    class Handler : IGRequest.Handler{
        override class func handlePush(responseProtoMessage: Message) {}
    }
}


//MARK: -
class IGFileDownloadRequest: IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(token: String, offset:Int64, maxChunkSize: Int32, type: IGFile.PreviewType) -> IGRequestWrapper {
            var downloadRequestMessage = IGPFileDownload()
            downloadRequestMessage.igpToken = token
            downloadRequestMessage.igpOffset = offset
            downloadRequestMessage.igpMaxLimit = maxChunkSize
            switch type {
            case .originalFile:
                downloadRequestMessage.igpSelector = .file
            case .smallThumbnail:
                downloadRequestMessage.igpSelector = .smallThumbnail
            case .largeThumbnail:
                downloadRequestMessage.igpSelector = .largeThumbnail
            case .waveformThumbnail:
                downloadRequestMessage.igpSelector = .waveformThumbnail
            }
            return IGRequestWrapper(message: downloadRequestMessage, actionID: 705)
        }
    }
    
    
    class Handler : IGRequest.Handler {
        class func interpret(response responseProtoMessage:IGPFileDownloadResponse) -> Data {
            return responseProtoMessage.igpBytes
        }
        
        override class func handlePush(responseProtoMessage: Message) {}
    }
}


