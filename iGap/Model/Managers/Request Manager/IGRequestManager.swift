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
import ProtocolBuffers
import RxSwift

let protoClassesLookupTable: [Int: (proto: GeneratedMessageProtocol.Type, reponseHandler: IGRequest.Handler.Type)] = [
    //System: xx
        0: (IGPErrorResponse.self                           as GeneratedMessageProtocol.Type,
            IGErrorRequest.Handler.self                     as IGRequest.Handler.Type),
    30001: (IGPConnectionSecuringResponse.self              as GeneratedMessageProtocol.Type,
            IGConnectionSecuringRequest.Handler.self        as IGRequest.Handler.Type),
    30002: (IGPConnectionSymmetricKeyResponse.self          as GeneratedMessageProtocol.Type,
            IGConnectionSymmetricKeyRequest.Handler.self    as IGRequest.Handler.Type),
    30003: (IGPHeartbeatResponse.self                       as GeneratedMessageProtocol.Type,
            IGHeartBeatRequest.Handler.self                 as IGRequest.Handler.Type),
    
    //User: 301xx
    30100: (IGPUserRegisterResponse.self                    as GeneratedMessageProtocol.Type,
            IGUserRegisterRequest.Handler.self              as IGRequest.Handler.Type),
    30101: (IGPUserVerifyResponse.self                      as GeneratedMessageProtocol.Type,
            IGUserVerifyRequest.Handler.self                as IGRequest.Handler.Type),
    30102: (IGPUserLoginResponse.self                       as GeneratedMessageProtocol.Type,
            IGUserLoginRequest.Handler.self                 as IGRequest.Handler.Type),
    30103: (IGPUserProfileSetEmailResponse.self             as GeneratedMessageProtocol.Type,
            IGUserProfileSetEmailRequest.Handler.self       as IGRequest.Handler.Type),
    30104: (IGPUserProfileSetGenderResponse.self            as GeneratedMessageProtocol.Type,
            IGUserProfileSetGenderRequest.Handler.self      as IGRequest.Handler.Type),
    30105: (IGPUserProfileSetNicknameResponse.self          as GeneratedMessageProtocol.Type,
            IGUserProfileSetNicknameRequest.Handler.self    as IGRequest.Handler.Type),
    30106: (IGPUserContactsImportResponse.self              as GeneratedMessageProtocol.Type,
            IGUserContactsImportRequest.Handler.self        as IGRequest.Handler.Type),
    30107: (IGPUserContactsGetListResponse.self             as GeneratedMessageProtocol.Type,
            IGUserContactsGetListRequest.Handler.self       as IGRequest.Handler.Type),
    30110: (IGPUserProfileGetEmailResponse.self             as GeneratedMessageProtocol.Type,
            IGUserProfileGetEmailRequest.Handler.self       as IGRequest.Handler.Type),
    30111: (IGPUserProfileGetGenderResponse.self            as GeneratedMessageProtocol.Type,
            IGUserProfileGetGenderRequest.Handler.self      as IGRequest.Handler.Type),
    30112: (IGPUserProfileGetNicknameResponse.self          as GeneratedMessageProtocol.Type,
            IGUserProfileGetNicknameRequest.Handler.self    as IGRequest.Handler.Type),
    30114: (IGPUserAvatarAddResponse.self                   as GeneratedMessageProtocol.Type,
            IGUserAvatarAddRequest.Handler.self             as IGRequest.Handler.Type),
    30116: (IGPUserAvatarGetListResponse.self               as GeneratedMessageProtocol.Type,
            IGUserAvatarGetListRequest.Handler.self         as IGRequest.Handler.Type),
    30117: (IGPUserInfoResponse.self                        as GeneratedMessageProtocol.Type,
            IGUserInfoRequest.Handler.self                  as IGRequest.Handler.Type),
    30118: (IGPUserGetDeleteTokenResponse.self              as GeneratedMessageProtocol.Type,
            IGUserGetDeleteTokenRequest.Handler.self        as IGRequest.Handler.Type),
    30119: (IGPUserDeleteResponse.self                      as GeneratedMessageProtocol.Type,
            IGUserDeleteRequest.Handler.self                as IGRequest.Handler.Type),
    30120: (IGPUserProfileSetSelfRemoveResponse.self        as GeneratedMessageProtocol.Type,
            IGUserProfileSetSelfRemoveRequest.Handler.self  as IGRequest.Handler.Type),
    30121: (IGPUserProfileGetSelfRemoveResponse.self        as GeneratedMessageProtocol.Type,
            IGUserProfileGetSelfRemoveRequest.Handler.self  as IGRequest.Handler.Type),
    30122: (IGPUserProfileCheckUsernameResponse.self        as GeneratedMessageProtocol.Type,
            IGUserProfileCheckUsernameRequest.Handler.self  as IGRequest.Handler.Type),
    30123: (IGPUserProfileUpdateUsernameResponse.self       as GeneratedMessageProtocol.Type,
            IGUserProfileUpdateUsernameRequest.Handler.self as IGRequest.Handler.Type),
    30124: (IGPUserUpdateStatusResponse.self                as GeneratedMessageProtocol.Type,
            IGUserUpdateStatusRequest.Handler.self          as IGRequest.Handler.Type),
    30125: (IGPUserSessionGetActiveListResponse.self        as GeneratedMessageProtocol.Type,
            IGUserSessionGetActiveListRequest.Handler.self  as IGRequest.Handler.Type),
    30126: (IGPUserSessionTerminateResponse.self            as GeneratedMessageProtocol.Type,
            IGUserSessionTerminateRequest.Handler.self      as IGRequest.Handler.Type),
    30127: (IGPUserSessionLogoutResponse.self               as GeneratedMessageProtocol.Type,
            IGUserSessionLogoutRequest.Handler.self         as IGRequest.Handler.Type),
    30128: (IGPUserContactsBlockResponse.self               as GeneratedMessageProtocol.Type,
            IGUserContactsBlockRequest.Handler.self         as IGRequest.Handler.Type),
    30129: (IGPUserContactsUnblockResponse.self             as GeneratedMessageProtocol.Type,
            IGUserContactsUnBlockRequest.Handler.self       as IGRequest.Handler.Type),
    30130: (IGPUserContactsGetBlockedListResponse.self      as GeneratedMessageProtocol.Type,
            IGUserContactsGetBlockedListRequest.Handler.self as IGRequest.Handler.Type),
    30143: (IGPUserPrivacyGetRuleResponse.self              as GeneratedMessageProtocol.Type,
            IGUserPrivacyGetRuleRequest.Handler.self        as IGRequest.Handler.Type),
    30144: (IGPUserPrivacySetRuleResponse.self              as GeneratedMessageProtocol.Type,
            IGUserPrivacySetRuleRequest.Handler.self        as IGRequest.Handler.Type),
    
    
    //Chat: 302xx
    30200: (IGPChatGetRoomResponse.self                     as GeneratedMessageProtocol.Type,
            IGChatGetRoomRequest.Handler.self               as IGRequest.Handler.Type),
    30201: (IGPChatSendMessageResponse.self                 as GeneratedMessageProtocol.Type,
            IGChatSendMessageRequest.Handler.self           as IGRequest.Handler.Type),
    30202: (IGPChatUpdateStatusResponse.self                as GeneratedMessageProtocol.Type,
            IGChatUpdateStatusRequest.Handler.self          as IGRequest.Handler.Type),
    30203: (IGPChatEditMessageResponse.self                 as GeneratedMessageProtocol.Type,
             IGChatEditMessageRequest.Handler.self          as IGRequest.Handler.Type),
    30204: (IGPChatDeleteMessageResponse.self               as GeneratedMessageProtocol.Type,
             IGChatDeleteMessageRequest.Handler.self        as IGRequest.Handler.Type),
    30205: (IGPChatClearMessageResponse.self                as GeneratedMessageProtocol.Type,
            IGChatClearMessageRequest.Handler.self          as IGRequest.Handler.Type),
    30206: (IGPChatDeleteResponse.self                      as GeneratedMessageProtocol.Type,
            IGChatDeleteRequest.Handler.self                as IGRequest.Handler.Type),
    30207: (IGPChatUpdateDraftResponse.self                 as GeneratedMessageProtocol.Type,
            IGChatUpdateDraftRequest.Handler.self           as IGRequest.Handler.Type),
    30208: (IGPChatGetDraftResponse.self                    as GeneratedMessageProtocol.Type,
            IGChatGetDraftRequest.Handler.self              as IGRequest.Handler.Type),
    30209: (IGPChatConvertToGroupResponse.self              as GeneratedMessageProtocol.Type,
            IGChatConvertToGroupRequest.Handler.self        as IGRequest.Handler.Type),
    30210: (IGPChatSetActionResponse.self                   as GeneratedMessageProtocol.Type,
             IGChatSetActionRequest.Handler.self            as IGRequest.Handler.Type),
    
    //Group: 303xx
    30300: (IGPGroupCreateResponse.self                     as GeneratedMessageProtocol.Type,
            IGGroupCreateRequest.Handler.self               as IGRequest.Handler.Type),
    30301: (IGPGroupAddMemberResponse.self                  as GeneratedMessageProtocol.Type,
            IGGroupAddMemberRequest.Handler.self            as IGRequest.Handler.Type),
    30302: (IGPGroupAddAdminResponse.self                   as GeneratedMessageProtocol.Type,
            IGGroupAddAdminRequest.Handler.self             as IGRequest.Handler.Type),
    30303: (IGPGroupAddModeratorResponse.self               as GeneratedMessageProtocol.Type,
            IGGroupAddModeratorRequest.Handler.self         as IGRequest.Handler.Type),
    30304: (IGPGroupClearMessageResponse.self               as GeneratedMessageProtocol.Type,
            IGGroupClearMessageRequest.Handler.self         as IGRequest.Handler.Type),
    30305: (IGPGroupEditResponse.self                       as GeneratedMessageProtocol.Type,
            IGGroupEditRequest.Handler.self                 as IGRequest.Handler.Type),
    30306: (IGPGroupKickAdminResponse.self                  as GeneratedMessageProtocol.Type,
            IGGroupKickAdminRequest.Handler.self            as IGRequest.Handler.Type),
    30307: (IGPGroupKickMemberResponse.self                 as GeneratedMessageProtocol.Type,
            IGGroupKickMemberRequest.Handler.self           as IGRequest.Handler.Type),
    30308: (IGPGroupKickModeratorResponse.self              as GeneratedMessageProtocol.Type,
            IGGroupKickModeratorRequest.Handler.self        as IGRequest.Handler.Type),
    30309: (IGPGroupLeftResponse.self                       as GeneratedMessageProtocol.Type,
            IGGroupLeftRequest.Handler.self                 as IGRequest.Handler.Type),
    30310: (IGPGroupSendMessageResponse.self                as GeneratedMessageProtocol.Type,
            IGGroupSendMessageRequest.Handler.self          as IGRequest.Handler.Type),
    30311: (IGPGroupUpdateStatusResponse.self               as GeneratedMessageProtocol.Type,
            IGGroupUpdateStatusRequest.Handler.self         as IGRequest.Handler.Type),
    30312: (IGPGroupAvatarAddResponse.self                  as GeneratedMessageProtocol.Type,
            IGGroupAvatarAddRequest.Handler.self            as IGRequest.Handler.Type),
    30313: (IGPGroupAvatarDeleteResponse.self               as GeneratedMessageProtocol.Type,
            IGGroupAvatarDeleteRequest.Handler.self         as IGRequest.Handler.Type),
    30314: (IGPGroupAvatarGetListResponse.self              as GeneratedMessageProtocol.Type,
            IGGroupAvatarGetListRequest.Handler.self        as IGRequest.Handler.Type),
    30315: (IGPGroupUpdateDraftResponse.self                as GeneratedMessageProtocol.Type,
            IGGroupUpdateDraftRequest.Handler.self          as IGRequest.Handler.Type),
    30316: (IGPGroupGetDraftResponse.self                   as GeneratedMessageProtocol.Type,
            IGGroupGetDraftRequest.Handler.self             as IGRequest.Handler.Type),
    30317: (IGPGroupGetMemberListResponse.self              as GeneratedMessageProtocol.Type,
            IGGroupGetMemberListRequest.Handler.self        as IGRequest.Handler.Type),
    30318: (IGPGroupDeleteResponse.self                     as GeneratedMessageProtocol.Type,
            IGGroupDeleteRequest.Handler.self               as IGRequest.Handler.Type),
    30319: (IGPGroupSetActionResponse.self                  as GeneratedMessageProtocol.Type,
            IGGroupSetActionRequest.Handler.self            as IGRequest.Handler.Type),
    30320: (IGPGroupDeleteMessageResponse.self              as GeneratedMessageProtocol.Type,
            IGGroupDeleteMessageRequest.Handler.self        as IGRequest.Handler.Type),
    30321: (IGPGroupCheckUsernameResponse.self              as GeneratedMessageProtocol.Type,
            IGGroupCheckUsernameRequest.Handler.self        as IGRequest.Handler.Type),
    30322: (IGPGroupCheckUsernameResponse.self              as GeneratedMessageProtocol.Type,
            IGGroupCheckUsernameRequest.Handler.self        as IGRequest.Handler.Type),
    30323: (IGPGroupRemoveUsernameResponse.self             as GeneratedMessageProtocol.Type,
            IGGroupRemoveUsernameRequest.Handler.self       as IGRequest.Handler.Type),
    30324: (IGPGroupRevokeLinkResponse.self                 as GeneratedMessageProtocol.Type,
            IGGroupRevokLinkRequest.Handler.self            as IGRequest.Handler.Type),
    30325: (IGPGroupEditMessageResponse.self                as GeneratedMessageProtocol.Type,
            IGGroupEditMessageRequest.Handler.self          as IGRequest.Handler.Type),
    
    //Channel: 304xx
    30400: (IGPChannelCreateResponse.self                   as GeneratedMessageProtocol.Type,
            IGChannelCreateRequest.Handler.self             as IGRequest.Handler.Type),
    30401: (IGPChannelAddMemberResponse.self                as GeneratedMessageProtocol.Type,
            IGChannelAddMemberRequest.Handler.self          as IGRequest.Handler.Type),
    30402: (IGPChannelAddAdminResponse.self                 as GeneratedMessageProtocol.Type,
            IGChannelAddAdminRequest.Handler.self           as IGRequest.Handler.Type),
    30403: (IGPChannelAddModeratorResponse.self             as GeneratedMessageProtocol.Type,
            IGChannelAddModeratorRequest.Handler.self       as IGRequest.Handler.Type),
    30404: (IGPChannelDeleteResponse.self                   as GeneratedMessageProtocol.Type,
            IGChannelDeleteRequest.Handler.self             as IGRequest.Handler.Type),
    30405: (IGPChannelEditResponse.self                     as GeneratedMessageProtocol.Type,
            IGChannelEditRequest.Handler.self               as IGRequest.Handler.Type),
    30406: (IGPChannelKickAdminResponse.self                as GeneratedMessageProtocol.Type,
            IGChannelKickAdminRequest.Handler.self          as IGRequest.Handler.Type),
    30407: (IGPChannelKickMemberResponse.self               as GeneratedMessageProtocol.Type,
            IGChannelKickMemberRequest.Handler.self         as IGRequest.Handler.Type),
    30408: (IGPChannelKickModeratorResponse.self            as GeneratedMessageProtocol.Type,
            IGChannelKickModeratorRequest.Handler.self      as IGRequest.Handler.Type),
    30409: (IGPChannelLeftResponse.self                     as GeneratedMessageProtocol.Type,
            IGChannelLeftRequest.Handler.self               as IGRequest.Handler.Type),
    30410: (IGPChannelSendMessageResponse.self              as GeneratedMessageProtocol.Type,
            IGChannelSendMessageRequest.Handler.self        as IGRequest.Handler.Type),
    30411: (IGPChannelDeleteMessageResponse.self            as GeneratedMessageProtocol.Type,
            IGChannelDeleteMessageRequest.Handler.self      as IGRequest.Handler.Type),
    30412: (IGPChannelAvatarAddResponse.self                as GeneratedMessageProtocol.Type,
            IGChannelAddAvatarRequest.Handler.self          as IGRequest.Handler.Type),
    30415: (IGPChannelUpdateDraftResponse.self              as GeneratedMessageProtocol.Type,
            IGChannelUpdateDraftRequest.Handler.self        as IGRequest.Handler.Type),
    30416: (IGPChannelGetDraftResponse.self                 as GeneratedMessageProtocol.Type,
            IGChannelGetDraftRequest.Handler.self           as IGRequest.Handler.Type),
    30417: (IGPChannelGetMemberListResponse.self            as GeneratedMessageProtocol.Type,
            IGChannelGetMemberListRequest.Handler.self      as IGRequest.Handler.Type),
    30419: (IGPChannelUpdateUsernameResponse.self           as GeneratedMessageProtocol.Type,
            IGChannelUpdateUsernameRequest.Handler.self     as IGRequest.Handler.Type),
    30420: (IGPChannelRemoveUsernameResponse.self           as GeneratedMessageProtocol.Type,
            IGChannelRemoveUsernameRequest.Handler.self     as IGRequest.Handler.Type),
    30422: (IGPChannelUpdateSignatureResponse.self          as GeneratedMessageProtocol.Type,
            IGChannelUpdateSignatureRequest.Handler.self    as IGRequest.Handler.Type),
    30425: (IGPChannelEditMessageResponse.self              as GeneratedMessageProtocol.Type,
            IGChannelEditMessageRequest.Handler.self        as IGRequest.Handler.Type),
    
    //Info: 305xx
    30500: (IGPInfoLocationResponse.self                    as GeneratedMessageProtocol.Type,
            IGInfoLocationRequest.Handler.self              as IGRequest.Handler.Type),
    30501: (IGPInfoCountryResponse.self                     as GeneratedMessageProtocol.Type,
            IGInfoCountryRequest.Handler.self               as IGRequest.Handler.Type),
    30503: (IGPInfoPageResponse.self                        as GeneratedMessageProtocol.Type,
            IGInfoPageRequest.Handler.self                  as IGRequest.Handler.Type),
    
    //Client: 306xx
    30600: (IGPClientConditionResponse.self                 as GeneratedMessageProtocol.Type,
            IGClientConditionRequest.Handler.self           as IGRequest.Handler.Type),
    30601: (IGPClientGetRoomListResponse.self               as GeneratedMessageProtocol.Type,
            IGClientGetRoomListRequest.Handler.self         as IGRequest.Handler.Type),
    30602: (IGPClientGetRoomResponse.self                   as GeneratedMessageProtocol.Type,
            IGClientGetRoomRequest.Handler.self             as IGRequest.Handler.Type),
    30603: (IGPClientGetRoomHistoryResponse.self            as GeneratedMessageProtocol.Type,
            IGClientGetRoomHistoryRequest.Handler.self      as IGRequest.Handler.Type),
    30605: (IGPClientSearchRoomHistoryResponse.self         as GeneratedMessageProtocol.Type,
            IGClientSearchRoomHistoryRequest.Handler.self   as IGRequest.Handler.Type),
    30606: (IGPClientResolveUsernameResponse.self           as GeneratedMessageProtocol.Type,
            IGClientResolveUsernameRequest.Handler.self     as IGRequest.Handler.Type),
    30607: (IGPClientCheckInviteLinkResponse.self           as GeneratedMessageProtocol.Type,
            IGClinetCheckInviteLinkRequest.Handler.self    as IGRequest.Handler.Type),
    30608: (IGPClientJoinByInviteLinkResponse.self          as GeneratedMessageProtocol.Type,
            IGClientJoinByInviteLinkRequest.Handler.self    as IGRequest.Handler.Type),
    30609: (IGPClientJoinByUsernameResponse.self            as GeneratedMessageProtocol.Type,
            IGClientJoinByUsernameRequest.Handler.self      as IGRequest.Handler.Type),
    30613: (IGPClientCountRoomHistoryResponse.self          as GeneratedMessageProtocol.Type,
            IGClientCountRoomHistoryRequest.Handler.self    as IGRequest.Handler.Type),
    
    //File: 307xx
    30700: (IGPFileUploadOptionResponse.self                as GeneratedMessageProtocol.Type,
            IGFileUploadOptionRequest.Handler.self          as IGRequest.Handler.Type),
    30701: (IGPFileUploadInitResponse.self                  as GeneratedMessageProtocol.Type,
            IGFileUploadInitRequest.Handler.self            as IGRequest.Handler.Type),
    30702: (IGPFileUploadResponse.self                      as GeneratedMessageProtocol.Type,
            IGFileUploadRequest.Handler.self                as IGRequest.Handler.Type),
    30703: (IGPFileUploadStatusResponse.self                as GeneratedMessageProtocol.Type,
            IGFileUploadStatusRequest.Handler.self          as IGRequest.Handler.Type),
    30704: (IGPFileInfoResponse.self                        as GeneratedMessageProtocol.Type,
            IGFileInfoRequest.Handler.self                  as IGRequest.Handler.Type),
    30705: (IGPFileDownloadResponse.self                    as GeneratedMessageProtocol.Type,
            IGFileDownloadRequest.Handler.self              as IGRequest.Handler.Type),
    
    //Push: 600xx
    60002: (IGPPushUserInfoExpiredResponse.self              as GeneratedMessageProtocol.Type,
           IGPushUserInfoExpiredRequest.Handler.self        as IGRequest.Handler.Type)
    
]

