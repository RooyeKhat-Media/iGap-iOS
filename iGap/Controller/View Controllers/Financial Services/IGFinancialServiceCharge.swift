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
import IGProtoBuff
import PecPayment

protocol AlertClouser {
    func onActionClick(title: String)
}

class IGFinancialServiceCharge: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate, MerchantResultObserver, TopupMerchantResultObserver {

    @IBOutlet weak var edtPhoneNubmer: UITextField!
    @IBOutlet weak var txtOperatorTransport: UILabel!
    @IBOutlet weak var btnOperator: UIButton!
    @IBOutlet weak var btnChargeType: UIButton!
    @IBOutlet weak var btnPrice: UIButton!
    @IBOutlet weak var btnBuy: UIButton!
    
    let PHONE_LENGTH = 11
    var latestPhoneNumber = ""
    
    let operatorIrancell = "Irancell"
    let operatorMCI = "MCI"
    let operatorRightel = "Rightel"
    let operatorNotDetect = "Not Detect Operator"
    
    let normalCharge = "Normal"
    let amazingCharge = "Amazing"
    let wimaxCharge = "Wimax"
    let permanently = "Permanently SIM Card"
    
    let P1000: Int64 = 10000
    let P2000: Int64 = 20000
    let P5000: Int64 = 50000
    let P10000: Int64 = 100000
    let P20000: Int64 = 200000
    let rials = "Rials"
    
    var operatorDictionary: [String:IGOperator] =
        ["0910":IGOperator.mci,
         "0911":IGOperator.mci,
         "0912":IGOperator.mci,
         "0913":IGOperator.mci,
         "0914":IGOperator.mci,
         "0915":IGOperator.mci,
         "0916":IGOperator.mci,
         "0917":IGOperator.mci,
         "0918":IGOperator.mci,
         "0919":IGOperator.mci,
         "0990":IGOperator.mci,
         "0991":IGOperator.mci,
         
         "0901":IGOperator.irancell,
         "0902":IGOperator.irancell,
         "0903":IGOperator.irancell,
         "0930":IGOperator.irancell,
         "0933":IGOperator.irancell,
         "0935":IGOperator.irancell,
         "0936":IGOperator.irancell,
         "0937":IGOperator.irancell,
         "0938":IGOperator.irancell,
         "0939":IGOperator.irancell,
         
         "0920":IGOperator.rightel,
         "0921":IGOperator.rightel,
         "0922":IGOperator.rightel]
    
    var operatorType: IGOperator!
    var operatorTypeBackup: IGOperator!
    var operatorChargeType: IGPMplGetTopupToken.IGPType!
    var chargeAmount: Int64!
    var operatorTransport: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        edtPhoneNubmer.delegate = self
        
