//
//  AssessmentQuestionResponseVO.swift
//  Autism
//
//  Created by Atinderpal Singh on 2020/06/15.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

struct AssessmentQuestionResponseVO: Codable {
    var success: Bool
    var statuscode: Int
    var message: String
    var question_type: String
    var screen_type: String
    var screen_id: String
    var enable_reinforcer: Bool

    var tacting4mQuestionInfo: Tacting4mMultipleQuestionInfo?
    var verbalQuestionInfo: VerbalQuestionInfo?
    var eyeContactQuestionInfo: EyeContactQuestionInfo?
    var puzzleQuestionInfo: PuzzleQuestionInfo?
    var reinforcerInfo: ReinforcerInfo?
    var reinforcerNonPreferredInfo: ReinforcerNonPreferredInfo?
    var which_type_question: WhichTypeQuestionInfo?
    var soundImitationInfo: SoundImitationInfo?
    var mazesInfo: MazesInfo?
    var independentPlayInfo: IndependentPlayInfo?
    var videoInfo: VideoInfo?
    var sortObject: SortObjectInfo?
    var mazeObject: MazeObject?
    var findObject: FindObject?
    var matchDate: MatchDate?
    var mathematicsCalculation: MathematicsCalculation?
    var matchSpelling: MatchSpelling?
    var readclock: Readclock?
    var sequenceInfo:SequenceResponseInfo?
    var drawingInfo: DrawingQuestionInfo?
    var coloringInfo: ColoringQuestionInfo?
    var alphabetLearningInfo: AlphabetLearningInfo?
    var matchingObjectInfo: MatchingObjectInfo?
    var makeWorkInfo: MakeWordInfo?
    var copyPatternInfo:CopyPatternInfo?
    var blockDesignInfo:BlockDesignInfo?
    var introductionQInfo:IntroductionQuestionInfo?
    var environmentalSoundInfo:EnvironmentalSoundQuestionInfo?
    var fillContainerInfo:FillContainerQuestionInfo?
    var faceTrackingInfo:FaceTrackingQuestionInfo?
    var bodyTrackingInfo:BodyTrackingQuestionInfo?
    var reinforceMultiChoiceInfo:ReinforceMultiChoiceInfo?
    var multiArrayQuestionInfo:MultiArrayQuestionInfo?
    var introVideoQuestionInfo:IntroVideoQuestionInfo?
    var balloonGameQuestionInfo:BalloonGameQuestionInfo?

    var mandInfo:MandInfo?
    var writingOnPadInfo:WritingOnPadInfo?

