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
import IGProtoBuff
import MBProgressHUD

class IGCreateNewGroupTableViewController: UITableViewController , UIGestureRecognizerDelegate {

    @IBOutlet weak var groupNameCell: UITableViewCell!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var groupAvatarImage: UIImageView!
    @IBOutlet weak var groupNameTextField: UITextField!
    var getRoomResponseID : Int64?
    var imagePicker = UIImagePickerController()
    let borderName = CALayer()
    let width = CGFloat(0.5)
    let greenColor = UIColor.organizationalColor()
    var mode : String?
    var roomId : Int64?
    var selectedUsersToCreateGroup = [IGRegisteredUser]()
    var hud = MBProgressHUD()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addBottomBorder()
        groupNameCell.selectionStyle = UITableViewCellSelectionStyle.none
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(didTapOnChangeImage))
        groupAvatarImage.addGestureRecognizer(tap)
        groupAvatarImage.isUserInteractionEnabled = true
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: "Next", title: "New Group")
        navigationItem.navigationController = self.navigationController as! IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        navigationItem.rightViewContainer?.addAction {
            if self.mode == "Convert Chat To Group" {
                self.requestToConvertChatToGroup()
            } else {
                self.requestToCreateGroup()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        groupNameTextField.becomeFirstResponder()
    }
    func didTapOnChangeImage() {
        choosePhotoActionSheet(sender : groupAvatarImage)
        
    }
    func roundUserImage(_ roundView:UIView){
        roundView.layer.borderWidth = 0
        roundView.layer.masksToBounds = true
        let borderUserImageColor = UIColor.organizationalColor()
        roundView.layer.borderColor = borderUserImageColor.cgColor
        roundView.layer.cornerRadius = roundView.frame.size.height/2
        roundView.clipsToBounds = true
    }

    func addBottomBorder(){
        borderName.borderColor = greenColor.cgColor
        borderName.frame = CGRect(x: 0, y: groupNameTextField.frame.size.height - width, width:groupNameTextField.frame.size.width, height: groupNameTextField.frame.size.height)
        borderName.borderWidth = width
        groupNameTextField.layer.addSublayer(borderName)
        groupNameTextField.layer.masksToBounds = true
    }
    
    
    @IBAction func createButtonClicked(_ sender: UIBarButtonItem) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func choosePhotoActionSheet(sender : UIImageView){
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
        let removeAction = UIAlertAction(title: "Remove Photo", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            let defualtImgae = UIImage(named: "IG_New_Group_Generic_Avatar")
            self.groupAvatarImage.image = defualtImgae
        })

        optionMenu.addAction(ChoosePhoto)
        
        optionMenu.addAction(cancelAction)
        let defualtImgae = UIImage(named: "IG_New_Group_Generic_Avatar")
        if groupAvatarImage.image != defualtImgae {
            optionMenu.addAction(removeAction)
        }
        
        
        let alertActions = optionMenu.actions
        for action in alertActions {
            if action.title == "Remove Photo"{
                let removeColor = UIColor.red
                action.setValue(removeColor, forKey: "titleTextColor")
            }
        }
        optionMenu.view.tintColor = UIColor.organizationalColor()
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) == true {
            optionMenu.addAction(cameraOption)} else {
            print ("I don't have a camera.")
        }
        if let popoverController = optionMenu.popoverPresentationController {
            popoverController.sourceView = sender
        }
        self.present(optionMenu, animated: true, completion: nil)
    }

    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows : Int = 0
        switch section {
        case 0:
            numberOfRows = 1
        case 1:
            numberOfRows = 1
        default:
            break
        }
        return numberOfRows
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var headerText : String = ""
        if section == 0 {
            headerText = ""
            
        }
        if section == 1{
            headerText = "   "
        }
        return headerText
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var headerHieght : CGFloat = 0
        if section == 0 {
            headerHieght = CGFloat.leastNonzeroMagnitude
        }
        if section == 1 {
            headerHieght = 0
        }
        return headerHieght
    }
    
    func requestToCreateGroup() {
        if let roomName = self.groupNameTextField.text {
            if roomName != "" {
                
                self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                self.hud.mode = .indeterminate
                
                let roomDescription = self.descriptionTextField.text
                IGGroupCreateRequest.Generator.generate(name: roomName, description: roomDescription).success({ (protoResponse) in
                    DispatchQueue.main.async {
                        
                        switch protoResponse {
                        case let groupCreateRespone as IGPGroupCreateResponse:
                            IGClientGetRoomRequest.Generator.generate(roomId: groupCreateRespone.igpRoomID).success({ (protoResponse) in
                                DispatchQueue.main.async {
                                    switch protoResponse {
                                    case let getRoomProtoResponse as IGPClientGetRoomResponse:
                                        
                                        IGClientGetRoomRequest.Handler.interpret(response: getRoomProtoResponse)
                                        
                                        for member in self.selectedUsersToCreateGroup {
                                            let groupRoom = IGRoom(igpRoom:getRoomProtoResponse.igpRoom)
                                            IGGroupAddMemberRequest.Generator.generate(userID: member.id , group: groupRoom ).success({ (protoResponse) in
                                                DispatchQueue.main.async {
                                                    switch protoResponse {
                                                    case let groupAddMemberResponse as IGPGroupAddMemberResponse :
                                                        IGGroupAddMemberRequest.Handler.interpret(response: groupAddMemberResponse)
                                                    default:
                                                        break
                                                    }
                                                }
                                            }).error({ (errorCode, waitTime) in
                                                
                                            }).send()
                                        }
                                        
                                        if self.groupAvatarImage.image != nil {
                                            let avatar = IGFile()
                                            avatar.attachedImage = self.groupAvatarImage.image
                                            let randString = IGGlobal.randomString(length: 32)
                                            avatar.primaryKeyId = randString
                                            avatar.name = randString
                                            
                                            IGUploadManager.sharedManager.upload(file: avatar, start: {
                                            }, progress: { (progress) in
                                                
                                            }, completion: { (uploadTask) in
                                                if let token = uploadTask.token {
                                                    IGGroupAvatarAddRequest.Generator.generate(attachment: token , roomID: getRoomProtoResponse.igpRoom.igpID).success({ (protoResponse) in
                                                        DispatchQueue.main.async {
                                                            switch protoResponse {
                                                            case let groupAvatarAddResponse as IGPGroupAvatarAddResponse:
                                                                IGGroupAvatarAddRequest.Handler.interpret(response: groupAvatarAddResponse)
                                                                self.hideProgress()
                                                                self.dismiss(animated: true, completion: {
                                                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: kIGNotificationNameDidCreateARoom),
                                                                                                    object: nil,
                                                                                                    userInfo: ["room": getRoomProtoResponse.igpRoom.igpID])
                                                                })
                                                                
                                                            default:
                                                                break
                                                            }
                                                        }
                                                    }).error({ (error, waitTime) in
                                                        self.hideProgress()
                                                    }).send()
                                                }
                                            }, failure: {
                                                self.hideProgress()
                                            })
                                        } else {
                                            self.hideProgress()
                                            self.dismiss(animated: true, completion: {
                                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kIGNotificationNameDidCreateARoom),
                                                                                object: nil,
                                                                                userInfo: ["room": getRoomProtoResponse.igpRoom.igpID])
                                            })
                                        }

                                    default:
                                        break
                                    }
                                }
                            }).error({ (errorCode, waitTime) in
                                self.hideProgress()
                            }).send()
                            break
                        default:
                            break
                        }
                    }
                }).error({ (errorCode, waitTime) in
                    self.hideProgress()
                }).send()
            }
        }
    }
    
    func hideProgress(){
        DispatchQueue.main.async {
            self.hud.hide(animated: true)
        }
    }
    
    func requestToConvertChatToGroup() {
        if let roomName = self.groupNameTextField.text {
            if roomName != "" {
                let roomDescription = self.descriptionTextField.text
                IGChatConvertToGroupRequest.Generator.generate(roomId: roomId!, name: roomName, description: roomDescription!).success({ (protoResponse) in
                    DispatchQueue.main.async {
                        switch protoResponse {
                        case let chatConvertToGroupResponse as IGPChatConvertToGroupResponse:
                            let convertChatToGroupResponse =  IGChatConvertToGroupRequest.Handler.interpret(response: chatConvertToGroupResponse)
                             let newRoomId = convertChatToGroupResponse.roomId
                            print(self.roomId)
                            print(newRoomId)
                            if self.navigationController is IGNavigationController {
                                //TODO: Whta the heck is these two l    ines?
                                self.navigationController?.popViewController(animated: true)
                                self.navigationController?.popToRootViewController(animated: true)
                            }

//                             self.dismiss(animated: true, completion: {
//                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kIGNotificationNameDidCreateARoom),
//                                                                object: nil,
//                                                                userInfo: ["room": newRoomId])
//                             })
                        default:
                            break
                        }
                    }
                }).error({ (errorCode, waitTime) in
                    
                }).send()
            }
        }
    }

}
extension IGCreateNewGroupTableViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            roundUserImage(groupAvatarImage)
            self.groupAvatarImage.image = pickedImage
        }
        imagePicker.dismiss(animated: true, completion: {
        })
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension IGCreateNewGroupTableViewController: UINavigationControllerDelegate {
    
}
