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


protocol IGMessageGeneralCollectionViewCellDelegate {
    func didTapAndHoldOnMessage(cellMessage: IGRoomMessage, cell: IGMessageGeneralCollectionViewCell)
    func didTapOnAttachment(cellMessage: IGRoomMessage, cell: IGMessageGeneralCollectionViewCell, imageView: IGImageView?)
    func didTapOnForwardedAttachment(cellMessage: IGRoomMessage, cell: IGMessageGeneralCollectionViewCell)
    func didTapOnOriginalMessageWhenReply(cellMessage: IGRoomMessage, cell: IGMessageGeneralCollectionViewCell)
    func didTapOnSenderAvatar(cellMessage: IGRoomMessage, cell: IGMessageGeneralCollectionViewCell)
    func didTapOnHashtag(hashtagText: String)
    func didTapOnMention(mentionText: String)
    func didTapOnURl(url: URL)
    func didTapOnRoomLink(link:String)
}


class IGMessageGeneralCollectionViewCell: UICollectionViewCell {
    var cellMessage: IGRoomMessage?
    var attachment: IGFile?
    var forwardedAttachment: IGFile?
    var delegate: IGMessageGeneralCollectionViewCellDelegate?
    
    func setMessage(_ message: IGRoomMessage, isIncommingMessage: Bool, shouldShowAvatar: Bool, messageSizes: RoomMessageCalculatedSize, isPreviousMessageFromSameSender: Bool, isNextMessageFromSameSender: Bool) {}
    
    func setMultipleSelectionMode(_ multipleSelectionMode: Bool) {}
}
