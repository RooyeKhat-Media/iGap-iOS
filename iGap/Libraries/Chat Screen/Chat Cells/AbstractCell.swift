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
    var forwardViewAbs: UIView!
    var replyViewAbs: UIView!
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
    
    var avatarViewAbs: IGAvatarView?
    var txtMessageAbs: ActiveLabel!
    var txtForwardedMessageAbs: ActiveLabel!

    var realmRoomMessage: IGRoomMessage!
    var messageSizes: RoomMessageCalculatedSize!
    var isIncommingMessage: Bool!
    var shouldShowAvatar: Bool!
    var isPreviousMessageFromSameSender: Bool!
    
    var leadingAbs: Constraint?
    var trailingAbs: Constraint?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.transform = CGAffineTransform(scaleX: 1.0, y: -1.0)
        self.backgroundColor = UIColor.clear
    }
    
    override func setMessage(_ message: IGRoomMessage, isIncommingMessage: Bool, shouldShowAvatar: Bool, messageSizes: RoomMessageCalculatedSize, isPreviousMessageFromSameSender: Bool, isNextMessageFromSameSender: Bool) {
        self.realmRoomMessage = message
        self.isIncommingMessage = isIncommingMessage
        self.shouldShowAvatar = shouldShowAvatar
        self.messageSizes = messageSizes
        self.isPreviousMessageFromSameSender = isPreviousMessageFromSameSender
        
        manageCellBubble()
        manageReceivedOrIncommingMessage()
        manageTextMessage()
        manageLink()
        manageGustureRecognizers()
        manageMessageStatus()
        manageReply()
        manageForward()
        manageTime()
        manageEdit()
    }
    
    /*
     ******************************************************************
     ************************** Message Text **************************
     ******************************************************************
     */
    
    private func manageTextMessage(){
        if realmRoomMessage.message != nil && realmRoomMessage.message != "" {
            txtMessageAbs.font = IGMessageCollectionViewCell.messageBodyTextViewFont()
            messageViewAbs?.isHidden = false
            txtMessageAbs?.isHidden = false
            messageViewAbs?.backgroundColor = UIColor.clear
            txtMessageAbs?.textColor = UIColor.chatBubbleTextColor(isIncommingMessage: isIncommingMessage)
            txtMessageHeightConstraintAbs?.constant = messageSizes.messageBodyHeight
            
            txtMessageAbs?.text = realmRoomMessage.message
        }
    }
    
    /*
     ******************************************************************
     ****************************** Time ******************************
     ******************************************************************
     */
    
    private func manageTime(){
        if let time = realmRoomMessage.creationTime {
            txtTimeAbs?.text = time.convertToHumanReadable()
            txtTimeAbs?.textColor = UIColor.chatTimeTextColor(isIncommingMessage: isIncommingMessage)
        }
    }
    
    /*
     ******************************************************************
     ****************************** Edit ******************************
     ******************************************************************
     */
    
    private func manageEdit() {
        if realmRoomMessage.isEdited {
            txtEditedAbs?.isHidden = false
            txtEditedAbs?.textColor = UIColor.chatTimeTextColor(isIncommingMessage: isIncommingMessage)
        } else {
            txtEditedAbs?.isHidden = true
        }
    }
    
    /*
     ******************************************************************
     ************************* Status Manager *************************
     ******************************************************************
     */
    
    private func manageMessageStatus(){
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
        
        if shouldShowAvatar && !isPreviousMessageFromSameSender {
            avatarViewAbs?.isHidden = false
            avatarBackViewAbs?.isHidden = false // avatar back view is redundant. why we should use this ?!!!
            
            if let user = realmRoomMessage.authorUser {
                avatarViewAbs?.setUser(user)
            }
        } else {
            
            avatarViewAbs?.isHidden = true
            avatarBackViewAbs?.isHidden = true
        }
    }
    
    /*
     ******************************************************************
     ********** Detect and Manage Received/Incomming Message **********
     ******************************************************************
     */
    
    private func manageReceivedOrIncommingMessage(){
        if isIncommingMessage {
            mainBubbleViewAbs?.layer.borderWidth = 0.0

            if isPreviousMessageFromSameSender {
                removeSenderName()
            } else {
                makeSenderName()

                if let sender = realmRoomMessage.authorUser {
                    txtSenderNameAbs.text = sender.displayName
                } else if let sender = realmRoomMessage.authorRoom {
                    txtSenderNameAbs.text = sender.title
                } else {
                    txtSenderNameAbs.text = ""
                }
            }

            imgStatusAbs.isHidden = true

            setAvatar()

        } else {
            mainBubbleViewAbs?.layer.borderWidth = 1.0
            imgStatusAbs?.isHidden = false
            avatarViewAbs?.isHidden = true
            avatarBackViewAbs?.isHidden = true

            removeSenderName()
        }
    }
    
    private func manageCellBubble(){
        
        /************ Bubble View ************/
        mainBubbleViewAbs.layer.cornerRadius = 18
        mainBubbleViewAbs.layer.masksToBounds = true
        mainBubbleViewAbs.layer.borderColor = UIColor(red: 179.0/255.0, green: 179.0/255.0, blue: 179.0/255.0, alpha: 1.0).cgColor
        mainBubbleViewAbs.backgroundColor = UIColor.chatBubbleBackground(isIncommingMessage: isIncommingMessage)
        
        /************ Bubble Size ************/
        mainBubbleViewWidthAbs.constant = messageSizes.bubbleSize.width //mainBubbleViewWidthAbs.priority = 1000
        
        /********* Bubble Direction *********/
        mainBubbleViewAbs.snp.makeConstraints { (make) in
            if isIncommingMessage {
                if leadingAbs != nil { leadingAbs?.deactivate() }
                if trailingAbs != nil { trailingAbs?.deactivate() }
                
                if shouldShowAvatar {
                    leadingAbs = make.leading.equalTo(self.contentView.snp.leading).offset(46).priority(999).constraint
                } else {
                    leadingAbs = make.leading.equalTo(self.contentView.snp.leading).offset(16).priority(999).constraint
                }
                trailingAbs = make.trailing.equalTo(self.contentView.snp.trailing).offset(-16).priority(250).constraint
                
                if leadingAbs != nil { leadingAbs?.activate() }
                if trailingAbs != nil { trailingAbs?.activate() }
                
            } else {
                if leadingAbs != nil { leadingAbs?.deactivate() }
                if trailingAbs != nil { trailingAbs?.deactivate() }
                
                trailingAbs = make.trailing.equalTo(self.contentView.snp.trailing).offset(-16).priority(999).constraint
                leadingAbs = make.leading.equalTo(self.contentView.snp.leading).offset(46).priority(250).constraint
                
                if leadingAbs != nil { leadingAbs?.activate() }
                if trailingAbs != nil { trailingAbs?.activate() }
            }
        }
    }
    
    /*
     ******************************************************************
     ************************** Link Manager **************************
     ******************************************************************
     */
    private func manageLink(){
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
    
    func manageGustureRecognizers() {
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
     ****************************** Reply *****************************
     ******************************************************************
     */
    
    private func manageReply(){
        if let repliedMessage = realmRoomMessage.repliedTo {
            
            makeReply()
            
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
            
            txtMessageAbs.snp.remakeConstraints{ (make) in
                make.top.equalTo((replyViewAbs?.snp.bottom)!).offset(3)
                make.height.greaterThanOrEqualTo(10).priority(.high)
            }
            
        } else {
            removeReply()
            
            txtMessageAbs.snp.remakeConstraints{ (make) in
                make.centerY.equalTo(mainBubbleViewAbs.snp.centerY)
            }
        }
    }
    
    /*
     ******************************************************************
     ***************************** Forward ****************************
     ******************************************************************
     */
    
    func manageForward(){
        
        if let originalMessage = realmRoomMessage.forwardedFrom {
            
            makeForward()
            
            if let user = originalMessage.authorUser {
                txtForwardAbs.text = "Forwarded from: \(user.displayName)"
            } else if let room = originalMessage.authorRoom {
                txtForwardAbs.text = "Forwarded from: \(room.title != nil ? room.title! : "")"
            } else {
                txtForwardAbs.text = "Forwarded from: "
            }

            let text = originalMessage.message
            if text != nil && text != "" {
                txtMessageAbs.text = text
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
            removeForward()
            //    self.forwardedFromViewHeightConstraint.constant = 0
            //    self.forwardedMessageAudioAndVoiceViewHeightConstraint.constant = 0
            //    self.forwardedMessageBodyContainerViewHeightConstraint.constant = 0
            //    self.forwardedMessageBodyContainerView.isHidden = false
        }
    }
    
    /*
     ************************************************************************************************************************************
     ******************************* View Maker (all methods for programmatically create cell view is here) *****************************
     ************************************************************************************************************************************
     */
    
    private func makeSenderName(){
        
        if txtSenderNameAbs == nil {
            txtSenderNameAbs = UILabel()
            txtSenderNameAbs.textColor = UIColor.senderNameColor()
            txtSenderNameAbs.font = UIFont.igFont(ofSize: 8.0)
            self.contentView.addSubview(txtSenderNameAbs)
        }
        
        txtSenderNameAbs.snp.makeConstraints { (make) in
            make.leading.equalTo(mainBubbleViewAbs.snp.leading).offset(8)
            make.trailing.equalTo(mainBubbleViewAbs.snp.trailing)
            make.bottom.equalTo(mainBubbleViewAbs.snp.top)
            make.height.equalTo(10)
        }
    }
    
    private func removeSenderName(){
        if txtSenderNameAbs != nil {
            txtSenderNameAbs.removeFromSuperview()
            txtSenderNameAbs = nil
        }
    }
    
    
    
    
    private func makeForward(){
        if forwardViewAbs == nil {
            forwardViewAbs = UIView()
            mainBubbleViewAbs.addSubview(forwardViewAbs!)
        }
        
        if txtForwardAbs == nil {
            txtForwardAbs = UILabel()
            forwardViewAbs?.addSubview(txtForwardAbs)
        }
        
        /* set color always for avoid from reuse item color. for example: show incomming forward color for received forward color */
        forwardViewAbs?.backgroundColor = UIColor.chatForwardedFromViewBackgroundColor(isIncommingMessage: isIncommingMessage)
        txtForwardAbs.textColor = UIColor.chatForwardedFromUsernameLabelColor(isIncommingMessage: isIncommingMessage)
        txtForwardAbs.font = UIFont.igFont(ofSize: 9.0)
        
        forwardViewAbs?.snp.makeConstraints { (make) in
            make.top.equalTo(mainBubbleViewAbs.snp.top).priority(.required)
            make.leading.equalTo(mainBubbleViewAbs.snp.leading)
            make.trailing.equalTo(mainBubbleViewAbs.snp.trailing)
            make.height.equalTo(30)
        }
        
        txtForwardAbs.snp.makeConstraints { (make) in
            make.top.equalTo(forwardViewAbs.snp.top)
            make.leading.equalTo(forwardViewAbs.snp.leading).offset(8)
            make.trailing.equalTo(forwardViewAbs.snp.trailing).offset(8)
            make.centerY.equalTo(forwardViewAbs.snp.centerY).priority(.required)
        }
    }
    
    private func removeForward(){
        if forwardViewAbs != nil {
            forwardViewAbs?.removeFromSuperview()
            forwardViewAbs = nil
        }
        
        if txtForwardAbs != nil {
            txtForwardAbs?.removeFromSuperview()
            txtForwardAbs = nil
        }
    }
    
    
    
    
    private func makeReply(){
        
        if replyViewAbs == nil {
            replyViewAbs = UIView()
            mainBubbleViewAbs.addSubview(replyViewAbs)
        }
        
        if replyLineViewAbs == nil {
            replyLineViewAbs = UIView()
            replyViewAbs.addSubview(replyLineViewAbs)
        }
        
        if txtReplyDisplayNameAbs == nil {
            txtReplyDisplayNameAbs = UILabel()
            replyViewAbs.addSubview(txtReplyDisplayNameAbs)
        }
        
        if txtReplyMessageAbs == nil {
            txtReplyMessageAbs = UILabel()
            replyViewAbs.addSubview(txtReplyMessageAbs)
        }
        
        replyViewAbs.snp.makeConstraints { (make) in
            make.trailing.equalTo(mainBubbleViewAbs.snp.trailing)
            make.leading.equalTo(mainBubbleViewAbs.snp.leading)
            make.top.equalTo(mainBubbleViewAbs.snp.top)
            make.height.equalTo(54)
        }
        
        replyLineViewAbs.snp.makeConstraints { (make) in
            make.leading.equalTo(replyViewAbs.snp.leading).offset(16)
            make.top.equalTo(replyViewAbs.snp.top).offset(10)
            make.bottom.equalTo(replyViewAbs.snp.bottom).offset(-10)
            make.width.equalTo(3)
        }
        
        txtReplyDisplayNameAbs.snp.makeConstraints { (make) in
            make.trailing.equalTo(replyViewAbs.snp.trailing)
            make.leading.equalTo(replyLineViewAbs.snp.trailing).offset(8)
            make.top.equalTo(replyLineViewAbs.snp.top)
            make.height.equalTo(10)
        }
        
        txtReplyMessageAbs.snp.makeConstraints { (make) in
            make.trailing.equalTo(replyViewAbs.snp.trailing)
            make.leading.equalTo(replyLineViewAbs.snp.trailing).offset(8)
            make.bottom.equalTo(replyLineViewAbs.snp.bottom)
            make.height.equalTo(13)
        }
        
        replyViewAbs?.backgroundColor         = UIColor.chatReplyToBackgroundColor(isIncommingMessage: isIncommingMessage)
        replyLineViewAbs.backgroundColor      = UIColor.chatReplyToIndicatorViewColor(isIncommingMessage: isIncommingMessage)
        txtReplyDisplayNameAbs.textColor      = UIColor.chatReplyToUsernameLabelTextColor(isIncommingMessage: isIncommingMessage)
        txtReplyMessageAbs.textColor          = UIColor.chatReplyToMessageBodyLabelTextColor(isIncommingMessage: isIncommingMessage)
        
        txtReplyDisplayNameAbs.font = UIFont.igFont(ofSize: 10.0)
        txtReplyMessageAbs.font = UIFont.igFont(ofSize: 13.0)
    }
    
    private func removeReply(){
        if replyViewAbs != nil {
            replyViewAbs?.removeFromSuperview()
            replyViewAbs = nil
        }
        
        if replyLineViewAbs != nil {
            replyLineViewAbs?.removeFromSuperview()
            replyLineViewAbs = nil
        }
        
        if txtReplyDisplayNameAbs != nil {
            txtReplyDisplayNameAbs?.removeFromSuperview()
            txtReplyDisplayNameAbs = nil
        }
        
        if txtReplyMessageAbs != nil {
            txtReplyMessageAbs?.removeFromSuperview()
            txtReplyMessageAbs = nil
        }
    }
}

