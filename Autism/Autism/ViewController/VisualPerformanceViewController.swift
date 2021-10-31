//
//  VisualPerformanceViewController.swift
//  Autism
//
//  Created by Atinderpal Singh on 2020/04/08.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit

struct PerformanceProgressModel {
    var title: String
    var progressValue: CGFloat
    var progressColor: UIColor
}

class VisualPerformanceViewController: UIViewController {
    @IBOutlet weak var visualPerformanceCollectionView: UICollectionView!
    private var progressModelList = [PerformanceProgressModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.customSetting()
    }
    @IBAction func backClicked(_ sender: Any) {
           self.navigationController?.popViewController(animated: true)
    }

}
//MARK:- UICollectionView Delegate and Datasource Methods

extension VisualPerformanceViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: 250, height: self.visualPerformanceCollectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return progressModelList.count
    }
    
    // make a cell for each cell index path
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PerformanceProgressCell.identifier, for: indexPath) as! PerformanceProgressCell
        cell.setData(model: progressModelList[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
    
}

//MARK:- Private Methods
extension VisualPerformanceViewController {
    private func customSetting() {
        self.progressModelList = [
            PerformanceProgressModel.init(title: "Learning", progressValue: 30, progressColor: .red),
            PerformanceProgressModel.init(title: "Visual", progressValue: 50, progressColor: .green),
            PerformanceProgressModel.init(title: "Play Skills", progressValue: 30, progressColor: .blue),
            PerformanceProgressModel.init(title: "Academics", progressValue: 80, progressColor: .brown),
            PerformanceProgressModel.init(title: "Tacting SKills", progressValue: 60, progressColor: .yellow),
            PerformanceProgressModel.init(title: "Receptive", progressValue: 25, progressColor: .magenta),
            PerformanceProgressModel.init(title: "Syntax & Grammer", progressValue: 75, progressColor: .orange),
            PerformanceProgressModel.init(title: "Sorting", progressValue: 50, progressColor: .red)
        ]
        visualPerformanceCollectionView.register(PerformanceProgressCell.nib, forCellWithReuseIdentifier: PerformanceProgressCell.identifier)
    }
}
