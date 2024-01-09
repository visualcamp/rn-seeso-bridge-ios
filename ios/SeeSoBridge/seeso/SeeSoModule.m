//
//  SeeSoModule.m
//  ParkinsonDetection
//
//  Created by David on 2023/08/31.
//
#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(SeeSoModule, NSObject)

RCT_EXTERN_METHOD(checkCameraPermission:(RCTResponseSenderBlock *)callback)
RCT_EXTERN_METHOD(requestCameraPermission:(RCTResponseSenderBlock *)callback)
RCT_EXTERN_METHOD(initSeeSo:(NSString *)licenseString option:(BOOL)option callback:(RCTResponseSenderBlock *)callback)
RCT_EXTERN_METHOD(isInit:(RCTResponseSenderBlock *)callback)
RCT_EXTERN_METHOD(deinitSeeSo:(RCTResponseSenderBlock *)callback)
RCT_EXTERN_METHOD(startTracking:(RCTResponseSenderBlock *)callback)
RCT_EXTERN_METHOD(stopTracking:(RCTResponseSenderBlock *)callback)
RCT_EXTERN_METHOD(startCollectSamples:(RCTResponseSenderBlock *)callback)
RCT_EXTERN_METHOD(isTracking:(RCTResponseSenderBlock *)callback)
RCT_EXTERN_METHOD(startCalibration:(double)x y:(double)y width:(double)width height:(double)height callback:(RCTResponseSenderBlock *)callback)
RCT_EXTERN_METHOD(stopCalibration:(RCTResponseSenderBlock *)callback)
RCT_EXTERN_METHOD(isCalibration:(RCTResponseSenderBlock *)callback)
RCT_EXTERN_METHOD(setCalibrationDatas:(NSArray<NSNumber *> *)datas callback:(RCTResponseSenderBlock *)callback)
@end

