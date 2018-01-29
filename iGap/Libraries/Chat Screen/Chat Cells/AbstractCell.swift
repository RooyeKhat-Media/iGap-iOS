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
import SnapKit

class AbstractCell: IGMessageGeneralCollectionViewCell {
    
    var mainBubbleViewAbs: UIView!
    var forwardViewAbs: UIView?
    var replyViewAbs: UIView?
    var mediaContainerViewAbs: UIView?
    var avatarBackViewAbs: UIView?
    var messageViewAbs: UIView?
    var replyLineViewAbs: UIView!
    
    var txtSenderNameAbs: UILabel!
    var txtEditedAbs: UILabel!
    var txtTimeAbs: UILabel!
    var txtReplyDisplayNameAbs: UILabel!
    var txtReplyMessageAbs: UILabel!
    var txtForwardAbs: UILabel!
    
    var imgStatusAbs: UIImageView!
    var imgMediaAbs: UIImageView?
    
    var txtMessageHeightConstraintAbs: NSLayoutConstraint!
    var mainBubbleViewWidthAbs: NSLayoutConstraint!
    var mainBubbleViewLeadingAbs: NSLayoutConstraint!
    var mainBubbleViewTrailingAbs: NSLayoutConstraint!
    var forwardHeightAbs: NSLayoutConstraint!
    
    var realmRoomMessage: IGRoomMessage!

    var avatarViewAbs: IGAvatarView?
    var txtMessageAbs: ActiveLabel!
    var txtForwardedMessageAbs: ActiveLabel!
    
