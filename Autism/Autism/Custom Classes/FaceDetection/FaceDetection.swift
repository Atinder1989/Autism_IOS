//
//  FaceDetection.swift
//  VisionFaceTrack
//
//  Created by Savleen on 22/09/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation
import AVKit
import Vision



class FaceDetection: NSObject {
    static let shared = FaceDetection()
    private var faceNotDetectionView: FaceNotDetectionView?
    private override init() {
        super.init()
     //   self.faceNotDetectionView = self.createFaceNotDetectionView()
    }
    
    // AVCapture variables to hold sequence data
    private var session: AVCaptureSession?
   // private var delegate: FaceDetectionDelegate?

    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var videoDataOutput: AVCaptureVideoDataOutput?
    private var videoDataOutputQueue: DispatchQueue?
    private var captureDevice: AVCaptureDevice?
    private var captureDeviceResolution: CGSize = CGSize()
    
    // Layer UI for drawing Vision results
    private var rootLayer: CALayer?
    private var detectionOverlayLayer: CALayer?
    
    // Vision requests
    private var detectionRequests: [VNDetectFaceRectanglesRequest]?
    private var trackingRequests: [VNTrackObjectRequest]?
    lazy private var sequenceRequestHandler = VNSequenceRequestHandler()
    
    private var faceDetectedTimer: Timer? = nil
    private var timeCount = 0
    private var faceDetectionDataList: [[String:Any]] = []
    var isFaceDetected = true
    
      private var faceDetectionDateTime: Date?
      private var faceNotDetectionDateTime: Date?
      private var secondsForFacedetectionOn = 15
      private var cameraOnTime = 4

}

extension UIDevice {
     var isSimulator: Bool {
            return TARGET_OS_SIMULATOR != 0
     }
}

// MARK: Public Methods
extension FaceDetection {
    
    func initializeFaceDetection() {
        if !UIDevice.current.isSimulator {
            self.session = self.setupAVCaptureSession()
            self.prepareVisionRequest()
        }
    }
    
    func startFaceDetectionSession() {
        self.startTimer()
    }
    
    func stopFaceDetectionSession() {
        self.resetData()
        self.offCameraForFaceDetection()
        self.stopTimer()
        self.removeFaceNotDetectionView()
    }
    
    func getFaceDetectionTime() -> Int {
        return 0
    }

    func getFaceNotDetectionTime() -> Int {
        return 0
    }
    
    func getFaceDetectionDataList() -> [[String:Any]]  {
        return self.faceDetectionDataList
    }
    
    func getIdleTimeinSeconds() -> Int {
        if self.faceDetectionDataList.count > 0 {
            var idleTime = 0
            for dict in self.faceDetectionDataList {
                let onTime:String = dict[ServiceParsingKeys.faceDetectionOnTime.rawValue] as! String
                let offTime = dict[ServiceParsingKeys.faceDetectionOffTime.rawValue] as! String
                if  let onTimeString = Utility.convertStringToDate(strDate: onTime, format: dateFormat),let offTimeString = Utility.convertStringToDate(strDate: offTime, format: dateFormat) {
                    let seconds = Utility.getDateDifferenceInSeconds(startDate: onTimeString, endDate: offTimeString)
                    idleTime = idleTime + abs(seconds)
                }
            }
            return idleTime
        }
        return 0
    }
}

// MARK: Private Methods For FaceNotDetectionView
extension FaceDetection {
    private func createFaceNotDetectionView() -> FaceNotDetectionView {
        let view = Utility.getView(of: FaceNotDetectionView.self)
         let frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width,
         height: UIScreen.main.bounds.height)
        view.frame = frame
        view.setDelegate(delegate: self)
        return view
    }
    
    private func showFaceNotDetectionView() {
        DispatchQueue.main.async { [weak self] in
            if let topVC = UIApplication.topViewController(),let this = self {
              let rViews = topVC.view.allSubViewsOf(type: FaceNotDetectionView.self)
                  if rViews.count == 0 {
                    if let faceNotDetection = this.faceNotDetectionView {
                        topVC.view.addSubview(faceNotDetection)
                        this.saveFaceOffTime()
                        AutismTimer.shared.stopTimer()
                    }
                  }
              }
          }
    }
    
    private func hideFaceNotDetectionView() {
        DispatchQueue.main.async { [weak self] in
            if let topVC = UIApplication.topViewController(),let this = self {
                this.removeFaceNotDetectionView()
                this.saveFaceOnTime()
                this.startRecorderWithAppFlow()
                AutismTimer.shared.initializeTimer(delegate: topVC as? AutismTimerDelegate )
             }
        }
    }
    
    private func removeFaceNotDetectionView(){
        if let topVC = UIApplication.topViewController() {
            let rViews = topVC.view.allSubViewsOf(type: FaceNotDetectionView.self)
            if rViews.count > 0 {
                rViews[0].removeFromSuperview()
            }
        }
    }
    
}
// MARK: Private Methods For Camera
extension FaceDetection {
    private func onCameraForFaceDetection() {
        if let s = self.session {
            if !s.isRunning {
                s.startRunning()
            }
        }
    }
    
