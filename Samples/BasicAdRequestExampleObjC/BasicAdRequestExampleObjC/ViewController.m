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

// Views
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UILabel *playedTimeLabel;
@property (nonatomic, strong) AASDKAdCompanionView *companionView;

@end

@implementation ViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Request ads";
    
    // Toolbar
    self.toolbar = [UIToolbar new];
    self.toolbar.translatesAutoresizingMaskIntoConstraints = NO;
    self.toolbar.barStyle = UIBarStyleDefault;
    
    UIBarButtonItem *requestAdsItem = [[UIBarButtonItem alloc] initWithTitle:@"Request ad(s)"
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(requestAds)];
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                            target:nil
                                                                            action: nil];
    
    UIBarButtonItem *skipAdsItem = [[UIBarButtonItem alloc] initWithTitle:@"Skip ad"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(skipAds)];
    self.toolbar.items = @[requestAdsItem, spacer, skipAdsItem];

    // Status
    self.statusLabel = [UILabel new];
    self.statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.statusLabel.backgroundColor = [UIColor clearColor];
    self.statusLabel.font = [UIFont systemFontOfSize:18.0];
    self.statusLabel.textColor = [UIColor blackColor];
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.adjustsFontForContentSizeCategory = YES;
    self.statusLabel.adjustsFontSizeToFitWidth = YES;

    // Played time
    self.playedTimeLabel = [UILabel new];
    self.playedTimeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.playedTimeLabel.backgroundColor = [UIColor clearColor];
    self.playedTimeLabel.font = [UIFont systemFontOfSize:20.0];
    self.playedTimeLabel.textColor = [UIColor blackColor];
    self.playedTimeLabel.textAlignment = NSTextAlignmentCenter;
    self.playedTimeLabel.adjustsFontForContentSizeCategory = YES;
    self.playedTimeLabel.adjustsFontSizeToFitWidth = YES;
    
    // Companion ad view
    self.companionView = [AASDKAdCompanionView new];
    self.companionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.companionView.backgroundColor = [UIColor clearColor];
    self.companionView.delegate = self;
    
    [self.view addSubview:self.toolbar];
    [self.view addSubview:self.statusLabel];
    [self.view addSubview:self.playedTimeLabel];
    
    CGFloat top = [((AppDelegate *)([UIApplication sharedApplication].delegate)).window safeAreaTop];
    CGFloat bottom = [((AppDelegate *)([UIApplication sharedApplication].delegate)).window safeAreaBottom];
    NSDictionary *views = @{@"time": self.playedTimeLabel, @"status": self.statusLabel, @"bar": self.toolbar};
    NSDictionary *metrics = @{@"side": @(20.0), @"top": @(MAX(20.0, top)), @"bottom": @(bottom)};
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-side-[time]-side-|" options:0 metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-side-[status]-side-|" options:0 metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[bar]-0-|" options:0 metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-top-[time]-[status]-(>=0)-[bar]-bottom-|" options:0 metrics:metrics views:views]];
    
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

- (void)requestAds {
    NSError *error;
    AASDKAdswizzAdZone *adZone = [[[AASDKAdswizzAdZoneBuilder new] withZoneId:@"12561"] buildAndReturnError:&error];
    if (error) {
        NSLog(@"Oops, ad zone is no valid");
        return;
    }
    
    AASDKAdswizzAdRequest *adRequest = [[[[[AASDKAdswizzAdRequestBuilder new] withServer:@"demo.deliveryengine.adswizz.com"] withZone:adZone] withCompanionZones:@"12562"] buildAndReturnError:&error];
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
            
            // Prepare
            [manager prepare];
        }
        self.adConnection = nil;
    }];
}

- (void)skipAds {
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
        case AASDKAdEventTypeReadyForPlay:
        {
            // Ad manager finished loading ad(s)
            // Before playing the ads you should pause your own content
            [self pauseContent];
            
            // Start playing ad(s)
            [self.adManager play];
            break;
        }
        case AASDKAdEventTypeDidStartPlaying:
        {
            // Ad manager started playing the ad(s)
            // Show a companion ad which will automatically be synced with the ad
            [self.view addSubview:self.companionView];
            
            NSDictionary *views = @{@"view": self.companionView};
            NSDictionary *metrics = @{};
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[view]-0-|" options:0 metrics:metrics views:views]];
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0@900-[view]-0@900-|" options:0 metrics:metrics views:views]];
            
            NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:self.companionView
                                                                      attribute:NSLayoutAttributeHeight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.companionView
                                                                      attribute:NSLayoutAttributeWidth
                                                                     multiplier:1.0
                                                                       constant:0];
            NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:self.companionView
                                                                       attribute:NSLayoutAttributeCenterX
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.view
                                                                       attribute:NSLayoutAttributeCenterX
                                                                      multiplier:1.0
                                                                        constant:0];
            NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:self.companionView
                                                                       attribute:NSLayoutAttributeCenterY
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.view
                                                                       attribute:NSLayoutAttributeCenterY
                                                                      multiplier:1.0
                                                                        constant:0];
            [self.view addConstraints:@[centerX, centerY, height]];
            break;
        }
        case AASDKAdEventTypeDidFinishPlaying:
        case AASDKAdEventTypeAllAdsCompleted:
        {
            // Ad manager just finished playing (all) ad(s)
            // Resume content
            [self playContent];
            
            // Cleanup
            self.adManager = nil;
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
