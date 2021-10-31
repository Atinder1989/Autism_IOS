//
//  AssessmentMultiArrayQuestionViewController.swift
//  Autism
//
//  Created by Dilip Technology on 18/11/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit
import FLAnimatedImage
    
class AssessmentMultiArrayQuestionViewController: UIViewController {

    @IBOutlet weak var questionTitle: UILabel!
    @IBOutlet weak var avatarImageView: FLAnimatedImageView!

    @IBOutlet weak var imagesCollectionView0: UICollectionView!
    @IBOutlet weak var imagesCollectionView1: UICollectionView!
    @IBOutlet weak var imagesCollectionView2: UICollectionView!
    @IBOutlet weak var imagesCollectionView3: UICollectionView!
    @IBOutlet weak var imagesCollectionView4: UICollectionView!
        
    private weak var delegate: AssessmentSubmitDelegate?
    private var whichTypeQuestionInfo: MultiArrayQuestionInfo!
    private var whichTypeViewModel = AssessmentMultiArrayQuestionViewModel()
    private var timeTakenToSolve = 0
    private var completeRate = 0
    private var questionState: QuestionState = .inProgress
     private var isUserInteraction = false {
             didSet {
                 self.view.isUserInteractionEnabled = isUserInteraction
             }
       }
    private var skipQuestion = false

    private var touchOnEmptyScreenCount = 0
    private var apiDataState: APIDataState = .notCall
    
    //New for multiple
    var currentIndex:Int = 0
    var isRightAnswer:Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.customSetting()
        self.listenModelClosures()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchOnEmptyScreenCount += 1
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
}

// MARK: Public Methods
extension AssessmentMultiArrayQuestionViewController {
    func setQuestionInfo(info:MultiArrayQuestionInfo,delegate:AssessmentSubmitDelegate) {
        self.apiDataState = .dataFetched
        self.whichTypeQuestionInfo = info
        self.delegate = delegate
    }
}

