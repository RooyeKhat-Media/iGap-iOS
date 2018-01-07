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
import RxRealm
import RxSwift
import RealmSwift
import Gifu

class IGMessageCollectionViewCell: IGMessageGeneralCollectionViewCell {
        
    struct ConstantSizes {
        struct Bubble {
            struct Height {
                struct Minimum {
                    static let TextOnly: CGFloat = 36.0
                    static let WithAttachment: CGFloat = 50.0
                }
                struct Maximum {
                    static let AttachmentFiled: CGFloat = 300.0
                }
                
            }
            struct Width {
                static let Minimum:             CGFloat =  50.0
                static let Maximum:             CGFloat = 218.0
                static let MaximumForChannels:  CGFloat = 300.0
            }
        }
    }
    
    @IBOutlet weak var selectedIndicatorView: UIView!
    @IBOutlet weak var selectedIndicatorViewLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var senderAvatarBackView: UIView!
    @IBOutlet weak var senderAvatarView: IGAvatarView!
    @IBOutlet weak var senderAvatarBackViewLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var senderNaemLabel: UILabel!
    
    @IBOutlet weak var mainBubbleView: UIView!
    @IBOutlet weak var mainBubbleViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainBubbleViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainBubbleViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainBubbleViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainBubbleViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var forwardedFromView: UIView!
    @IBOutlet weak var forwardedFromLabel: UILabel!
    @IBOutlet weak var forwardedFromViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var replyToView: UIView!
    @IBOutlet weak var replyToIndicatorView: UIView!
    @IBOutlet weak var replyToUserNameLabel: UILabel!
    @IBOutlet weak var replyToMessageBodyLabel: UILabel!
    @IBOutlet weak var replyToViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var forwardedMessageAudioAndVoiceViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var forwardedMessageAudioAndVoiceView: UIView!
    @IBOutlet weak var forwardedMessageMediaContainerView: UIView!
    @IBOutlet weak var forwardedMessageMediaContainerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var forwardedMessageMediaImageView: GIFImageView!
    @IBOutlet weak var forwardedMediaDownloadUploadIndicatorView: IGDownloadUploadIndicatorView!
    
    
    @IBOutlet weak var forwardedMessageBodyContainerView: UIView!
  
    @IBOutlet weak var forwardedMessageBodyLabel: ActiveLabel!
    @IBOutlet weak var forwardedMessageBodyContainerViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var mediaContainerView: UIView!
    @IBOutlet weak var mediaImageView: IGImageView!
    @IBOutlet weak var mediaContainerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mediaDownloadUploadIndicatorView: IGDownloadUploadIndicatorView!

    
    @IBOutlet weak var attachmentContainreView: UIView!
    @IBOutlet weak var attachmentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var attachmentThumbnailImageView: UIImageView!
    @IBOutlet weak var attachmentFileNameLabel: UILabel!
    @IBOutlet weak var attachmentFileArtistLabel: UILabel!
    @IBOutlet weak var attachmentPlayVoiceButton: UIButton!
    @IBOutlet weak var attachmentProgressSlider: UISlider!
    @IBOutlet weak var attachmentTimeOrSizeLabel: UILabel!
    @IBOutlet weak var attachmentProgressSliderLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var attachmentDownloadUploadIndicatorView: IGDownloadUploadIndicatorView!
    
    @IBOutlet weak var contactsContainerView: IGContactInMessageCellView!
    @IBOutlet weak var contactsContainerViewHeightConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var bodyView: UIView!
//    @IBOutlet weak var bodyTextView: UITextView!
    @IBOutlet weak var bodyLabel: ActiveLabel!
    @IBOutlet weak var bodyViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var statusIndicatorImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeLabelTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var timeLabelBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var editedLabel: UILabel!
    
    
    var isIncommingMessage = false
    var isMultiSelectMode = false
    var shouldShowSenderAvatar = false
    var forwardMediaFileAttachment : IGForwardMessageAudioAndVoiceAttachmentView?
    let disposeBag = DisposeBag()
    
    //MARK: - Class Methods
    class func nib() -> UINib {
        return UINib(nibName: "IGMessageCollectionViewCell", bundle: Bundle(for: self))
    }
    
    class func cellReuseIdentifier() -> String {
        return NSStringFromClass(self)
    }
    
    class func messageBodyTextViewFont() -> UIFont {
        return UIFont.igFont(ofSize: 14.0)//.systemFont(ofSize: 14.0)
    }
    
    class func replyToLabelFont() -> UIFont {
        return UIFont.igFont(ofSize: 14.0)
    }
    
    /*
     * addArbitraryTexts:
     *  is true when cell should show "edited" and time
     *  is false when calculating height for the original message in a forwarded message
     */
    class func bodyRect(text: NSString, isEdited: Bool, addArbitraryTexts: Bool) -> CGSize {
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.lineSpacing = 4
        paragraph.paragraphSpacing = -2
        
        //add an arbitrary string as time text to calculate whether the time fits in the currnt line or it should 
        //be moved to a new line
        var textWithTime = ""
        if addArbitraryTexts {
            if isEdited {
                textWithTime = text.appending("xxxxxxxxxxxxx")
            } else {
                textWithTime = text.appending("xxxxxxx")
            }
        } else {
            textWithTime = text.appending("")
        }
        let attributes: [String: Any] = [NSFontAttributeName: messageBodyTextViewFont(),
                                         NSParagraphStyleAttributeName: paragraph]
        var stringRect = textWithTime.boundingRect(with: CGSize(width: IGMessageCollectionViewCell.ConstantSizes.Bubble.Width.Maximum,
                                                                height:CGFloat.greatestFiniteMagnitude),
                                                   options: [.usesLineFragmentOrigin, .usesFontLeading], //, .truncatesLastVisibleLine, .usesDeviceMetrics],
                                                   attributes: attributes,
                                                   context: nil)
        
