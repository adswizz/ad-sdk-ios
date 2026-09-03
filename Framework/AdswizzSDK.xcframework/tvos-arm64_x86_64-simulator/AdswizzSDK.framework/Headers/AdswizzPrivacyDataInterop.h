//
//  AdswizzPrivacyDataInterop.h
//  AdswizzCore
//
//  Created by Teodor Cristea on 21.10.2024.
//  Copyright © 2024 Inc, AdsWizz. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol AdswizzMotionActivityManager;
@protocol AdswizzSpeechRecognizer;

NS_ASSUME_NONNULL_BEGIN

typedef NS_CLOSED_ENUM(NSUInteger, AdswizzPermissionTypeObjC) {
    /// System permissions
    location,           // when in use
#if !TARGET_OS_TV
    locationAdvanced,   // always
#endif
    photo,              // photo library
    microphone,         // microphone
    speech,             // speech recognition
    calendar,           // write only
    calendarAdvanced,   // full access
    contacts,           // contacts
    camera,             // camera
    idfa,               // idfa
    motionActivity,     // activity motion
};

typedef NS_CLOSED_ENUM(NSUInteger, AdswizzPermissionValueObjC) {
    granted,
    denied,
    notAsked,
    cantAsk
};

//MARK: - AdswizzRequestPermissionResult
/// Permission request result wrapper.
@interface AdswizzRequestPermissionResult : NSObject

@property (assign, nonatomic) AdswizzPermissionValueObjC success;
@property (strong, nonatomic, nullable) NSError *failure;
- (instancetype)initWithSuccess:(AdswizzPermissionValueObjC)success failure:(nullable NSError *)failure;

@end

typedef void (^AdswizzRequestPermissionHandler)(AdswizzRequestPermissionResult *result);

//MARK: - AdswizzPrivacyDataInterop
/// AdswizzSDKPrivacyData interop wrapper.
@interface AdswizzPrivacyDataInterop : NSObject

+ (BOOL)privacyDataModuleAvailable;
- (instancetype)init;
/// Get the authorization status for `permission`.
- (AdswizzPermissionValueObjC)authorizationStatusForPermission:(AdswizzPermissionTypeObjC)permission;
/// Attempt to request permission `type` with a `completion` block.
- (void)requestPermissionType:(AdswizzPermissionTypeObjC)permission completion:(AdswizzRequestPermissionHandler)handler;

- (nullable id<AdswizzMotionActivityManager>)buildActivityManager;
- (nullable id<AdswizzSpeechRecognizer>)buildSpeechRecognizerWithLocale:(NSLocale *)locale;

@end

NS_ASSUME_NONNULL_END
