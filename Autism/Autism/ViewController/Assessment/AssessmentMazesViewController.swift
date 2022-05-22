//
//  AssessmentMazesViewController.swift
//  Autism
//
//  Created by mac on 12/06/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit
import SpriteKit
import FLAnimatedImage

class AssessmentMazesViewController: UIViewController {
    private weak var delegate: AssessmentSubmitDelegate?
    private let mazeViewModel = AssessmentMazeViewModel()
    private var mazeQuestionInfo: MazesInfo!
    private let notificationName = "NotificationIdentifier"
    
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var imgViewBG: UIImageView!
    @IBOutlet weak var heightImgViewBG: NSLayoutConstraint!
    
    @IBOutlet weak var imgViewObject: UIImageView!
    @IBOutlet weak var imgViewGoal: UIImageView!
    
    var minX:CGFloat = 100
    var maxX:CGFloat = UIScreen.main.bounds.width-100
    
    @IBOutlet weak var avatarImageView: FLAnimatedImageView!
    private var timeTakenToSolve = 0
    private var completeRate = 0
    private var skipQuestion = false
    private var questionState: QuestionState = .inProgress
    
    private var isUserInteraction = false {
           didSet {
               self.view.isUserInteractionEnabled = isUserInteraction
           }
    }
    
    private var apiDataState: APIDataState = .notCall

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customSetting()
        self.listenModelClosures()
        self.screenDesigning()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
           NotificationCenter.default.removeObserver(self, name: Notification.Name(notificationName), object: nil)
    }
    
    @IBAction func exitAssessmentClicked(_ sender: Any) {
        self.stopTimer()
        SpeechManager.shared.setDelegate(delegate: nil)
        UserManager.shared.exitAssessment()
    }
    
      @IBAction func skipQuestionClicked(_ sender: Any) {
        if !skipQuestion {
          self.skipQuestion = true
          self.moveToNextQuestion()
        }
      }
    
    //MARK:- Maze Variable
    let yDiff:CGFloat = 50//100
    
    var cWidth:CGFloat = 330
    var xStart:CGFloat = 17
    var yRef:CGFloat = 400//384
    //768/2 = 384
    var path = UIBezierPath()
    
    //MARK:- Maze Methods
    func screenDesigning()
    {
        imgViewGoal.isHidden = true
        if(mazeQuestionInfo.maze_id == "1") {
            
            imgViewObject.center = CGPoint(x: imgViewObject.center.x, y: (self.view.frame.size.height/2.0)-20/*365*/)
            imgViewObject.transform = CGAffineTransform(rotationAngle: CGFloat(-10 * 3.14159265358979/180))
            
            minX = imgViewObject.center.x
            maxX = imgViewGoal.center.x - 150
            
            cWidth = self.view.frame.size.width-200
            xStart = 17
            yRef = 384
    
            var p1 = CGPoint(x: xStart+(cWidth*0), y: yRef)
            var p2 = CGPoint(x: xStart+(cWidth*1), y: yRef-100)
            
            var start = self.drawCurveLineFromPoint1(start: p1, toPoint: p2)
                        
            p1 = CGPoint(x: xStart+(cWidth*0), y: yRef+yDiff)
            p2 = CGPoint(x: xStart+(cWidth*1), y: yRef+yDiff-100)
            
            start = self.drawLineFromPoint(start: start, toPoint: p2)
                
            start = self.drawReverseCurveLineFromPoint1(start: p2, toPoint: p1)
            
            start = self.drawLineFromPoint(start: start, toPoint: CGPoint(x: xStart, y: yRef))
            
            path.move(to: start)
            
        } else if(mazeQuestionInfo.maze_id == "2") {
            
            imgViewObject.center = CGPoint(x: imgViewObject.center.x, y: (self.view.frame.size.height/2.0)-20/*365*/)
//            imgViewObject.bounds = CGRect(x: 0, y: 0, width: 190, height: 190)
            imgViewObject.transform = CGAffineTransform(rotationAngle: CGFloat(-20 * 3.14159265358979/180))
            
            minX = imgViewObject.center.x
            maxX = imgViewGoal.center.x - 150
            
            cWidth = (self.view.frame.size.width-200)/2.0
            xStart = 17
            yRef = 384
            
            var p1 = CGPoint(x: xStart+(cWidth*0), y: yRef+20)
            var p2 = CGPoint(x: xStart+(cWidth*1), y: yRef-20)
            var p3 = CGPoint(x: xStart+(cWidth*2), y: yRef-30)
            
            var start = self.drawCurveLineFromPoint2(start: p1, toPoint: p2)
            start = self.drawCurveLineFromPoint2(start: p2, toPoint: p3)
                        
            p1 = CGPoint(x: xStart+(cWidth*0), y: yRef+yDiff+20)
            p2 = CGPoint(x: xStart+(cWidth*1), y: yRef+yDiff-20)
            p3 = CGPoint(x: xStart+(cWidth*2), y: yRef+yDiff-30)
            
            start = self.drawLineFromPoint(start: start, toPoint: p3)
                
            start = self.drawReverseCurveLineFromPoint2(start: p3, toPoint: p2)
            start = self.drawReverseCurveLineFromPoint2(start: p2, toPoint: p1)
            
            start = self.drawLineFromPoint(start: start, toPoint: CGPoint(x: xStart, y: yRef+20))
            
            path.move(to: start)
        } else if(mazeQuestionInfo.maze_id == "3") {
            cWidth = 330
            xStart = 17
            yRef = 300
            
            imgViewObject.center = CGPoint(x: imgViewObject.center.x, y: imgViewObject.center.y-20)
            imgViewObject.transform = CGAffineTransform(rotationAngle: CGFloat(-20 * 3.14159265358979/180))
            
            minX = imgViewObject.center.x
            maxX = imgViewGoal.center.x - 150
            
            cWidth = (self.view.frame.size.width-200)/3.0
            xStart = 17
            yRef = 364

            var p1 = CGPoint(x: xStart+(cWidth*0), y: yRef+20)
            var p2 = CGPoint(x: xStart+(cWidth*1), y: yRef)
            var p3 = CGPoint(x: xStart+(cWidth*2), y: yRef)
            var p4 = CGPoint(x: xStart+(cWidth*3), y: yRef)
            
            var start = self.drawCurveLineFromPoint3(start: p1, toPoint: p2)
            start = self.drawCurveLineFromPoint3(start: p2, toPoint: p3)
            start = self.drawCurveLineFromPoint3(start: p3, toPoint: p4)
            
            
            
            p1 = CGPoint(x: xStart+(cWidth*0), y: yRef+yDiff+20)
            p2 = CGPoint(x: xStart+(cWidth*1), y: yRef+yDiff)
            p3 = CGPoint(x: xStart+(cWidth*2), y: yRef+yDiff)
            p4 = CGPoint(x: xStart+(cWidth*3), y: yRef+yDiff)
            
            start = self.drawLineFromPoint(start: start, toPoint: p4)
                
            start = self.drawReverseCurveLineFromPoint3(start: p4, toPoint: p3)
            start = self.drawReverseCurveLineFromPoint3(start: p3, toPoint: p2)
            start = self.drawReverseCurveLineFromPoint3(start: p2, toPoint: p1)
            
            start = self.drawLineFromPoint(start: start, toPoint: CGPoint(x: xStart, y: yRef+20))
            
            path.move(to: start)
        }
                        
        path.close()
        self.showPath()
        
        imgViewObject.removeFromSuperview()
        self.view.addSubview(imgViewObject)
    }
    
    func drawCurveLineFromPoint1(start : CGPoint, toPoint end:CGPoint) -> CGPoint {
        
        let cDiff = cWidth/4.0
        let yControl:CGFloat = 250
        
        let c1:CGPoint = CGPoint(x:start.x+cDiff+40, y:yRef-yControl+40)
        let c2:CGPoint = CGPoint(x:start.x+cDiff+cDiff-20, y:yRef+yControl-70)
        path.move(to: start)
        path.addCurve(to: end, controlPoint1: c1, controlPoint2: c2)
        
        return end
    }
    
