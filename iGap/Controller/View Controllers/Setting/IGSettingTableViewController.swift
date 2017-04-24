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

class IGSettingTableViewController: UITableViewController {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userAvatarView: IGAvatarView!
    @IBOutlet weak var cameraButton: UIButton!

    var imagePicker = UIImagePickerController()
    let borderName = CALayer()
    let width = CGFloat(0.5)
    var shareContent = NSString()

    override func viewDidLoad() {
        super.viewDidLoad()
        let currentUserId = IGAppManager.sharedManager.userID()
        let realm = try! Realm()
        let predicate = NSPredicate(format: "id = %lld", currentUserId!)
        if let userInDb = realm.objects(IGRegisteredUser.self).filter(predicate).first {
            userAvatarView.setUser(userInDb)
            usernameLabel.text = userInDb.displayName
          	//let tap = UITapGestureRecognizer.init(target: self, action: ((self.showAvatar(avatar:userInDb.avatar!))))
            //userAvatarView.addGestureRecognizer(tap)
            userAvatarView.isUserInteractionEnabled = true

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
    
     func showAvatar(avatar: IGAvatar) {
        let photos = [IGMedia(avatar: avatar)]
        let currentPhoto = photos[0]
        let galleryPreview = INSPhotosViewController(photos: photos, initialPhoto: currentPhoto, referenceView: nil)
        present(galleryPreview, animated: true, completion: nil)
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
            performSegue(withIdentifier: "GoToAccountSettingPage", sender: self)
        }
        if indexPath.section == 1 && indexPath.row == 0 {
            performSegue(withIdentifier: "GoToContactListPage", sender: self)
        }
        if indexPath.section == 1 && indexPath.row == 2 {
            performSegue(withIdentifier: "GoToChatSettingPage", sender: self)
        }
        if indexPath.section == 1 && indexPath.row == 3 {
            performSegue(withIdentifier: "GoToNotificationSettingsPage", sender: self)
        }
        if indexPath.section == 1 && indexPath.row == 1 {
            performSegue(withIdentifier: "GoToPrivacyAndPolicySettingsPage", sender: self)
        }
        if indexPath.section == 2 && indexPath.row == 0 {
            shareContent = "Hey Join iGap and start new connection with friends and family for free, no matter what device they are on!\niGap Limitless Connection\nwww.iGap.net"
            let activityViewController = UIActivityViewController(activityItems: [shareContent as NSString], applicationActivities: nil)
            
            present(activityViewController, animated: true, completion: {})
        }
        if indexPath.section == 2 && indexPath.row == 1 {
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
