//
//  SeeSoModule.swift
//  ParkinsonDetection
//
//  Created by David on 2023/08/30.
//

import Foundation
import React
import SeeSo
import AVFoundation

@objc(SeeSoModule)
class SeeSoModule: NSObject {
  private var gazeTracker : GazeTracker?

  private var initCallback : RCTResponseSenderBlock?

  @objc func checkCameraPermission(_ callback: @escaping RCTResponseSenderBlock) {
    DispatchQueue.main.async {
      let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
      let isAuthorized = (authStatus == .authorized)
      callback([isAuthorized])
    }
  }

  @objc func requestCameraPermission(_ callback: @escaping RCTResponseSenderBlock) {
    DispatchQueue.main.async {
      AVCaptureDevice.requestAccess(for: .video) { granted in
        if granted {
          callback([true])
        } else {
          callback([false])
        }
      }
    }
  }

  @objc func initSeeSo(_ licenseString: String, option: Bool, callback: @escaping RCTResponseSenderBlock) {
    if(self.gazeTracker != nil) {
      GazeTracker.deinitGazeTracker(tracker: self.gazeTracker)
      self.gazeTracker = nil
    }
    DispatchQueue.main.async { [weak self] in
      guard let self = self else {return}
      if _checkCameraPermission() {
        self.initCallback = callback
        let userStatusOption = UserStatusOption()
        if option {
          userStatusOption.useAll()
        }
        DispatchQueue.global(qos: .userInteractive).async {
          GazeTracker.initGazeTracker(license: licenseString, delegate: self, option: userStatusOption)
        }
      } else {
        callback(["Camera_Permission_", false])
      }
    }
  }

  @objc func isInit(_ callback: @escaping RCTResponseSenderBlock) {
    let isExist = self.gazeTracker != nil
    DispatchQueue.main.async {
      callback([isExist])
    }
  }

  @objc func deinitSeeSo(_ callback: @escaping RCTResponseSenderBlock) {
    GazeTracker.deinitGazeTracker(tracker: self.gazeTracker)
    DispatchQueue.main.async {
      callback([true])
    }
  }

  @objc func startTracking(_ callback: @escaping RCTResponseSenderBlock) {
    DispatchQueue.main.async { [weak self] in
      guard let self = self else {return}
      if _checkCameraPermission() {
        if let tracker = self.gazeTracker{
          tracker.startTracking()
          callback(["start_tracking", true])
        } else {
          callback(["GazeTracking not init", false])
        }
      } else {
        callback(["Camera_Permission_", false])
      }
    }
  }

  @objc func stopTracking(_ callback: @escaping RCTResponseSenderBlock) {
    DispatchQueue.main.async { [weak self] in
      guard let self = self else {return}
      if _checkCameraPermission() {
        if let tracker = self.gazeTracker {
          tracker.stopTracking()
          callback(["stop_tracking", true])
        } else {
          callback(["GazeTracking not init", false])
        }
      } else {
        callback(["Camera_Permission_", false])
      }
    }
  }

  @objc func isTracking(_ callback: @escaping RCTResponseSenderBlock) {
    DispatchQueue.main.async { [weak self] in
      guard let self = self else {return}
      if _checkCameraPermission() {
        let result = self.gazeTracker?.isTracking()
        if let result = result{
          callback(["is_tracking", result])
        } else {
          callback(["GazeTracking not init", false])
        }
      } else {
        callback(["Camera_Permission_", false])
      }
    }
  }

  @objc func startCalibration(_ x: Double, y: Double, width: Double, height: Double, callback: @escaping RCTResponseSenderBlock) {
    DispatchQueue.main.async { [weak self] in
      guard let self = self else {return}
      if _checkCameraPermission() {
        let region = CGRect(x: x, y: y, width: width, height: height)
        let result = self.gazeTracker?.startCalibration(region: region)
        if let result = result{
          callback(["start_calibration", result])
        } else {
          callback(["GazeTracking not init", false])
        }
      } else {
        callback(["Camera_Permission_", false])
      }
    }
  }

  @objc func stopCalibration(_ callback: @escaping RCTResponseSenderBlock) {
    DispatchQueue.main.async { [weak self] in
      guard let self = self else {return}
      if _checkCameraPermission() {
        if let tracker = self.gazeTracker{
          tracker.stopCalibration()
          callback(["stop_calibration", true])
        } else {
          callback(["GazeTracking not init", false])
        }
      } else {
        callback(["Camera_Permission_", false])
      }
    }
  }

  @objc func startCollectSamples(_ callback: @escaping RCTResponseSenderBlock) {
    DispatchQueue.main.async { [weak self] in
      guard let self = self else {return}
      if _checkCameraPermission() {
        if let tracker = self.gazeTracker {
          tracker.startCollectSamples()
          callback(["stop_calibration", true])
        } else {
          callback(["GazeTracking not init", false])
        }
      } else {
        callback(["Camera_Permission_", false])
      }
    }
  }

