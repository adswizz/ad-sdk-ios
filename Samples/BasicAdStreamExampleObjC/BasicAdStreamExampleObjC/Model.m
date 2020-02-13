//
//  Model.m
//  BasicAdStreamExampleObjC
//
//  Created by Teodor Cristea on 13/02/2020.
//  Copyright © 2020 Inc, AdsWizz. All rights reserved.
//

#import "Model.h"

@interface Model () <AASDKAdManagerDelegate, AASDKInteractiveAdManagerDelegate, AASDKAdStreamManagerDelegate>

@property(nonatomic, strong) NSURL *url;
@property(nonatomic, copy) NSString *adServer;
@property(nonatomic, readwrite) PlayerState state;
@property (nonatomic, strong) id<AASDKAdManager> adBreakManager;
@property(nonatomic, strong) AASDKAdswizzAdStreamManager *streamManager;

@end

@implementation Model

- (instancetype)init {
    self = [super init];
    if (self) {
        self.state = PlayerStateStopped;
        self.adServer = @"demo.deliveryengine.adswizz.com";
        self.url = [NSURL URLWithString:@"http://sdk.mobile.streaming.adswizz.com:8500/shakeDemo"];
    }
    return self;
}

// Public
- (BOOL)isReadyToPlay {
    return self.state != PlayerStateStopped;
}

- (BOOL)play {
    if (self.url == nil) {
        return NO;
    }
    
    BOOL canPlay = [self preparePlay];
    
    NSError *error = nil;
    [self.streamManager playWith:self.url error:&error];
    self.state = PlayerStatePlaying;
    [self.streamDelegate modelDidStartStreaming:self];
    return canPlay && error == nil;
}

- (void)stop:(BOOL)callDelegate {
    [self.streamManager stop];
    self.streamManager.delegate = nil;
    self.streamManager = nil;
    self.state = PlayerStateStopped;
    if (callDelegate) {
        [self.streamDelegate modelDidStopStreaming:self];
    }
}

- (void)pause {
    [self.streamManager pause];
    self.state = PlayerStatePaused;
    [self.streamDelegate modelDidPauseStreaming:self];
}

- (void)resume {
    [self.streamManager resume];
    self.state = PlayerStatePlaying;
    [self.streamDelegate modelDidResumeStreaming:self];
}

- (void)skipAd {
    [self.adBreakManager skipAd];
}

// Private
- (BOOL)preparePlay {
    // Stop current streaming if running
    [self stop:NO];
    
    NSError *error = nil;
    // Create a new stream manager
    if (self.streamManager == nil) {
        self.streamManager = [[[[[AASDKAdswizzAdStreamManagerBuilder new] withAdServer:self.adServer] withHttpProtocol:AASDKAdswizzAdRequestProtocolHttps] withCompanionZones:@""] buildAndReturnError:&error];
        self.streamManager.delegate = self;
    }
    return error == nil;
}

#pragma mark - AASDKInteractiveAdManagerDelegate

- (void)interactiveAdManager:(id <AASDKAdManager> _Nonnull)adManager shouldPresentCoupon:(NSData * _Nonnull)pkpassData {
}
- (void)interactiveAdManager:(id <AASDKAdManager> _Nonnull)adManager didReceiveAdEvent:(id <AASDKInteractiveAdEvent> _Nonnull)event {
}

#pragma mark - AASDKAdManagerDelegate

- (void)adManager:(id <AASDKAdManager> _Nonnull)adManager didReceiveAd:(id <AASDKAdData> _Nullable)ad error:(NSError * _Nonnull)error {
    NSLog(@"ad manager: %@ -- received ad: %@", adManager, ad.id);
}

- (void)adManager:(id <AASDKAdManager> _Nonnull)adManager didReceiveAdEvent:(id <AASDKAdEvent> _Nonnull)event {
    NSLog(@"ad manager: %@ -- triggered ad event: %@", adManager, event.stringEvent);
    
    switch (event.event) {
        case AASDKAdEventTypeDidFinishLoading:
        {
            //necessary, if there is more than one ad in the manager
            [adManager play];
            break;
        }
        case AASDKAdEventTypeDidStartPlaying:
        {
            //current ad in AdManager is playing
            break;
        }
        case AASDKAdEventTypeAllAdsDidFinishPlaying:
        {
            // Ad manager just finished playing (all) ad(s)
            break;
        }
        default:
            break;
    }

}

#pragma mark - AASDKAdStreamManagerDelegate

- (void)adStreamManager:(AASDKAdStreamManager * _Nonnull)adstreamManager willStartPlaying:(NSURL * _Nonnull)url {
    NSLog(@"ad stream manager: %@ -- received willStartPlaying: %@", adstreamManager, url);
}

- (void)adStreamManager:(AASDKAdStreamManager * _Nonnull)adstreamManager adBreakStarted:(id <AASDKAdManager> _Nonnull)manager {
    NSLog(@"ad stream manager: %@ -- received adBreakStarted", adstreamManager);
    self.adBreakManager = manager;
    self.adBreakManager.delegate = self; // register for notification on this AdManager
    self.adBreakManager.interactiveDelegate = self; // register for interactive ads notifications
    // Ad manager started playing the ad(s)
    [self.adBreakDelegate modelDidStartAdBreak:self];
}

- (void)adStreamManager:(AASDKAdStreamManager * _Nonnull)adstreamManager stateChanged:(enum AASDKMediaPlayerStatus)state {
    NSLog(@"ad stream manager: %@ -- received stateChanged: %@", adstreamManager, @(state));
}

- (void)adStreamManager:(AASDKAdStreamManager * _Nonnull)adstreamManager adBreakEnded:(id <AASDKAdManager> _Nonnull)manager {
    NSLog(@"ad stream manager: %@ -- received adBreakEnded", adstreamManager);
    self.adBreakManager.delegate = nil;
    self.adBreakManager.interactiveDelegate = nil;
    self.adBreakManager = nil;
    // Ad manager just finished playing (all) ad(s)
    [self.adBreakDelegate modelDidEndAdBreak:self];
}

- (void)adStreamManager:(AASDKAdStreamManager * _Nonnull)adstreamManager metadataChanged:(NSArray<AVMetadataItem *> * _Nonnull)metadata {
    NSLog(@"ad stream manager: %@ -- received metadataChanged", adstreamManager);
}

- (void)adStreamManagerWillReconnect:(AASDKAdStreamManager * _Nonnull)adstreamManager {
    NSLog(@"ad stream manager: %@ -- received willReconnect", adstreamManager);
}

- (void)adStreamManagerPlayerShouldPause:(AASDKAdStreamManager * _Nonnull)adstreamManager {
    NSLog(@"ad stream manager: %@ -- received playerShouldPause", adstreamManager);
}

- (void)adStreamManagerPlayerShouldResume:(AASDKAdStreamManager * _Nonnull)adstreamManager {
    NSLog(@"ad stream manager: %@ -- received playerShouldResume", adstreamManager);
}

@end
