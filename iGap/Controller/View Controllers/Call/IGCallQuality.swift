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
import Cosmos
import IGProtoBuff
import SnapKit

class IGCallQuality: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var txtiGapCallQuality: UILabel!
    @IBOutlet weak var userActionView: UIView!
    @IBOutlet weak var edtReason: UITextField!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    var ratingView: CosmosView!
    
    var rateId: Int64!
    
    @IBAction func btnSubmit(_ sender: UIButton) {
        sendRateRequest()
    }
    
    @IBAction func btnCancel(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func edtTextChangeListener(_ sender: UITextField) {
        if (sender.text?.isEmpty)! {
            btnSubmit.isEnabled = false
        } else {
            btnSubmit.isEnabled = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnSubmit.removeUnderline()
        btnCancel.removeUnderline()
        
        edtReason.delegate = self
        
        edtReason.isHidden = true
        userActionView.layer.cornerRadius = 15
        makeRatingView()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    private func makeRatingView(){
        ratingView = CosmosView()
        ratingView.rating = 3
        
        ratingView.settings.fillMode = .full
        ratingView.settings.starSize = 40
        ratingView.settings.starMargin = 5
        ratingView.settings.filledColor = UIColor.callRatingView()
        ratingView.settings.filledBorderColor = UIColor.callRatingView()
        ratingView.settings.emptyBorderColor = UIColor.darkGray
        
        ratingView.didFinishTouchingCosmos = { rating in
            if rating <= 2.0 {
                self.edtReason.isHidden = false
                
                if self.edtReason.text != nil && !(self.edtReason.text?.isEmpty)! {
                    self.btnSubmit.isEnabled = true
                } else {
                    self.btnSubmit.isEnabled = false
                }
            } else {
                self.edtReason.isHidden = true
                self.btnSubmit.isEnabled = true
            }
        }
        ratingView.didTouchCosmos = { rating in }
        
        mainView.addSubview(ratingView)
        ratingView.snp.makeConstraints { (make) in
            make.top.equalTo(txtiGapCallQuality.snp.bottom).offset(15)
            make.centerX.equalTo(txtiGapCallQuality.snp.centerX)
        }
    }
    
    private func sendRateRequest(){
        
        var reason = ""
        if edtReason.text != nil && !(edtReason.text?.isEmpty)! {
            reason = edtReason.text!
        }
        
        IGSignalingRateRequest.Generator.generate(id:rateId, rate:Int32(ratingView.rating), reason:reason).success({ (protoResponse) in
            DispatchQueue.main.async {
                if let rateReponse = protoResponse as? IGPSignalingRateResponse { //IGSignalingRateRequest.Handler.interpret(response: rateReponse)
                    let alert = UIAlertController(title: "Success", message: "Your comment has been successfully submitted", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        self.dismiss(animated: true, completion: nil)
                    })
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }).error ({ (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Timeout", message: "Please try again later", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                }
            default:
                break
            }
            
        }).send()
    }
}