//MARK:- 1
    func drawReverseCurveLineFromPoint1(start : CGPoint, toPoint end:CGPoint) -> CGPoint {
        
        let cDiff = cWidth/3.0
        let yControl:CGFloat = 250
        
        let c1:CGPoint = CGPoint(x:start.x-cDiff-cDiff-20, y:yRef+yDiff-yControl+40)
        let c2:CGPoint = CGPoint(x:start.x-cDiff-100, y:yRef+yDiff+yControl-80)
        path.move(to: start)
        path.addCurve(to: end, controlPoint1: c2, controlPoint2: c1)
        
        return end
    }
    
    //MARK:- 2
    func drawCurveLineFromPoint2(start : CGPoint, toPoint end:CGPoint) -> CGPoint {
        
        let cDiff = cWidth/3.0
        let yControl:CGFloat = 180
        
        let c1:CGPoint = CGPoint(x:start.x+cDiff, y:yRef-yControl)
        let c2:CGPoint = CGPoint(x:start.x+cDiff+cDiff, y:yRef+yControl-100)
        path.move(to: start)
        path.addCurve(to: end, controlPoint1: c1, controlPoint2: c2)
        
        return end
    }
    
    func drawReverseCurveLineFromPoint2(start : CGPoint, toPoint end:CGPoint) -> CGPoint {
        
        let cDiff = cWidth/3.0
        let yControl:CGFloat = 200
        
        let c1:CGPoint = CGPoint(x:start.x-cDiff-cDiff, y:yRef+yDiff-yControl)
        let c2:CGPoint = CGPoint(x:start.x-cDiff, y:yRef+yDiff+yControl-100)
        path.move(to: start)
        path.addCurve(to: end, controlPoint1: c2, controlPoint2: c1)
        
        return end
    }
    
    //MARK:- 3
    func drawCurveLineFromPoint3(start : CGPoint, toPoint end:CGPoint) -> CGPoint {
        
        let cDiff = cWidth/3.0
        let yControl:CGFloat = 150
        
        let c1:CGPoint = CGPoint(x:start.x+cDiff, y:yRef-yControl)
        let c2:CGPoint = CGPoint(x:start.x+cDiff+cDiff, y:yRef+yControl-50)
        path.move(to: start)
        path.addCurve(to: end, controlPoint1: c1, controlPoint2: c2)
        
        return end
    }
    

    func drawReverseCurveLineFromPoint3(start : CGPoint, toPoint end:CGPoint) -> CGPoint {
        
        let cDiff = cWidth/3.0
        let yControl:CGFloat = 150
        
        let c1:CGPoint = CGPoint(x:start.x-cDiff-cDiff, y:yRef+yDiff-yControl)
        let c2:CGPoint = CGPoint(x:start.x-cDiff, y:yRef+yDiff+yControl)
        path.move(to: start)
        path.addCurve(to: end, controlPoint1: c2, controlPoint2: c1)
        
        return end
    }
    
    func drawLineFromPoint(start : CGPoint, toPoint end:CGPoint) -> CGPoint {
        
        path.move(to: start)
        path.addLine(to: end)
        
        return end
    }

    func showPath()
    {
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor.green.cgColor
        shapeLayer.lineWidth = 5.0
        shapeLayer.backgroundColor = UIColor.clear.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        
        //view.layer.addSublayer(shapeLayer)
    }
    
    //MARK:- Touch Delegate
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let touch = touches.first {
        let location = touch.location(in: self.view)
        timeTakenToSolve = 0
        print("location.y = ", location.y)
        if(path.cgPath.contains(location)) {
            if(imgViewObject.frame.contains(location) == true) {
                self.calculateThePosition(location)
            }
        }
      }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
     
        if let touch = touches.first {
            let location = touch.location(in: self.view)
            
                if(imgViewObject.frame.contains(location) == true) {
                    self.calculateThePosition(location)
                }
          }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if(self.questionState != .submit ) {
            if(imgViewObject.center.x >= maxX-5) {
                self.questionState = .submit
                completeRate = 100
                SpeechManager.shared.speak(message: SpeechMessage.hurrayGoodJob.getMessage(self.mazeQuestionInfo.correct_text), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
            }
        }
    }
    
    func calculateThePosition(_ location:CGPoint)
    {
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {

            let yCenter384:CGFloat = self.view.frame.size.height/2.0//384
            
            if(self.mazeQuestionInfo.maze_id == "1") {
                
                let diff = Int(self.cWidth)/12
                let iX = Int(location.x)%Int(self.cWidth)
                print("iX = ", iX)
//                print("yCenter384-location.y = ", yCenter384-location.y)
                let ydiff = yCenter384-location.y
                if(ydiff < -40 || ydiff > 40) {
                    return
                }
                print("ydiff = ", ydiff)
                
                var yRef:CGFloat = location.y
                if(iX >= 0*diff && iX <= 1*diff) {
                    self.imgViewObject.transform = CGAffineTransform(rotationAngle: CGFloat(-20 * 3.14159265358979/180))
                    yRef = yCenter384-10//375
                } else if(iX >= 0*diff && iX <= 2*diff) {
                    self.imgViewObject.transform = CGAffineTransform(rotationAngle: CGFloat(-10 * 3.14159265358979/180))
                    yRef = yCenter384-20//365
                } else if(2*diff >= 0 && iX <= 3*diff) {
                    self.imgViewObject.transform = CGAffineTransform(rotationAngle: CGFloat(0 * 3.14159265358979/180))
                    yRef = yCenter384-34//350
                } else if(3*diff >= 0 && iX <= 4*diff) {
                    self.imgViewObject.transform = CGAffineTransform(rotationAngle: CGFloat(10 * 3.14159265358979/180))
                    yRef = yCenter384-30//355
                } else if(4*diff >= 0 && iX <= 5*diff) {
                    self.imgViewObject.transform = CGAffineTransform(rotationAngle: CGFloat(20 * 3.14159265358979/180))
                    yRef = yCenter384-20//365
                } else if(5*diff >= 0 && iX <= 6*diff) {
                    self.imgViewObject.transform = CGAffineTransform(rotationAngle: CGFloat(25 * 3.14159265358979/180))
                    yRef = yCenter384-0//385
                } else if(6*diff >= 0 && iX <= 7*diff) {
                    self.imgViewObject.transform = CGAffineTransform(rotationAngle: CGFloat(15 * 3.14159265358979/180))
                    yRef = yCenter384+16//400
                } else if(7*diff >= 0 && iX <= 8*diff) {
                    self.imgViewObject.transform = CGAffineTransform(rotationAngle: CGFloat(5 * 3.14159265358979/180))
                    yRef = yCenter384+20//405
                } else if(8*diff >= 0 && iX <= 9*diff) {
                    self.imgViewObject.transform = CGAffineTransform(rotationAngle: CGFloat(-5 * 3.14159265358979/180))
                    yRef = yCenter384+10//405
                }
                else if(9*diff >= 0 && iX <= 10*diff) {
                    self.imgViewObject.transform = CGAffineTransform(rotationAngle: CGFloat(-15 * 3.14159265358979/180))
                    yRef = yCenter384-00//385
                } else if(10*diff >= 0 && iX <= 11*diff) {
                    self.imgViewObject.transform = CGAffineTransform(rotationAngle: CGFloat(-16 * 3.14159265358979/180))
                    yRef = yCenter384-24//360
                } else if(11*diff >= 0 && iX <= 12*diff) {
                    self.imgViewObject.transform = CGAffineTransform(rotationAngle: CGFloat(-7 * 3.14159265358979/180))
                    yRef = yCenter384-44//340
                } else {
                    yRef = yCenter384-60//325
                }
                if(12*diff < Int(location.x)) {
                    //self.imgViewObject.center = CGPoint(x:CGFloat(12*diff), y:yRef)
                } else {
                    if(location.x > 100) {
                        self.imgViewObject.center = CGPoint(x:location.x, y:yRef)
                    }
                }
            } else if(self.mazeQuestionInfo.maze_id == "2") {
                
                let cW:CGFloat = self.view.frame.size.width-200
                
                let diff = Int(cW)/12
                let iX = Int(location.x)%Int(cW)
                print("iX = ", iX)
                print("diff = ", diff)
                
                let ydiff = yCenter384-location.y
                if(ydiff < -50 || ydiff > 50) {
                    return
                }

                var yRef:CGFloat = location.y
                if(iX >= 0*diff && iX <= 1*diff) {
                    self.imgViewObject.transform = CGAffineTransform(rotationAngle: CGFloat(-25 * 3.14159265358979/180))
                    yRef = yCenter384-14//370
                } else if(1*diff >= 0 && iX <= 2*diff) {
                    self.imgViewObject.transform = CGAffineTransform(rotationAngle: CGFloat(0 * 3.14159265358979/180))
                    yRef = yCenter384-34//350
                } else if(2*diff >= 0 && iX <= 3*diff) {
                    self.imgViewObject.transform = CGAffineTransform(rotationAngle: CGFloat(20 * 3.14159265358979/180))
                    yRef = yCenter384-30//354
                } else if(3*diff >= 0 && iX <= 4*diff) {
                    self.imgViewObject.transform = CGAffineTransform(rotationAngle: CGFloat(30 * 3.14159265358979/180))
                    yRef = yCenter384-0//384
                } else if(4*diff >= 0 && iX <= 5*diff) {
                    self.imgViewObject.transform = CGAffineTransform(rotationAngle: CGFloat(10 * 3.14159265358979/180))
                    yRef = yCenter384+30//414
                } else if(5*diff >= 0 && iX <= 6*diff) {
                    self.imgViewObject.transform = CGAffineTransform(rotationAngle: CGFloat(-20 * 3.14159265358979/180))
                    yRef = yCenter384+26//410
                } else if(6*diff >= 0 && iX <= 7*diff) {
                    self.imgViewObject.transform = CGAffineTransform(rotationAngle: CGFloat(-20 * 3.14159265358979/180))
                    yRef = yCenter384-4//380
                } else if(7*diff >= 0 && iX <= 8*diff) {
                    self.imgViewObject.transform = CGAffineTransform(rotationAngle: CGFloat(-25 * 3.14159265358979/180))
                    yRef = yCenter384-44//340
                } else if(8*diff >= 0 && iX <= 9*diff) {
                    self.imgViewObject.transform = CGAffineTransform(rotationAngle: CGFloat(10 * 3.14159265358979/180))
                    yRef = yCenter384-34//350
                } else if(9*diff >= 0 && iX <= 10*diff) {
                    self.imgViewObject.transform = CGAffineTransform(rotationAngle: CGFloat(30 * 3.14159265358979/180))
                    yRef = yCenter384-14//370
                } else if(10*diff >= 0 && iX <= 11*diff) {
                    self.imgViewObject.transform = CGAffineTransform(rotationAngle: CGFloat(20 * 3.14159265358979/180))
                    yRef = yCenter384+6//390
                } else if(11*diff >= 0 && iX <= 12*diff) {
                    self.imgViewObject.transform = CGAffineTransform(rotationAngle: CGFloat(-10 * 3.14159265358979/180))
                    yRef = yCenter384-0//385
                }
                print("yRef = ", yRef)
                if(12*diff < Int(location.x)) {
                    //self.imgViewObject.center = CGPoint(x:CGFloat(12*diff), y:yRef)
                } else {
                    if(location.x > 100) {
                        self.imgViewObject.center = CGPoint(x:location.x, y:yRef)
                    }
                }
            } else  if(self.mazeQuestionInfo.maze_id == "3") {
                
                let diff = Int(self.cWidth)/5
                
                let iX = Int(location.x)%Int(self.cWidth)
                print("iX = ", iX)
                
                let ydiff = yCenter384-location.y
                if(ydiff < -80 || ydiff > 60) {
                    return
                }

                if(iX >= 0*diff && iX <= 1*diff) {
                    self.imgViewObject.transform = CGAffineTransform(rotationAngle: CGFloat(-45 * 3.14159265358979/180))
                } else if(1*diff >= 0 && iX <= 2*diff) {
                    self.imgViewObject.transform = CGAffineTransform(rotationAngle: CGFloat(10 * 3.14159265358979/180))
                } else if(2*diff >= 0 && iX <= 3*diff) {
                    self.imgViewObject.transform = CGAffineTransform(rotationAngle: CGFloat(30 * 3.14159265358979/180))
                } else if(3*diff >= 0 && iX <= 4*diff) {
                    self.imgViewObject.transform = CGAffineTransform(rotationAngle: CGFloat(45 * 3.14159265358979/180))
                } else if(4*diff >= 0 && iX <= 5*diff) {
                    self.imgViewObject.transform = CGAffineTransform(rotationAngle: CGFloat(-10 * 3.14159265358979/180))
                }
                self.imgViewObject.center = location
            }
            
        }) { (finished) in
             UIView.animate(withDuration: 1, animations: {
                
        //        self.startAndRepeatCommands()
           })
        }
                
        
    }
    
}

