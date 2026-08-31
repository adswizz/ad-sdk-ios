//
//  ViewController.m
//  BasicAdRequestExampleObjC
//
//  Created by Teodor Cristea on 17/09/2019.
//  Copyright © 2020 Inc, AdsWizz. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "UIWindow+SafeArea.h"
#import "NSBundle+Version.h"
#import "ExternalMediaPlayerObjC.h"

#import <AdswizzSDK/AdswizzSDK.h>
#import <AVFoundation/AVFoundation.h>

// Private interface
@interface ViewController () <AASDKAdManagerDelegate, AASDKAdCompanionViewDelegate>
// Ads
@property (nonatomic, strong) id<AASDKAdManager> adManager;
@property (nonatomic, strong) AASDKAdRequestConnection *adConnection;

// Content playback
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic) Boolean isPlaying;
@property (nonatomic, strong) ExternalMediaPlayerObjC* externalPlayer;

// Views
@property (nonatomic, strong) IBOutlet UIToolbar *toolbar;
@property (nonatomic, strong) IBOutlet UILabel *statusLabel;
@property (nonatomic, strong) IBOutlet UILabel *playedTimeLabel;
@property (nonatomic, strong) IBOutlet AASDKAdCompanionView *companionView;
@property (nonatomic, strong) IBOutlet UISwitch* externalPlayerSwitch;

@end

@implementation ViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [NSString stringWithFormat:@"%@ - AdsWizz SDK v%@", @"Request ads", [[NSBundle bundleForClass:[AASDKAdRequest class]] version]];

    self.companionView.delegate = self;
    self.externalPlayer = [[ExternalMediaPlayerObjC alloc] init];
    
    // Prepare content playback
    NSString *path = [[NSBundle mainBundle] pathForResource:@"content_example" ofType:@"mp3"];
    if (path) {
        NSURL *url = [[NSURL alloc] initWithString:path];
        if (url) {
            // Start content playback
            NSError *error;
            self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
            self.audioPlayer.numberOfLoops = -1;
            
            if (!error) {
                [self playContent];
            } else {
                NSLog(@"can't play file");
            }
        } else {
            NSLog(@"can't load file");
        }
    } else {
        NSLog(@"can't find file");
    }
}

#pragma mark - Ad(s) request

- (IBAction)switchValueChanged:(UISwitch*) toggle {
    
}

- (IBAction)requestAds {
    NSError *error;
    AASDKAdswizzAdZone *adZone = [[[AASDKAdswizzAdZoneBuilder new] withZoneId:@"17862"] buildAndReturnError:&error];
    if (error) {
        NSLog(@"Oops, ad zone is no valid");
        return;
    }
    
    AASDKAdswizzAdRequest *adRequest = [[[[[AASDKAdswizzAdRequestBuilder new] withServer:@"demo.deliveryengine.adswizz.com"] withZone:adZone] withCompanionZoneIds:@[@17863]] buildAndReturnError:&error];
    if (error) {
        NSLog(@"Oops, the request is not valid");
        return;
    }
    
    // Cancel current connection if any
    [self.adConnection cancel];
    
    // Create and trigger a connection
    self.adConnection = [[AASDKAdRequestConnection alloc] initFor:adRequest error:&error];
    if (error) {
        NSLog(@"Oops, the connection is not valid");
        return;
    }
    
    [self.adConnection requestAdsWithCompletion:^(id<AASDKAdManager> _Nullable manager, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Ad request connection failed to retrieve ads with error = %@", error);
        } else {
            // Keep a strong ref to adManager
            self.adManager = manager;
            manager.delegate = self;
            
            if (self.externalPlayerSwitch.isOn) {
                AASDKAdManagerSettings* settings = [[AASDKAdManagerSettings alloc] init];
                settings.player = self.externalPlayer;
                manager.adManagerSettings = settings;
            }
            // Prepare
            [manager prepare];
        }
        self.adConnection = nil;
    }];
}

- (IBAction)skipAds {
    [self.adManager skipAd];
}

#pragma mark - Content playback

- (void)playContent {
    if (!self.isPlaying) {
        self.isPlaying = YES;
        [self.audioPlayer play];
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(updateTime)
                                                    userInfo:nil
                                                     repeats: YES];
        self.statusLabel.alpha = 0.0;
        self.statusLabel.text = @"Playing content...";
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat
                         animations:^{
                             self.statusLabel.alpha = 1.0;
                         } completion:^(BOOL finished) {}];
    }

}

