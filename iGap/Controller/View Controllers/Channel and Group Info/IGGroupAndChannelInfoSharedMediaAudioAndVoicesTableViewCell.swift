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

class IGGroupAndChannelInfoSharedMediaAudioAndVoicesTableViewCell: UITableViewCell {

    @IBOutlet weak var mediaCoverImageView: UIImageView!
    @IBOutlet weak var mediaSizeLabel: UILabel!
    @IBOutlet weak var creationDateLabel: UILabel!
    @IBOutlet weak var durationTimeLabel: UILabel!
    @IBOutlet weak var playingSlider: UISlider!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var songNameLabel: UILabel!
    private var player = IGMusicPlayer.sharedPlayer
    private var playerWatcherIndex = 0
    var flag: Bool = false
    var attachment: IGFile?
    override func awakeFromNib() {
        super.awakeFromNib()
               // playerWatcherIndex = player.addWatcher(self)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setMediaPlayer(attachment: IGFile , message: IGRoomMessage) {
        self.playingSlider.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb"), for: .normal)
        playingSlider.value = 0.0
        durationTimeLabel.text = "\(playingSlider.value)"
        let sizeInByte = attachment.size
        var sizeSting = ""
        if sizeInByte < 1024 {
            //byte
            sizeSting = "\(sizeInByte) B"
        } else if sizeInByte < 1048576 {
            //kilobytes
            sizeSting = "\(sizeInByte/1024) KB"
        } else if sizeInByte < 1073741824 {
            //megabytes
            sizeSting = "\(sizeInByte/1048576) MB"
        } else { //if sizeInByte < 1099511627776 {
            //gigabytes
            sizeSting = "\(sizeInByte/1073741824) GB"
        }
        self.mediaSizeLabel.text = sizeSting
        
        if let creationtime = message.creationTime {
        creationDateLabel.text = "\(creationtime)"
            }
        
        if attachment.type == .voice {
            songNameLabel.text = attachment.name
            mediaCoverImageView.image = UIImage(named: "IG_Music_Player_Mic")
        }
        if attachment.type == .audio {
            //fetchMP3Info(attachment: attachment)
            songNameLabel.text = attachment.name
            mediaCoverImageView.setThumbnail(for: attachment)
        }
        
        let path = attachment.path()
        let asset = AVURLAsset(url: path!)
        let time = (CMTimeGetSeconds(asset.duration))
        let timeInt = Int(attachment.duration)
        let remainingSeconds = timeInt%60
        let remainingMiuntes = timeInt/60
        durationTimeLabel.text = "\(remainingMiuntes):\(remainingSeconds)"
        playingSlider.maximumValue = Float(time)
        
    }
    
    
}