        //var stringSize = stringRect.integral.size
        stringRect.size.height = stringRect.height * 0.95 + 20
        return stringRect.size
//        
//        let attrString = NSAttributedString(string: text as String, attributes: attributes)
//        let framesetter = CTFramesetterCreateWithAttributedString(attrString)
//        let targetSize = CGSize(width: IGMessageCollectionViewCell.ConstantSizes.Bubble.Width.Maximum,
//                                height:CGFloat.greatestFiniteMagnitude)
//        let fitSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, attrString.length), nil, targetSize, nil)
//        //CFRelease(framesetter);
//        
////        return fitSize
//
////        let view = UITextView(frame: CGRect(x: 0, y: 0, width: IGMessageCollectionViewCell.ConstantSizes.Bubble.Width.Maximum, height: 0))
////        view.text = text as String
////        let size = view.sizeThatFits(CGSize(width: IGMessageCollectionViewCell.ConstantSizes.Bubble.Width.Maximum, height: CGFloat.greatestFiniteMagnitude))
////        //return size
//        
//        
//        
//        
//        
////        return attrString.boundingRect(with: CGSize(width: IGMessageCollectionViewCell.ConstantSizes.Bubble.Width.Maximum,
////                                                    height:CGFloat.greatestFiniteMagnitude),
////                                       options: [.usesLineFragmentOrigin, .usesFontLeading],
////                                       context: nil)
//        
//        
////        sting.a
////        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString: someString attributes:attributesDictionary];
////        [string appendAttributedString: [[NSAttributedString alloc] initWithString: anotherString];
////        CGRect rect = [string boundingRectWithSize:constraint options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) context:nil];
        
    }
    
    class func replyToLabelRect(username: NSString) -> CGRect {
        let attributes: [String: UIFont] = [NSFontAttributeName: messageBodyTextViewFont()]
        let text = ""
        let stringRect = text.boundingRect(with: CGSize(width: IGMessageCollectionViewCell.ConstantSizes.Bubble.Width.Minimum,
                                                        height:CGFloat.greatestFiniteMagnitude),
                                           options: [.usesLineFragmentOrigin, .usesFontLeading],
                                           attributes: attributes,
                                           context: nil)
        return stringRect
    }
    
    //MARK: - Instance Methods
    //MARK: Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.cellMessage = nil
        self.delegate = nil
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.transform = CGAffineTransform(scaleX: 1.0, y: -1.0)
        self.backgroundColor = UIColor.clear
//        self.backgroundViewForShadow.layer.cornerRadius = 18
//        self.backgroundViewForShadow.layer.masksToBounds = false
//        self.backgroundViewForShadow.layer.shadowColor = UIColor.black.cgColor
//        self.backgroundViewForShadow.layer.shadowOpacity = 0.15
//        self.backgroundViewForShadow.layer.shadowRadius = 4.0
//        self.backgroundViewForShadow.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        self.mainBubbleView.layer.cornerRadius = 18
        self.mainBubbleView.layer.masksToBounds = true
        self.mainBubbleView.layer.borderColor = UIColor(red: 179.0/255.0, green: 179.0/255.0, blue: 179.0/255.0, alpha: 1.0).cgColor
        
        self.mediaContainerView.layer.cornerRadius = 18
        self.mediaContainerView.layer.masksToBounds = true
        self.mediaDownloadUploadIndicatorView.shouldShowSize = true
        self.forwardedMediaDownloadUploadIndicatorView.shouldShowSize = true
        
        self.senderAvatarBackView.layer.cornerRadius = 15
        self.senderAvatarBackView.layer.masksToBounds = true
//        self.senderAvatarBackView.layer.shadowColor = UIColor.black.cgColor
//        self.senderAvatarBackView.layer.shadowOpacity = 0.25
//        self.senderAvatarBackView.layer.shadowRadius = 4.0
//        self.senderAvatarBackView.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        //self.senderAvatarImageView.layer.cornerRadius = 15
        //self.senderAvatarImageView.layer.masksToBounds = true
        
        self.bodyLabel.text = nil
        self.bodyLabel.font = IGMessageCollectionViewCell.messageBodyTextViewFont()
//        self.bodyLabel.verticalAlignment = .top
//        self.bodyLabel.isScrollEnabled = false
//        self.bodyLabel.textContainerInset = UIEdgeInsetsMake(2.5, 0, 0, 0)
        

