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

class IGSplashScreenViewController: UIViewController {

    
    @IBOutlet weak var backgroundLatyer: UIView!
    @IBOutlet weak var mainImageView: GIFImageView!
    @IBOutlet weak var secondCenterImageView: UIImageView!
    @IBOutlet weak var animateCityImageView: UIImageView!
    @IBOutlet weak var greenTreeImageView: UIImageView!
    @IBOutlet weak var CenterImageView: UIImageView!
    @IBOutlet weak var secondIGapLabel: UILabel!
    @IBOutlet weak var iGapLabel: UILabel!
    @IBOutlet weak var limitlessConnectionLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var pageControll: UIPageControl!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var secendDescriptionTextView: UITextView!
    @IBOutlet weak var thirdDescriptionTextView: UITextView!
    @IBOutlet weak var fourthDescriptionTextView: UITextView!
    @IBOutlet weak var fifthDescriptionTextView: UITextView!
    
    var pageIndex : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.isNavigationBarHidden = true
        
        animateCityImage()
        handlePageControll()
        scrollView.delegate = self
        scrollView.contentSize = CGSize(width: self.view.frame.width*5, height: scrollView.frame.size.height)
        scrollView.backgroundColor = UIColor.clear
        startButton.layer.borderWidth = 0
        startButton.layer.cornerRadius = 15
        startButton.alpha = 0.0
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(animateCityImage), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mainImageView.prepareForAnimation(withGIFNamed: "Splash", loopCount: 1) { (Void) in
            DispatchQueue.main.async( execute: {
                UIView.animate(withDuration: 0.4, animations: {
                    let frame = self.mainImageView.frame
                    self.mainImageView.frame = CGRect(x: frame.origin.x + frame.size.width/10.0,
                                                      y: frame.origin.y + frame.size.height/10.0,
                                                      width: frame.size.width - frame.size.width/5.0,
                                                      height: frame.size.height - frame.size.height/5.0)
                    
                    }, completion: { (Bool) in
                        UIView.animate(withDuration: 0.2, animations: {
                            let frame = self.mainImageView.frame
                            self.mainImageView.frame = CGRect(x: frame.origin.x - frame.size.width/2.0,
                                                              y: frame.origin.y - frame.size.height/2.0,
                                                              width: frame.size.width * 2.0,
                                                              height: frame.size.height * 2.0)
                            self.mainImageView.alpha = 0.0
                            self.backgroundLatyer.alpha = 0.0
                        }, completion: { (Bool) in
                            //
                        })
                })

            })
        }
        mainImageView.startAnimatingGIF()
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
    
    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    
    
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
        UIView.animate(withDuration: 10.0, delay: 0.0, options: [.repeat,.curveLinear]  , animations: {
            firstAnimationImageView.frame = firstAnimationImageView.frame.offsetBy(dx: -1 * firstAnimationImageView.frame.size.width, dy: 0.0)
            secondAnimationImageView.frame = secondAnimationImageView.frame.offsetBy(dx: -1 * secondAnimationImageView.frame.size.width, dy: 0.0)
        }, completion: nil)
    }

    
    private func handlePageControll(){
    }
}

