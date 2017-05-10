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
import ProtocolBuffers
import RealmSwift
import MBProgressHUD
import IGProtoBuff
import INSPhotoGalleryFramework
import AVKit
import AVFoundation


private let reuseIdentifier = "SharedMediaImageAndVideoCell"

class IGChannelAndGroupSharedMediaImagesAndVideosCollectionViewController: UICollectionViewController , UIGestureRecognizerDelegate {

    var sharedMedia: [IGRoomMessage] = []
    var room: IGRoom?
    var hud = MBProgressHUD()
    var shareMediaMessage : Results<IGRoomMessage>!
    var notificationToken: NotificationToken?
    var isFetchingFiles: Bool = false
    var navigationTitle : String!
    var sharedMediaFilter : IGSharedMediaFilter?
//    var countOfSharedMedia : Int32 = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        if let thisRoom = room {
            let messagePredicate = NSPredicate(format: "roomId = %lld AND isDeleted == false AND  isFromSharedMedia == true", thisRoom.id)
            shareMediaMessage =  try! Realm().objects(IGRoomMessage.self).filter(messagePredicate)
            self.notificationToken = shareMediaMessage.addNotificationBlock { (changes: RealmCollectionChange) in
                switch changes {
                case .initial:
                    self.collectionView?.reloadData()
                    break
                case .update(_, let deletions, let insertions, let modifications):
                    print("updating members tableV")
                    // Query messages have changed, so apply them to the TableView
                    self.collectionView?.reloadData()
                    break
                case .error(let err):
                    // An error occurred while opening the Realm file on the background worker thread
                    fatalError("\(err)")
                    break
                }
            }
        }
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: navigationTitle )
        navigationItem.navigationController = self.navigationController as! IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
        let screenRect : CGRect = UIScreen.main.bounds
        let screenWidth: CGFloat = screenRect.size.width
        layout.itemSize = CGSize(width: screenWidth/3, height: screenWidth/3)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView?.collectionViewLayout = layout

            }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return sharedMedia.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SharedMediaImageAndVideoCell", for: indexPath) as! IGChannelAndGroupInfoSharedMediaImagesAndVideosCollectionViewCell
        // Configure the cell
        if sharedMedia[indexPath.row].type == .image || sharedMedia[indexPath.row].type == .imageAndText {
            if let sharedImage: IGRoomMessage = sharedMedia[indexPath.row] {
                if let sharedAttachment = sharedImage.attachment {
                    if sharedAttachment.type == .image {
                        cell.sharedMediaImageView.setThumbnail(for: sharedAttachment)
                        cell.videoSizeLabel.isHidden = true
                        sharedMediaFilter = .image
                        //cell.attachment = sharedAttachment
                        cell.setMediaIndicator(message: sharedImage)
                        

                    }
                }
            }
        }
        
        if sharedMedia[indexPath.row].type == .video || sharedMedia[indexPath.row].type == .videoAndText {
            if let sharedImage: IGRoomMessage = sharedMedia[indexPath.row] {
                if let sharedAttachment = sharedImage.attachment {
                    if sharedAttachment.type == .video {
                        cell.sharedMediaImageView.setThumbnail(for: sharedAttachment)
                        let sizeInByte = sharedAttachment.size
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
                        cell.videoSizeLabel.text = sizeSting
                        cell.videoSizeLabel.isHidden = false
                        sharedMediaFilter = .video
                        cell.setMediaIndicator(message: sharedImage)
                       // cell.attachment = sharedAttachment
                    }

                }
            }
            
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if sharedMedia[indexPath.row].type == .image {
            var photos: [INSPhotoViewable] = Array(self.sharedMedia.map { (message) -> IGMedia in
                return IGMedia(message: message, forwardedMedia: false)
            })
            
            let currentPhoto = photos[indexPath.row]
            let galleryPreview = INSPhotosViewController(photos: photos, initialPhoto: currentPhoto, referenceView: nil)
            present(galleryPreview, animated: true, completion: nil)
        } else if sharedMedia[indexPath.row].type == .video {
            if let path = sharedMedia[indexPath.row].attachment?.path() {
                let player = AVPlayer(url: path)
                let avController = AVPlayerViewController()
                avController.player = player
                player.play()
                present(avController, animated: true, completion: nil)
                
            }
        }
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offsetY > contentHeight - scrollView.frame.size.height {
            if isFetchingFiles == false {
            loadMoreDataFromServer()
            self.collectionView?.reloadData()
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
    
   
}

extension IGChannelAndGroupSharedMediaImagesAndVideosCollectionViewController : UICollectionViewDelegateFlowLayout {
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let edgeIneset: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return edgeIneset
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenRect : CGRect = UIScreen.main.bounds
        let screenWidth: CGFloat = screenRect.size.width
        let cellWidth = screenWidth / 3.0
        let size = CGSize(width: cellWidth, height: cellWidth)
        
        return size
    }
}

