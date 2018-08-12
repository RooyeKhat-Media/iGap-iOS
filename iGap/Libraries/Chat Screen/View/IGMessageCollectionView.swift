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

protocol IGMessageCollectionViewDataSource : UICollectionViewDataSource {
    func collectionView(_ collectionView: IGMessageCollectionView, messageAt indexpath: IndexPath) -> IGRoomMessage
}

class IGMessageCollectionView: UICollectionView {
    
//    var dataStorage: IGMessageCollectionViewDataSource?
    let layout = IGMessageCollectionViewFlowLayout()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureCollectionView()
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        configureCollectionView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
        configureCollectionView()
    }
    
    func configureCollectionView() {
//        self.translatesAutoresizingMaskIntoConstraints = true
        
        self.backgroundColor = UIColor.clear
        self.keyboardDismissMode = .interactive
        self.alwaysBounceVertical = true
        self.bounces = true
        
//        let bgImage = UIImageView();
//        bgImage.image = UIImage(named: "IG_Chat_Screen_Background");
//        bgImage.contentMode = .scaleToFill
//        self.backgroundView = bgImage
        
        self.setCollectionViewLayout(layout, animated: true)
        self.register(TextCell.nib(), forCellWithReuseIdentifier: TextCell.cellReuseIdentifier())
        self.register(ImageCell.nib(), forCellWithReuseIdentifier: ImageCell.cellReuseIdentifier())
        self.register(VideoCell.nib(), forCellWithReuseIdentifier: VideoCell.cellReuseIdentifier())
        self.register(GifCell.nib(), forCellWithReuseIdentifier: GifCell.cellReuseIdentifier())
        self.register(ContactCell.nib(), forCellWithReuseIdentifier: ContactCell.cellReuseIdentifier())
        self.register(FileCell.nib(), forCellWithReuseIdentifier: FileCell.cellReuseIdentifier())
        self.register(VoiceCell.nib(), forCellWithReuseIdentifier: VoiceCell.cellReuseIdentifier())
        self.register(AudioCell.nib(), forCellWithReuseIdentifier: AudioCell.cellReuseIdentifier())
        self.register(LocationCell.nib(), forCellWithReuseIdentifier: LocationCell.cellReuseIdentifier())
        self.register(IGMessageCollectionViewCell.nib(), forCellWithReuseIdentifier: IGMessageCollectionViewCell.cellReuseIdentifier())
        self.register(IGMessageLogCollectionViewCell.nib(), forCellWithReuseIdentifier: IGMessageLogCollectionViewCell.cellReuseIdentifier())
        self.register(IGMessageLogCollectionViewCell.nib(), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: IGMessageLogCollectionViewCell.cellReuseIdentifier())
        
        
        
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return true
    }
    

    
}
