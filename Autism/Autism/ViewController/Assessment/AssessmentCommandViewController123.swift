//
//  AssessmentCommandViewController.swift
//  Autism
//
//  Created by Dilip Technology on 15/09/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit
import FLAnimatedImage
import AVFoundation

class CommandImageView : UIImageView {
    var cmd : Command?
}

class AssessmentCommandViewController123: UIViewController {

    @IBOutlet weak var questionTitle: UILabel!
//    @IBOutlet weak var preferredImageView: UIImageView!
//    @IBOutlet weak var nonPreferredImageView: UIImageView!
    @IBOutlet weak var avatarImageView: FLAnimatedImageView!

    @IBOutlet weak var viewContainer: UIView!
    
    @IBOutlet weak var imgViewLeft: CommandImageView!
    @IBOutlet weak var imgViewRight: CommandImageView!
    @IBOutlet weak var imgViewCenter: CommandImageView!
    @IBOutlet weak var imgViewTop: CommandImageView!
    @IBOutlet weak var imgViewBottom: CommandImageView!
    
    @IBOutlet weak var imgViewHand: UIImageView!
    
    let commandViewModal: CommandViewModel = CommandViewModel()
    
    var commandList:[Command] = []
    var indexCommand:Int = 0
    var originalAvatarFrame:CGRect!
    private var initialFrame: CGRect?
    var selectedImgView:UIImageView!
    
    var speechArray:[String] = []
    
    private var isUserInteraction = true {
          didSet {
              self.view.isUserInteractionEnabled = isUserInteraction
          }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.customSetting()
        self.listenModelClosures()
        self.commandViewModal.fetchCommands()
        self.setCenterAvatar()
    }
        
    func setCenterAvatar()
    {
        self.originalAvatarFrame = CGRect(x:UIScreen.main.bounds.size.width-225, y:UIScreen.main.bounds.size.height-280, width: 200, height: 255)
        avatarImageView.bounds = CGRect(x:0, y:0, width: 200, height: 255)
        avatarImageView.center = self.view.center
        avatarImageView.transform = CGAffineTransform.identity.scaledBy(x: 2, y: 2)
        
        //900x600
        let tW:CGFloat = 900
        let tH:CGFloat = 600
        var imgWH:CGFloat = 220
        
        imgViewLeft.frame = CGRect(x:50, y:(tH-imgWH)/2.0, width:imgWH, height:imgWH)
        imgViewRight.frame = CGRect(x:tW-imgWH-50, y:(tH-imgWH)/2.0, width:imgWH, height:imgWH)
        
        imgWH = 200
        
//        imgViewCenter.frame = CGRect(x:0, y:0, width:imgWH, height:imgWH)
//        imgViewTop.frame = CGRect(x:0, y:0, width:imgWH, height:imgWH)
//        imgViewBottom.frame = CGRect(x:0, y:0, width:imgWH, height:imgWH)
        
    }
    
    func setOriginalAvatar()
    {
        avatarImageView.frame = self.originalAvatarFrame
        avatarImageView.transform = CGAffineTransform.identity.scaledBy(x: 1, y: 1)
    }
    
