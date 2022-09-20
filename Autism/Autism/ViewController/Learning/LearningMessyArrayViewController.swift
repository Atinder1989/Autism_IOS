//
//  LearningMessyArrayViewController.swift
//  Autism
//
//  Created by Dilip Saket on 02/09/22.
//  Copyright © 2022 IMPUTE. All rights reserved.
//

import UIKit
import FLAnimatedImage
import AVFoundation

class LearningMessyArrayViewController: UIViewController {

    private let messyArrayViewModel: LearningMessyArrayViewModel = LearningMessyArrayViewModel()
    
    @IBOutlet weak var imageViewRight:  UIImageView!
    @IBOutlet weak var imageViewCroos:  UIImageView!
    
    @IBOutlet weak var imageViewBG:  ImageViewWithID!
    
    @IBOutlet weak var imageView1:  ImageViewWithID!
    @IBOutlet weak var imageView2:  ImageViewWithID!
    @IBOutlet weak var imageView3:  ImageViewWithID!
    @IBOutlet weak var imageView4:  ImageViewWithID!
    @IBOutlet weak var imageView5:  ImageViewWithID!
    @IBOutlet weak var imageView6:  ImageViewWithID!
    @IBOutlet weak var imageView7:  ImageViewWithID!
    @IBOutlet weak var imageView8:  ImageViewWithID!
    @IBOutlet weak var imageView9:  ImageViewWithID!
    @IBOutlet weak var imageView10: ImageViewWithID!
    @IBOutlet weak var imageViewTouched: ImageViewWithID?

    var selectedObject:ImageViewWithID!
//    var currectObject:ImageViewWithID!
    
    private var initialFrame: CGRect?
    
    @IBOutlet weak var thumnailImageView: UIImageView!
    @IBOutlet weak var speechTitle: UILabel!
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var skipLearningButton: UIButton!
    @IBOutlet weak var bufferLoaderView: UIView!
    private var bufferLoaderTimer: Timer?

    
    private var program: LearningProgramModel!
    private var skillDomainId: String!
    private var command_array: [ScriptCommandInfo] = []
    var questionId = ""

    var correct_option = "0"
    
    private var imageList = [AnimationImageModel]() {
        didSet{
            DispatchQueue.main.async {
//                self.imagesCollectionView.reloadData()
            }
        }
    }

    private var isImagesDownloaded = false
    private var isChildAction = false
    private var videoItem: VideoItem?
    private var isChildActionCompleted = false {
        didSet {
            if isChildActionCompleted {
                DispatchQueue.main.async {
                    self.messyArrayViewModel.calculateChildAction(state: self.isChildActionCompleted, touch: self.isTouch)
                }
            }
        }
    }
    private var selectedIndex = -1 {
        didSet {
            DispatchQueue.main.async {
//                self.imagesCollectionView.reloadData()
            }
        }
    }
    private var thumbnailImage: UIImage?
    private var videoFinishTimer: Timer? = nil
    private var videoFinishWaitingTime = 0

    
    var downloaded10Images:Bool = false
    var wh:CGFloat = 160.0
    
    private var isTouch = false
    var isFromViewdidLoad:Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()

