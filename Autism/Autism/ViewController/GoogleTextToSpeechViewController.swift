//
//  GoogleTextToSpeechViewController.swift
//  Autism
//
//  Created by Savleen on 25/05/21.
//  Copyright © 2021 IMPUTE. All rights reserved.
//

import UIKit

/*
struct GoogleSpeech {
    var title: String
    //var voiceType: VoiceType
}

class GoogleTextToSpeechViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

//    let voices: [GoogleSpeech] = [
//    GoogleSpeech.init(title: "FEMALE", voiceType: .standardA),
//    GoogleSpeech.init(title: "FEMALE", voiceType: .standardB),
//    GoogleSpeech.init(title: "MALE", voiceType: .standardC),
//    GoogleSpeech.init(title: "MALE", voiceType: .standardD),
//
//    GoogleSpeech.init(title: "FEMALE", voiceType: .waveNetA),
//    GoogleSpeech.init(title: "FEMALE", voiceType: .waveNetB),
//    GoogleSpeech.init(title: "MALE", voiceType: .waveNetC),
//    GoogleSpeech.init(title: "MALE", voiceType: .waveNetD),
//
//    ]
    
    @IBOutlet weak var voiceTableview: UITableView!
    
    @IBOutlet weak var textView: UITextView!


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.voiceTableview.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.voiceTableview.delegate = self
        self.voiceTableview.dataSource = self
    }
    
    @IBAction func backClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return self.voices.count
        }
        
        // create a cell for each table view row
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {


            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
            // set the text from the data model
            cell.textLabel?.text = self.voices[indexPath.row].title + ":   " + self.voices[indexPath.row].voiceType.rawValue
            
            return cell
        }
        
        // method to run when table view cell is tapped
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            print("You tapped cell number \(indexPath.row).")

            /*
            GoogleSpeechService.shared.speak(text: textView.text, voiceType: self.voices[indexPath.row].voiceType) {
                print("####### Finish Speaking");
            }
             */
        }
    

}
*/