  @objc func isCalibration(_ callback: @escaping RCTResponseSenderBlock) {
    DispatchQueue.main.async { [weak self] in
      guard let self = self else {return}
      if _checkCameraPermission() {
        let result = self.gazeTracker?.isCalibrating()
        if let result = result{
          callback(["is_calibration", result])
        } else {
          callback(["GazeTracking not init", false])
        }
      } else {
        callback(["Camera_Permission_", false])
      }
    }
  }

  @objc func setCalibrationDatas(_ datas: [Double], callback: @escaping RCTResponseSenderBlock) {
    DispatchQueue.main.async { [weak self] in
      guard let self = self else {return}
      if _checkCameraPermission() {
        let result = self.gazeTracker?.setCalibrationData(calibrationData: datas)
        if let result = result {
          callback(["set_Calibration", result])
        } else {
          callback(["GazeTracking not init", false])
        }
      } else {
        callback(["Camera_Permission_", false])
      }
    }
  }

  private func _checkCameraPermission() -> Bool {
    let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
    return (authStatus == .authorized)
  }
}

extension SeeSoModule : InitializationDelegate, GazeDelegate, FaceDelegate, UserStatusDelegate, StatusDelegate, CalibrationDelegate {
  func onInitialized(tracker: SeeSo.GazeTracker?, error: SeeSo.InitializationError) {
    if (tracker != nil) {
      initCallback?([error.description, true])
      self.gazeTracker = tracker
      self.gazeTracker?.gazeDelegate = self
      self.gazeTracker?.statusDelegate = self
      self.gazeTracker?.calibrationDelegate = self
      self.gazeTracker?.faceDelegate = self
      self.gazeTracker?.userStatusDelegate = self
    } else {
      initCallback?([error.description, false])
    }
    initCallback = nil;
  }

  func onGaze(gazeInfo: SeeSo.GazeInfo) {
    DispatchQueue.main.async {
      SeeSoEventEmitter.eventEmitter.onGaze(timestamp: Int(gazeInfo.timestamp), x: gazeInfo.x, y: gazeInfo.y, fixationX: gazeInfo.fixationX, fixationY: gazeInfo.fixationY, trackingState: gazeInfo.trackingState.description, eyeMovement: gazeInfo.eyeMovementState.description, screenState: gazeInfo.screenState.description, leftOpenness: gazeInfo.leftOpenness, rightOpenness: gazeInfo.rightOpenness)
    }
  }

  func onStarted() {
    DispatchQueue.main.async {
      SeeSoEventEmitter.eventEmitter.onStatus(isTracking: true, errorMessage: "none")
    }
  }

  func onStopped(error: SeeSo.StatusError) {
    DispatchQueue.main.async {
      SeeSoEventEmitter.eventEmitter.onStatus(isTracking: false, errorMessage: error.description)
    }
  }

  func onCalibrationNextPoint(x: Double, y: Double) {
    DispatchQueue.main.async {
      SeeSoEventEmitter.eventEmitter.onCalibrationNext(nextX: x, nextY: y)
    }
  }

  func onCalibrationProgress(progress: Double) {
    DispatchQueue.main.async {
      SeeSoEventEmitter.eventEmitter.onCalibrationProgress(progress: progress)
    }
  }

  func onCalibrationFinished(calibrationData: [Double]) {
    DispatchQueue.main.async {
      SeeSoEventEmitter.eventEmitter.onCalibrationFinished(calibrationData: calibrationData)
    }
  }

  func onFace(faceInfo: FaceInfo) {
    DispatchQueue.main.async {
      SeeSoEventEmitter.eventEmitter.onFace(timestamp: Int(faceInfo.timestamp), score: faceInfo.score, left: faceInfo.rect.minX, top: faceInfo.rect.minY, right: faceInfo.rect.maxX, bottom: faceInfo.rect.maxY, pitch: faceInfo.pitch, yaw: faceInfo.yaw, roll: faceInfo.roll, imageWidth: Int(faceInfo.imageSize.width), imageHeight: Int(faceInfo.imageSize.height), centerX: faceInfo.centerX, centerY: faceInfo.centerY, centerZ: faceInfo.centerZ)
    }
  }

  func onBlink(timestamp: Int, isBlinkLeft: Bool, isBlinkRight: Bool, isBlink: Bool, leftOpenness: Double, rightOpenness: Double) {
    DispatchQueue.main.async {
      SeeSoEventEmitter.eventEmitter.onBlink(timestamp: timestamp, isBlinkLeft: isBlinkLeft, isBlinkRight: isBlinkRight, isBlink: isBlink, leftOpenness: leftOpenness, rightOpenness: rightOpenness)
    }
  }

  func onAttention(timestampBegin: Int, timestampEnd: Int, score: Double) {
//    DispatchQueue.main.async {
//      SeeSoEventEmitter.eventEmitter.onAttention(timestampBegin: timestampBegin, timestampEnd: timestampEnd, score: score)
//    }
  }

  func onDrowsiness(timestamp: Int, isDrowsiness: Bool, intensity: Double) {
//    DispatchQueue.main.async {
//      SeeSoEventEmitter.eventEmitter.onDrowsiness(timestamp: timestamp, isDrowsiness: isDrowsiness, intensity: intensity)
//    }
  }

}
