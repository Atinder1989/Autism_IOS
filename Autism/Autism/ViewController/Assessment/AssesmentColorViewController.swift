//
//  AssesmentColorViewController.swift
//  Autism
//
//  Created by mac on 07/07/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit
import Sketch
import FLAnimatedImage

class AssesmentColorViewController: UIViewController ,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate, ColourPadViewDelegate, StampViewDelegate {
    
    private weak var delegate: AssessmentSubmitDelegate?
    private var prevPoint1: CGPoint!
    private var prevPoint2: CGPoint!
    private var lastPoint:CGPoint!
    private var coloringInfo: ColoringQuestionInfo!
    private var timeTakenToSolve = 0
    private let colorViewModel = AssesmentColorViewModel()
    private var skipQuestion = false
    private var questionState: QuestionState = .inProgress

    @IBOutlet weak var avatarImageView: FLAnimatedImageView!
    @IBOutlet weak var collectionOption: UICollectionView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var sketchView: SketchView!
    @IBOutlet weak var lblTitle: UILabel!
    private var isUserInteraction = false {
                   didSet {
                       self.view.isUserInteractionEnabled = isUserInteraction
                   }
    }

    var arrayOption = ["pen","palette", "undo", "redo","samp", "clear"]
    var viewColourPad:ColourPadView!
    var viewStamp:StampView!
    private var apiDataState: APIDataState = .notCall
    private var touchOnEmptyScreenCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.apiDataState = .dataFetched
        self.listenModelClosures()
        isUserInteraction = false
        SpeechManager.shared.setDelegate(delegate: self)
        SpeechManager.shared.speak(message: self.coloringInfo.question_title, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
      //  Utility.setView(view: submitButton, cornerRadius: 5, borderWidth: 0, color: .clear)
        
        
        let imageUrlString = ServiceHelper.baseURL.getMediaBaseUrl() + coloringInfo.image
        let imageUrl:URL = URL(string: imageUrlString)!
        
        // Start background thread so that image loading does not make app unresponsive
         DispatchQueue.global(qos: .userInitiated).async {
            
            let imageData:NSData? = NSData(contentsOf: imageUrl) ?? nil
            
            if(imageData != nil) {
            // When from background thread, UI needs to be updated on main_queue
                DispatchQueue.main.async {
                    let image = UIImage(data: imageData as! Data)
                    self.sketchView.loadImage(image: image!, drawMode: .scale)
                    self.apiDataState = .imageDownloaded
                }
            }
        }

    
        
        collectionOption.register(UINib(nibName: PaintOptionCell.identifier, bundle: nil), forCellWithReuseIdentifier: PaintOptionCell.identifier)

        self.lblTitle.text = coloringInfo.question_title
        AutismTimer.shared.initializeTimer(delegate: self)
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchOnEmptyScreenCount += 1
    }
    
    @IBAction func exitAssessmentClicked(_ sender: Any) {
        self.stopTimer()
        UserManager.shared.exitAssessment()
    }
    @IBAction func skipQuestionClicked(_ sender: Any) {
        if !skipQuestion {
            self.questionState = .submit
            skipQuestion = true
        self.stopTimer()
        SpeechManager.shared.speak(message: SpeechMessage.moveForward.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        }
    }
    
    @IBAction func submitClicked(_ sender: Any) {
        self.questionState = .submit
        self.stopTimer()
        SpeechManager.shared.speak(message:SpeechMessage.excellentWork.getMessage(self.coloringInfo.correct_text), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
      //  self.colorViewModel.uploadImage(image: self.sketchView.asImage(), timeTaken: self.timeTakenToSolve, info: self.coloringInfo, skip: skipQuestion, touchOnEmptyScreenCount: touchOnEmptyScreenCount)
    }
    
   
    
    @objc private func calculateTimeTaken() {
        
        if !Utility.isNetworkAvailable() {
            return
        }
           self.timeTakenToSolve += 1
    }
    
    private func stopTimer() {
        AutismTimer.shared.stopTimer()
           
    }
    
   func numberOfSections(in collectionView: UICollectionView) -> Int {
                  return 1
              }
              func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
               return arrayOption.count
              }
              func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
               
               
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier:PaintOptionCell.identifier, for: indexPath as IndexPath) as! PaintOptionCell
             