//login is not required for these methods
var withoutLoginMehotdsActionID : [Int] = [100, 101, 102, 500, 501, 502, 503]


class IGRequestManager {
    //MARK: Initilizers
    static let sharedManager = IGRequestManager()
    
    private let disposeBag = DisposeBag()
    private let timeoutSeconds: Double  = 15.0
    private var queuedRequests   = [String : IGRequestWrapper]()
    private var pendingRequests  = [String : IGRequestWrapper]()
    private var resolvedRequests = [String : IGRequestWrapper]()
    
    private init() {
        //send pending request and listen for network changes
        IGAppManager.sharedManager.connectionStatus.asObservable().subscribe(onNext: { (networkStatus) in
            if networkStatus == .connected {
                if self.queuedRequests.count > 0 {
                    self.queuedRequests.forEach {
                        let id = $0.key
                        let reqW = $0.value
                        self.queuedRequests.removeValue(forKey: id)
                        self.addRequestIDAndSend(requestWrappers: reqW)
                        
                    }
                }
            }
        }, onError: { (error) in
            
        }, onCompleted: { 
            
        }, onDisposed: {
            
        }).addDisposableTo(disposeBag)
        
        
        IGAppManager.sharedManager.isUserLoggedIn.asObservable().subscribe(onNext: { (loginState) in
            if loginState {
                if self.queuedRequests.count > 0 {
                    self.queuedRequests.forEach {
                        let id = $0.key
                        let reqW = $0.value
                        self.queuedRequests.removeValue(forKey: id)
                        self.addRequestIDAndSend(requestWrappers: reqW)
                    }
                }
            }
        }, onError: { (error) in
            
        }, onCompleted: {
            
        }, onDisposed: {
            
        }).addDisposableTo(disposeBag)
    }
    
