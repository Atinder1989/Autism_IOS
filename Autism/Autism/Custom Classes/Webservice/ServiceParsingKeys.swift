//
//  ServiceParsingKeys.swift
//  Assignment
//
//  Created by Atinderpal Singh on 05/02/19.
//  Copyright © 2019 Abc. All rights reserved.
//

import Foundation

enum ServiceParsingKeys : String, CodingKey {
    case success     =   "success"
    case statuscode  =   "statuscode"
    case message = "message"
    case name  = "name"
    case parentName  = "parentName"    
    case code  = "code"
    case image  = "image"
    case docs  = "docs"
    case data  = "data"
    case email  = "email"
    case language  = "language"
    case password  = "password"
    case token  = "token"
    case user  = "user"
    case id     = "_id"
    case verified  = "verified"
    case verification  = "verification"
    case screen_id  = "screen_id"
    case label_code  = "label_code"
    case label_text  = "label_text"
    case error_text  = "error_text"
    case language_code  = "language_code"
    case sensory_issue  = "sensory_issue"
    case challenging_behaviour  = "challenging_behaviour"
    case allergie  = "allergie"
    case diet  = "diet"
    case reinforcer  = "reinforcer"
    case other_detail  = "other_detail"
    case other_detail_id = "other_detail_id"
    case other_detail_infos = "other_detail_infos"
    case info = "info"
    case filled = "filled"
    case empty = "empty"
    case normalId     = "id"
    case user_id     = "user_id"
    case question_type     = "question_type"
    case questionDetail     = "questionDetail"
    case question_title     = "question_title"
    case timeout     = "timeout"
    case answer     = "answer"
    case frame_image     = "frame_image"
    case trial_time     = "trial_time"
    case time_interval = "time_interval"
    case completion_time     = "completion_time"
    case image_count     = "image_count"
    case block     = "block"
    case empty_image     = "empty_image"
    case is_hidden = "is_hidden"
    case rein_force_non_preferreds     = "rein_force_non_preferreds"
    case correct_answer     = "correct_answer"
    case correct_image = "correct_image"
    case req_no     = "req_no"
    case assessment_type     = "assessment_type"
    case images     = "images"
    case audio_file     = "audio_file"
    case level     = "level"
    case video     = "video"
    case answers     = "answers"
    case status  = "status"
    case complete_rate  = "complete_rate"
    case question_id  = "question_id"
    case success_count  = "success_count"
    case time_taken  = "time_taken"
    case puzzle_count  = "puzzle_count"
    case selection  = "selection"
    case preferredSelection  = "preferredSelection"
    case touchResponse  = "touchResponse"
    case responseTime  = "responseTime"
    case nickname  = "nickname"
    case dob  = "dob"
    case guardian_name  = "guardian_name"
    case country  = "country"
    case city  = "city"
    case parent_contact_number  = "parent_contact_number"
    case value  = "value"
    case value_id = "value_id"
    case option  = "option"
    case detail  = "detail"
    case bucketList_count  = "bucketList_count"
    case imagesList_count  = "imagesList_count"
    case imagesList  = "imagesList"
    case bg_image  = "bg_image"
    case screen_type  = "screen_type"
    case first_value  = "first_value"
    case second_value  = "second_value"
    case correct_value  = "correct_value"
    case answer_time  = "answer_time"
    case hour  = "hour"
    case minute  = "minute"
    case priority  = "priority"
    case total_attempt = "total_attempt"
    case total_correct = "total_correct"
    //case skill_domain = "skill_domain"
    case bucketList = "bucketList"
    case avtar_list = "avtar_list"
    case avatar_id = "avatar_id"
    case first_digit = "first_digit"
    case second_digit = "second_digit"
    case operatorString = "operator"
    case avatar = "avatar"
    case request = "request"
    case response = "response"
    case error = "error"
    case answer_date = "answer_date"
    case image_url = "image_url"
    case enable_reinforcer = "enable_reinforcer"
    case type = "type"
    case word = "word"
    case repeat_count = "repeat_count"
    case sequence_number = "sequence_number"
    case word_count = "word_count"
    case option_count = "option_count"
    case skill_domain_id = "skill_domain_id"
    case program_id = "program_id"
    case userResult = "userResult"
    case avtar_variations = "avtar_variations"
    case avtar_id = "avtar_id"
    case file = "file"
    case file_type = "file_type"
    case variation_type = "variation_type"
    case localDBFilePath = "localDBFilePath"
    case isDownloaded = "isDownloaded"
    case userid = "userid"
    case performance = "performance"
    case order = "order"
    case key = "key"
    case assesment_score = "assesment_score"
    case languageCode = "languageCode"
    case languageName = "languageName"
    case languageImage = "languageImage"
    case languageStatus = "languageStatus"
    case title = "title"
    case complete = "complete"
    case skip = "skip"
    case avtar_data = "avtar_data"
    case skill_name = "skill_name"
    case program_type = "program_type"
    case description = "description"
    case question = "question"
    case user_parent_feedback = "user_parent_feedback"
    case video_selection_70_data = "video_selection_70_data"
    case picture_array_25_data = "picture_array_25_data"
    case question_table_data = "question_table_data"
    case find_word_data = "find_word_data"
    case video_url = "video_url"
    case assessment_status = "assessment_status"
    case url = "url"
    case lookAtObjectTime = "lookAtObjectTime"
    case moving = "moving"
    case sound_of_animal = "sound_of_animal"
    case position = "position"
    case eye_tracking_supported_device = "eye_tracking_supported_device"
    case total_count = "total_count"
    case faceDetectionTime = "faceDetectionTime"
    case faceNotDetectionTime = "faceNotDetectionTime"
    case cmd_name = "cmd_name"
    case command_array = "command_array"
    case Position = "Position"
    case text = "text"
    case drag_direction = "drag_direction"
    case larger_scale = "larger_scale"
    case image_border = "image_border"
    case touchOnEmptyScreenCount = "touchOnEmptyScreenCount"
    case selectedIndex = "selectedIndex"
    case incorrectDragDropCount = "incorrectDragDropCount"
    case wrongAnswerCount = "wrongAnswerCount"
    case condition = "condition"
    case child_condition = "child_condition"
    case isExpanded = "isExpanded"
    case child_count = "child_count"
    case cmd_array = "cmd_array"
    case avatar_variation = "avatar_variation"
    case variables_text = "variables_text"
    case time_in_second = "time_in_second"
    case objejct_image = "objejct_image"
    case goal_image = "goal_image"
    case child_action_duration = "child_action_duration"
    case child_action = "child_action"
    case is_complete = "is_complete"
    case bounce_direction = "bounce_direction"
    case color_code = "color_code"
    case correct_option = "correct_option"    
    case cmd_type = "cmd_type"
    case trial_prompt_type = "trial_prompt_type"
    case prompt_type = "prompt_type"
    case prompt_detail = "prompt_detail"
    case maze_id = "maze_id"
    case skill_domain_name = "skill_domain_name"
    case skill_domain_image = "skill_domain_image"
    case program = "program"
    case program_name = "program_name"
    case program_order = "program_order"
    case assement_complete_rate = "assement_complete_rate"
    case assement_complete_status = "assement_complete_status"
    case trial_complete_rate = "trial_complete_rate"
    case trial_complete_status = "trial_complete_status"
    case isFaceDetected = "isFaceDetected"
    case isDragStarted = "isDragStarted"
    case complete_percentage = "complete_percentage"
    case childDetail = "childDetail"
    case attemptLevel = "attemptLevel"
    case questionType = "questionType"
    case touch = "touch"
    case image_with_text = "image_with_text"
    case switch_command_time = "switch_command_time"
    case learning_complete_rate = "learning_complete_rate"
    case learning_complete_status = "learning_complete_status"
    case program_image = "program_image"
    case course_type = "course_type"
    case content_type = "content_type"
    //Trial
    case questionData = "questionData"
    case learning_current_status = "learning_current_status"
    case learning_status = "learning_status"
    case trial_status = "trial_status"
    case show_circle = "show_circle"
    case learning_attempt_status = "learning_attempt_status"
    case trial_attempt_status = "trial_attempt_status"
    case assement_attempt_status = "assement_attempt_status"
    case complete_count = "complete_count"
    case count = "count"
    case assesment_status = "assesment_status"
    case faceDetectionDataList = "faceDetectionDataList"
    case screenLoadTime = "screenLoadTime"
    case screenSubmitTime = "screenSubmitTime"
    case idleTime = "idleTime"
    case faceDetectionOnTime = "faceDetectionOnTime"
    case faceDetectionOffTime = "faceDetectionOffTime"
    case showSkillprogram = "showSkillprogram"
    case skillprogramDetail = "skillprogramDetail"
    case child_actions = "child_actions"
    case sound = "sound"
    case all_dates = "all_dates"
    case history = "history"
    case startdate = "startdate"
    case start_date = "start_date"
    case end_date = "end_date"
    case userAnswer = "userAnswer"
    case log_type = "log_type"
    case transparent = "transparent"
    case table_name = "table_name"
    case position_of_finger = "position_of_finger"
    case blink = "blink"
    case blink_count = "blink_count"
    case assesment_question = "assesment_question"

    case header = "header"
    case errorCode = "errorCode"
    case state = "state"
    case avtar_gender = "avtar_gender"
    case avatarGender = "avatarGender"

    case avatar_move = "avatar_move"
    case zoom_on = "zoom_on"
    case background = "background"
    case reinforce = "reinforce"
    case correct_text = "correct_text"
    case incorrect_text = "incorrect_text"
    
    case bucket = "bucket"
    case index = "index"
    
    case new_correct_question_till_mand = "new_correct_question_till_mand"
    case content_id = "content_id"
}