- (void)pauseContent {
    if (self.isPlaying) {
        self.isPlaying = NO;
        [self.audioPlayer pause];
        self.statusLabel.text = @"Content paused...";
        [self.statusLabel.layer removeAllAnimations];
        [UIView animateWithDuration:0.0
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             self.statusLabel.alpha = 1.0;
                         } completion:^(BOOL finished) {}];
    }
}

- (void)updateTime {
    NSInteger currentTime = self.audioPlayer.currentTime;
    NSInteger minutes = currentTime/60;
    NSInteger seconds = currentTime - minutes * 60;
    
    self.playedTimeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
}

#pragma mark - AASDKAdManager

- (void)adManager:(id<AASDKAdManager> _Nonnull)adManager didReceiveAd:(id<AASDKAdData> _Nullable)ad error:(NSError * _Nonnull)error {
    NSLog(@"ad manager: %@ -- received ad: %@", adManager, ad.id);
}

- (void)adManager:(id<AASDKAdManager> _Nonnull)adManager didReceiveAdEvent:(id<AASDKAdEvent> _Nonnull)event {
    NSLog(@"ad manager: %@ -- triggered ad event: %@", adManager, event.stringEvent);
    
    switch (event.event) {
        case AASDKAdEventTypePreparingForPlay:
        {
            if (self.externalPlayerSwitch.isOn) {
                [self.externalPlayerSwitch setUserInteractionEnabled: NO];
                [self pauseContent];
                NSURL* url = [[NSURL alloc] initWithString: event.ad.asset.mediaUrl];
                if (url != NULL) {
                    [self.externalPlayer play: url];
                }
            }
        }
        break;
            
        case AASDKAdEventTypeReadyForPlay:
        {
            if (self.externalPlayerSwitch.isOn) {
                return;
            }
            [self.externalPlayerSwitch setUserInteractionEnabled: NO];
            // Ad manager finished loading ad(s)
            // Before playing the ads you should pause your own content
            [self pauseContent];
            
            // Start playing ad(s)
            [self.adManager play];
            break;
        }
        case AASDKAdEventTypeDidStartPlaying:
        {
            break;
        }
        case AASDKAdEventTypeDidFinishPlaying:
        case AASDKAdEventTypeAdCompleted:
        case AASDKAdEventTypeAllAdsCompleted:
        {
            // Ad manager just finished playing (all) ad(s)
            // Resume content
            [self playContent];
            
            // Cleanup
            self.adManager = nil;
            [self.externalPlayer stop];
            [self.externalPlayerSwitch setUserInteractionEnabled: YES];
            break;
        }
        default:
            break;
    }
}

#pragma mark - AASDKAdCompanionViewDelegate

- (void)adCompanionViewWillLoad:(AASDKAdCompanionView * _Nonnull)adCompanionView {
    NSLog(@"Received companion event: willLoadAd");
}

- (void)adCompanionViewDidDisplay:(AASDKAdCompanionView * _Nonnull)adCompanionView {
    NSLog(@"Received companion event: didDisplayAd");
}

- (void)adCompanionView:(AASDKAdCompanionView * _Nonnull)adCompanionView didFailToDisplay:(NSError * _Nonnull)error {
    NSLog(@"Received companion event: didFailToDisplayAd");
}

- (void)adCompanionViewDidEndDisplay:(AASDKAdCompanionView * _Nonnull)adCompanionView {
    NSLog(@"Received companion event: didEndDisplay");
}

- (BOOL)adCompanionView:(AASDKAdCompanionView * _Nonnull)adCompanionView shouldOverrideCompanionClickThrough:(NSURL * _Nonnull)url {
    // Return true if you want to handle the click through URL yourself
    // e.g open it up with in-app Safari web view
    // By default it returns false which signals the SDK to handle it internally
    // As a result it will exit the app and open the URL in default Safari app
    return NO;
}

- (void)adCompanionViewWillLeaveApplication:(AASDKAdCompanionView * _Nonnull)adCompanionView {
    NSLog(@"Received companion event: willLeaveApp");
}

@end
