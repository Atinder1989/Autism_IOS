//
//  TrialPictureArrayViewController.swift
//  Autism
//
//  Created by Dilip Technology on 08/12/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit

class TrialPictureArrayViewController: UIViewController {
    
    private var matchingObjectInfo: MatchingObjectInfo!
    private let matchingObjectViewModel = TrialMatchingObjectViewModel()
    private weak var delegate: TrialSubmitDelegate?
    
    @IBOutlet weak var collectionOption: UICollectionView!
    @IBOutlet weak var collectionViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var labelTitle: UILabel!
        
    private var answerIndex = -1
    private var success_count = 0
    private var timeTakenToSolve = 0
    private var questionCompletionTimer: Timer? = nil
    private var initialState = true
    private var questionState: QuestionState = .inProgress
    private var skipQuestion = false
    private var isUserInteraction = false {
             didSet {
                 self.view.isUserInteractionEnabled = isUserInteraction
             }
    }
    private var selectedIndex = -1 {
           didSet {
               DispatchQueue.main.async {
                   self.collectionOption.reloadData()
               }
           }
    }
    
    private var apiDataState: APIDataState = .notCall
    private var touchOnEmptyScreenCount = 0

    var is_green_circle:Bool = false
    
    var isFromLearning:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let layout = collectionOption.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }

        collectionOption.register(UINib(nibName: MatchingObjectCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: MatchingObjectCollectionViewCell.identifier)

        self.customSetting()
        self.listenModelClosures()
        
        answerIndex = Int(self.matchingObjectInfo.correct_answer)!-1
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchOnEmptyScreenCount += 1
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.matchingObjectViewModel.stopAllCommands()
    }
    
    @IBAction func exitAssessmentClicked(_ sender: Any) {
           self.stopQuestionCompletionTimer()
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
    
extension TrialPictureArrayViewController {
    func setMatchingObjectInfo(info:MatchingObjectInfo, delegate:TrialSubmitDelegate) {
        self.apiDataState = .dataFetched
        self.matchingObjectInfo = info
        self.delegate = delegate
    }
    
    func setMatchingObjectInfo(info:MatchingObjectInfo) {
        self.apiDataState = .dataFetched
        self.matchingObjectInfo = info
    }
}

extension TrialPictureArrayViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.matchingObjectInfo.image_with_text.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        if(UIDevice.current.userInterfaceIdiom == .pad) {
            return CGSize.init(width: 260, height: 260)
        } else {
            return CGSize.init(width: 140, height: 140)
        }
       }

// make a cell for each cell index path
internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier:MatchingObjectCollectionViewCell.identifier, for: indexPath as IndexPath) as! MatchingObjectCollectionViewCell
    cell.clipsToBounds = true
    let optionSelected = self.matchingObjectInfo.image_with_text[indexPath.row]
    let urlString = ServiceHelper.baseURL.getMediaBaseUrl() + optionSelected.image
    cell.imageObject.setImageWith(urlString: urlString)
    cell.greenTickImageView.isHidden = true
    
    if(UIDevice.current.userInterfaceIdiom == .pad) {
        cell.imageObject.frame = CGRect(x: 0, y: 0, width: 260, height: 260)
    } else {
        cell.imageObject.frame = CGRect(x: 0, y: 0, width: 140, height: 140)
    }
    cell.imageObject.transform = CGAffineTransform.identity.scaledBy(x: 1, y: 1) // Scale your image
    cell.imageObject.backgroundColor = .clear
    
     if selectedIndex == -1 {

     } else {
        if indexPath.row == answerIndex {
            if(is_green_circle == false) {
            cell.greenTickImageView.isHidden = false
            cell.greenTickImageView.image = UIImage.init(named: "greenTick")
            }
            
            if(selectedIndex == answerIndex) {
            } else {
                Animations.shake(on: cell)
            }
        }
        else if selectedIndex == indexPath.row {
            cell.fingerImageView.isHidden = true
            
            cell.greenTickImageView.isHidden = false
            cell.greenTickImageView.image = UIImage.init(named: "cross")
        } else {
            cell.fingerImageView.isHidden = true
        }
    }

    return cell
}

func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    self.selectedIndex = indexPath.row
    self.questionState = .submit

    if indexPath.row == answerIndex {
        self.success_count = 100
        SpeechManager.shared.speak(message: SpeechMessage.hurrayGoodJob.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
    } else {
        let objImage = self.matchingObjectInfo.image_with_text[answerIndex]
        self.success_count = 0
        SpeechManager.shared.speak(message: SpeechMessage.rectifyAnswer.getMessage()+objImage.name, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
    }
}
}

