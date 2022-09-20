//
//  UserProfileViewModel.swift
//  Autism
//
//  Created by Atinderpal Singh on 2020/05/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

class UserProfileViewModel:NSObject {
    var labelsClosure : (() -> Void)?
    var dropdownClosure : (() -> Void)?
    var editProfileDataClosure : ((_ labelsResponseVO: ScreenLabelResponseVO,_ editProfile:EditUserProfileResponse) -> Void)?

    var submitClosure : ((UserProfileSubmitResponseVO) -> Void)?
    var noNetWorkClosure: (() -> Void)?
    
    private var othterDetailFormlist = [FormModel]()
    private var reinforcerFormlist = [FormModel]()
    private var isDropDownResponse = false
    private var isEditProfile = false

    var labelsResponseVO: ScreenLabelResponseVO? = nil {
        didSet {
            if let closure = self.labelsClosure {
                closure()
            }
        }
    }
    
    var dropDownListResponseVO: DropDownListResponseVO? = nil {
           didSet {
               if let closure = self.dropdownClosure {
                    if isDropDownResponse {
                        self.isDropDownResponse = false
                        closure()
                    }
               }
           }
    }
    
    func isUserEditProfile() -> Bool {
        return isEditProfile
    }
    
    func updateSensoryIssueList(list:[OptionModel]) {
            self.dropDownListResponseVO?.sensoryIssueList.removeAll()
            self.dropDownListResponseVO?.sensoryIssueList = list
    }
    
    func updateChallengingBehaviourList(list:[OptionModel]) {
            self.dropDownListResponseVO?.challengingBehaviourList.removeAll()
            self.dropDownListResponseVO?.challengingBehaviourList = list
    }
    
    
    func updateOtherDetailsList(list:[OptionModel]) {
        self.dropDownListResponseVO?.otherDetail.removeAll()
        self.dropDownListResponseVO?.otherDetail = list
    }
    
    func updateOtherSubDetailFormList(formList:[FormModel]) {
        self.othterDetailFormlist.removeAll()
        self.othterDetailFormlist = formList
    }

    func updateReinforcerFormList(formList:[FormModel]) {
        self.reinforcerFormlist.removeAll()
        self.reinforcerFormlist = formList
    }

    
    func fetchProfileScreenLabels(isEditProfile:Bool) {
        self.isEditProfile = isEditProfile
        if !Utility.isNetworkAvailable() {
            if let noNetwork = self.noNetWorkClosure {
                       noNetwork()
            }
            return
        }
        var service = Service.init(httpMethod: .POST)
        service.url = ServiceHelper.screenLabelUrl()
        if let user = UserManager.shared.getUserInfo() {
        service.params = [
            ServiceParsingKeys.screen_id.rawValue:ScreenLabel.userprofile.rawValue,
            ServiceParsingKeys.language.rawValue:user.languageCode
        ]
        }
        ServiceManager.processDataFromServer(service: service, model: ScreenLabelResponseVO.self) { (responseVo, error) in
            if let e = error {
                print(e.localizedDescription)
                self.labelsResponseVO = nil
            } else {
                if let response = responseVo {
                    self.labelsResponseVO = response
                    self.fetchProfileDataDropDownList()
                }
            }
        }
    }
    
    func fetchProfileDataDropDownList() {
        var service = Service.init(httpMethod: .POST)
        service.url = ServiceHelper.userProfileDataDropDownListUrl()
        if let user = UserManager.shared.getUserInfo() {
        service.params = [
            ServiceParsingKeys.language.rawValue:user.languageCode
        ]
        }
        ServiceManager.processDataFromServer(service: service, model: DropDownListResponseVO.self) { (responseVo, error) in
            if let e = error {
                print(e.localizedDescription)
            } else {
                if let response = responseVo {
                    self.isDropDownResponse = true
                    //if !self.isEditProfile {
                        self.dropDownListResponseVO = response
                    //}
                }
            }
            
            if self.isEditProfile {
                self.fetchEditProfileData()
            }
        }
    }
    
    func fetchEditProfileData() {
        var service = Service.init(httpMethod: .POST)
        service.url = ServiceHelper.edituserProfileUrl()
        if let user = UserManager.shared.getUserInfo() {
        service.params = [
            ServiceParsingKeys.userid.rawValue:user.id
        ]
        }
        ServiceManager.processDataFromServer(service: service, model: EditUserProfileResponse.self) { (responseVo, error) in
            if let e = error {
                print(e.localizedDescription)
            } else {
                if let response = responseVo {
                    if let closure = self.editProfileDataClosure, let labelResponse = self.labelsResponseVO {
                        self.updateallList(editProfileResponse: response)
                        closure(labelResponse,response)
                    }
                }
            }
           
        }
    }
    
