//
//  DashboardLevelCell.swift
//  Autism
//
//  Created by Savleen on 29/07/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit

class DashboardLevelCell: UICollectionViewCell {
    @IBOutlet weak var levelLbl: UILabel!
    @IBOutlet weak var messageLbl: UILabel!
    @IBOutlet weak var completeLbl: UILabel!
    @IBOutlet weak var levelImageView: UIImageView!
    @IBOutlet weak var starCollectionView: UICollectionView!
    private var levelCount = 0
    private var performanceModel: Performance?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        starCollectionView.delegate = self
        starCollectionView.dataSource = self
        starCollectionView.register(ImageCell.nib, forCellWithReuseIdentifier: ImageCell.identifier)
    }
    
    func setData(model:Performance,levelCount:Int) {
        self.performanceModel = model
        self.levelCount = levelCount
        self.levelLbl.text = model.title
        self.messageLbl.text = model.message
        self.completeLbl.text = "\(model.complete_count)/\(model.count)"
        DispatchQueue.main.async {
            self.starCollectionView.reloadData()
        }
    }
    
    @IBAction func startClicked(_ sender: Any) {
         
    }

}


extension DashboardLevelCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let width = self.starCollectionView.frame.width / CGFloat(self.levelCount)
    return CGSize.init(width: width-5, height: width-5)
}

func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if let performance = self.performanceModel {
        if let value = Int(performance.level) {
            return value
        }
    }
    return 0
}

// make a cell for each cell index path
internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.identifier, for: indexPath) as! ImageCell
    cell.dataImageView.image = UIImage.init(named: "star")
    return cell
}
}
