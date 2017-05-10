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
import RealmSwift
import IGProtoBuff
import INSPhotoGalleryFramework
import RxRealm
import RxSwift
import Gifu
class IGSettingTableViewController: UITableViewController {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userAvatarView: IGAvatarView!
    @IBOutlet weak var cameraButton: UIButton!

    var imagePicker = UIImagePickerController()
    let borderName = CALayer()
    let width = CGFloat(0.5)
    var shareContent = NSString()
    var user : IGRegisteredUser?
    var avatars: [IGAvatar] = []
    var deleteView: IGTappableView?
    var userAvatar: IGAvatar?
    var downloadIndicatorMainView : IGDownloadUploadIndicatorView?
        
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        requestToGetAvatarList()
        let currentUserId = IGAppManager.sharedManager.userID()
        
        let realm = try! Realm()
        let predicate = NSPredicate(format: "id = %lld", currentUserId!)
        if let userInDb = realm.objects(IGRegisteredUser.self).filter(predicate).first {
            userAvatarView.setUser(userInDb)
            usernameLabel.text = userInDb.displayName
            user = userInDb
            userAvatarView.avatarImageView?.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.handleTap(recognizer:)))
            userAvatarView.avatarImageView?.addGestureRecognizer(tap)

            let navigationItem = self.navigationItem as! IGNavigationItem
            navigationItem.addModalViewItems(leftItemText: nil, rightItemText: "Done", title: "Settings")
        }
        
        let navigationItem = self.navigationItem as! IGNavigationItem
       // navigationItem.setChatListsNavigationItems()
        navigationItem.rightViewContainer?.addAction {
            self.dismiss(animated: true, completion: { 
                
            })
        }
        
        
        //roundUserImage(cameraButton)
        let cameraBtnImage = UIImage(named: "camera")
        cameraButton.setBackgroundImage(cameraBtnImage, for: .normal)
        self.tableView.backgroundView = UIImageView(image: UIImage(named: "IG_Settigns_Bg"))
        tableView.tableFooterView = UIView()
        imagePicker.delegate = self
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.isUserInteractionEnabled = true
        requestToGetAvatarList()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.isUserInteractionEnabled = true

    }
    
    func requestToGetAvatarList() {
        if let currentUserId = IGAppManager.sharedManager.userID() {
        IGUserAvatarGetListRequest.Generator.generate(userId: currentUserId).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let UserAvatarGetListoResponse as IGPUserAvatarGetListResponse:
                    let responseAvatars =   IGUserAvatarGetListRequest.Handler.interpret(response: UserAvatarGetListoResponse, userId: currentUserId)
                    self.avatars = responseAvatars
                    for avatar in self.avatars {
                        let avatarView = IGImageView()
                        avatarView.setImage(avatar: avatar)
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
            default:
                break
            }
            
        }).send()
        }
    }
    
    func handleTap(recognizer:UITapGestureRecognizer) {
        if recognizer.state == .ended {
            if let userAvatar = user?.avatar {
            showAvatar( avatar: userAvatar)
            }
        }
    }
    
    var avatarPhotos : [INSPhotoViewable]?
    var galleryPhotos: INSPhotosViewController?
    func showAvatar(avatar : IGAvatar) {
            var photos: [INSPhotoViewable] = self.avatars.map { (avatar) -> IGMedia in
               // setMediaIndicator(avatar: avatar)
                return IGMedia(avatar: avatar)
            }
        avatarPhotos = photos
        let currentPhoto = photos[0]

        let deleteViewFrame = CGRect(x:320, y:595, width: 25 , height:25)
        let trashImageView = UIImageView()
        trashImageView.image = UIImage(named: "IG_Trash_avatar")
        trashImageView.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        deleteView = IGTappableView(frame: deleteViewFrame)
        deleteView?.addSubview(trashImageView)
        let downloadViewFrame = self.view.bounds
        deleteView?.addAction {
            self.didTapOnTrashButton()
        }
         downloadIndicatorMainView = IGDownloadUploadIndicatorView(frame: downloadViewFrame)
        let galleryPreview = INSPhotosViewController(photos: photos, initialPhoto: currentPhoto, referenceView: nil, deleteView: deleteView, downloadView: nil)
        galleryPhotos = galleryPreview
        present(galleryPreview, animated: true, completion: nil)
        
    }
    
    func setMediaIndicator(avatar: IGAvatar) {
        if let msgAttachment = avatar.file {
            if let messageAttachmentVariableInCache = IGAttachmentManager.sharedManager.getRxVariable(attachmentPrimaryKeyId: msgAttachment.primaryKeyId!) {
                self.userAvatar?.file = messageAttachmentVariableInCache.value
            } else {
                self.userAvatar?.file = msgAttachment.detach()
                let attachmentRef = ThreadSafeReference(to: msgAttachment)
                IGAttachmentManager.sharedManager.add(attachmentRef: attachmentRef)
                self.userAvatar?.file = IGAttachmentManager.sharedManager.getRxVariable(attachmentPrimaryKeyId: msgAttachment.primaryKeyId!)?.value
            }
            
            
            if let variableInCache = IGAttachmentManager.sharedManager.getRxVariable(attachmentPrimaryKeyId: msgAttachment.primaryKeyId!) {
                self.userAvatar?.file = variableInCache.value
                variableInCache.asObservable().subscribe({ (event) in
                    DispatchQueue.main.async {
                        self.updateAttachmentDownloadUploadIndicatorView()
                    }
                }).addDisposableTo(disposeBag)
            } else {
            }
            
            //MARK: ▶︎ Rx End
                //self.forwardedMessageAudioAndVoiceViewHeightConstraint.constant = 0
                self.userAvatarView.isHidden = false
                self.downloadIndicatorMainView?.isHidden = false
                let progress = Progress(totalUnitCount: 100)
                progress.completedUnitCount = 0
                
               // self.sharedMediaImageView.setThumbnail(for: msgAttachment)
                // self.forwardedMessageMediaContainerViewHeightConstraint.constant = messageSizes.forwardedMessageAttachmentHeight //+ 20
                
                if msgAttachment.status != .ready {
                    self.downloadIndicatorMainView?.size = msgAttachment.sizeToString()
                    self.downloadIndicatorMainView?.delegate = self
                }
            
            
        }
        
    }
    
    
    func updateAttachmentDownloadUploadIndicatorView() {
        if let attachment =  self.userAvatar?.file {
            
            if attachment.status == .ready {
                self.downloadIndicatorMainView?.setState(attachment.status)
                setThumbnailForAttachments()
                if attachment.type == .image {
                   // self.currentPhoto.setThumbnail(for: attachment)
                }
                return
            }
            
            
            switch attachment.type {
            case .video, .image:
                self.downloadIndicatorMainView?.setFileType(.media)
                self.downloadIndicatorMainView?.setState(attachment.status)
                if attachment.status == .downloading ||  attachment.status == .uploading {
                    self.downloadIndicatorMainView?.setPercentage(attachment.downloadUploadPercent)
                }
            default:
                break
            }
        }
        
    }
    
    func setThumbnailForAttachments() {
        if let attachment = self.userAvatar?.file {
          //  self.currentPhoto.isHidden = false
            
        }
    }

    
    func didTapOnTrashButton() {
        
//        galleryPhotos?.currentPhotoViewController = { [weak self] photo in
//            if let index = self?.avatarPhotos?.index(where: {$0 === photo}) {
//                 print(self?.avatars[index].id)
//               // let indexPath = IndexPath(item: index, section: 0)
//                //let cell = collectionView.cellForItem(at: indexPath) as? ExampleCollectionViewCell
//            }
//            return nil
//        }
//        if let index = self.avatarPhotos?.index(where: {$0 === photo}) {
//            print(avatars[index].id)
//            
//        }

    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 2
        case 2 :
            return 2
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        

        if indexPath.section == 0 && indexPath.row == 0 {
            self.tableView.isUserInteractionEnabled = false
            performSegue(withIdentifier: "GoToAccountSettingPage", sender: self)
        }
        if indexPath.section == 1 && indexPath.row == 0 {
            self.tableView.isUserInteractionEnabled = false

            performSegue(withIdentifier: "GoToContactListPage", sender: self)
        }
        if indexPath.section == 1 && indexPath.row == 2 {
            self.tableView.isUserInteractionEnabled = false

            performSegue(withIdentifier: "GoToChatSettingPage", sender: self)
        }
        if indexPath.section == 1 && indexPath.row == 3 {
            self.tableView.isUserInteractionEnabled = false

            performSegue(withIdentifier: "GoToNotificationSettingsPage", sender: self)
        }
        if indexPath.section == 1 && indexPath.row == 1 {
            self.tableView.isUserInteractionEnabled = false
            performSegue(withIdentifier: "GoToPrivacyAndPolicySettingsPage", sender: self)
        }
        if indexPath.section == 2 && indexPath.row == 0 {
            shareContent = "Hey Join iGap and start new connection with friends and family for free, no matter what device they are on!\niGap Limitless Connection\nwww.iGap.net"
            let activityViewController = UIActivityViewController(activityItems: [shareContent as NSString], applicationActivities: nil)
            
            present(activityViewController, animated: true, completion: {})
        }
        if indexPath.section == 2 && indexPath.row == 1 {
            self.tableView.isUserInteractionEnabled = false
            performSegue(withIdentifier: "GoToAboutSettingPage", sender: self)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return CGFloat.leastNormalMagnitude
        }
        return tableView.sectionHeaderHeight
    }
    
    @IBAction func userImageClick(_ sender: UIButton) {
        //choosePhotoActionSheet(sender: userImage)
    }
    
    @IBAction func cameraButtonClick(_ sender: UIButton) {
        choosePhotoActionSheet(sender: cameraButton)
    }

    func choosePhotoActionSheet(sender : UIButton){
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cameraOption = UIAlertAction(title: "Take a Photo", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Take a Photo")
            if UIImagePickerController.availableCaptureModes(for: .rear) != nil{
                self.imagePicker.delegate = self
                self.imagePicker.allowsEditing = true
                self.imagePicker.sourceType = .camera
                self.imagePicker.cameraCaptureMode = .photo
                if UIDevice.current.userInterfaceIdiom == .phone {
                    self.present(self.imagePicker, animated: true, completion: nil)
                }
                else {
                    self.present(self.imagePicker, animated: true, completion: nil)//4
                    self.imagePicker.popoverPresentationController?.sourceView = (sender )
                    self.imagePicker.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
                    self.imagePicker.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
                }
            }
        })
        let ChoosePhoto = UIAlertAction(title: "Choose Photo", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Choose Photo")
            self.imagePicker.delegate = self
            self.imagePicker.allowsEditing = true
            self.imagePicker.sourceType = .photoLibrary
            if UIDevice.current.userInterfaceIdiom == .phone {
                self.present(self.imagePicker, animated: true, completion: nil)
            }
            else {
                self.present(self.imagePicker, animated: true, completion: nil)//4
                self.imagePicker.popoverPresentationController?.sourceView = (sender)
                self.imagePicker.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
                self.imagePicker.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        optionMenu.addAction(ChoosePhoto)
        optionMenu.addAction(cancelAction)
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) == true {
            optionMenu.addAction(cameraOption)} else {
            print ("I don't have a camera.")
        }
        if let popoverController = optionMenu.popoverPresentationController {
            popoverController.sourceView = cameraButton
        }
        self.present(optionMenu, animated: true, completion: nil)
    }
}