        self.customSetting()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFromViewdidLoad {
            isFromViewdidLoad = false
            
            if self.command_array.count == 0 {
                self.messyArrayViewModel.fetchLearningSolidQuestionCommands(skillDomainId: self.skillDomainId, program: self.program)
                if(UIDevice.current.userInterfaceIdiom != .pad) {
                    thumnailImageView.contentMode = .scaleAspectFit
                }
            } else {
                self.messyArrayViewModel.setScriptResponse(command_array: command_array, questionid: questionId,program: program,skillDomainId: skillDomainId)
            }
        }
    }

    func setData(program:LearningProgramModel, skillDomainId:String,command_array: [ScriptCommandInfo],questionId:String) {
        
        self.listenModelClosures()
        self.program = program
        self.skillDomainId = skillDomainId
        self.questionId = questionId
        self.command_array = command_array
    }
    
    private func customSetting() {
        
        imageViewBG.alpha = 0.9
        imageViewBG.backgroundColor = .clear
        imageViewBG.isHidden = false
    }

    private func initializeFilledImageView() {
        
        if(program.label_code != .mathematics) {
            self.initializeTheFramesLeanier()
        } else {
            self.initializeTheFrames()
        }
        
        if(self.imageList.count > 0) {
            imageView1.aModel = self.imageList[0]
            ImageDownloader.sharedInstance.downloadImage(urlString:  self.imageList[0].url, imageView: imageView1, callbackAfterNoofImages: self.imageList.count, delegate: self)
        }

        if(self.imageList.count > 1) {
            imageView2.aModel = self.imageList[1]
            ImageDownloader.sharedInstance.downloadImage(urlString: self.imageList[1].url, imageView: imageView2, callbackAfterNoofImages: self.imageList.count, delegate: self)
        }
        
        if(self.imageList.count > 2) {
            imageView3.aModel = self.imageList[2]
            ImageDownloader.sharedInstance.downloadImage(urlString: self.imageList[2].url, imageView: imageView3, callbackAfterNoofImages: self.imageList.count, delegate: self)
        }
        if(self.imageList.count > 3) {
            imageView4.aModel = self.imageList[3]
            ImageDownloader.sharedInstance.downloadImage(urlString:  self.imageList[3].url, imageView: imageView4, callbackAfterNoofImages: self.imageList.count, delegate: self)
        }
        if(self.imageList.count > 4) {
            imageView5.aModel = self.imageList[4]
            ImageDownloader.sharedInstance.downloadImage(urlString: self.imageList[4].url, imageView: imageView5, callbackAfterNoofImages: self.imageList.count, delegate: self)
        }
        if(self.imageList.count > 5) {
            imageView6.aModel = self.imageList[5]
            ImageDownloader.sharedInstance.downloadImage(urlString: self.imageList[5].url, imageView: imageView6, callbackAfterNoofImages: self.imageList.count, delegate: self)
        }
        if(self.imageList.count > 6) {
            imageView7.aModel = self.imageList[6]
            ImageDownloader.sharedInstance.downloadImage(urlString: self.imageList[6].url, imageView: imageView7, callbackAfterNoofImages: self.imageList.count, delegate: self)
        }
        if(self.imageList.count > 7) {
            imageView8.aModel = self.imageList[7]
            ImageDownloader.sharedInstance.downloadImage(urlString: self.imageList[7].url, imageView: imageView8, callbackAfterNoofImages: self.imageList.count, delegate: self)
        }
        if(self.imageList.count > 8) {
            imageView9.aModel = self.imageList[8]
            ImageDownloader.sharedInstance.downloadImage(urlString: self.imageList[8].url, imageView: imageView9, callbackAfterNoofImages: self.imageList.count, delegate: self)
        }
        if(self.imageList.count > 9) {
            imageView10.aModel = self.imageList[9]
            ImageDownloader.sharedInstance.downloadImage(urlString: self.imageList[9].url, imageView: imageView10, callbackAfterNoofImages: self.imageList.count, delegate: self)
        }

        if(program.label_code != .lr_messyarray_touch) {
            self.addPanGesture()
        }
    }
    
    func initializeTheFrames() {
        
        let screenW:CGFloat = UIScreen.main.bounds.width
        let screenH:CGFloat = UIScreen.main.bounds.height

        
        var y:CGFloat = 300
        
        var ySpace:CGFloat = 20.0
        var xSpace:CGFloat = (screenW-(5*wh))/6.0
        var xRef:CGFloat = xSpace
        
        
        var yRef:CGFloat = y+wh+ySpace

        if(UIDevice.current.userInterfaceIdiom != .pad) {
            y = 160
            wh = 70
            
            ySpace = 10
            xSpace = (screenW-(5*wh))/6.0
            
            xRef = xSpace
            yRef = screenH-safeAreaBottom-100//y+wh+ySpace
        }

        let noOfImages:Int = self.imageList.count
        
        if(noOfImages < 4) {
            imageView1.frame = CGRect(x: xRef, y: yRef, width: wh, height: wh)
            xRef = xRef+wh+xSpace
            
            xRef = xRef+wh+xSpace
            imageView3.frame = CGRect(x: xRef, y: yRef-ySpace-ySpace-(wh/2.0), width: wh, height: wh)
            xRef = xRef+wh+xSpace
            
            xRef = xRef+wh+xSpace
            imageView2.frame = CGRect(x: xRef, y: yRef, width: wh, height: wh)
            xRef = xRef+wh+xSpace

        } else if(noOfImages == 4) {
            imageView1.frame = CGRect(x: xRef, y: yRef, width: wh, height: wh)
            xRef = xRef+wh+xSpace
            imageView3.frame = CGRect(x: xRef, y: y, width: wh, height: wh)
            xRef = xRef+wh+xSpace
            //imageView5.frame = CGRect(x: xRef, y: yRef-ySpace-ySpace-(wh/2.0), width: wh, height: wh)
            xRef = xRef+wh+xSpace
            imageView4.frame = CGRect(x: xRef, y: yRef, width: wh, height: wh)
            xRef = xRef+wh+xSpace
            imageView2.frame = CGRect(x: xRef, y: y, width: wh, height: wh)
            xRef = xRef+wh+xSpace

        } else if(noOfImages > 4) {
            imageView1.frame = CGRect(x: xRef, y: yRef, width: wh, height: wh)
            xRef = xRef+wh+xSpace
            imageView4.frame = CGRect(x: xRef, y: y, width: wh, height: wh)
            xRef = xRef+wh+xSpace
            imageView3.frame = CGRect(x: xRef, y: yRef-ySpace-ySpace-(wh/2.0), width: wh, height: wh)
            xRef = xRef+wh+xSpace
            imageView5.frame = CGRect(x: xRef, y: y, width: wh, height: wh)
            xRef = xRef+wh+xSpace
            imageView2.frame = CGRect(x: xRef, y: yRef, width: wh, height: wh)
            xRef = xRef+wh+xSpace
        }
        
        yRef = y
        xRef = xSpace
        
        if(noOfImages == 6) {
            xRef = xRef+wh+xSpace
            xRef = xRef+wh+xSpace
            
            imageView6.frame = CGRect(x: xRef, y: yRef+ySpace+wh+(wh/2.0), width: wh, height: wh)
        } else if(noOfImages == 7) {
            imageView9.frame = CGRect(x: xRef, y: yRef-ySpace-(wh/2.0), width: wh, height: wh)
            xRef = xRef+wh+xSpace
            imageView6.frame = CGRect(x: xRef, y: yRef+ySpace+wh+(wh/2.0), width: wh, height: wh)
            xRef = xRef+wh+xSpace
            imageView8.frame = CGRect(x: xRef, y: yRef+ySpace+wh+(wh/2.0)+ySpace, width: wh, height: wh)
            xRef = xRef+wh+xSpace
            imageView7.frame = CGRect(x: xRef, y: yRef+ySpace+wh+(wh/2.0), width: wh, height: wh)
            xRef = xRef+wh+xSpace
            imageView10.frame = CGRect(x: xRef, y: yRef-ySpace-(wh/2.0), width: wh, height: wh)
            xRef = xRef+wh+xSpace
        } else if(noOfImages == 9) {
            imageView8.frame = CGRect(x: xRef, y: yRef-ySpace-(wh/2.0), width: wh, height: wh)
            xRef = xRef+wh+xSpace
            imageView6.frame = CGRect(x: xRef, y: yRef+ySpace+wh+(wh/2.0), width: wh, height: wh)
            xRef = xRef+wh+xSpace
            //imageView8.frame = CGRect(x: xRef, y: yRef+ySpace+wh+(wh/2.0)+ySpace, width: wh, height: wh)
            xRef = xRef+wh+xSpace
            imageView7.frame = CGRect(x: xRef, y: yRef+ySpace+wh+(wh/2.0), width: wh, height: wh)
            xRef = xRef+wh+xSpace
            imageView9.frame = CGRect(x: xRef, y: yRef-ySpace-(wh/2.0), width: wh, height: wh)
            xRef = xRef+wh+xSpace

        } else {
            imageView9.frame = CGRect(x: xRef, y: yRef-ySpace-(wh/2.0), width: wh, height: wh)
            xRef = xRef+wh+xSpace
            imageView6.frame = CGRect(x: xRef, y: yRef+ySpace+wh+(wh/2.0), width: wh, height: wh)
            xRef = xRef+wh+xSpace
            imageView8.frame = CGRect(x: xRef, y: yRef+ySpace+wh+(wh/2.0)+ySpace, width: wh, height: wh)
            xRef = xRef+wh+xSpace
            imageView7.frame = CGRect(x: xRef, y: yRef+ySpace+wh+(wh/2.0), width: wh, height: wh)
            xRef = xRef+wh+xSpace
            imageView10.frame = CGRect(x: xRef, y: yRef-ySpace-(wh/2.0), width: wh, height: wh)
            xRef = xRef+wh+xSpace
        }
    }
    
    func initializeTheFramesLeanier() {
        
        let screenW:CGFloat = UIScreen.main.bounds.width
        let screenH:CGFloat = UIScreen.main.bounds.height

        var wh:CGFloat = 180.0
        var y:CGFloat = 300
        
        var ySapce:CGFloat = 20.0
        var xSpace:CGFloat = (screenW-(5*wh))/6.0
        var xRef:CGFloat = xSpace
        
        
        var yRef:CGFloat = y+wh+ySapce

        if(UIDevice.current.userInterfaceIdiom != .pad) {
//            y = screenH-safeAreaBottom-100
            y = 160
            wh = 70
            
            ySapce = 10
            xSpace = (screenW-(5*wh))/6.0
            
            xRef = xSpace
            yRef = screenH-safeAreaBottom-100//y+wh+ySapce
        }
        
        let noOfImages:Int = self.imageList.count

        if(noOfImages == 4) {
            xSpace = (screenW-(CGFloat(noOfImages)*wh))/CGFloat(noOfImages+1)
            xRef = xSpace
            
            imageView1.frame = CGRect(x: xRef, y: yRef, width: wh, height: wh)
            xRef = xRef+wh+xSpace
            imageView2.frame = CGRect(x: xRef, y: yRef, width: wh, height: wh)
            xRef = xRef+wh+xSpace
            imageView3.frame = CGRect(x: xRef, y: yRef, width: wh, height: wh)
            xRef = xRef+wh+xSpace
            imageView4.frame = CGRect(x: xRef, y: yRef, width: wh, height: wh)
            xRef = xRef+wh+xSpace
            return
        }
    
        //if(noOfImages == 5) {
            imageView1.frame = CGRect(x: xRef, y: yRef, width: wh, height: wh)
            xRef = xRef+wh+xSpace
            imageView4.frame = CGRect(x: xRef, y: yRef, width: wh, height: wh)
            xRef = xRef+wh+xSpace
            imageView3.frame = CGRect(x: xRef, y: yRef, width: wh, height: wh)
            xRef = xRef+wh+xSpace
            imageView5.frame = CGRect(x: xRef, y: yRef, width: wh, height: wh)
            xRef = xRef+wh+xSpace
            imageView2.frame = CGRect(x: xRef, y: yRef, width: wh, height: wh)
            xRef = xRef+wh+xSpace
        //}
        yRef = y
        xRef = xSpace
        
        if(noOfImages == 6) {
            xRef = xRef+wh+xSpace
            xRef = xRef+wh+xSpace
            imageView6.frame = CGRect(x: xRef, y: yRef, width: wh, height: wh)
        } else if(noOfImages == 7) {
            xRef = xRef+wh+xSpace
            imageView6.frame = CGRect(x: xRef, y: yRef, width: wh, height: wh)
            xRef = xRef+wh+xSpace
            xRef = xRef+wh+xSpace
            imageView7.frame = CGRect(x: xRef, y: yRef, width: wh, height: wh)
            xRef = xRef+wh+xSpace
        } else if(noOfImages == 8) {
            xRef = xRef+wh+xSpace
            imageView6.frame = CGRect(x: xRef, y: yRef, width: wh, height: wh)
            xRef = xRef+wh+xSpace
            imageView7.frame = CGRect(x: xRef, y: yRef, width: wh, height: wh)
            xRef = xRef+wh+xSpace
            imageView8.frame = CGRect(x: xRef, y: yRef, width: wh, height: wh)
        } else if(noOfImages == 9) {
            imageView6.frame = CGRect(x: xRef, y: yRef, width: wh, height: wh)
            xRef = xRef+wh+xSpace
            imageView7.frame = CGRect(x: xRef, y: yRef, width: wh, height: wh)
            xRef = xRef+wh+xSpace
            imageView10.frame = CGRect(x: xRef, y: yRef, width: wh, height: wh)
            xRef = xRef+wh+xSpace
            imageView8.frame = CGRect(x: xRef, y: yRef, width: wh, height: wh)
            xRef = xRef+wh+xSpace
            imageView9.frame = CGRect(x: xRef, y: yRef, width: wh, height: wh)
            xRef = xRef+wh+xSpace

        } else if(noOfImages == 10) {
            imageView6.frame = CGRect(x: xRef, y: yRef, width: wh, height: wh)
            xRef = xRef+wh+xSpace
            imageView9.frame = CGRect(x: xRef, y: yRef, width: wh, height: wh)
            xRef = xRef+wh+xSpace
            imageView8.frame = CGRect(x: xRef, y: yRef, width: wh, height: wh)
            xRef = xRef+wh+xSpace
            imageView10.frame = CGRect(x: xRef, y: yRef, width: wh, height: wh)
            xRef = xRef+wh+xSpace
            imageView7.frame = CGRect(x: xRef, y: yRef, width: wh, height: wh)
            xRef = xRef+wh+xSpace
        }

    }
    private func addPanGesture() {

        self.imageViewBG.isUserInteractionEnabled = true
        let gestureRecognizer0 = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        self.imageViewBG.addGestureRecognizer(gestureRecognizer0)
        
        if(self.imageList.count > 0) {
            let gestureRecognizer1 = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
            self.imageView1.addGestureRecognizer(gestureRecognizer1)
        }
        if(self.imageList.count > 1) {
            let gestureRecognizer2 = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
            self.imageView2.addGestureRecognizer(gestureRecognizer2)
        }
        if(self.imageList.count > 2) {
            let gestureRecognizer3 = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
            self.imageView3.addGestureRecognizer(gestureRecognizer3)
        }
        if(self.imageList.count > 3) {
            let gestureRecognizer4 = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
            self.imageView4.addGestureRecognizer(gestureRecognizer4)
        }
        if(self.imageList.count > 4) {
            let gestureRecognizer5 = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
            self.imageView5.addGestureRecognizer(gestureRecognizer5)
        }
        if(self.imageList.count > 5) {
            let gestureRecognizer6 = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
            self.imageView6.addGestureRecognizer(gestureRecognizer6)
        }
        if(self.imageList.count > 6) {
            let gestureRecognizer7 = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
            self.imageView7.addGestureRecognizer(gestureRecognizer7)
        }
        if(self.imageList.count > 7) {
            let gestureRecognizer8 = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
            self.imageView8.addGestureRecognizer(gestureRecognizer8)
        }
        if(self.imageList.count > 8) {
            let gestureRecognizer9 = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
            self.imageView9.addGestureRecognizer(gestureRecognizer9)
        }
        if(self.imageList.count > 9) {
            let gestureRecognizer10 = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
            self.imageView10.addGestureRecognizer(gestureRecognizer10)
        }
    }
    
    
    @IBAction func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
            
            case .began:
            if self.initialFrame == nil && selectedObject == nil {
                self.selectedObject = (gestureRecognizer.view as? ImageViewWithID)!
                self.initialFrame = self.selectedObject.frame

            }
            break
        case .changed:

            let currentFilledPattern:ImageViewWithID = (gestureRecognizer.view as? ImageViewWithID)!
            
            if(selectedObject != currentFilledPattern) {
                return
            }
            
            if self.initialFrame == nil && selectedObject == nil {
                return
            }
            let translation = gestureRecognizer.translation(in: self.view)
            self.selectedObject.center = CGPoint(x: gestureRecognizer.view!.center.x + translation.x, y: gestureRecognizer.view!.center.y + translation.y)
            gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
            break
        case .ended:
            
            let currentFilledImageView:ImageViewWithID = (gestureRecognizer.view as? ImageViewWithID)!
            
            if self.initialFrame == nil && selectedObject == nil {
                return
            }
            
            if(selectedObject != currentFilledImageView) {
                return
            }
            
            let dropLocation = gestureRecognizer.location(in: view)
            var isLocationExist = false
            
            if(self.correct_option == "1") {
                if(currentFilledImageView == imageView1) {
                    if imageViewBG.frame.contains(dropLocation) {
                        isLocationExist = true
                        self.handleValidDropLocation(filledImageView: currentFilledImageView, emptyImageView: imageViewBG)
                    }
                } else if(currentFilledImageView == imageViewBG) {
                    if imageView1.frame.contains(dropLocation) {
                        isLocationExist = true
                        self.handleValidDropLocation(filledImageView: currentFilledImageView, emptyImageView: imageView1)
                    }
                }
            } else if(self.correct_option == "2") {
                if(currentFilledImageView == imageView2) {
                    if imageViewBG.frame.contains(dropLocation) {
                        isLocationExist = true
                        self.handleValidDropLocation(filledImageView: currentFilledImageView, emptyImageView: imageViewBG)
                    }
                } else if(currentFilledImageView == imageViewBG) {
                    if imageView2.frame.contains(dropLocation) {
                        isLocationExist = true
                        self.handleValidDropLocation(filledImageView: currentFilledImageView, emptyImageView: imageView2)
                    }
                }
            } else if(self.correct_option == "3") {
                if(currentFilledImageView == imageView3) {
                    if imageViewBG.frame.contains(dropLocation) {
                        isLocationExist = true
                        self.handleValidDropLocation(filledImageView: currentFilledImageView, emptyImageView: imageViewBG)
                    }
                } else if(currentFilledImageView == imageViewBG) {
                    if imageView3.frame.contains(dropLocation) {
                        isLocationExist = true
                        self.handleValidDropLocation(filledImageView: currentFilledImageView, emptyImageView: imageView3)
                    }
                }
            } else if(self.correct_option == "4") {
                if(currentFilledImageView == imageView4) {
                    if imageViewBG.frame.contains(dropLocation) {
                        isLocationExist = true
                        self.handleValidDropLocation(filledImageView: currentFilledImageView, emptyImageView: imageViewBG)
                    }
                } else if(currentFilledImageView == imageViewBG) {
                    if imageView4.frame.contains(dropLocation) {
                        isLocationExist = true
                        self.handleValidDropLocation(filledImageView: currentFilledImageView, emptyImageView: imageView4)
                    }
                }
            } else if(self.correct_option == "5") {
                if(currentFilledImageView == imageView5) {
                    if imageViewBG.frame.contains(dropLocation) {
                        isLocationExist = true
                        self.handleValidDropLocation(filledImageView: currentFilledImageView, emptyImageView: imageViewBG)
                    }
                } else if(currentFilledImageView == imageViewBG) {
                    if imageView5.frame.contains(dropLocation) {
                        isLocationExist = true
                        self.handleValidDropLocation(filledImageView: currentFilledImageView, emptyImageView: imageView5)
                    }
                }
            } else if(self.correct_option == "6") {
                if(currentFilledImageView == imageView6) {
                    if imageViewBG.frame.contains(dropLocation) {
                        isLocationExist = true
                        self.handleValidDropLocation(filledImageView: currentFilledImageView, emptyImageView: imageViewBG)
                    }
                } else if(currentFilledImageView == imageViewBG) {
                    if imageView6.frame.contains(dropLocation) {
                        isLocationExist = true
                        self.handleValidDropLocation(filledImageView: currentFilledImageView, emptyImageView: imageView6)
                    }
                }
            } else if(self.correct_option == "7") {
                if(currentFilledImageView == imageView7) {
                    if imageViewBG.frame.contains(dropLocation) {
                        isLocationExist = true
                        self.handleValidDropLocation(filledImageView: currentFilledImageView, emptyImageView: imageViewBG)
                    }
                } else if(currentFilledImageView == imageViewBG) {
                    if imageView7.frame.contains(dropLocation) {
                        isLocationExist = true
                        self.handleValidDropLocation(filledImageView: currentFilledImageView, emptyImageView: imageView7)
                    }
                }
            } else if(self.correct_option == "8") {
                if(currentFilledImageView == imageView8) {
                    if imageViewBG.frame.contains(dropLocation) {
                        isLocationExist = true
                        self.handleValidDropLocation(filledImageView: currentFilledImageView, emptyImageView: imageViewBG)
                    }
                } else if(currentFilledImageView == imageViewBG) {
                    if imageView8.frame.contains(dropLocation) {
                        isLocationExist = true
                        self.handleValidDropLocation(filledImageView: currentFilledImageView, emptyImageView: imageView8)
                    }
                }
            } else if(self.correct_option == "9") {
                if(currentFilledImageView == imageView9) {
                    if imageViewBG.frame.contains(dropLocation) {
                        isLocationExist = true
                        self.handleValidDropLocation(filledImageView: currentFilledImageView, emptyImageView: imageViewBG)
                    }
                } else if(currentFilledImageView == imageViewBG) {
                    if imageView9.frame.contains(dropLocation) {
                        isLocationExist = true
                        self.handleValidDropLocation(filledImageView: currentFilledImageView, emptyImageView: imageView9)
                    }
                }
            } else if(self.correct_option == "10") {
                if(currentFilledImageView == imageView10) {
                    if imageViewBG.frame.contains(dropLocation) {
                        isLocationExist = true
                        self.handleValidDropLocation(filledImageView: currentFilledImageView, emptyImageView: imageViewBG)
                    }
                } else if(currentFilledImageView == imageViewBG) {
                    if imageView10.frame.contains(dropLocation) {
                        isLocationExist = true
                        self.handleValidDropLocation(filledImageView: currentFilledImageView, emptyImageView: imageView10)
                    }
                }
            }
            
            if !isLocationExist {
                self.handleInvalidDropLocation(currentImageView:currentFilledImageView)
            }
            
            break
        default:
            break
        }
    }
    
    private func handleInvalidDropLocation(currentImageView:ImageViewWithID){
        DispatchQueue.main.async {
            if let frame = self.initialFrame {
                self.selectedObject.frame = frame
                self.initialFrame = nil
                self.selectedObject = nil
            }
            self.isChildActionCompleted = false
        }
    }
    
    private func handleValidDropLocation(filledImageView:ImageViewWithID,emptyImageView:ImageViewWithID){
        DispatchQueue.main.async {
            emptyImageView.image = filledImageView.image
            filledImageView.image = nil
            filledImageView.isHidden = true
            
            if let frame = self.initialFrame {
                self.selectedObject.frame = frame
                self.initialFrame = nil
                self.selectedObject = nil
            }
            self.isChildActionCompleted = true

            SpeechManager.shared.speak(message: SpeechMessage.hurrayGoodJob.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        touchOnEmptyScreenCount += 1
        
        if let touch = touches.first {
            let position = touch.location(in: view)
            print(position)

           if(imageView1.frame.contains(position)) {
               imageViewTouched = imageView1
           } else if(imageView2.frame.contains(position)) {
               imageViewTouched = imageView2
           } else if(imageView3.frame.contains(position)) {
               imageViewTouched = imageView3
           } else if(imageView4.frame.contains(position)) {
                imageViewTouched = imageView4
           } else if(imageView5.frame.contains(position)) {
                imageViewTouched = imageView5
           } else if(imageView6.frame.contains(position)) {
                imageViewTouched = imageView6
           } else if(imageView7.frame.contains(position)) {
                imageViewTouched = imageView7
           } else if(imageView8.frame.contains(position)) {
                imageViewTouched = imageView8
           } else if(imageView9.frame.contains(position)) {
                imageViewTouched = imageView9
           } else if(imageView10.frame.contains(position)) {
                imageViewTouched = imageView10
           } else {
                imageViewTouched = nil
           }
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if(program.label_code != .lr_messyarray_touch) {
            return
        }

        if let touch = touches.first {
            self.isTouch = true
                let position = touch.location(in: view)
                print(position)
            if(imageViewTouched != nil) {
                if(self.imageViewTouched!.frame.contains(position)) {
                                        
                    if(self.imageViewTouched?.aModel?.correct_option == ScriptCommandOptionType.actiontrue) {
                        self.isChildActionCompleted = true

                        imageViewRight.isHidden = false
                        imageViewCroos.isHidden = true
                        SpeechManager.shared.speak(message: SpeechMessage.hurrayGoodJob.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
                    } else {
                        self.isChildActionCompleted = false
                        if(UIDevice.current.userInterfaceIdiom != .pad) {
                            self.imageViewCroos.frame = CGRect(x: imageViewTouched!.center.x+(wh/2.0)-24, y: imageViewTouched!.center.y+(wh/2.0)-24, width: 24, height: 24)
                        } else {
                            self.imageViewCroos.frame = CGRect(x: imageViewTouched!.center.x+(wh/2.0)-34, y: imageViewTouched!.center.y+(wh/2.0)-34, width: 34, height: 34)
                        }

                        imageViewRight.isHidden = false
                        imageViewCroos.isHidden = false
                    }
                }
            }
        }
    }

}

//MARK: - Private
extension LearningMessyArrayViewController {
    
    private func moveToNextCommand() {
       // self.view.isUserInteractionEnabled = false
        self.stopTimer()
        self.restartButton.isHidden = true
        self.nextButton.isHidden = true
        NotificationCenter.default.removeObserver(NSNotification.Name.AVPlayerItemDidPlayToEndTime)
        self.playerView.isHidden = true
        self.thumnailImageView.isHidden = true
        self.messyArrayViewModel.updateCurrentCommandIndex()
    }
        
    private func listenModelClosures() {
        self.messyArrayViewModel.videoFinishedClosure = { [weak self] in
            DispatchQueue.main.async {
                if let this = self {
                this.videoFinished()
                }
            }
        }
        
        self.messyArrayViewModel.bufferLoaderClosure = {
            DispatchQueue.main.async {
                if self.messyArrayViewModel.isBufferLoader {
                    self.showBufferLoader()
                } else {
                    self.hideBufferLoader()
                }
            }
        }
        
       self.messyArrayViewModel.clearScreenClosure = {
             DispatchQueue.main.async {
                 self.customSetting()
             }
       }
               
       self.messyArrayViewModel.noNetWorkClosure = {
           Utility.showRetryView(delegate: self)
       }
        
       self.messyArrayViewModel.clearSpeechTextClosure = {
            DispatchQueue.main.async {
                self.speechTitle.text = ""
            }
       }
        
       self.messyArrayViewModel.showSpeechTextClosure = { text in
            DispatchQueue.main.async {
                self.speechTitle.text = text
            }
       }
       
       self.messyArrayViewModel.showVideoClosure = { urlString in
           DispatchQueue.main.async {
            self.customSetting()
            self.addPlayer(urlString: urlString)
           }
       }
        
        self.messyArrayViewModel.childActionStateClosure = { state in
             DispatchQueue.main.async {
                //self.view.isUserInteractionEnabled = state
                self.isChildAction = state
             }
        }
       
       self.messyArrayViewModel.showImagesClosure = {commandInfo in
           DispatchQueue.main.async { [self] in
                var array : [AnimationImageModel] = []
                if let option = commandInfo.option {
                    let correctOption = (Int(option.correct_option) ?? 0) - 1
                    self.correct_option = option.correct_option
                    
                    for (index, element) in commandInfo.valueList.enumerated() {
                        var scModel = AnimationImageModel.init()
                        scModel.url = element
                        scModel.value_id = commandInfo.value_idList[index]
                        
                        if index == correctOption {
                            scModel.correct_option = ScriptCommandOptionType.actiontrue
                            ImageDownloader.sharedInstance.downloadImage(urlString:  scModel.url, imageView: self.imageViewBG, callbackAfterNoofImages: 1, delegate: nil)
                            
                        } else {
                            scModel.correct_option = ScriptCommandOptionType.actionfalse
                        }
                        scModel.isShowFinger = false
                        scModel.isShowTapFingerAnimation = false
                        scModel.isCircleShape = option.show_circle
                        array.append(scModel)
                    }
                }
               
                let screenWidth:CGFloat = max(UIScreen.main.bounds.height, UIScreen.main.bounds.width)
                let screenHeight:CGFloat = max(UIScreen.main.bounds.height, UIScreen.main.bounds.height)

                if(UIDevice.current.userInterfaceIdiom != .pad) {
                                       
                } else {
                                      
                }

                self.imageList.removeAll()
                self.imageList = array
                self.initializeFilledImageView()
                //self.messyArrayViewModel.updateCurrentCommandIndex()
            }
       }
        self.messyArrayViewModel.showFingerClosure = {
             DispatchQueue.main.async {
                self.selectedIndex = -1
                self.updateImageListWithShowFinger()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.resetImageList()
                }
             }
        }
        self.messyArrayViewModel.showTapFingerAnimationClosure = {
             DispatchQueue.main.async {
                self.updateImageListWithShowTapFingerAnimation()
                let deadlineTime = DispatchTime.now() + .seconds(3)
                DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                    self.messyArrayViewModel.calculateChildAction(state: false, touch: self.isTouch)
                    self.messyArrayViewModel.updateCurrentCommandIndex()
                }
             }
        }
        
        self.messyArrayViewModel.blinkImageClosure = { questionInfo in
            
            DispatchQueue.main.async {
                if let option = questionInfo.option {
                    if(self.correct_option == "1") {
                        self.blinkImage(count: Int(option.time_in_second) ?? Int(learningAnimationDuration), imageView: self.imageView1)
                    } else if(self.correct_option == "2") {
                        self.blinkImage(count: Int(option.time_in_second) ?? Int(learningAnimationDuration), imageView: self.imageView2)
                    } else if(self.correct_option == "3") {
                        self.blinkImage(count: Int(option.time_in_second) ?? Int(learningAnimationDuration), imageView: self.imageView3)
                    } else if(self.correct_option == "4") {
                        self.blinkImage(count: Int(option.time_in_second) ?? Int(learningAnimationDuration), imageView: self.imageView4)
                    } else if(self.correct_option == "5") {
                        self.blinkImage(count: Int(option.time_in_second) ?? Int(learningAnimationDuration), imageView: self.imageView5)
                    } else if(self.correct_option == "6") {
                        self.blinkImage(count: Int(option.time_in_second) ?? Int(learningAnimationDuration), imageView: self.imageView6)
                    } else if(self.correct_option == "7") {
                        self.blinkImage(count: Int(option.time_in_second) ?? Int(learningAnimationDuration), imageView: self.imageView7)
                    } else if(self.correct_option == "8") {
                        self.blinkImage(count: Int(option.time_in_second) ?? Int(learningAnimationDuration), imageView: self.imageView8)
                    } else if(self.correct_option == "9") {
                        self.blinkImage(count: Int(option.time_in_second) ?? Int(learningAnimationDuration), imageView: self.imageView9)
                    } else if(self.correct_option == "10") {
                        self.blinkImage(count: Int(option.time_in_second) ?? Int(learningAnimationDuration), imageView: self.imageView10)
                    }
                }
            }
        }

    }
    
    private func blinkImage(count:Int,imageView:UIImageView) {
        if count == 0 {
            self.messyArrayViewModel.updateCommandIndex()
            return
        }
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 1, animations: {
                    imageView.alpha = 0.2
                    self.imageViewBG.alpha = 0.2
                }) { [weak self] finished in
                    if let this = self {
                        imageView.alpha = 1
                        self!.imageViewBG.alpha = 1
                        this.blinkImage(count: count - 1,imageView:imageView)
                    }
                }
        }
    }
       
    private func updateImageListWithShowFinger() {
        var array : [AnimationImageModel] = []
        for element in self.imageList {
            var scModel = element
            if element.correct_option == ScriptCommandOptionType.actiontrue {
                scModel.isShowFinger = true
            } else {
                scModel.isShowFinger = false
            }
            array.append(scModel)
        }
        self.imageList.removeAll()
        self.imageList = array
    }
    
    private func updateImageListWithBlinkImageAnimation() {
        var array : [AnimationImageModel] = []
        for element in self.imageList {
            var scModel = element
            if element.correct_option == ScriptCommandOptionType.actiontrue {
                scModel.isBlink = true
            } else {
                scModel.isBlink = false
            }
            array.append(scModel)
        }
        self.imageList.removeAll()
        self.imageList = array
    }

    private func updateImageListWithShowTapFingerAnimation() {
        var array : [AnimationImageModel] = []
        for element in self.imageList {
            var scModel = element
            if element.correct_option == ScriptCommandOptionType.actiontrue {
                scModel.isShowTapFingerAnimation = true
                scModel.isShowFinger = true
            } else {
                scModel.isShowTapFingerAnimation = false
                scModel.isShowFinger = false
            }
            array.append(scModel)
        }
        self.imageList.removeAll()
        self.imageList = array
    }
    
    private func resetImageList() {
        var array : [AnimationImageModel] = []
        for element in self.imageList {
            var scModel = element
            scModel.isShowFinger = false
            array.append(scModel)
        }
        self.imageList.removeAll()
        self.imageList = array
    }
    
    private func addPlayer(urlString:String) {
        let string = ServiceHelper.baseURL.getMediaBaseUrl() + urlString
        if let playerController = messyArrayViewModel.playerController {
            if let avplayerController = playerController.avPlayerController {
                self.playerView.isHidden = false
                self.playerView.addSubview(avplayerController.view)
                avplayerController.view.frame = self.playerView.bounds
                self.videoItem = VideoItem.init(url: string)
                self.playVideo()
                self.thumbnailImage = Utility.getThumbnailImage(urlString: string, time: CMTimeMake(value: 5, timescale: 2))
            }
        }
        
    }
    
    private func showBufferLoader() {
        self.playerView.bringSubviewToFront(self.bufferLoaderView)
        self.bufferLoaderView.isHidden = false
        if let timer = self.bufferLoaderTimer {
            timer.invalidate()
        }
        self.bufferLoaderTimer = Timer.scheduledTimer(timeInterval: TimeInterval(0.2),
                        target: self,
                        selector: #selector(self.startBufferLoaderAnimation),
                        userInfo: nil, repeats: true)
    }

    @objc private func startBufferLoaderAnimation () {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {() -> Void in
                self.bufferLoaderView.transform = self.bufferLoaderView.transform.rotated(by: CGFloat(Double.pi))
            }, completion: {(_ finished: Bool) -> Void in
            })
        }
    }

    private func hideBufferLoader() {
        if let timer = self.bufferLoaderTimer {
            self.bufferLoaderView.isHidden = true
            timer.invalidate()
            self.bufferLoaderTimer = nil
        }
    }
    
    
    private func playVideo() {
        if let item = self.videoItem {
        messyArrayViewModel.playVideo(item: item)
        self.nextButton.isHidden = true
        self.restartButton.isHidden = true
        self.thumnailImageView.isHidden = true
        }
    }
    
    func stopPlayer() {
        self.messyArrayViewModel.stopVideo()
    }
    
    private func videoFinished() {
        self.restartButton.isHidden = false
        self.nextButton.isHidden = false
        if let image = self.thumbnailImage {
            self.thumnailImageView.image = image
            self.thumnailImageView.isHidden = false
        }
        self.initializeTimer()
    }
    
    private func initializeTimer() {
        videoFinishTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(calculateTimeTaken), userInfo: nil, repeats: true)
    }
    
    @objc private func calculateTimeTaken()  {
        videoFinishWaitingTime += 1
        print("Video Finish Timer Start == \(videoFinishWaitingTime)")
        if let info = self.messyArrayViewModel.getCurrentCommandInfo(),let option = info.option {
            let time = Int(option.switch_command_time) ?? 0
            if self.videoFinishWaitingTime >= time  {
                self.moveToNextCommand()
            }
        }
    }
    
    private func stopTimer() {
        if let timer = self.videoFinishTimer {
            print("Video Timer Stop ======== ")
            timer.invalidate()
            self.videoFinishTimer = nil
            self.videoFinishWaitingTime = 0
        }
    }

 }

extension LearningMessyArrayViewController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        if Utility.isNetworkAvailable() {
            Utility.hideRetryView()
        }
    }
}


extension LearningMessyArrayViewController: ImageDownloaderDelegate {
    func finishDownloading() {
        if !isImagesDownloaded {
            self.isImagesDownloaded = true
            self.messyArrayViewModel.updateCurrentCommandIndex()
        }
    }
}
