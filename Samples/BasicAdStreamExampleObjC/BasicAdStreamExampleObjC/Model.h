//
//  Model.h
//  BasicAdStreamExampleObjC
//
//  Created by Teodor Cristea on 13/02/2020.
//  Copyright © 2020 Inc, AdsWizz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AdswizzSDK/AdswizzSDK.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, PlayerState) {
  PlayerStatePlaying,
  PlayerStateStopped,
  PlayerStatePaused
};

@class Model;
@protocol ModelAdBreakDelegate

- (void)modelDidStartAdBreak:(Model *)model;
- (void)modelDidEndAdBreak:(Model *)model;
 
@end

@protocol ModelStreamingDelegate

- (void)modelDidStartStreaming:(Model *)model;
- (void)modelDidStopStreaming:(Model *)model;
- (void)modelDidPauseStreaming:(Model *)model;
- (void)modelDidResumeStreaming:(Model *)model;
 
@end


@interface Model : NSObject

@property(nonatomic, readwrite) BOOL isUsingExternalPlayer;
@property(nonatomic, assign, readonly) PlayerState state;
@property (nonatomic, weak) id <ModelStreamingDelegate> streamDelegate;
@property (nonatomic, weak) id <ModelAdBreakDelegate> adBreakDelegate;

- (BOOL)play;
- (void)stop:(BOOL)callDelegate;
- (void)pause;
- (void)resume;
- (void)skipAd;
- (BOOL)isReadyToPlay;

@end

NS_ASSUME_NONNULL_END