    private func updateallList(editProfileResponse:EditUserProfileResponse) {
        if let dropdownResponse = self.dropDownListResponseVO {
            var updatedResponse = dropdownResponse
            var sensoryList = [OptionModel]()
            var challengingBehaviourList = [OptionModel]()
            var reinforcerList = [OptionModel]()
            var otherDetailList = [OptionModel]()

            for model in dropdownResponse.sensoryIssueList {
                for editmodel in editProfileResponse.sensoryIssueList {
                    if editmodel.option == model.id {
                        var newModel = OptionModel.init(id: model.id, name: model.name, lngCode: model.language_code, isyes: false, isno: false, isdontknow: false, infoList: model.otherDetailInfoList, info: model.info)
                        if editmodel.value == "yes" {
                            newModel.isYes = true
                        } else if editmodel.value == "no" {
                            newModel.isNo = true
                        } else if editmodel.value == "dont_know" {
                            newModel.isDontKnow = true
                        }
                        sensoryList.append(newModel)
                        break
                    }
                }
            }
            
            for model in dropdownResponse.challengingBehaviourList {
                for editmodel in editProfileResponse.challengingBehaviourList {
                    if editmodel.option == model.id {
                        var newModel = OptionModel.init(id: model.id, name: model.name, lngCode: model.language_code, isyes: false, isno: false, isdontknow: false, infoList: model.otherDetailInfoList, info: model.info)
                        if editmodel.value == "yes" {
                            newModel.isYes = true
                        } else if editmodel.value == "no" {
                            newModel.isNo = true
                        } else if editmodel.value == "dont_know" {
                            newModel.isDontKnow = true
                        }
                        challengingBehaviourList.append(newModel)
                        break
                    }
                }
            }
            
            for model in dropdownResponse.otherDetail {
                for editmodel in editProfileResponse.otherDetail {
                    if editmodel.option == model.id {
                        var newModel = OptionModel.init(id: model.id, name: model.name, lngCode: model.language_code, isyes: false, isno: false, isdontknow: false, infoList: model.otherDetailInfoList, info: model.info)
                        if editmodel.value == "yes" {
                            newModel.isYes = true
                        } else if editmodel.value == "no" {
                            newModel.isNo = true
                        } else if editmodel.value == "dont_know" {
                            newModel.isDontKnow = true
                        }
                        otherDetailList.append(newModel)
                        break
                    }
                }
            }
            
            
            updatedResponse.sensoryIssueList.removeAll()
            updatedResponse.sensoryIssueList = sensoryList
            
            updatedResponse.challengingBehaviourList.removeAll()
            updatedResponse.challengingBehaviourList = challengingBehaviourList
            
            updatedResponse.otherDetail.removeAll()
            updatedResponse.otherDetail = otherDetailList
         
            self.dropDownListResponseVO = updatedResponse
        }
    }
    
    func submitUserProfile(basicinfo:[FormModel]) {
        
           var service = Service.init(httpMethod: .POST)
        if !self.isEditProfile {
            service.url = ServiceHelper.userProfileSubmitDataUrl()
        } else {
            service.url = ServiceHelper.updateUserProfileUrl()
        }

        if let user = UserManager.shared.getUserInfo() {
            let paramsDict :[String: Any] =  [
                ServiceParsingKeys.language_code.rawValue:user.languageCode,
                ServiceParsingKeys.user_id.rawValue : user.id,
                ServiceParsingKeys.nickname.rawValue :Utility.encrypt(text: basicinfo[0].text),
                ServiceParsingKeys.dob.rawValue :Utility.encrypt(text: basicinfo[1].text),
                ServiceParsingKeys.guardian_name.rawValue :Utility.encrypt(text: basicinfo[2].text),
                ServiceParsingKeys.country.rawValue :Utility.encrypt(text: basicinfo[3].text),
                ServiceParsingKeys.state.rawValue :Utility.encrypt(text: basicinfo[4].text),
                ServiceParsingKeys.city.rawValue :Utility.encrypt(text: basicinfo[5].text),
                ServiceParsingKeys.parent_contact_number.rawValue :Utility.encrypt(text: basicinfo[6].text),
                ServiceParsingKeys.sensory_issue.rawValue:self.getSensoryIssueParams(),
                ServiceParsingKeys.reinforcer.rawValue:self.getReinforcerParams(),
                ServiceParsingKeys.challenging_behaviour.rawValue:self.getChallengingBehaviourParams(),
                ServiceParsingKeys.other_detail.rawValue:self.getOtherDetailsParams()
            ]
             service.params = paramsDict
         }
           ServiceManager.processDataFromServer(service: service, model: UserProfileSubmitResponseVO.self) { (responseVo, error) in
               if let e = error {
                   print(e.localizedDescription)
               } else {
                
                   if let response = responseVo {
                    UserManager.shared.updateUserProfileInfo(response: response)
                    if let closure = self.submitClosure {
                        closure(response)
                    }
                   }
               }
           }
       }

    func submitDeviceToken(fcmToken:String) {
                   
        var service = Service.init(httpMethod: .POST)
        service.url = ServiceHelper.getNotificationSubscribeUrl()
        
        if let user = UserManager.shared.getUserInfo() {
            let token:String =  user.token
            service.headers = ["Authorization": "Bearer "+token]
        }

        let paramsDict :[String: Any] =  [ServiceParsingKeys.device_id.rawValue:fcmToken]
        service.params = paramsDict
           ServiceManager.processDataFromServer(service: service, model: UserDeviceSubmitResponseVO.self) { (responseVo, error) in
               if let e = error {
                   print(e.localizedDescription)
               } else {
                   if let response = responseVo {
//                       UserManager.shared.updateUserProfileInfo(response: response)
//                        if let closure = self.submitClosure {
//                            closure(response)
//                        }
                    }
               }
           }
       }

}

