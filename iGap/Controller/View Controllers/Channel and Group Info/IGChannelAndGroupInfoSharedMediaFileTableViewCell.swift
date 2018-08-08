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
import RxSwift

class IGChannelAndGroupInfoSharedMediaFileTableViewCell: UITableViewCell {
    
    @IBOutlet weak var creationDateLabel: UILabel!
    @IBOutlet weak var fileSizeLabel: UILabel!
    @IBOutlet weak var fileImageView: UIImageView!
    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var indicatorView: IGDownloadUploadIndicatorView!
    
    var attachment: IGFile?
    let disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        self.indicatorView.prepareForReuse()
        self.indicatorView.isHidden = true
    }
    
    func setFileDetails(attachment: IGFile , message: IGRoomMessage) {
        
        if let messageAttachmentVariableInCache = IGAttachmentManager.sharedManager.getRxVariable(attachmentPrimaryKeyId: attachment.primaryKeyId!) {
            self.attachment = messageAttachmentVariableInCache.value
        } else {
            self.attachment = attachment.detach()
            IGAttachmentManager.sharedManager.add(attachment: self.attachment!)
            self.attachment = IGAttachmentManager.sharedManager.getRxVariable(attachmentPrimaryKeyId: attachment.primaryKeyId!)?.value
        }
        
        let fileImage = UIImage(named: "IG_Message_Cell_File_Generic")
        fileImageView.image = fileImage
        if let creationDate = message.creationTime {
            creationDateLabel.text = "\(creationDate.completeHumanReadableTime())"
        }
        self.fileSizeLabel.text = IGAttachmentManager.sharedManager.convertFileSize(sizeInByte: attachment.size)
        fileImageView.setThumbnail(for: attachment)
        fileNameLabel.text = attachment.name
        
        switch attachment.fileTypeBasedOnNameExtension {
        case .docx:
            self.fileImageView.image = UIImage(named: "IG_Message_Cell_File_Doc")
        default:
            self.fileImageView.image = UIImage(named: "IG_Message_Cell_File_Generic")
        }
        
        
        if let variableInCache = IGAttachmentManager.sharedManager.getRxVariable(attachmentPrimaryKeyId: attachment.primaryKeyId!) {
            self.attachment = variableInCache.value
            variableInCache.asObservable().subscribe({ (event) in
                DispatchQueue.main.async {
                    self.updateAttachmentDownloadUploadIndicatorView()
                }
            }).disposed(by: disposeBag)
        }
        
        switch (message.type) {
        case .file, .fileAndText:
            
            self.indicatorView.isHidden = false
            self.fileImageView.isHidden = false
            
            Progress(totalUnitCount: 100).completedUnitCount = 0
            
            if attachment.status != .ready {
                self.indicatorView.size = attachment.sizeToString()
                self.indicatorView.delegate = self
            }
            
        default:
            break
        }
    }
    
    func updateAttachmentDownloadUploadIndicatorView() {
        if let attachment = self.attachment {
            if IGGlobal.isFileExist(path: attachment.path(), fileSize: attachment.size) {
                self.indicatorView.setState(.ready)
                self.fileImageView.setThumbnail(for: attachment)
                return
            }
            
            switch attachment.type {
            case .file:
                self.indicatorView.setFileType(.media)
                self.indicatorView.setState(attachment.status)
                if attachment.status == .downloading || attachment.status == .uploading {
                    self.indicatorView.setPercentage(attachment.downloadUploadPercent)
                }
            default:
                break
            }
        }
    }
}

extension IGChannelAndGroupInfoSharedMediaFileTableViewCell: IGDownloadUploadIndicatorViewDelegate {
    
    func downloadUploadIndicatorDidTapOnStart(_ indicator: IGDownloadUploadIndicatorView) {
        if let attachment = self.attachment {
            IGDownloadManager.sharedManager.download(file: attachment, previewType: .originalFile, completion: { (attachment) -> Void in }, failure: {})
        }
    }
    func downloadUploadIndicatorDidTapOnCancel(_ indicator: IGDownloadUploadIndicatorView) {}
}

