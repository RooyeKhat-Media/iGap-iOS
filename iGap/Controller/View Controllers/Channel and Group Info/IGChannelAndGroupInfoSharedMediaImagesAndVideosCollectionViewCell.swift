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

class IGChannelAndGroupInfoSharedMediaImagesAndVideosCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var sharedMediaImageView: UIImageView!
    @IBOutlet weak var videoSizeLabel: UILabel!
    @IBOutlet weak var mediaDownloadIndicator: IGDownloadUploadIndicatorView!
    
    var attachment: IGFile?
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    override func awakeFromNib() {
        self.mediaDownloadIndicator.shouldShowSize = true
        self.mediaDownloadIndicator.isHidden = true

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        sharedMediaImageView.image = nil
        videoSizeLabel.text = nil
        //self.mediaDownloadIndicator.isHidden = true
        self.mediaDownloadIndicator.prepareForReuse()
    }
    func setMediaIndicator(message: IGRoomMessage) {
        if message.attachment?.status != .ready {
            self.mediaDownloadIndicator.isHidden = false
            self.mediaDownloadIndicator.size = attachment?.sizeToString()
            self.mediaDownloadIndicator.delegate = self
            self.mediaDownloadIndicator.setFileType(.media)
            self.mediaDownloadIndicator.setState((message.attachment?.status)!)
            if attachment?.status == .downloading ||  message.attachment?.status == .uploading {
                self.mediaDownloadIndicator.setPercentage((message.attachment?.downloadUploadPercent)!)
            }

        }
        
    }

}
extension IGChannelAndGroupInfoSharedMediaImagesAndVideosCollectionViewCell: IGDownloadUploadIndicatorViewDelegate {
    func downloadUploadIndicatorDidTapOnStart(_ indicator: IGDownloadUploadIndicatorView) {
        if self.attachment?.status == .downloading {
            return
        }
        if self.attachment?.status == .readyToDownload {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
               // self.mediaDownloadIndicator.prepareForReuse()
                let progress = Progress(totalUnitCount: 100)
                progress.completedUnitCount = 0
                self.mediaDownloadIndicator.setState((self.attachment?.status)!)
                self.mediaDownloadIndicator.setPercentage((self.attachment?.downloadUploadPercent)!)
            }

        }
        
        if let attachment = self.attachment {
            IGDownloadManager.sharedManager.download(file: attachment, previewType: .originalFile, completion: {
                self.mediaDownloadIndicator.prepareForReuse()
                self.mediaDownloadIndicator.setState((attachment.status))

            }, failure: {
                
            })
        }
    }
    
    func downloadUploadIndicatorDidTapOnCancel(_ indicator: IGDownloadUploadIndicatorView) {
        
    }
}
