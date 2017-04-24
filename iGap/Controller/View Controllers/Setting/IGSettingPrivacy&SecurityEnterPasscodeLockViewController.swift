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

class IGSettingPrivacy_SecurityEnterPasscodeLockViewController: UIViewController {
    
    class IGPassCodeDigitView: UIView {
        var digitView : UIView!
        override init(frame: CGRect) {
            super.init(frame: frame)
            digitView = UIView()
            self.addSubview(digitView)
            digitView.backgroundColor = UIColor.black
            digitView.snp.makeConstraints { (make) in
                make.centerY.equalTo(self.snp.centerY)
                make.left.equalTo(self.snp.left)
                make.width.equalTo(frame.width)
                make.height.equalTo(frame.height / 2.0)
            }
            
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func roundDigitView(isRounded: Bool) {
            if isRounded == true {
                if digitView.frame.size.height == self.frame.height / 2.0 {
                    digitView.snp.updateConstraints { (make) in
                        make.height.equalTo(frame.width)
                    }
                    digitView.layer.cornerRadius = digitView.frame.size.width / 2.0
                }
            }else{
                digitView.snp.updateConstraints{ (make) in
                    make.height.equalTo(self.frame.height / 2.0)
                    digitView.layer.cornerRadius = 0
                    
                }
            }
        }
    }
    
    class IGDigitViewContainer : UIView {
        var arrayOfDigitView : [IGPassCodeDigitView]?
        func addDigitViewsToMainView ( numberOfDigits : Int ) {
            arrayOfDigitView = [IGPassCodeDigitView]()
            var i = 0
            while i < numberOfDigits  {
                let digitView = IGPassCodeDigitView(frame: CGRect(x:0 , y: 14 , width : 25 , height : 14))
                self.addSubview(digitView)
                digitView.snp.makeConstraints{ (make) in
                    if i == 0 {
                        make.left.equalTo(self.snp.left)
                    } else {
                        make.left.equalTo((arrayOfDigitView?.last!.snp.right)!).offset(25)
                    }
                    make.centerY.equalTo(self.snp.centerY)
                    make.width.equalTo(25.0)
                    make.height.equalTo(14.0)
                }
                self.layoutIfNeeded()
                arrayOfDigitView?.append(digitView)
                
                i += 1
            }
            
            self.snp.makeConstraints { (make) in
                make.width.equalTo((numberOfDigits * 25) + (numberOfDigits - 1) * 25)
                make.height.equalTo(28)
            }
            
        }
        
        func roundDigit(digitIndex: Int ,isRounded : Bool) {
            arrayOfDigitView?[digitIndex].roundDigitView(isRounded: isRounded)
            
        }
        func removeAllRoundDigit() {
            for digit in arrayOfDigitView! {
                digit.roundDigitView(isRounded: false)
            }
        }
    }
    class IGPassCodeViewWithTitle : UIView {
        var passCodeMainView : IGDigitViewContainer!
        var passCodeTitleLabel : UILabel!
        var digitView : IGPassCodeDigitView!
        func makePassCodeMainView(title: String , numberOfDigit: Int) {
            passCodeMainView = IGDigitViewContainer()
            self.addSubview(passCodeMainView)
            passCodeMainView.snp.makeConstraints{ (make) in
                make.center.equalTo(self.snp.center)
                make.width.equalTo(200)
                make.height.equalTo(28)
            }
            passCodeMainView.addDigitViewsToMainView(numberOfDigits: numberOfDigit)
            passCodeTitleLabel = UILabel()
            self.addSubview(passCodeTitleLabel)
            passCodeTitleLabel.snp.makeConstraints{ (make) in
                make.bottom.equalTo(passCodeMainView.snp.top).offset(-50)
                make.width.equalTo(300)
                make.height.equalTo(passCodeMainView.snp.height)
                make.centerX.equalTo(self.snp.centerX)
            }
            passCodeTitleLabel.text = title
            passCodeTitleLabel.textAlignment = .center
            self.snp.makeConstraints{ (make) in
                make.width.equalTo(passCodeTitleLabel.snp.width)
                make.height.equalTo(200)
            }
        }
        
        func roundDigitAtIndex(digitIndex: Int , isRounded: Bool) {
            passCodeMainView.roundDigit(digitIndex: digitIndex, isRounded: isRounded)
        }
        
        func removeAllRoundDigit() {
            passCodeMainView.removeAllRoundDigit()
        }
        
        func passcodeTitleShouldChanged(newTitle: String) {
            passCodeTitleLabel.text = newTitle
        }
        