// MARK: Public Methods
extension AssessmentMazesViewController {
    func setMazesQuestionInfo(info:MazesInfo,delegate:AssessmentSubmitDelegate) {
        self.mazeQuestionInfo = info
        self.delegate = delegate
    }
}

// MARK: Private Methods
extension AssessmentMazesViewController {
    private func customSetting() {
        
        isUserInteraction = false
        SpeechManager.shared.setDelegate(delegate: self)
        lblTitle.text = mazeQuestionInfo.question_title
        self.reDownloadImages()
        
        var imgWH:CGFloat = 220
        var yPos:CGFloat = (UIScreen.main.bounds.size.height-imgWH)/2.0
        
        if(UIDevice.current.userInterfaceIdiom != .pad) {
            imgWH = 140
            yPos = (UIScreen.main.bounds.size.height-imgWH)/2.0
        }
        imgViewObject.frame = CGRect(x:0, y:yPos, width:imgWH, height:imgWH)
        imgViewGoal.frame = CGRect(x:UIScreen.main.bounds.size.width-imgWH, y:yPos, width:imgWH, height:imgWH)
        
        heightImgViewBG.constant = imgWH
        
    }
    
    func reDownloadImages()
    {
        if(mazeQuestionInfo.bg_image != "" && mazeQuestionInfo.goal_image != "" && mazeQuestionInfo.objejct_image != "") {
            
            ImageDownloader.sharedInstance.downloadImage(urlString:  mazeQuestionInfo.bg_image, imageView: imgViewBG, callbackAfterNoofImages: 3, delegate: self)
            
            ImageDownloader.sharedInstance.downloadImage(urlString:  mazeQuestionInfo.goal_image, imageView: imgViewGoal, callbackAfterNoofImages: 3, delegate: self)

            ImageDownloader.sharedInstance.downloadImage(urlString:  mazeQuestionInfo.objejct_image, imageView: imgViewObject, callbackAfterNoofImages: 3, delegate: self)
        }
    }

