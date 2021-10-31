//
//  FAQViewController.swift
//  Autism
//
//  Created by Atinderpal Singh on 2020/04/03.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit

class FAQViewController: UIViewController {
    @IBOutlet weak var listTableView: UITableView!
    var expandRowIndex = 0
    var list:[FAQModel] = [FAQModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let model1 = FAQModel.init(title: "What is Lorem Ipsum?", text: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.")
        let model2 = FAQModel.init(title: "Why do we use it?", text: "It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using 'Content here, content here', making it look like readable English. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text, and a search for 'lorem ipsum' will uncover many web sites still in their infancy. Various versions have evolved over the years, sometimes by accident, sometimes on purpose (injected humour and the like).")
        list.append(model1)
        list.append(model2)
        listTableView.register(FAQCell.nib, forCellReuseIdentifier: FAQCell.identifier)
        listTableView.tableFooterView = UIView.init()
    }

    @IBAction func backClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

}

// MARK: UITableview Delegates And Datasource Methods
extension FAQViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = self.list[indexPath.row]
        let titleFont = UIFont.init(name: AppFont.helveticaNeue.rawValue, size: 18)
        let titleSize = Utility.textSize(text: model.title, font: titleFont)
        if indexPath.row == expandRowIndex {
            let textFont = UIFont.init(name: AppFont.helveticaNeue.rawValue, size: 16)
            let textSize = Utility.textSize(text: model.text, font: textFont)
            return titleSize.height + 60 + textSize.height + 60
        }
        return titleSize.height + 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FAQCell.identifier) as! FAQCell
        cell.selectionStyle = .none
        cell.setData(model: self.list[indexPath.row])
         return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.expandRowIndex = indexPath.row
        self.listTableView.beginUpdates()
        self.listTableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        self.listTableView.endUpdates()
    }
}


struct FAQModel {
    var title: String
    var text: String
}
