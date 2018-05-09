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
import MBProgressHUD

class IGCreateNewChannelTableViewController: UITableViewController {

    @IBOutlet weak var channelAvatarImage: UIImageView!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var channelnameTextField: UITextField!
    var imagePicker = UIImagePickerController()
    let borderName = CALayer()
    let width = CGFloat(0.5)
    var invitedLink : String?
    var igpRoom : IGPRoom!
    let greenColor = UIColor.organizationalColor()
    var hud = MBProgressHUD()
    var defaultImage = UIImage(named: "IG_New_Channel_Generic_Avatar")

    override func viewDidLoad() {
        super.viewDidLoad()
        addBottomBorder()
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(didTapOnChangeImage))
        channelAvatarImage.addGestureRecognizer(tap)
        channelAvatarImage.isUserInteractionEnabled = true
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addModalViewItems(leftItemText: "Cancel", rightItemText: "Next", title: "New Channel")
        navigationItem.leftViewContainer?.addAction {
            self.navigationController?.popToRootViewController(animated: true)
        }
        navigationItem.rightViewContainer?.addAction {
            if self.channelnameTextField.text?.isEmpty == true {
                let alert = UIAlertController(title: "Alert", message: "Please fill in the Channel name field. ", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                alert.view.tintColor = UIColor.organizationalColor()
                self.present(alert, animated: true, completion: nil)

            }else{
                self.createChannel()
            }
            
        }
    }
    
    func addBottomBorder(){
        borderName.borderColor = greenColor.cgColor
        borderName.frame = CGRect(x: 0, y: channelnameTextField.frame.size.height - width, width:  channelnameTextField.frame.size.width, height: channelnameTextField.frame.size.height)
        borderName.borderWidth = width
        channelnameTextField.layer.addSublayer(borderName)
        channelnameTextField.layer.masksToBounds = true
    }
    
    func createChannel(){
        if let roomName = self.channelnameTextField.text {
            if roomName != "" {
                
                self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                self.hud.mode = .indeterminate
                
                let roomDescription = self.descriptionTextField.text
                IGChannelCreateRequest.Generator.generate(name: roomName, description: roomDescription).success({ (protoResponse) in
                    DispatchQueue.main.async {
                        switch protoResponse {
                        case let channelCreateRespone as IGPChannelCreateResponse :
                            IGClientGetRoomRequest.Generator.generate(roomId: channelCreateRespone.igpRoomID).success({ (protoResponse) in
                                DispatchQueue.main.async {
                                    self.invitedLink = IGChannelCreateRequest.Handler.interpret(response: channelCreateRespone)
                                    
                                    switch protoResponse {
                                    case let getRoomProtoResponse as IGPClientGetRoomResponse:
                                        if self.channelAvatarImage.image != self.defaultImage {
                                            let avatar = IGFile()
                                            avatar.attachedImage = self.channelAvatarImage.image
                                            let randString = IGGlobal.randomString(length: 32)
                                            avatar.primaryKeyId = randString
                                            avatar.name = randString
                                            IGUploadManager.sharedManager.upload(file: avatar, start: {
                                                
                                            }, progress: { (progress) in
                                                
                                            }, completion: { (uploadTask) in
                                                if let token = uploadTask.token {
                                                    IGChannelAddAvatarRequest.Generator.generate(attachment: token , roomID: getRoomProtoResponse.igpRoom.igpID).success({ (protoResponse) in
                                                        DispatchQueue.main.async {
                                                            switch protoResponse {
                                                            case let channelAvatarAddResponse as IGPChannelAvatarAddResponse:
                                                                IGChannelAddAvatarRequest.Handler.interpret(response: channelAvatarAddResponse)
                                                                self.hideProgress()
                                                                self.performSegue(withIdentifier: "GotoChooseTypeOfChannelToCreate", sender: self)
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
                                            IGClientGetRoomRequest.Handler.interpret(response: getRoomProtoResponse)
                                            self.igpRoom = getRoomProtoResponse.igpRoom
                                        } else {
                                            IGClientGetRoomRequest.Handler.interpret(response: getRoomProtoResponse)
                                            self.igpRoom = getRoomProtoResponse.igpRoom
                                            self.hideProgress()
                                            self.performSegue(withIdentifier: "GotoChooseTypeOfChannelToCreate", sender: self)
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
    
    func didTapOnChangeImage() {
        choosePhotoActionSheet(sender : channelAvatarImage)
    }
    
    func roundUserImage(_ roundView:UIView){
        roundView.layer.borderWidth = 0
        roundView.layer.masksToBounds = true
        let borderUserImageColor = UIColor.organizationalColor()
        roundView.layer.borderColor = borderUserImageColor.cgColor
        roundView.layer.cornerRadius = roundView.frame.size.height/2
        roundView.clipsToBounds = true
    }


    func choosePhotoActionSheet(sender : UIImageView){
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: IGGlobal.detectAlertStyle())
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
            self.defaultImage = UIImage(named: "IG_New_Channel_Generic_Avatar")
            self.channelAvatarImage.image = self.defaultImage
        })

        optionMenu.addAction(ChoosePhoto)
        optionMenu.addAction(cancelAction)
        self.defaultImage = UIImage(named: "IG_New_Channel_Generic_Avatar")
        if self.channelAvatarImage.image != self.defaultImage {
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


    @IBAction func nextButtonClicked(_ sender: UIBarButtonItem) {
    }
    
    @IBAction func cancelButtonClicked(_ sender: UIBarButtonItem) {
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! IGNewChannelChoosePublicOrPrivateTableViewController
        destinationVC.invitedLink = invitedLink
        destinationVC.igpRoom = igpRoom
    }
}
extension IGCreateNewChannelTableViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            roundUserImage(channelAvatarImage)
            self.channelAvatarImage.image = pickedImage
        }
        imagePicker.dismiss(animated: true, completion: {
        })
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension IGCreateNewChannelTableViewController: UINavigationControllerDelegate {
    
}