    private func listenModelClosures() {
       self.mazeViewModel.dataClosure = {
          DispatchQueue.main.async {
                if let res = self.mazeViewModel.accessmentSubmitResponseVO {
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
    
    @objc private func methodOfReceivedNotification(notification: Notification) {
        
         let time:String = UserDefaults.standard.object(forKey: "time") as! String
        
        let timeInt = Int(time)
        
        self.mazeViewModel.submitUserAnswer(successCount: timeInt!, info: self.mazeQuestionInfo,timeTaken: 0, skip: false)
    }
    
     private func moveToNextQuestion() {
         self.stopTimer()
                    RecordingManager.shared.stopRecording()
                    RecordingManager.shared.stopWaitUserAnswerTimer()
                    self.completeRate = 0
                    self.questionState = .submit
                    SpeechManager.shared.speak(message: SpeechMessage.moveForward.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        
     }
     
     @objc private func calculateTimeTaken() {
         
         if !Utility.isNetworkAvailable() {
             return
         }
         self.timeTakenToSolve += 1
        trailPromptTimeForUser += 1
        
         if self.timeTakenToSolve >= mazeQuestionInfo.completion_time  {
             self.moveToNextQuestion()
         } else if trailPromptTimeForUser == mazeQuestionInfo.trial_time && self.timeTakenToSolve < mazeQuestionInfo.completion_time
         {
             trailPromptTimeForUser = 0
             SpeechManager.shared.speak(message: SpeechMessage.keepTrying.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
         }
     }
     
    private func stopTimer() {
        AutismTimer.shared.stopTimer()
    }
     
     private func stopSpeechAndRecorder() {
         SpeechManager.shared.setDelegate(delegate: nil)
         RecordingManager.shared.stopRecording()
         RecordingManager.shared.stopWaitUserAnswerTimer()
     }
}

extension AssessmentMazesViewController: SpeechManagerDelegate {
    
    func speechDidFinish(speechText:String) {
        self.avatarImageView.isHidden = true

        if let type = Utility.getSpeechMessageType(text: speechText) {
                   if type != .hurrayGoodJob {
                       self.avatarImageView.animatedImage =  getIdleGif()
                   }
               }
        else {
                self.avatarImageView.animatedImage =  getIdleGif()
        }
        
        switch self.questionState {
        case .submit:
            self.stopTimer()
            self.stopSpeechAndRecorder()
            self.mazeViewModel.submitUserAnswer(successCount: completeRate, info: self.mazeQuestionInfo, timeTaken: timeTakenToSolve, skip: false)
            break
        default:
            isUserInteraction = true
            break
        }
    }
    
    func speechDidStart(speechText:String) {
        self.isUserInteraction = false
        self.avatarImageView.isHidden = false

        if let type = Utility.getSpeechMessageType(text: speechText) {
            switch type {
            case .hurrayGoodJob:
                self.avatarImageView.animatedImage =  getHurrayGif()
                return
            case .wrongAnswer:
                self.avatarImageView.animatedImage =  getWrongAnswerGif()
                return
            default:
                break
            }
        }
        self.avatarImageView.animatedImage =  getTalkingGif()
    }
}

extension AssessmentMazesViewController: ImageDownloaderDelegate {
    func finishDownloading() {
        self.apiDataState = .imageDownloaded
        SpeechManager.shared.speak(message:self.mazeQuestionInfo.question_title, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
       // self.initializeTimer()
        AutismTimer.shared.initializeTimer(delegate: self)
    }
}

extension AssessmentMazesViewController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        if Utility.isNetworkAvailable() {
            Utility.hideRetryView()
            if(self.apiDataState == .notCall || self.apiDataState == .dataFetched) {
                self.reDownloadImages()
            } else {
                
            }
            SpeechManager.shared.setDelegate(delegate: self)
        }
    }
}

extension AssessmentMazesViewController: AutismTimerDelegate {
    func timerUpdate() {
        self.calculateTimeTaken()
    }
}