    init(from decoder:Decoder) throws {
        let container = try decoder.container(keyedBy: ServiceParsingKeys.self)
        self.success = try container.decodeIfPresent(Bool.self, forKey: .success) ?? false
        self.statuscode = try container.decodeIfPresent(Int.self, forKey: .statuscode) ?? 0
        self.message = try container.decodeIfPresent(String.self, forKey: .message) ?? ""
        
        let dataContainer = try container.nestedContainer(keyedBy: ServiceParsingKeys.self, forKey: .data)
        self.screen_type = try dataContainer.decodeIfPresent(String.self, forKey: .screen_type) ?? ""
        self.enable_reinforcer = try dataContainer.decodeIfPresent(Bool.self, forKey: .enable_reinforcer) ?? false
        self.screen_id = try dataContainer.decodeIfPresent(String.self, forKey: .screen_id) ?? ""
        self.question_type = self.screen_type//try dataContainer.decodeIfPresent(String.self, forKey: .question_type) ?? ""

        let questionTitle = try dataContainer.decodeIfPresent(String.self, forKey: .question_title) ?? ""
        let req_no = try dataContainer.decodeIfPresent(String.self, forKey: .req_no) ?? ""
        let skill_domain_id = try dataContainer.decodeIfPresent(String.self, forKey: .skill_domain_id) ?? ""
        let program_id = try dataContainer.decodeIfPresent(String.self, forKey: .program_id) ?? ""
        let level = try dataContainer.decodeIfPresent(String.self, forKey: .level) ?? ""
        let content_type = try dataContainer.decodeIfPresent(String.self, forKey: .content_type) ?? ""

        if(content_type == "mand") {
            self.question_type = content_type
            self.screen_type = content_type
        }
        
        let type = AssessmentQuestionType.init(rawValue: self.question_type)
        switch type {
        
        case .writing_on_pad:
            self.writingOnPadInfo = try dataContainer.decodeIfPresent(WritingOnPadInfo.self, forKey: .questionDetail) ?? nil
            self.writingOnPadInfo?.question_type = type!.rawValue
            self.writingOnPadInfo?.skill_domain_id = skill_domain_id
            self.writingOnPadInfo?.program_id = program_id
        case .mand:
            self.mandInfo = try container.decodeIfPresent(MandInfo.self, forKey: .data) ?? nil
            self.mandInfo?.content_type = content_type
            self.mandInfo?.question_type = self.question_type
            self.mandInfo?.screen_type = self.screen_type
        case .balloon_game:
            self.balloonGameQuestionInfo = try dataContainer.decodeIfPresent(BalloonGameQuestionInfo.self, forKey: .questionDetail) ?? nil
            self.balloonGameQuestionInfo?.question_type = type!.rawValue
            self.balloonGameQuestionInfo?.skill_domain_id = skill_domain_id
            self.balloonGameQuestionInfo?.program_id = program_id
        case .intro_video:
            self.introVideoQuestionInfo = try dataContainer.decodeIfPresent(IntroVideoQuestionInfo.self, forKey: .questionDetail) ?? nil
            self.introVideoQuestionInfo?.question_type = type!.rawValue
            self.introVideoQuestionInfo?.skill_domain_id = skill_domain_id
            self.introVideoQuestionInfo?.program_id = program_id
        
        case .body_tracking:
            self.bodyTrackingInfo = try dataContainer.decodeIfPresent(BodyTrackingQuestionInfo.self, forKey: .questionDetail) ?? nil
            self.bodyTrackingInfo?.question_type = type!.rawValue
            self.bodyTrackingInfo?.skill_domain_id = skill_domain_id
            self.bodyTrackingInfo?.program_id = program_id
        case .face_tracking:
            self.faceTrackingInfo = try dataContainer.decodeIfPresent(FaceTrackingQuestionInfo.self, forKey: .questionDetail) ?? nil
            self.faceTrackingInfo?.question_type = type!.rawValue
            self.faceTrackingInfo?.skill_domain_id = skill_domain_id
            self.faceTrackingInfo?.program_id = program_id

        case .eye_contact:
            self.eyeContactQuestionInfo = try dataContainer.decodeIfPresent(EyeContactQuestionInfo.self, forKey: .questionDetail) ?? nil
            self.eyeContactQuestionInfo?.question_type = type!.rawValue
            self.eyeContactQuestionInfo?.skill_domain_id = skill_domain_id
            self.eyeContactQuestionInfo?.program_id = program_id

        case .VerbalResponse,.verbal_actions, .verbal_with_multiple, .manding_verbal_video:
            self.verbalQuestionInfo = try dataContainer.decodeIfPresent(VerbalQuestionInfo.self, forKey: .questionDetail) ?? nil
            self.verbalQuestionInfo?.question_type = type!.rawValue
            self.verbalQuestionInfo?.skill_domain_id = skill_domain_id
            self.verbalQuestionInfo?.program_id = program_id
        case .tacting_4m_multiple:
            self.tacting4mQuestionInfo = try dataContainer.decodeIfPresent(Tacting4mMultipleQuestionInfo.self, forKey: .questionData) ?? nil
            self.tacting4mQuestionInfo?.question_type = type!.rawValue
            self.tacting4mQuestionInfo?.skill_domain_id = skill_domain_id
            self.tacting4mQuestionInfo?.program_id = program_id
            self.tacting4mQuestionInfo?.imagesList          = try dataContainer.decodeIfPresent([ImageModel].self, forKey: .rein_force_non_preferreds) ?? []
        case .Puzzle,.puzzle_show_alpha, .paint:
            self.blockDesignInfo = try dataContainer.decodeIfPresent(BlockDesignInfo.self, forKey: .questionDetail) ?? nil
            self.blockDesignInfo?.question_type = type!.rawValue
            self.blockDesignInfo?.skill_domain_id = skill_domain_id
            self.blockDesignInfo?.program_id = program_id

//            self.puzzleQuestionInfo = try dataContainer.decodeIfPresent(PuzzleQuestionInfo.self, forKey: .questionDetail) ?? nil
//            self.puzzleQuestionInfo?.question_type = type!.rawValue
//            self.puzzleQuestionInfo?.skill_domain_id = skill_domain_id
//            self.puzzleQuestionInfo?.program_id = program_id

        case .drawing:
            self.drawingInfo = try dataContainer.decodeIfPresent(DrawingQuestionInfo.self, forKey: .questionDetail) ?? nil
            self.drawingInfo?.question_type = type!.rawValue
            self.drawingInfo?.skill_domain_id = skill_domain_id
            self.drawingInfo?.program_id = program_id

         case .coloring_picture:
            self.coloringInfo = try dataContainer.decodeIfPresent(ColoringQuestionInfo.self, forKey: .questionDetail) ?? nil
            self.coloringInfo?.question_type = type!.rawValue
            self.coloringInfo?.skill_domain_id = skill_domain_id
            self.coloringInfo?.program_id = program_id

        case .reinforce,.reinforce_prefered:
            self.reinforcerInfo = try dataContainer.decodeIfPresent(ReinforcerInfo.self, forKey: .questionDetail) ?? nil
            self.reinforcerInfo?.questionTitle = questionTitle
            self.reinforcerInfo?.req_no = req_no
            self.reinforcerInfo?.skill_domain_id = skill_domain_id
            self.reinforcerInfo?.program_id = program_id
            let questionDataContainer = try dataContainer.nestedContainer(keyedBy: ServiceParsingKeys.self, forKey: .questionData)
            self.reinforcerInfo?.trial_time = try questionDataContainer.decodeIfPresent(Int.self, forKey: .trial_time) ?? 0
            self.reinforcerInfo?.completion_time = try questionDataContainer.decodeIfPresent(Int.self, forKey: .completion_time) ?? 0
            self.reinforcerInfo?.level = level
            self.reinforcerNonPreferredInfo = try dataContainer.decodeIfPresent(ReinforcerNonPreferredInfo.self, forKey: .rein_force_non_preferreds) ?? nil
        case .which_type_question,.PictureArray,.touch_object:
            self.which_type_question = try dataContainer.decodeIfPresent(WhichTypeQuestionInfo.self, forKey: .questionDetail) ?? nil
            self.which_type_question?.question_type = type!.rawValue
            self.which_type_question?.skill_domain_id = skill_domain_id
            self.which_type_question?.program_id = program_id
            
        case .multi_array_question:
            self.multiArrayQuestionInfo = try dataContainer.decodeIfPresent(MultiArrayQuestionInfo.self, forKey: .questionDetail) ?? nil
            self.multiArrayQuestionInfo?.question_type = type!.rawValue
            self.multiArrayQuestionInfo?.skill_domain_id = skill_domain_id
            self.multiArrayQuestionInfo?.program_id = program_id
            
        case .reinforce_multi_choice:
//            try container.nestedContainer(keyedBy: ServiceParsingKeys.self, forKey: .data)
            self.reinforceMultiChoiceInfo = try container.decodeIfPresent(ReinforceMultiChoiceInfo.self, forKey: .data) ?? nil
            self.reinforceMultiChoiceInfo?.question_type = type!.rawValue
            self.reinforceMultiChoiceInfo?.skill_domain_id = skill_domain_id
            self.reinforceMultiChoiceInfo?.program_id = program_id
            self.reinforceMultiChoiceInfo?.req_no = req_no
            //self.reinforceMultiChoiceInfo?.questionTitle = questionTitle
            
        case .sound_imitation:
            self.soundImitationInfo = try dataContainer.decodeIfPresent(SoundImitationInfo.self, forKey: .questionDetail) ?? nil
            self.soundImitationInfo?.question_type = type!.rawValue
            self.soundImitationInfo?.skill_domain_id = skill_domain_id
            self.soundImitationInfo?.program_id = program_id

        case .Mazes:
            self.mazesInfo = try dataContainer.decodeIfPresent(MazesInfo.self, forKey: .questionDetail) ?? nil
            self.mazesInfo?.question_type = type!.rawValue
            self.mazesInfo?.skill_domain_id = skill_domain_id
            self.mazesInfo?.program_id = program_id
        case .independent_play:
            self.independentPlayInfo = try dataContainer.decodeIfPresent(IndependentPlayInfo.self, forKey: .questionDetail) ?? nil
            self.independentPlayInfo?.question_type = type!.rawValue
            self.independentPlayInfo?.skill_domain_id = skill_domain_id
            self.independentPlayInfo?.program_id = program_id
        case .Videos, .manding_videos:
            self.videoInfo = try dataContainer.decodeIfPresent(VideoInfo.self, forKey: .questionDetail) ?? nil
            self.videoInfo?.question_type = type!.rawValue
            self.videoInfo?.skill_domain_id = skill_domain_id
            self.videoInfo?.program_id = program_id

        case .sort_object:
            self.sortObject = try dataContainer.decodeIfPresent(SortObjectInfo.self, forKey: .questionDetail) ?? nil
            self.sortObject?.question_type = type!.rawValue
            self.sortObject?.skill_domain_id = skill_domain_id
            self.sortObject?.program_id = program_id

        case .match_count:
            self.mazeObject = try dataContainer.decodeIfPresent(MazeObject.self, forKey: .questionDetail) ?? nil
            self.mazeObject?.question_type = type!.rawValue
            self.mazeObject?.skill_domain_id = skill_domain_id
            self.mazeObject?.program_id = program_id

        case .find_object:
            self.findObject = try dataContainer.decodeIfPresent(FindObject.self, forKey: .questionDetail) ?? nil
            self.findObject?.question_type = type!.rawValue
            self.findObject?.skill_domain_id = skill_domain_id
            self.findObject?.program_id = program_id

        case .calendar:
            self.matchDate = try dataContainer.decodeIfPresent(MatchDate.self, forKey: .questionDetail) ?? nil
            self.matchDate?.question_type = type!.rawValue
            self.matchDate?.skill_domain_id = skill_domain_id
            self.matchDate?.program_id = program_id

        case .arrange_sequence:
            self.sequenceInfo = try dataContainer.decodeIfPresent(SequenceResponseInfo.self, forKey: .questionDetail) ?? nil
            self.sequenceInfo?.question_type = type!.rawValue
            self.sequenceInfo?.skill_domain_id = skill_domain_id
            self.sequenceInfo?.program_id = program_id

        case .add_subs_mathematics:
            self.mathematicsCalculation = try dataContainer.decodeIfPresent(MathematicsCalculation.self, forKey: .questionDetail) ?? nil
            self.mathematicsCalculation?.question_type = type!.rawValue
            self.mathematicsCalculation?.skill_domain_id = skill_domain_id
            self.mathematicsCalculation?.program_id = program_id

        case .spelling:
            self.matchSpelling = try dataContainer.decodeIfPresent(MatchSpelling.self, forKey: .questionDetail) ?? nil
            self.matchSpelling?.question_type = type!.rawValue
            self.matchSpelling?.skill_domain_id = skill_domain_id
            self.matchSpelling?.program_id = program_id

        case .read_clock:
            self.readclock = try dataContainer.decodeIfPresent(Readclock.self, forKey: .questionDetail) ?? nil
            self.readclock?.question_type = type!.rawValue
            self.readclock?.skill_domain_id = skill_domain_id
            self.readclock?.program_id = program_id

        case .alphabet_learning:
            self.alphabetLearningInfo = try dataContainer.decodeIfPresent(AlphabetLearningInfo.self, forKey: .questionDetail) ?? nil
            self.alphabetLearningInfo?.question_type = type!.rawValue
            self.alphabetLearningInfo?.skill_domain_id = skill_domain_id
            self.alphabetLearningInfo?.program_id = program_id

        case .matching_object, .matching_object_drag, .match_object_with_messy_array, .matching_one_pair, .matching_three_pair, .match_object_drag_with_messy_array, .touch_object_with_messy_array, .reading_notes:
            self.matchingObjectInfo = try dataContainer.decodeIfPresent(MatchingObjectInfo.self, forKey: .questionDetail) ?? nil
            self.matchingObjectInfo?.question_type = type!.rawValue
            self.matchingObjectInfo?.skill_domain_id = skill_domain_id
            self.matchingObjectInfo?.program_id = program_id

        case .make_word:
            self.makeWorkInfo = try dataContainer.decodeIfPresent(MakeWordInfo.self, forKey: .questionDetail) ?? nil
            self.makeWorkInfo?.question_type = type!.rawValue
            self.makeWorkInfo?.skill_domain_id = skill_domain_id
            self.makeWorkInfo?.program_id = program_id

        case .copy_pattern, .sort_sequence:
            self.copyPatternInfo = try dataContainer.decodeIfPresent(CopyPatternInfo.self, forKey: .questionDetail) ?? nil
            self.copyPatternInfo?.question_type = type!.rawValue
            self.copyPatternInfo?.skill_domain_id = skill_domain_id
            self.copyPatternInfo?.program_id = program_id

        case .block_design:
            self.blockDesignInfo = try dataContainer.decodeIfPresent(BlockDesignInfo.self, forKey: .questionDetail) ?? nil
            self.blockDesignInfo?.question_type = type!.rawValue
            self.blockDesignInfo?.skill_domain_id = skill_domain_id
            self.blockDesignInfo?.program_id = program_id

        case .introduction,.introduction_name:
            self.introductionQInfo = try dataContainer.decodeIfPresent(IntroductionQuestionInfo.self, forKey: .questionDetail) ?? nil
            self.introductionQInfo?.question_type = type!.rawValue
            self.introductionQInfo?.skill_domain_id = skill_domain_id
            self.introductionQInfo?.program_id = program_id

        case .environtmental_sounds:
            self.environmentalSoundInfo = try dataContainer.decodeIfPresent(EnvironmentalSoundQuestionInfo.self, forKey: .questionDetail) ?? nil
            self.environmentalSoundInfo?.question_type = type!.rawValue
            self.environmentalSoundInfo?.skill_domain_id = skill_domain_id
            self.environmentalSoundInfo?.program_id = program_id

        case .fill_container, .fill_container_by_count:
            self.fillContainerInfo = try dataContainer.decodeIfPresent(FillContainerQuestionInfo.self, forKey: .questionDetail) ?? nil
            self.fillContainerInfo?.content_type = content_type
            self.fillContainerInfo?.question_type = type!.rawValue
            self.fillContainerInfo?.skill_domain_id = skill_domain_id
            self.fillContainerInfo?.program_id = program_id
        default:
            break
        }
    }

    func encode(to encoder: Encoder) throws {

    }
}