        func passwordisIncorrect() {
            let animation = CABasicAnimation(keyPath: "position")
            animation.duration = 0.07
            animation.repeatCount = 4
            animation.autoreverses = true
            let firstValue = CGPoint(x: passCodeMainView.center.x - 10, y: passCodeMainView.center.y)
            animation.fromValue = NSValue(cgPoint:(firstValue))
            let secondValue = CGPoint(x: passCodeMainView.center.x + 10, y:  passCodeMainView.center.y)
            animation.toValue = NSValue(cgPoint: (secondValue))
            passCodeMainView.layer.add(animation, forKey: "position")
        }
        
    }
    @IBOutlet weak var mainViewPassCode: UIView!
    @IBOutlet weak var mainViewPassCodeLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var hiddenTextField: UITextField!
    var isfirstTimeToEnterPassCode: Bool? = true
    var isChangePasswordMode: Bool?
    var isLockedAppMode: Bool?
    var isTurnOnPassCode: Bool = true
    var passcodeMainView : UIView!
    var passCodeViewWithTitle = IGPassCodeViewWithTitle()
    var titleOfPassCode : String?
    var newPassCodeText: String?
    var oldPassCodeText: String?
    var lockPassCode : String? = "1234"
    var numberOfAnimatePassCodeView: Int = 0
    var isTimeToReEnterNewPassCode: Bool = false
    var digitIsNotRound : Bool = true
    var isReturnKeyIsPressed : Bool = false
    
    override func viewDidLoad() {
        if isChangePasswordMode == true {
            titleOfPassCode = "Please Enter Your Old Passcode"
        } else {
            titleOfPassCode = "Please Enter Your Passcode"
        }
        self.view.addSubview(mainViewPassCode)
        self.mainViewPassCode.addSubview(passCodeViewWithTitle)
        passCodeViewWithTitle.snp.makeConstraints { (make) in
            make.center.equalTo(self.mainViewPassCode.snp.center)
            make.width.equalTo(mainViewPassCode.snp.width)
            make.height.equalTo(mainViewPassCode.snp.height)
        }
        passCodeViewWithTitle.makePassCodeMainView(title: titleOfPassCode!, numberOfDigit: 4)
        hiddenTextField.delegate = self
        self.hiddenTextField.becomeFirstResponder()
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addModalViewItems(leftItemText: "Cancel", rightItemText: "Done", title: "Enter PassCode")
        navigationItem.leftViewContainer?.addAction {
            self.dismiss(animated: true, completion: nil)
        }
        hiddenTextField.keyboardType = .phonePad
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let passCodeTableView =  segue.destination as? IGSettingPrivacy_SecurityPasscodeLockTableViewController
        passCodeTableView?.loadItForSecendTime = true
    }
    
}
extension IGSettingPrivacy_SecurityEnterPasscodeLockViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        isReturnKeyIsPressed = true
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard var text = hiddenTextField.text else { return true }
        var newLength : Int = 0
        