    //MARK: Public Methods
    //MARK: Send
    func addRequestIDAndSend(requestWrappers : IGRequestWrapper ...) {
        for requestWrapper in requestWrappers {
            //TODO: handle batch requests
            var shouldSendRequest = false
            
            if IGAppManager.sharedManager.connectionStatus.value == .connected {
                if IGAppManager.sharedManager.isUserLoggedIn.value {
                    shouldSendRequest = true
                } else if withoutLoginMehotdsActionID.contains(requestWrapper.actionId) {
                    shouldSendRequest = true
                }
            }
            
            if shouldSendRequest {
                if let request = generateIGRequestObject() {
                    pendingRequests[request.igpId] = requestWrapper
                    requestWrapper.id = request.igpId
                    _ = requestWrapper.message.setIgpRequest(request)
                    IGWebSocketManager.sharedManager.send(requestW: requestWrapper)
                    DispatchQueue.main.asyncAfter(deadline: .now() + timeoutSeconds , execute: {
                        self.internalTimeOut(for: requestWrapper)
                    })
                }
            } else {
                let randomID = generateRandomRequestID()
                queuedRequests[randomID] = requestWrapper
            }
        }
    }
    
    func userDidLogout() {
        queuedRequests   = [String : IGRequestWrapper]()
        pendingRequests  = [String : IGRequestWrapper]()
        resolvedRequests = [String : IGRequestWrapper]()
    }
    
//    func requestWrapperForReponse(_ response:IGPResponse) -> IGRequestWrapper? {
//        let requestWrapper = pendingRequests[response.igpId]
//        if requestWrapper != nil {
//            return requestWrapper
//        }
//        return nil
//    }
    