    private func offCameraForFaceDetection() {
        if let s = self.session {
            s.stopRunning()
        }
    }
}


// MARK: Private Methods
extension FaceDetection {
    private func resetData() {
         timeCount = 0
         self.faceDetectionDataList.removeAll()
         isFaceDetected = true
         self.faceNotDetectionDateTime = nil
         self.faceDetectionDateTime = nil
    }
    
    private func startRecorderWithAppFlow() {
        if let topVC = UIApplication.topViewController() {
            if (topVC is AssessmentIntroductionViewController) || (topVC is AssessmentVerbalQuestionViewController) || (topVC is AssessmentVerbalMultiplesViewController) || (topVC is AssessmentSoundImitationViewController) || (topVC is AssessmentEnvironmentalSoundViewController)  {
                if !RecordingManager.shared.isRecording() {
                        RecordingManager.shared.startRecording(delegate: topVC as! RecordingManagerDelegate)
                }
            }
        }
        
        
    }

    private func stopRecorderWithAppFlow() {
//        if let topVC = UIApplication.topViewController() {
//          if (topVC is AssessmentIntroductionViewController) {
//            if RecordingManager.shared.isRecording() {
//               RecordingManager.shared.stopRecording()
//               RecordingManager.shared.stopWaitUserAnswerTimer()
//            }
//          }
//        }
        
//        if RecordingManager.shared.isRecording() {
//
//        }
        RecordingManager.shared.stopRecording()
        RecordingManager.shared.stopWaitUserAnswerTimer()
    }
  
