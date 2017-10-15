/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the RooyeKhat Media Company - www.RooyeKhat.co
 * All rights reserved.
 */

import Foundation
import AVFoundation

enum RepeatType {
    case none
    case single
    case all
}

protocol IGMusicPlayerDelegate {
    //var mustBeSettable: Int { get set }
    func player(_ player:IGMusicPlayer, didStartPlaying item:AVPlayerItem)
    func player(_ player:IGMusicPlayer, didPausePlaying item:AVPlayerItem)
    func player(_ player:IGMusicPlayer, didStopPlaying item:AVPlayerItem)
}

//func ==(lhs: IGMusicPlayerDelegate, rhs: IGMusicPlayerDelegate) -> Bool {
//    return lhs. == rhs.identifier()
//}
//
//func !=(lhs: IGMusicPlayerDelegate, rhs: IGMusicPlayerDelegate) -> Bool {
//    return lhs.identifier() != rhs.identifier()
//}


class IGMusicPlayer {
    static let sharedPlayer = IGMusicPlayer()
    
    private var player = AVQueuePlayer()
    private var mediaList = [AVPlayerItem]()
    private var filesList = [IGFile]()
    private var currentItems: AVPlayerItem?
    private var currentFile: IGFile?
    private var repeatState: RepeatType = .none
    private var shuffle: Bool = false
    private var currentTime : CMTime?
    
    private var watchers = [IGMusicPlayerDelegate]() //player can have more than one delegate (watcher)
    
    private init() {
        
    }
    
    func play(index: Int, from list: Array<IGFile>) {
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: [])
        let path = list.first?.path()
        let asset = AVURLAsset(url: path!)
        let playerItem = AVPlayerItem(asset: asset)
        player.insert(playerItem, after:nil)
        player.play()
    }
    
    func resume() {
    }
    
    func getCurrentTime() -> CMTime {
        return player.currentTime()
    }
    
    func pause() {
        player.pause()
    }
    
    func next() {
    }
    
    func previuos() {
    }
    
    func seekToTime(value : CMTime) {
        player.currentItem?.seek(to: value)
    }

    
    func setShuffle(_ shuffle:Bool) {
    }
    
    func setRepeat(_ repeatState:RepeatType) {
    }
    
    func addWatcher(_ watcher:IGMusicPlayerDelegate) -> Int {
        watchers.append(watcher)
        return watchers.count - 1
    }
    
    func removeWatcher(at index:Int) {
        watchers.remove(at: index)
    }
    
    func checkPlayerControlStatus() -> Bool {
        if player.rate > 0 {
            return true
        } else {
            return false
        }
    }
    
    func removeItemsFromList() {
        player.removeAllItems()
    }
    
}
