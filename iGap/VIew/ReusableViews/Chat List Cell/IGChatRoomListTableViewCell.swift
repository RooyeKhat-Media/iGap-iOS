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
import MGSwipeTableCell
import RxSwift
import IGProtoBuff
import SwiftProtobuf
import GrowingTextView
import pop
import SnapKit
import AVFoundation
import DBAttachmentPickerControllerLibrary
import INSPhotoGalleryFramework
import AVKit
import RealmSwift
import RxRealm
import RxSwift
import RxCocoa
import MBProgressHUD

class IGChatRoomListTableViewCell: MGSwipeTableCell {
    
    @IBOutlet weak var avatarView: IGAvatarView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var lastMessageStatusContainerView: UIView!
    @IBOutlet weak var deliveryStateImageView: UIImageView!
    @IBOutlet weak var unreadCountLabel: UILabel!
    @IBOutlet weak var lastMessageStatusContainerViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var roomTypeIndicatorImageView: UIImageView!
    @IBOutlet weak var roomTitleLabelLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var imgMute: UIImageView!
    
    let currentLoggedInUserID = IGAppManager.sharedManager.userID()
    
    var room: IGRoom?
    var lastMessageStatusContainerViewWidthConstraintDefault: CGFloat = 18.0
    var roomVariableFromRoomManagerCache: Variable<IGRoom>?
    var users = try! Realm().objects(IGRegisteredUser.self)
    let disposeBag = DisposeBag()
    
    //MARK: - Class Methods
    class func nib() -> UINib {
        return UINib(nibName: "IGChatRoomListTableViewCell", bundle: Bundle(for: self))
    }
    