    private func startTimer() {
        if self.faceDetectedTimer == nil {
            faceDetectedTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(calculateFaceDetectedTime), userInfo: nil, repeats: true)
        }
    }
    
    @objc private func calculateFaceDetectedTime() {
        self.timeCount = self.timeCount + 1
        print("Face Detection Timer ========= \(self.timeCount)")
        if timeCount == secondsForFacedetectionOn {
            self.stopTimer()
            self.onCameraForFaceDetection()
        } else {
            if !isFaceDetected {
                if let user = UserManager.shared.getUserInfo() {
                    let message = Utility.deCrypt(text: user.nickname) + SpeechMessage.lookingForYou.getMessage()
                  //  SpeechManager.shared.speak(message: message, uttrenceRate: AppConstant.speakUtteranceNormalRate.rawValue.floatValue)
                }
            }
        }
    }
    
    private func stopTimer() {
        if let timer = self.faceDetectedTimer {
            timer.invalidate()
            self.faceDetectedTimer = nil
            self.timeCount = 0
        }
    }
    

    private func handleFaceNotDetected() {
        print("@@@@@@@@@@@@@@@@@@@@@@")
        self.isFaceDetected = false
        self.offCameraForFaceDetection()
        self.stopRecorderWithAppFlow()
        self.showFaceNotDetectionView()
        self.startTimer()
    }
    
    private func handleFaceDetected() {
        print("**********************")
        self.isFaceDetected = true
        self.offCameraForFaceDetection()
        self.hideFaceNotDetectionView()
        self.startTimer()
    }
    
    private func saveFaceOffTime() {
        if let date = self.faceNotDetectionDateTime {
            let stringDate = Utility.convertDateToString(date: date, format: dateFormat)
            if faceDetectionDataList.count > 0 {
                let lastElement = faceDetectionDataList.last
                if let val = lastElement![ServiceParsingKeys.faceDetectionOnTime.rawValue] {
                    self.faceDetectionDataList.remove(at: self.faceDetectionDataList.count - 1)
                    let dict:[String:Any] = [ServiceParsingKeys.faceDetectionOffTime.rawValue:stringDate,ServiceParsingKeys.faceDetectionOnTime.rawValue:val]
                    self.faceDetectionDataList.append(dict)

                } else {
                    let dict:[String:Any] = [ServiceParsingKeys.faceDetectionOffTime.rawValue:stringDate]
                    self.faceDetectionDataList.append(dict)
                }
            } else {
                let dict:[String:Any] = [ServiceParsingKeys.faceDetectionOffTime.rawValue:stringDate]
                self.faceDetectionDataList.append(dict)
            }
        }
        self.faceNotDetectionDateTime = nil
        self.faceDetectionDateTime = nil
    }
    
    private func saveFaceOnTime() {
        if let date = self.faceDetectionDateTime {
            let stringDate = Utility.convertDateToString(date: date, format: dateFormat)
            if faceDetectionDataList.count > 0 {
                let lastElement = faceDetectionDataList.last
                if let val = lastElement![ServiceParsingKeys.faceDetectionOffTime.rawValue] {
                    self.faceDetectionDataList.remove(at: self.faceDetectionDataList.count - 1)
                    let dict:[String:Any] = [ServiceParsingKeys.faceDetectionOnTime.rawValue:stringDate,ServiceParsingKeys.faceDetectionOffTime.rawValue:val]
                    self.faceDetectionDataList.append(dict)

                } else {
                    let dict:[String:Any] = [ServiceParsingKeys.faceDetectionOnTime.rawValue:stringDate]
                    self.faceDetectionDataList.append(dict)
                }
            } else {
                let dict:[String:Any] = [ServiceParsingKeys.faceDetectionOnTime.rawValue:stringDate]
                self.faceDetectionDataList.append(dict)
            }
        }
        print(self.faceDetectionDataList)
        self.faceNotDetectionDateTime = nil
        self.faceDetectionDateTime = nil
    }
    
    // MARK: AVCapture Setup
    /// - Tag: CreateCaptureSession
    private func setupAVCaptureSession() -> AVCaptureSession? {
        let captureSession = AVCaptureSession()
        do {
            let inputDevice = try self.configureFrontCamera(for: captureSession)
            self.configureVideoDataOutput(for: inputDevice.device, resolution: inputDevice.resolution, captureSession: captureSession)
            return captureSession
        } catch let executionError as NSError {
            self.presentError(executionError)
        } catch {
            self.presentErrorAlert(message: "An unexpected failure has occured")
        }
        
        self.teardownAVCapture()
        return nil
    }
    
    /// - Tag: ConfigureDeviceResolution
    private func highestResolution420Format(for device: AVCaptureDevice) -> (format: AVCaptureDevice.Format, resolution: CGSize)? {
        var highestResolutionFormat: AVCaptureDevice.Format? = nil
        var highestResolutionDimensions = CMVideoDimensions(width: 0, height: 0)
        
        for format in device.formats {
            let deviceFormat = format as AVCaptureDevice.Format
            
            let deviceFormatDescription = deviceFormat.formatDescription
            if CMFormatDescriptionGetMediaSubType(deviceFormatDescription) == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange {
                let candidateDimensions = CMVideoFormatDescriptionGetDimensions(deviceFormatDescription)
                if (highestResolutionFormat == nil) || (candidateDimensions.width > highestResolutionDimensions.width) {
                    highestResolutionFormat = deviceFormat
                    highestResolutionDimensions = candidateDimensions
                }
            }
        }
        
        if highestResolutionFormat != nil {
            let resolution = CGSize(width: CGFloat(highestResolutionDimensions.width), height: CGFloat(highestResolutionDimensions.height))
            return (highestResolutionFormat!, resolution)
        }
        
        return nil
    }
    
    private func configureFrontCamera(for captureSession: AVCaptureSession) throws -> (device: AVCaptureDevice, resolution: CGSize) {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .front)
        
        if let device = deviceDiscoverySession.devices.first {
            if let deviceInput = try? AVCaptureDeviceInput(device: device) {
                if captureSession.canAddInput(deviceInput) {
                    captureSession.addInput(deviceInput)
                }
                
                if let highestResolution = self.highestResolution420Format(for: device) {
                    try device.lockForConfiguration()
                    device.activeFormat = highestResolution.format
                    device.unlockForConfiguration()
                    
                    return (device, highestResolution.resolution)
                }
            }
        }
        
        throw NSError(domain: "ViewController", code: 1, userInfo: nil)
    }
    
    /// - Tag: CreateSerialDispatchQueue
    private func configureVideoDataOutput(for inputDevice: AVCaptureDevice, resolution: CGSize, captureSession: AVCaptureSession) {
        
        let videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        
        // Create a serial dispatch queue used for the sample buffer delegate as well as when a still image is captured.
        // A serial dispatch queue must be used to guarantee that video frames will be delivered in order.
        let videoDataOutputQueue = DispatchQueue(label: "com.example.apple-samplecode.VisionFaceTrack")
        videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        
        if captureSession.canAddOutput(videoDataOutput) {
            captureSession.addOutput(videoDataOutput)
        }
        
        videoDataOutput.connection(with: .video)?.isEnabled = true
        
        if let captureConnection = videoDataOutput.connection(with: AVMediaType.video) {
            if captureConnection.isCameraIntrinsicMatrixDeliverySupported {
                captureConnection.isCameraIntrinsicMatrixDeliveryEnabled = true
            }
        }
        
        self.videoDataOutput = videoDataOutput
        self.videoDataOutputQueue = videoDataOutputQueue
        
        self.captureDevice = inputDevice
        self.captureDeviceResolution = resolution
    }
    
   
    
    // Removes infrastructure for AVCapture as part of cleanup.
    private func teardownAVCapture() {
        self.videoDataOutput = nil
        self.videoDataOutputQueue = nil
        
        if let previewLayer = self.previewLayer {
            previewLayer.removeFromSuperlayer()
            self.previewLayer = nil
        }
    }
    
    // MARK: Helper Methods for Error Presentation
    
    private func presentErrorAlert(withTitle title: String = "Unexpected Failure", message: String) {
        if let topVC = UIApplication.topViewController() {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            topVC.present(alertController, animated: true)
        }
    }
    
    private func presentError(_ error: NSError) {
        self.presentErrorAlert(withTitle: "Failed with error \(error.code)", message: error.localizedDescription)
    }
    
    private func exifOrientationForDeviceOrientation(_ deviceOrientation: UIDeviceOrientation) -> CGImagePropertyOrientation {
        
        switch deviceOrientation {
        case .portraitUpsideDown:
            return .rightMirrored
            
        case .landscapeLeft:
            return .downMirrored
            
        case .landscapeRight:
            return .upMirrored
            
        default:
            return .leftMirrored
        }
    }
    
    private func exifOrientationForCurrentDeviceOrientation() -> CGImagePropertyOrientation {
        return exifOrientationForDeviceOrientation(UIDevice.current.orientation)
    }
    
    // MARK: Performing Vision Requests
    
    /// - Tag: WriteCompletionHandler
    private func prepareVisionRequest() {
        
        //self.trackingRequests = []
        var requests = [VNTrackObjectRequest]()
        
        let faceDetectionRequest = VNDetectFaceRectanglesRequest(completionHandler: { (request, error) in
            
            if error != nil {
                print("FaceDetection error: \(String(describing: error)).")
            }
            
            guard let faceDetectionRequest = request as? VNDetectFaceRectanglesRequest,
                let results = faceDetectionRequest.results as? [VNFaceObservation] else {
                    return
            }
            DispatchQueue.main.async { [weak self] in
                // Add the observations to the tracking list
                if let this = self {
                for observation in results {
                    let faceTrackingRequest = VNTrackObjectRequest(detectedObjectObservation: observation)
                    requests.append(faceTrackingRequest)
                }
                    this.trackingRequests = requests
                }
            }
        })
        
        // Start with detection.  Find face, then track it.
        self.detectionRequests = [faceDetectionRequest]
        
        self.sequenceRequestHandler = VNSequenceRequestHandler()
        
        //self.setupVisionDrawingLayers()
    }
}