extension IGSettingTableViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.userAvatarView.setImage(pickedImage)
            
            let avatar = IGFile()
            avatar.attachedImage = pickedImage
            let randString = IGGlobal.randomString(length: 32)
            avatar.primaryKeyId = randString
            avatar.name = randString
            
            IGUploadManager.sharedManager.upload(file: avatar, start: {
                
            }, progress: { (progress) in
                
            }, completion: { (uploadTask) in
                if let token = uploadTask.token {
                    IGUserAvatarAddRequest.Generator.generate(token: token).success({ (protoResponse) in
                        DispatchQueue.main.async {
                            switch protoResponse {
                            case let avatarAddResponse as IGPUserAvatarAddResponse:
                                IGUserAvatarAddRequest.Handler.interpret(response: avatarAddResponse)
                            default:
                                break
                            }
                        }
                    }).error({ (error, waitTime) in
                        
                    }).send()
                }
            }, failure: {
                
            })
        }
        imagePicker.dismiss(animated: true, completion: {
        })
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension IGSettingTableViewController: UINavigationControllerDelegate {
    
}
extension IGSettingTableViewController: IGDownloadUploadIndicatorViewDelegate {
    func downloadUploadIndicatorDidTapOnStart(_ indicator: IGDownloadUploadIndicatorView) {
        if self.userAvatar?.file?.status == .downloading {
            return
        }
        
        if let attachment = self.userAvatar?.file {
            IGDownloadManager.sharedManager.download(file: attachment, previewType: .originalFile, completion: {
                
            }, failure: {
                
            })
        }
        
    }
    
    func downloadUploadIndicatorDidTapOnCancel(_ indicator: IGDownloadUploadIndicatorView) {
        
    }
}

