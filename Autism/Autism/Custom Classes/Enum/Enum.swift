//
//  Enum.swift
//  Autism
//
//  Created by Atinderpal Singh on 2020/03/25.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation
import UIKit


enum ForestStageImage : String {
    case start      = "start"
    case goal       = "goal"
    case none     = "none"
}

enum MenuItem : String {
    case changeLanguage = "changeLanguage"
    case editprofile = "editprofile"

    case subscription_plan = "subscription_plan"
    case feedback = "feedback"
    case faqs = "faqs"
    case tutorials = "tutorials"
    case privacy_policy = "privacy_policy"
    case terms_and_conditions = "terms_and_conditions"
    case deleteAccount = "deleteAccount"

    case logout = "logout"
    
    func getName(labelResponse:ScreenLabelResponseVO) -> String {
        var name = ""
        switch self {
        case .editprofile:
            name = labelResponse.getLiteralof(code: DashboardLabelCode.editprofile.rawValue).label_text
        case .changeLanguage:
            name = labelResponse.getLiteralof(code: DashboardLabelCode.changeLanguage.rawValue).label_text
        case .subscription_plan:
            name = labelResponse.getLiteralof(code: DashboardLabelCode.subscription_plan.rawValue).label_text
        case .feedback:
            name = labelResponse.getLiteralof(code: DashboardLabelCode.feedback.rawValue).label_text
        case .faqs:
            name = labelResponse.getLiteralof(code: DashboardLabelCode.faqs.rawValue).label_text
        case .tutorials:
            name = labelResponse.getLiteralof(code: DashboardLabelCode.tutorials.rawValue).label_text
        case .privacy_policy:
            name = labelResponse.getLiteralof(code: DashboardLabelCode.privacy_policy.rawValue).label_text
        case .terms_and_conditions:
            name = labelResponse.getLiteralof(code: DashboardLabelCode.terms_and_conditions.rawValue).label_text
        case .deleteAccount:
            name = labelResponse.getLiteralof(code: DashboardLabelCode.deleteAccount.rawValue).label_text
        case .logout:
            name = labelResponse.getLiteralof(code: DashboardLabelCode.logout.rawValue).label_text
        }
        return name
    }
    
}

enum AppFont: String {
    case helveticaNeue = "HelveticaNeue"
    case MaisonNeueDemi = "MaisonNeue-Demi"
}

enum ScreenLabel:String {
    case login = "login"
    case signup = "register"
    case userprofile = "main_profile"
    case forgot_pass = "forgot_pass"
    case avatar_Selection = "avatar_Selection"
    case begin_Assessment = "begin_Assessment"
    case assessment_Start = "assessment_Start"
    case assessment_Complete = "assessment_Complete"
    case dashboard = "dashboard"
    case parentFeedback = "parentFeedback"
    case begin_Learning = "begin_Learning"
    case modules_name = "modules_name"
}

enum ScreenRedirection:String {
    case mainProfile = "main_profile"
    case assesment = "assesment"
    case login = "login"
    case home = "home"
    case avatar = "avatar"
    case dashboard = "dashboard"
    case assessmentComplete = "assessmentComplete"
    case parentFeedback = "parentFeedback"
    case none = "none"
    
    func getViewController() -> UIViewController {
        switch self {
        case .mainProfile:
            return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
        case .assesment:
            return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AssessmentViewController") as! AssessmentViewController
        case .home:
            return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        case .avatar:
                   return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AvatarSelectionViewController") as! AvatarSelectionViewController
        case .dashboard:
                    return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DashboardViewController") as! DashboardViewController
        case .assessmentComplete:
            
            SpeechManager.shared.setDelegate(delegate: nil)
            RecordingManager.shared.stopRecording()
            RecordingManager.shared.stopWaitUserAnswerTimer()

                    return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AssessmentCompleteViewController") as! AssessmentCompleteViewController
        case .login:
                    return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            
        case .parentFeedback:
                    return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ParentFeedbackViewController") as! ParentFeedbackViewController
        default:
        break
        }
        return UIViewController()
    }
}

