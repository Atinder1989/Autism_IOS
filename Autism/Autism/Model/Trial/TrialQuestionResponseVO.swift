//
//  TrialQuestionResponseVO.swift
//  Autism
//
//  Created by Dilip Technology on 22/10/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

struct TrialQuestionResponseVO: Codable {
        
    var success: Bool
    var statuscode: Int
    var message: String
    
    var id: String
    var question_type: String
    var enable_reinforcer: Bool = false
    var skill_domain_id: String
    var program_id: String
    var trial_prompt_type: String
    var prompt_type: String
    
    var prompt_detail: [ScriptCommandInfo]
    
    var matchingObjectInfo: MatchingObjectInfo?
    var verbalQuestionInfo: VerbalQuestionInfo?
    var matchSpellingQuestionInfo: MatchSpelling?
    var mathematicsCalculationInfo: MathematicsCalculation?
    var balloonGameQuestionInfo:BalloonGameQuestionInfo?
    var bodyTrackingInfo:BodyTrackingQuestionInfo?
    var mazeInfo:MazesInfo?
    
    var screen_id: String
    
    var reinforce :[ImageModel]
    
//    var eyeContactQuestionInfo: EyeContactQuestionInfo?
//    var puzzleQuestionInfo: PuzzleQuestionInfo?
//    var reinforcerInfo: ReinforcerInfo?
//    var reinforcerNonPreferredInfo: ReinforcerNonPreferredInfo?
//    var which_type_question: WhichTypeQuestionInfo?
//    var soundImitationInfo: SoundImitationInfo?
//    var mazesInfo: MazesInfo?
//    var independentPlayInfo: IndependentPlayInfo?
//    var videoInfo: VideoInfo?
//    var sortObject: SortObjectInfo?
//    var mazeObject: MazeObject?
//    var findObject: FindObject?
//    var matchDate: MatchDate?
//    var mathematicsCalculation: MathematicsCalculation?
//    var matchSpelling: MatchSpelling?
//    var readclock: Readclock?
//    var sequenceInfo:SequenceResponseInfo?
//    var drawingInfo: DrawingQuestionInfo?
//    var coloringInfo: ColoringQuestionInfo?
//    var alphabetLearningInfo: AlphabetLearningInfo?
////    var matchingObjectInfo: MatchingObjectInfo?
//    var makeWorkInfo: MakeWordInfo?
//    var copyPatternInfo:CopyPatternInfo?
//    var blockDesignInfo:BlockDesignInfo?
//    var introductionQInfo:IntroductionQuestionInfo?
//    var environmentalSoundInfo:EnvironmentalSoundQuestionInfo?
//    var fillContainerInfo:FillContainerQuestionInfo?
//    var faceTrackingInfo:FaceTrackingQuestionInfo?
//    var bodyTrackingInfo:BodyTrackingQuestionInfo?

