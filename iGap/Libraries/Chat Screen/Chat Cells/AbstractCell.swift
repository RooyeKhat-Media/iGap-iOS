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
import RealmSwift
import RxSwift

class AbstractCell: IGMessageGeneralCollectionViewCell {
    
    var mainBubbleViewAbs: UIView!
    var forwardViewAbs: UIView!
    var replyViewAbs: UIView!
    var mediaContainerViewAbs: UIView?
    var messageViewAbs: UIView?
    var replyLineViewAbs: UIView!
    
    var txtSenderNameAbs: UILabel!
    var txtEditedAbs: UILabel!
    var txtTimeAbs: UILabel!
    var txtReplyDisplayNameAbs: UILabel!
    var txtReplyMessageAbs: UILabel!
    var txtForwardAbs: UILabel!
    
    var imgStatusAbs: UIImageView!
    var imgFileAbs: UIImageView!
    
    var txtMessageHeightConstraintAbs: NSLayoutConstraint!
    var mainBubbleViewWidthAbs: NSLayoutConstraint!
    var mediaHeightConstraintAbs: NSLayoutConstraint!
    
    var avatarViewAbs: IGAvatarView!
    var txtMessageAbs: ActiveLabel!
    var imgMediaAbs: IGImageView!
    var indicatorViewAbs: IGDownloadUploadIndicatorView!

    var realmRoomMessage: IGRoomMessage!
    var finalRoomMessage: IGRoomMessage!
    var messageSizes: RoomMessageCalculatedSize!
    var isIncommingMessage: Bool!
    var shouldShowAvatar: Bool!
    var isPreviousMessageFromSameSender: Bool!
    
    var leadingAbs: Constraint?
    var trailingAbs: Constraint?
    var imgMediaTopAbs: Constraint!
    var imgMediaHeightAbs: Constraint!
    
    let disposeBag = DisposeBag()
    
    var isForward = false
    var isReply = false
    
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
        
