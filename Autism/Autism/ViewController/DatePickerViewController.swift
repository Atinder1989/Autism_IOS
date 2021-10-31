//
//  DatePickerViewController.swift
//  Autism
//
//  Created by Atinderpal Singh on 2020/05/18.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit

protocol DatePickerViewControllerDelegate:NSObject {
    func donePressed(dateString:String)
    func cancelPressed()
}

extension DatePickerViewControllerDelegate {
    func donePressed(dateString:String) {}
    func cancelPressed() {}
}

class DatePickerViewController: UIViewController {
    @IBOutlet weak var datePicker: UIDatePicker!
    weak var delegate: DatePickerViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.timeZone = NSTimeZone(forSecondsFromGMT: 0) as TimeZone
        datePicker.maximumDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())
    }
    
    override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    }
    
    @IBAction func dateChanged(_ sender: UIDatePicker) {
        print(sender.date)
    }

    @IBAction func doneClicked(_ sender: UIDatePicker) {
        if let del = self.delegate {
            let df = DateFormatter()
            df.dateFormat = "dd-MM-yyyy"
            let dateString = df.string(from: datePicker.date)
            del.donePressed(dateString: dateString)
        }
    }
    
    @IBAction func cancelChanged(_ sender: UIDatePicker) {
        if let del = self.delegate {
            del.cancelPressed()
        }
    }
}
