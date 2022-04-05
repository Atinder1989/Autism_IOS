//
//  ParentFeedbackViewController.swift
//  Autism
//
//  Created by Savleen on 11/08/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit

class ParentFeedbackViewController: UIViewController {
    @IBOutlet weak var feedbackCollectionView: UICollectionView!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var thanksMessageView: UIView!
    @IBOutlet weak var screenTitleLbl: UILabel!
    @IBOutlet weak var parentFeedbackThanksMessageTextview: UITextView!
    @IBOutlet weak var parentFeedbackMessageTextView: UITextView!

    @IBOutlet weak var feedbackMessageNextButton: UIButton!
    @IBOutlet weak var feedbackThanksMessageNextButton: UIButton!

    var messageRead:Bool = false
    private let feedbackModel = ParentFeedbackViewModel()
    private var scrollIndex = 0 {
        didSet {
            self.scrollCollectionViewTo(index: self.scrollIndex)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customSetting()
        self.listenModelClosures()
        self.feedbackModel.fetchParentFeedbackScreenLabels()
    }
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
           // Utility.lockOrientation(UIInterfaceOrientationMask.landscape, andRotateTo: UIInterfaceOrientation.landscapeLeft)
     }
    
    @IBAction func feedbackMessageNextClicked(_ sender: Any) {
        messageRead = true
        DispatchQueue.main.async {
            UIView.animate(withDuration: 1.5, animations: {
                self.messageView.alpha = 0
            }) { (isFinished) in
                self.messageView.isHidden = true
                self.screenTitleLbl.isHidden = false
                self.feedbackCollectionView.isHidden = false
            }
        }
    }
    
    @IBAction func feedbackThanksMessageNextClicked(_ sender: Any) {
        if let user = UserManager.shared.getUserInfo() {
            if  let type = ScreenRedirection.init(rawValue: user.screen_id){
                let vc = type.getViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    

}

//MARK:- Private Methods
extension ParentFeedbackViewController {
    private func customSetting() {
        self.navigationController?.navigationBar.isHidden = true
         feedbackCollectionView.register(ParentFeedbackCell.nib, forCellWithReuseIdentifier: ParentFeedbackCell.identifier)
        Utility.setView(view: self.feedbackCollectionView, cornerRadius: 10, borderWidth: 0, color: .clear)
        Utility.setView(view: self.feedbackMessageNextButton, cornerRadius: Utility.isRunningOnIpad() ? 30 : 20, borderWidth: 0, color: .clear)
        Utility.setView(view: self.feedbackThanksMessageNextButton, cornerRadius: Utility.isRunningOnIpad() ? 30 : 20, borderWidth: 0.5, color: .darkGray)
        Utility.setView(view: self.thanksMessageView, cornerRadius: 10, borderWidth: 0, color: .clear)
    }
    
    private func setLabels(labelresponse:ScreenLabelResponseVO) {
        self.screenTitleLbl.text = labelresponse.getLiteralof(code: ParentFeedbackLabelCode.parentfeedback.rawValue).label_text
        //self.feedbackMessageNextButton.setTitle(labelresponse.getLiteralof(code: ParentFeedbackLabelCode.next.rawValue).label_text, for: .normal)
        //self.feedbackThanksMessageNextButton.setTitle(labelresponse.getLiteralof(code: ParentFeedbackLabelCode.next.rawValue).label_text, for: .normal)
        let message = labelresponse.getLiteralof(code: ParentFeedbackLabelCode.feedbackMessage.rawValue).label_text.replacingOccurrences(of: "\\n", with: "\n\n")
        self.parentFeedbackMessageTextView.text = message
        let thanksMessage = labelresponse.getLiteralof(code: ParentFeedbackLabelCode.feedbackThanksMessage.rawValue).label_text.replacingOccurrences(of: "\\n", with: "\n")
        self.parentFeedbackThanksMessageTextview.text = thanksMessage
        self.messageView.isHidden = false
    }
    
    func setData()
    {
        
    }
    private func listenModelClosures() {
        
        self.feedbackModel.noNetWorkClosure = {
            Utility.showRetryView(delegate: self)
        }
        
        self.feedbackModel.dataClosure = {
             DispatchQueue.main.async {
                if let labelResponse = self.feedbackModel.labelsResponseVO {
                    self.setLabels(labelresponse: labelResponse)
                }
                if let _ = self.feedbackModel.feedbackResponseVo {
                        self.feedbackCollectionView.reloadData()
                }
            }
         }
        
        self.feedbackModel.submitParentFeedbackClosure = { response in
            DispatchQueue.main.async {
                if response.success {
                    self.screenTitleLbl.isHidden = true
                    self.feedbackCollectionView.isHidden = true
                    self.thanksMessageView.isHidden = false
                    self.setData()
                } else {
                        if let labelresponse = self.feedbackModel.labelsResponseVO {
                            Utility.showAlert(title: labelresponse.getLiteralof(code: ParentFeedbackLabelCode.information.rawValue).label_text, message: response.message)
                    }
                }
            }
        }
        
    }
    
    private func showPopOverView(sourceView:UIView, frame:CGRect,vc:UIViewController) {
        if let popoverPresentationController = vc.popoverPresentationController {
            popoverPresentationController.permittedArrowDirections = .any
            popoverPresentationController.sourceView = sourceView
            popoverPresentationController.sourceRect = frame
            present(vc, animated: true, completion: nil)
        }
    }
    
    private func scrollCollectionViewTo(index:Int) {
            self.feedbackCollectionView.scrollToItem(at:IndexPath(item: index, section: 0), at: .centeredVertically, animated: true)
    }
    
}

//MARK:- UICollectionView Datasource and Delegate Methods
extension ParentFeedbackViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: self.feedbackCollectionView.frame.width, height: self.feedbackCollectionView.frame.height)
}

func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if let res = self.feedbackModel.feedbackResponseVo {
        return res.feedbackList.count
    }
   return 0
}

