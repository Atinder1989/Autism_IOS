//
//  PopOverContentViewController.swift
//  Autism
//
//  Created by Atinderpal Singh on 2020/05/18.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import UIKit

//struct CountryModel {
//    var name: String
//    var code: String
//}

protocol PopOverContentViewControllerDelegate:NSObject {
    func didSelectState(state:String?)

    func didSelectCountry(country:String?)
    func didSelectMultipleDetailsOf(type:PopOverContentType,selectedList:[Int],formmodel:FormModel?)
    func selectedHistoryIndex(index:Int)
}

extension PopOverContentViewControllerDelegate {
    func didSelectState(state:String?) {}

    func didSelectCountry(country:String?) {}
    func didSelectMultipleDetailsOf(type:PopOverContentType,selectedList:[Int],formmodel:FormModel?) {}
    func selectedHistoryIndex(index:Int){}

}

class PopOverContentViewController: UIViewController {
    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var donebuttonHeight: NSLayoutConstraint!

    weak var delegate: PopOverContentViewControllerDelegate?
    var popOverContentType : PopOverContentType = .none

//    private var countries: [CountryModel] = {
//        var arrayOfCountries: [CountryModel] = []
//        for code in NSLocale.isoCountryCodes as [String] {
//            let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
//            let name = NSLocale(localeIdentifier: "en_UK").displayName(forKey: NSLocale.Key.identifier, value: id) ?? "Country not found for code: \(code)"
//            arrayOfCountries.append(CountryModel.init(name: name, code: code))
//        }
//
//        let array  = arrayOfCountries.sorted(by: { (Obj1, Obj2) -> Bool in
//            return (Obj1.name.localizedCaseInsensitiveCompare(Obj2.name) == .orderedAscending)
//        })
//
//        return array
//    }()
    
    var states: [String] = []
    private var countries: [String] = []
    
    var dropDownList =  [OtherDetailInfo]()
    var reinforcerList =  [OptionModel]()

    var formModel : FormModel? = nil
    var labelResposne : ScreenLabelResponseVO!

    private var selectedIndexList = [Int]()
    private var selectedCountry : String? = nil
    private var selectedState : String? = nil

    var historyList = [AllDates]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.listTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.listTableView.tableFooterView = UIView.init()
        Utility.setView(view: self.doneButton, cornerRadius: 20, borderWidth: 0, color: .clear)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let list = Array(Utility.sharedInstance.countriesDictionary.keys)
        countries = list.sorted(by: <)
        print(countries)
          self.doneButton.setTitle(labelResposne.getLiteralof(code: UserProfileLabelCode.done.rawValue).label_text, for: .normal)
        
        if self.historyList.count > 0 {
            self.donebuttonHeight.constant = 0
        }
    }
    
    @IBAction func doneClicked(_ sender: Any) {
        if let del = self.delegate {
            switch popOverContentType {
            case .state:
                del.didSelectState(state: selectedState)
                case .country:
                    del.didSelectCountry(country: self.selectedCountry)
            case .otherDetails,.reinforcer:
                del.didSelectMultipleDetailsOf(type: self.popOverContentType, selectedList: self.selectedIndexList, formmodel: self.formModel)
                default:
                    if selectedIndexList.count > 0 {
                        del.selectedHistoryIndex(index: selectedIndexList[0])
                    } else {
                        del.selectedHistoryIndex(index:0)
                    }
                    break
            }
        }
    }
    
    func setLabels(lblResponse:ScreenLabelResponseVO,delegate: PopOverContentViewControllerDelegate?){
        self.labelResposne = lblResponse
        self.delegate = delegate
    }
}

// MARK: UITableview Delegates And Datasource Methods
extension PopOverContentViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch popOverContentType {
        case .state:
                return states.count
        case .country:
                return self.countries.count
        case .otherDetails:
            return self.dropDownList.count
        case .reinforcer:
            return self.reinforcerList.count
        default:
            return self.historyList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.listTableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        cell.accessoryType = .none
        cell.selectionStyle = .none
        cell.textLabel?.textColor = UIColor.black
        switch popOverContentType {
        case .country:
            if let country = selectedCountry {
                if country == self.countries[indexPath.row] {
                    cell.accessoryType = .checkmark;
                }
            }
            cell.textLabel?.text = self.countries[indexPath.row]
        case .state:
            if let state = selectedState {
                if state == self.states[indexPath.row] {
                    cell.accessoryType = .checkmark;
                }
            }
            cell.textLabel?.text = self.states[indexPath.row]
            
        case .otherDetails:
            if self.selectedIndexList.contains(indexPath.row)
                       {
                           cell.accessoryType = .checkmark;
                       }
            cell.textLabel?.text = self.dropDownList[indexPath.row].name
        case .reinforcer:
                 if self.selectedIndexList.contains(indexPath.row)
                            {
                                cell.accessoryType = .checkmark;
                            }
                 cell.textLabel?.text = self.reinforcerList[indexPath.row].name
                 cell.imageView?.setImageWith(urlString: ServiceHelper.baseURL.getMediaBaseUrl() + self.reinforcerList[indexPath.row].image, placeholderImage: "applogo")
        default:
            if self.selectedIndexList.contains(indexPath.row)
                       {
                           cell.accessoryType = .checkmark;
                       }
            cell.textLabel?.text = self.historyList[indexPath.row].title
            break
        }
        cell.backgroundColor = .clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            switch popOverContentType {
            case .state:
                self.selectedState = self.states[indexPath.row]
            case .country:
                self.selectedCountry = self.countries[indexPath.row]
            case .otherDetails:
                if self.selectedIndexList.contains(indexPath.row) {
                    if let index = self.selectedIndexList.firstIndex(of: indexPath.row) {
                        self.selectedIndexList.remove(at: index)
                    }
                } else {
                        self.selectedIndexList.append(indexPath.row)
                }
            case .reinforcer:
                if self.selectedIndexList.count > 0 {
                        if let index = self.selectedIndexList.firstIndex(of: indexPath.row) {
                            self.selectedIndexList.remove(at: index)
                        } else {
                            self.selectedIndexList.removeAll()
                            self.selectedIndexList.append(indexPath.row)
                        }
                } else {
                    self.selectedIndexList.append(indexPath.row)
                }
            default:
                if let del = self.delegate {
                    del.selectedHistoryIndex(index: indexPath.row)
                }
                return
            }
        self.listTableView.reloadData()
    }
}