// MARK: Private Methods
extension AssessmentMultiArrayQuestionViewController {
    private func moveToNextQuestion() {
         self.stopTimer()
         self.questionState = .submit
         self.completeRate = 0
        SpeechManager.shared.speak(message: SpeechMessage.moveForward.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
    }

    private func customSetting() {
        isUserInteraction = false
        SpeechManager.shared.setDelegate(delegate: self)
        
        imagesCollectionView0.register(ImageCell.nib, forCellWithReuseIdentifier: ImageCell.identifier)
        imagesCollectionView1.register(ImageCell.nib, forCellWithReuseIdentifier: ImageCell.identifier)
        imagesCollectionView2.register(ImageCell.nib, forCellWithReuseIdentifier: ImageCell.identifier)
        imagesCollectionView3.register(ImageCell.nib, forCellWithReuseIdentifier: ImageCell.identifier)
        imagesCollectionView4.register(ImageCell.nib, forCellWithReuseIdentifier: ImageCell.identifier)
        
        let w:CGFloat = self.view.frame.size.width-200
        let h:CGFloat = 300
        if(currentIndex == 0) {
            imagesCollectionView0.frame = CGRect(x: (self.view.frame.size.width-w)/2.0, y: 400, width: w, height: h)

            imagesCollectionView1.frame = CGRect(x: self.view.frame.size.width-200, y: 150, width: 200, height: 40)
            imagesCollectionView2.frame = CGRect(x: self.view.frame.size.width-200, y: 200, width: 200, height: 40)
            imagesCollectionView3.frame = CGRect(x: self.view.frame.size.width-200, y: 250, width: 200, height: 40)
            imagesCollectionView4.frame = CGRect(x: self.view.frame.size.width-200, y: 300, width: 200, height: 40)
        } else if(currentIndex == 1) {
            imagesCollectionView1.bounds = CGRect(x: 0, y: 0, width: w, height: h)
            imagesCollectionView1.center = self.view.center
        } else if(currentIndex == 2) {
            imagesCollectionView2.bounds = CGRect(x: 0, y: 0, width: w, height: h)
            imagesCollectionView2.center = self.view.center
        } else if(currentIndex == 3) {
            imagesCollectionView3.bounds = CGRect(x: 0, y: 0, width: w, height: h)
            imagesCollectionView3.center = self.view.center
        } else if(currentIndex == 4) {
            imagesCollectionView4.bounds = CGRect(x: 0, y: 0, width: w, height: h)
            imagesCollectionView4.center = self.view.center
        }
        
        self.questionTitle.text = ""//self.whichTypeQuestionInfo.question_title
        AutismTimer.shared.initializeTimer(delegate: self)
    }
    
    func showNextImage()
    {
        
        let w:CGFloat = self.view.frame.size.width-200
        let h:CGFloat = 300
        let xRef:CGFloat = (self.view.frame.size.width-w)/2.0
        
        self.isRightAnswer = false
        currentIndex = currentIndex+1
        if(currentIndex < self.whichTypeQuestionInfo.blocks.count) {
            self.questionTitle.text = self.whichTypeQuestionInfo.blocks[currentIndex].question_title

            UIView.animate(withDuration: 0.5,
                                  delay: 0,
                                options: [],
                             animations: {
                                if(self.currentIndex == 0) {
                                    self.imagesCollectionView0.frame = CGRect(x: xRef, y: 400, width: w, height: h)
                                } else if(self.currentIndex == 1) {
                                    self.imagesCollectionView1.frame = CGRect(x: xRef, y: 400, width: w, height: h)
                                    self.imagesCollectionView0.frame = CGRect(x: 10, y: 150, width: 200, height: 40)
                                    
                                    self.imagesCollectionView0.reloadData()
                                    self.imagesCollectionView1.reloadData()
                                } else if(self.currentIndex == 2) {
                                    self.imagesCollectionView2.frame = CGRect(x: xRef, y: 400, width: w, height: h)
                                    self.imagesCollectionView1.frame = CGRect(x: 10, y: 200, width: 200, height: 40)
                                    
                                    self.imagesCollectionView1.reloadData()
                                    self.imagesCollectionView2.reloadData()
                                } else if(self.currentIndex == 3) {
                                    self.imagesCollectionView3.frame = CGRect(x: xRef, y: 400, width: w, height: h)
                                    self.imagesCollectionView2.frame = CGRect(x: 10, y: 250, width: 200, height: 40)
                                    
                                    self.imagesCollectionView2.reloadData()
                                    self.imagesCollectionView3.reloadData()
                                } else if(self.currentIndex == 4) {
                                    self.imagesCollectionView4.frame = CGRect(x: xRef, y: 400, width: w, height: h)
                                    self.imagesCollectionView3.frame = CGRect(x: 10, y: 300, width: 200, height: 40)
                                    
                                    self.imagesCollectionView3.reloadData()
                                    self.imagesCollectionView4.reloadData()
                                }
                             }, completion: {_ in
                                SpeechManager.shared.setDelegate(delegate: self)
                                SpeechManager.shared.speak(message: self.whichTypeQuestionInfo.blocks[self.currentIndex].question_title, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
                             }
            )
        }
    }
    
    private func listenModelClosures() {
            self.navigationController?.navigationBar.isHidden = true
            self.whichTypeViewModel.dataClosure = {
                DispatchQueue.main.async {
                    if let res = self.whichTypeViewModel.accessmentSubmitResponseVO {
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
    
   
    
    @objc private func calculateTimeTaken() {
        if !Utility.isNetworkAvailable() {
            return
        }
        
        self.timeTakenToSolve += 1
        trailPromptTimeForUser += 1

        if self.timeTakenToSolve == Int(AppConstant.screenloadQuestionSpeakTimeDelay.rawValue) {
             self.questionTitle.text = self.whichTypeQuestionInfo.blocks[currentIndex].question_title
            SpeechManager.shared.speak(message:  self.whichTypeQuestionInfo.blocks[currentIndex].question_title, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        } else if trailPromptTimeForUser == whichTypeQuestionInfo.trial_time && self.timeTakenToSolve < whichTypeQuestionInfo.completion_time
        {
            if(isUserInteraction == false) {
                return
            }
            trailPromptTimeForUser = 0
            SpeechManager.shared.speak(message: SpeechMessage.keepTrying.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        } else {
            if(isUserInteraction == false) {
                return
            }
            let time_inteval = whichTypeQuestionInfo.time_interval+(currentIndex*whichTypeQuestionInfo.time_interval)
            if (self.timeTakenToSolve >= time_inteval) {
                isUserInteraction = false
                if(currentIndex < self.whichTypeQuestionInfo.blocks.count) {
                    self.showNextImage()
                } else {
                    self.moveToNextQuestion()
                }
            }
        }
        
    }
    
    func stopTimer() {
        AutismTimer.shared.stopTimer()
    }
    
}

extension AssessmentMultiArrayQuestionViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w:CGFloat = self.view.frame.size.width-224
        let layWH:CGFloat = (w-80)/4.0
        
        if(currentIndex == 0 && collectionView == imagesCollectionView0) {
            return CGSize.init(width: layWH, height: layWH)
        } else if(currentIndex == 1 && collectionView == imagesCollectionView1) {
            return CGSize.init(width: layWH, height: layWH)
        } else if(currentIndex == 2 && collectionView == imagesCollectionView2) {
            return CGSize.init(width: layWH, height: layWH)
        } else if(currentIndex == 3 && collectionView == imagesCollectionView3) {
            return CGSize.init(width: layWH, height: layWH)
        } else if(currentIndex == 4 && collectionView == imagesCollectionView4) {
            return CGSize.init(width: layWH, height: layWH)
        } else {
            return CGSize.init(width: 40, height: 40)
        }
        
        if(w == 800) {
            if(currentIndex == 0 && collectionView == imagesCollectionView0) {
                return CGSize.init(width: 180, height: 180)
            } else if(currentIndex == 1 && collectionView == imagesCollectionView1) {
                return CGSize.init(width: 180, height: 180)
            } else if(currentIndex == 2 && collectionView == imagesCollectionView2) {
                return CGSize.init(width: 180, height: 180)
            } else if(currentIndex == 3 && collectionView == imagesCollectionView3) {
                return CGSize.init(width: 180, height: 180)
            } else if(currentIndex == 4 && collectionView == imagesCollectionView4) {
                return CGSize.init(width: 180, height: 180)
            } else {
                return CGSize.init(width: 40, height: 40)
            }
        } else {
            if(currentIndex == 0 && collectionView == imagesCollectionView0) {
                return CGSize.init(width: 220, height: 220)
            } else if(currentIndex == 1 && collectionView == imagesCollectionView1) {
                return CGSize.init(width: 220, height: 220)
            } else if(currentIndex == 2 && collectionView == imagesCollectionView2) {
                return CGSize.init(width: 220, height: 220)
            } else if(currentIndex == 3 && collectionView == imagesCollectionView3) {
                return CGSize.init(width: 220, height: 220)
            } else if(currentIndex == 4 && collectionView == imagesCollectionView4) {
                return CGSize.init(width: 220, height: 220)
            } else {
                return CGSize.init(width: 40, height: 40)
            }
        }
        
        
//        self.collectionViewWidthConstraint.constant = CGFloat(4 * 240)
//        self.collectionViewHeightConstraint.constant = 300
//        return CGSize.init(width: 40, height: 40)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if(self.whichTypeQuestionInfo.blocks.count >= 5) {
            if(collectionView == imagesCollectionView0) {
                return self.whichTypeQuestionInfo.blocks[0].imagesList.count
            } else if(collectionView == imagesCollectionView1) {
                return self.whichTypeQuestionInfo.blocks[1].imagesList.count
            } else if(collectionView == imagesCollectionView2) {
                return self.whichTypeQuestionInfo.blocks[2].imagesList.count
            } else if(collectionView == imagesCollectionView3) {
                return self.whichTypeQuestionInfo.blocks[3].imagesList.count
            } else if(collectionView == imagesCollectionView4) {
                return self.whichTypeQuestionInfo.blocks[4].imagesList.count
            } else {
                return self.whichTypeQuestionInfo.blocks[currentIndex].imagesList.count
            }
        } else if(self.whichTypeQuestionInfo.blocks.count >= 4) {
            if(collectionView == imagesCollectionView0) {
                return self.whichTypeQuestionInfo.blocks[0].imagesList.count
            } else if(collectionView == imagesCollectionView1) {
                return self.whichTypeQuestionInfo.blocks[1].imagesList.count
            } else if(collectionView == imagesCollectionView2) {
                return self.whichTypeQuestionInfo.blocks[2].imagesList.count
            } else if(collectionView == imagesCollectionView3) {
                return self.whichTypeQuestionInfo.blocks[3].imagesList.count
            } else {
                return self.whichTypeQuestionInfo.blocks[currentIndex].imagesList.count
            }
        } else if(self.whichTypeQuestionInfo.blocks.count >= 3) {
            if(collectionView == imagesCollectionView0) {
                return self.whichTypeQuestionInfo.blocks[0].imagesList.count
            } else if(collectionView == imagesCollectionView1) {
                return self.whichTypeQuestionInfo.blocks[1].imagesList.count
            } else if(collectionView == imagesCollectionView2) {
                return self.whichTypeQuestionInfo.blocks[2].imagesList.count
            } else {
                return self.whichTypeQuestionInfo.blocks[currentIndex].imagesList.count
            }
        } else if(self.whichTypeQuestionInfo.blocks.count >= 2) {
            if(collectionView == imagesCollectionView0) {
                return self.whichTypeQuestionInfo.blocks[0].imagesList.count
            } else if(collectionView == imagesCollectionView1) {
                return self.whichTypeQuestionInfo.blocks[1].imagesList.count
            } else {
                return self.whichTypeQuestionInfo.blocks[currentIndex].imagesList.count
            }
        } else if(self.whichTypeQuestionInfo.blocks.count >= 1) {
            if(collectionView == imagesCollectionView0) {
                return self.whichTypeQuestionInfo.blocks[0].imagesList.count
            }
        } else {
            return 0//self.whichTypeQuestionInfo.blocks[currentIndex].imagesList.count
        }
        return 0
    }
    
    // make a cell for each cell index path
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.identifier, for: indexPath) as! ImageCell
        
        var model:ImageModel!
        if(collectionView.tag < self.whichTypeQuestionInfo.blocks.count) {
            model = self.whichTypeQuestionInfo.blocks[collectionView.tag].imagesList[indexPath.row]
        } else{
            return cell
        }
                
        cell.greenTickImageView.isHidden = true
        cell.greenTickImageView.image = nil
        
        cell.setData(model: model)
        
        var cornerRadius = cell.frame.size.width / 2
        var borderWidth:CGFloat = 2
        
        if (self.whichTypeQuestionInfo.question_type == AssessmentQuestionType.touch_object.rawValue) {
            cornerRadius = 0.0
            borderWidth = 0.0
            cell.dataImageView.transform = CGAffineTransform(rotationAngle: CGFloat(model.degrees * .pi/180))
        } else {
            cell.dataImageView.transform = CGAffineTransform(rotationAngle: 0)
        }
        cell.greenTickImageView.contentMode = .center
        
        if self.whichTypeQuestionInfo.blocks[collectionView.tag].selectedIndex == -1 {
          Utility.setView(view: cell.dataImageView, cornerRadius: cornerRadius, borderWidth: borderWidth, color: .darkGray)
        } else {
            let sIndex = self.whichTypeQuestionInfo.blocks[collectionView.tag].selectedIndex
            if indexPath.row == Int(self.whichTypeQuestionInfo.blocks[collectionView.tag].correct_answer)! - 1 {
                 cell.greenTickImageView.isHidden = false
                 cell.greenTickImageView.image = UIImage.init(named: "greenTick")
                 Utility.setView(view: cell.dataImageView, cornerRadius: cornerRadius, borderWidth: borderWidth, color: .greenBorderColor)
                
                if(sIndex != indexPath.row) {
                    Animations.shake(on: cell)
                }
             }
            else if self.whichTypeQuestionInfo.blocks[collectionView.tag].selectedIndex == indexPath.row {
                
                 cell.greenTickImageView.isHidden = false
                 cell.greenTickImageView.image = UIImage.init(named: "cross")
                 Utility.setView(view: cell.dataImageView, cornerRadius: cornerRadius, borderWidth: borderWidth, color: .redBorderColor)
                
             } else {
                 Utility.setView(view: cell.dataImageView, cornerRadius: cornerRadius, borderWidth: borderWidth, color: .darkGray)
             }
        }
      return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.whichTypeQuestionInfo.blocks[collectionView.tag].selectedIndex = indexPath.row
        self.questionState = .submit
        
        let answerIndex = Int(self.whichTypeQuestionInfo.blocks[currentIndex].correct_answer)! - 1
        if indexPath.row == answerIndex {
            
            self.completeRate = self.completeRate + (100/whichTypeQuestionInfo.blocks.count)
            self.currentIndex = self.currentIndex+1
            self.timeTakenToSolve = currentIndex*self.whichTypeQuestionInfo.time_interval
            if(currentIndex < self.whichTypeQuestionInfo.blocks.count) {
                self.questionState = .inProgress
                isUserInteraction = false
                self.isRightAnswer = true
                self.currentIndex = self.currentIndex-1
                SpeechManager.shared.speak(message: SpeechMessage.excellentWork.getMessage(self.whichTypeQuestionInfo.correct_text), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
            } else {
                self.questionState = .submit
                self.currentIndex = self.currentIndex-1
                SpeechManager.shared.speak(message: SpeechMessage.hurrayGoodJob.getMessage(self.whichTypeQuestionInfo.correct_text), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
                
                if(self.currentIndex == 0) {
                    self.imagesCollectionView0.reloadData()
                } else if(self.currentIndex == 1) {
                    self.imagesCollectionView1.reloadData()
                } else if(self.currentIndex == 2) {
                    self.imagesCollectionView2.reloadData()
                } else if(self.currentIndex == 3) {
                    self.imagesCollectionView3.reloadData()
                } else if(self.currentIndex == 4) {
                    self.imagesCollectionView4.reloadData()
                }
            }
        } else {

            
            
            self.currentIndex = self.currentIndex+1
            self.timeTakenToSolve = currentIndex*self.whichTypeQuestionInfo.time_interval
            if(currentIndex < self.whichTypeQuestionInfo.blocks.count) {
                self.questionState = .inProgress
                isUserInteraction = false
                self.isRightAnswer = true
                self.currentIndex = self.currentIndex-1
                
                var model:ImageModel!
                if(collectionView.tag < self.whichTypeQuestionInfo.blocks.count) {
                    model = self.whichTypeQuestionInfo.blocks[collectionView.tag].imagesList[answerIndex]
                    SpeechManager.shared.speak(message: SpeechMessage.rectifyAnswer.getMessage()+model.name, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
                }
            } else {
                self.currentIndex = self.currentIndex-1
                var model:ImageModel!
                if(collectionView.tag < self.whichTypeQuestionInfo.blocks.count) {
                    model = self.whichTypeQuestionInfo.blocks[collectionView.tag].imagesList[answerIndex]
                    SpeechManager.shared.speak(message: SpeechMessage.rectifyAnswer.getMessage()+model.name, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
                }
            }
        }
        collectionView.reloadData()
    }
    
}

// MARK: Speech Manager Delegate Methods
extension AssessmentMultiArrayQuestionViewController: SpeechManagerDelegate {
    func speechDidFinish(speechText:String) {
        if(speechText == self.whichTypeQuestionInfo.question_title) {
            self.questionTitle.text = self.whichTypeQuestionInfo.blocks[currentIndex].question_title
            //SpeechManager.shared.speak(message:  self.whichTypeQuestionInfo.blocks[currentIndex].question_title, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
            //return
        } else {
            if(currentIndex < self.whichTypeQuestionInfo.blocks.count) {
                if(speechText == self.whichTypeQuestionInfo.blocks[currentIndex].question_title) {
                    self.avatarImageView.isHidden = true
                    isUserInteraction = true
                    return
                }
            }
        }
        
        self.avatarImageView.isHidden = true

        if let type = Utility.getSpeechMessageType(text: speechText) {
            if type != .hurrayGoodJob && type != .wrongAnswer {
                self.avatarImageView.animatedImage =  idleGif
            }
        } else {
            self.avatarImageView.animatedImage =  idleGif
        }
        
        switch self.questionState {
        case .submit:
            self.stopTimer()
            SpeechManager.shared.setDelegate(delegate: nil)
            self.whichTypeViewModel.submitVerbalQuestionDetails(info: self.whichTypeQuestionInfo, completeRate: completeRate, timetaken: self.timeTakenToSolve, skip: self.skipQuestion, touchOnEmptyScreenCount: self.touchOnEmptyScreenCount)
            
        case .inProgress:
            if(isRightAnswer == true) {
                self.showNextImage()
            } else {
                isUserInteraction = true
            }
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

extension AssessmentMultiArrayQuestionViewController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
        
        if Utility.isNetworkAvailable() {
            Utility.hideRetryView()
            if(self.apiDataState == .notCall) {
                self.listenModelClosures()
            }
            SpeechManager.shared.setDelegate(delegate: self)
        }
    }
}

extension AssessmentMultiArrayQuestionViewController: AutismTimerDelegate {
    func timerUpdate() {
        self.calculateTimeTaken()
    }
}
