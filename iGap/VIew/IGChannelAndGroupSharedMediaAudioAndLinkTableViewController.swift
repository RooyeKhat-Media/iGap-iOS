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
import INSPhotoGalleryFramework

class IGChannelAndGroupSharedMediaAudioAndLinkTableViewController: UITableViewController , UIGestureRecognizerDelegate, UIDocumentInteractionControllerDelegate {
    
    var sharedMedia = [IGRoomMessage]()
    var room: IGRoom?
    var hud = MBProgressHUD()
    var shareMediaMessage : Results<IGRoomMessage>!
    var notificationToken: NotificationToken?
    var isFetchingFiles: Bool = false
    var navigationTitle : String!
    var sharedMediaFilter : IGSharedMediaFilter?
    private var player = IGMusicPlayer.sharedPlayer
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: navigationTitle )
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        
    }
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.isUserInteractionEnabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sharedMedia.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = UIColor.yellow
        if sharedMedia[indexPath.row].type == .audio || sharedMedia[indexPath.row].type == .audioAndText || sharedMedia[indexPath.row].type == .voice {
            let audioCell = tableView.dequeueReusableCell(withIdentifier: "SharedAudioAndVoiceCell", for: indexPath) as! IGGroupAndChannelInfoSharedMediaAudioAndVoicesTableViewCell
            let sharedImage = sharedMedia[indexPath.row]
            if let sharedAttachment = sharedImage.attachment {
                if sharedAttachment.type == .audio || sharedAttachment.type == .voice {
                    audioCell.setMediaPlayer(attachment: sharedAttachment , message: sharedImage )
                    if sharedAttachment.type == .audio {
                        sharedMediaFilter = .audio
                    } else  if  sharedAttachment.type == .voice {
                        sharedMediaFilter = .voice
                    }
                    return audioCell
                }
            }
        }
        
        if sharedMedia[indexPath.row].type == .file || sharedMedia[indexPath.row].type == .fileAndText {
            
            let fileCell = tableView.dequeueReusableCell(withIdentifier: "SharedFileCell", for: indexPath) as! IGChannelAndGroupInfoSharedMediaFileTableViewCell
            let sharedFile = sharedMedia[indexPath.row]
            if let sharedAttachment = sharedFile.attachment {
                if sharedAttachment.type == .file {
                    fileCell.setFileDetails(attachment: sharedAttachment , message: sharedFile)
                    sharedMediaFilter = .file
                    return fileCell
                }
            }
            
        } else if sharedMedia[indexPath.row].type == .text {
            let linkCell = tableView.dequeueReusableCell(withIdentifier: "SharedLinkCell", for: indexPath) as! IGGroupInfoShareMediaLinkTableViewCell
            let sharedLink = sharedMedia[indexPath.row]
            linkCell.setLinkDetails(message: sharedLink)
            sharedMediaFilter = .url
            return linkCell
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.isUserInteractionEnabled = false
        if sharedMedia[indexPath.row].type == .voice || sharedMedia[indexPath.row].type == .audio || sharedMedia[indexPath.row].type == .audioAndText {
            let musicPlayer = IGMusicViewController()
            musicPlayer.attachment = sharedMedia[indexPath.row].attachment
            self.present(musicPlayer, animated: true, completion: {})
        } else if let path = sharedMedia[indexPath.row].attachment?.path() {
            let controller = UIDocumentInteractionController()
            controller.delegate = self
            controller.url = path
            controller.presentPreview(animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offsetY > contentHeight - scrollView.frame.size.height {
            if isFetchingFiles == false {
                loadMoreDataFromServer()
            }
        }
    }
    
    func loadMoreDataFromServer() {
        if let selectedRoom = room {
            isFetchingFiles = true
            self.hud.mode = .indeterminate
            IGClientSearchRoomHistoryRequest.Generator.generate(roomId: selectedRoom.id, offset: Int32(sharedMedia.count), filter: sharedMediaFilter!).success({ (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let clientSearchRoomHistoryResponse as IGPClientSearchRoomHistoryResponse:
                        let response =  IGClientSearchRoomHistoryRequest.Handler.interpret(response: clientSearchRoomHistoryResponse , roomId: selectedRoom.id)
                        if let messagesResponse: [IGPRoomMessage] = response.messages {
                            for message in messagesResponse {
                                let msg = IGRoomMessage(igpMessage: message, roomId: selectedRoom.id)
                                self.sharedMedia.append(msg)
                            }
                        }
                        self.isFetchingFiles = false
                        self.tableView?.reloadData()
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
                        self.isFetchingFiles = false
                        self.present(alert, animated: true, completion: nil)
                    }
                default:
                    break
                }
                
            }).send()
        }
    }
    
    /******* overrided method for show file attachment (use from UIDocumentInteractionControllerDelegate) *******/
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
}
