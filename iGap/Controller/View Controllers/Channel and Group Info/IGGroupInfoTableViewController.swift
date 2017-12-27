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
import RxRealm
import RxSwift
import RxCocoa
import IGProtoBuff
import MGSwipeTableCell
import MBProgressHUD
import INSPhotoGalleryFramework
import NVActivityIndicatorView

class IGGroupInfoTableViewController: UITableViewController , UIGestureRecognizerDelegate , NVActivityIndicatorViewable {

    @IBOutlet weak var groupNameLabelTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var groupDescriptionLabelTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var groupTypeLabelTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var groupTypeCell: UITableViewCell!
    @IBOutlet weak var groupDescriptionCell: UITableViewCell!
    @IBOutlet weak var groupNameCell: UITableViewCell!
    @IBOutlet weak var groupLinkCell: UITableViewCell!
    @IBOutlet weak var groupAllMemberCell: UITableViewCell!
    @IBOutlet weak var groupSharedMediaCell: UITableViewCell!
    @IBOutlet weak var groupNotificationCell: UITableViewCell!
    @IBOutlet weak var groupMemberCanAddMembersCell: UITableViewCell!
    @IBOutlet weak var adminsAndModeratorCell: UITableViewCell!
    @IBOutlet weak var groupAvatarView: IGAvatarView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var groupNameTitleLabel: UILabel!
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var groupDescriptionLabel: UILabel!
    @IBOutlet weak var groupTypeLabel: UILabel!
    @IBOutlet weak var groupLinkLabel: UILabel!
    @IBOutlet weak var memberCountLabel: UILabel!
    @IBOutlet weak var canAddMembersSwitch: UISwitch!
    @IBOutlet weak var leaveGroupLabel: UILabel!
    
