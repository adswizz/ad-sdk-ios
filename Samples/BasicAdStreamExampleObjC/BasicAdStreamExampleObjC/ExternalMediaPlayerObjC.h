//
//  ExternalMediaPlayerObjC.h
//  BasicAdStreamExampleObjC
//
//  Created by Adrian Manolache on 15.07.2022.
//  Copyright © 2022 Inc, AdsWizz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AdswizzSDK/AdswizzSDK.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ExternalMediaPlayerObjC:NSObject <AASDKMediaPlayerState>

///  Delegate
@property (nonatomic, readonly) NSTimeInterval currentPlayhead;

@property (nonatomic, readonly) NSTimeInterval currentDuration;

@property (nonatomic, readonly) enum AASDKMediaPlayerStatus playerStatus;

@property (nonatomic, readonly, copy) NSArray<AVMetadataItem *> * _Nullable metadataItem;

@property (nonatomic, readonly) BOOL isBufferingWhilePaused;
/// Report volume for the player. This value should be between [0..1].
/// A value of 0.0 indicates silence; a value of 1.0 (the default) indicates full audio volume for the player instance.
@property (nonatomic, readonly) float volume;
/// Targetability
/// If the player failed to play the content this could report the last error, otherwise this should be nil.
@property (nonatomic, readonly) NSError * _Nullable lastError;
/// Targetability
/// A list of players capabilities
@property (nonatomic, readonly, copy) NSSet<AASDKMediaPlayerCapability *> * _Nullable capabilities;
/// Targetability
/// A list of player states as described by IAB which will better help in targetability
@property (nonatomic, readonly, copy) NSSet<AASDKMediaPlayerStateInfo *> * _Nullable stateInfo;

@property (nonatomic, readwrite) BOOL receivedPlayerDidFinishPlaying;
@property (nonatomic, readwrite) BOOL receivedPlayerPlaying;
@property (nonatomic, readwrite) BOOL observingCurrentItem;
@property (nonatomic, readwrite) AVPlayer* avPlayer;

- (void) play: (NSURL*) url;
- (void) stop;
- (void) pause;
- (void) resume;

@end

NS_ASSUME_NONNULL_END