                let strOption = arrayOption[indexPath.row]
                if(strOption == "clear") {
                    cell.imgOption.image = UIImage(named: "eraser")
                } else {
                    cell.imgOption.image = UIImage(named: arrayOption[indexPath.row])
                }
               return cell
             
               }
                  
           
             
              
              func collectionView(_ collectionView: UICollectionView,
                                  layout collectionViewLayout: UICollectionViewLayout,
                                  sizeForItemAt indexPath: IndexPath) -> CGSize {
              
                  return CGSize(width:110, height:110)
                 
               
              }
           
           func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            
            let strOption = arrayOption[indexPath.row]

            if(strOption == "pen") {
               sketchView.drawTool = .pen
            }
          else if(strOption == "palette") {
                self.tapPaletteButton()
            }
            
           else if(strOption == "eraser") {
                        sketchView.drawTool = .eraser
                   }
            
           else if(strOption == "undo") {
                        sketchView.undo()
                   }
            
           else if(strOption == "redo") {
                        sketchView.redo()
                   }
            
          else  if(strOption == "figure") {
                self.tapFigureButton()
                   }
            else if(strOption == "filter") {
                self.tapFilterButton()
            }
          else if(strOption == "samp") {
                     self.tapStampButton()
                 }
                
       
                
             else {
                 sketchView.clear()
            }
              
                collectionOption.reloadData()
           }
        func colourDidSelcted(_ colourPadView: ColourPadView, _ color: UIColor) {
            
            sketchView.drawTool = .pen
            self.sketchView.lineColor = color
        }
    
        func tapPaletteButton() {
            sketchView.drawTool = .pen
            if(self.viewStamp != nil) {
                self.viewStamp.frame = CGRect(x: -self.viewStamp.frame.size.width, y: self.viewStamp.frame.origin.y, width: self.viewStamp.frame.size.width, height: self.viewStamp.frame.size.height)
            }
            
            if(viewColourPad == nil) {
                viewColourPad = ColourPadView.init(frame: CGRect(x: 0, y: 140, width: 200, height: 524))
                viewColourPad.delegate = self
                viewColourPad.backgroundColor = .clear
                self.view.addSubview(viewColourPad)
            } else {
                
                UIView.animate(withDuration: 0.2,
                           delay: 0.2,
                           options: UIView.AnimationOptions.curveEaseIn,
                           animations: { () -> Void in

                            if(self.viewColourPad.frame.origin.x == 0) {
                                self.viewColourPad.frame = CGRect(x: -200, y: self.viewColourPad.frame.origin.y, width: 200, height: self.viewColourPad.frame.size.height)
                            } else {
                                self.viewColourPad.frame = CGRect(x: 0, y: self.viewColourPad.frame.origin.y, width: 200, height: self.viewColourPad.frame.size.height)
                            }

                }, completion: { (finished) -> Void in
                    // ....
                })

            }
            
        }
        
        func tapFillButton() {
            sketchView.drawTool = .fill
        }

    func stampDidSelcted(_ stampView: StampView, _ stamp: String) {
        self.changeStampMode(stampName: stamp)
    }

        func tapStampButton() {
            
            if(self.viewColourPad != nil) {
                self.viewColourPad.frame = CGRect(x: -200, y: self.viewColourPad.frame.origin.y, width: 200, height: self.viewColourPad.frame.size.height)
            }
            
            let yRef = UIScreen.main.bounds.size.height-140-100

            if(viewStamp == nil) {
                    
                viewStamp = StampView.init(frame: CGRect(x:0, y:yRef, width:400, height:140))
                viewStamp.delegate = self
                viewStamp.backgroundColor = UIColor.init(white: 0.9, alpha: 0.5)
                self.view.addSubview(viewStamp)
            } else {
                UIView.animate(withDuration: 0.2,
                           delay: 0.2,
                           options: UIView.AnimationOptions.curveEaseIn,
                           animations: { () -> Void in

                            if(self.viewStamp.frame.origin.x == 0) {
                                self.viewStamp.frame = CGRect(x: -self.viewStamp.frame.size.width, y: yRef, width: self.viewStamp.frame.size.width, height: self.viewStamp.frame.size.height)
                            } else {
                                self.viewStamp.frame = CGRect(x: 0, y: yRef, width: self.viewStamp.frame.size.width, height: self.viewStamp.frame.size.height)
                            }

                }, completion: { (finished) -> Void in
                    // ....
                })
            }
        }

        private func changeStampMode(stampName: String) {
            sketchView.stampImage = UIImage(named: stampName)
            sketchView.drawTool = .stamp
        }

        func tapFigureButton() {
            // Line
            let lineAction = UIAlertAction(title: "Line", style: .default) { _ in
                self.sketchView.drawTool = .line
            }
            // Arrow
            let arrowAction = UIAlertAction(title: "Arrow", style: .default) { _ in
                self.sketchView.drawTool = .arrow
            }
            // Rect
            let rectAction = UIAlertAction(title: "Rect", style: .default) { _ in
                self.sketchView.drawTool = .rectangleStroke
            }
            // Rectfill
            let rectFillAction = UIAlertAction(title: "Rect(Fill)", style: .default) { _ in
                self.sketchView.drawTool = .rectangleFill
            }
            // Ellipse
            let ellipseAction = UIAlertAction(title: "Ellipse", style: .default) { _ in
                self.sketchView.drawTool = .ellipseStroke
            }
            // EllipseFill
            let ellipseFillAction = UIAlertAction(title: "Ellipse(Fill)", style: .default) { _ in
                self.sketchView.drawTool = .ellipseFill
            }
            // Star
            let starAction = UIAlertAction(title: "Star platinum", style: .default) { _ in
                self.sketchView.drawTool = .star
            }
            // Cancel
            let cancelAction = UIAlertAction(title: "Cancel", style: .default) { _ in }

            let alertController = UIAlertController(title: "Please select a figure", message: nil, preferredStyle: .alert)
            alertController.addAction(lineAction)
            alertController.addAction(arrowAction)
            alertController.addAction(rectAction)
            alertController.addAction(rectFillAction)
            alertController.addAction(ellipseAction)
            alertController.addAction(ellipseFillAction)
            alertController.addAction(starAction)
            alertController.addAction(cancelAction)

            present(alertController, animated: true, completion: nil)
        }

        func tapFilterButton() {
            // Normal
            let normalAction = UIAlertAction(title: "Normal", style: .default) { _ in
                self.sketchView.drawingPenType = .normal
            }
            // Blur
            let blurAction = UIAlertAction(title: "Blur", style: .default) { _ in
                self.sketchView.drawingPenType = .blur
            }
            // Neon
            let neonAction = UIAlertAction(title: "Neon", style: .default) { _ in
                self.sketchView.drawingPenType = .neon
            }
            // Cancel
            let cancelAction = UIAlertAction(title: "Cancel", style: .default) { _ in }

            let alertController = UIAlertController(title: "Please select a filter type", message: nil, preferredStyle: .alert)
            alertController.addAction(normalAction)
            alertController.addAction(blurAction)
            alertController.addAction(neonAction)
            alertController.addAction(cancelAction)

            present(alertController, animated: true, completion: nil)
        }
    
  

}

