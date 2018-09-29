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

class IGMusicViewController: UIViewController {
    
    @IBOutlet weak var mediaCoverImageView: UIImageView!
    @IBOutlet weak var mediaCurrentTimeSlider: UISlider!
    @IBOutlet weak var mediaElapsedTimeLabel: UILabel!
    @IBOutlet weak var mediaRemainingTimeLabel: UILabel!
    @IBOutlet weak var mediaNameLabel: UILabel!
    @IBOutlet weak var mediaArtistAlbumName: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var previousButton: UIButton!
    private var player = IGMusicPlayer.sharedPlayer
    private var playerWatcherIndex = 0
    var flag: Bool = false
    var attachment: IGFile?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mediaCurrentTimeSlider.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb"), for: .normal)
        mediaCurrentTimeSlider.value = 0.0
        mediaElapsedTimeLabel.text = "\(mediaCurrentTimeSlider.value)"
        if let attach = attachment {
            if attach.type == .voice {
                mediaNameLabel.text = attach.fileNameOnDisk
                mediaArtistAlbumName.text = ""
                mediaCoverImageView.image = UIImage(named: "IG_Music_Player_Mic")
            }
            if attachment?.type == .audio {
                fetchMP3Info()
            }
            let path = attach.path()
            let asset = AVURLAsset(url: path!)
            let time = (CMTimeGetSeconds(asset.duration))
            let timeInt = Int(time)
            let remainingSeconds = timeInt%60
            let remainingMiuntes = timeInt/60
            mediaRemainingTimeLabel.text = "\(remainingMiuntes):\(remainingSeconds)"
            mediaCurrentTimeSlider.maximumValue = Float(time)
        }
        playerWatcherIndex = player.addWatcher(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let file = attachment {
            let files = [file]
            player.play(index: 0, from: files)
            updateSliderValue()
        }
    }
    
    func updateSliderValue() {
        if flag == false {
            mediaCurrentTimeSlider.isContinuous = true
            let currentTime = player.getCurrentTime()
            let currentTimeFloat = (CMTimeGetSeconds(currentTime))
            let currentValue = Float(currentTimeFloat)
            if currentValue <=  mediaCurrentTimeSlider.maximumValue{
                mediaCurrentTimeSlider.setValue(Float(currentTimeFloat),animated: true)
                let elapsedtime = (CMTimeGetSeconds(currentTime))
                let elapsedtimeInt = Int(elapsedtime)
                let remainingSeconds = elapsedtimeInt%60
                let remainingMiuntes = elapsedtimeInt/60
                mediaElapsedTimeLabel.text = "\(remainingMiuntes):\(remainingSeconds)"
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.updateSliderValue()
                }
            }
            if currentValue == mediaCurrentTimeSlider.maximumValue {
                let playImage = UIImage(named: "IG_Music_Player_Play")
                playPauseButton.setImage(playImage, for: .normal)
            }
        }
    }
    
    @IBAction func didTouchUpInsideSlide(_ sender: Any) {
        sliderValueChanged()
    }
    
    @IBAction func didTouchoutSideSlide(_ sender: Any) {
        sliderValueChanged()
    }
    
    @IBAction func didTouchDownSlide(_ sender: Any) {
        flag = true
    }
    
    func sliderValueChanged() {
        let path = attachment!.path()
        let asset = AVURLAsset(url: path!)
        let playerItem = AVPlayerItem(asset: asset)
        let t1 = Float((playerItem.currentTime().value))
        let t2 = Float((playerItem.currentTime().timescale))
        let times2 = t1 / t2
        print(times2)
        let timeScale = playerItem.asset.duration.timescale
        let value = mediaCurrentTimeSlider.value
        let valueInt = Int64(value)
        player.seekToTime(value:  CMTimeMakeWithSeconds(Float64(valueInt), timeScale))
        flag = false
        updateSliderValue()
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
                case "artist": mediaArtistAlbumName.text = value as? String
                case "albumname": albumName = (value as? String)!
                case "artwork" where value is NSData : mediaCoverImageView.image = UIImage(data: (value as! NSData) as Data)
                default:
                    continue
                }
            }
            
            if mediaCoverImageView.image == nil {
                mediaCoverImageView.image = UIImage(named: "IG_Message_Cell_Player_Default_Cover")
            }
            
            mediaNameLabel.text = "\(titleName)-\(albumName)"
        }
    }
    
    @IBAction func didChangedSliderValue(_ sender: Any) {
        flag = true
        let value = mediaCurrentTimeSlider.value
        let valueInt = Int(value)
        let remainingSeconds = valueInt%60
        let remainingMiuntes = valueInt/60
        mediaElapsedTimeLabel.text = "\(remainingMiuntes):\(remainingSeconds)"
    }
    
    @IBAction func didTapOnPlayPauseButton(_ sender: UIButton) {
        if let file = attachment {
            let files = [file]
            let isPlaying = player.checkPlayerControlStatus()
            if isPlaying {
                let playImage = UIImage(named: "IG_Music_Player_Play")
                playPauseButton.setImage(playImage, for: .normal)
                player.pause()
                flag = true
            } else {
                let pauseImage = UIImage(named: "IG_Music_Player_Pause")
                playPauseButton.setImage(pauseImage, for: .normal)
                player.play(index: 0, from: files)
                flag = false
                updateSliderValue()
            }
        }
    }
    
    @IBAction func didTapOnNextButton(_ sender: UIButton) {
        
    }
    
    @IBAction func didTapOnPreviousButton(_ sender: UIButton) {
        
    }
    
    @IBAction func didTapOnCloseButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: {
            self.player.pause()
            let path = self.attachment!.path()
            let asset = AVURLAsset(url: path!)
            let playerItem = AVPlayerItem(asset: asset)
            let timeScale = playerItem.asset.duration.timescale
            self.player.seekToTime(value:  CMTimeMakeWithSeconds(Float64(0), timeScale))
            self.player.removeItemsFromList()
        })
    }
    
}

extension IGMusicViewController:IGMusicPlayerDelegate {
    func player(_ player:IGMusicPlayer, didStartPlaying item:AVPlayerItem) {
        
    }
    
    func player(_ player:IGMusicPlayer, didPausePlaying item:AVPlayerItem) {
        
    }
    
    func player(_ player:IGMusicPlayer, didStopPlaying item:AVPlayerItem) {
        
    }
}