extension TrialPictureArrayViewController {
    func setSortQuestionInfo(info:MatchingObjectInfo, delegate:TrialSubmitDelegate) {
        self.matchingObjectInfo = info
        self.delegate = delegate
    }
}

extension TrialPictureArrayViewController {
    private func customSetting() {
        

        labelTitle.isHidden = false
        collectionOption.isHidden = false
        
        self.isUserInteraction = false
        SpeechManager.shared.setDelegate(delegate: self)
        SpeechManager.shared.speak(message:  matchingObjectInfo.question_title, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        collectionOption.register(UINib(nibName: MatchingObjectCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: MatchingObjectCollectionViewCell.identifier)
        labelTitle.text = matchingObjectInfo.question_title
        self.initializeTimer()
                

        if(UIDevice.current.userInterfaceIdiom == .pad) {
            self.collectionViewWidthConstraint.constant = CGFloat(280*self.matchingObjectInfo.image_with_text.count)
        } else {
            self.collectionViewWidthConstraint.constant = CGFloat(150*self.matchingObjectInfo.image_with_text.count)
        }

        collectionOption.clipsToBounds = true
        if self.matchingObjectInfo.prompt_detail.count > 0 {
            self.matchingObjectViewModel.setQuestionInfo(info:matchingObjectInfo)
        }
    }
    
    private func listenModelClosures() {
       self.matchingObjectViewModel.dataClosure = {
          DispatchQueue.main.async {
                if let res = self.matchingObjectViewModel.trialSubmitResponseVO {
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
        
        self.matchingObjectViewModel.startPracticeClosure = {
            DispatchQueue.main.async {
                //self.customSetting()
            }
        }
        
        self.matchingObjectViewModel.showImageClosure = { questionInfo in
             DispatchQueue.main.async {
             }
        }
        
        //P1
        self.matchingObjectViewModel.blinkImageClosure = { questioninfo in
            DispatchQueue.main.async { [self] in
                
                for i in 0..<self.matchingObjectInfo.image_with_text.count {
                    let img = self.matchingObjectInfo.image_with_text[i]
                    if(img.id == questioninfo.value_id) {
                        let collection:MatchingObjectCollectionViewCell = self.collectionOption.cellForItem(at: IndexPath.init(row: i, section: 0)) as! MatchingObjectCollectionViewCell
                        self.blink(collection.imageObject, count: 3)
                    }
                }
             }
        }
        
        //P2
        self.matchingObjectViewModel.showGreenCircleClosure = { questioninfo in
            DispatchQueue.main.async { [self] in
                
                for i in 0..<self.matchingObjectInfo.image_with_text.count {
                    let img = self.matchingObjectInfo.image_with_text[i]
                    if(img.id == questioninfo.value_id) {
                        let collectionCell:MatchingObjectCollectionViewCell = self.collectionOption.cellForItem(at: IndexPath.init(row: i, section: 0)) as! MatchingObjectCollectionViewCell
                        self.green_circle(collectionCell.imageObject, count: 3)
                    }
                }
             }
        }
        
        //P3
        self.matchingObjectViewModel.showFingerOnImageClosure = { questioninfo in
            DispatchQueue.main.async { [self] in

                for i in 0..<self.matchingObjectInfo.image_with_text.count {
                    let img = self.matchingObjectInfo.image_with_text[i]
                    if(img.id == questioninfo.value_id) {
                        let collectionCell:MatchingObjectCollectionViewCell = self.collectionOption.cellForItem(at: IndexPath.init(row: i, section: 0)) as! MatchingObjectCollectionViewCell
                        self.show_finger_on_image(collectionCell.fingerImageView, count: 3)
                    }
                }
             }
        }
        
        //P4 P6
        self.matchingObjectViewModel.showTapFingerAnimationClosure = { questioninfo in
            DispatchQueue.main.async { [self] in
                
                for i in 0..<self.matchingObjectInfo.image_with_text.count {
                    let img = self.matchingObjectInfo.image_with_text[i]
                    if(img.id == questioninfo.value_id) {
                        let collectionCell:MatchingObjectCollectionViewCell = self.collectionOption.cellForItem(at: IndexPath.init(row: i, section: 0)) as! MatchingObjectCollectionViewCell
                        self.show_tap_fingure_animation(collectionCell.fingerImageView, count: 3)
                    }
                }
             }
        }
        
        //P5.1
        self.matchingObjectViewModel.makeBiggerClosure = { questioninfo in
            DispatchQueue.main.async { [self] in
                                
                for i in 0..<self.matchingObjectInfo.image_with_text.count {
                    let img = self.matchingObjectInfo.image_with_text[i]

                    if(img.id == questioninfo.value_id) {
                        let collectionCell:MatchingObjectCollectionViewCell = self.collectionOption.cellForItem(at: IndexPath.init(row: i, section: 0)) as! MatchingObjectCollectionViewCell
                        collectionOption.bringSubviewToFront(collectionCell)

                        if(selectedIndex >= 0) {
                            
                        } else {
                            if(self.answerIndex == self.matchingObjectInfo.image_with_text.count-1) {
                                Animations.makeBiggerAnimation(isLeft:false, imageView: collectionCell.imageObject, questionInfo: questioninfo) { (finished) in
                                    self.matchingObjectViewModel.updateCurrentCommandIndex()
                                }
                            } else {
                                Animations.makeBiggerAnimation(imageView: collectionCell.imageObject, questionInfo: questioninfo) { (finished) in
                                    self.matchingObjectViewModel.updateCurrentCommandIndex()
                                }
                            }
                        }
                    }
                }
             }
        }
        
        //P5.2
        self.matchingObjectViewModel.makeImageNormalClosure = { questioninfo in
            DispatchQueue.main.async { [self] in
                
                for i in 0..<self.matchingObjectInfo.image_with_text.count {
                    let img = self.matchingObjectInfo.image_with_text[i]
                    if(img.id == questioninfo.value_id) {
                        let collectionCell:MatchingObjectCollectionViewCell = self.collectionOption.cellForItem(at: IndexPath.init(row: i, section: 0)) as! MatchingObjectCollectionViewCell
                        collectionOption.bringSubviewToFront(collectionCell)
                        
                        if(selectedIndex >= 0) {
                            
                        } else {
                            if(self.answerIndex == self.matchingObjectInfo.image_with_text.count-1) {
                                Animations.normalImageAnimation(isLeft:false, imageView: collectionCell.imageObject, questionInfo: questioninfo) { (finished) in
                                    self.matchingObjectViewModel.updateCurrentCommandIndex()
                                }
                            } else {
                                Animations.normalImageAnimation(imageView: collectionCell.imageObject, questionInfo: questioninfo) { (finished) in
                                    self.matchingObjectViewModel.updateCurrentCommandIndex()
                                }
                            }
                        }
                    }
                }
             }
        }
    }

    //Methods
    //P1
    private func blink(_ imageView: UIImageView, count: Int) {
        
        if(selectedIndex >= 0) {
            return
        }
        if count == 0 {
            self.matchingObjectViewModel.updateCurrentCommandIndex()
            return
        }
        UIView.animate(withDuration: learningAnimationDuration-2, animations: {
            imageView.alpha = 0.2
        }) { [self] finished in
            UIView.animate(withDuration: learningAnimationDuration-2, animations: {
                imageView.alpha = 1.0
            }) { [self] finished in
                blink(imageView, count: count - 1)
            }
        }
    }
    //P2
    private func green_circle(_ imageView: UIImageView, count: Int) {
        
        if(selectedIndex >= 0) {
            return
        }
        if count == 0 {
            self.matchingObjectViewModel.updateCurrentCommandIndex()
            return
        }
        self.is_green_circle = true
        self.selectedIndex = self.answerIndex
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
            self.is_green_circle = false
            self.selectedIndex = -1
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0, execute: {
            self.green_circle(imageView, count: count - 1)
        })
    }
    
    //P3
    private func show_finger_on_image(_ imageView: UIImageView, count: Int) {
        if(selectedIndex >= 0) {
            imageView.isHidden = true
            return
        }
        if count == 0 {
            self.matchingObjectViewModel.updateCurrentCommandIndex()
            return
        }
         
        let width = (self.collectionOption.frame.width-CGFloat((self.matchingObjectInfo.image_with_text.count*20)))/CGFloat(self.matchingObjectInfo.image_with_text.count)
        let widthHalf = width/2.0
        
        let height = self.collectionOption.frame.height
        let heightHalf = height/2.0
        
        imageView.frame = CGRect(x: widthHalf/2, y: heightHalf+30, width: widthHalf, height: widthHalf)
        imageView.isHidden =  false
        
    }
    
    //P4 & P6
    private func show_tap_fingure_animation(_ imageView: UIImageView, count: Int) {
        
        if(selectedIndex >= 0) {
            imageView.isHidden = true
            return
        }
        if count == 0 {
            self.matchingObjectViewModel.updateCurrentCommandIndex()
            return
        }
                
        imageView.isHidden = false
        let width = (self.collectionOption.frame.width-CGFloat((self.matchingObjectInfo.image_with_text.count*20)))/CGFloat(self.matchingObjectInfo.image_with_text.count)
        let widthHalf = width/2.0
        
        imageView.frame = CGRect(x: widthHalf-(widthHalf/2), y: width, width: widthHalf, height: widthHalf)
        imageView.isHidden =  false
        
        UIView.animate(withDuration: learningAnimationDuration-2, animations: {
            imageView.frame = CGRect(x: widthHalf-(widthHalf/2), y: widthHalf-(widthHalf/2), width: widthHalf, height: widthHalf)
        }) { [self] finished in
            UIView.animate(withDuration: learningAnimationDuration-2, animations: {
                imageView.alpha = 1.0
            }) { [self] finished in
                imageView.isHidden = true
                imageView.frame = CGRect(x: widthHalf-(widthHalf/2), y: width, width: widthHalf, height: widthHalf)
                show_tap_fingure_animation(imageView, count: count - 1)
            }
        }
    }

}

extension TrialPictureArrayViewController {
    
    private func moveToNextQuestion() {
          self.stopQuestionCompletionTimer()
          self.questionState = .submit
          self.success_count = 0
          SpeechManager.shared.speak(message: SpeechMessage.moveForward.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
    }
    
    private func initializeTimer() {
        questionCompletionTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(calculateTimeTaken), userInfo: nil, repeats: true)
    }
    @objc private func calculateTimeTaken() {
        
        if !Utility.isNetworkAvailable() {
            return
        }
        print("Match Object")
        self.timeTakenToSolve += 1
        print(timeTakenToSolve)
        if self.timeTakenToSolve == self.matchingObjectInfo.trial_time {
            SpeechManager.shared.speak(message: SpeechMessage.keepTrying.getMessage(), uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
        } else if self.timeTakenToSolve == self.matchingObjectInfo.completion_time {
            self.moveToNextQuestion()
    }
}

    private func stopQuestionCompletionTimer() {
    if let timer = self.questionCompletionTimer {
              timer.invalidate()
        self.questionCompletionTimer = nil
    }
}
 
    func submitTrialMatchingAnswer(info:MatchingObjectInfo) {

        if let user = UserManager.shared.getUserInfo() {

            let parameters: [String : Any] = [
               ServiceParsingKeys.user_id.rawValue :user.id,
               ServiceParsingKeys.question_type.rawValue :info.question_type,
               ServiceParsingKeys.time_taken.rawValue :self.timeTakenToSolve,
               ServiceParsingKeys.complete_rate.rawValue :success_count,
               ServiceParsingKeys.success_count.rawValue : success_count,
               ServiceParsingKeys.question_id.rawValue :info.id,
               ServiceParsingKeys.language.rawValue:user.languageCode,
               ServiceParsingKeys.req_no.rawValue:info.req_no,
               ServiceParsingKeys.skill_domain_id.rawValue:info.skill_domain_id,
               ServiceParsingKeys.level.rawValue:info.level,
               ServiceParsingKeys.skip.rawValue:skipQuestion,
                ServiceParsingKeys.program_id.rawValue:info.program_id,

                ServiceParsingKeys.course_type.rawValue:"Trial",
                ServiceParsingKeys.prompt_type.rawValue:info.prompt_type,

                ServiceParsingKeys.touchOnEmptyScreenCount.rawValue:touchOnEmptyScreenCount,
                ServiceParsingKeys.faceDetectionTime.rawValue:FaceDetection.shared.getFaceDetectionTime(),
                ServiceParsingKeys.faceNotDetectionTime.rawValue:FaceDetection.shared.getFaceNotDetectionTime(),
            ]
            LearningManager.submitTrialMatchingAnswer(parameters: parameters)
        }
    }
}

// MARK: Speech Manager Delegate Methods
extension TrialPictureArrayViewController: SpeechManagerDelegate {
    func speechDidFinish(speechText:String) {
        switch self.questionState {
        case .submit:
            self.stopQuestionCompletionTimer()
            SpeechManager.shared.setDelegate(delegate: nil)
            
            if(self.isFromLearning == false) {
                self.matchingObjectViewModel.submitUserAnswer(successCount: self.success_count, info: self.matchingObjectInfo, timeTaken: self.timeTakenToSolve, skip: self.skipQuestion, touchOnEmptyScreenCount: self.touchOnEmptyScreenCount, selectedIndex: self.selectedIndex)
            } else {
                self.submitTrialMatchingAnswer(info: self.matchingObjectInfo)
            }
            
            break
        default:
            self.isUserInteraction = true
            break
        }
    }
    
    func speechDidStart(speechText:String) {
        self.isUserInteraction = false

    }
}


extension TrialPictureArrayViewController: NetworkRetryViewDelegate {
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

