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
import AVFoundation
import MediaPlayer
class IGForwardMessageAudioAndVoiceAttachmentView: UIView {
    
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var mediaRemainingTimeLabel: UILabel!
    @IBOutlet weak var mediaCoverImageView: UIImageView!
    @IBOutlet weak var playingSlider: UISlider!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    private var player = IGMusicPlayer.sharedPlayer
    private var playerWatcherIndex = 0
    var flag: Bool = false
    var attachment: IGFile?
    
    
    
    //MARK: - Class Methods
    class func nib() -> UINib {
        return UINib(nibName: "IGForwardMessageAudioAndVoiceAttachment", bundle: Bundle(for: self))
    }
    
    class func cellReuseIdentifier() -> String {
        return NSStringFromClass(self)
    }
    
    class func messageBodyTextViewFont() -> UIFont {
        return UIFont.igFont(ofSize: 14.0)
    }
    
    class func replyToLabelFont() -> UIFont {
        return UIFont.igFont(ofSize: 14.0)
    }

    class func sizeForAttachment() -> CGSize {
        let height = 101
        let width = 350
        return CGSize(width: width, height: height)
    }


    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib ()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib ()
    }
    
    func loadViewFromNib() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "IGForwardMessageAudioAndVoiceAttachment", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = CGRect(x: 0, y: 0, width: 260, height: 68)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(view)
    }
    
    override func awakeFromNib() {
        
    }
    
    func setMediaPlayerCell(_ attachment: IGFile) {
        print(attachment.fileNameOnDisk)
        self.playingSlider.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb"), for: .normal)
        playingSlider.value = 0.0
        mediaRemainingTimeLabel.text = "\(playingSlider.value)"
            if attachment.type == .voice {
                songNameLabel.text = attachment.fileNameOnDisk
                artistLabel.text = ""
                let voiceImage = UIImage(named: "IG_Message_Cell_Voice")
                mediaCoverImageView.image = voiceImage
            }
            if attachment.type == .audio {
                fetchMP3Info()
            }
            let path = attachment.path()
            let asset = AVURLAsset(url: path!)
            let time = (CMTimeGetSeconds(asset.duration))
            let timeInt = Int(time)
            let remainingSeconds = timeInt%60
            let remainingMiuntes = timeInt/60
            mediaRemainingTimeLabel.text = "\(remainingMiuntes):\(remainingSeconds)"
            playingSlider.maximumValue = Float(time)
            playerWatcherIndex = player.addWatcher(self)

    }
    
    func fetchMP3Info() {
        var albumName = ""
        var titleName = ""
        if let attach = attachment {
            let path = attach.path()
            let asset = AVURLAsset(url: path!)
            let playerItem = AVPlayerItem(asset: asset)
            let metaList = playerItem.asset.commonMetadata
            for item in metaList {
                guard let key = item.commonKey, let value = item.value else{
                    continue
                }
                switch key {
                case "title" : titleName = (value as? String)!
                case "artist": artistLabel.text = value as? String
                case "albumname": albumName = (value as? String)!
                case "artwork" where value is NSData : mediaCoverImageView.image = UIImage(data: (value as! NSData) as Data)
                default:
                    continue
                }
            }
            songNameLabel.text = "\(titleName)-\(albumName)"
        }
    }
}
extension IGForwardMessageAudioAndVoiceAttachmentView: IGMusicPlayerDelegate {
    func player(_ player:IGMusicPlayer, didStartPlaying item:AVPlayerItem) {
        
    }
    
    func player(_ player:IGMusicPlayer, didPausePlaying item:AVPlayerItem) {
        
    }
    
    func player(_ player:IGMusicPlayer, didStopPlaying item:AVPlayerItem) {
        
    }
}