        detectFinalMessage()
        manageCellBubble()
        manageReceivedOrIncommingMessage()
        manageReply()
        manageForward()
        manageEdit()
        manageTextMessage()
        manageViewPosition()
        manageLink()
        manageGustureRecognizers()
        manageAttachment()
    }
    /*
     ******************************************************************
     ********************** Detect Final Message **********************
     ******************************************************************
     */
    
    /* check that exist forward/reply and fill finalMessage with correct value */
    private func detectFinalMessage(){
        if let message = realmRoomMessage.forwardedFrom {
            isForward = true
            isReply = false
            finalRoomMessage = message
        } else if realmRoomMessage.repliedTo != nil {
            isForward = false
            isReply = true
            finalRoomMessage = realmRoomMessage
        } else {
            isForward = false
            isReply = false
            finalRoomMessage = realmRoomMessage
        }
    }
    
    /*
     ******************************************************************
     ************************** Message Text **************************
     ******************************************************************
     */
    
    private func manageTextMessage(){
        
        if finalRoomMessage.message != nil && finalRoomMessage.message != "" {
            txtMessageAbs.font = IGMessageCollectionViewCell.messageBodyTextViewFont()
            messageViewAbs?.isHidden = false
            txtMessageAbs?.isHidden = false
            messageViewAbs?.backgroundColor = UIColor.clear
            txtMessageAbs?.textColor = UIColor.chatBubbleTextColor(isIncommingMessage: isIncommingMessage)
            if isForward {
                txtMessageHeightConstraintAbs?.constant = messageSizes.forwardedMessageBodyHeight
            } else {
                txtMessageHeightConstraintAbs?.constant = messageSizes.messageBodyHeight
            }
            txtMessageAbs?.text = finalRoomMessage.message
        } else {
            txtMessageHeightConstraintAbs?.constant = 0
            messageViewAbs?.isHidden = true
            txtMessageAbs?.isHidden = true
        }
    }
    
    /*
     ******************************************************************
     ********************** Manage View Positions *********************
     ******************************************************************
     */
    
    private func manageViewPosition(){
        
        if txtMessageAbs == nil {
            return
        }
        
        if finalRoomMessage.attachment == nil {
            if isForward {
                txtMessageAbs.snp.remakeConstraints{ (make) in
                    make.top.equalTo((forwardViewAbs?.snp.bottom)!).offset(3)
                }
            } else if isReply {
                txtMessageAbs.snp.remakeConstraints{ (make) in
                    make.top.equalTo((replyViewAbs?.snp.bottom)!).offset(3)
                }
            } else {
                txtMessageAbs.snp.remakeConstraints{ (make) in
                    make.centerY.equalTo(mainBubbleViewAbs.snp.centerY)
                }
            }
            
            removeImage()
            
        } else {
            switch (finalRoomMessage.type) {
            case .image, .video, .gif:

                makeImage()
                
                txtMessageAbs.snp.remakeConstraints{ (make) in
                    make.centerY.equalTo(mainBubbleViewAbs.snp.centerY)
                }
                
                break
            case .imageAndText, .videoAndText, .gifAndText:

                makeImage()
                
                txtMessageAbs.snp.remakeConstraints{ (make) in
                    make.top.equalTo(imgMediaAbs.snp.bottom)
                }
                break
                
                
            case .voice:
                break
            
                
            case .audio:
                txtMessageAbs.snp.remakeConstraints{ (make) in
                    make.centerY.equalTo(mainBubbleViewAbs.snp.centerY)
                }
                break
            case .audioAndText:
                txtMessageAbs.snp.remakeConstraints{ (make) in
                    make.top.equalTo(imgFileAbs.snp.bottom)
                }
                break
                
                
            case .file:
                txtMessageAbs.snp.remakeConstraints{ (make) in
                    make.centerY.equalTo(mainBubbleViewAbs.snp.centerY)
                }
                break
            case .fileAndText:
                txtMessageAbs.snp.remakeConstraints{ (make) in
                    make.top.equalTo(imgFileAbs.snp.bottom)
                }
                break
                
                
            default:
                break
            }
        }
    }
    
    /*
     ******************************************************************
     ****************************** Time ******************************
     ******************************************************************
     */
    
    private func manageTime(statusExist: Bool){
        if let time = realmRoomMessage.creationTime {
            makeTime(statusExist: statusExist)
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
            makeEdit()
        } else {
            removeEdit()
        }
    }
    
    /*
     ******************************************************************
     ************************* Status Manager *************************
     ******************************************************************
     */
    
    private func manageMessageStatus(){
        makeStatus()
        
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
            
            makeAvatar()
            if let user = realmRoomMessage.authorUser {
                avatarViewAbs.setUser(user)
            }
            
        } else {
            removeAvatar()
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

            removeStatus()
            manageTime(statusExist: false)
            setAvatar()
            
        } else {
            
            mainBubbleViewAbs?.layer.borderWidth = 1.0
            removeAvatar()
            removeSenderName()
            manageTime(statusExist: true)
            manageMessageStatus()
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
            
            if leadingAbs != nil { leadingAbs?.deactivate() }
            if trailingAbs != nil { trailingAbs?.deactivate() }
            
            if isIncommingMessage {
                
                if #available(iOS 11.0, *) {
                    mainBubbleViewAbs.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner, .layerMaxXMinYCorner]
                }
                
                if shouldShowAvatar {
                    leadingAbs = make.leading.equalTo(self.contentView.snp.leading).offset(46).priority(999).constraint
                } else {
                    leadingAbs = make.leading.equalTo(self.contentView.snp.leading).offset(16).priority(999).constraint
                }
                trailingAbs = make.trailing.equalTo(self.contentView.snp.trailing).offset(-16).priority(250).constraint
                
            } else {
                
                if #available(iOS 11.0, *) {
                    mainBubbleViewAbs.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                }
                
                trailingAbs = make.trailing.equalTo(self.contentView.snp.trailing).offset(-16).priority(999).constraint
                leadingAbs = make.leading.equalTo(self.contentView.snp.leading).offset(46).priority(250).constraint
            }
            
            if leadingAbs != nil { leadingAbs?.activate() }
            if trailingAbs != nil { trailingAbs?.activate() }
        }
    }
    
    /*
     ******************************************************************
     ************************** Link Manager **************************
     ******************************************************************
     */
    private func manageLink(){
        linkManager(txtMessage: txtMessageAbs)
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
                self.delegate?.didTapOnMention(mentionText: mention )
            }
            
            label.handleHashtagTap { hashtag in
                self.delegate?.didTapOnHashtag(hashtagText: hashtag)
            }
            
            label.handleURLTap { url in
                self.delegate?.didTapOnURl(url: url)
            }
            
            label.handleCustomTap(for:customInvitedLink) {
                self.delegate?.didTapOnRoomLink(link: $0)
            }
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
        
        if imgFileAbs != nil {
            let onFileClick = UITapGestureRecognizer(target: self, action: #selector(didTapOnAttachment(_:)))
            imgFileAbs.addGestureRecognizer(onFileClick)
            imgFileAbs.isUserInteractionEnabled = true
        }
        
        if mediaContainerViewAbs != nil {
            let tap1 = UITapGestureRecognizer(target: self, action: #selector(didTapOnAttachment(_:)))
            mediaContainerViewAbs?.addGestureRecognizer(tap1)
            mediaContainerViewAbs?.isUserInteractionEnabled = true
        }

        if imgMediaAbs != nil {
            let tap2 = UITapGestureRecognizer(target: self, action: #selector(didTapOnAttachment(_:)))
            imgMediaAbs?.addGestureRecognizer(tap2)
            imgMediaAbs?.isUserInteractionEnabled = true
        }
        
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
            
        } else {
            removeReply()
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

        } else {
            removeForward()
        }
    }
    
    /*
     ******************************************************************
     ************************ Manage Attachment ***********************
     ******************************************************************
     */
    
    private func manageAttachment(){
        
        if var attachment = finalRoomMessage.attachment {
            
            if let attachmentVariableInCache = IGAttachmentManager.sharedManager.getRxVariable(attachmentPrimaryKeyId: attachment.primaryKeyId!) {
                self.attachment = attachmentVariableInCache.value
            } else {
                self.attachment = attachment.detach()
                let attachmentRef = ThreadSafeReference(to: attachment)
                IGAttachmentManager.sharedManager.add(attachmentRef: attachmentRef)
                self.attachment = IGAttachmentManager.sharedManager.getRxVariable(attachmentPrimaryKeyId: attachment.primaryKeyId!)!.value
            }
            
            /* Rx Start */
            if let variableInCache = IGAttachmentManager.sharedManager.getRxVariable(attachmentPrimaryKeyId: attachment.primaryKeyId!) {
                attachment = variableInCache.value
                variableInCache.asObservable().subscribe({ (event) in
                    DispatchQueue.main.async {
                        self.updateAttachmentDownloadUploadIndicatorView()
                    }
                }).addDisposableTo(disposeBag)
            }
            /* Rx End */
            
            switch (finalRoomMessage.type) {
            case .image, .imageAndText, .video, .videoAndText, .gif, .gifAndText:
                
                imgMediaAbs.setThumbnail(for: attachment)
                if attachment.status != .ready {
                    indicatorViewAbs.size = attachment.sizeToString()
                    indicatorViewAbs.delegate = self
                }
                
                /**** seems to not need ****
                if finalRoomMessage.type == .gif || finalRoomMessage.type == .gifAndText {
                    attachment.loadData()
                    if let data = attachment.data {
                        imgMediaAbs.prepareForAnimation(withGIFData: data)
                        imgMediaAbs.startAnimatingGIF()
                    } else {
                        self.downloadUploadIndicatorDidTapOnStart(indicatorViewAbs)
                    }
                }
                */
                indicatorViewAbs.shouldShowSize = true
                break
            default:
                break
            }
        }
    }
    
    func updateAttachmentDownloadUploadIndicatorView() {
        if let attachment = self.attachment {
            
            if attachment.status == .ready {
                indicatorViewAbs.setState(attachment.status)
                if attachment.type == .gif {
                    attachment.loadData()
                    if let data = attachment.data {
                        imgMediaAbs.prepareForAnimation(withGIFData: data)
                        imgMediaAbs.startAnimatingGIF()
                    }
                } else if attachment.type == .image {
                    imgMediaAbs.setThumbnail(for: attachment)
                }
                return
            }
            
            
            switch attachment.type {
            case .video, .image, .gif:
                indicatorViewAbs.setFileType(.media)
                indicatorViewAbs.setState(attachment.status)
                if attachment.status == .downloading ||  attachment.status == .uploading {
                    indicatorViewAbs.setPercentage(attachment.downloadUploadPercent)
                }
                break
            case .audio, .voice, .file:
                if self.isIncommingMessage {
                    indicatorViewAbs.setFileType(.incommingFile)
                } else {
                    indicatorViewAbs.setFileType(.outgoingFile)
                }
                indicatorViewAbs.setState(attachment.status)
                if attachment.status == .downloading ||  attachment.status == .uploading {
                    indicatorViewAbs.setPercentage(self.attachment!.downloadUploadPercent)
                }
                break
            }
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
            txtSenderNameAbs.textColor = UIColor.senderNameColorDark()
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
            make.trailing.equalTo(forwardViewAbs.snp.trailing).offset(-8)
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
            make.height.equalTo(14)
        }
        
        txtReplyMessageAbs.snp.makeConstraints { (make) in
            make.trailing.equalTo(replyViewAbs.snp.trailing)
            make.leading.equalTo(replyLineViewAbs.snp.trailing).offset(8)
            make.bottom.equalTo(replyLineViewAbs.snp.bottom)
            make.height.equalTo(17)
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
    
    
    
    
    private func makeAvatar(){
        if avatarViewAbs == nil {
            let frame = CGRect(x:0 ,y:0 ,width:30 ,height:30)
            avatarViewAbs = IGAvatarView(frame: frame)
            self.contentView.addSubview(avatarViewAbs)
        }

        avatarViewAbs.snp.makeConstraints { (make) in
            make.leading.equalTo(self.contentView.snp.leading).offset(8)
            make.top.equalTo(mainBubbleViewAbs.snp.top)
            make.width.equalTo(30)
            make.height.equalTo(30)
        }
    }
    
    private func removeAvatar(){
        if avatarViewAbs != nil {
            avatarViewAbs.removeFromSuperview()
            avatarViewAbs = nil
        }
    }
    
    
    
    
    private func makeStatus(){
        if imgStatusAbs == nil {
            imgStatusAbs = UIImageView()
            mainBubbleViewAbs.addSubview(imgStatusAbs)
        }
        
        imgStatusAbs.snp.makeConstraints { (make) in
            make.trailing.equalTo(mainBubbleViewAbs.snp.trailing).offset(-10)
            make.centerY.equalTo(txtTimeAbs.snp.centerY)
            make.height.equalTo(10)
            make.width.equalTo(10)
        }
    }
    
    private func removeStatus(){
        if imgStatusAbs != nil {
            imgStatusAbs.removeFromSuperview()
            imgStatusAbs = nil
        }
    }
    
    
    
    
    private func makeTime(statusExist: Bool){
        if txtTimeAbs == nil {
            txtTimeAbs = UILabel()
            txtTimeAbs.font = UIFont.igFont(ofSize: 9.0)
            mainBubbleViewAbs.addSubview(txtTimeAbs)
        }
        
        txtTimeAbs.snp.makeConstraints{ (make) in
            make.trailing.equalTo(mainBubbleViewAbs.snp.trailing).offset(-15)
            make.bottom.equalTo(mainBubbleViewAbs.snp.bottom).offset(-11)
            make.width.equalTo(30)
            make.height.equalTo(11)
        }
    }
    
    private func removeTime(){
        if txtTimeAbs != nil {
            txtTimeAbs.removeFromSuperview()
            txtTimeAbs = nil
        }
    }
    
    
    
    
    private func makeEdit(){
        if txtEditedAbs == nil {
            txtEditedAbs = UILabel()
            txtEditedAbs.text = "edited"
            txtEditedAbs.font = UIFont.igFont(ofSize: 9.0)
            txtEditedAbs.textColor = UIColor.chatTimeTextColor(isIncommingMessage: isIncommingMessage)
            mainBubbleViewAbs.addSubview(txtEditedAbs)
        }
        
        txtEditedAbs.snp.makeConstraints { (make) in
            make.trailing.equalTo(txtTimeAbs.snp.leading).offset(-3)
            make.centerY.equalTo(txtTimeAbs.snp.centerY)
            make.width.equalTo(30)
            make.height.equalTo(11)
        }
    }
    
    private func removeEdit(){
        if txtEditedAbs != nil {
            txtEditedAbs.removeFromSuperview()
            txtEditedAbs = nil
        }
    }
    
    
    
    
    private func makeImage(){
        if imgMediaAbs != nil {
            imgMediaAbs.removeFromSuperview()
            imgMediaAbs = nil
        }
        
        if indicatorViewAbs != nil {
            indicatorViewAbs.removeFromSuperview()
            indicatorViewAbs = nil
        }
        
        if imgMediaAbs == nil {
            imgMediaAbs = IGImageView()
            mainBubbleViewAbs.addSubview(imgMediaAbs)
        }
        
        if indicatorViewAbs == nil {
            indicatorViewAbs = IGDownloadUploadIndicatorView()
            mainBubbleViewAbs.addSubview(indicatorViewAbs)
        }
        
        imgMediaAbs.snp.makeConstraints { (make) in

            make.trailing.equalTo(mainBubbleViewAbs.snp.trailing)
            make.leading.equalTo(mainBubbleViewAbs.snp.leading)
            
            if imgMediaTopAbs != nil { imgMediaTopAbs.deactivate() }
            if imgMediaHeightAbs != nil { imgMediaHeightAbs.deactivate() }
            
            if isForward {
                imgMediaTopAbs = make.top.equalTo(forwardViewAbs.snp.bottom).constraint
                imgMediaHeightAbs = make.height.equalTo(messageSizes.forwardedMessageAttachmentHeight).constraint
            } else if isReply {
                imgMediaTopAbs = make.top.equalTo(replyViewAbs.snp.bottom).constraint
                imgMediaHeightAbs = make.height.equalTo(messageSizes.MessageAttachmentHeight).constraint
            } else {
                imgMediaTopAbs = make.top.equalTo(mainBubbleViewAbs.snp.top).constraint
                imgMediaHeightAbs = make.height.equalTo(messageSizes.MessageAttachmentHeight).constraint
            }
            
            if imgMediaTopAbs != nil { imgMediaTopAbs.activate() }
            if imgMediaHeightAbs != nil { imgMediaHeightAbs.activate() }
        }
        
        indicatorViewAbs.snp.makeConstraints { (make) in
            make.top.equalTo(imgMediaAbs.snp.top)
            make.bottom.equalTo(imgMediaAbs.snp.bottom)
            make.trailing.equalTo(imgMediaAbs.snp.trailing)
            make.leading.equalTo(imgMediaAbs.snp.leading)
        }
    }
    
    private func removeImage(){
        if imgMediaAbs != nil {
            imgMediaAbs.removeFromSuperview()
            imgMediaAbs = nil
        }
        
        if indicatorViewAbs != nil {
            indicatorViewAbs.removeFromSuperview()
            indicatorViewAbs = nil
        }
    }
}

/*
 ******************************************************************
 **************************** extensions **************************
 ******************************************************************
 */

extension AbstractCell: IGDownloadUploadIndicatorViewDelegate {
    func downloadUploadIndicatorDidTapOnStart(_ indicator: IGDownloadUploadIndicatorView) {
        if self.attachment?.status == .downloading {
            return
        }
        
        if let attachment = self.attachment {
            IGDownloadManager.sharedManager.download(file: attachment, previewType: .originalFile, completion: { (attachment) -> Void in
                
            }, failure: {
                
            })
        }
        if let forwardAttachment = self.forwardedAttachment {
            IGDownloadManager.sharedManager.download(file: forwardAttachment, previewType: .originalFile, completion: { (attachment) -> Void in
                
            }, failure: {
                
            })
            
        }
    }
    
    func downloadUploadIndicatorDidTapOnCancel(_ indicator: IGDownloadUploadIndicatorView) {
        
    }
}