enum AssessmentQuestionType: String
{
    case puzzle_show_alpha = "puzzle_show_alpha"
    case body_tracking = "body_tracking"
    case face_tracking = "face_tracking"
    case environtmental_sounds = "environtmental_sounds"
    case VerbalResponse = "VerbalResponse"
    case verbal_actions = "verbal_actions"
    case eye_contact = "eye_contact"
    case Puzzle = "Puzzle"
    case reinforce = "reinforce"
    case which_type_question = "which_type_question"
    case PictureArray = "PictureArray"
    case touch_object = "touch_object"
    case sound_imitation = "sound_imitation"
    case reinforce_prefered = "reinforce_prefered"
    case Mazes = "Mazes"
    case Videos = "Videos"
    case sort_object = "sort_object"
    case match_count = "match count"
    case find_object = "find_object"
    case calendar = "calendar"
    case add_subs_mathematics = "add_subs_mathematics"
    case spelling = "spelling"
    case read_clock = "read_clock"
    case arrange_sequence = "arrange_sequence"
    case drawing = "drawing"
    case coloring_picture = "coloring_picture"
    case alphabet_learning = "alphabet_learning"
    case matching_object = "matching_object"
    case matching_object_drag = "matching_object_drag"
    case match_object_with_messy_array = "match_object_with_messy_array"
    case match_object_drag_with_messy_array = "match_object_drag_with_messy_array"
    case make_word = "make_word"
    case copy_pattern = "copy_pattern"
    case block_design = "block_designs"
    case introduction = "introduction"
    case introduction_name = "introduction_name"
    case fill_container = "fill_container"
    case independent_play = "independent_play"
    case verbal_with_multiple = "verbal_with_multiple"
    case reinforce_multi_choice = "reinforce_multi_choice"
    case multi_array_question = "multi_array_question"
    case intro_video = "intro_video"
    case matching_one_pair = "matching_one_pair"
    case tacting_4m_multiple = "tacting_4m_multiple"
    case manding_videos = "manding_videos"
    //New added for trial errors
    case sound_of_animals = "sound_of_animals"
    case colors = "colors"
    case shapes = "shapes"
    case solid_colors = "solid_colors"
    case manding_verbal_video = "manding_verbal_video"
    case matching_three_pair = "matching_three_pair"
    case balloon_game = "balloon_game"
    case touch_object_with_messy_array = "touch_object_with_messy_array"
    
    case mand = "mand"
    case writing_on_pad = "writing_on_pad"
    case fill_container_by_count = "fill_container_by_count"
    case sort_sequence = "sort_sequence"
    case reading_notes = "reading_notts"
    case paint = "paint"
    case picture_scene_touch_object = "picture_scene_touch_object"
    
    case none = "none"
}

//enum TrialQuestionType: String
//{
//    case puzzle_show_alpha = "puzzle_show_alpha"
//    case body_tracking = "body_tracking"
//    case face_tracking = "face_tracking"
//    case environtmental_sounds = "environtmental_sounds"
//    case VerbalResponse = "VerbalResponse"
//    case verbal_actions = "verbal_actions"
//    case eye_contact = "eye_contact"
//    case Puzzle = "Puzzle"
//    case reinforce = "reinforce"
//    case which_type_question = "which_type_question"
//    case PictureArray = "PictureArray"
//    case touch_object = "touch_object"
//    case sound_imitation = "sound_imitation"
//    case reinforce_prefered = "reinforce_prefered"
//    case Mazes = "Mazes"
//    case Videos = "Videos"
//    case sort_object = "sort_object"
//    case match_count = "match count"
//    case find_object = "find_object"
//    case calendar = "calendar"
//    case add_subs_mathematics = "add_subs_mathematics"
//    case spelling = "spelling"
//    case read_clock = "read_clock"
//    case arrange_sequence = "arrange_sequence"
//    case drawing = "drawing"
//    case coloring_picture = "coloring_picture"
//    case alphabet_learning = "alphabet_learning"
//    case matching_object = "matching_object"
//    case make_word = "make_word"
//    case copy_pattern = "copy_pattern"
//    case block_design = "block_designs"
//    case introduction = "introduction"
//    case introduction_name = "introduction_name"
//    case fill_container = "fill_container"
//    case independent_play = "independent_play"
//    case matching_one_pair = "matching_one_pair"
//    case colors = "colors"
//    case shapes = "shapes"
//    case solid_colors = "solid_colors"
//    case sound_of_animals = "sound_of_animals"
//    case none = "none"
//}
enum QuestionState: String {
    case inProgress = "inProgress"
    case submit = "submit"
    case wrongAnswer = "wrongAnswer"
}

enum CourseModule: String {
    case learning = "Learning"
    case trial = "Trial"
    case assessment = "Assessment"
    case mand = "mand"
    case none = "none"
}

enum ModuleStatus: String {
    case notStarted = "Not Started"
    case started = "Started"
    case pending = "Pending"
    case completed = "Completed"
    case none = "none"
}



enum APIDataState: String {
    case notCall = "notCall"
    case dataFetched = "dataFetched"
    case imageDownloaded = "imageDownloaded"
    case comandRunning = "comandRunning"
    case comandFinished = "comandFinished"
}

enum AvatarGender: String {
    case male = "Male"
    case female = "Female"
}

enum AppLanguage: String {
    case ja = "ja"
    case en = "en"
    func getLanguageCode() -> String {
        switch self {
        case .ja:
            return "ja-JP"
        case .en:
            return "en-US"
        }
    }
    