    var room : IGRoom?
    private let disposeBag = DisposeBag()
    var hud = MBProgressHUD()
    var myRole : IGGroupMember.IGRole!
    var signMessageIndexPath : IndexPath?
    var imagePicker = UIImagePickerController()
    var selectedGroup: IGGroupRoom?
    var groupRoom : Results<IGRoom>!
    var mode : String? = "Members"
    var notificationToken: NotificationToken?
    var connectionStatus: IGAppManager.ConnectionStatus?
    var avatars: [IGAvatar] = []
    var deleteView: IGTappableView?
    var userAvatar: IGAvatar?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestToGetRoom()
        requestToGetAvatarList()
        myRole = room?.groupRoom?.role
        showGroupInfo()
        imagePicker.delegate = self
        self.tableView.backgroundColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
        tableView.tableFooterView = UIView()
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: "Group Info")
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self

        
        groupAvatarView.avatarImageView?.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.handleTap(recognizer:)))
        groupAvatarView.avatarImageView?.addGestureRecognizer(tap)

        switch myRole! {
        case .admin:
            cameraButton.isHidden = false
            groupTypeCell.accessoryType = .none
            groupTypeLabelTrailingConstraint.constant = 10
            break
        case .owner:
            leaveGroupLabel.text = "Delete group"
            cameraButton.isHidden = false
            break
        case .member:
            if room?.groupRoom?.type == .publicRoom {
                groupAllMemberCell.isHidden = true
                
            } else {
               groupAllMemberCell.isHidden = false
            }
            adminsAndModeratorCell.isHidden = true
            groupLinkCell.isHidden = true
            groupNameCell.accessoryType = .none
            groupNameLabelTrailingConstraint.constant = 10
            groupTypeCell.accessoryType = .none
            groupTypeLabelTrailingConstraint.constant = 10
            cameraButton.isHidden = true
            break
        case .moderator:
            if room?.groupRoom?.type == .publicRoom {
                groupAllMemberCell.isHidden = true
                groupLinkCell.isHidden = true
            } else {
                groupAllMemberCell.isHidden = false
            }
            adminsAndModeratorCell.isHidden = true
            groupNameCell.accessoryType = .none
            groupNameLabelTrailingConstraint.constant = 10
            groupTypeCell.accessoryType = .none
            groupTypeLabelTrailingConstraint.constant = 10
            cameraButton.isHidden = true
            break
        }
        
        let predicate = NSPredicate(format: "id = %lld", (room?.id)!)
        groupRoom =  try! Realm().objects(IGRoom.self).filter(predicate)
        self.notificationToken = groupRoom.addNotificationBlock { (changes: RealmCollectionChange) in
            
            let predicatea = NSPredicate(format: "id = %lld", (self.room?.id)!)
            self.room =  try! Realm().objects(IGRoom.self).filter(predicatea).first!
            
            self.showGroupInfo()
        }
        
        IGAppManager.sharedManager.connectionStatus.asObservable().subscribe(onNext: { (connectionStatus) in
            DispatchQueue.main.async {
                self.updateConnectionStatus(connectionStatus)
                
            }
        }, onError: { (error) in
            
        }, onCompleted: {
            
        }, onDisposed: {
            
        }).addDisposableTo(disposeBag)

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.isUserInteractionEnabled = true
    }
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.isUserInteractionEnabled = true

    }
    @IBAction func didTapOnCameraBtn(_ sender: UIButton) {
    }
    
    @IBAction func didTapOnCameraButton(_ sender: UIButton) {
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
        
        let deleteAction = UIAlertAction(title: "Delete Main Avatar", style: .destructive, handler: {
            (alert: UIAlertAction!) -> Void in
            self.deleteAvatar()
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
        
        if myRole == .owner || myRole == .admin {
            optionMenu.addAction(deleteAction)
        }
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
    
    func deleteAvatar(){
        let avatar = self.avatars[0]
        IGGroupAvatarDeleteRequest.Generator.generate(avatarId: avatar.id, roomId: (room?.id)!).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let groupAvatarDeleteResponse as IGPGroupAvatarDeleteResponse :
                    IGGroupAvatarDeleteRequest.Handler.interpret(response: groupAvatarDeleteResponse)
                    self.avatarPhotos?.remove(at: 0)
                    self.avatars.remove(at: 0)
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 4
        case 1:
            return 3
        case 2 :
            return 1
        case 3 :
            return 1
        default:
            return 0
        }

    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            print(myRole)
            switch indexPath.row {
            case 0:
                if myRole == .owner || myRole == .admin {
                    self.tableView.isUserInteractionEnabled = false
                self.performSegue(withIdentifier: "showGroupNameSetting", sender: self)
                }
             break
            case 1:
                self.tableView.isUserInteractionEnabled = false
                self.performSegue(withIdentifier: "showDescribeGroupSetting", sender: self)
                break
            case 2:
                if myRole == .owner {
                self.tableView.isUserInteractionEnabled = false
                self.performSegue(withIdentifier: "showGroupTypeSetting", sender: self)
                }
            case 3:
                showGroupLinkAlert()
            default:
                break
            }
            
        }
        if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                self.tableView.isUserInteractionEnabled = false
                self.performSegue(withIdentifier: "showGroupMemberSetting", sender: self)
            case 1:
                self.tableView.isUserInteractionEnabled = false
                self.performSegue(withIdentifier: "showGroupAdminsAnadModeratorsSetting", sender: self)
            default:
                break
            }
        }
        if indexPath.section == 2 {
            switch indexPath.row {
            case 0:
                self.performSegue(withIdentifier: "showGroupSharedMediaSetting", sender: self)
            default:
                break
            }
        }
        
        if indexPath.section == 3 {
            switch indexPath.row {
            case 0:
                showDeleteChannelActionSheet()
               // self.performSegue(withIdentifier: "showGroupSharedMediaSetting", sender: self)
            default:
                break
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row == 1 && adminsAndModeratorCell.isHidden == true {
            return 0.0
        }
        if indexPath.section == 1 && indexPath.row == 0 && groupAllMemberCell.isHidden == true {
            return 0.0
        }
        if indexPath.section == 1 && indexPath.row == 2 && groupMemberCanAddMembersCell.isHidden == true {
            return 0.0
        }
//        if indexPath.section == 2 && indexPath.row == 0 && groupSharedMediaCell.isHidden == true {
//            return 0.0
//        }
//        if indexPath.section == 2 && indexPath.row == 1 && groupNotificationCell.isHidden == true {
//            return 0.0
//        }
        if indexPath.section == 0 && indexPath.row == 3 && groupLinkCell.isHidden == true {
            return 0.0
        }
        
        return 44.0
    }
    
    func updateConnectionStatus(_ status: IGAppManager.ConnectionStatus) {
        
        switch status {
        case .connected:
            connectionStatus = .connected
        case .connecting:
            connectionStatus = .connecting
        case .waitingForNetwork:
            connectionStatus = .waitingForNetwork
        }
        
    }
    
    func handleTap(recognizer:UITapGestureRecognizer) {
        if recognizer.state == .ended {
            if let userAvatar = room?.groupRoom?.avatar {
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
        
        if(photos.count==0){
            return
        }
        avatarPhotos = photos
        let currentPhoto = photos[0]
        
//        let galleryPreview = INSPhotosViewController(photos: photos, initialPhoto: currentPhoto, referenceView: nil)
//        present(galleryPreview, animated: true, completion: nil)
        
//        var photos: [INSPhotoViewable] = self.avatars.map { (avatar) -> IGMedia in
//            return IGMedia(avatar: avatar)
//        }
//        avatarPhotos = photos
//        let currentPhoto = photos[0]
//        let deleteViewFrame = CGRect(x:320, y:595, width: 25 , height:25)
//        let trashImageView = UIImageView()
//        trashImageView.image = UIImage(named: "IG_Trash_avatar")
//        trashImageView.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
//        if myRole == .owner || myRole == .admin {
//            deleteView = IGTappableView(frame: deleteViewFrame)
//            deleteView?.addSubview(trashImageView)
//            deleteView?.addAction {
//                self.didTapOnTrashButton()
//            }
//        } else {
//            deleteView = nil
//        }
//
        let downloadIndicatorMainView = UIView()
        let downloadViewFrame = self.view.bounds
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
                
                if UIImage.originalImage(for: currentAvatarFile!) != nil {
                    galleryPreview.hiddenDownloadView()
                    self.stopAnimating()
                    return
                }
                
                if let attachment = currentAvatarFile {
                    IGDownloadManager.sharedManager.download(file: attachment, previewType: .originalFile, completion: {
                        DispatchQueue.main.async {
                            galleryPreview.hiddenDownloadView()
                            self.stopAnimating()
                        }
                    }, failure: {
                        DispatchQueue.main.async {
                            galleryPreview.hiddenDownloadView()
                            self.stopAnimating()
                        }
                    })
                }
                
            }
        }
        scheduledTimerWithTimeInterval()
    }
    
    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to Call the function **Countdown** with the interval of 1 seconds
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateCounting), userInfo: nil, repeats: true)
    }
    
   @objc func updateCounting(){
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
                
                if UIImage.originalImage(for: currentAvatarFile!) != nil {
                    DispatchQueue.main.async {
                        self.galleryPhotos?.hiddenDownloadView()
                        self.stopAnimating()
                    }
                    
                    self.currentAvatarId = nextAvatarId
                    return
                }
                
                if let attachment = currentAvatarFile {
                    IGDownloadManager.sharedManager.download(file: attachment, previewType: .originalFile, completion: {
                        DispatchQueue.main.async {
                            self.galleryPhotos?.hiddenDownloadView()
                            self.stopAnimating()
                        }
                    }, failure: {
                        
                    })
                }
                self.currentAvatarId = nextAvatarId
            } else {
                
            }
        }
    }


    
    func didTapOnTrashButton() {
        timer.invalidate()
        let thisPhoto = galleryPhotos?.accessCurrentPhotoDetail()
        if let index =  self.avatarPhotos?.index(where: {$0 === thisPhoto}) {
            let thisAvatarId = self.avatars[index].id
            IGGroupAvatarDeleteRequest.Generator.generate(avatarId: thisAvatarId, roomId: (room?.id)!).success({ (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let groupAvatarDeleteResponse as IGPGroupAvatarDeleteResponse :
                        IGGroupAvatarDeleteRequest.Handler.interpret(response: groupAvatarDeleteResponse)
                        self.avatarPhotos?.remove(at: index)
                        self.avatars.remove(at: index)
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
    
    
    func requestToGetAvatarList() {
        if let currentRoomID = room?.id {
            IGGroupAvatarGetListRequest.Generator.generate(roomId: currentRoomID).success({ (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let groupAvatarGetListResponse as IGPGroupAvatarGetListResponse:
                        let responseAvatars = IGGroupAvatarGetListRequest.Handler.interpret(response: groupAvatarGetListResponse)
                    self.avatars = responseAvatars
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


    func showGroupInfo() {
        groupNameTitleLabel.text = room?.title
        groupNameLabel.text = room?.title
        groupDescriptionLabel.text = room?.groupRoom?.roomDescription
        if let groupRoom = room {
            groupAvatarView.setRoom(groupRoom)
        }
        if let groupType = room?.groupRoom?.type {
            switch groupType {
            case .privateRoom:
                groupTypeLabel.text = "Private"
            case .publicRoom:
                groupTypeLabel.text = "Public"
                break
            }
        }
        if let memberCount = room?.groupRoom?.participantCount {
            memberCountLabel.text = "\(memberCount)"
        }
        var groupLink: String? = ""
        if room?.groupRoom?.type == .privateRoom {
            groupLink = room?.groupRoom?.privateExtra?.inviteLink
        }
        if room?.groupRoom?.type == .publicRoom {
            if let groupUsername = room?.groupRoom?.publicExtra?.username {
                groupLink = "iGap.net/\(groupUsername)"
            }
        }
        groupLinkLabel.text = groupLink
    }
    
    func showDeleteChannelActionSheet() {
        var title : String!
        var actionTitle: String!
        if myRole == .owner {
            title = "Are you sure you want to Delete this group?"
            actionTitle = "Delete"
        }else{
            title = "Are you sure you want to leave this group?"
            actionTitle = "Leave"
        }
        let deleteConfirmAlertView = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: actionTitle , style:.default , handler: {
            (alert: UIAlertAction) -> Void in
                if self.myRole == .owner {
                    if self.connectionStatus == .connecting || self.connectionStatus == .waitingForNetwork {
                        let alert = UIAlertController(title: "Error", message: "No Network Connection", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        
                    self.deleteGroupRequest()
                    }
                }else{
                    if self.connectionStatus == .connecting || self.connectionStatus == .waitingForNetwork {
                        let alert = UIAlertController(title: "Error", message: "No Network Connection", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                    }else {
                        self.leftGroupRequest(room: self.room!)
                    }
                }
            
        })
        let cancelAction = UIAlertAction(title: "Cancel", style:.cancel , handler: {
            (alert: UIAlertAction) -> Void in
        })
        deleteConfirmAlertView.addAction(deleteAction)
        deleteConfirmAlertView.addAction(cancelAction)
        let alertActions = deleteConfirmAlertView.actions
        for action in alertActions {
            if action.title == actionTitle{
                let logoutColor = UIColor.red
                action.setValue(logoutColor, forKey: "titleTextColor")
            }
        }
        deleteConfirmAlertView.view.tintColor = UIColor.organizationalColor()
        if let popoverController = deleteConfirmAlertView.popoverPresentationController {
            popoverController.sourceView = self.tableView
            popoverController.sourceRect = CGRect(x: self.tableView.frame.midX-self.tableView.frame.midX/2, y: self.tableView.frame.midX-self.tableView.frame.midX/2, width: self.tableView.frame.midX, height: self.tableView.frame.midY)
            popoverController.permittedArrowDirections = UIPopoverArrowDirection.init(rawValue: 0)
        }
        present(deleteConfirmAlertView, animated: true, completion: nil)
        
        
    }

    
    func showGroupLinkAlert() {
        if selectedGroup != nil {
            var channelLink: String? = ""
            if room?.groupRoom?.type == .privateRoom {
                channelLink = room?.groupRoom?.privateExtra?.inviteLink
            }
            if room?.groupRoom?.type == .publicRoom {
                channelLink = room?.groupRoom?.publicExtra?.username
            }
            let alert = UIAlertController(title: "Group Link", message: channelLink, preferredStyle: .alert)
            let copyAction = UIAlertAction(title: "Copy", style: .default, handler: {
                (alert: UIAlertAction) -> Void in
                UIPasteboard.general.string = channelLink
            })
            let shareAction = UIAlertAction(title: "Share", style: .default, handler: nil)
            let changeAction = UIAlertAction(title: "Change", style: .default, handler: {
                (alert: UIAlertAction) -> Void in
                if self.room?.groupRoom?.type == .publicRoom {
                    self.performSegue(withIdentifier: "showGroupTypeSetting", sender: self)
                }
                else if self.room?.groupRoom?.type == .privateRoom {
                    self.requestToRevolLink()
                }
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.view.tintColor = UIColor.organizationalColor()
            alert.addAction(copyAction)
            alert.addAction(shareAction)
            if myRole == .owner {
            alert.addAction(changeAction)
            }
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func requestToRevolLink() {
        IGGroupRevokLinkRequest.Generator.generate(roomID: (room?.id)!).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let groupRevokeLinkRequest as IGPGroupRevokeLinkResponse:
                    IGGroupRevokLinkRequest.Handler.interpret(response: groupRevokeLinkRequest)
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
                    self.hud.hide(animated: true)
                    self.present(alert, animated: true, completion: nil)
                }
            default:
                break
            }
            
        }).send()
    }
    

    func requestToGetRoom() {
        if let groupRoom = room {
            IGClientGetRoomRequest.Generator.generate(roomId: groupRoom.id).success({ (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let clientGetRoomResponse as IGPClientGetRoomResponse:
                        let igpRoom = IGClientGetRoomRequest.Handler.interpret(response: clientGetRoomResponse)
                        
                        
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
                        self.hud.hide(animated: true)
                        self.present(alert, animated: true, completion: nil)
                    }
                default:
                    break
                }
                
            }).send()
        }
    }
    
    func leftGroupRequest(room: IGRoom) {
        self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.hud.mode = .indeterminate
        IGGroupLeftRequest.Generator.generate(room: room).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let groupLeft as IGPGroupLeftResponse:
                    IGGroupLeftRequest.Handler.interpret(response: groupLeft)
                    if self.navigationController is IGNavigationController {
                        _ = self.navigationController?.popToRootViewController(animated: true)
                    }
                default:
                    break
                }
                self.hud.hide(animated: true)
            }
        }).error({ (errorCode , waitTime) in
            DispatchQueue.main.async {
                switch errorCode {
                case .timeout:
                    let alert = UIAlertController(title: "Timeout", message: "Please try again later", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                default:
                    break
                }
                self.hud.hide(animated: true)
            }
        }).send()
    }
    
    func deleteGroupRequest() {
        if let groupRoom = room {
            self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            self.hud.mode = .indeterminate
            IGGroupDeleteRequest.Generator.generate(group: groupRoom).success({ (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let groupDeleteResponse as IGPGroupDeleteResponse:
                        IGGroupDeleteRequest.Handler.interpret(response: groupDeleteResponse)
                        if self.navigationController is IGNavigationController {
                            _ = self.navigationController?.popToRootViewController(animated: true)
                        }

                    default:
                        break
                    }
                    self.hud.hide(animated: true)

                }
            }).error ({ (errorCode, waitTime) in
                DispatchQueue.main.async {
                    self.hud.hide(animated: true)
                    switch errorCode {
                    case .timeout:
                        let alert = UIAlertController(title: "Timeout", message: "Please try again later", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                    default:
                        break
                    }
                }
            }).send()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showGroupNameSetting" {
            let destination = segue.destination as! IGGroupInfoEditNameTableViewController
            destination.room = room
        }
        if  segue.identifier == "showDescribeGroupSetting" {
            let destination = segue.destination as! IGGroupEditDescriptionTableViewController
            destination.room = room
        }
        
        if segue.identifier ==  "showGroupTypeSetting" {
            let destination = segue.destination as! IGGroupInfoEditTypeTableViewController
            destination.room = room
        }
        if segue.identifier == "showGroupMemberSetting" {
            let destination = segue.destination as! IGGroupInfoMemberListTableViewController
            destination.room = room
        }
        if segue.identifier == "showGroupAdminsAnadModeratorsSetting" {
            let destination = segue.destination as! IGGroupInfoAdminsAndModeratorsListTableViewController
            destination.room = room
        }
        if segue.identifier == "showGroupSharedMediaSetting" {
            let destination = segue.destination as! IGGroupSharedMediaListTableViewController
            destination.room = room
        }
        
        
    }

}
extension IGGroupInfoTableViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.groupAvatarView.setImage(pickedImage)
            
            let avatar = IGFile()
            avatar.attachedImage = pickedImage
            let randString = IGGlobal.randomString(length: 32)
            avatar.primaryKeyId = randString
            avatar.name = randString
            
            IGUploadManager.sharedManager.upload(file: avatar, start: {
                
            }, progress: { (progress) in
                
            }, completion: { (uploadTask) in
                if let token = uploadTask.token {
                    IGGroupAvatarAddRequest.Generator.generate(attachment: token , roomID: (self.room?.id)!).success({ (protoResponse) in
                        DispatchQueue.main.async {
                            switch protoResponse {
                            case let avatarAddResponse as IGPGroupAvatarAddResponse:
                                let userAvatar = IGGroupAvatarAddRequest.Handler.interpret(response: avatarAddResponse)
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

extension IGGroupInfoTableViewController: UINavigationControllerDelegate {
    
}