    @IBAction func exitAssessmentClicked(_ sender: Any) {
           
           SpeechManager.shared.setDelegate(delegate: nil)
           UserManager.shared.exitAssessment()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func skipQuestionClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func customSetting() {
        SpeechManager.shared.setDelegate(delegate: self)
    }
    
    private func listenModelClosures() {
       
       self.commandViewModal.noNetWorkClosure = {
           Utility.showRetryView(delegate: self)
       }
        
         self.commandViewModal.dataClosure = {
           DispatchQueue.main.async {
               if let res = self.commandViewModal.commandResponseVO {
                self.commandList = res.command_array
                self.startAndRepeatCommands()
               }
           }
        }
   }
    
    func startAndRepeatCommands()
    {
        do {
            sleep(2)
        }

        DispatchQueue.main.async { [self] in
            if(self.indexCommand < self.commandList.count) {
                let cmd = self.commandList[self.indexCommand]
                self.indexCommand = self.indexCommand+1
                
                let commandType = CommandType.init(rawValue: cmd.cmd_name)
                
                switch commandType {
                case .show_image:
                    self.showImage(cmd)
                break
                case .text_to_speech:
                    self.speachText(cmd)
                break
                case .drag_image:
                    self.dragImage(cmd)
                break
                case .blink_image:
                    self.blinkImage(cmd)
                break
                case .blink_all_images:
                    self.blinkAllImages(count: 3)
                break
                case .zoomout_image:
                    self.zoomImage(cmd)
                break
                case .make_bigger:
                    self.makeBigger(cmd)
                break
                case .make_image_normal:
                    self.makeNormal(cmd)
                break
                case .clear_screen:
                    self.clearCommand(cmd)
                break;
                default:
                
                break
            }
        }
        }
    }
    
    //MARK:- COMMANDS
    func clearCommand(_ cmd:Command) {
        
        self.imgViewLeft.image = nil
        self.imgViewRight.image = nil
        self.imgViewCenter.image = nil
        self.imgViewTop.image = nil
        self.imgViewBottom.image = nil
        
        self.imgViewLeft.layer.borderWidth = 0.0
        self.imgViewLeft.layer.borderColor = UIColor.clear.cgColor
        self.imgViewLeft.layer.cornerRadius = 0
        
        self.startAndRepeatCommands()
    }
    
    func showImage(_ cmd:Command) {
        
            let options = cmd.option
            
            let aligmentType = AligmentType.init(rawValue: options.position.lowercased())
            switch aligmentType {
            case .left:
                imgViewLeft.cmd = cmd
                
                if(options.image_border == "yes") {
                    self.imgViewLeft.layer.borderWidth = 2.0
                    self.imgViewLeft.layer.borderColor = UIColor.green.cgColor
                    self.imgViewLeft.layer.cornerRadius = 110
                }
                
                ImageDownloader.sharedInstance.downloadImage(urlString: cmd.value, imageView: self.imgViewLeft, callbackAfterNoofImages: 1, delegate: self)
                break
            case .right:
                imgViewRight.cmd = cmd
                ImageDownloader.sharedInstance.downloadImage(urlString: cmd.value, imageView: self.imgViewRight, callbackAfterNoofImages: 1, delegate: self)
                break
            case .top:
                imgViewTop.cmd = cmd
                ImageDownloader.sharedInstance.downloadImage(urlString: cmd.value, imageView: self.imgViewTop, callbackAfterNoofImages: 1, delegate: self)
                break;
            case .bottom:
                imgViewBottom.cmd = cmd
                ImageDownloader.sharedInstance.downloadImage(urlString: cmd.value, imageView: self.imgViewBottom, callbackAfterNoofImages: 1, delegate: self)
                break;
            case .center:
                imgViewCenter.cmd = cmd
                ImageDownloader.sharedInstance.downloadImage(urlString: cmd.value, imageView: self.imgViewCenter, callbackAfterNoofImages: 1, delegate: self)
                break;
            default:
//                imgViewLeft.cmd = cmd
//                ImageDownloader.sharedInstance.downloadImage(urlString: cmd.value, imageView: self.imgViewLeft, callbackAfterNoofImages: 1, delegate: self)
                break;
            }
    }
    
    func speachText(_ cmd:Command)
    {
        DispatchQueue.main.async {
                        
            if(self.speechArray.count == 0) {
                self.speechArray = cmd.value.components(separatedBy: "<br>")
            }
            
            if(self.speechArray.count > 0) {
                
                self.questionTitle.text = self.speechArray[0]
                SpeechManager.shared.speak(message:  self.speechArray[0], uttrenceRate:0.35)//AppConstant.speakUtteranceNormalRate.rawValue.floatValue
                self.speechArray.removeFirst()
            }
        }
    }
    
    func dragImage(_ cmd:Command) {
                
        DispatchQueue.main.async {
            
            self.imgViewHand.isHidden = false
            
            let dragType = DragType.init(rawValue: cmd.option.drag_direction.lowercased())
            let diffHand:CGFloat = 140
            switch dragType {
            case .right_to_left:
                self.imgViewRight.removeFromSuperview()
                self.viewContainer.addSubview(self.imgViewRight)
                self.imgViewHand.removeFromSuperview()
                self.viewContainer.addSubview(self.imgViewHand)
                self.imgViewHand.frame = CGRect(x: self.imgViewRight.frame.origin.x, y: self.imgViewRight.frame.origin.y+diffHand, width: self.imgViewRight.frame.size.width, height: self.imgViewRight.frame.size.height)
                let initialFrame:CGRect = self.imgViewRight.frame
                UIView.animate(withDuration: 3.0,
                                      delay: 0,
                                    options: [],
                                 animations: {
                                    self.imgViewRight.center = self.imgViewLeft.center
                                    self.imgViewHand.center  = CGPoint(x:self.imgViewLeft.center.x, y:self.imgViewLeft.center.y+diffHand)
                                 }, completion: {_ in
                                    self.imgViewHand.isHidden = true
                                    self.imgViewRight.frame = initialFrame
                                    self.startAndRepeatCommands()
                                 })
                break
            case .left_to_right:
                self.imgViewLeft.removeFromSuperview()
                self.viewContainer.addSubview(self.imgViewLeft)
                self.imgViewHand.removeFromSuperview()
                self.viewContainer.addSubview(self.imgViewHand)
                self.imgViewHand.frame = CGRect(x: self.imgViewLeft.frame.origin.x, y: self.imgViewLeft.frame.origin.y+diffHand, width: self.imgViewLeft.frame.size.width, height: self.imgViewLeft.frame.size.height)
                let initialFrame:CGRect = self.imgViewLeft.frame
                UIView.animate(withDuration: 3.0,
                                      delay: 0,
                                    options: [],
                                 animations: {
                                    self.imgViewLeft.frame = self.imgViewRight.frame
                                    self.imgViewHand.center  = self.imgViewRight.center
                                 }, completion: {_ in
                                    self.imgViewHand.isHidden = true
                                    self.imgViewLeft.frame = initialFrame
                                    self.startAndRepeatCommands()
                                 })
                break
            case .top_to_bottom:
                self.imgViewTop.removeFromSuperview()
                self.viewContainer.addSubview(self.imgViewTop)
                self.imgViewHand.removeFromSuperview()
                self.viewContainer.addSubview(self.imgViewHand)
                self.imgViewHand.frame = CGRect(x: self.imgViewTop.frame.origin.x, y: self.imgViewTop.frame.origin.y+diffHand, width: self.imgViewTop.frame.size.width, height: self.imgViewTop.frame.size.height)
                self.imgViewHand.frame = self.imgViewTop.frame
                UIView.animate(withDuration: 3.0,
                                      delay: 0,
                                    options: [],
                                 animations: {
                                    self.imgViewTop.frame = self.imgViewBottom.frame
                                    self.imgViewHand.center  = self.imgViewBottom.center
                                 }, completion: {_ in
                                    self.imgViewHand.isHidden = true
                                    self.startAndRepeatCommands()
                                 })
                break
            case .bottom_to_top:
                self.imgViewBottom.removeFromSuperview()
                self.viewContainer.addSubview(self.imgViewBottom)
                self.imgViewHand.removeFromSuperview()
                self.viewContainer.addSubview(self.imgViewHand)
                self.imgViewHand.frame = CGRect(x: self.imgViewBottom.frame.origin.x, y: self.imgViewBottom.frame.origin.y+diffHand, width: self.imgViewBottom.frame.size.width, height: self.imgViewBottom.frame.size.height)
                self.imgViewHand.frame = self.imgViewBottom.frame
                UIView.animate(withDuration: 3.0,
                                      delay: 0,
                                    options: [],
                                 animations: {
                                    self.imgViewBottom.frame = self.imgViewTop.frame
                                    self.imgViewHand.center  = self.imgViewTop.center
                                 }, completion: {_ in
                                    self.imgViewHand.isHidden = true
                                    self.startAndRepeatCommands()
                                 })
                break
            default:
                break;
            }
        }
    }
    
    //MARK:- ZOOM
    func zoomImage(_ cmd:Command) {
        DispatchQueue.main.async {
            if(self.imgViewLeft.image != nil) {
                if(cmd.id == self.imgViewLeft.cmd?.id) {
                    self.zoomOutAnimation(zoomView: self.imgViewLeft)
                }
            }
            if(self.imgViewRight.image != nil) {
                if(cmd.id == self.imgViewRight.cmd?.id) {
                    self.zoomOutAnimation(zoomView: self.imgViewRight)
                }
            }
            if(self.imgViewCenter.image != nil) {
                if(cmd.id == self.imgViewCenter.cmd?.id) {
                    self.zoomOutAnimation(zoomView: self.imgViewCenter)
                }
            }
            if(self.imgViewTop.image != nil) {
                if(cmd.id == self.imgViewTop.cmd?.id) {
                    self.zoomOutAnimation(zoomView: self.imgViewTop)
                }
            }
            if(self.imgViewBottom.image != nil) {
                if(cmd.id == self.imgViewBottom.cmd?.id) {
                    self.zoomOutAnimation(zoomView: self.imgViewBottom)
                }
            }
        }
    }
    
    func zoomOutAnimation(zoomView: CommandImageView?)
    {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
               // HERE
            zoomView!.transform = CGAffineTransform.identity.scaledBy(x: 2, y: 2) // Scale your image
         }) { (finished) in
             UIView.animate(withDuration: 1, animations: {
              zoomView!.transform = CGAffineTransform.identity // undo in 1 seconds
                self.startAndRepeatCommands()
           })
        }
    }
    
    func makeBigger(_ cmd:Command) {

        DispatchQueue.main.async {
            if(self.imgViewLeft.image != nil) {
                if(cmd.id == self.imgViewLeft.cmd?.id) {
                    self.makeBigger(zoomView: self.imgViewLeft, cmd:cmd)
                    self.imgViewRight.isHidden = true
                }
            }
            if(self.imgViewRight.image != nil) {
                if(cmd.id == self.imgViewRight.cmd?.id) {
                    self.makeBigger(zoomView: self.imgViewRight, cmd:cmd)
                    self.imgViewLeft.isHidden = true
                }
            }
            if(self.imgViewCenter.image != nil) {
                if(cmd.id == self.imgViewCenter.cmd?.id) {
                    self.makeBigger(zoomView: self.imgViewCenter, cmd:cmd)
                }
            }
            if(self.imgViewTop.image != nil) {
                if(cmd.id == self.imgViewTop.cmd?.id) {
                    self.makeBigger(zoomView: self.imgViewTop, cmd:cmd)
                }
            }
            if(self.imgViewBottom.image != nil) {
                if(cmd.id == self.imgViewBottom.cmd?.id) {
                    self.makeBigger(zoomView: self.imgViewBottom, cmd:cmd)
                }
            }
        }
    }
    
    func makeBigger(zoomView: CommandImageView?, cmd:Command)
    {
        zoomView!.removeFromSuperview()
        self.viewContainer!.addSubview(zoomView!)
                
        let initialW:CGFloat = zoomView!.frame.size.width

        let scaleSize:CGFloat = CGFloat(cmd.option.larger_scale.floatValue)
        let diffC:CGFloat = (initialW/2.0) * (scaleSize-1)
        
        UIView.animate(withDuration: 1.5, delay: 1.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
               // HERE
            zoomView!.transform = CGAffineTransform.identity.scaledBy(x: scaleSize, y: scaleSize) // Scale your image
            zoomView!.center = CGPoint(x: zoomView!.center.x+diffC, y: zoomView!.center.y)
         }) { (finished) in
             UIView.animate(withDuration: 1, animations: {
                self.startAndRepeatCommands()
           })
        }
        
    }
    
    func makeNormal(_ cmd:Command) {
        
        DispatchQueue.main.async {
            if(self.imgViewLeft.image != nil) {
                if(cmd.id == self.imgViewLeft.cmd?.id) {
                    self.makeNormal(zoomView: self.imgViewLeft)
                }
            }
            if(self.imgViewRight.image != nil) {
                if(cmd.id == self.imgViewRight.cmd?.id) {
                    self.makeNormal(zoomView: self.imgViewRight)
                }
            }
            if(self.imgViewCenter.image != nil) {
                if(cmd.id == self.imgViewCenter.cmd?.id) {
                    self.makeNormal(zoomView: self.imgViewCenter)
                }
            }
            if(self.imgViewTop.image != nil) {
                if(cmd.id == self.imgViewTop.cmd?.id) {
                    self.makeNormal(zoomView: self.imgViewTop)
                }
            }
            if(self.imgViewBottom.image != nil) {
                if(cmd.id == self.imgViewBottom.cmd?.id) {
                    self.makeNormal(zoomView: self.imgViewBottom)
                }
            }
        }
    }
    
    func makeNormal(zoomView: CommandImageView?)
    {
        let initialW:CGFloat = zoomView!.frame.size.width
        let xScale:CGFloat = zoomView!.transform.a;
        let originalW:CGFloat = initialW/xScale
        let diffScale:CGFloat = xScale-1
        
        let diffC:CGFloat = (originalW/2.0) * diffScale

//
//        let scaleSize:CGFloat = CGFloat(cmd.option.larger_scale.floatValue)

        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
               // HERE
            self.imgViewLeft.isHidden = false
            self.imgViewRight.isHidden = false
            zoomView!.transform = CGAffineTransform.identity.scaledBy(x: 1, y: 1) // Scale your image
            zoomView!.center = CGPoint(x: zoomView!.center.x-diffC, y: zoomView!.center.y)
         }) { (finished) in
             UIView.animate(withDuration: 1, animations: {
                
                self.startAndRepeatCommands()
           })
        }
    }
    
    
    //MARK:-
    func blinkImage(_ cmd:Command){
        
        DispatchQueue.main.async {
            if(self.imgViewLeft.image != nil) {
                if(cmd.id == self.imgViewLeft.cmd?.id) {
                    self.blink(blinkView: self.imgViewLeft)
                }
            }
            if(self.imgViewRight.image != nil) {
                if(cmd.id == self.imgViewRight.cmd?.id) {
                    self.blink(blinkView: self.imgViewRight)
                }
            }
            if(self.imgViewCenter.image != nil) {
                if(cmd.id == self.imgViewCenter.cmd?.id) {
                    self.blink(blinkView: self.imgViewCenter)
                }
            }
            if(self.imgViewTop.image != nil) {
                if(cmd.id == self.imgViewTop.cmd?.id) {
                    self.blink(blinkView: self.imgViewTop)
                }
            }
            if(self.imgViewBottom.image != nil) {
                if(cmd.id == self.imgViewBottom.cmd?.id) {
                    self.blink(blinkView: self.imgViewBottom)
                }
            }
        }
    }

    func blink(blinkView:CommandImageView, duration: TimeInterval = 0.5, delay: TimeInterval = 0.5, alpha: CGFloat = 0.0, repeatCount: Int = 10) {
        self.blink(blinkView, count: 3)
    }
        
    func blink(_ view: CommandImageView?, count: Int) {
        if count == 0 {
            self.startAndRepeatCommands()
            return
        }

        UIView.animate(withDuration: 0.4, animations: {
            view?.alpha = 0.4
        }) { [self] finished in

            UIView.animate(withDuration: 0.4, animations: {
                view?.alpha = 1.0
            }) { [self] finished in
                blink(view, count: count - 1)
            }
        }
    }
    
    
    func blinkAllImages(count: Int) {
        if count == 0 {
            self.startAndRepeatCommands()
            return
        }

        DispatchQueue.main.async {

        UIView.animate(withDuration: 0.4, animations: {
            self.imgViewLeft?.alpha = 0.4
            self.imgViewRight?.alpha = 0.4
        }) { [self] finished in

            UIView.animate(withDuration: 0.4, animations: {
                self.imgViewLeft?.alpha = 1.0
                self.imgViewRight?.alpha = 1.0
            }) { [self] finished in
                self.blinkAllImages(count: count - 1)
            }
        }
        }
    }
}



