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
import NVActivityIndicatorView
class IGSettingTableViewController: UITableViewController , NVActivityIndicatorViewable {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userAvatarView: IGAvatarView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var versionCell: UITableViewCell!
    @IBOutlet weak var versionLabel: UILabel!

    var imagePicker = UIImagePickerController()
    let borderName = CALayer()
    let width = CGFloat(0.5)
    var shareContent = NSString()
    var user : IGRegisteredUser?
    var avatars: [IGAvatar] = []
    var deleteView: IGTappableView?
    var userAvatar: IGAvatar?
    //var downloadIndicatorMainView : IGDownloadUploadIndicatorView?
        
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        requestToGetAvatarList()
        let currentUserId = IGAppManager.sharedManager.userID()
        
        self.clearsSelectionOnViewWillAppear = true
        
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
        
        self.tableView.backgroundColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
        
        tableView.tableFooterView = UIView()
        imagePicker.delegate = self
        
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            self.versionLabel.text = "iGap iOS Client V \(version)"
        }
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.isUserInteractionEnabled = true
       // requestToGetAvatarList()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.isUserInteractionEnabled = true
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tableView.isUserInteractionEnabled = true
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: animated)
        }
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
                       // avatarView.setImage(avatar: avatar)
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
    var lastIndex: Array<Any>.Index?
    var currentAvatarId: Int64?
    var timer = Timer()
    func showAvatar(avatar : IGAvatar) {
            var photos: [INSPhotoViewable] = self.avatars.map { (avatar) -> IGMedia in
                return IGMedia(avatar: avatar)
            }
        avatarPhotos = photos
        let currentPhoto = photos[0]
        let deleteViewFrame = CGRect(x:320, y:595, width: 25 , height:25)
        let trashImageView = UIImageView()
        trashImageView.image = UIImage(named: "IG_Trash_avatar")
        trashImageView.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
//        deleteView = IGTappableView(frame: deleteViewFrame)
//        deleteView?.addSubview(trashImageView)
        let downloadViewFrame = self.view.bounds
//        deleteView?.addAction {
//            self.didTapOnTrashButton()
//        }
        let downloadIndicatorMainView = UIView()
        downloadIndicatorMainView.backgroundColor = UIColor.white
        downloadIndicatorMainView.frame = downloadViewFrame
        let andicatorViewFrame = CGRect(x: view.bounds.midX, y: view.bounds.midY,width: 50 , height: 50)
        let activityIndicatorView = NVActivityIndicatorView(frame: andicatorViewFrame,
                                                            type: NVActivityIndicatorType.audioEqualizer)
        downloadIndicatorMainView.addSubview(activityIndicatorView)
        
        let galleryPreview = INSPhotosViewController(photos: photos, initialPhoto: currentPhoto, referenceView: nil, deleteView: deleteView, downloadView: downloadIndicatorMainView)
        galleryPhotos = galleryPreview
        present(galleryPreview, animated: true, completion: nil)
        activityIndicatorView.startAnimating()
        //activityIndicatorView.startAnimating()

        DispatchQueue.main.async {
            let size = CGSize(width: 30, height: 30)
            self.startAnimating(size, message: nil, type: NVActivityIndicatorType.ballRotateChase)
            
            let thisPhoto = galleryPreview.accessCurrentPhotoDetail()
            
            //self.avatarPhotos.index(of:thisPhoto)
           if let index =  self.avatarPhotos?.index(where: {$0 === thisPhoto}) {
            self.lastIndex = index
            let currentAvatarFile = self.avatars[index].file
            self.currentAvatarId = self.avatars[index].id
            if currentAvatarFile?.status == .downloading {
                return
            }
            
            if let attachment = currentAvatarFile {
                IGDownloadManager.sharedManager.download(file: attachment, previewType: .originalFile, completion: { (attachment) -> Void in
                    DispatchQueue.main.async {
                        galleryPreview.hiddenDownloadView()
                        self.stopAnimating()
                    }
                }, failure: {
                    
                })
            }

            }

       }
        scheduledTimerWithTimeInterval()
    }
    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to Call the function **Countdown** with the interval of 1 seconds
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.updateCounting), userInfo: nil, repeats: true)
    }
    
    func updateCounting(){
        let nextPhoto = galleryPhotos?.accessCurrentPhotoDetail()
        if let index =  self.avatarPhotos?.index(where: {$0 === nextPhoto}) {
            let currentAvatarFile = self.avatars[index].file
            let nextAvatarId = self.avatars[index].id
            if nextAvatarId != self.currentAvatarId {
                let size = CGSize(width: 30, height: 30)
                self.startAnimating(size, message: nil, type: NVActivityIndicatorType.ballRotateChase)
                if currentAvatarFile?.status == .downloading {
                    return
                }
                
                if let attachment = currentAvatarFile {
                    IGDownloadManager.sharedManager.download(file: attachment, previewType: .originalFile, completion: { (attachment) -> Void in
                        self.galleryPhotos?.hiddenDownloadView()
                        self.stopAnimating()
                    }, failure: {
                        
                    })
                }
                self.currentAvatarId = nextAvatarId
            } else {
                
            }
        }
    }

    


    func setThumbnailForAttachments() {
        if let attachment = self.userAvatar?.file {
          //  self.currentPhoto.isHidden = false
            
        }
    }

    
    func didTapOnTrashButton() {
        timer.invalidate()
        let thisPhoto = galleryPhotos?.accessCurrentPhotoDetail()
        if let index =  self.avatarPhotos?.index(where: {$0 === thisPhoto}) {
            let thisAvatarId = self.avatars[index].id
            IGUserAvatarDeleteRequest.Generator.generate(avatarID: thisAvatarId).success({ (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let userAvatarDeleteResponse as IGPUserAvatarDeleteResponse :
                        IGUserAvatarDeleteRequest.Handler.interpret(response: userAvatarDeleteResponse)
                        self.avatarPhotos?.remove(at: index)
                        self.scheduledTimerWithTimeInterval()
                    default:
                        break
                    }
                }
            }).error ({ (errorCode, waitTime) in
                self.scheduledTimerWithTimeInterval()
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
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 7
        case 1:
            return 1
        case 2:
            return 1
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                self.tableView.isUserInteractionEnabled = false
                performSegue(withIdentifier: "GoToAccountSettingPage", sender: self)
            } else if indexPath.row == 1 {
                self.tableView.isUserInteractionEnabled = false
                performSegue(withIdentifier: "GoToContactListPage", sender: self)
            } else if indexPath.row == 2 {
                self.tableView.isUserInteractionEnabled = false
                performSegue(withIdentifier: "showLookAndFind", sender: self)
            } else if indexPath.row == 3 {
                self.tableView.isUserInteractionEnabled = false
                performSegue(withIdentifier: "GoToPrivacyAndPolicySettingsPage", sender: self)
            } else if indexPath.row == 4 {
                shareContent = "Hey Join iGap and start new connection with friends and family for free, no matter what device they are on!\niGap Limitless Connection\nwww.iGap.net"
                let activityViewController = UIActivityViewController(activityItems: [shareContent as NSString], applicationActivities: nil)
                present(activityViewController, animated: true, completion: {})
            } else if indexPath.row == 5 {
                self.tableView.isUserInteractionEnabled = false
                performSegue(withIdentifier: "GoToAboutSettingPage", sender: self)
            } else if indexPath.row == 6 {
                showLogoutActionSheet()
            } else if indexPath.row == 7 {
                self.tableView.isUserInteractionEnabled = false
                performSegue(withIdentifier: "GoToChatSettingPage", sender: self)
            } else if indexPath.row == 8 {
                self.tableView.isUserInteractionEnabled = false
                performSegue(withIdentifier: "GoToNotificationSettingsPage", sender: self)
            }
                
        } else if indexPath.section == 1 && indexPath.row == 0 {
            self.tableView.isUserInteractionEnabled = false
            performSegue(withIdentifier: "ShowQRScanner", sender: self)
        }
        self.tableView.deselectRow(at: indexPath, animated: false)
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
    
    
    
    func showLogoutActionSheet(){
        let logoutConfirmAlertView = UIAlertController(title: "Are you sure you want to Log out?", message: nil, preferredStyle: .actionSheet)
        let logoutAction = UIAlertAction(title: "Log out", style:.default , handler: {
            (alert: UIAlertAction) -> Void in
            self.dismiss(animated: true, completion: {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.logoutAndShowRegisterViewController()
                IGWebSocketManager.sharedManager.closeConnection()
            })
            
        })
        let cancelAction = UIAlertAction(title: "Cancel", style:.cancel , handler: {
            (alert: UIAlertAction) -> Void in
        })
        logoutConfirmAlertView.addAction(logoutAction)
        logoutConfirmAlertView.addAction(cancelAction)
        let alertActions = logoutConfirmAlertView.actions
        for action in alertActions {
            if action.title == "Log out"{
                let logoutColor = UIColor.red
                action.setValue(logoutColor, forKey: "titleTextColor")
            }
        }
        logoutConfirmAlertView.view.tintColor = UIColor.organizationalColor()
        if let popoverController = logoutConfirmAlertView.popoverPresentationController {
            popoverController.sourceView = self.tableView
            popoverController.sourceRect = CGRect(x: self.tableView.frame.midX-self.tableView.frame.midX/2, y: self.tableView.frame.midX-self.tableView.frame.midX/2, width: self.tableView.frame.midX, height: self.tableView.frame.midY)
            popoverController.permittedArrowDirections = UIPopoverArrowDirection.init(rawValue: 0)
        }
        present(logoutConfirmAlertView, animated: true, completion: nil)
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
            IGDownloadManager.sharedManager.download(file: attachment, previewType: .originalFile, completion: { (attachment) -> Void in
                
            }, failure: {
                
            })
        }
        
    }
    
    func downloadUploadIndicatorDidTapOnCancel(_ indicator: IGDownloadUploadIndicatorView) {
        
    }
}