        self.bodyLabel.customize { (label) in
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
        
        self.forwardedMessageBodyLabel.text = nil
        self.forwardedMessageBodyLabel.font = IGMessageCollectionViewCell.messageBodyTextViewFont()
        self.forwardedMessageBodyLabel.customize { (label) in
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
        
        addGustureRecognizers()
        hideAllSubViews()
        emptyAllImageViews()
        
        if isMultiSelectMode {
            self.selectedIndicatorView.isHidden = false
        } else {
            self.selectedIndicatorView.isHidden = true
        }
    }
    
    deinit {
        print (#function)
    }
    
    
    
    override func prepareForReuse() {
        print (#function)
        super.prepareForReuse()
        self.bodyLabel.text = nil
        self.cellMessage = nil
        self.delegate = nil
        hideAllSubViews()
        emptyAllImageViews()
        self.mediaDownloadUploadIndicatorView.prepareForReuse()
        self.forwardedMediaDownloadUploadIndicatorView.prepareForReuse()
        self.attachmentDownloadUploadIndicatorView.prepareForReuse()
        self.mediaImageView.prepareForReuse()
        self.forwardedMessageMediaImageView.prepareForReuse()
        if isMultiSelectMode {
            self.selectedIndicatorView.isHidden = false
        } else {
            self.selectedIndicatorView.isHidden = true
        }
    }
    
    func hideAllSubViews() {
        selectedIndicatorView.isHidden = true
        senderAvatarBackView.isHidden = true
        senderAvatarView.isHidden = true
        forwardedFromView.isHidden = true
        forwardedFromLabel.isHidden = true
        replyToView.isHidden = true
        replyToIndicatorView.isHidden = true
        replyToUserNameLabel.isHidden = true
        replyToMessageBodyLabel.isHidden = true
        forwardedMessageMediaContainerView.isHidden = true
        forwardedMessageMediaImageView.isHidden = true
        forwardedMessageBodyContainerView.isHidden = true
        forwardedMessageBodyLabel.isHidden = true
        mediaContainerView.isHidden = true
        mediaImageView.isHidden = true
        mediaDownloadUploadIndicatorView.isHidden = true
        attachmentContainreView.isHidden = true
        attachmentThumbnailImageView.isHidden = true
        attachmentFileNameLabel.isHidden = true
        attachmentFileArtistLabel.isHidden = true
        attachmentPlayVoiceButton.isHidden = true
        attachmentProgressSlider.isHidden = true
        attachmentTimeOrSizeLabel.isHidden = true
        attachmentDownloadUploadIndicatorView.isHidden = true
        contactsContainerView.isHidden = true
        bodyView.isHidden = true
        bodyLabel.isHidden = true
        statusIndicatorImageView.isHidden = true
        timeLabel.isHidden = true
        editedLabel.isHidden = true
        forwardedMessageAudioAndVoiceView.isHidden = true
        
        forwardedMessageMediaContainerView.backgroundColor = UIColor.clear
        forwardedFromView.backgroundColor = UIColor.clear
    }
    
    func emptyAllImageViews() {
        //senderAvatarImageView.image = nil
        forwardedMessageMediaImageView.image = nil
        mediaImageView.image = nil
        attachmentThumbnailImageView.image = nil
        statusIndicatorImageView.image = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    //MARK: Set Data
    override func setMessage(_ message: IGRoomMessage, isIncommingMessage: Bool, shouldShowAvatar: Bool, messageSizes: RoomMessageCalculatedSize, isPreviousMessageFromSameSender: Bool, isNextMessageFromSameSender: Bool) {

    
        self.isIncommingMessage = isIncommingMessage
        self.shouldShowSenderAvatar = shouldShowAvatar
        
        self.cellMessage = message
        
        
        if isIncommingMessage {
            self.mainBubbleView.layer.borderWidth = 0.0
            self.attachmentContainreView.backgroundColor = UIColor.white
            if let sender = message.authorUser {
                self.senderNaemLabel.text = sender.displayName
            } else if let sender = message.authorRoom {
                self.senderNaemLabel.text = sender.title
            } else {
                self.senderNaemLabel.text = ""
            }
        } else {
            self.mainBubbleView.layer.borderWidth = 1.0
            self.senderNaemLabel.text = ""
        }
        
        mainBubbleViewWidthConstraint.constant = messageSizes.bubbleSize.width // + 8 + 8
        mainBubbleViewWidthConstraint.priority = 1000
        
        forwardedMessageMediaContainerViewHeightConstraint.constant = 0
        forwardedMessageBodyContainerViewHeightConstraint.constant = 0
        
        //forwardedMessageMediaContainerView.isHidden = true
        //forwardedMessageBodyContainerView.isHidden = true
        
        self.mainBubbleView.backgroundColor = UIColor.chatBubbleBackground(isIncommingMessage: isIncommingMessage)
        
        
        if isIncommingMessage {
            timeLabelTrailingConstraint.constant = 10
            self.statusIndicatorImageView.isHidden = true
            if shouldShowAvatar {
                mainBubbleViewLeadingConstraint.priority = 999
                mainBubbleViewTrailingConstraint.priority = 750
                mainBubbleViewLeadingConstraint.constant = 46
                senderAvatarView.isHidden = false
                senderAvatarBackView.isHidden = false
                senderNaemLabel.isHidden = false
            } else {
                mainBubbleViewLeadingConstraint.priority = 999
                mainBubbleViewTrailingConstraint.priority = 750
                mainBubbleViewLeadingConstraint.constant = 16
                senderAvatarView.isHidden = true
                senderAvatarBackView.isHidden = true
                senderNaemLabel.isHidden = true
            }
        } else {
            self.statusIndicatorImageView.isHidden = false
            timeLabelTrailingConstraint.constant = 18
            mainBubbleViewLeadingConstraint.priority = 750
            mainBubbleViewTrailingConstraint.priority = 999
            mainBubbleViewTrailingConstraint.constant = 16
            senderAvatarView.isHidden = true
            senderAvatarBackView.isHidden = true
            senderNaemLabel.isHidden = true
        }
        
        if isPreviousMessageFromSameSender {
            mainBubbleViewTopConstraint.constant = 0.5
            senderAvatarView.isHidden = true
            senderAvatarBackView.isHidden = true
            senderNaemLabel.isHidden = true
        } else {
            mainBubbleViewTopConstraint.constant = 10.0
        }
        
        
        if isNextMessageFromSameSender {
            mainBubbleViewBottomConstraint.constant = 2.5
        } else {
            mainBubbleViewBottomConstraint.constant = 2.5
        }
        
        //MARK: Avatar
        if shouldShowAvatar {
            if let user = message.authorUser {
                senderAvatarView.setUser(user)
            }
        }
        
        //MARK: Reply
        if let repliedMessage = message.repliedTo {
            replyToView.isHidden                = false
            replyToIndicatorView.isHidden       = false
            replyToUserNameLabel.isHidden       = false
            replyToMessageBodyLabel.isHidden    = false
            replyToView.backgroundColor             = UIColor.chatReplyToBackgroundColor(isIncommingMessage: isIncommingMessage)
            replyToIndicatorView.backgroundColor    = UIColor.chatReplyToIndicatorViewColor(isIncommingMessage: isIncommingMessage)
            replyToUserNameLabel.textColor          = UIColor.chatReplyToUsernameLabelTextColor(isIncommingMessage: isIncommingMessage)
            replyToMessageBodyLabel.textColor       = UIColor.chatReplyToMessageBodyLabelTextColor(isIncommingMessage: isIncommingMessage)

            
            if let user = repliedMessage.authorUser {
                self.replyToUserNameLabel.text = user.displayName
            }
            
            if repliedMessage.type == .contact {
                self.replyToMessageBodyLabel.text = "Contact"
                self.replyToViewHeightConstraint.constant = 50
            }else if let body = repliedMessage.message {
                self.replyToMessageBodyLabel.text = body
                self.replyToViewHeightConstraint.constant = 50
            } else if let media = repliedMessage.attachment {
                self.replyToMessageBodyLabel.text = media.name
                self.replyToViewHeightConstraint.constant = 50
            } else {
                self.replyToMessageBodyLabel.text = ""
                self.replyToViewHeightConstraint.constant = 50
            }
        } else {
            self.replyToViewHeightConstraint.constant = 0
        }
        
        
        //MARK: Forward
        if let originalMessage = message.forwardedFrom {
            forwardedFromView.isHidden  = false
            forwardedFromLabel.isHidden = false
            forwardedFromView.backgroundColor                   = UIColor.chatForwardedFromViewBackgroundColor(isIncommingMessage: isIncommingMessage)
            forwardedFromLabel.textColor                        = UIColor.chatForwardedFromUsernameLabelColor(isIncommingMessage: isIncommingMessage)
            forwardedMessageMediaContainerView.backgroundColor  = UIColor.chatForwardedFromMediaContainerViewBackgroundColor(isIncommingMessage: isIncommingMessage)
            forwardedMessageBodyContainerView.backgroundColor   = UIColor.chatForwardedFromBodyContainerViewBackgroundColor(isIncommingMessage: isIncommingMessage)
            forwardedMessageBodyLabel.textColor                 = UIColor.chatForwardedFromBodyLabelTextColor(isIncommingMessage: isIncommingMessage)
            
            //MARK: ▶︎ Forward Title
            if let user = originalMessage.authorUser {
                self.forwardedFromLabel.text = "FROM: \(user.displayName)"
            } else if let room = originalMessage.authorRoom {
                self.forwardedFromLabel.text = "FROM: \(room.title != nil ? room.title! : "")"
            } else {
                self.forwardedFromLabel.text = "FROM: "
            }
            self.forwardedFromViewHeightConstraint.constant = 20
            
            //MARK: ▶︎ Forward Body
            let text = originalMessage.message
            if text != nil && text != "" {
                forwardedMessageBodyLabel.isHidden = false
                forwardedMessageBodyLabel.text = text
                self.forwardedMessageBodyContainerViewHeightConstraint.constant = messageSizes.forwardedMessageBodyHeight
                self.forwardedMessageBodyContainerView.isHidden = false
            } else {
                self.forwardedMessageBodyContainerViewHeightConstraint.constant = 0
            }
            
            
            //MARK: ▶︎ Forward Attachment
            if var attachment = originalMessage.attachment {
                if let attachmentVariableInCache = IGAttachmentManager.sharedManager.getRxVariable(attachmentPrimaryKeyId: attachment.primaryKeyId!) {
                    self.forwardedAttachment = attachmentVariableInCache.value
                } else {
                    self.forwardedAttachment = attachment.detach()
                    let attachmentRef = ThreadSafeReference(to: attachment)
                    IGAttachmentManager.sharedManager.add(attachmentRef: attachmentRef)
                    self.forwardedAttachment = IGAttachmentManager.sharedManager.getRxVariable(attachmentPrimaryKeyId: attachment.primaryKeyId!)!.value
                }
                //MARK: ▶︎ Rx Start
                if let variableInCache = IGAttachmentManager.sharedManager.getRxVariable(attachmentPrimaryKeyId: attachment.primaryKeyId!) {
                    attachment = variableInCache.value
                    variableInCache.asObservable().subscribe({ (event) in
                        DispatchQueue.main.async {
                            self.updateForwardedAttachmentDownloadUploadIndicatorView()
                        }
                    }).addDisposableTo(disposeBag)
                } else {
                    
                }
                //MARK: ▶︎ Rx End
                switch (originalMessage.type) {
                case .image, .imageAndText, .video, .videoAndText, .gif, .gifAndText:
                    self.forwardedMessageAudioAndVoiceViewHeightConstraint.constant = 0
                    self.forwardedMessageMediaImageView.isHidden = false
                    self.forwardedMessageMediaContainerView.isHidden = false
                    let progress = Progress(totalUnitCount: 100)
                    progress.completedUnitCount = 0
                    
                    self.forwardedMessageMediaImageView.setThumbnail(for: attachment)
                    self.forwardedMessageMediaContainerViewHeightConstraint.constant = messageSizes.forwardedMessageAttachmentHeight //+ 20
                    
                    if attachment.status != .ready {
                        self.forwardedMediaDownloadUploadIndicatorView.size = attachment.sizeToString()
                        self.forwardedMediaDownloadUploadIndicatorView.delegate = self
                    }
                    if originalMessage.type == .gif || originalMessage.type == .gifAndText {
                        attachment.loadData()
                        if let data = attachment.data {
                            self.forwardedMessageMediaImageView.prepareForAnimation(withGIFData: data)
                            self.forwardedMessageMediaImageView.startAnimatingGIF()
                        } else {
                            self.downloadUploadIndicatorDidTapOnStart(self.forwardedMediaDownloadUploadIndicatorView)
                            
                        }
                    }
                    break
                case .voice :
                    self.forwardedMessageMediaContainerViewHeightConstraint.constant = 0
                    self.forwardedMessageAudioAndVoiceView.isHidden = false
                    self.forwardedMessageAudioAndVoiceViewHeightConstraint.constant = messageSizes.forwardedMessageAttachmentHeight
                    forwardMediaFileAttachment = IGForwardMessageAudioAndVoiceAttachmentView()
                    forwardMediaFileAttachment?.setMediaPlayerCell(attachment)
                    self.forwardedMessageAudioAndVoiceView.addSubview(forwardMediaFileAttachment!)
                    forwardMediaFileAttachment?.attachment = attachment
                    break
                    
                case .audio , .audioAndText :

                    self.mediaContainerViewHeightConstraint.constant = 0
                    self.attachmentViewHeightConstraint.constant = 91.0
                    self.attachmentContainreView.isHidden = false
                    self.attachmentThumbnailImageView.isHidden = false
                    self.attachmentFileNameLabel.isHidden = false
                    self.attachmentFileArtistLabel.isHidden = false
                    self.attachmentProgressSlider.isHidden = false
                    self.attachmentTimeOrSizeLabel.isHidden = false
                    self.attachmentFileNameLabel.text = attachment.name
                    if isIncommingMessage {
                        self.attachmentProgressSlider.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb"), for: .normal)
                        self.attachmentProgressSlider.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb"), for: .focused)
                        self.attachmentProgressSlider.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb"), for: .selected)
                        self.attachmentProgressSlider.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb"), for: .highlighted)
                    } else {
                        self.attachmentProgressSlider.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb_Outgoing"), for: .normal)
                        self.attachmentProgressSlider.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb_Outgoing"), for: .focused)
                        self.attachmentProgressSlider.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb_Outgoing"), for: .selected)
                        self.attachmentProgressSlider.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb_Outgoing"), for: .highlighted)
                    }
                    
                    self.attachmentProgressSlider.setValue(0.0, animated: false)
                    self.attachmentThumbnailImageView.setThumbnail(for: attachment)
                    self.attachmentProgressSliderLeadingConstraint.constant = 8.0
                    self.attachmentThumbnailImageView.layer.cornerRadius = 16.0
                    self.attachmentThumbnailImageView.layer.masksToBounds = true
                    if self.attachment?.status != .ready {
                        self.attachmentDownloadUploadIndicatorView.layer.cornerRadius = 16.0
                        self.attachmentDownloadUploadIndicatorView.layer.masksToBounds = true
                        self.attachmentDownloadUploadIndicatorView.size = attachment.sizeToString()
                        self.attachmentDownloadUploadIndicatorView.delegate = self
                    }
                    let timeM = Int(attachment.duration / 60)
                    let timeS = Int(attachment.duration.truncatingRemainder(dividingBy: 60.0))
                    self.attachmentTimeOrSizeLabel.text = "0:00 / \(timeM):\(timeS)"
                    
                    forwardedMessageBodyContainerView.isHidden = true
                    forwardedMessageBodyLabel.isHidden = true
                    contactsContainerView.isHidden = false
                    
                    self.forwardedMessageAudioAndVoiceViewHeightConstraint.constant = 0
                    self.forwardedFromViewHeightConstraint.constant = 20
                    contactsContainerViewHeightConstraint.constant = 100
                    
                    timeLabel.backgroundColor = UIColor.clear
                default:
                    break
                }
            } else {
                if originalMessage.type == .contact {
                    
                    forwardedMessageBodyContainerView.isHidden = true
                    forwardedMessageBodyLabel.isHidden = true
                    contactsContainerView.isHidden = false

                    self.forwardedMessageAudioAndVoiceViewHeightConstraint.constant = 0
                    self.forwardedFromViewHeightConstraint.constant = 20
                    contactsContainerViewHeightConstraint.constant = 100
                    
                    timeLabel.backgroundColor = UIColor.clear
                    contactsContainerView.setContact((message.forwardedFrom?.contact!)!, isIncommingMessage: isIncommingMessage)
                    
                } else {
                    self.forwardedMessageMediaContainerViewHeightConstraint.constant = 0
                    self.forwardedMessageAudioAndVoiceViewHeightConstraint.constant = 0
                }
            }
        } else {
            self.forwardedFromViewHeightConstraint.constant = 0
            self.forwardedMessageAudioAndVoiceViewHeightConstraint.constant = 0
            self.forwardedMessageBodyContainerViewHeightConstraint.constant = 0
            self.forwardedMessageBodyContainerView.isHidden = false
        }

        //MARK: Attachments
        self.mediaContainerView.backgroundColor      = UIColor.clear
        self.attachmentContainreView.backgroundColor = UIColor.chatBubbleBackground(isIncommingMessage: isIncommingMessage)
        self.attachmentFileNameLabel.textColor       = UIColor.chatBubbleTextColor(isIncommingMessage: isIncommingMessage)
        self.attachmentFileArtistLabel.textColor     = UIColor.chatBubbleTextColor(isIncommingMessage: isIncommingMessage)
        self.attachmentTimeOrSizeLabel.textColor     = UIColor.chatBubbleTextColor(isIncommingMessage: isIncommingMessage)
        if var attachment = message.attachment {
            if let attachmentVariableInCache = IGAttachmentManager.sharedManager.getRxVariable(attachmentPrimaryKeyId: attachment.primaryKeyId!) {
                self.attachment = attachmentVariableInCache.value
            } else {
                self.attachment = attachment.detach()
                let attachmentRef = ThreadSafeReference(to: attachment)
                IGAttachmentManager.sharedManager.add(attachmentRef: attachmentRef)
                self.attachment = IGAttachmentManager.sharedManager.getRxVariable(attachmentPrimaryKeyId: attachment.primaryKeyId!)!.value
            }
            
            //MARK: ▶︎ Rx Start
            if let variableInCache = IGAttachmentManager.sharedManager.getRxVariable(attachmentPrimaryKeyId: attachment.primaryKeyId!) {
                attachment = variableInCache.value
                variableInCache.asObservable().subscribe({ (event) in
                    DispatchQueue.main.async {
                        self.updateAttachmentDownloadUploadIndicatorView()
                    }
                }).addDisposableTo(disposeBag)
            } else {
                
            }
            //MARK: ▶︎ Rx End

            switch (message.type) {
            case .image, .imageAndText, .video, .videoAndText, .gif, .gifAndText:
                self.mediaContainerView.isHidden = false
                self.mediaImageView.isHidden = false
                self.mediaImageView.backgroundColor = UIColor.clear
//                let progress = Progress(totalUnitCount: 100)
//                progress.completedUnitCount = 0
                self.mediaImageView.setThumbnail(for: attachment)
                self.mediaContainerViewHeightConstraint.constant = messageSizes.MessageAttachmentHeight //height
                if attachment.status != .ready {
                    self.mediaDownloadUploadIndicatorView.size = attachment.sizeToString()
                    self.mediaDownloadUploadIndicatorView.delegate = self
                } else {
                    
                }
                
                if message.type == .gif || message.type == .gifAndText {
                    attachment.loadData()
                    if let data = attachment.data {
                        self.mediaImageView.prepareForAnimation(withGIFData: data)
                        self.mediaImageView.startAnimatingGIF()
                    } else {
                        self.downloadUploadIndicatorDidTapOnStart(self.mediaDownloadUploadIndicatorView)
                    }
                }
                
                //self.attachmentContainreView.isHidden = true
                self.attachmentViewHeightConstraint.constant = 0.0
                
                
                
                break
            case .voice:
//                self.mediaContainerView.isHidden = true
                self.mediaContainerViewHeightConstraint.constant = 0
                self.attachmentProgressSliderLeadingConstraint.constant = 30.0
                self.attachmentViewHeightConstraint.constant = 68.0
                self.attachmentContainreView.isHidden = false
                self.attachmentPlayVoiceButton.isHidden = false
                self.attachmentFileNameLabel.isHidden = false
                self.attachmentProgressSlider.isHidden = false
                self.attachmentTimeOrSizeLabel.isHidden = false
                if message.authorUser != nil {
                    self.attachmentFileNameLabel.text = "Recorded by \(message.authorUser!.displayName)"
                } else if message.authorRoom != nil {
                    self.attachmentFileNameLabel.text = "Recorded voice"
                }
                
                if isIncommingMessage {
                    self.attachmentProgressSlider.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb"), for: .normal)
                    self.attachmentProgressSlider.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb"), for: .focused)
                    self.attachmentProgressSlider.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb"), for: .selected)
                    self.attachmentProgressSlider.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb"), for: .highlighted)
                    self.attachmentProgressSlider.minimumTrackTintColor = UIColor.organizationalColor()
                    self.attachmentProgressSlider.maximumTrackTintColor = UIColor(red: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1.0)
                    self.attachmentPlayVoiceButton.setImage(UIImage(named:"IG_Message_Cell_Player_Voice_Play"), for: .normal)
                } else {
                    self.attachmentProgressSlider.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb_Outgoing"), for: .normal)
                    self.attachmentProgressSlider.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb_Outgoing"), for: .focused)
                    self.attachmentProgressSlider.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb_Outgoing"), for: .selected)
                    self.attachmentProgressSlider.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb_Outgoing"), for: .highlighted)
                    self.attachmentProgressSlider.minimumTrackTintColor = UIColor(red: 235.0/255.0, green: 235.0/255.0, blue: 235.0/255.0, alpha: 1.0)
                    self.attachmentProgressSlider.maximumTrackTintColor = UIColor(red: 22.0/255.0, green: 91.0/255.0, blue: 88.0/255.0, alpha: 1.0)
                    self.attachmentPlayVoiceButton.setImage(UIImage(named:"IG_Message_Cell_Player_Voice_Play_Outgoing"), for: .normal)
                }
                self.attachmentProgressSlider.setValue(0.0, animated: false)
                self.attachmentThumbnailImageView.setThumbnail(for: attachment)
                self.attachmentProgressSliderLeadingConstraint.constant = 28.0
                self.attachmentThumbnailImageView.layer.cornerRadius = 16.0
                self.attachmentThumbnailImageView.layer.masksToBounds = true
                if self.attachment?.status != .ready {
                    self.attachmentDownloadUploadIndicatorView.layer.cornerRadius = 16.0
                    self.attachmentDownloadUploadIndicatorView.layer.masksToBounds = true
                    self.attachmentDownloadUploadIndicatorView.size = attachment.sizeToString()
                    self.attachmentDownloadUploadIndicatorView.delegate = self
                }
                let timeM = Int(attachment.duration / 60)
                let timeS = Int(attachment.duration.truncatingRemainder(dividingBy: 60.0))
                self.attachmentTimeOrSizeLabel.text = "0:00 / \(timeM):\(timeS)"
                break
            case .audio, .audioAndText:
//                self.mediaContainerView.isHidden = true
                self.mediaContainerViewHeightConstraint.constant = 0
                self.attachmentViewHeightConstraint.constant = 91.0
                self.attachmentContainreView.isHidden = false
                self.attachmentThumbnailImageView.isHidden = false
                self.attachmentFileNameLabel.isHidden = false
                self.attachmentFileArtistLabel.isHidden = false
                self.attachmentProgressSlider.isHidden = false
                self.attachmentTimeOrSizeLabel.isHidden = false
                self.attachmentFileNameLabel.text = attachment.name
                if isIncommingMessage {
                    self.attachmentProgressSlider.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb"), for: .normal)
                    self.attachmentProgressSlider.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb"), for: .focused)
                    self.attachmentProgressSlider.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb"), for: .selected)
                    self.attachmentProgressSlider.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb"), for: .highlighted)
                } else {
                    self.attachmentProgressSlider.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb_Outgoing"), for: .normal)
                    self.attachmentProgressSlider.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb_Outgoing"), for: .focused)
                    self.attachmentProgressSlider.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb_Outgoing"), for: .selected)
                    self.attachmentProgressSlider.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb_Outgoing"), for: .highlighted)
                }
                
                self.attachmentProgressSlider.setValue(0.0, animated: false)
                self.attachmentThumbnailImageView.setThumbnail(for: attachment)
                self.attachmentProgressSliderLeadingConstraint.constant = 8.0
                self.attachmentThumbnailImageView.layer.cornerRadius = 16.0
                self.attachmentThumbnailImageView.layer.masksToBounds = true
                if self.attachment?.status != .ready {
                    self.attachmentDownloadUploadIndicatorView.layer.cornerRadius = 16.0
                    self.attachmentDownloadUploadIndicatorView.layer.masksToBounds = true
                    self.attachmentDownloadUploadIndicatorView.size = attachment.sizeToString()
                    self.attachmentDownloadUploadIndicatorView.delegate = self
                }
                let timeM = Int(attachment.duration / 60)
                let timeS = Int(attachment.duration.truncatingRemainder(dividingBy: 60.0))
                self.attachmentTimeOrSizeLabel.text = "0:00 / \(timeM):\(timeS)"
                
                break
            case .file, .fileAndText:
                
                self.attachmentFileNameLabel.isHidden = false
                self.attachmentTimeOrSizeLabel.isHidden = false
                self.attachmentContainreView.isHidden = false
                self.mediaContainerViewHeightConstraint.constant = 0
                self.attachmentViewHeightConstraint.constant = 55.0
                self.attachmentFileNameLabel.text = attachment.name
                self.attachmentTimeOrSizeLabel.text = attachment.sizeToString()
                if self.attachment?.status != .ready {
                    self.attachmentDownloadUploadIndicatorView.layer.cornerRadius = 16.0
                    self.attachmentDownloadUploadIndicatorView.layer.masksToBounds = true
                    self.attachmentDownloadUploadIndicatorView.delegate = self
                }
            default:
                break
            }
        } else {
            
            if let forwardMessage = message.forwardedFrom {
                if forwardMessage.type == .audio  || forwardMessage.type == .audioAndText {
                    // do nothing
                } else {
                    mediaContainerView.isHidden = true
                    mediaContainerViewHeightConstraint.constant = 0
                    attachmentContainreView.isHidden = true
                    attachmentViewHeightConstraint.constant = 0.0
                }
            } else {
                mediaContainerView.isHidden = true
                mediaContainerViewHeightConstraint.constant = 0
                attachmentContainreView.isHidden = true
                attachmentViewHeightConstraint.constant = 0.0
            }
        }
        
        //MARK: Body Text (message)
        if  message.message != nil && message.message != "" {
            let body = message.message
            bodyViewHeightConstraint.constant = messageSizes.messageBodyHeight
            bodyLabel.text = body
            bodyView.isHidden = false
            bodyLabel.isHidden = false
            timeLabelBottomConstraint.constant = 11.0
            timeLabel.backgroundColor = UIColor.clear
            bodyView.backgroundColor = UIColor.clear
            bodyLabel.textColor = UIColor.chatBubbleTextColor(isIncommingMessage: isIncommingMessage)
        } else {
            timeLabelBottomConstraint.constant = 4.0
            timeLabel.backgroundColor = UIColor.lightGray
            timeLabel.layer.cornerRadius = 5.5
            timeLabel.layer.masksToBounds = true
            bodyViewHeightConstraint.constant = 0
        }
        
        //MARK: Contact
        self.contactsContainerView.backgroundColor = UIColor.clear
        if message.type == .contact {
            timeLabel.backgroundColor = UIColor.clear
            contactsContainerView.isHidden = false
            contactsContainerViewHeightConstraint.constant = 100
            contactsContainerView.setContact(message.contact!, isIncommingMessage: isIncommingMessage)
        } else {
            contactsContainerViewHeightConstraint.constant = 0
        }
        
        //MARK: Time
        if let time = message.creationTime {
            timeLabel.text = time.convertToHumanReadable()
            timeLabel.isHidden = false
            timeLabel.textColor = UIColor.chatTimeTextColor(isIncommingMessage: isIncommingMessage)
            //if message.type == .voice || message.type == .file {
            timeLabel.backgroundColor = UIColor.clear
            //}
        }
        
        //MARK: Edited
        if message.isEdited {
            self.editedLabel.isHidden = false
            self.editedLabel.textColor = UIColor.chatTimeTextColor(isIncommingMessage: isIncommingMessage)
        }
        
        //MARK: Status
        switch message.status {
        case .sending:
            self.statusIndicatorImageView.image = UIImage(named: "IG_Message_Cell_State_Sending")
        case .sent:
            self.statusIndicatorImageView.image = UIImage(named: "IG_Message_Cell_State_Sent")
        case .delivered:
            self.statusIndicatorImageView.image = UIImage(named: "IG_Message_Cell_State_Delivered")
        case .seen,.listened:
            self.statusIndicatorImageView.image = UIImage(named: "IG_Message_Cell_State_Seen")
        case .failed, .unknown:
            self.statusIndicatorImageView.image = nil
        }
    }
    
    
    override func setMultipleSelectionMode(_ multipleSelectionMode: Bool) {
        isMultiSelectMode = multipleSelectionMode
        if isIncommingMessage {
            if isMultiSelectMode {
                self.selectedIndicatorView.isHidden = false
                if shouldShowSenderAvatar {
                    senderAvatarBackViewLeadingConstraint.constant = 8 + 30
                    mainBubbleViewLeadingConstraint.constant = 46 + 30
                } else {
                    mainBubbleViewLeadingConstraint.constant = 16 + 30
                }
            } else {
                self.selectedIndicatorView.isHidden = true
                if shouldShowSenderAvatar {
                    senderAvatarBackViewLeadingConstraint.constant = 8
                    mainBubbleViewLeadingConstraint.constant = 46
                } else {
                    mainBubbleViewLeadingConstraint.constant = 16
                }
            }
        } else {
            if isMultiSelectMode {
                self.selectedIndicatorView.isHidden = false
            } else {
                self.selectedIndicatorView.isHidden = true
            }
        }
        UIView.animate(withDuration: 0.2, animations: {
            self.contentView.layoutIfNeeded()
        })
    }

    
    //MARK: Gesture Recognizers
    func addGustureRecognizers() {
        let tapAndHold = UILongPressGestureRecognizer(target: self, action: #selector(didTapAndHoldOnCell(_:)))
        tapAndHold.minimumPressDuration = 0.2
        self.mainBubbleView.addGestureRecognizer(tapAndHold)
        self.mainBubbleView.isUserInteractionEnabled = true
        
        
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(didTapOnAttachment(_:)))
        self.mediaContainerView.addGestureRecognizer(tap1)
        self.mediaContainerView.isUserInteractionEnabled = true
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(didTapOnAttachment(_:)))
        self.mediaImageView.addGestureRecognizer(tap2)
        self.mediaImageView.isUserInteractionEnabled = true
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(didTapOnAttachment(_:)))
        self.attachmentContainreView.addGestureRecognizer(tap3)
        self.attachmentContainreView.isUserInteractionEnabled = true
        let tap4 = UITapGestureRecognizer(target: self, action:  #selector(didTapOnForwardedAttachment(_:)))
        self.forwardedMessageAudioAndVoiceView.addGestureRecognizer(tap4)
        self.forwardedMessageAudioAndVoiceView.isUserInteractionEnabled = true
        
        let tap5 = UITapGestureRecognizer(target: self, action: #selector(didTapOnSenderAvatar(_:)))
        self.senderAvatarView.addGestureRecognizer(tap5)
    }

    func didTapAndHoldOnCell(_ gestureRecognizer: UILongPressGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            self.delegate?.didTapAndHoldOnMessage(cellMessage: cellMessage!, cell: self)
        default:
            break
        }
    }
    
    func didTapOnAttachment(_ gestureRecognizer: UITapGestureRecognizer) {
        self.delegate?.didTapOnAttachment(cellMessage: cellMessage!, cell: self)
    }
    
    func didTapOnForwardedAttachment(_ gestureRecognizer: UITapGestureRecognizer) {
        self.delegate?.didTapOnForwardedAttachment(cellMessage: cellMessage!, cell: self)
        
    }
    
    func didTapOnSenderAvatar(_ gestureRecognizer: UITapGestureRecognizer) {
        self.delegate?.didTapOnSenderAvatar(cellMessage: cellMessage!, cell: self)
    }
    
    
    
    //MARK: Update UI based on attachment status
    func updateAttachmentDownloadUploadIndicatorView() {
        if let attachment = self.attachment {
            
            if attachment.status == .ready {
                self.mediaDownloadUploadIndicatorView.setState(attachment.status)
                setThumbnailForAttachments()
                if attachment.type == .gif {
                    attachment.loadData()
                    if let data = attachment.data {
                        self.mediaImageView.prepareForAnimation(withGIFData: data)
                        self.mediaImageView.startAnimatingGIF()
                    }
                } else if attachment.type == .image {
                    self.mediaImageView.setThumbnail(for: attachment)
                }
                return
            }
            
            
            switch attachment.type {
            case .video, .image, .gif:
//                self.mediaDownloadUploadIndicatorView.isHidden = false
//                self.attachmentDownloadUploadIndicatorView.isHidden = true
                self.mediaDownloadUploadIndicatorView.setFileType(.media)
                self.mediaDownloadUploadIndicatorView.setState(attachment.status)
                if attachment.status == .downloading ||  attachment.status == .uploading {
                    self.mediaDownloadUploadIndicatorView.setPercentage(attachment.downloadUploadPercent)
                }
                
            case .audio, .voice, .file:
                if self.isIncommingMessage {
                    self.attachmentDownloadUploadIndicatorView.setFileType(.incommingFile)
                } else {
                    self.attachmentDownloadUploadIndicatorView.setFileType(.outgoingFile)
                }
                self.attachmentDownloadUploadIndicatorView.setState(attachment.status)
                if attachment.status == .downloading ||  attachment.status == .uploading {
                    self.attachmentDownloadUploadIndicatorView.setPercentage(self.attachment!.downloadUploadPercent)
                }
            }
        }
        
    }
    
    
    func setThumbnailForAttachments() {
        if let attachment = self.attachment {
            self.attachmentThumbnailImageView.isHidden = false
            if attachment.type == .voice {
                self.attachmentThumbnailImageView.image = UIImage(named: "IG_Message_Cell_Voice")
            } else {
                switch attachment.fileTypeBasedOnNameExtension {
                case .docx:
                    self.attachmentThumbnailImageView.image = UIImage(named: "IG_Message_Cell_File_Doc")
                default:
                    self.attachmentThumbnailImageView.image = UIImage(named: "IG_Message_Cell_File_Generic")
                }
            }
        }
    }
    
    
    func updateForwardedAttachmentDownloadUploadIndicatorView() {
        if let attachment = self.forwardedAttachment {
            
            if attachment.status == .ready {
                self.forwardedMediaDownloadUploadIndicatorView.setState(attachment.status)
                setThumbnailForForwardedAttachments()
                if attachment.type == .gif {
                    attachment.loadData()
                    if let data = attachment.data {
                        self.forwardedMessageMediaImageView.prepareForAnimation(withGIFData: data)
                        self.forwardedMessageMediaImageView.startAnimatingGIF()
                    }
                } else if attachment.type == .image {
                    self.forwardedMessageMediaImageView.setThumbnail(for: attachment)
                }
                return
            }
            
            
            switch attachment.type {
            case .video, .image, .gif:
                self.forwardedMediaDownloadUploadIndicatorView.setFileType(.media)
                self.forwardedMediaDownloadUploadIndicatorView.setState(attachment.status)
                if attachment.status == .downloading ||  attachment.status == .uploading {
                    self.forwardedMediaDownloadUploadIndicatorView.setPercentage(attachment.downloadUploadPercent)
                }
            case .audio, .voice, .file:
                break
//                if self.isIncommingMessage {
//                    //self.attachmentDownloadUploadIndicatorView.setFileType(.incommingFile)
//                } else {
//                    //self.attachmentDownloadUploadIndicatorView.setFileType(.outgoingFile)
//                }
//                self.attachmentDownloadUploadIndicatorView.setState(attachment.status)
//                if attachment.status == .downloading ||  attachment.status == .uploading {
//                    self.attachmentDownloadUploadIndicatorView.setPercentage(self.attachment!.downloadUploadPercent)
//                }
            }
        }
    }
    

    
    func setThumbnailForForwardedAttachments() {
        
        if let attachment = self.forwardedAttachment {
            self.attachmentThumbnailImageView.isHidden = false
            if attachment.type == .voice {
                self.attachmentThumbnailImageView.image = UIImage(named: "IG_Message_Cell_Voice")
            } else {
                switch attachment.fileTypeBasedOnNameExtension {
                case .docx:
                    self.attachmentThumbnailImageView.image = UIImage(named: "IG_Message_Cell_File_Doc")
                default:
                    self.attachmentThumbnailImageView.image = UIImage(named: "IG_Message_Cell_File_Generic")
                }
            }
        }

    }
}


extension IGMessageCollectionViewCell: IGDownloadUploadIndicatorViewDelegate {
    func downloadUploadIndicatorDidTapOnStart(_ indicator: IGDownloadUploadIndicatorView) {
        if self.attachment?.status == .downloading {
            return
        }
        
        if let attachment = self.attachment {
            IGDownloadManager.sharedManager.download(file: attachment, previewType: .originalFile, completion: {
                
            }, failure: {
                
            })
        }
        if let forwardAttachment = self.forwardedAttachment {
            IGDownloadManager.sharedManager.download(file: forwardAttachment, previewType: .originalFile, completion: {
                
            }, failure: {
                
            })

        }
    }
    
    func downloadUploadIndicatorDidTapOnCancel(_ indicator: IGDownloadUploadIndicatorView) {
        
    }
}