// MARK: Speech Manager Delegate Methods
extension AssessmentCommandViewController: SpeechManagerDelegate {
    func speechDidFinish(speechText:String) {
        self.questionTitle.text = ""
        self.isUserInteraction = true
        
        if(self.speechArray.count > 0) {
            self.questionTitle.text = self.speechArray[0]
            SpeechManager.shared.speak(message:  self.speechArray[0], uttrenceRate:0.35)//AppConstant.speakUtteranceNormalRate.rawValue.floatValue
            self.speechArray.removeFirst()
        }
        else {
            self.avatarImageView.isHidden = true
            self.startAndRepeatCommands()
        }
    }
    
    func speechDidStart(speechText:String) {
        self.isUserInteraction = false
        self.avatarImageView.isHidden = false

         if let type = Utility.getSpeechMessageType(text: speechText) {
                   switch type {
                   case .hurrayGoodJob:
                       self.avatarImageView.animatedImage =  hurrayGif
                       return
                   case .wrongAnswer:
                       self.avatarImageView.animatedImage =  wrongAnswerGif
                       return
                   default:
                       break
                   }
               }
               self.avatarImageView.animatedImage =  talkingGif
    }
}

extension AssessmentCommandViewController: ImageDownloaderDelegate {
    func finishDownloading() {
        DispatchQueue.main.async {
            self.setOriginalAvatar()
            self.startAndRepeatCommands()
        }
    }
}
extension AssessmentCommandViewController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        
        if Utility.isNetworkAvailable() {
            Utility.hideRetryView()
            SpeechManager.shared.setDelegate(delegate: self)
        }
    }
}