        if numberOfAnimatePassCodeView == 0 && isfirstTimeToEnterPassCode == true {
            newLength = text.characters.count + string.characters.count - range.length
        }else {
            newLength = text.characters.count - range.length
        }
        if(newLength <= 4) {
            if newLength == 0 {
                passCodeViewWithTitle.removeAllRoundDigit()
            }
            if  newLength == 1 {
                digitIsNotRound = false
                passCodeViewWithTitle.roundDigitAtIndex(digitIndex: newLength - 1, isRounded: true)
                
                if digitIsNotRound == false {
                    passCodeViewWithTitle.roundDigitAtIndex(digitIndex: newLength  , isRounded: false)
                    digitIsNotRound = true
                }
            }
            if newLength == 2 {
                digitIsNotRound = false
                passCodeViewWithTitle.roundDigitAtIndex(digitIndex: newLength - 1, isRounded: true)
                if digitIsNotRound == false {
                    passCodeViewWithTitle.roundDigitAtIndex(digitIndex: newLength  , isRounded: false)
                    digitIsNotRound = true
                }
                
            }
            
            if newLength == 3 {
                digitIsNotRound = false
                passCodeViewWithTitle.roundDigitAtIndex(digitIndex: newLength - 1, isRounded: true)
                if digitIsNotRound == false {
                    passCodeViewWithTitle.roundDigitAtIndex(digitIndex: newLength  , isRounded: false)
                    digitIsNotRound = true
                }
                
            }
            if newLength == 4 {
                digitIsNotRound = false
                passCodeViewWithTitle.roundDigitAtIndex(digitIndex: newLength - 1 , isRounded: true)
                if isLockedAppMode == true {
                    if text == lockPassCode {
                        self.performSegue(withIdentifier: "BackToPasscodeTable", sender: self)
                    }else {
                        passCodeViewWithTitle.passwordisIncorrect()
                        passCodeViewWithTitle.removeAllRoundDigit()
                        hiddenTextField.text = ""
                    }
                }
                
                if isTurnOnPassCode == true && numberOfAnimatePassCodeView == 0 {
                    newPassCodeText = hiddenTextField.text! + string
                    let slideInFromLeftTransition = CATransition()
                    slideInFromLeftTransition.type = kCATransitionPush
                    slideInFromLeftTransition.subtype = kCATransitionFromRight
                    slideInFromLeftTransition.duration = 0.5
                    slideInFromLeftTransition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                    slideInFromLeftTransition.fillMode = kCAFillModeRemoved
                    self.mainViewPassCode.layer.add(slideInFromLeftTransition, forKey: "slideInFromLeftTransition")
                    mainViewPassCodeLeadingConstraint.constant = -400
                    title = "Please Re-enter Your New PassCode"
                    passCodeViewWithTitle.passcodeTitleShouldChanged(newTitle: title!)
                    mainViewPassCodeLeadingConstraint.constant = -16
                    passCodeViewWithTitle.removeAllRoundDigit()
                    numberOfAnimatePassCodeView = 1
                    hiddenTextField.text = ""
                }
                
                if isTurnOnPassCode == true && numberOfAnimatePassCodeView == 1 && hiddenTextField.text != ""{
                    var reTypePassCodeText = hiddenTextField.text! + string
                    let compareReTypePassCodeText = String(reTypePassCodeText.characters.dropFirst())
                    print(compareReTypePassCodeText)
                    if compareReTypePassCodeText == newPassCodeText {
                        self.performSegue(withIdentifier: "BackToPasscodeTable", sender: self)
                    } else {
                        passCodeViewWithTitle.passwordisIncorrect()
                        passCodeViewWithTitle.removeAllRoundDigit()
                        hiddenTextField.text = ""
                    }
                }
                
                if isChangePasswordMode == true && numberOfAnimatePassCodeView == 0{
                    var comparePassCodeText : String = ""
                    if isfirstTimeToEnterPassCode == true {
                        comparePassCodeText = hiddenTextField.text! + string
                    } else {
                        let compareText = hiddenTextField.text! + string
                        comparePassCodeText = String(compareText.characters.dropFirst())
                    }
                    if comparePassCodeText != lockPassCode {
                        passCodeViewWithTitle.passwordisIncorrect()
                        passCodeViewWithTitle.removeAllRoundDigit()
                        hiddenTextField.text = ""
                        isfirstTimeToEnterPassCode = false
                    } else {
                        let slideInFromLeftTransition = CATransition()
                        slideInFromLeftTransition.type = kCATransitionPush
                        slideInFromLeftTransition.subtype = kCATransitionFromRight
                        slideInFromLeftTransition.duration = 0.5
                        slideInFromLeftTransition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                        slideInFromLeftTransition.fillMode = kCAFillModeRemoved
                        self.mainViewPassCode.layer.add(slideInFromLeftTransition, forKey: "slideInFromLeftTransition")
                        mainViewPassCodeLeadingConstraint.constant = -400
                        title = "Please Enter Your New PassCode"
                        passCodeViewWithTitle.passcodeTitleShouldChanged(newTitle: title!)
                        mainViewPassCodeLeadingConstraint.constant = -16
                        passCodeViewWithTitle.removeAllRoundDigit()
                        numberOfAnimatePassCodeView = 1
                        hiddenTextField.text = ""
                    }
                }
                
                if isChangePasswordMode == true && numberOfAnimatePassCodeView == 1 && hiddenTextField.text != "" {
                    var comparePassCodeText : String = ""
                    let compareText = hiddenTextField.text! + string
                    comparePassCodeText = String(compareText.characters.dropFirst())
                    newPassCodeText = comparePassCodeText
                    let slideInFromLeftTransition = CATransition()
                    slideInFromLeftTransition.type = kCATransitionPush
                    slideInFromLeftTransition.subtype = kCATransitionFromRight
                    slideInFromLeftTransition.duration = 0.5
                    slideInFromLeftTransition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                    slideInFromLeftTransition.fillMode = kCAFillModeRemoved
                    self.mainViewPassCode.layer.add(slideInFromLeftTransition, forKey: "slideInFromLeftTransition")
                    mainViewPassCodeLeadingConstraint.constant = -400
                    title = "Please Re-Enter Your  New PassCode"
                    passCodeViewWithTitle.passcodeTitleShouldChanged(newTitle: title!)
                    mainViewPassCodeLeadingConstraint.constant = -16
                    passCodeViewWithTitle.removeAllRoundDigit()
                    numberOfAnimatePassCodeView = 2
                    isTimeToReEnterNewPassCode = true
                    hiddenTextField.text = ""
                    
                }
                if isTimeToReEnterNewPassCode == true && hiddenTextField.text != "" {
                    var comparePassCodeText : String = ""
                    let compareText = hiddenTextField.text! + string
                    comparePassCodeText = String(compareText.characters.dropFirst())
                    if comparePassCodeText == newPassCodeText {
                        let alert = UIAlertController(title: "Success", message: "Your passcode changed successfuly", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style:.default , handler: {
                            (alert: UIAlertAction) -> Void in
                            self.performSegue(withIdentifier: "BackToPasscodeTable", sender: self)
                        })
                        alert.addAction(okAction)
                        alert.view.tintColor = UIColor.organizationalColor()
                        self.present(alert, animated: true, completion: nil)
                    }else {
                        passCodeViewWithTitle.passwordisIncorrect()
                        passCodeViewWithTitle.removeAllRoundDigit()
                        hiddenTextField.text = ""
                        isfirstTimeToEnterPassCode = false
                        
                    }
                    
                }
                
            }
            return true
        }else{
            return false
        }
    }
}