// make a cell for each cell index path
 func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ParentFeedbackCell.identifier, for: indexPath) as! ParentFeedbackCell
    if let res = self.feedbackModel.feedbackResponseVo {
       
        if let labelresponse = self.feedbackModel.labelsResponseVO {
            cell.setData(feedbackModel: res.feedbackList[indexPath.row], delegate: self, lableResponse: labelresponse)

            
            if indexPath.row == 0 {
                cell.btnPrevious.isHidden = true
            } else {
                cell.btnPrevious.isHidden = false
            }
          /*  cell.btnPrevious.setTitle(labelresponse.getLiteralof(code: ParentFeedbackLabelCode.previous.rawValue).label_text, for: .normal)
            
            if indexPath.row == res.feedbackList.count - 1 {
                cell.btnNext.setTitle(labelresponse.getLiteralof(code: ParentFeedbackLabelCode.submit.rawValue).label_text, for: .normal)
            } else {
                cell.btnNext.setTitle(labelresponse.getLiteralof(code: ParentFeedbackLabelCode.next.rawValue).label_text, for: .normal)
            } */
        }
    }
    return cell
    }
}
//MARK:- ParentFeedbackCellDelegate Methods
extension ParentFeedbackViewController: ParentFeedbackCellDelegate {
    func didUpdateFeedbackList(feedbackModel: ParentFeedbackModel) {
        self.feedbackModel.updateFeedbackList(feedbackModel: feedbackModel)
    }
    
    func didClickOnQuestionMark(sender: UIButton, optionModel: ProgramTypeModel) {
          let vc = Utility.getViewController(ofType: OptionDescriptionViewController.self)
              vc.info = optionModel.info
              let popOverWidth:CGFloat = 348
              let sizeText = Utility.getSize(optionModel.info, font: UIFont(name:AppFont.helveticaNeue.rawValue,size:17)!, boundingSize: CGSize(width: popOverWidth, height: 20000.0))
              vc.modalPresentationStyle = .popover
              vc.preferredContentSize = CGSize(width: popOverWidth, height: sizeText.height+20)
             self.showPopOverView(sourceView: sender as UIView, frame: sender.bounds, vc: vc)
        
    }
    func didClickOnNext(){
       let newIndex = self.scrollIndex + 1
        if let res = self.feedbackModel.feedbackResponseVo {
            if newIndex == res.feedbackList.count // Submit Clicked
            {
                self.feedbackModel.submitParentFeedbackList()
            } else {
                self.scrollIndex = newIndex
            }
        }
    }
    
    func didClickOnPrevious(){
        self.scrollIndex = self.scrollIndex - 1
    }
      
}
extension ParentFeedbackViewController: NetworkRetryViewDelegate {
    func didTapOnRetry() {
                
        if Utility.isNetworkAvailable() {
            if(messageRead == true) {
                Utility.hideRetryView()
            } else {
                self.feedbackModel.fetchParentFeedbackScreenLabels()
            }
        }
    }
}

extension ParentFeedbackViewController: ImageDownloaderDelegate {
    func finishDownloading() {
        DispatchQueue.main.async {
            self.setData()
        }
    }
}
