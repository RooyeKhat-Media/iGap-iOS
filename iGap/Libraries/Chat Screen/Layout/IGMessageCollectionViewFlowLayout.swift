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

class IGMessageCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    let messageContainerSizeCalculator = IGMessageCollectionViewCellSizeCalculator.sharedCalculator
    let messageCellSize = CellSizeCalculator.sharedCalculator
    var _collectionView : IGMessageCollectionView?
    var _insertIndexPaths = [IndexPath]()
    var _deleteIndexPaths = [IndexPath]()
    
    override init() {
        super.init()
        configureFlowLayout()
        self.register(IGHeader.self, forDecorationViewOfKind: "IGHeader")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureFlowLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureFlowLayout() {
        
    }
    
    deinit {
        
    }
    
    
    func size(for message:IGRoomMessage) -> RoomMessageCalculatedSize {
        return messageContainerSizeCalculator.mainBubbleCountainerSize(for: message)
    }
    
    func sizeCell(for message:IGRoomMessage) -> RoomMessageCalculatedSize {
        return messageCellSize.mainBubbleCountainerSize(for: message)
    }
    
//    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
//        super.prepare(forCollectionViewUpdates: updateItems)
//        
//        _insertIndexPaths = [IndexPath]()
//        _deleteIndexPaths = [IndexPath]()
//        
//        for item in updateItems {
//            if item.updateAction == .insert {
//                _insertIndexPaths.append(item.indexPathAfterUpdate!)
//            } else if item.updateAction == .delete {
//                _deleteIndexPaths.append(item.indexPathBeforeUpdate!)
//            }
//        }
//    }
//    
//    override func finalizeCollectionViewUpdates() {
//        super.finalizeCollectionViewUpdates()
//    }
//    
//    
//    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
//        var attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
//        
////        if _insertIndexPaths.contains(itemIndexPath) {
////            if attributes == nil {
////                attributes = self.layoutAttributesForItem(at: itemIndexPath)
////            }
////
////            attributes!.transform3D = CATransform3DMakeTranslation(0.0, -2 * attributes!.frame.size.height - 4.0, 0.0)
//////
//////            if (itemIndexPath.item != 0 || self.collectionView!.contentOffset.y < -self.collectionView!.contentInset.top - CGFloat(FLT_EPSILON)) {
//////                attributes!.alpha = 0.0
//////            } else {
//////                attributes!.alpha = 1.0
//////                attributes!.bounds = CGRect(x: 0, y: 0, width: attributes!.frame.size.width, height: 24.0)
//////            }
//////            
////        }
//        
//        return attributes
//    }
//    
//    
//    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
//        let attributes = super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath)
//        
//        if _deleteIndexPaths.contains(itemIndexPath) {
//            if attributes != nil {
//                attributes!.alpha = 0.0
//            }
//        }
//        
//        return attributes
//    }
//    
//    
//    
//    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
//        super.layoutAttributesForItem(at: indexPath)
//        let attr = UICollectionViewLayoutAttributes(forDecorationViewOfKind: "IGHeader", with: indexPath)
//        attr.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
//        return attr
//    }
//
    
//    override func prepare() {
//        self.scrollDirection = .vertical
//        self.minimumInteritemSpacing = 1
//        self.minimumLineSpacing = 1
//        self.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: self.minimumLineSpacing, right: 0)
//        let collectionViewWidth = self.collectionView?.bounds.size.width ?? 0
//        self.headerReferenceSize = CGSize(width: collectionViewWidth, height: 40)
//        
//        // cell size
//        
//        self.itemSize = CGSize(width: collectionViewWidth, height: 100)
//        
//        // Note: call super last if we set itemSize
//        super.prepare()
//    }
    
//    
//    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
//        let attributes = super.layoutAttributesForElements(in: rect)
//        
//        var attributesNew = Array<UICollectionViewLayoutAttributes>()
//        
//        if attributes != nil {
//            for attr in attributes! {
//                if attr.representedElementCategory == .cell {
//                    attr.alpha = 0.2
//                    
//                    let decorationAttr = self.layoutAttributesForDecorationView(ofKind: "", at: attr.indexPath)
//                    decorationAttr!.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
//                    
//                    attributesNew.append(attr)
//                    attributesNew.append(decorationAttr!)
//                }
//            }
//        }
//        
//
//        
//        return attributesNew
//    }
    
////        if var attrs = super.layoutAttributesForElements(in: rect) {
////            return attrs.append(self.layoutAttributesForDecorationView(ofKind: "IGHeader", at: IndexPath(row: 0, section: 0))!)
////        }
//        
//        let decorationAttribute = self.layoutAttributesForDecorationView(ofKind: "IGHeader", at: IndexPath(row: 0, section: 0))!
////        decorationAttribute.representedElementCategory = .decorationView
//        let cellAttribute       = super.layoutAttributesForItem(at: IndexPath(row: 0, section: 0))!
////        cellAttribute.representedElementCategory = .cell
//        
//        
//        
//        return [decorationAttribute, cellAttribute]
//    }
//    
    override func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attr = UICollectionViewLayoutAttributes(forDecorationViewOfKind: "IGHeader", with: indexPath)
//        attr.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        return attr
    }
    
    
    
    
    
    
    
    
    
}