    //MARK: Receive
    func didReceive(decryptedData: NSData) {
        //var convertedData = NSData(data: decryptedData)
        let firstTwoByte = decryptedData.subdata(with: NSMakeRange(0, 2))
        let payload = decryptedData.subdata(with: NSMakeRange(2, decryptedData.length-2))
        var actionIDArray = [UInt8](repeating:0, count:firstTwoByte.count)
        firstTwoByte.copyBytes(to: &actionIDArray, count: firstTwoByte.count)
        actionIDArray.reverse() // this line is because the actionID is little-endian
        
        var actionID = 0
        for byte in actionIDArray {
            actionID = actionID << 8
            actionID = actionID | Int(byte)
        }
        
        print("✦ \(NSDate.timeIntervalSinceReferenceDate) ----- ➤➤➤ Action ID: \(actionID)")
    
        if let lookupTableResult = protoClassesLookupTable[actionID] {
            let protoClassName = lookupTableResult.proto
            do {
                let responseProtoMessage = try protoClassName.parseFrom(data: payload) as! GeneratedResponseMessage
                let requestHandlerClassName = lookupTableResult.reponseHandler
                if let response = responseProtoMessage.igpResponse {
                    //check if this is a `reponse` or a `push`
                    if let correspondingRequestWrapper = pendingRequests[response.igpId] {
                        if actionID == 0 { //-> failed
                            let errorProtoMessage = responseProtoMessage as! IGPErrorResponse
                            print("✘ \(NSDate.timeIntervalSinceReferenceDate) ----- ✘✘✘✘✘✘ Major Code: \(errorProtoMessage.igpMajorCode)")
                            print("✘ \(NSDate.timeIntervalSinceReferenceDate) ----- ✘✘✘✘✘✘ Minor Code: \(errorProtoMessage.igpMinorCode)")
                            
                            let errorData = IGErrorRequest.Handler.interpret(response: errorProtoMessage)
                            
                            if let error = correspondingRequestWrapper.error {
                                error(errorData.error, errorData.wait)
                            }
                        } else { // -> successful
                            if let sucess = correspondingRequestWrapper.success {
                                sucess(responseProtoMessage)
                            } else {
                                requestHandlerClassName.handlePush(responseProtoMessage: responseProtoMessage)
                            }
                        }
                        resolvedRequests[response.igpId] = correspondingRequestWrapper
                        pendingRequests[response.igpId]  = nil
                    } else if resolvedRequests[response.igpId] != nil {
                        print ("✦ \(NSDate.timeIntervalSinceReferenceDate) ----- Response is already resolved")
                    } else {
                        //this is a `pushed` message
                        //call its corresponding handler class to handle push
                        requestHandlerClassName.handlePush(responseProtoMessage: responseProtoMessage)
                    }
                } else {
                    print ("✦ \(NSDate.timeIntervalSinceReferenceDate) ----- Response without IGResponse Property")
                }
            } catch let error {
                print ("✦ \(NSDate.timeIntervalSinceReferenceDate) ----- Error Parsing Proto From Binary Data")
                print (error)
            }
            
        } else {
            //at this point ignore this data
            //maybe new command (protos) added to server but
            //not supported yet by this version of iOS client
            print ("✦ \(NSDate.timeIntervalSinceReferenceDate) ----- Unsupported action ID")
        }
    }
    
    
    func internalTimeOut(for requestWrapper: IGRequestWrapper) {
        //check if request is still pending 
        if pendingRequests[requestWrapper.id] != nil {
            resolvedRequests[requestWrapper.id] = requestWrapper
            pendingRequests[requestWrapper.id]  = nil
            if let error = requestWrapper.error {
                error(.timeout, nil)
            }
        }
    }
    
    //MARK: Private Methods
    func generateIGRequestObject() -> IGPRequest? {
        let requestBuilder = IGPRequest.Builder()
        requestBuilder.setIgpId(generateRandomRequestID())
        do {
            let request = try requestBuilder.build()
            return request
        } catch {
            
        }
        return nil
    }
    
    private func generateRandomRequestID() -> String {
        return IGGlobal.randomString(length: 48)
    }
    
    private func generateRandomBatchID() -> String {
        return IGGlobal.randomString(length: 48)
    }
    
}

