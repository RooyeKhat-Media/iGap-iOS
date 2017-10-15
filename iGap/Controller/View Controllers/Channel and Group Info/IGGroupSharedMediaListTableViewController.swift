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
import SwiftProtobuf
import RealmSwift
import MBProgressHUD
import IGProtoBuff

class IGGroupSharedMediaListTableViewController: UITableViewController , UIGestureRecognizerDelegate {

    @IBOutlet weak var sizeOfSharedVideos: UILabel!
    @IBOutlet weak var sizeOfSharedImage: UILabel!
    @IBOutlet weak var sizeOfSharedAudiosLabel: UILabel!
    @IBOutlet weak var sizeOfSharedFiles: UILabel!
    @IBOutlet weak var sizeOfSharedLinksLabel: UILabel!
    @IBOutlet weak var sizeOfSharedVoice: UILabel!
    
//    @IBOutlet weak var imageIndicator: UIActivityIndicatorView!
//    @IBOutlet weak var voicesIndicator: UIActivityIndicatorView!
//    @IBOutlet weak var linkIndicator: UIActivityIndicatorView!
//    @IBOutlet weak var fileIndicator: UIActivityIndicatorView!
//    @IBOutlet weak var audioIndicator: UIActivityIndicatorView!
//    @IBOutlet weak var videoIndicator: UIActivityIndicatorView!
    
    
    var selectedRowNum : Int!
    var room: IGRoom?
    var hud = MBProgressHUD()
    var sharedMediaImageFile: [IGRoomMessage] = []
    var sharedMediaAudioFile: [IGRoomMessage] = []
    var sharedMediaVideoFile: [IGRoomMessage] = []
    var sharedMediaLinkFile:  [IGRoomMessage] = []
    var sharedMediaFile:      [IGRoomMessage] = []
    var sharedMediaVoiceFile:     [IGRoomMessage] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: "Done", title: "shared Media")
        navigationItem.navigationController = self.navigationController as! IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        getCountOfImages()
        getCountOfAudio()
        getCountOfVideos()
        getCountOfFile()
        getCountOfVoices()
        getCountOfLinks()
        getCountOfSahredMediaFiles()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.isUserInteractionEnabled = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 6
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            selectedRowNum = indexPath.row
            switch indexPath.row {
            case 0:
                if sharedMediaImageFile.count != 0 {
                    self.tableView.isUserInteractionEnabled = false

                self.performSegue(withIdentifier: "showImagesAndVideoSharedMediaCollection", sender: self)
                }
                break
            case 1:
                if sharedMediaAudioFile.count != 0 {
                    self.tableView.isUserInteractionEnabled = false
                self.performSegue(withIdentifier: "showLinksAndAudioSharedMediaTableview", sender: self)
                }
                break
            case 2:
                if sharedMediaVideoFile.count != 0 {
                    self.tableView.isUserInteractionEnabled = false
                self.performSegue(withIdentifier: "showImagesAndVideoSharedMediaCollection", sender: self)
                }
                break
            case 3:
                if sharedMediaFile.count != 0 {
                    self.tableView.isUserInteractionEnabled = false
                self.performSegue(withIdentifier: "showLinksAndAudioSharedMediaTableview", sender: self)
                }
                break
            case 4:
                if sharedMediaVoiceFile.count != 0 {
                    self.tableView.isUserInteractionEnabled = false
                self.performSegue(withIdentifier: "showLinksAndAudioSharedMediaTableview", sender: self)
                }
                break
            case 5:
                if sharedMediaLinkFile.count != 0 {
                    self.tableView.isUserInteractionEnabled = false
                    self.performSegue(withIdentifier: "showLinksAndAudioSharedMediaTableview", sender: self)
                }

            default:
                break
            }
            
        }
    }
    
    func getCountOfSahredMediaFiles() {
        if let selectedRoom = room {
            self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            self.hud.mode = .indeterminate
            IGClientCountRoomHistoryRequest.Generator.generate(roomID: selectedRoom.id).success({ (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let clientCountRoomHistory as IGPClientCountRoomHistoryResponse:
                        let response = IGClientCountRoomHistoryRequest.Handler.interpret(response: clientCountRoomHistory)
                        let media = response.media
                        let audio = response.audio
                        let video = response.video
                        let url = response.url
                        let file = response.file
                        let gif  = response.gif
                        let image = response.image
                        let voice = response.voice
                        self.sizeOfSharedVideos.text = "\(video)"
                        self.sizeOfSharedFiles.text = "\(file)"
                        self.sizeOfSharedImage.text = "\(image)"
                        self.sizeOfSharedVoice.text = "\(voice)"
                        self.sizeOfSharedAudiosLabel.text = "\(audio)"
                        self.sizeOfSharedLinksLabel.text = "\(url)"
                        self.hud.hide(animated: true)
                        
                    default:
                        break
                    }
                }
            }).error ({ (errorCode, waitTime) in
                switch errorCode {
                case .timeout:
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Timeout", message: "Please try again later", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                        self.hud.hide(animated: true)
                        
                    }
                default:
                    break
                }
                
            }).send()


        }
    }
    
    func getCountOfImages() {
        
        if let selectedRoom = room {
            IGClientSearchRoomHistoryRequest.Generator.generate(roomId: selectedRoom.id, offset: 0, filter: .image).success({ (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let clientSearchRoomHistoryResponse as IGPClientSearchRoomHistoryResponse:
                        let response =  IGClientSearchRoomHistoryRequest.Handler.interpret(response: clientSearchRoomHistoryResponse , roomId: selectedRoom.id)
                        if let messagesResponse: [IGPRoomMessage] = response.messages {
                            for message in messagesResponse {
                                let msg = IGRoomMessage(igpMessage: message, roomId: selectedRoom.id)
                                self.sharedMediaImageFile.append(msg)
                            }
                        }
                    default:
                        break
                    }
                }
            }).error ({ (errorCode, waitTime) in
                switch errorCode {
                case .timeout:
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Timeout", message: "Please try again later", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                case .clientSearchRoomHistoryNotFound:
                    DispatchQueue.main.async {
                        self.sizeOfSharedImage.text = "\(0)"
                    }
                default:
                    break
                }
                
            }).send()
            
        }
    }
    
    func getCountOfAudio() {
        if let selectedRoom = room {
            IGClientSearchRoomHistoryRequest.Generator.generate(roomId: selectedRoom.id, offset: 0, filter: .audio).success({ (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let clientSearchRoomHistoryResponse as IGPClientSearchRoomHistoryResponse:
                        let response =  IGClientSearchRoomHistoryRequest.Handler.interpret(response: clientSearchRoomHistoryResponse , roomId: selectedRoom.id)
                        if let messagesResponse: [IGPRoomMessage] = response.messages {
                            for message in messagesResponse {
                                let msg = IGRoomMessage(igpMessage: message, roomId: selectedRoom.id)
                                self.sharedMediaAudioFile.append(msg)
                            }
                        }
                        
                    default:
                        break
                    }
                }
            }).error ({ (errorCode, waitTime) in
                switch errorCode {
                case .timeout:
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Timeout", message: "Please try again later", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                case .clientSearchRoomHistoryNotFound:
                    DispatchQueue.main.async {
                        self.sizeOfSharedAudiosLabel.text = "\(0)"
                    }

                default:
                    break
                }
                
            }).send()
            
        }
    }
    
    func getCountOfVideos() {
        if let selectedRoom = room {
            IGClientSearchRoomHistoryRequest.Generator.generate(roomId: selectedRoom.id, offset: 0, filter: .video).success({ (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let clientSearchRoomHistoryResponse as IGPClientSearchRoomHistoryResponse:
                        let response =  IGClientSearchRoomHistoryRequest.Handler.interpret(response: clientSearchRoomHistoryResponse , roomId: selectedRoom.id)
                        if let messagesResponse: [IGPRoomMessage] = response.messages {
                            for message in messagesResponse {
                                let msg = IGRoomMessage(igpMessage: message, roomId: selectedRoom.id)
                                self.sharedMediaVideoFile.append(msg)
                            }
                        }
                    default:
                        break
                    }
                }
            }).error ({ (errorCode, waitTime) in
                switch errorCode {
                case .timeout:
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Timeout", message: "Please try again later", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                case .clientSearchRoomHistoryNotFound:
                    DispatchQueue.main.async {
                        self.sizeOfSharedVideos.text = "\(0)"

                    }

                default:
                    break
                }
                
            }).send()
            
        }
        
    }
    
    func getCountOfFile() {
        
        if let selectedRoom = room {
            IGClientSearchRoomHistoryRequest.Generator.generate(roomId: selectedRoom.id, offset: 0, filter: .file).success({ (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let clientSearchRoomHistoryResponse as IGPClientSearchRoomHistoryResponse:
                        let response =  IGClientSearchRoomHistoryRequest.Handler.interpret(response: clientSearchRoomHistoryResponse , roomId: selectedRoom.id)
                        if let messagesResponse: [IGPRoomMessage] = response.messages {
                            for message in messagesResponse {
                                let msg = IGRoomMessage(igpMessage: message, roomId: selectedRoom.id)
                                self.sharedMediaFile.append(msg)
                            }
                        }
                        let countOfImage = response.NotDeletedCount
                        self.sizeOfSharedFiles.text = "\(countOfImage)"
                    default:
                        break
                    }
                }
            }).error ({ (errorCode, waitTime) in
                switch errorCode {
                case .timeout:
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Timeout", message: "Please try again later", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                case .clientSearchRoomHistoryNotFound:
                    DispatchQueue.main.async {
                        self.sizeOfSharedFiles.text = "\(0)"
                    }

                default:
                    break
                }
                
            }).send()
            
        }

    }
    
    func getCountOfVoices() {
        if let selectedRoom = room {
            IGClientSearchRoomHistoryRequest.Generator.generate(roomId: selectedRoom.id, offset: 0, filter: .voice).success({ (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let clientSearchRoomHistoryResponse as IGPClientSearchRoomHistoryResponse:
                        let response =  IGClientSearchRoomHistoryRequest.Handler.interpret(response: clientSearchRoomHistoryResponse , roomId: selectedRoom.id)
                        if let messagesResponse: [IGPRoomMessage] = response.messages {
                            for message in messagesResponse {
                                let msg = IGRoomMessage(igpMessage: message, roomId: selectedRoom.id)
                                self.sharedMediaVoiceFile.append(msg)
                            }
                        }
                        let countOfImage = response.NotDeletedCount
                        self.sizeOfSharedVoice.text = "\(countOfImage)"
                    default:
                        break
                    }
                }
            }).error ({ (errorCode, waitTime) in
                switch errorCode {
                case .timeout:
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Timeout", message: "Please try again later", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                case .clientSearchRoomHistoryNotFound:
                    DispatchQueue.main.async {
                        self.sizeOfSharedLinksLabel.text = "\(0)"
                    }
   
                default:
                    break
                }
                
            }).send()
            
        }

    }
    func getCountOfLinks() {
        if let selectedRoom = room {
            IGClientSearchRoomHistoryRequest.Generator.generate(roomId: selectedRoom.id, offset: 0, filter: .url).success({ (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let clientSearchRoomHistoryResponse as IGPClientSearchRoomHistoryResponse:
                        let response =  IGClientSearchRoomHistoryRequest.Handler.interpret(response: clientSearchRoomHistoryResponse , roomId: selectedRoom.id)
                        if let messagesResponse: [IGPRoomMessage] = response.messages {
                            for message in messagesResponse {
                                let msg = IGRoomMessage(igpMessage: message, roomId: selectedRoom.id)
                                self.sharedMediaLinkFile.append(msg)
                            }
                        }
                        let countOfImage = response.NotDeletedCount
                        self.sizeOfSharedLinksLabel.text = "\(countOfImage)"
                    default:
                        break
                    }
                }
            }).error ({ (errorCode, waitTime) in
                switch errorCode {
                case .timeout:
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Timeout", message: "Please try again later", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                case .clientSearchRoomHistoryNotFound:
                    DispatchQueue.main.async {
                        self.sizeOfSharedLinksLabel.text = "\(0)"
                    }
                    
                default:
                    break
                }
                
            }).send()
            
        }
        

    }


        // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showImagesAndVideoSharedMediaCollection" {
            let destination = segue.destination as! IGChannelAndGroupSharedMediaImagesAndVideosCollectionViewController
            
            destination.room = room
            switch selectedRowNum {
            case 0:
                destination.navigationTitle = "Images"
                destination.sharedMedia = sharedMediaImageFile
            case 2:
                destination.navigationTitle = "Videos"
                destination.sharedMedia = sharedMediaVideoFile
            default:
                break
            }
        }
        
        if segue.identifier == "showLinksAndAudioSharedMediaTableview" {
            let destination = segue.destination as! IGChannelAndGroupSharedMediaAudioAndLinkTableViewController
            destination.room = room
            switch selectedRowNum {
            case 1:
                destination.navigationTitle = "Audio"
                
                destination.sharedMedia = sharedMediaAudioFile
            case 3:
                destination.navigationTitle = "Files"
                destination.sharedMedia = sharedMediaFile
            case 4:
                destination.navigationTitle = "Voices"
                print( sharedMediaVoiceFile.count)
                destination.sharedMedia = sharedMediaVoiceFile
            case 5:
                destination.navigationTitle = "Links"
                print( sharedMediaLinkFile.count)
                destination.sharedMedia = sharedMediaLinkFile
                
            default:
                break
            }
            
        }
    }
}
