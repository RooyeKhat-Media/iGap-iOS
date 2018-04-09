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
import MapKit
import CoreLocation


class MKHipsterTileOverlay : MKTileOverlay {
    
    let cache = NSCache<AnyObject, AnyObject>()
    let operationQueue = OperationQueue()
    
    override func url(forTilePath path: MKTileOverlayPath) -> URL {
        return NSURL(string: String(format: "https://tile.openstreetmap.org/%d/%d/%d.png", path.z, path.x, path.y))! as URL
    }
    
    override func loadTile(at path: MKTileOverlayPath, result: @escaping (Data?, Error?) -> Void) {
        let url = self.url(forTilePath: path)
        if let cachedData = cache.object(forKey: url as AnyObject) as? NSData {
            result(cachedData as Data, nil)
        } else {
            let request = NSURLRequest(url: url)
            NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: operationQueue) {
                [weak self]
                response, data, error in
                if let data = data {
                    self?.cache.setObject(data as AnyObject, forKey: url as AnyObject)
                }
                result(data, error)
            }
        }
    }
}