    init(from decoder:Decoder) throws {
        
        let container = try decoder.container(keyedBy: ServiceParsingKeys.self)
                
        self.success = try container.decodeIfPresent(Bool.self, forKey: .success) ?? false
        self.statuscode = try container.decodeIfPresent(Int.self, forKey: .statuscode) ?? 0
        self.message = try container.decodeIfPresent(String.self, forKey: .message) ?? ""
        self.reinforce = try container.decodeIfPresent([ImageModel].self, forKey: .reinforce) ?? []
        
        let dataContainer = try container.nestedContainer(keyedBy: ServiceParsingKeys.self, forKey: .data)
        
        self.screen_id = try dataContainer.decodeIfPresent(String.self, forKey: .screen_id) ?? ""
        self.enable_reinforcer = try dataContainer.decodeIfPresent(Bool.self, forKey: .enable_reinforcer) ?? false
        self.id = try dataContainer.decodeIfPresent(String.self, forKey: .id) ?? ""
        self.question_type = try dataContainer.decodeIfPresent(String.self, forKey: .question_type) ?? ""
        self.skill_domain_id = try dataContainer.decodeIfPresent(String.self, forKey: .skill_domain_id) ?? ""
        self.program_id = try dataContainer.decodeIfPresent(String.self, forKey: .program_id) ?? ""
        self.trial_prompt_type = try dataContainer.decodeIfPresent(String.self, forKey: .trial_prompt_type) ?? ""
        self.prompt_type = try dataContainer.decodeIfPresent(String.self, forKey: .prompt_type) ?? ""
        
        self.prompt_detail = try dataContainer.decodeIfPresent([ScriptCommandInfo].self, forKey: .prompt_detail) ?? []
        
        
        let type = AssessmentQuestionType.init(rawValue: self.question_type)
        switch type {
        case .spelling:
            self.matchSpellingQuestionInfo = try dataContainer.decodeIfPresent(MatchSpelling.self, forKey: .questionDetail) ?? nil
            self.matchSpellingQuestionInfo?.question_type = type!.rawValue
            self.matchSpellingQuestionInfo?.skill_domain_id = skill_domain_id
            self.matchSpellingQuestionInfo?.program_id = program_id
            self.matchSpellingQuestionInfo?.trial_prompt_type = self.trial_prompt_type
            self.matchSpellingQuestionInfo?.prompt_detail = self.prompt_detail
            self.matchSpellingQuestionInfo?.prompt_type = self.prompt_type
        case .add_subs_mathematics:
            self.mathematicsCalculationInfo = try dataContainer.decodeIfPresent(MathematicsCalculation.self, forKey: .questionDetail) ?? nil
            self.mathematicsCalculationInfo?.question_type = type!.rawValue
            self.mathematicsCalculationInfo?.skill_domain_id = skill_domain_id
            self.mathematicsCalculationInfo?.program_id = program_id
            self.mathematicsCalculationInfo?.trial_prompt_type = self.trial_prompt_type
            self.mathematicsCalculationInfo?.prompt_detail = self.prompt_detail
            self.mathematicsCalculationInfo?.prompt_type = self.prompt_type
        case .matching_object,.matching_one_pair,.matching_three_pair, .PictureArray :
            self.matchingObjectInfo = try dataContainer.decodeIfPresent(MatchingObjectInfo.self, forKey: .questionDetail) ?? nil
            //self.matchingObjectInfo?.question_type = type!.rawValue
            self.matchingObjectInfo?.skill_domain_id = skill_domain_id
            self.matchingObjectInfo?.program_id = program_id
            self.matchingObjectInfo?.trial_prompt_type = self.trial_prompt_type
            self.matchingObjectInfo?.prompt_detail = self.prompt_detail
            self.matchingObjectInfo?.prompt_type = self.prompt_type
        case .VerbalResponse,.verbal_actions,.verbal_with_multiple:
            self.verbalQuestionInfo = try dataContainer.decodeIfPresent(VerbalQuestionInfo.self, forKey: .questionDetail) ?? nil
            self.verbalQuestionInfo?.question_type = type!.rawValue
            self.verbalQuestionInfo?.skill_domain_id = skill_domain_id
            self.verbalQuestionInfo?.program_id = program_id
            self.verbalQuestionInfo?.trial_prompt_type = self.trial_prompt_type
            self.verbalQuestionInfo?.prompt_detail = self.prompt_detail
            self.verbalQuestionInfo?.trial_prompt_type = self.prompt_type
            self.verbalQuestionInfo?.prompt_type = self.prompt_type
            self.verbalQuestionInfo?.reinforce = self.reinforce
        case .environtmental_sounds,.sound_of_animals:
            self.verbalQuestionInfo = try dataContainer.decodeIfPresent(VerbalQuestionInfo.self, forKey: .questionDetail) ?? nil
            self.verbalQuestionInfo?.question_type = type!.rawValue
            self.verbalQuestionInfo?.skill_domain_id = skill_domain_id
            self.verbalQuestionInfo?.program_id = program_id
            self.verbalQuestionInfo?.prompt_detail = self.prompt_detail
            self.verbalQuestionInfo?.trial_prompt_type = self.trial_prompt_type
            self.verbalQuestionInfo?.prompt_type = self.prompt_type
        
        case .balloon_game:
            self.balloonGameQuestionInfo = try dataContainer.decodeIfPresent(BalloonGameQuestionInfo.self, forKey: .questionDetail) ?? nil
            self.balloonGameQuestionInfo?.question_type = type!.rawValue
            self.balloonGameQuestionInfo?.skill_domain_id = skill_domain_id
            self.balloonGameQuestionInfo?.program_id = program_id
            self.balloonGameQuestionInfo?.trial_prompt_type = self.trial_prompt_type
            self.balloonGameQuestionInfo?.prompt_detail = self.prompt_detail
            self.balloonGameQuestionInfo?.prompt_type = self.prompt_type
        
        case .body_tracking:
            self.bodyTrackingInfo = try dataContainer.decodeIfPresent(BodyTrackingQuestionInfo.self, forKey: .questionDetail) ?? nil
            self.bodyTrackingInfo?.question_type = type!.rawValue
            self.bodyTrackingInfo?.skill_domain_id = skill_domain_id
            self.bodyTrackingInfo?.program_id = program_id
            self.bodyTrackingInfo?.trial_prompt_type = self.trial_prompt_type
            self.bodyTrackingInfo?.prompt_detail = self.prompt_detail
            self.bodyTrackingInfo?.prompt_type = self.prompt_type
            
        case .Mazes:
            self.mazeInfo = try dataContainer.decodeIfPresent(MazesInfo.self, forKey: .questionDetail) ?? nil
            self.mazeInfo?.question_type = type!.rawValue
            self.mazeInfo?.skill_domain_id = skill_domain_id
            self.mazeInfo?.program_id = program_id
            self.mazeInfo?.trial_prompt_type = self.trial_prompt_type
            self.mazeInfo?.prompt_detail = self.prompt_detail
            self.mazeInfo?.prompt_type = self.prompt_type

            
        default:
            break
        }
    }

    func encode(to encoder: Encoder) throws {

    }
}



