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
import ProtocolBuffers

enum IGFileUploadingStatus {
    case unknown
    case uploading
    case processing
    case processed
}


class IGFileUploadOptionRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(size: Int64) -> IGRequestWrapper {
            let uploadOptionRequestBuilder = IGPFileUploadOption.Builder()
            uploadOptionRequestBuilder.setIgpSize(size)
            return IGRequestWrapper(messageBuilder: uploadOptionRequestBuilder, actionID: 700)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage: IGPFileUploadOptionResponse) -> (initialBytesLimit: Int32,  finalBytesLimit:Int32) {
            let initialBytesLimit = responseProtoMessage.igpFirstBytesLimit
            let finalBytesLimit = responseProtoMessage.igpLastBytesLimit
            return (initialBytesLimit: initialBytesLimit, finalBytesLimit: finalBytesLimit)
        }
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {}
        override class func error() {}
        override class func timeout() {}
    }
}

//MARK: -
class IGFileUploadInitRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(initialBytes: Data, finalBytes: Data, size: Int64, hash: Data, name: String) -> IGRequestWrapper {
            let uploadInitRequestBuilder = IGPFileUploadInit.Builder()
            uploadInitRequestBuilder.setIgpFirstBytes(initialBytes)
            uploadInitRequestBuilder.setIgpLastBytes(finalBytes)
            uploadInitRequestBuilder.setIgpSize(size)
            uploadInitRequestBuilder.setIgpFileHash(hash)
            uploadInitRequestBuilder.setIgpFileName(name)
            return IGRequestWrapper(messageBuilder: uploadInitRequestBuilder, actionID: 701)
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
        
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {}
        override class func error() {}
        override class func timeout() {}
    }
}

//MARK: -
class IGFileUploadRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(token: String, offset: Int64, data: Data) -> IGRequestWrapper {
            let uploadRequestBuilder = IGPFileUpload.Builder()
            uploadRequestBuilder.setIgpToken(token)
            uploadRequestBuilder.setIgpOffset(offset)
            uploadRequestBuilder.setIgpBytes(data)
            return IGRequestWrapper(messageBuilder: uploadRequestBuilder, actionID: 702)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPFileUploadResponse) -> (progress: Double, nextLimit: Int32, nextOffset: Int64) {
            let progress : Double = responseProtoMessage.igpProgress
            let nextLimit : Int32 = responseProtoMessage.igpNextLimit
            let nextOffset : Int64 = responseProtoMessage.igpNextOffset
            return (progress: progress, nextLimit: nextLimit, nextOffset: nextOffset)
            
        }
        
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {}
        override class func error() {}
        override class func timeout() {}
    }
}

//MARK: -
class IGFileUploadStatusRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(token: String) -> IGRequestWrapper {
            let uploadStatusRequestBuilder = IGPFileUploadStatus.Builder()
            uploadStatusRequestBuilder.setIgpToken(token)
            return IGRequestWrapper(messageBuilder: uploadStatusRequestBuilder, actionID: 703)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPFileUploadStatusResponse) -> (status: IGFileUploadingStatus, progress: Double, retryDelay: Int32) {
            var status: IGFileUploadingStatus
            if responseProtoMessage.hasIgpStatus {
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
            } else {
                status = .unknown
            }
            let progress = responseProtoMessage.igpProgress
            let retryDelay = responseProtoMessage.igpRecheckDelayMs
            
            return (status: status, progress: progress, retryDelay: retryDelay)
        }
        
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {}
        override class func error() {}
        override class func timeout() {}
    }
}


//MARK: -
class IGFileInfoRequest: IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(token: String) -> IGRequestWrapper {
            let fileInfoRequestBuilder = IGPFileInfo.Builder()
            fileInfoRequestBuilder.setIgpToken(token)
            return IGRequestWrapper(messageBuilder: fileInfoRequestBuilder, actionID: 704)
        }
    }
    
    class Handler : IGRequest.Handler{
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {}
        override class func error() {}
        override class func timeout() {}
    }
}


//MARK: -
class IGFileDownloadRequest: IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(token: String, offset:Int64, maxChunkSize: Int32, type: IGFile.PreviewType) -> IGRequestWrapper{
            let downloadRequestbuilder = IGPFileDownload.Builder()
            downloadRequestbuilder.setIgpToken(token)
            downloadRequestbuilder.setIgpOffset(offset)
            downloadRequestbuilder.setIgpMaxLimit(maxChunkSize)            
            switch type {
            case .originalFile:
                downloadRequestbuilder.setIgpSelector(.file)
            case .smallThumbnail:
                downloadRequestbuilder.setIgpSelector(.smallThumbnail)
            case .largeThumbnail:
                downloadRequestbuilder.setIgpSelector(.largeThumbnail)
            case .waveformThumbnail:
                downloadRequestbuilder.setIgpSelector(.waveformThumbnail)
            }
            return IGRequestWrapper(messageBuilder: downloadRequestbuilder, actionID: 705)
        }
    }
    
    
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPFileDownloadResponse) -> Data {
            return responseProtoMessage.igpBytes
        }
        
        override class func handlePush(responseProtoMessage: GeneratedResponseMessage) {}
        override class func error() {}
        override class func timeout() {}
    }
}


