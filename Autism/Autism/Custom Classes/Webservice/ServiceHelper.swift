//
//  ServiceHelper.swift
//  Assignment
//
//  Created by Atinderpal Singh on 05/02/19.
//  Copyright © 2019 Abc. All rights reserved.
//

import Foundation

class ServiceHelper: NSObject {
    static var baseURL: ServiceEnvironment {
        get {
            return ServiceEnvironment.DevelopmentNew
        }
    }
}

//MARK: All Apis
extension ServiceHelper {
    static func languageListUrl() -> String {
        return baseURL.rawValue + "languages"
    }
    static func registerUrl() -> String {
        return baseURL.rawValue + "register?"
    }
    static func forgotPasswordUrl() -> String {
           return baseURL.rawValue + "forgot"
       }
    static func loginUrl() -> String {
        return baseURL.rawValue + "login?"
    }
    static func setPriority() -> String {
        return baseURL.rawValue + "updatePriority"
    }
    static func screenLabelUrl() -> String {
        return baseURL.rawValue + "screen_label_refs/label"
    }
    static func challengingBehaviourUrl() -> String {
           return baseURL.rawValue + "challenging_behaviour"
    }
    static func sensoryIssueUrl() -> String {
              return baseURL.rawValue + "sensory_issue"
    }
    static func userProfileDataDropDownListUrl() -> String {
              return baseURL.rawValue + "user_profile_data"
    }
    static func userProfileSubmitDataUrl() -> String {
                 return baseURL.rawValue + "user_profile"
    }
    
    static func edituserProfileUrl() -> String {
                 return baseURL.rawValue + "user_profile/profile"
    }
    static func updateUserProfileUrl() -> String {
                 return baseURL.rawValue + "user_profile/update"
    }
    
    static func getassessmentDashboardUrl() -> String {
                return baseURL.rawValue + "assesmentDashboard"
    }
    
    static func getDashboardUrl() -> String {
                return baseURL.rawValue + "dashboard"
    }
    
    static func getResetAssessmentUrl() -> String {
                return baseURL.rawValue + "resetUserData"
    }
    
  
    static func assessmentQuestionSubmitUrl() -> String {
        return baseURL.rawValue + "submitQuestion"
    }

    static func avatarListUrl() -> String {
            return baseURL.rawValue + "get_avtar_list"
    }
    static func setAvatarUrl() -> String {
            return baseURL.rawValue + "Setavtar"
    }
    static func getUserAvatarUrl() -> String {
               return baseURL.rawValue + "get_user_avatar"
    }
    static func getInsertLogUrl() -> String {
            return baseURL.rawValue + "insertLog"
    }
    static func getUploadImageUrl() -> String {
            return baseURL.rawValue + "upload_answer_image"
    }

    static func getQuestionUrl() -> String {
        return baseURL.rawValue + "getQuestion"
    }
   
    static func parentFeedbackUrl() -> String {
        return baseURL.rawValue + "parent_feedback"
    }
    static func submitParentFeedbackUrl() -> String {
           return baseURL.rawValue + "parentFeedbackSubmit"
    }
   
 
    static func getLearningQuestionUrl() -> String {
        return baseURL.rawValue + "dummy_get_learning_content"//"getLearningQuestion"
    }
    //New Development
    //https://impute.co.jp:5000/v1/dummy_learning_submit
    static func getLearningAnswerUrl() -> String {
        return baseURL.rawValue + "dummy_learning_submit"
    }
   
    
    static func getLearningSkillProgram() -> String {
        return baseURL.rawValue + "getLearningSkillProgram"
    }
    static func getResetLearning() -> String {
        return baseURL.rawValue + "userLearningReset"
    }
    
    //New Development
    //https://impute.co.jp:5000/v1/dummy_get_learning_content
    static func getLearningAlgoUrl() -> String {
                return baseURL.rawValue + "dummy_get_learning_content"
    }
    static func getUserDeleteAccountUrl() -> String {
                return baseURL.rawValue + "userDeleteAccount"
    }
    
    //Algo
    static func trialQuestionUrl() -> String {
        return baseURL.rawValue + "trialQuestion"
    }
    //Algo
    static func trialAnswerUrl() -> String {
        return baseURL.rawValue + "trial_answer"
    }
    
    //Local to check
    static func getTrailQuestion() -> String {
        return baseURL.rawValue + "getTrailQuestion"
    }
    //Local to check
    static func trialQuestionSubmitUrl() -> String {
        return baseURL.rawValue + "trailSubmitAssistAnswer"
    }
}