extension IGSplashScreenViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControll.currentPage = Int(pageNumber)
        pageIndex = Int(pageNumber)
        switch pageIndex {
        case 0:
            UIView.transition(with: self.descriptionTextView,
                              duration: 0.5,
                              options: UIViewAnimationOptions.transitionCrossDissolve,
                              animations: {
                                self.secendDescriptionTextView.alpha = 0
                                self.thirdDescriptionTextView.alpha = 0
                                self.fourthDescriptionTextView.alpha = 0
                                self.fifthDescriptionTextView.alpha = 0
                                self.limitlessConnectionLabel.alpha = 1
                                self.descriptionTextView.alpha = 1
                                self.CenterImageView.image = UIImage(named: "IG_Splash_Logo")
                                self.CenterImageView.alpha = 1
                                self.secondCenterImageView.alpha = 0
                                self.iGapLabel.text = "iGAP"
                                self.iGapLabel.alpha = 1
                                self.secondIGapLabel.alpha = 0
                                self.limitlessConnectionLabel.text = "Limitless Connection"
                                self.descriptionTextView.textAlignment = .center
                                self.startButton.alpha = 0.0
                                self.skipButton.alpha = 1.0
            },
                              completion: nil)
            break
        case 1:
            UIView.transition(with: self.secendDescriptionTextView,
                              duration: 0.5,
                              options: UIViewAnimationOptions.transitionCrossDissolve,
                              animations: {
                                self.descriptionTextView.alpha = 0
                                self.thirdDescriptionTextView.alpha = 0
                                self.fourthDescriptionTextView.alpha = 0
                                self.fifthDescriptionTextView.alpha = 0
                                self.secendDescriptionTextView.alpha = 1
                                self.limitlessConnectionLabel.alpha = 0
                                self.secondCenterImageView.image = UIImage(named: "IG_Splash_Secure")
                                self.CenterImageView.alpha = 0
                                self.secondCenterImageView.alpha = 1
                                self.secondIGapLabel.text = "SECURITY"
                                self.iGapLabel.alpha = 0
                                self.secondIGapLabel.alpha = 1
                                self.secendDescriptionTextView.textAlignment = .center
                                self.startButton.alpha = 0.0
                                self.skipButton.alpha = 1.0
            },
                              completion: nil)
            break
        case 2:
            UIView.transition(with: self.thirdDescriptionTextView,
                              duration: 0.5,
                              options: UIViewAnimationOptions.transitionCrossDissolve,
                              animations: {
                                self.descriptionTextView.alpha = 0
                                self.secendDescriptionTextView.alpha = 0
                                self.fourthDescriptionTextView.alpha = 0
                                self.fifthDescriptionTextView.alpha = 0
                                self.limitlessConnectionLabel.alpha = 0
                                self.iGapLabel.text = "CHAT"
                                self.secondIGapLabel.alpha = 0
                                self.iGapLabel.alpha = 1
                                self.CenterImageView.image = UIImage(named: "IG_Splash_Chat")
                                self.secondCenterImageView.alpha = 0
                                self.CenterImageView.alpha = 1
                                self.thirdDescriptionTextView.alpha = 1
                                self.thirdDescriptionTextView.textAlignment = .center
                                self.startButton.alpha = 0.0
                                self.skipButton.alpha = 1.0
                                
            },
                              completion: nil)
            break
        case 3:
            UIView.transition(with: self.fourthDescriptionTextView,
                              duration: 0.5,
                              options: UIViewAnimationOptions.transitionCrossDissolve,
                              animations: {
                                self.descriptionTextView.alpha = 0
                                self.secendDescriptionTextView.alpha = 0
                                self.thirdDescriptionTextView.alpha = 0
                                self.fifthDescriptionTextView.alpha = 0
                                self.limitlessConnectionLabel.alpha = 0
                                self.secondIGapLabel.text = "FILE TRANSFER"
                                self.iGapLabel.alpha = 0
                                self.secondIGapLabel.alpha = 1
                                self.secondCenterImageView.image = UIImage(named: "IG_Splash_Transfer")
                                self.CenterImageView.alpha = 0
                                self.secondCenterImageView.alpha = 1
                                self.fourthDescriptionTextView.alpha = 1
                                self.fourthDescriptionTextView.textAlignment = .center
                                self.startButton.alpha = 0.0
                                self.skipButton.alpha = 1.0
            },
                              completion: nil)
            break
        case 4:
            UIView.transition(with: self.fifthDescriptionTextView,
                              duration: 0.5,
                              options: UIViewAnimationOptions.transitionCrossDissolve,
                              animations: {
                                self.descriptionTextView.alpha = 0
                                self.secendDescriptionTextView.alpha = 0
                                self.thirdDescriptionTextView.alpha = 0
                                self.fourthDescriptionTextView.alpha = 0
                                self.limitlessConnectionLabel.alpha = 0
                                self.iGapLabel.text = "EVERYTHING FOR FREE"
                                self.secondIGapLabel.alpha = 0
                                self.iGapLabel.alpha = 1
                                self.CenterImageView.image = UIImage(named: "IG_Splash_Boy")
                                self.secondCenterImageView.alpha = 0
                                self.CenterImageView.alpha = 1
                                self.fifthDescriptionTextView.alpha = 1
                                self.fifthDescriptionTextView.textAlignment = .center
                                self.startButton.alpha = 1.0
                                self.skipButton.alpha = 0.0
            },
                              completion: nil)
            break
        default:
            break
        }
    }
}
