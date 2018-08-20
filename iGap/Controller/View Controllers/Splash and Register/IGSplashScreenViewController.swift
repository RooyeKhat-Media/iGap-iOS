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
import Gifu
import SnapKit

class IGSplashScreenViewController: UIViewController {
    
    
    @IBOutlet weak var backgroundLayer: UIView!
    @IBOutlet weak var gifImageView: GIFImageView!
    @IBOutlet weak var pageControll: UIPageControl!
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var skipButton: UIButton!
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var animateCityImageView: UIImageView!
    @IBOutlet weak var greenTreeImageView: UIImageView!
    @IBOutlet weak var startButton: UIButton!
    
    
    
    var numberOfPages: Int = 6
    var pageIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IGContactManager.importedContact = false
        
        // Do any additional setup after loading the view.
        self.navigationController?.isNavigationBarHidden = true
        
        animateCityImage()
        addSwipegestureRecognizer()
        
        pageControll.numberOfPages = numberOfPages
        pageControll.isUserInteractionEnabled = false
        
        startButton.layer.borderWidth = 0
        startButton.layer.cornerRadius = 15
        startButton.alpha = 0.0
        
        skipButton.layer.borderWidth = 0
        skipButton.layer.cornerRadius = 8
        
        NotificationCenter.default.addObserver(self, selector: #selector(animateCityImage), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        let gradient: CAGradientLayer = CAGradientLayer()
        let gradientStartColor = UIColor(hexString: "bae6ff")
        let gradientCebterColor = UIColor(hexString: "e4f5ff")
        let gradientEndColor = UIColor.white
        gradient.colors = [gradientStartColor.cgColor, gradientCebterColor.cgColor, gradientEndColor.cgColor]
        gradient.locations = [0.0 , 0.25, 0.5]
        gradient.startPoint = CGPoint(x: 1.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.topView.frame.size.width, height: self.topView.frame.size.height)
        
        self.topView.layer.insertSublayer(gradient, at: 0)
        
        
        let images = ["IG_Splash_Cute_1", "IG_Splash_Cute_2", "IG_Splash_Cute_3", "IG_Splash_Cute_4", "IG_Splash_Cute_5", "IG_Splash_Cute_6"]
        let titles = ["Limitless Connection", "Security & Privacy", "Chat", "File Transferring", "Voice Call", "Everything for free in iGap!"]
        let descriptions = ["Build your own world by iGap right now.\nIt takes only few minutes to join iGap community.",
                            "iGap attaches the utmost importance to your security and privacy using the individual encryption algorithms and guarantees a safe and secure connection between you, your friends and family.",
                            "You can have one-on-one or group chats and even create your own channel and add members in order to share information with millions of people.",
                            "You have an authority to transfer any file with any size and type or save them on your cloud storage; and then share anything you'd like to with anyone you'd want to.",
                            "You can make thoroughly free and secure voice calls to anyone on iGap and save your money. iGap voice call is P2P-based with no servers' interference in voice transmission.",
                            "Let's stop waiting!\niGap is thoroughly free. So, just now build your own world freely."]
        
        for i in 0..<numberOfPages {
            let imageView = UIImageView(frame: CGRect.zero)
            imageView.image = UIImage(named: images[i])
            imageView.tag = i
            self.topView.addSubview(imageView)
            imageView.snp.makeConstraints({ (make) in
                make.width.equalTo(162.0)
                make.height.equalTo(125.0)
                make.centerX.equalToSuperview()
                make.top.equalToSuperview().offset(36.0)
            })
            
            
            let titleLabel = UILabel(frame: CGRect.zero)
            titleLabel.text = titles[i]
            titleLabel.textAlignment = .center
            titleLabel.tag = i
            titleLabel.font = UIFont.boldSystemFont(ofSize: 18.0)
            self.topView.addSubview(titleLabel)
            titleLabel.snp.makeConstraints({ (make) in
                make.top.equalTo(imageView.snp.bottom).offset(28.0)
                make.width.equalToSuperview().offset(-32.0)
                make.height.equalTo(20.0)
                make.centerX.equalToSuperview()
            })
            
            
            let desciptionLabel = UILabel(frame: CGRect.zero)
            desciptionLabel.text = descriptions[i]
            desciptionLabel.textAlignment = .center
            desciptionLabel.numberOfLines = 0
            desciptionLabel.tag = i
            self.topView.addSubview(desciptionLabel)
            desciptionLabel.snp.makeConstraints({ (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(8.0)
                make.width.equalToSuperview().offset(-32.0)
                make.bottom.equalToSuperview()
                make.centerX.equalToSuperview()
            })
            
            
            if i != 0 {
                imageView.alpha = 0.0
                titleLabel.alpha = 0.0
                desciptionLabel.alpha = 0.0
            }
        }
        
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        gifImageView.prepareForAnimation(withGIFNamed: "Splash", loopCount: 1) { (Void) in
            DispatchQueue.main.async( execute: {
                UIView.animate(withDuration: 0.4, animations: {
//                    let frame = self.gifImageView.frame
//                    self.gifImageView.frame = CGRect(x: frame.origin.x + frame.size.width/10.0,
//                                                     y: frame.origin.y + frame.size.height/10.0,
//                                                     width: frame.size.width - frame.size.width/5.0,
//                                                     height: frame.size.height - frame.size.height/5.0)
                    
                }, completion: { (Bool) in
                    UIView.animate(withDuration: 0.2, animations: {
                        let frame = self.gifImageView.frame
                        self.gifImageView.frame = CGRect(x: frame.origin.x - frame.size.width/2.0,
                                                         y: frame.origin.y - frame.size.height/2.0,
                                                         width: frame.size.width * 2.0,
                                                         height: frame.size.height * 2.0)
                        self.gifImageView.alpha = 0.0
                        self.backgroundLayer.alpha = 0.0
                    }, completion: { (Bool) in
                        //
                    })
                })
                
            })
        }
        gifImageView.startAnimatingGIF()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func didTapOnSkipButton(_ sender: UIButton) {
        self.performSegue(withIdentifier: "showPhoneNumber", sender: self)
    }
    
    @IBAction func didTapOnStartButton(_ sender: UIButton) {
        self.performSegue(withIdentifier: "showPhoneNumber", sender: self)
    }    
    
    @objc private func animateCityImage() {
        self.animateCityImageView.subviews.forEach({ $0.removeFromSuperview() })
        let backgroundImage = UIImage(named:"IG_Splash_City")!
        // UIImageView 1
        let firstAnimationImageView = UIImageView(image: backgroundImage)
        firstAnimationImageView.frame = CGRect(x: 0.0, 
                                               y: 0.0,
                                               width: backgroundImage.size.width,
                                               height: self.animateCityImageView.frame.size.height)
        firstAnimationImageView.contentMode = .scaleAspectFit
        self.animateCityImageView.addSubview(firstAnimationImageView)
        // UIImageView 2
        let secondAnimationImageView = UIImageView(image: backgroundImage)
        secondAnimationImageView.frame = CGRect(x: firstAnimationImageView.frame.size.width,
                                                y: 0.0,
                                                width: backgroundImage.size.width,
                                                height: self.animateCityImageView.frame.height)
        self.animateCityImageView.addSubview(secondAnimationImageView)
        // Animate background
        UIView.animate(withDuration: 40.0, delay: 0.0, options: [.repeat,.curveLinear]  , animations: {
            firstAnimationImageView.frame = firstAnimationImageView.frame.offsetBy(dx: -1 * firstAnimationImageView.frame.size.width, dy: 0.0)
            secondAnimationImageView.frame = secondAnimationImageView.frame.offsetBy(dx: -1 * secondAnimationImageView.frame.size.width, dy: 0.0)
        }, completion: nil)
    }
    
    
    func addSwipegestureRecognizer() {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture(_:)))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture(_:)))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
        
        
    }
    
    @objc func respondToSwipeGesture(_ gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                if pageIndex > 0 {
                    changeView(for: pageIndex - 1)
                }
            case UISwipeGestureRecognizerDirection.left:
                if pageIndex < (numberOfPages - 1) {
                    changeView(for: pageIndex + 1)
                }
            default:
                break
            }
        }
    }
    
    func changeView(for page: Int) {
        pageControll.currentPage = page
        pageIndex = page
        UIView.animate(withDuration: 0.5, animations: {
            for view in self.topView.subviews {
                if (view == self.skipButton && self.pageIndex != self.numberOfPages - 1) || view.tag == self.pageIndex {
                    view.alpha = 1.0
                } else {
                    view.alpha = 0.0
                }
            }
            if self.pageIndex == self.numberOfPages - 1 {
                self.startButton.alpha = 1.0
            } else {
                self.startButton.alpha = 0.0
            }
        }) { (completed) in
            
        }
    }
}