extension AssesmentColorViewController {
    func setColorQuestionInfo(info:ColoringQuestionInfo,delegate:AssessmentSubmitDelegate) {
        self.coloringInfo = info
        self.delegate = delegate
    }
    
     private func listenModelClosures() {
          self.colorViewModel.dataClosure = {
             DispatchQueue.main.async {
                   if let res = self.colorViewModel.accessmentSubmitResponseVO {
                           if res.success {
                             self.dismiss(animated: true) {
                                   if let del = self.delegate {
                                       del.submitQuestionResponse(response: res)
                                  }
                              }
                       }
                   }
               }
         }
       }
}

// MARK: Speech Manager Delegate Methods
extension AssesmentColorViewController: SpeechManagerDelegate {
    func speechDidFinish(speechText:String) {
        self.avatarImageView.isHidden = true
        isUserInteraction = true

        if let type = Utility.getSpeechMessageType(text: speechText) {
            if type != .excellentWork {
                self.avatarImageView.animatedImage =  idleGif
            }
        } else {
                self.avatarImageView.animatedImage =  idleGif
        }
        if self.questionState == .submit {
            SpeechManager.shared.setDelegate(delegate: nil)
            self.colorViewModel.uploadImage(image: self.sketchView.asImage(), timeTaken: self.timeTakenToSolve, info: self.coloringInfo, skip: skipQuestion, touchOnEmptyScreenCount: touchOnEmptyScreenCount)
        }
        
    }
    
    func speechDidStart(speechText:String) {
        self.isUserInteraction = false
        self.avatarImageView.isHidden = false

        if let type = Utility.getSpeechMessageType(text: speechText) {
            switch type {
            case .excellentWork:
                self.avatarImageView.animatedImage =  excellentGif
                return
            default:
                break
            }
        }
        self.avatarImageView.animatedImage =  talkingGif
    }
}

extension AssesmentColorViewController: ImageDownloaderDelegate {
    func finishDownloading() {
        self.apiDataState = .imageDownloaded
//        SpeechManager.shared.speak(message:self.sortObjectInfo.question_title, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
//        self.questionTitle.text = self.sortObjectInfo.question_title
    }
}
extension AssesmentColorViewController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        
        print("self.apiDataState = ", self.apiDataState)
        if Utility.isNetworkAvailable() {
            Utility.hideRetryView()
            if(self.apiDataState == .notCall) {

            } else if(self.apiDataState == .dataFetched) {
                let imageUrlString = ServiceHelper.baseURL.getMediaBaseUrl() + coloringInfo.image
                let imageUrl:URL = URL(string: imageUrlString)!
                DispatchQueue.global(qos: .userInitiated).async {
                    let imageData:NSData = NSData(contentsOf: imageUrl)!
                   DispatchQueue.main.async {
                        let image = UIImage(data: imageData as Data)
                        self.sketchView.loadImage(image: image!, drawMode: .scale)
                        self.apiDataState = .imageDownloaded
                    }
                }
            } else {
                
            }
            SpeechManager.shared.setDelegate(delegate: self)
        }
    }
}

extension AssesmentColorViewController: AutismTimerDelegate {
    func timerUpdate() {
        self.calculateTimeTaken()
    }
}
