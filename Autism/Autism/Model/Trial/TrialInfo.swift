//
//  TrialInfo.swift
//  Autism
//
//  Created by Dilip Technology on 22/10/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

struct TrialInfo: Codable {
            
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
    var spellingQuestionInfo:MatchSpelling?
    var mathematicsCalculationInfo: MathematicsCalculation?
    var balloonGameQuestionInfo: BalloonGameQuestionInfo?
    var bodyTrackingQuestionInfo: BodyTrackingQuestionInfo!
    
    init(from decoder:Decoder) throws {
        
        let dataContainer = try decoder.container(keyedBy: ServiceParsingKeys.self)
                
        //let dataContainer = try container.nestedContainer(keyedBy: ServiceParsingKeys.self, forKey: .data)
        
        self.id = try dataContainer.decodeIfPresent(String.self, forKey: .id) ?? ""
        self.question_type = try dataContainer.decodeIfPresent(String.self, forKey: .question_type) ?? ""
        self.skill_domain_id = try dataContainer.decodeIfPresent(String.self, forKey: .skill_domain_id) ?? ""
        self.program_id = try dataContainer.decodeIfPresent(String.self, forKey: .program_id) ?? ""
        self.trial_prompt_type = try dataContainer.decodeIfPresent(String.self, forKey: .trial_prompt_type) ?? ""
        self.prompt_type = try dataContainer.decodeIfPresent(String.self, forKey: .prompt_type) ?? ""
        self.enable_reinforcer = try dataContainer.decodeIfPresent(Bool.self, forKey: .enable_reinforcer) ?? false
        self.prompt_detail = try dataContainer.decodeIfPresent([ScriptCommandInfo].self, forKey: .prompt_detail) ?? []

        let type = AssessmentQuestionType.init(rawValue: self.question_type)
        switch type {
        case .matching_object,.matching_one_pair, .PictureArray,.matching_three_pair:
            self.matchingObjectInfo = try dataContainer.decodeIfPresent(MatchingObjectInfo.self, forKey: .questionDetail) ?? nil
            self.matchingObjectInfo?.question_type = type!.rawValue
            self.matchingObjectInfo?.skill_domain_id = skill_domain_id
            self.matchingObjectInfo?.program_id = program_id
            self.matchingObjectInfo?.trial_prompt_type = self.trial_prompt_type
            self.matchingObjectInfo?.prompt_detail = self.prompt_detail
            self.matchingObjectInfo?.prompt_type = self.prompt_type
        case .VerbalResponse,.verbal_actions, .introduction_name, .environtmental_sounds, .verbal_with_multiple:
            self.verbalQuestionInfo = try dataContainer.decodeIfPresent(VerbalQuestionInfo.self, forKey: .questionDetail) ?? nil
            self.verbalQuestionInfo?.question_type = type!.rawValue
            self.verbalQuestionInfo?.skill_domain_id = skill_domain_id
            self.verbalQuestionInfo?.program_id = program_id
            self.verbalQuestionInfo?.trial_prompt_type = self.trial_prompt_type
            self.verbalQuestionInfo?.prompt_detail = self.prompt_detail
            self.verbalQuestionInfo?.trial_prompt_type = self.prompt_type
            self.verbalQuestionInfo?.prompt_type = self.prompt_type
        case .spelling:
            self.spellingQuestionInfo = try dataContainer.decodeIfPresent(MatchSpelling.self, forKey: .questionDetail) ?? nil
            self.spellingQuestionInfo?.question_type = type!.rawValue
            self.spellingQuestionInfo?.skill_domain_id = skill_domain_id
            self.spellingQuestionInfo?.program_id = program_id
            self.spellingQuestionInfo?.trial_prompt_type = self.trial_prompt_type
            self.spellingQuestionInfo?.prompt_detail = self.prompt_detail
            self.spellingQuestionInfo?.trial_prompt_type = self.prompt_type
            self.spellingQuestionInfo?.prompt_type = self.prompt_type
        case .add_subs_mathematics:
            self.mathematicsCalculationInfo = try dataContainer.decodeIfPresent(MathematicsCalculation.self, forKey: .questionDetail) ?? nil
            self.mathematicsCalculationInfo?.question_type = type!.rawValue
            self.mathematicsCalculationInfo?.skill_domain_id = skill_domain_id
            self.mathematicsCalculationInfo?.program_id = program_id
            self.mathematicsCalculationInfo?.trial_prompt_type = self.trial_prompt_type
            self.mathematicsCalculationInfo?.prompt_detail = self.prompt_detail
            self.mathematicsCalculationInfo?.trial_prompt_type = self.prompt_type
            self.mathematicsCalculationInfo?.prompt_type = self.prompt_type
        case .balloon_game:
            self.balloonGameQuestionInfo = try dataContainer.decodeIfPresent(BalloonGameQuestionInfo.self, forKey: .questionDetail) ?? nil
            self.balloonGameQuestionInfo?.question_type = type!.rawValue
            self.balloonGameQuestionInfo?.skill_domain_id = skill_domain_id
            self.balloonGameQuestionInfo?.program_id = program_id
            self.balloonGameQuestionInfo?.trial_prompt_type = self.trial_prompt_type
            self.balloonGameQuestionInfo?.prompt_detail = self.prompt_detail
            self.balloonGameQuestionInfo?.trial_prompt_type = self.prompt_type
            self.balloonGameQuestionInfo?.prompt_type = self.prompt_type
        case .body_tracking:
            self.bodyTrackingQuestionInfo = try dataContainer.decodeIfPresent(BodyTrackingQuestionInfo.self, forKey: .questionDetail) ?? nil
            self.bodyTrackingQuestionInfo?.question_type = type!.rawValue
            self.bodyTrackingQuestionInfo?.skill_domain_id = skill_domain_id
            self.bodyTrackingQuestionInfo?.program_id = program_id
            self.bodyTrackingQuestionInfo?.trial_prompt_type = self.trial_prompt_type
            self.bodyTrackingQuestionInfo?.prompt_detail = self.prompt_detail
            self.bodyTrackingQuestionInfo?.trial_prompt_type = self.prompt_type
            self.bodyTrackingQuestionInfo?.prompt_type = self.prompt_type
            
        default:
            break
        }
    }
    

    func encode(to encoder: Encoder) throws {

    }
}



