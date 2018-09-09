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
import AKMaskField
import IGProtoBuff

class IGSettingAddContactViewController: UIViewController, UIGestureRecognizerDelegate, IGRegistrationStepSelectCountryTableViewControllerDelegate {

    @IBOutlet weak var edtFirstName: UITextField!
    @IBOutlet weak var edtLastName: UITextField!
    @IBOutlet weak var txtCountryCode: UILabel!
    @IBOutlet weak var edtPhoneNumber: AKMaskField!
    @IBOutlet weak var btnChooseCountry: UIButton!
    static var reloadAfterAddContact: Bool = false
    
    @IBAction func btnChooseCountry(_ sender: UIButton) {
        let chooseCountry = IGRegistrationStepSelectCountryTableViewController.instantiateFromAppStroryboard(appStoryboard: .Register)
        chooseCountry.popView = true
        chooseCountry.delegate = self
        self.navigationController!.pushViewController(chooseCountry, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeView()

        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: "Done", title: "Add Contact")
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        navigationItem.rightViewContainer?.addAction {
            self.addContact()
        }
    }
    
    private func makeView(){
        btnChooseCountry.layer.cornerRadius = 5
        btnChooseCountry.layer.borderWidth = 1
        btnChooseCountry.layer.borderColor = UIColor.iGapColor().cgColor
        
        txtCountryCode.layer.cornerRadius = 5
        txtCountryCode.layer.borderWidth = 1
        txtCountryCode.layer.borderColor = UIColor.iGapColor().cgColor
    }
    
    private func addContact(){
        
        if edtPhoneNumber != nil && !(edtPhoneNumber.text?.isEmpty)! && edtFirstName != nil && !(edtFirstName.text?.isEmpty)!  {
            // continue
        } else {
            return
        }
        
        var lastName: String = ""
        if edtLastName != nil && !(edtLastName.text?.isEmpty)! {
            lastName = edtLastName.text!
        }
        
        let contact = IGContact(phoneNumber: "\(txtCountryCode.text!)\(edtPhoneNumber.text!)", firstName: edtFirstName.text, lastName: lastName)
        IGUserContactsImportRequest.Generator.generate(contacts: [contact], force: true).success({ (protoResponse) in
            DispatchQueue.main.async {
                if let contactImportResponse = protoResponse as? IGPUserContactsImportResponse {
                    IGUserContactsImportRequest.Handler.interpret(response: contactImportResponse)
                    self.getContactListFromServer()
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
    
    func getContactListFromServer() {
        IGUserContactsGetListRequest.Generator.generate().success { (protoResponse) in
            switch protoResponse {
            case let contactGetListResponse as IGPUserContactsGetListResponse:
                DispatchQueue.main.async {
                    IGUserContactsGetListRequest.Handler.interpret(response: contactGetListResponse)
                    IGSettingAddContactViewController.reloadAfterAddContact = true
                    self.navigationController?.popViewController(animated: true)
                }
                break
            default:
                break
            }
            }.error { (errorCode, waitTime) in
                
            }.send()
    }
    
    
    fileprivate func setSelectedCountry(_ country:IGCountryInfo) {
        txtCountryCode.text = "+" + String(Int((country.countryCode)))
        btnChooseCountry.setTitle(country.countryName , for: UIControlState.normal)
        
        if country.codePattern != nil && country.codePattern != "" {
            edtPhoneNumber.setMask((country.codePatternMask), withMaskTemplate: country.codePatternTemplate)
        } else {
            let codePatternMask = "{ddddddddddddddddddddddddd}"
            let codePatternTemplate = "_________________________"
            edtPhoneNumber.setMask(codePatternMask, withMaskTemplate: codePatternTemplate)
        }
    }
    
    func didSelectCountry(country: IGCountryInfo) {
        setSelectedCountry(country)
    }
}
