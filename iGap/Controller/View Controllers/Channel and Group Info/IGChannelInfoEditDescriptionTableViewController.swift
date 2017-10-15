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
class IGChannelInfoEditDescriptionTableViewController: UITableViewController , UIGestureRecognizerDelegate {

    @IBOutlet weak var channelDescriptionTextView: UITextView!
    var room: IGRoom?
    var hud = MBProgressHUD()
    var placeholderLabel : UILabel!
    var myRole : IGChannelMember.IGRole!
    override func viewDidLoad() {
        super.viewDidLoad()
        channelDescriptionTextView.text = room?.channelRoom?.roomDescription
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.navigationController =  self.navigationController as! IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
                channelDescriptionTextView.delegate = self
                myRole = room?.channelRoom?.role
        if myRole == .owner || myRole == .admin {
            channelDescriptionTextView.isUserInteractionEnabled = true
            navigationItem.addNavigationViewItems(rightItemText: "Done", title: "Description")
            navigationItem.rightViewContainer?.addAction {
                self.changeChannelDescription()
            }
            
            placeholderLabel = UILabel()
            placeholderLabel.text = "Enter some text to describe channel..."
            placeholderLabel.font = UIFont.italicSystemFont(ofSize: (channelDescriptionTextView.font?.pointSize)!)
            placeholderLabel.sizeToFit()
            channelDescriptionTextView.addSubview(placeholderLabel)
            placeholderLabel.frame.origin = CGPoint(x: 5, y: (channelDescriptionTextView.font?.pointSize)! / 2)
            placeholderLabel.textColor = UIColor.lightGray
            placeholderLabel.isHidden = !channelDescriptionTextView.text.isEmpty
            channelDescriptionTextView.tintColor = UIColor.organizationalColor()
        } else {
            navigationItem.addNavigationViewItems(rightItemText: nil, title: "Description")
            channelDescriptionTextView.isUserInteractionEnabled = false
            print(room?.channelRoom?.roomDescription)
            if room?.channelRoom?.roomDescription == "" {
                channelDescriptionTextView.text = "No Description"
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
    func changeChannelDescription() {
        self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.hud.mode = .indeterminate
        if let desc = channelDescriptionTextView.text {
            if room != nil {
                IGChannelEditRequest.Generator.generate(roomId: (room?.id)!, channelName: (room?.title)!, description: desc).success({ (protoResponse) in
                    DispatchQueue.main.async {
                        switch protoResponse {
                        case let editChannelResponse as IGPChannelEditResponse:
                            let channelEditResponse = IGChannelEditRequest.Handler.interpret(response: editChannelResponse)
                            self.channelDescriptionTextView.text = channelEditResponse.description
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
extension IGChannelInfoEditDescriptionTableViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !channelDescriptionTextView.text.isEmpty
    }

}
