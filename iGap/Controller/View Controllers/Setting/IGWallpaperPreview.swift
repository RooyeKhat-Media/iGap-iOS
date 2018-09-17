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
import RxSwift
import RealmSwift

class IGWallpaperPreview: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var imgWallpaper: UIImageView!
    @IBOutlet weak var btnSet: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var downloadIndicator: IGDownloadUploadIndicatorView!

    let disposeBag = DisposeBag()
    var wallpaperFile : IGFile?
    var wallpaperLocal: NSData?
    var colorHex: String?
    var allowSetWallpaper: Bool = false
    
    static var chatWallpaper: NSData?
    static var chatSolidColor: String?
    
    @IBAction func btnSet(_ sender: UIButton) {
        if !allowSetWallpaper {
            return
        }
        
        if colorHex != nil {
            IGFactory.shared.setWallpaperSolidColor(solidColor: colorHex!)
            IGFactory.shared.setWallpaperFile(wallpaper: nil)
            IGWallpaperPreview.chatSolidColor = colorHex!
            IGWallpaperPreview.chatWallpaper = nil
        } else {
            var imageData : NSData!
            if wallpaperLocal != nil {
                imageData = wallpaperLocal
            } else {
                imageData = try? NSData(contentsOf: (wallpaperFile?.path())!)
            }
            IGFactory.shared.setWallpaperFile(wallpaper: imageData)
            IGFactory.shared.setWallpaperSolidColor(solidColor: nil)
            IGWallpaperPreview.chatWallpaper = imageData
            IGWallpaperPreview.chatSolidColor = nil
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnCancel(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initNavigationBar()
        customIndicatorView()
        
        btnSet.removeUnderline()
        btnCancel.removeUnderline()
        
        if wallpaperLocal != nil {
            imgWallpaper.image = UIImage(data: wallpaperLocal! as Data)
            allowSetWallpaper = true
            self.downloadIndicator.setState(.ready)
            return
        }
        
        if colorHex != nil {
            imgWallpaper.backgroundColor = UIColor.hexStringToUIColor(hex: colorHex!)
            allowSetWallpaper = true
            self.downloadIndicator.setState(.ready)
            return
        }
        
        imgWallpaper.setThumbnail(for: wallpaperFile!)
        
        if !IGGlobal.isFileExist(path: wallpaperFile?.path()){
            
            /*** don't need to use listener for set download percentage, because wallpapaers will be downloaded in one chunck
             
            if let attachmentVariableInCache = IGAttachmentManager.sharedManager.getRxVariable(attachmentPrimaryKeyId: wallpaperFile.primaryKeyId!) {
                self.wallpaperFile = attachmentVariableInCache.value
            } else {
                self.wallpaperFile = wallpaperFile.detach()
                IGAttachmentManager.sharedManager.add(attachment: wallpaperFile)
                wallpaperFile = IGAttachmentManager.sharedManager.getRxVariable(attachmentPrimaryKeyId: wallpaperFile.primaryKeyId!)!.value
            }
            
            if let variableInCache = IGAttachmentManager.sharedManager.getRxVariable(attachmentPrimaryKeyId: wallpaperFile.primaryKeyId!) {
                variableInCache.asObservable().subscribe({ (event) in
                    DispatchQueue.main.async {
                        self.downloadIndicator.setPercentage(self.wallpaperFile.downloadUploadPercent)
                    }
                }).disposed(by: disposeBag)
            }
            ***/

            self.downloadIndicator.setPercentage(0.0)
            self.downloadIndicator.setFileType(.media)
            self.downloadIndicator.clipsToBounds = true
            self.downloadIndicator.shouldShowSize = false
            self.downloadIndicator.setState(.downloading)
            
            IGDownloadManager.sharedManager.download(file: wallpaperFile!, previewType: .originalFile, completion: { (attachment) -> Void in
                self.allowSetWallpaper = true
                DispatchQueue.main.async {
                    self.downloadIndicator.setPercentage(1.0)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // use delay for show percent to user
                    self.imgWallpaper.setThumbnail(for: self.wallpaperFile!)
                }
            }, failure: {
                
            })
        } else {
            allowSetWallpaper = true
            self.downloadIndicator.setState(.ready)
        }
    }
    
    private func initNavigationBar(){
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: "Wallpaper Preview", width: 250)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
    }
    
    private func customIndicatorView(){
        downloadIndicator.layer.cornerRadius = 40
        downloadIndicator.backgroundView?.backgroundColor = UIColor.black.withAlphaComponent(0.6)
    }
    
}