        initNavigationBar()
        manageButtonsView(buttons: [btnOperator,btnChargeType,btnPrice,btnBuy])
        ButtonViewActivate(button: btnOperator ,isEnable: false)
    }
    
    func initNavigationBar(){
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: "Top Up SIM Card")
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
    }
    
    private func manageButtonsView(buttons: [UIButton]){
        for btn in buttons {
            btn.removeUnderline()
            btn.layer.cornerRadius = 5
            btn.layer.borderWidth = 1
            btn.layer.borderColor = UIColor.iGapColor().cgColor
        }
    }
    
    private func ButtonViewActivate(button: UIButton, isEnable: Bool){
        
        if isEnable {
            button.layer.borderColor = UIColor.iGapColor().cgColor
            button.layer.backgroundColor = UIColor.white.cgColor
        } else {
            button.layer.borderColor = UIColor.gray.cgColor
            button.layer.backgroundColor = UIColor.lightGray.cgColor
        }
    }
    
    private func setOperator(){
        
        if operatorType == nil {
            btnOperator.setTitle(operatorNotDetect, for: UIControlState.normal)
            return
        }
        
        switch operatorType {
        case .irancell:
            btnOperator.setTitle(operatorIrancell, for: UIControlState.normal)
            break
            
        case .mci:
            btnOperator.setTitle(operatorMCI, for: UIControlState.normal)
            break
            
        case .rightel:
            btnOperator.setTitle(operatorRightel, for: UIControlState.normal)
            break
            
        default:
            break
        }
        
        operatorChargeType = nil
        self.btnChargeType.setTitle("Choose Charge Type", for: UIControlState.normal)
    }
    
    private func showAlertView(title: String, message: String?, subtitles: [String], alertClouser: @escaping ((_ title :String) -> Void), hasCancel: Bool = true){
        let option = UIAlertController(title: title, message: message, preferredStyle: IGGlobal.detectAlertStyle())
        
        for subtitle in subtitles {
            let action = UIAlertAction(title: subtitle, style: .default, handler: { (action) in
                alertClouser(action.title!)
            })
            option.addAction(action)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        option.addAction(cancel)
        
        self.present(option, animated: true, completion: {})
    }
    
    private func showErrorAlertView(title: String, message: String?, dismiss: Bool = false){
        let option = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .cancel, handler: { (action) in
            if dismiss {
                self.navigationController?.popViewController(animated: true)
            }
        })
        option.addAction(ok)
        self.present(option, animated: true, completion: {})
    }

    private func registerTopup(token: String){
        let initpayment = InitPayment()
        initpayment.registerTopup(merchant: self)
        initpayment.initTopupPayment(Token: token, MerchantVCArg: self, TSPEnabled: 0)
    }
    
    /*********************************************************/
    /********************* User Actions **********************/
    /*********************************************************/
    
    @IBAction func switchToggle(_ sender: UISwitch) {
        if sender.isOn {
            operatorTransport = true
            txtOperatorTransport.text = "Ported Subscriber Enable"
            txtOperatorTransport.textColor = UIColor.iGapColor()
        } else {
            operatorTransport = false
            txtOperatorTransport.text = "Ported Subscriber Disable"
            txtOperatorTransport.textColor = UIColor.gray
            
            if operatorTypeBackup != nil {
                operatorType = operatorTypeBackup
                setOperator()
            }
        }
        btnOperator.isEnabled = sender.isOn
        ButtonViewActivate(button: btnOperator, isEnable: sender.isOn)
    }
    
    @IBAction func btnChooseOperator(_ sender: UIButton) {
        showAlertView(title: "Choose Operator", message: nil, subtitles: [operatorIrancell,operatorMCI,operatorRightel], alertClouser: { (title) -> Void in
            
            switch title {
            case self.operatorIrancell:
                self.operatorType = IGOperator.irancell
                self.setOperator()
                break
            case self.operatorMCI:
                self.operatorType = IGOperator.mci
                self.setOperator()
                break
            case self.operatorRightel:
                self.operatorType = IGOperator.rightel
                self.setOperator()
                break
            default:
                break
            }
            self.view.endEditing(true)
        })
    }
    
    @IBAction func btnChooseChargeType(_ sender: UIButton) {
        
        var chargeType: [String] = [normalCharge]
        if operatorType == IGOperator.irancell {
            chargeType = [normalCharge,amazingCharge,wimaxCharge,permanently]
        }
        
        showAlertView(title: "Charge Type", message: nil, subtitles: chargeType, alertClouser: { (title) -> Void in
            
            switch title {
            case self.normalCharge:
                if self.operatorType == IGOperator.irancell {
                    self.operatorChargeType = IGPMplGetTopupToken.IGPType.irancellPrepaid
                } else if self.operatorType == IGOperator.mci {
                    self.operatorChargeType = IGPMplGetTopupToken.IGPType.mci
                } else if self.operatorType == IGOperator.rightel {
                    self.operatorChargeType = IGPMplGetTopupToken.IGPType.rightel
                }
                self.btnChargeType.setTitle(self.normalCharge, for: UIControlState.normal)
                break
                
            case self.amazingCharge:
                self.operatorChargeType = IGPMplGetTopupToken.IGPType.irancellWow
                self.btnChargeType.setTitle(self.amazingCharge, for: UIControlState.normal)
                break
                
            case self.wimaxCharge:
                self.operatorChargeType = IGPMplGetTopupToken.IGPType.irancellWimax
                self.btnChargeType.setTitle(self.wimaxCharge, for: UIControlState.normal)
                break
                
            case self.permanently:
                self.operatorChargeType = IGPMplGetTopupToken.IGPType.irancellPostpaid
                self.btnChargeType.setTitle(self.permanently, for: UIControlState.normal)
                break
                
            default:
                break
            }
            self.view.endEditing(true)
        })
    }
    
    @IBAction func btnChoosePrice(_ sender: UIButton) {
        
        let chargePrice = ["\(P1000) \(rials)" , "\(P2000) \(rials)" , "\(P5000) \(rials)", "\(P10000) \(rials)", "\(P20000) \(rials)"]
        
        showAlertView(title: "Charge Price", message: nil, subtitles: chargePrice, alertClouser: { (title) -> Void in
            switch title {
            case "\(self.P1000) \(self.rials)":
                self.chargeAmount = self.P1000
                break
            case "\(self.P2000) \(self.rials)":
                self.chargeAmount = self.P2000
                break
            case "\(self.P5000) \(self.rials)":
                self.chargeAmount = self.P5000
                break
            case "\(self.P10000) \(self.rials)":
                self.chargeAmount = self.P10000
                break
            case "\(self.P20000) \(self.rials)":
                self.chargeAmount = self.P20000
                break
            default:
                break
            }
            self.btnPrice.setTitle(title, for: UIControlState.normal)
            self.view.endEditing(true)
        })
    }
    
    @IBAction func btnBuy(_ sender: UIButton) {
        
        guard let phoneNumber: String! = edtPhoneNubmer.text else {
            return
        }
        
        if (phoneNumber.characters.count) < 11 || !phoneNumber.isNumber ||  (operatorDictionary[(phoneNumber!.substring(offset: 4))] == nil) {
            showErrorAlertView(title: "Error", message: "phone number is wrong!")
            return
        }
        
        if operatorChargeType == nil || chargeAmount == nil {
            showErrorAlertView(title: "Error", message: "Please complete all options!")
            return
        }
        
        IGGlobal.prgShow(self.view)
        IGMplGetTopupToken.Generator.generate(number: Int64(phoneNumber!)!, amount: chargeAmount, type: operatorChargeType).success({ (protoResponse) in
            IGGlobal.prgHide()
            if let getTokenResponse = protoResponse as? IGPMplGetTopupTokenResponse {
                if getTokenResponse.igpStatus == 0 { //success
                    self.registerTopup(token: getTokenResponse.igpToken)
                } else {
                    self.showErrorAlertView(title: "خطا", message: getTokenResponse.igpMessage)
                }
            }
        }).error ({ (errorCode, waitTime) in
            IGGlobal.prgHide()
            switch errorCode {
            case .timeout:
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Timeout", message: "Please try again later!", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                }
            default:
                break
            }
            
        }).send()
    }
    
    
    /*********************************************************/
    /*************** Overrided Payment Mehtods ***************/
    /*********************************************************/
    
    func TopupMerchantUpdate(encData: String, message: String, status: Int) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func TopupMerchantError(errorType: Int) {
        showErrorAlertView(title: "Payment Error", message: "Payment error occurred!", dismiss: true)
    }
    
    
    
    func update(encData: String, message: String, status: Int) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func error(errorType: Int, orderID: Int) {
        self.navigationController?.popViewController(animated: true)
    }
    
    /*********************************************************/
    /******************* Overrided Method ********************/
    /*********************************************************/
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let text = edtPhoneNubmer.text {
            let newLength = text.characters.count + string.characters.count - range.length
            if (newLength == PHONE_LENGTH) {
                operatorTypeBackup = operatorDictionary[text.substring(offset: 4)]
                if !operatorTransport {
                    operatorType = operatorTypeBackup
                }
                setOperator()
                latestPhoneNumber = text
                DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.5){
                    self.view.endEditing(true)
                }
            } else if (newLength > PHONE_LENGTH) {
                edtPhoneNubmer.text = latestPhoneNumber
            } else {
                latestPhoneNumber = text
            }
        }
        return true
    }
}