    class func cellReuseIdentifier() -> String {
        return NSStringFromClass(self)
    }
    
    
    //MARK: - Instance Methods
    //MARK: Initializers
    override func awakeFromNib() {
        super.awakeFromNib()
        lastMessageStatusContainerView.layer.cornerRadius = 9.0
        lastMessageStatusContainerView.layer.masksToBounds = true
        
        contentView.backgroundColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
        self.initialConfiguration()
        
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(getUserAvatarAgain(_:)),
                                               name: NSNotification.Name(rawValue: kIGNoticationForPushUserExpire),
                                               object: nil)

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.initialConfiguration()
    }
    
    func getUserAvatarAgain(_ aNotification: Notification) {
        if let userId = aNotification.userInfo?["user"] as? Int64{
            let predicate = NSPredicate(format: "id = %lld", userId )
            if let userInDb = try! Realm().objects(IGRegisteredUser.self).filter(predicate).first {
             // setUserStatus(userInDb)
            }
            IGChatGetRoomRequest.Generator.generate(peerId: userId).success({ (protoResponse) in
                 DispatchQueue.main.async {
                  switch protoResponse {
                  case let chatGetRoomResponse as IGPChatGetRoomResponse:
                    let roomId =  IGChatGetRoomRequest.Handler.interpret(response: chatGetRoomResponse)
                    if self.room?.id == roomId {
                        self.setRoom(room: self.room!)
                    }
                default:
                    break
                }
                }
                
                //avatarView.setUser(user)
                
            }).error({ (errorCode, waitTime) in
                
            }).send()
            
            
        }
    }
    
    func setUserStatus(_ user: IGRegisteredUser) {
        

        
    }

    
    func initialConfiguration() {
        self.selectionStyle = .none
        lastMessageStatusContainerView.backgroundColor = UIColor.red
        avatarView.clean()
        nameLabel.text = ""
        lastMessageLabel.text = ""
        timeLabel.text = ""
        deliveryStateImageView.image = nil
        roomVariableFromRoomManagerCache = nil
        roomTypeIndicatorImageView.image = nil
    }
    
    deinit {
        roomVariableFromRoomManagerCache = nil
    }
    
    //MARK: Configure
    func setRoom(room: IGRoom) {
        self.room = room
        avatarView.setRoom(room)
        
        switch room.type {
        case .chat:
            roomTypeIndicatorImageView.image = nil
            roomTitleLabelLeftConstraint.constant = 16
        case .group:
            roomTypeIndicatorImageView.image = UIImage(named: "IG_Chat_List_Type_Group")
            roomTitleLabelLeftConstraint.constant = 36
        case .channel:
            roomTypeIndicatorImageView.image = UIImage(named: "IG_Chat_List_Type_Channel")
            roomTitleLabelLeftConstraint.constant = 36
        }

        if room.mute == IGRoom.IGRoomMute.mute {
            lastMessageStatusContainerView.backgroundColor = UIColor.gray
            imgMute.image = UIImage(named: "IG_Chat_List_Mute")
            imgMute.isHidden = false
        } else {
            lastMessageStatusContainerView.backgroundColor = UIColor.red
            imgMute.isHidden = true
        }
        
        if room.pinId > 0 {
            contentView.backgroundColor = UIColor(red: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 1.0)
        } else {
            contentView.backgroundColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
        }
        
        if room.unreadCount > 0 {
            nameLabel.font = UIFont.igFont(ofSize: 15.0, weight: .bold)
            nameLabel.textColor = UIColor.black
            
            lastMessageLabel.font = UIFont.igFont(ofSize: 14.0, weight: .medium)
            lastMessageLabel.textColor = UIColor(red: 34.0/255.0, green: 34.0/255.0, blue: 34.0/255.0, alpha: 1.0)
            
            timeLabel.font = UIFont.igFont(ofSize: 12.0, weight: .regular)
            timeLabel.textColor = UIColor.black
            
        } else {
            nameLabel.font = UIFont.igFont(ofSize: 15.0, weight: .regular)
            nameLabel.textColor = UIColor(red: 38.0/255.0, green: 38.0/255.0, blue: 38.0/255.0, alpha: 1.0)
            
            lastMessageLabel.font = UIFont.igFont(ofSize: 14.0, weight: .regular)
            lastMessageLabel.textColor = UIColor(red: 127.0/255.0, green: 127.0/255.0, blue: 127.0/255.0, alpha: 1.0)
            
            timeLabel.font = UIFont.igFont(ofSize: 12.0, weight: .regular)
            timeLabel.textColor = UIColor(red: 132.0/255.0, green: 132.0/255.0, blue: 132.0/255.0, alpha: 1.0)
        }
        if room.draft != nil && (room.draft?.message != "" || room.draft?.replyTo != -1) {
            lastMessageLabel.font = UIFont.igFont(ofSize: 14.0)//.italic()
        }
        
        
        self.nameLabel.text = room.title
// Commented this codes for avoid from crash after logout and login again
//        if let roomVariable = IGRoomManager.shared.varible(for: room) {
//            roomVariableFromRoomManagerCache = roomVariable
//            roomVariableFromRoomManagerCache?.asObservable().subscribe({ (event) in
//
//                DispatchQueue.main.async {
//                    if self.roomVariableFromRoomManagerCache?.value.id != room.id {
//                        return
//                    }
//                    if self.roomVariableFromRoomManagerCache?.value.currenctActionsByUsers.count != 0 {
//                        self.lastMessageLabel.text = self.roomVariableFromRoomManagerCache!.value.currentActionString() + " ..."
//                    } else {
//                        self.setLastMessage(for: room)
//                    }
//                }
//            }).addDisposableTo(disposeBag)
//        }
        
        setLastMessage(for: room)
        
        
        if room.unreadCount > 0 {
            lastMessageStatusContainerView.isHidden = false
            deliveryStateImageView.isHidden = true
            unreadCountLabel.isHidden = false
            unreadCountLabel.text = "\(room.unreadCount)"
           // self.sendDeliveredMessage()
            let labelFrame = unreadCountLabel.textRect(forBounds: CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: 18.0) , limitedToNumberOfLines: 1)
            lastMessageStatusContainerViewWidthConstraint.constant = max(lastMessageStatusContainerViewWidthConstraintDefault, labelFrame.size.width + 8)
        } else {
            var isLastMessageIncomming = true
            lastMessageStatusContainerViewWidthConstraint.constant = lastMessageStatusContainerViewWidthConstraintDefault
            if let lastMessage = room.lastMessage {
                if let senderUser = lastMessage.authorUser {
                    if senderUser.id == currentLoggedInUserID {
                        isLastMessageIncomming = false
                    }
                }
            }

            if room.pinId > 0 {
                lastMessageStatusContainerView.isHidden = false
                deliveryStateImageView.isHidden = false
                unreadCountLabel.isHidden = true
                deliveryStateImageView.image = UIImage(named: "IG_Chat_List_Pin")
                lastMessageStatusContainerView.backgroundColor = UIColor.clear
            } else {

                if isLastMessageIncomming {
                    lastMessageStatusContainerView.isHidden = true
                    deliveryStateImageView.isHidden = true
                    unreadCountLabel.isHidden = true
                    
                } else {
                    lastMessageStatusContainerView.isHidden = false
                    deliveryStateImageView.isHidden = false
                    unreadCountLabel.isHidden = true
                    if let lastMessage = room.lastMessage {
                        switch lastMessage.status {
                        case .sending:
                            deliveryStateImageView.image = UIImage(named: "IG_Chat_List_Delivery_State_Pending")
                            lastMessageStatusContainerView.backgroundColor = UIColor.clear
                            break
                        case .sent:
                            deliveryStateImageView.image = UIImage(named: "IG_Chat_List_Delivery_State_Sent")
                            lastMessageStatusContainerView.backgroundColor = UIColor.clear
                            break
                        case .delivered:
                            deliveryStateImageView.image = UIImage(named: "IG_Chat_List_Delivery_State_Delivered")
                            lastMessageStatusContainerView.backgroundColor = UIColor.clear
                            break
                        case .seen:
                            deliveryStateImageView.image = UIImage(named: "IG_Chat_List_Delivery_State_Seen")
                            lastMessageStatusContainerView.backgroundColor = UIColor.clear
                            break
                        case .failed:
                            deliveryStateImageView.image = UIImage(named: "IG_Chat_List_Delivery_State_Failed")
                            lastMessageStatusContainerView.backgroundColor = UIColor.red
                            break
                        default:
                            break
                        }
                    }
                }
            }
        }
    }
    
    
    private func setLastMessage(for room: IGRoom) {
        if let draft = room.draft, (room.draft?.message != "" || room.draft?.replyTo != -1) {
            if let lastMessage = room.lastMessage {
                self.timeLabel.text = lastMessage.creationTime?.convertToHumanReadable(onlyTimeIfToday: true)
            } else {
                self.timeLabel.text = ""
            }
            self.lastMessageLabel.text = "Draft: \(draft.message)"
        } else if let lastMessage = room.lastMessage {
            self.timeLabel.text = lastMessage.creationTime?.convertToHumanReadable(onlyTimeIfToday: true)
            if let forwarded = lastMessage.forwardedFrom {
                if let user = forwarded.authorUser {
                    self.lastMessageLabel.text = "Forwared message from \(user.displayName)"
                } else if let title = forwarded.authorRoom?.title {
                    self.lastMessageLabel.text = "Forwared message from \(title)"
                } else {
                    self.lastMessageLabel.text = "Forwared message"
                }
            } else {
                switch lastMessage.type {
                case .audioAndText, .gifAndText, .fileAndText, .imageAndText, .videoAndText, .text:
                    self.lastMessageLabel.text = lastMessage.message
                case .image:
                    self.lastMessageLabel.text = "Image"
                case .video:
                    self.lastMessageLabel.text = "Video"
                case .gif:
                    self.lastMessageLabel.text = "Gif"
                case .audio:
                    self.lastMessageLabel.text = "Audio message"
                case .voice:
                    self.lastMessageLabel.text = "Voice message"
                case .file:
                    if let name = lastMessage.attachment?.name {
                        self.lastMessageLabel.text = name
                    } else {
                        self.lastMessageLabel.text = "File"
                    }
                default:
                    self.lastMessageLabel.text = "Some other type of message"
                    break
                }
            }
            if lastMessage.type == .log {
                self.lastMessageLabel.text = IGRoomMessageLog.textForLogMessage(lastMessage)
            }
        } else {
            self.timeLabel.text = ""
            self.lastMessageLabel.text  = ""
        }
    }
    func sendDeliveredMessage(){
        if let message = self.room?.lastMessage{
            switch self.room!.type {
            case .chat:
                IGChatUpdateStatusRequest.Generator.generate(roomID: self.room!.id, messageID: message.id, status: .delivered).success({ (responseProto) in
                    switch responseProto {
                    case let response as IGPChatUpdateStatusResponse:
                        IGChatUpdateStatusRequest.Handler.interpret(response: response)
                    default:
                        break
                    }
                }).error({ (errorCode, waitTime) in
                    
                }).send()
            case .group:
                IGGroupUpdateStatusRequest.Generator.generate(roomID: self.room!.id, messageID: message.id, status: .delivered).success({ (responseProto) in
                    switch responseProto {
                    case let response as IGPGroupUpdateStatusResponse:
                        IGGroupUpdateStatusRequest.Handler.interpret(response: response)
                    default:
                        break
                    }
                }).error({ (errorCode, waitTime) in
                    
                }).send()
                break
            case .channel:
                    IGChannelGetMessagesStatsRequest.Generator.generate(messages: [message], room: self.room!).success({ (responseProto) in
                        
                    }).error({ (errorCode, waitTime) in
                        
                    }).send()
            }
        }
    }
}
