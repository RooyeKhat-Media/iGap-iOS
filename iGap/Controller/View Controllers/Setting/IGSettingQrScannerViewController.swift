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
import SnapKit
import MBProgressHUD
import SwiftProtobuf
import IGProtoBuff

class IGSettingQrScannerViewController: UIViewController , UIGestureRecognizerDelegate{
    
    var previewView: UIView!
    var scanner: MTBBarcodeScanner?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        previewView = UIView(frame: CGRect.zero)
        self.view.addSubview(previewView)
        previewView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.height.equalTo(previewView.snp.width)
            make.left.equalTo(self.view.snp.left).offset(16)
            make.right.equalTo(self.view.snp.right).offset(-16)
        }
        scanner = MTBBarcodeScanner(previewView: previewView)
        
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: "QR Scanner")
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        MTBBarcodeScanner.requestCameraPermission(success: { success in
            if success {
                do {
                    try self.scanner?.startScanning(resultBlock: { codes in
                        if let codes = codes {
                            for code in codes {
                                if let stringValue = code.stringValue {
                                    self.resolveScannedQrCode(stringValue)
                                    self.scanner?.stopScanning()
                                    return
                                }
                            }
                        }
                    })
                } catch {
                    NSLog("Unable to start scanning")
                }
            } else {
                // no access to camera
            }
        })
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.scanner?.stopScanning()
        
        super.viewWillDisappear(animated)
    }
    
    
    
    func resolveScannedQrCode(_ code: String) {
        print("Found code: \(code)")
        
        if code.contains("igap://") {
            
        } else {
            //try signing in other device
            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud.mode = .indeterminate
            IGUserVerifyNewDeviceRequest.Generator.generate(token: code).success({ (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let userVerifyNewDeviceProtoResponse as IGPUserVerifyNewDeviceResponse:
                        let newDeviceResponse = IGUserVerifyNewDeviceRequest.Handler.interpret(response: userVerifyNewDeviceProtoResponse)
                        let alertTitle = "New Device Login"
                        let alertMessage = "App Name: \(newDeviceResponse.appName)\nBuild Version: \(newDeviceResponse.buildVersion)\nApp Version: \(newDeviceResponse.appVersion)\nPlatform: \(newDeviceResponse.platform)\nPlatform Version: \(newDeviceResponse.platformVersion)\nDevice: \(newDeviceResponse.device)\nDevice Name: \(newDeviceResponse.devicename)"
                        self.showAlert(title: alertTitle, message: alertMessage, action: {
                            self.dismiss(animated: true, completion: nil)
                        }, completion: nil)
                    default:
                        break
                    }
                }
            }).error({ (error, waitTime) in
                
            }).send()
        }
    }
    
    
}
