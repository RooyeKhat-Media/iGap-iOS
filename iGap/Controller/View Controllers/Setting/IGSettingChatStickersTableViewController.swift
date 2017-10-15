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
//import LGSemiModalNavController

class IGSettingChatStickersTableViewController: UITableViewController {
    
    var collectionView : UICollectionView?{
        didSet{
            collectionView?.register(IGSettingChatStickerModalCollectionViewCell.self, forCellWithReuseIdentifier: "CollectionCell")
            collectionView?.dataSource = self
            collectionView?.delegate = self
        }
    }
    let greenColor = UIColor.organizationalColor()
    let stickerText = ["Lorem","Ipsum","Dolor"]
    let stickerImageView = ["arrow21","boy","face.jpg"]
    let numberOfStickerText = [20,12,15]
    override func viewDidLoad() {
        super.viewDidLoad()
        setupEditBarButton()
    }
   
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stickerText.count
        }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StickerTableViewCell", for: indexPath) as! IGSettingChatStickersTableViewCell
        cell.stickerTitle.text = stickerText[indexPath.row]
        cell.stickerStatusLable.text = "Saved"
        cell.numberOfStickerInPackage.text = "\(numberOfStickerText[indexPath.row])" + "Stickers"
        cell.numberOfStickerInPackage.textColor = UIColor.gray
        cell.stickerStatusLable.textColor = greenColor
        cell.stickerImageView.image = UIImage(named: stickerImageView[indexPath.row])
        return cell
        }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            showStcikers(indexpath: indexPath)
        }
    func setupEditBarButton(){
        let editButton = UIButton()
        editButton.frame = CGRect(x: 8, y: 0, width: 60, height: 60)
        editButton.setTitle("Cancel", for: UIControlState.normal)
        editButton.setTitleColor(greenColor, for: .normal)
        editButton.addTarget(self, action: #selector(IGSettingChatStickersTableViewController.editButtonClicked), for: UIControlEvents.touchUpInside)
        let topLeftbarButtonItem = UIBarButtonItem(customView: editButton)
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = topLeftbarButtonItem
    }
    func editButtonClicked(){ }
    
    func showStcikers(indexpath : IndexPath) {
        let stickersView: UIView = UIView(frame: CGRect(x:2, y:20, width:self.view.frame.size.width - 10,height: 352))
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: 80, height: 80)
        layout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: stickersView.frame, collectionViewLayout: layout)
        collectionView?.backgroundColor = UIColor.clear
        stickersView.addSubview(collectionView!)
        let alertController = UIAlertController(title: "", message: "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n", preferredStyle: UIAlertControllerStyle.actionSheet)
        alertController.view.addSubview(stickersView)
        let normalTitleFont = UIFont.systemFont(ofSize: UIFont.labelFontSize, weight: UIFontWeightSemibold)
        let attrs = NSAttributedString(string: stickerText[indexpath.row], attributes: [NSFontAttributeName : normalTitleFont])
        alertController.setValue(attrs, forKey: "attributedTitle")
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        { (action) in
            
        }
        alertController.addAction(cancelAction)
        let stickerAddOrRemoveAction = UIAlertAction(title: "Add 'Loem' sticker", style: .default){ (action) in
            
        }
        alertController.addAction(stickerAddOrRemoveAction)
        let shareAction = UIAlertAction(title: "Share", style: .default)
        { (action) in
        }
        alertController.addAction(shareAction)
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = self.tableView
            popoverController.containerView?.frame.size.height = 900
            popoverController.sourceRect = CGRect(x:self.view.bounds.midX,y: 500,width:0,height:300)
        }
        self.present(alertController, animated: true)
    }

}

    extension IGSettingChatStickersTableViewController : UICollectionViewDataSource {
        func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 9
            }
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
            }
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! IGSettingChatStickerModalCollectionViewCell
            let imageview:UIImageView=UIImageView(frame: CGRect(x:-5, y:0, width: collectionView.frame.width / 5, height: collectionView.frame.width / 5))
            let image:UIImage = UIImage(named:"IG_Settings_Camera")!
            imageview.image = image
            cell.contentView.addSubview(imageview)
            return cell
        }
    }
    extension IGSettingChatStickersTableViewController : UICollectionViewDelegateFlowLayout {
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            let edgeIneset: UIEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
            return edgeIneset
    }
}
    extension IGSettingChatStickersTableViewController : UICollectionViewDelegate {
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            print("Select")
    }

}
