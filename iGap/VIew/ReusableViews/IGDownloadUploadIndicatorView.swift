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

protocol IGDownloadUploadIndicatorViewDelegate {
    func downloadUploadIndicatorDidTapOnStart(_ indicator: IGDownloadUploadIndicatorView)
    func downloadUploadIndicatorDidTapOnCancel(_ indicator: IGDownloadUploadIndicatorView)
    
}

class IGDownloadUploadIndicatorView: UIView {
    
    enum IndicatorType {
        case media
        case incommingFile
        case outgoingFile
    }
    
    var delegate: IGDownloadUploadIndicatorViewDelegate?
    private var state: IGFile.Status = .readyToDownload
    var shouldShowSize: Bool = false
    var size: String? {
        didSet {
            self.sizeLabel?.text = size
        }
    }
    
    private var backgroundView: UIView?
    private var containerView: UIView?
    private var downloadButton: UIButton?
    private var sizeLabel: UILabel?
    private var downloadUploadView: UIView?
    private var downloadUploadPercentageLabel: UILabel?
    private var downlaodUploadProgressPathWidth: CGFloat = 5.0
    fileprivate var downloadUploadProgressLayer: CAShapeLayer!
    
    private var currentPercent = 0.0
    private var nextPercent    = 0.0
    
    private var downloadImageName: String = ""
    private var downloadUploadText = ""
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        configure()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    func configure() {
        self.isHidden = false
        self.backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        self.addSubview(backgroundView!)
        backgroundView!.backgroundColor = UIColor.black
        backgroundView?.alpha = 0.5
        self.backgroundView?.snp.makeConstraints({ (make) in
            make.center.equalTo(self.snp.center)
            make.width.equalTo(self.snp.width)
            make.height.equalTo(self.snp.height)
        })
        
        self.alpha = 1.0
        self.backgroundColor = UIColor.clear
        self.isUserInteractionEnabled = true
        let tapRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(didTapOnView))
        self.addGestureRecognizer(tapRecognizer)
        self.setState(.readyToDownload)
    }
    
    func prepareForReuse() {
        self.downloadButton?.removeFromSuperview()
        self.sizeLabel?.removeFromSuperview()
        self.downloadUploadView?.removeFromSuperview()
        self.downloadUploadPercentageLabel?.removeFromSuperview()
        
        self.downloadButton = nil
        self.sizeLabel = nil
        self.downloadUploadView = nil
        self.downloadUploadPercentageLabel = nil
    }
    
    func didTapOnView() {
        self.delegate?.downloadUploadIndicatorDidTapOnStart(self)
    }
    
    func setFileType(_ type: IndicatorType) {
        switch type {
        case .media:
            downloadImageName = "IG_Message_Cell_Attachment_Download"
            backgroundView?.alpha = 0.5
            sizeLabel?.alpha = 1.0
            downlaodUploadProgressPathWidth = 5.0
            downloadUploadPercentageLabel?.textColor = UIColor.white
            downloadUploadPercentageLabel?.font = UIFont.systemFont(ofSize: 5.0, weight: 2)
            break
        case .incommingFile:
            downloadImageName = "IG_Message_Cell_Attachment_Download_File"
            backgroundView?.alpha = 0.0
            sizeLabel?.alpha = 0.0
            downlaodUploadProgressPathWidth = 2.0
            downloadUploadPercentageLabel?.textColor = UIColor.black
            downloadUploadPercentageLabel?.font = UIFont.systemFont(ofSize: 4.0, weight: 2)
            break
        case .outgoingFile:
            downloadImageName = "IG_Message_Cell_Attachment_Download_File_Outgoing"
            backgroundView?.alpha = 0.0
            sizeLabel?.alpha = 0.0
            downlaodUploadProgressPathWidth = 2.0
            downloadUploadPercentageLabel?.textColor = UIColor.white
            downloadUploadPercentageLabel?.font = UIFont.systemFont(ofSize: 4.0, weight: 2)
            break
        }
        
        self.addDownloadButtonIfNeeded() //In case of reuse
        self.downloadButton?.setImage(UIImage(named:downloadImageName), for: .normal)
    }
    
    
    func setState(_ state:IGFile.Status) {
        switch state {
        case .readyToDownload:
            self.addDownloadButtonIfNeeded()
            self.addSizeLabelIfNeeded()
            self.downloadUploadView?.removeFromSuperview()
            self.downloadUploadView = nil
            self.isHidden = false
            self.downloadUploadText = "Processing"
            break
        case .downloading:
            self.downloadUploadView?.isHidden = false
            self.downloadButton?.removeFromSuperview()
            self.sizeLabel?.removeFromSuperview()
            self.downloadButton = nil
            self.sizeLabel = nil
            self.isHidden = false
            self.downloadUploadText = "Downloading"
            break
        case .processingAfterDownload:
            break
            
        case .downloadPause:
            self.addDownloadButtonIfNeeded()
            self.addSizeLabelIfNeeded()
            self.downloadUploadView?.removeFromSuperview()
            self.downloadUploadView = nil
            self.isHidden = false
            self.downloadUploadText = "Download Paused"
            break
        case .downloadFailed:
            break
            
        case .processingForUpload:
            self.downloadUploadView?.isHidden = false
            self.downloadButton?.removeFromSuperview()
            self.sizeLabel?.removeFromSuperview()
            self.downloadButton = nil
            self.sizeLabel = nil
            self.isHidden = false
            break
        case .uploading:
            self.downloadUploadView?.isHidden = false
            self.downloadButton?.removeFromSuperview()
            self.sizeLabel?.removeFromSuperview()
            self.downloadButton = nil
            self.sizeLabel = nil
            self.isHidden = false
            self.downloadUploadText = "Uploading"
            break
        case .waitingForServerProcess:
            break
            
        case .uploadPause:
            break
        case .uploadFailed:
            break
            
        case .ready:
            self.downloadUploadText = ""
            self.downloadUploadView?.removeFromSuperview()
            self.downloadButton?.removeFromSuperview()
            self.sizeLabel?.removeFromSuperview()
            self.downloadUploadView = nil
            self.downloadButton = nil
            self.sizeLabel = nil
            self.downloadUploadView = nil
            self.isHidden = true
        case .unknown:
            break
        }
    }
    
    
    func setPercentage(_ percent: Double) {
        self.addDownlaodViewIfNeeded()
        
        // We want to animate the strokeEnd property of the circleLayer
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = 1.0
        animation.delegate = self
        
        if downloadUploadProgressLayer.strokeEnd == 0 {
            animation.fromValue = 0.0
        } else if downloadUploadProgressLayer.strokeEnd == 1 {
            return
        } else {
            animation.fromValue = downloadUploadProgressLayer.presentation()?.strokeEnd //currentPercent
        }
        
        let nextValue = percent
        
        
        downloadUploadPercentageLabel?.text = "\(self.downloadUploadText)\n\(String(format: "%.2f", percent*100))%"
        
        animation.toValue = nextValue
        
        // Do a linear animation (i.e. the speed of the animation stays the same)
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        // Set the circleLayer's strokeEnd property to the download percent so that it's the
        // right value when the animation ends.
        downloadUploadProgressLayer.strokeEnd = CGFloat(nextValue)
        
        // Do the actual animation
        //downloadProgressLayer.removeAnimation(forKey: "animateCircle")
        downloadUploadProgressLayer.add(animation, forKey: "animateCircle")

        currentPercent = nextValue
    }
    
    //MARK: Private Methods
    private func addDownloadButtonIfNeeded() {
        if self.downloadButton == nil {
            self.downloadButton = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            self.downloadButton?.setImage(UIImage(named:downloadImageName), for: .normal)
            self.downloadButton?.addTarget(self, action: #selector(didTapOnView), for: .touchUpInside)
            self.addSubview(self.downloadButton!)
            self.downloadButton?.snp.makeConstraints({ (make) in
                make.centerX.equalTo(self.snp.centerX)
                make.centerY.equalTo(self.snp.centerY).offset(-2.5)
                make.height.equalTo(self.snp.height).multipliedBy(0.6).priority(999)
                make.width.equalTo(self.snp.height).multipliedBy(0.6).priority(999)
                make.height.lessThanOrEqualTo(50)
                make.width.lessThanOrEqualTo(50)
            })
        }
    }
    
    private func addSizeLabelIfNeeded() {
        if self.sizeLabel == nil  && shouldShowSize {
            self.sizeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            self.sizeLabel?.text = size
            self.sizeLabel?.font = UIFont.systemFont(ofSize: 9.0, weight: 2)
            self.sizeLabel?.textColor = UIColor.white
            self.sizeLabel?.textAlignment = .center
            self.addSubview(self.sizeLabel!)
            self.sizeLabel?.snp.makeConstraints({ (make) in
                make.centerX.equalTo(self.snp.centerX)
                make.width.equalTo(self.snp.width)
                make.top.equalTo((self.downloadButton?.snp.bottom)!).offset(-7.5)
                make.height.equalTo(10)
            })
        }
    }
    
    
    private func addDownlaodViewIfNeeded() {
        if downloadUploadView == nil {
            let downloadViewWidth = min(frame.width * 0.8, 66)
            let downloadViewheight = downloadViewWidth
            let downloadViewX = (frame.width - downloadViewWidth) / 2.0
            let downloadViewY = (frame.height - downloadViewWidth) / 2.0
            downloadUploadView = UIView(frame: CGRect(x: downloadViewX, y: downloadViewY, width: downloadViewWidth, height: downloadViewheight))
            self.addSubview(downloadUploadView!)
            
            
            let pathWidth = downlaodUploadProgressPathWidth //: CGFloat = 5.0
            let circlePath = UIBezierPath(arcCenter: CGPoint(x: downloadViewWidth / 2.0, y: downloadViewWidth / 2.0),
                                          radius: (downloadViewWidth - pathWidth) / 2.0,
                                          startAngle: CGFloat(-(M_PI / 2.0)),
                                          endAngle: CGFloat(M_PI * 1.5),
                                          clockwise: true)
            
            // Setup the CAShapeLayer with the path, colors, and line width
            let shadowLayer = CAShapeLayer()
            shadowLayer.path = circlePath.cgPath
            shadowLayer.fillColor = UIColor.clear.cgColor
            shadowLayer.strokeColor = UIColor.black.withAlphaComponent(0.2).cgColor
            shadowLayer.lineWidth = pathWidth + 1.0
            shadowLayer.strokeEnd = 1.0
            // Add the circleLayer to the view's layer's sublayers
            downloadUploadView!.layer.addSublayer(shadowLayer)
            
            // Setup the CAShapeLayer with the path, colors, and line width
            let circleLayer = CAShapeLayer()
            circleLayer.path = circlePath.cgPath
            circleLayer.fillColor = UIColor.clear.cgColor
            circleLayer.strokeColor = UIColor.black.cgColor
            circleLayer.lineWidth = pathWidth
            circleLayer.strokeEnd = 1.0
            // Add the circleLayer to the view's layer's sublayers
            downloadUploadView!.layer.addSublayer(circleLayer)
            
            // Setup the CAShapeLayer with the path, colors, and line width
            downloadUploadProgressLayer = CAShapeLayer()
            downloadUploadProgressLayer.path = circlePath.cgPath
            downloadUploadProgressLayer.fillColor = UIColor.clear.cgColor
            downloadUploadProgressLayer.strokeColor = UIColor.organizationalColor().cgColor
            downloadUploadProgressLayer.lineWidth = pathWidth
            // Don't draw the circle initially
            downloadUploadProgressLayer.strokeEnd = 0.0
            downloadUploadProgressLayer.presentation()?.strokeEnd = 0.0
            // Add the circleLayer to the view's layer's sublayers
            downloadUploadView!.layer.addSublayer(downloadUploadProgressLayer)
            
            downloadUploadPercentageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            downloadUploadPercentageLabel?.font = UIFont.systemFont(ofSize: 4.0, weight: 2)
            downloadUploadPercentageLabel?.numberOfLines = 0
            downloadUploadPercentageLabel?.textAlignment = .center
            
            downloadUploadView?.addSubview(downloadUploadPercentageLabel!)
            
            self.downloadUploadPercentageLabel?.snp.makeConstraints({ (make) in
                make.width.equalTo(downloadUploadView!.snp.width)
                make.height.equalTo(downloadUploadView!.snp.height)
                make.center.equalTo(downloadUploadView!.snp.center)
            })
        }
    }
}

extension IGDownloadUploadIndicatorView: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let strokeEnd = downloadUploadProgressLayer.presentation()?.strokeEnd {
            if  strokeEnd >= CGFloat(1){
                //TODO: nil all subviews and sublayers
//                self.removeFromSuperview()
                self.isHidden = true
            } else {
                
            }
        }
    }
}