// MARK: AVCaptureVideoDataOutputSampleBufferDelegate Methods
extension FaceDetection: AVCaptureVideoDataOutputSampleBufferDelegate {
    // MARK: AVCaptureVideoDataOutputSampleBufferDelegate
    /// - Tag: PerformRequests
    // Handle delegate method callback on receiving a sample buffer.
    internal func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        print("captureOutput ========= $$$$$$$$$$$$$$$$")
        var requestHandlerOptions: [VNImageOption: AnyObject] = [:]
        
        let cameraIntrinsicData = CMGetAttachment(sampleBuffer, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, attachmentModeOut: nil)
        if cameraIntrinsicData != nil {
            requestHandlerOptions[VNImageOption.cameraIntrinsics] = cameraIntrinsicData
        }
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("Failed to obtain a CVPixelBuffer for the current output frame.")
            return
        }
        
        let exifOrientation = self.exifOrientationForCurrentDeviceOrientation()
        guard let requests = self.trackingRequests, !requests.isEmpty else {
            // No tracking object detected, so perform initial detection
            let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer,
                                                            orientation: exifOrientation,
                                                            options: requestHandlerOptions)
            
            do {
                guard let detectRequests = self.detectionRequests else {
                    return
                }
                DispatchQueue.main.async { [weak self] in
                    
                    if let this = self {
                    if let date = this.faceNotDetectionDateTime {
                        let seconds = Utility.getDateDifferenceInSeconds(startDate: date, endDate: Date())
                        print("Seconds === \(seconds)")
                        if seconds == this.cameraOnTime {
                            this.handleFaceNotDetected()
                        }
                    } else {
                        this.faceNotDetectionDateTime = Date()
                    }
                    }
                    
                }
                try imageRequestHandler.perform(detectRequests)
            } catch let error as NSError {
                NSLog("Failed to perform FaceRectangleRequest: %@", error)
            }
            return
        }
        
        do {
            try self.sequenceRequestHandler.perform(requests,
                                                     on: pixelBuffer,
                                                     orientation: exifOrientation)
        } catch let error as NSError {
            NSLog("Failed to perform SequenceRequest: %@", error)
        }
        
        // Setup the next round of tracking.
        var newTrackingRequests = [VNTrackObjectRequest]()
        for trackingRequest in requests {
            
            guard let results = trackingRequest.results else {
                return
            }
            
            guard let observation = results[0] as? VNDetectedObjectObservation else {
                return
            }
            
            if !trackingRequest.isLastFrame {
                if observation.confidence > 0.3 {
                    trackingRequest.inputObservation = observation
                } else {
                    trackingRequest.isLastFrame = true
                }
                newTrackingRequests.append(trackingRequest)
            }
        }
        self.trackingRequests = newTrackingRequests
        
        if newTrackingRequests.isEmpty {
            // Nothing to track, so abort.
            return
        }
        
        // Perform face landmark tracking on detected faces.
        var faceLandmarkRequests = [VNDetectFaceLandmarksRequest]()
        
        // Perform landmark detection on tracked faces.
        for trackingRequest in newTrackingRequests {
            
            let faceLandmarksRequest = VNDetectFaceLandmarksRequest(completionHandler: { (request, error) in
                
                if error != nil {
                    print("FaceLandmarks error: \(String(describing: error)).")
                }
                
                guard let landmarksRequest = request as? VNDetectFaceLandmarksRequest,
                      let _ = landmarksRequest.results as? [VNFaceObservation] else {
                        return
                }
            })
            
            guard let trackingResults = trackingRequest.results else {
                return
            }
            
            guard let observation = trackingResults[0] as? VNDetectedObjectObservation else {
                return
            }
            let faceObservation = VNFaceObservation(boundingBox: observation.boundingBox)
            faceLandmarksRequest.inputFaceObservations = [faceObservation]
            
            // Continue to track detected facial landmarks.
            faceLandmarkRequests.append(faceLandmarksRequest)
            
            let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer,
                                                            orientation: exifOrientation,
                                                            options: requestHandlerOptions)
            DispatchQueue.main.async {  [weak self] in
            do {
                if let this = self {
                if let date = this.faceDetectionDateTime {
                    let seconds = Utility.getDateDifferenceInSeconds(startDate: date, endDate: Date())
                    print("Seconds === \(seconds)")
                    if seconds == this.cameraOnTime {
                        this.handleFaceDetected()
                    }
                } else {
                    this.faceDetectionDateTime = Date()
                }
                }
                try imageRequestHandler.perform(faceLandmarkRequests)
            } catch let error as NSError {
                NSLog("Failed to perform FaceLandmarkRequest: %@", error)
            }
            }
        }
    }
}


extension FaceDetection: FaceNotDetectionViewDelegate {
    func didTapOnOk(){
        stopTimer()
        self.faceDetectionDateTime = Date()
        handleFaceDetected()
    }
}
