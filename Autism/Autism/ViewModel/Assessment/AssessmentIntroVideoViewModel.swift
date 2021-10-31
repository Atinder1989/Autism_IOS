//
//  AssessmentIntroVideoViewModel.swift
//  Autism
//
//  Created by Savleen on 26/11/20.
//  Copyright © 2020 IMPUTE. All rights reserved.
//

import Foundation

class AssessmentIntroVideoViewModel  {
    var playerController: PlayerController?

    var dataClosure : (() -> Void)?
    var bufferLoaderClosure : (() -> Void)?
    var videoFinishedClosure : (() -> Void)?

        var accessmentSubmitResponseVO: AssessmentQuestionResponseVO? = nil {
                   didSet {
                       if let closure = self.dataClosure {
                           closure()
                       }
                   }
               }
    
    var isBufferLoader: Bool = false {
        didSet {
            if let bufferLoader = self.bufferLoaderClosure {
                bufferLoader()
            }
        }
    }
    
    init() {
        playerController = PlayerController.init()
        if let controller = self.playerController {
            controller.initializePlayer(delegate: self)
        }
    }
    
    func playVideo(item: VideoItem) {
        if let controller = self.playerController {
            controller.playVideo(item: item)
        }
    }
    
    func pausePlayer() {
        if let controller = self.playerController {
            controller.playPauseCommandToPlayer()
        }
    }
    
    func stopVideo() {
        if let controller = self.playerController {
            controller.stopVideo()
        }
    }
         
    func submitUserAnswer(info:IntroVideoQuestionInfo,skip:Bool) {
            var service = Service.init(httpMethod: .POST)
            service.url = ServiceHelper.assessmentQuestionSubmitUrl()
            if let user = UserManager.shared.getUserInfo() {
                service.params = [ ServiceParsingKeys.user_id.rawValue:user.id,
                                   ServiceParsingKeys.question_type.rawValue : info.question_type,
                    ServiceParsingKeys.question_id.rawValue : info.id,
                    ServiceParsingKeys.language.rawValue:user.languageCode,
                    ServiceParsingKeys.req_no.rawValue:info.req_no,
                    ServiceParsingKeys.skill_domain_id.rawValue:info.skill_domain_id,
                    ServiceParsingKeys.level.rawValue:info.level,
                    ServiceParsingKeys.skip.rawValue:skip,
                    ServiceParsingKeys.program_id.rawValue:info.program_id,
                    ServiceParsingKeys.faceNotDetectionTime.rawValue:FaceDetection.shared.getFaceNotDetectionTime(),
                    ServiceParsingKeys.log_type.rawValue:CourseModule.assessment.rawValue,
                ]
            }
            
            ServiceManager.processDataFromServer(service: service, model: AssessmentQuestionResponseVO.self) { (responseVo, error) in
                if let _ = error {
                     self.accessmentSubmitResponseVO = nil
                } else {
                    if let response = responseVo {
                        self.accessmentSubmitResponseVO = response
                    }
                }
            }
        }
    }


// MARK: - PlayerController Delegate
extension AssessmentIntroVideoViewModel: PlayerControllerDelegate {
    func didChangeJTPlayerStatus(status: VideoPlayerStatus) {
        switch status {
        case .playbackLikelyToKeepUp:
            self.isBufferLoader = false
        case .readyToPlay:
            self.isBufferLoader = false
        case .reachedToEnd:
            if let closure = self.videoFinishedClosure {
                closure()
            }
        case .bufferEmpty:
                self.isBufferLoader = true
        default:
            break
        }
    }
}