    func getEnglishSpeechIdentifier(gender: AvatarGender) -> String {
        switch gender {
        case .female: return "com.apple.ttsbundle.siri_female_en-US_compact"
        case .male: return "com.apple.ttsbundle.siri_male_en-US_compact"
        }
    }
    
    func getJapaneseSpeechIdentifier(gender: AvatarGender) -> String {
        switch gender {
        case .female: return "ja-JP-Wavenet-B"
        case .male: return "ja-JP-Wavenet-C"
        }
    }
    
}

 enum WishType: String {
     case goodMorning
     case goodNoon
     case goodAfterNoon
     case goodEvening
     case goodNight
    
     func getWish() -> String {
         var message = ""
         if let user = UserManager.shared.getUserInfo() {
             switch self {
                 case .goodMorning:
                     if user.languageCode == AppLanguage.en.rawValue {
                         message = "Good Morning, "
                     }  else if user.languageCode == AppLanguage.ja.rawValue {
                         message = "おはよう。 "
                     }
                 case .goodNoon:
                     if user.languageCode == AppLanguage.en.rawValue {
                         message = "Good Noon, "
                     }  else if user.languageCode == AppLanguage.ja.rawValue {
                         message = "こんにちは。 "
                     }
                 case .goodAfterNoon:
                     if user.languageCode == AppLanguage.en.rawValue {
                         message = "Good Afternoon, "
                     }  else if user.languageCode == AppLanguage.ja.rawValue {
                         message = "こんにちは。 "
                     }
                 case .goodEvening:
                     if user.languageCode == AppLanguage.en.rawValue {
                         message = "Good Evening, "
                     }  else if user.languageCode == AppLanguage.ja.rawValue {
                         message = "こんばんは。 "
                     }
                 case .goodNight:
                     if user.languageCode == AppLanguage.en.rawValue {
                         message = "Good Night, "
                     }  else if user.languageCode == AppLanguage.ja.rawValue {
                         message = "こんばんは。 "
                     }
             }
         }
         return message
     }
     
 }



enum AligmentType: String {
    case left   = "left"
    case right  = "right"
    case top    = "top"
    case bottom = "bottom"
    case center = "center"
}



enum ProgramCode: String {
    case matching   = "matching"
    case colors   = "colors"
    case basic_colors   = "basic_colors"
    case shapes   = "shapes"
    case solid_colors   = "solid_colors"
    case colors_shapes   = "colors_shapes"
    case simple_colors   = "simple_colors"
    case vocal_Imitations   = "vocal_Imitations"
    case matching_identical   = "matching_identical"
    case matching_identical_2   = "matching_identical_2"
    case matching_identical_3   = "matching_identical_3"
    case spelling   = "spelling"
    case matching_three_pair   = "matching_three_pair"
    case manding_2words_help   = "manding_2words_help"
    case mathematics   = "mathematics"
    case fine_motor_movements   = "fine_motor_movements"
    case eye_contact   = "eye_contact"
    case visual_tracking   = "visual_tracking"
    case following_instructions   = "following_instructions"
    case grabing_objects   = "grabing_objects"
    case expressively_labeling_items   = "expressively_labeling_items"

    case echoic1M   = "echoic1M"
    case echoic_2M   = "echoic_2M"
    case echoice_3M   = "echoice_3M"
    case echoice_4M   = "echoice_4M"
    case echoic_5M   = "echoic_5M"
    case echoice_5M_2   = "echoice_5M_2"
    case echoice_3M_2   = "echoice_3M_2"

    case tacting_2objects_help   = "tacting_2objects_help"
    case tacting_4object_no_help   = "tacting_4object_no_help"
    case tacting_6non_favourite_2   = "tacting_6non_favourite_2"
    case tacting_6non_favourite   = "tacting_6non_favourite"
    case tacting_10_item   = "tacting_10_item"
    case tacting_2objects_no_help   = "tacting_2objects_no_help"
    
    case tacting_1m   = "tacting_1m"
    case tacting_2m   = "tacting_2m"
    case tacting_3m   = "tacting_3m"
    case tacting_4m   = "tacting_4m"
    case tacting_5m   = "tacting_5m"

    case lr_1m   = "lr_1m"
    case lr_2m   = "lr_2m"
    case lr_3m   = "lr_3m"
    case lr_4m   = "lr_4m"
    case lr_5m   = "lr_5m"
    
    case math = "math"
    case lr_ffc_l3_g11 = "lr_ffc_l3_g11"
    case parent_presence = "parent_presence"
    case quiz_intro = "quiz_intro"
    case lr_messyarray_touch = "lr_messyarray_touch"
    case math_sorting = "math_sorting"
    case vpmts_goal_6m = "vpmts_goal_6m"
    case writing_goal13 = "writing_goal13"

    case add_subs_mathematics = "add_subs_mathematics" //added to separate
    case lrffc_goal13 = "lrffc_goal13"
    
    case none      = "none"
}




