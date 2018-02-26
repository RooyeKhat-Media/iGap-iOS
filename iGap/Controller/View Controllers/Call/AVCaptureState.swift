/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the RooyeKhat Media Company - www.RooyeKhat.co
 * All rights reserved.
 */

import Foundation
import AVFoundation

class AVCaptureState {
    static var isVideoDisabled: Bool {
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        return status == .restricted || status == .denied
    }
    
    static var isAudioDisabled: Bool {
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeAudio)
        return status == .restricted || status == .denied
    }
}

