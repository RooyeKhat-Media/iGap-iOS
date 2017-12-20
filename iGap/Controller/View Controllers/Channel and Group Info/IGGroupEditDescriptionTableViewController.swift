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

class IGGroupEditDescriptionTableViewController: UITableViewController , UIGestureRecognizerDelegate  {
    
    @IBOutlet weak var groupDescriptionTextView: UITextView!
    
    var room: IGRoom?
    var hud = MBProgressHUD()
    var placeholderLabel : UILabel!
    var myRole : IGGroupMember.IGRole?
    override func viewDidLoad() {
        super.viewDidLoad()
        let navigationItem = self.navigationItem as! IGNavigationItem
        if let groupRoom = room {
            groupDescriptionTextView.text = groupRoom.groupRoom?.roomDescription
        }
        
        navigationItem.navigationController = self.navigationController as! IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        groupDescriptionTextView.delegate = self
        
        myRole = room?.groupRoom?.role
        if myRole == .owner || myRole == .admin {
            groupDescriptionTextView.isUserInteractionEnabled = true
            navigationItem.addNavigationViewItems(rightItemText: "Done", title: "Description")
            navigationItem.rightViewContainer?.addAction {
                self.changeGroupDescription()
            }
            placeholderLabel = UILabel()
            placeholderLabel.text = "Enter some text to describe group..."
            placeholderLabel.font = UIFont.italicSystemFont(ofSize: (groupDescriptionTextView.font?.pointSize)!)
            placeholderLabel.sizeToFit()
            groupDescriptionTextView.addSubview(placeholderLabel)
            placeholderLabel.frame.origin = CGPoint(x: 5, y: (groupDescriptionTextView.font?.pointSize)! / 2)
            placeholderLabel.textColor = UIColor.lightGray
            placeholderLabel.isHidden = !groupDescriptionTextView.text.isEmpty
            groupDescriptionTextView.tintColor = UIColor.organizationalColor()
        } else {
            navigationItem.addNavigationViewItems(rightItemText: nil, title: "Description")
            groupDescriptionTextView.isUserInteractionEnabled = false
            if room?.groupRoom?.roomDescription == "" {
                groupDescriptionTextView.text = "No Description"
                
            }
        }
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
        return 1
    }
    
    func changeGroupDescription() {
        self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.hud.mode = .indeterminate
        
        if let desc = groupDescriptionTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            if room != nil {
                IGGroupEditRequest.Generator.generate(groupName:(room?.title)! , groupDescription: desc , groupRoomId: (room?.id)!).success({ (protoResponse) in
                    DispatchQueue.main.async {
                        switch protoResponse {
                        case let editGroupResponse as IGPGroupEditResponse:
                            let groupEditResponse = IGGroupEditRequest.Handler.interpret(response: editGroupResponse)
                            self.groupDescriptionTextView.text = groupEditResponse.groupDesc
                            self.hud.hide(animated: true)
                            if self.navigationController is IGNavigationController {
                                self.navigationController?.popViewController(animated: true)
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
                            self.hud.hide(animated: true)
                            self.present(alert, animated: true, completion: nil)
                        }
                    default:
                        break
                    }
                    
                }).send()
                
            }
        }
    }
    
}
extension IGGroupEditDescriptionTableViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !groupDescriptionTextView.text.isEmpty
    }
}
