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

class IGChannelAndGroupInfoSharedMediaImagesAndVideosCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var sharedMediaImageView: UIImageView!
    @IBOutlet weak var videoSizeLabel: UILabel!
    @IBOutlet weak var mediaDownloadIndicator: IGDownloadUploadIndicatorView!
    let disposeBag = DisposeBag()
    
    var attachment: IGFile?
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    override func awakeFromNib() {}
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func prepareForReuse() {
        sharedMediaImageView.image = nil
        videoSizeLabel.text = nil
        self.mediaDownloadIndicator.prepareForReuse()
        self.mediaDownloadIndicator.isHidden = true
        self.sharedMediaImageView.isHidden = true
    }
    
    func setMediaIndicator(message: IGRoomMessage) {
        if let msgAttachment = message.attachment {
            if let messageAttachmentVariableInCache = IGAttachmentManager.sharedManager.getRxVariable(attachmentPrimaryKeyId: msgAttachment.primaryKeyId!) {
                self.attachment = messageAttachmentVariableInCache.value
            } else {
                self.attachment = msgAttachment.detach()
                //let attachmentRef = ThreadSafeReference(to: msgAttachment)
                IGAttachmentManager.sharedManager.add(attachment: attachment!)
                self.attachment = IGAttachmentManager.sharedManager.getRxVariable(attachmentPrimaryKeyId: msgAttachment.primaryKeyId!)?.value
            }
            
            
            if let variableInCache = IGAttachmentManager.sharedManager.getRxVariable(attachmentPrimaryKeyId: msgAttachment.primaryKeyId!) {
                attachment = variableInCache.value
                variableInCache.asObservable().subscribe({ (event) in
                    DispatchQueue.main.async {
                        self.updateAttachmentDownloadUploadIndicatorView()
                    }
                }).disposed(by: disposeBag)
            }
            
            //MARK: ▶︎ Rx End
            switch (message.type) {
            case .image, .imageAndText, .video, .videoAndText:
                self.sharedMediaImageView.isHidden = false
                self.mediaDownloadIndicator.isHidden = false
                let progress = Progress(totalUnitCount: 100)
                progress.completedUnitCount = 0
                
                self.sharedMediaImageView.setThumbnail(for: msgAttachment)
                
                if msgAttachment.status != .ready {
                    self.mediaDownloadIndicator.size = msgAttachment.sizeToString()
                    self.mediaDownloadIndicator.delegate = self
                }
            default:
                break
            }
        }
    }
    
    func updateAttachmentDownloadUploadIndicatorView() {
        if let attachment = self.attachment {
            if IGGlobal.isFileExist(path: attachment.path(), fileSize: attachment.size) {
                self.mediaDownloadIndicator.setState(.ready)
                if attachment.type == .image || attachment.type == .video {
                    self.sharedMediaImageView.setThumbnail(for: attachment)
                }
                return
            }
            
            switch attachment.type {
            case .video, .image:
                self.mediaDownloadIndicator.setFileType(.media)
                self.mediaDownloadIndicator.setState(attachment.status)
                if attachment.status == .downloading ||  attachment.status == .uploading {
                    self.mediaDownloadIndicator.setPercentage(attachment.downloadUploadPercent)
                }
            default:
                break
            }
        }
    }
}
extension IGChannelAndGroupInfoSharedMediaImagesAndVideosCollectionViewCell: IGDownloadUploadIndicatorViewDelegate {
    func downloadUploadIndicatorDidTapOnStart(_ indicator: IGDownloadUploadIndicatorView) {
        if let attachment = self.attachment {
            IGDownloadManager.sharedManager.download(file: attachment, previewType: .originalFile, completion: { (attachment) -> Void in }, failure: {})
        }
    }
    
    func downloadUploadIndicatorDidTapOnCancel(_ indicator: IGDownloadUploadIndicatorView) {}
}
