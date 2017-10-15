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
import CameraViewController
import IGProtoBuff
import SwiftProtobuf

class IGRegistrationStepProfileInfoViewController: UITableViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var textFiledEditingIndicatorView: UIView!
    
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nicknameTextField.delegate = self
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(didTapOnChangeImage))
        profileImageView.addGestureRecognizer(tap)
        profileImageView.isUserInteractionEnabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        let navItem = self.navigationItem as! IGNavigationItem
        navItem.addModalViewItems(leftItemText: nil, rightItemText: "Done", title: "Your Profile")
        navItem.rightViewContainer?.addAction {
            self.didTapOnDone()
        }
        imagePicker.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        self.nicknameTextField.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    func keyboardWillShow(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.tableView.contentInset = UIEdgeInsetsMake(0, 0, keyboardFrame.size.height + 10, 0)
        })
    }

    
    func didTapOnOutside() {
        nicknameTextField.resignFirstResponder()
    }
    
    func didTapOnDone() {
        if let nickname = nicknameTextField.text {
            IGUserProfileSetNicknameRequest.Generator.generate(nickname: nickname).success({ (responseProto) in
                DispatchQueue.main.async {
                    switch responseProto {
                    case let setNicknameReponse as IGPUserProfileSetNicknameResponse:
                        IGAppManager.sharedManager.save(nickname: setNicknameReponse.igpNickname)
                        
                        IGUserInfoRequest.Generator.generate(userID: IGAppManager.sharedManager.userID()!).success({ (protoResponse) in
                            DispatchQueue.main.async {
                                switch protoResponse {
                                case let userInfoResponse as IGPUserInfoResponse:
                                    let igpUser = userInfoResponse.igpUser
                                    IGFactory.shared.saveRegistredUsers([igpUser])
                                    break
                                default:
                                    break
                                }
//                                self.hud.hide(animated: true)
                                IGAppManager.sharedManager.setUserLoginSuccessful()
                                self.dismiss(animated: true, completion: nil)
                            
                            }
                        }).error({ (errorCode, waitTime) in
                            DispatchQueue.main.async {
//                                self.hud.hide(animated: true)
                                let alertVC = UIAlertController(title: "Error", message: "There was an error logging you in. Try again please.", preferredStyle: .alert)
                                let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                                alertVC.addAction(ok)
                                self.present(alertVC, animated: true, completion: nil)
                            }
                        }).send()
                        
                        
                    default:
                        break
                    }    
                }
            }).error({ (errorCode, waitTime) in
                DispatchQueue.main.async {
//                    self.hud.hide(animated: true)
                    let alertVC = UIAlertController(title: "Error", message: "There was an error setting your nickname. Try again please.", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertVC.addAction(ok)
                    self.present(alertVC, animated: true, completion: nil)
                }
            }).send()
        }
    }
    
    func didTapOnChangeImage() {
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
                    self.imagePicker.popoverPresentationController?.sourceView = (self.profileImageView)
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
                self.imagePicker.popoverPresentationController?.sourceView = (self.profileImageView)
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
            popoverController.sourceView = self.profileImageView
        }
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    }

extension IGRegistrationStepProfileInfoViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.profileImageView.image = pickedImage
            self.profileImageView.layer.cornerRadius = self.profileImageView.frame.height / 2.0
            self.profileImageView.layer.masksToBounds = true
            
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

extension IGRegistrationStepProfileInfoViewController: UINavigationControllerDelegate {
    
}

extension IGRegistrationStepProfileInfoViewController: UITextFieldDelegate {
    
}