    var isIncommingMessage: Bool!
    var shouldShowAvatar: Bool!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.transform = CGAffineTransform(scaleX: 1.0, y: -1.0)
        self.backgroundColor = UIColor.clear
    }
    
    private func addForward(){
        
    }
    
    override func setMessage(_ message: IGRoomMessage, isIncommingMessage: Bool, shouldShowAvatar: Bool, messageSizes: RoomMessageCalculatedSize, isPreviousMessageFromSameSender: Bool, isNextMessageFromSameSender: Bool) {
        txtMessageAbs.text = ""
        self.realmRoomMessage = message
        self.isIncommingMessage = isIncommingMessage
        self.shouldShowAvatar = shouldShowAvatar
        
        /* main bubble view */
        mainBubbleViewAbs.layer.cornerRadius = 18
        mainBubbleViewAbs.layer.masksToBounds = true
        mainBubbleViewAbs.layer.borderColor = UIColor(red: 179.0/255.0, green: 179.0/255.0, blue: 179.0/255.0, alpha: 1.0).cgColor
        mainBubbleViewAbs.backgroundColor = UIColor.chatBubbleBackground(isIncommingMessage: isIncommingMessage)
        
        txtMessageAbs.font = IGMessageCollectionViewCell.messageBodyTextViewFont()
        
        detectLink()
        addGustureRecognizers()
        manageRecivedOrIncommingMessage()
        setMessageStatus()
        manageReply()
        manageForward()
        
        // seems to not worked !!!
        //mainBubbleViewWidthAbs.constant = messageSizes.bubbleSize.width
        //mainBubbleViewWidthAbs.priority = 1000
        
        
        if isPreviousMessageFromSameSender {
            avatarViewAbs?.isHidden = true
            avatarBackViewAbs?.isHidden = true
            txtSenderNameAbs?.isHidden = true
        } else {
            txtSenderNameAbs?.isHidden = false
        }

        if  message.message != nil && message.message != "" {
            txtMessageAbs?.text = message.message
            messageViewAbs?.isHidden = false
            txtMessageAbs?.isHidden = false
            messageViewAbs?.backgroundColor = UIColor.clear
            txtMessageAbs?.textColor = UIColor.chatBubbleTextColor(isIncommingMessage: isIncommingMessage)
            txtMessageHeightConstraintAbs?.constant = messageSizes.messageBodyHeight
        }

        if let time = message.creationTime {
            txtTimeAbs?.text = time.convertToHumanReadable()
            txtTimeAbs?.textColor = UIColor.chatTimeTextColor(isIncommingMessage: isIncommingMessage)
        }

        if message.isEdited {
            txtEditedAbs?.isHidden = false
            txtEditedAbs?.textColor = UIColor.chatTimeTextColor(isIncommingMessage: isIncommingMessage)
        } else {
            txtEditedAbs?.isHidden = true
        }
    }
    
    /*
     ******************************************************************
     ****************************** Reply *****************************
     ******************************************************************
     */
    
    private func manageReply(){
        if let repliedMessage = realmRoomMessage.repliedTo {

            replyViewAbs?.isHidden                = false
            replyLineViewAbs.isHidden             = false
            txtReplyDisplayNameAbs.isHidden       = false
            txtReplyMessageAbs.isHidden           = false
            
            replyViewAbs?.backgroundColor         = UIColor.chatReplyToBackgroundColor(isIncommingMessage: isIncommingMessage)
            replyLineViewAbs.backgroundColor      = UIColor.chatReplyToIndicatorViewColor(isIncommingMessage: isIncommingMessage)
            txtReplyDisplayNameAbs.textColor      = UIColor.chatReplyToUsernameLabelTextColor(isIncommingMessage: isIncommingMessage)
            txtReplyMessageAbs.textColor          = UIColor.chatReplyToMessageBodyLabelTextColor(isIncommingMessage: isIncommingMessage)
            
            
            if let user = repliedMessage.authorUser {
                txtReplyDisplayNameAbs.text = user.displayName
            }
            
            if repliedMessage.type == .contact {
                txtReplyMessageAbs.text = "Contact"
            }else if let body = repliedMessage.message {
                txtReplyMessageAbs.text = body
            } else if let media = repliedMessage.attachment {
                txtReplyMessageAbs.text = media.name
            } else {
                txtReplyMessageAbs.text = ""
            }
            
            if forwardHeightAbs != nil {
                forwardHeightAbs.constant = 0
            }
            replyViewAbs?.snp.makeConstraints{ (make) in
                make.top.equalTo(mainBubbleViewAbs.snp.top).priority(100)
            }

            txtMessageAbs.snp.remakeConstraints{ (make) in
                make.top.equalTo((replyViewAbs?.snp.bottom)!).offset(3)
                make.height.greaterThanOrEqualTo(10).priority(.high)
            }
            
            
        } else {
            txtMessageAbs.snp.remakeConstraints{ (make) in
                make.centerY.equalTo(mainBubbleViewAbs.snp.centerY)
            }
            replyViewAbs?.isHidden = true
        }
    }
    
    /*
     ******************************************************************
     ************************* Status Manager *************************
     ******************************************************************
     */
    
    private func setMessageStatus(){
        switch realmRoomMessage.status {
        case .sending:
            imgStatusAbs.image = UIImage(named: "IG_Message_Cell_State_Sending")
        case .sent:
            imgStatusAbs.image = UIImage(named: "IG_Message_Cell_State_Sent")
        case .delivered:
            imgStatusAbs.image = UIImage(named: "IG_Message_Cell_State_Delivered")
        case .seen,.listened:
            imgStatusAbs.image = UIImage(named: "IG_Message_Cell_State_Seen")
        case .failed, .unknown:
            imgStatusAbs.image = nil // TODO - Saeed - show failed icon for failed message
        }
    }
    
    /*
     ******************************************************************
     *************************** Set Avatar ***************************
     ******************************************************************
     */
    
    private func setAvatar(){
        
        if shouldShowAvatar {
            avatarViewAbs?.isHidden = false
            avatarBackViewAbs?.isHidden = false // avatar back view is redundant. why we should use this ?!!!
            
            if let user = realmRoomMessage.authorUser {
                avatarViewAbs?.setUser(user)
            }
            
            mainBubbleViewLeadingAbs.constant = 46
        } else {
            
            avatarViewAbs?.isHidden = true
            avatarBackViewAbs?.isHidden = true
            
            mainBubbleViewLeadingAbs.constant = 16
        }
    }
    
    /*
     ******************************************************************
     ********** Detect and Manage Received/Incomming Message **********
     ******************************************************************
     */
    
    private func manageRecivedOrIncommingMessage(){
        if isIncommingMessage {
            mainBubbleViewAbs?.layer.borderWidth = 0.0
            if let sender = realmRoomMessage.authorUser {
                txtSenderNameAbs.text = sender.displayName
            } else if let sender = realmRoomMessage.authorRoom {
                txtSenderNameAbs.text = sender.title
            } else {
                txtSenderNameAbs.text = ""
            }
            imgStatusAbs.isHidden = true
            
            setAvatar()
            
        } else {
            mainBubbleViewAbs?.layer.borderWidth = 1.0
            txtSenderNameAbs.text = ""
            imgStatusAbs?.isHidden = false
            avatarViewAbs?.isHidden = true
            avatarBackViewAbs?.isHidden = true
            txtSenderNameAbs.isHidden = true
        }
    }
    
    /*
     ******************************************************************
     ************************** Link Manager **************************
     ******************************************************************
     */
    private func detectLink(){
        linkManager(txtMessage: txtMessageAbs)
        
        // don't used
        //txtForwardedMessageAbs.text = nil
        linkManager(txtMessage: txtForwardedMessageAbs)
    }
    
    private func linkManager(txtMessage: ActiveLabel?){
        if txtMessage == nil {
            return
        }
        
        txtMessage?.font = IGMessageCollectionViewCell.messageBodyTextViewFont()
        txtMessage?.customize { (label) in
            let customInvitedLink = ActiveType.custom(pattern: "((?:http|https)://)?[iGap\\.net]+(\\.\\w{0})?(/(?<=/)(?:[\\join./]+[a-zA-Z0-9]{2,}))") //look for iGap.net/join/
            label.enabledTypes.append(customInvitedLink)
            label.hashtagColor = UIColor(red:0.23, green:0.65, blue:0.57, alpha:1.00)
            label.mentionColor = UIColor.organizationalColor()
            label.URLColor = UIColor(red:0.24, green:0.47, blue:0.51, alpha:1.00)
            label.customColor[customInvitedLink] = UIColor.organizationalColor()
            
            label.handleMentionTap { mention in
                self.delegate?.didTapOnMention(mentionText: mention ) }
            label.handleHashtagTap { hashtag in
                self.delegate?.didTapOnHashtag(hashtagText: hashtag) }
            label.handleURLTap { url in
                self.delegate?.didTapOnURl(url: url) }
            label.handleCustomTap(for:customInvitedLink) { self.delegate?.didTapOnRoomLink(link: $0) }
        }
    }
    
    /*
     ******************************************************************
     *********************** Gesture Recognizer ***********************
     ******************************************************************
     */
    
    func addGustureRecognizers() {
        let tapAndHold = UILongPressGestureRecognizer(target: self, action: #selector(didTapAndHoldOnCell(_:)))
        tapAndHold.minimumPressDuration = 0.2
        mainBubbleViewAbs.addGestureRecognizer(tapAndHold)
        mainBubbleViewAbs.isUserInteractionEnabled = true
        
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(didTapOnAttachment(_:)))
        mediaContainerViewAbs?.addGestureRecognizer(tap1)
        mediaContainerViewAbs?.isUserInteractionEnabled = true

        let tap2 = UITapGestureRecognizer(target: self, action: #selector(didTapOnAttachment(_:)))
        imgMediaAbs?.addGestureRecognizer(tap2)
        imgMediaAbs?.isUserInteractionEnabled = true
        
        // don't used yet
        //let tap3 = UITapGestureRecognizer(target: self, action: #selector(didTapOnAttachment(_:)))
        //self.attachmentContainreView.addGestureRecognizer(tap3)
        //self.attachmentContainreView.isUserInteractionEnabled = true
        //let tap4 = UITapGestureRecognizer(target: self, action:  #selector(didTapOnForwardedAttachment(_:)))
        //self.forwardedMessageAudioAndVoiceView.addGestureRecognizer(tap4)
        //self.forwardedMessageAudioAndVoiceView.isUserInteractionEnabled = true
        
        let tap5 = UITapGestureRecognizer(target: self, action: #selector(didTapOnSenderAvatar(_:)))
        avatarViewAbs?.addGestureRecognizer(tap5)
    }
    
    func didTapAndHoldOnCell(_ gestureRecognizer: UILongPressGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            self.delegate?.didTapAndHoldOnMessage(cellMessage: realmRoomMessage!, cell: self)
        default:
            break
        }
    }
    
    func didTapOnAttachment(_ gestureRecognizer: UITapGestureRecognizer) {
        self.delegate?.didTapOnAttachment(cellMessage: realmRoomMessage!, cell: self)
    }
    
    func didTapOnForwardedAttachment(_ gestureRecognizer: UITapGestureRecognizer) {
        self.delegate?.didTapOnForwardedAttachment(cellMessage: realmRoomMessage!, cell: self)
        
    }
    
    func didTapOnSenderAvatar(_ gestureRecognizer: UITapGestureRecognizer) {
        self.delegate?.didTapOnSenderAvatar(cellMessage: realmRoomMessage!, cell: self)
    }
    
    
    /*
     ******************************************************************
     ***************************** Forward ****************************
     ******************************************************************
     */
    
    func manageForward(){
        
        if let originalMessage = realmRoomMessage.forwardedFrom {
            forwardViewAbs?.isHidden  = false
            forwardViewAbs?.backgroundColor           = UIColor.chatForwardedFromViewBackgroundColor(isIncommingMessage: isIncommingMessage)
            txtForwardAbs.textColor                   = UIColor.chatForwardedFromUsernameLabelColor(isIncommingMessage: isIncommingMessage)
            
            if let user = originalMessage.authorUser {
                txtForwardAbs.text = "Forwarded from: \(user.displayName)"
            } else if let room = originalMessage.authorRoom {
                txtForwardAbs.text = "Forwarded from: \(room.title != nil ? room.title! : "")"
            } else {
                txtForwardAbs.text = "Forwarded from: "
            }
            forwardHeightAbs.constant = 30
            
            let text = originalMessage.message
            if text != nil && text != "" {
                txtMessageAbs.text = text
            }
            
            /*
             * set priority bigger than replyViewAbs priority
             */
            forwardViewAbs?.snp.makeConstraints{ (make) in
                make.top.equalTo(mainBubbleViewAbs.snp.top).priority(200)
            }
            
            txtMessageAbs.snp.remakeConstraints{ (make) in
                make.top.equalTo((forwardViewAbs?.snp.bottom)!).offset(3)
            }
            
            //MARK: ▶︎ Forward Attachment
            //        if var attachment = originalMessage.attachment {
            //            if let attachmentVariableInCache = IGAttachmentManager.sharedManager.getRxVariable(attachmentPrimaryKeyId: attachment.primaryKeyId!) {
            //                self.forwardedAttachment = attachmentVariableInCache.value
            //            } else {
            //                self.forwardedAttachment = attachment.detach()
            //                let attachmentRef = ThreadSafeReference(to: attachment)
            //                IGAttachmentManager.sharedManager.add(attachmentRef: attachmentRef)
            //                self.forwardedAttachment = IGAttachmentManager.sharedManager.getRxVariable(attachmentPrimaryKeyId: attachment.primaryKeyId!)!.value
            //            }
            //            //MARK: ▶︎ Rx Start
            //            if let variableInCache = IGAttachmentManager.sharedManager.getRxVariable(attachmentPrimaryKeyId: attachment.primaryKeyId!) {
            //                attachment = variableInCache.value
            //                variableInCache.asObservable().subscribe({ (event) in
            //                    DispatchQueue.main.async {
            //                        self.updateForwardedAttachmentDownloadUploadIndicatorView()
            //                    }
            //                }).addDisposableTo(disposeBag)
            //            } else {
            //
            //            }
            //            //MARK: ▶︎ Rx End
            //            switch (originalMessage.type) {
            //            case .image, .imageAndText, .video, .videoAndText, .gif, .gifAndText:
            //                self.forwardedMessageAudioAndVoiceViewHeightConstraint.constant = 0
            //                self.forwardedMessageMediaImageView.isHidden = false
            //                self.forwardedMessageMediaContainerView.isHidden = false
            //                let progress = Progress(totalUnitCount: 100)
            //                progress.completedUnitCount = 0
            //
            //                self.forwardedMessageMediaImageView.setThumbnail(for: attachment)
            //                self.forwardedMessageMediaContainerViewHeightConstraint.constant = messageSizes.forwardedMessageAttachmentHeight //+ 20
            //
            //                if attachment.status != .ready {
            //                    self.forwardedMediaDownloadUploadIndicatorView.size = attachment.sizeToString()
            //                    self.forwardedMediaDownloadUploadIndicatorView.delegate = self
            //                }
            //                if originalMessage.type == .gif || originalMessage.type == .gifAndText {
            //                    attachment.loadData()
            //                    if let data = attachment.data {
            //                        self.forwardedMessageMediaImageView.prepareForAnimation(withGIFData: data)
            //                        self.forwardedMessageMediaImageView.startAnimatingGIF()
            //                    } else {
            //                        self.downloadUploadIndicatorDidTapOnStart(self.forwardedMediaDownloadUploadIndicatorView)
            //
            //                    }
            //                }
            //                break
            //            case .voice :
            //                self.forwardedMessageMediaContainerViewHeightConstraint.constant = 0
            //                self.forwardedMessageAudioAndVoiceView.isHidden = false
            //                self.forwardedMessageAudioAndVoiceViewHeightConstraint.constant = messageSizes.forwardedMessageAttachmentHeight
            //                forwardMediaFileAttachment = IGForwardMessageAudioAndVoiceAttachmentView()
            //                forwardMediaFileAttachment?.setMediaPlayerCell(attachment)
            //                self.forwardedMessageAudioAndVoiceView.addSubview(forwardMediaFileAttachment!)
            //                forwardMediaFileAttachment?.attachment = attachment
            //                break
            //
            //            case .audio , .audioAndText :
            //
            //                self.mediaContainerViewHeightConstraint.constant = 0
            //                self.attachmentViewHeightConstraint.constant = 91.0
            //                self.attachmentContainreView.isHidden = false
            //                self.attachmentThumbnailImageView.isHidden = false
            //                self.attachmentFileNameLabel.isHidden = false
            //                self.attachmentFileArtistLabel.isHidden = false
            //                self.attachmentProgressSlider.isHidden = false
            //                self.attachmentTimeOrSizeLabel.isHidden = false
            //                self.attachmentFileNameLabel.text = attachment.name
            //                if isIncommingMessage {
            //                    self.attachmentProgressSlider.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb"), for: .normal)
            //                    self.attachmentProgressSlider.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb"), for: .focused)
            //                    self.attachmentProgressSlider.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb"), for: .selected)
            //                    self.attachmentProgressSlider.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb"), for: .highlighted)
            //                } else {
            //                    self.attachmentProgressSlider.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb_Outgoing"), for: .normal)
            //                    self.attachmentProgressSlider.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb_Outgoing"), for: .focused)
            //                    self.attachmentProgressSlider.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb_Outgoing"), for: .selected)
            //                    self.attachmentProgressSlider.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb_Outgoing"), for: .highlighted)
            //                }
            //
            //                self.attachmentProgressSlider.setValue(0.0, animated: false)
            //                self.attachmentThumbnailImageView.setThumbnail(for: attachment)
            //                self.attachmentProgressSliderLeadingConstraint.constant = 8.0
            //                self.attachmentThumbnailImageView.layer.cornerRadius = 16.0
            //                self.attachmentThumbnailImageView.layer.masksToBounds = true
            //                if self.attachment?.status != .ready {
            //                    self.attachmentDownloadUploadIndicatorView.layer.cornerRadius = 16.0
            //                    self.attachmentDownloadUploadIndicatorView.layer.masksToBounds = true
            //                    self.attachmentDownloadUploadIndicatorView.size = attachment.sizeToString()
            //                    self.attachmentDownloadUploadIndicatorView.delegate = self
            //                }
            //                let timeM = Int(attachment.duration / 60)
            //                let timeS = Int(attachment.duration.truncatingRemainder(dividingBy: 60.0))
            //                self.attachmentTimeOrSizeLabel.text = "0:00 / \(timeM):\(timeS)"
            //
            //                forwardedMessageBodyContainerView.isHidden = true
            //                forwardedMessageBodyLabel.isHidden = true
            //                contactsContainerView.isHidden = false
            //
            //                self.forwardedMessageAudioAndVoiceViewHeightConstraint.constant = 0
            //                self.forwardedFromViewHeightConstraint.constant = 20
            //                contactsContainerViewHeightConstraint.constant = 100
            //
            //                timeLabel.backgroundColor = UIColor.clear
            //
            //            case .file, .fileAndText:
            //
            //                self.forwardedMessageAudioAndVoiceViewHeightConstraint.constant = 0
            //                self.attachmentThumbnailImageView.isHidden = false
            //                self.attachmentFileNameLabel.isHidden = false
            //                self.attachmentTimeOrSizeLabel.isHidden = false
            //                self.attachmentContainreView.isHidden = false
            //                self.mediaContainerViewHeightConstraint.constant = 0
            //                self.attachmentViewHeightConstraint.constant = 55.0
            //                self.attachmentFileNameLabel.text = attachment.name
            //                self.attachmentThumbnailImageView.setThumbnail(for: attachment)
            //                self.attachmentTimeOrSizeLabel.text = attachment.sizeToString()
            //                if self.attachment?.status != .ready {
            //                    self.attachmentDownloadUploadIndicatorView.layer.masksToBounds = true
            //                    self.attachmentDownloadUploadIndicatorView.delegate = self
            //                }
            //
            //            default:
            //                break
            //            }
            //        } else {
            //            if originalMessage.type == .contact {
            //
            //                forwardedMessageBodyContainerView.isHidden = true
            //                forwardedMessageBodyLabel.isHidden = true
            //                contactsContainerView.isHidden = false
            //
            //                self.forwardedMessageAudioAndVoiceViewHeightConstraint.constant = 0
            //                self.forwardedFromViewHeightConstraint.constant = 20
            //                contactsContainerViewHeightConstraint.constant = 100
            //
            //                timeLabel.backgroundColor = UIColor.clear
            //                contactsContainerView.setContact((message.forwardedFrom?.contact!)!, isIncommingMessage: isIncommingMessage)
            //
            //            } else {
            //                self.forwardedMessageMediaContainerViewHeightConstraint.constant = 0
            //                self.forwardedMessageAudioAndVoiceViewHeightConstraint.constant = 0
            //            }
            //        }
        } else {
             forwardViewAbs?.isHidden  = true
            //    self.forwardedFromViewHeightConstraint.constant = 0
            //    self.forwardedMessageAudioAndVoiceViewHeightConstraint.constant = 0
            //    self.forwardedMessageBodyContainerViewHeightConstraint.constant = 0
            //    self.forwardedMessageBodyContainerView.isHidden = false
        }
    }
}