// MARK: Private Methods
extension UserProfileViewModel {
    private func getReinforcerParams() -> [[String:String]] {
          var array = [[String:String]]()
          if let res = self.dropDownListResponseVO {
              for formModel in self.reinforcerFormlist {
                  var dict : [String:String] = [:]
                  for listmodel in res.reinforcerList {
                      if formModel.text == listmodel.name {
                          dict[ServiceParsingKeys.option.rawValue] = listmodel.id
                          dict[ServiceParsingKeys.value.rawValue] = self.labelsResponseVO?.getLiteralof(code: UserProfileLabelCode.yes.rawValue).label_code
                          array.append(dict)
                      }
                  }
              }
          }
          return array
      }
    
    private func getSensoryIssueParams() -> [[String:String]] {
          var array = [[String:String]]()
          if let res = self.dropDownListResponseVO {
              for model in res.sensoryIssueList {
                  var dict : [String:String] = [:]
                  dict[ServiceParsingKeys.option.rawValue] = model.id
                  
                  if model.isYes {
                      dict[ServiceParsingKeys.value.rawValue] = self.labelsResponseVO?.getLiteralof(code: UserProfileLabelCode.yes.rawValue).label_code
                  } else if model.isNo {
                      dict[ServiceParsingKeys.value.rawValue] = self.labelsResponseVO?.getLiteralof(code: UserProfileLabelCode.no.rawValue).label_code
                  } else if model.isDontKnow {
                      dict[ServiceParsingKeys.value.rawValue] = self.labelsResponseVO?.getLiteralof(code: UserProfileLabelCode.dont_know.rawValue).label_code
                  }
                  array.append(dict)
              }
          }
          return array
      }
    
    
    private func getOtherDetailsParams() -> [[String:Any]] {
            
              var array = [[String:Any]]()
              if let res = self.dropDownListResponseVO {
                  for model in res.otherDetail {
                    var dict : [String:Any] = [:]
                    dict[ServiceParsingKeys.option.rawValue] = model.id
                      if model.isYes {
                          dict[ServiceParsingKeys.value.rawValue] = self.labelsResponseVO?.getLiteralof(code: UserProfileLabelCode.yes.rawValue).label_code
                        if model.otherDetailInfoList.count > 0 {
                            var arrayString = [String]()
                            for fModel in self.othterDetailFormlist {
                                if fModel.title.lowercased().contains(model.name.lowercased()) {
                                    arrayString = fModel.text.components(separatedBy: ",")
                                    break
                                }
                            }
                            var arrayOfDetail = [[String:String]]()
                            for text in arrayString {
                                var subdict : [String:String] = [:]
                                for m in model.otherDetailInfoList {
                                    if text == m.name {
                                        subdict[ServiceParsingKeys.option.rawValue] = m.id
                                        subdict[ServiceParsingKeys.value.rawValue] = self.labelsResponseVO?.getLiteralof(code: UserProfileLabelCode.yes.rawValue).label_code
                                        arrayOfDetail.append(subdict)
                                        break
                                    }
                                }
                            }
                            dict[ServiceParsingKeys.detail.rawValue] = arrayOfDetail
                        }
                      } else if model.isNo {
                          dict[ServiceParsingKeys.value.rawValue] = self.labelsResponseVO?.getLiteralof(code: UserProfileLabelCode.no.rawValue).label_code
                          dict[ServiceParsingKeys.detail.rawValue] = []
                      } else if model.isDontKnow {
                          dict[ServiceParsingKeys.value.rawValue] = self.labelsResponseVO?.getLiteralof(code: UserProfileLabelCode.dont_know.rawValue).label_code
                          dict[ServiceParsingKeys.detail.rawValue] = []
                      }
                      array.append(dict)
                  }
              }
              return array
    }
    
    private func getChallengingBehaviourParams() -> [[String:String]] {
             var array = [[String:String]]()
             if let res = self.dropDownListResponseVO {
                 for model in res.challengingBehaviourList {
                     var dict : [String:String] = [:]
                     dict[ServiceParsingKeys.option.rawValue] = model.id
                     
                     if model.isYes {
                         dict[ServiceParsingKeys.value.rawValue] = self.labelsResponseVO?.getLiteralof(code: UserProfileLabelCode.yes.rawValue).label_code
                     } else if model.isNo {
                         dict[ServiceParsingKeys.value.rawValue] = self.labelsResponseVO?.getLiteralof(code: UserProfileLabelCode.no.rawValue).label_code
                     } else if model.isDontKnow {
                         dict[ServiceParsingKeys.value.rawValue] = self.labelsResponseVO?.getLiteralof(code: UserProfileLabelCode.dont_know.rawValue).label_code
                     }
                     array.append(dict)
                 }
             }
             return array
         }
       
}

