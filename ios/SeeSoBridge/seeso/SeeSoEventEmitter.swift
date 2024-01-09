//
//  SeeSoEventEmitter.swift
//  ParkinsonDetection
//
//  Created by David on 2023/08/30.
//

import Foundation
import React

@objc(SeeSoEventEmitter)
open class SeeSoEventEmitter: RCTEventEmitter {
  static var eventEmitter: SeeSoEventEmitter!

  override init() {
    super.init()
    SeeSoEventEmitter.eventEmitter = self
  }

  override open func supportedEvents() -> [String]! {
    return ["onGaze", "onStatus", "onCalibrationNext", "onCalibrationProgress", "onCalibrationFinished", "onFace", "onBlink"]
  }

  @objc func onGaze(timestamp: Int, x: Double, y:Double, fixationX: Double, fixationY: Double, trackingState : String, eyeMovement : String, screenState : String, leftOpenness: Double, rightOpenness: Double) {
    SeeSoEventEmitter.eventEmitter?.sendEvent(withName: "onGaze", body: ["timestamp" : timestamp, "x" : x, "y" : y, "fixationX" : fixationX, "fixationY" : fixationY, "trackingState" : trackingState, "eyeMovementState": eyeMovement, "screenState": screenState, "leftOpenness": leftOpenness, "rightOpenness": rightOpenness] as [String : Any])
  }

  @objc func onFace(timestamp: Int, score: Double, left: Double, top: Double, right: Double, bottom: Double, pitch: Double, yaw: Double, roll: Double, imageWidth: Int, imageHeight: Int, centerX: Double, centerY: Double, centerZ: Double) {
    SeeSoEventEmitter.eventEmitter.sendEvent(withName: "onFace", body: ["timestamp": timestamp, "left": left, "top": top, "right": right, "bottom": bottom, "pitch": pitch, "yaw": yaw, "roll": roll, "imageWidth": imageWidth, "imageHeight": imageHeight, "centerX": centerX, "centerY": centerY, "centerZ": centerZ] as [String : Any])
  }

  @objc func onStatus(isTracking : Bool, errorMessage : String) {
    SeeSoEventEmitter.eventEmitter?.sendEvent(withName: "onStatus", body: ["errorMessage" : errorMessage, "isTracking" : isTracking] as [String : Any])
  }

  @objc func onCalibrationNext(nextX: Double, nextY: Double) {
    SeeSoEventEmitter.eventEmitter?.sendEvent(withName: "onCalibrationNext", body: ["nextX": nextX, "nextY": nextY] as [String : Any])
  }

  @objc func onCalibrationProgress(progress : Double) {
    SeeSoEventEmitter.eventEmitter?.sendEvent(withName: "onCalibrationProgress", body: ["progress": progress] as [String : Any])
  }

  @objc func onCalibrationFinished(calibrationData : [Double]) {
    SeeSoEventEmitter.eventEmitter?.sendEvent(withName: "onCalibrationFinished", body: ["calibrationData": calibrationData] as [String : Any])
  }

  @objc func onAttention(timestampBegin: Int, timestampEnd: Int, score: Double) {
    SeeSoEventEmitter.eventEmitter?.sendEvent(withName: "onAttention", body: ["timestampBegin": timestampBegin, "timestampEnd": timestampEnd, "score": score] as [String: Any])
  }

  @objc func onBlink(timestamp: Int, isBlinkLeft: Bool, isBlinkRight: Bool, isBlink: Bool, leftOpenness: Double, rightOpenness: Double) {
    SeeSoEventEmitter.eventEmitter.sendEvent(withName: "onBlink", body: ["timestamp": timestamp, "isBlinkLeft": isBlinkLeft, "isBlinkRight": isBlinkRight, "isBlink": isBlink, "leftOpenness": leftOpenness, "rightOpenness": rightOpenness] as [String: Any])
  }

  @objc func onDrowsiness(timestamp: Int, isDrowsiness: Bool, intensity: Double) {
    SeeSoEventEmitter.eventEmitter.sendEvent(withName: "onDrowsiness", body: ["timestamp": timestamp, "isDrowsiness": isDrowsiness, "intensity": intensity] as [String: Any])
  }

}
