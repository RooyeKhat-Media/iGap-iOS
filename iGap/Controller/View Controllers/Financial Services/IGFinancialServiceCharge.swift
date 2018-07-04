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

protocol AlertClouser {
    func onActionClick(title: String)
}

class IGFinancialServiceCharge: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate {

    @IBOutlet weak var edtPhoneNubmer: UITextField!
    @IBOutlet weak var txtOperatorTransport: UILabel!
    @IBOutlet weak var btnOperator: UIButton!
    @IBOutlet weak var btnChargeType: UIButton!
    @IBOutlet weak var btnPrice: UIButton!
    @IBOutlet weak var btnBuy: UIButton!
    
    let operatorIrancell = "Irancell"
    let operatorHamraheAval = "Hamrahe Aval"
    let operatorRightel = "Rightel"
    
    let normalCharge = "Normal"
    let amazingCharge = "Amazing"
    let wimaxCharge = "Wimax"
    let permanently = "Charge the SIM Card Permanently"
    
    let P1000 = "10.000 Rials"
    let P2000 = "20.000 Rials"
    let P5000 = "50.000 Rials"
    let P10000 = "100.000 Rials"
    let P20000 = "200.000 Rials"
    
    var operatorType: String!
    var chargeType: String!
    var chargePrice: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initNavigationBar()
        manageButtonsView(buttons: [btnOperator,btnChargeType,btnPrice,btnBuy])
        ButtonViewActivate(button: btnOperator ,isEnable: false)
    }
    
    func initNavigationBar(){
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: "Charge Service")
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
    }
    
    private func manageButtonsView(buttons: [UIButton]){
        for btn in buttons {
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
    
    private func showAlertView(title: String, message: String, subtitles: [String], alertClouser: @escaping ((_ title :String) -> Void), hasCancel: Bool = true){
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
    
    /*********************************************************/
    /********************* User Actions **********************/
    /*********************************************************/
    
    @IBAction func switchToggle(_ sender: UISwitch) {
        if sender.isOn {
            txtOperatorTransport.text = "Operator Transport Enable"
            txtOperatorTransport.textColor = UIColor.iGapColor()
        } else {
            txtOperatorTransport.text = "Operator Transport Disable"
            txtOperatorTransport.textColor = UIColor.gray
        }
        btnOperator.isEnabled = sender.isOn
        ButtonViewActivate(button: btnOperator, isEnable: sender.isOn)
    }
    
    @IBAction func btnChooseOperator(_ sender: UIButton) {
        showAlertView(title: "Choose Operator", message: "", subtitles: [operatorIrancell,operatorRightel,operatorHamraheAval], alertClouser: { (title) -> Void in
            
            switch title {
            case self.operatorIrancell:
                break
            case self.operatorRightel:
                break
            case self.operatorHamraheAval:
                break
            default:
                break
            }
        })
    }
    
    @IBAction func btnChooseChargeType(_ sender: UIButton) {
        //showAlertView(title: "Charge Type", message: "", subtitles: [], alertClouser: <#T##((String) -> Void)##((String) -> Void)##(String) -> Void#>)
    }
    
    @IBAction func btnChoosePrice(_ sender: UIButton) {
        
    }
    
    @IBAction func btnBuy(_ sender: UIButton) {
        
    }
    
    /*********************************************************/
    /******************* Overrided Method ********************/
    /*********************************************************/
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
}
