//
//  ViewController.m
//  BasicAdStreamExampleObjC
//
//  Created by Teodor Cristea on 17/09/2019.
//  Copyright © 2020 Inc, AdsWizz. All rights reserved.
//

#import "ViewController.h"
#import "Model.h"
#import "NSBundle+Version.h"
#import <AVFoundation/AVFoundation.h>

// Private interface
@interface ViewController () <AASDKAdCompanionViewDelegate, ModelAdBreakDelegate, ModelStreamingDelegate>

// Model
@property (nonatomic, strong) Model *model;

// Views
@property (nonatomic, strong) IBOutlet UILabel *statusLabel;
@property (nonatomic, strong) IBOutlet UILabel *companionViewLabel;
@property (nonatomic, strong) IBOutlet UIButton *playStopButton;
@property (nonatomic, strong) IBOutlet UIButton *pauseResumeButton;
@property (nonatomic, strong) IBOutlet UIButton *skipAdButton;
@property (nonatomic, strong) IBOutlet UISwitch *externalPlayerToggler;
@property (nonatomic, strong) IBOutlet AASDKAdCompanionView *companionView;

@end

@implementation ViewController

#pragma mark - UIViewController

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [NSString stringWithFormat:@"%@ - AdsWizz SDK v%@", @"Ad streaming", [[NSBundle bundleForClass:[AASDKAdRequest class]] version]];
    
    self.model = [Model new];
    self.model.adBreakDelegate = self;
    self.model.streamDelegate = self;
    
    [self.playStopButton setTitle:@"Play stream" forState:UIControlStateNormal];
    [self.playStopButton setTitle:@"Stop stream" forState:UIControlStateSelected];

    [self.pauseResumeButton setTitle:@"Pause stream" forState:UIControlStateNormal];
    [self.pauseResumeButton setTitle:@"Resume stream" forState:UIControlStateSelected];

    self.skipAdButton.selected = YES;
    self.skipAdButton.hidden = YES;

    // Companion ad view
    self.companionView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.1];
    self.companionView.delegate = self;
}

#pragma mark - Actions

- (IBAction) externalPlayerSwitchChanged: (UISwitch *)mySwitch {
    self.model.isUsingExternalPlayer = mySwitch.isOn;
}

- (IBAction)playStopStream:(UIButton *)button {
    switch (self.model.state) {
        case PlayerStatePlaying:
        case PlayerStatePaused:
        {
            [self.model stop:YES];
            self.pauseResumeButton.selected = NO;
        }
            break;
        case PlayerStateStopped:
        {
            BOOL success = [self.model play];
            if (!success) {
                NSLog(@"Failed to play ad stream!");
            }
        }
            break;
        default:
            break;
    }
    button.selected = self.model.state == PlayerStatePlaying;
}

- (IBAction)pauseResumeStream:(UIButton *)button {
    if (!self.model.isReadyToPlay) {
        return;
    }
    button.selected = !button.isSelected;
    
    switch (self.model.state) {
        case PlayerStatePlaying:
        {
            [self.model pause];
        }
            break;
        case PlayerStatePaused:
        {
            [self.model resume];
        }
            break;
        default:
            break;
    }
}

- (IBAction)skipAd:(UIButton *)button {
    [self.model skipAd];
}

#pragma mark - Helpers

- (void)setStatus:(NSString *)text fading:(BOOL)enabled {
    self.statusLabel.text = text;
    if (enabled) {
        self.statusLabel.alpha = 0.0;
    } else {
        [self.statusLabel.layer removeAllAnimations];
    }
    
    [UIView animateWithDuration:enabled ? 0.5 : 0.0
                          delay:0.0
                        options: enabled ? UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat : UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.statusLabel.alpha = 1.0;
                     } completion:^(BOOL finished) {}];
}

- (void)enableSkipButton:(BOOL)enable animated:(BOOL)animated {
    if ((!self.skipAdButton.isHidden && enable) || (self.skipAdButton.isHidden && !enable)) {
        return;
    }
    
    [UIView animateWithDuration:animated ? 0.3 : 0.0 animations:^{
        self.skipAdButton.hidden = !enable;
    }];
}

#pragma mark - ModelDelegate

- (void)modelDidStartStreaming:(Model *)model {
    [self setStatus:@"Playing stream..." fading:YES];
}

- (void)modelDidStopStreaming:(Model *)model {
    [self setStatus:@"Stream stopped" fading:NO];
}

- (void)modelDidPauseStreaming:(Model *)model {
    [self setStatus:@"Stream paused" fading:NO];
}

- (void)modelDidResumeStreaming:(Model *)model {
    [self setStatus:@"Playing stream..." fading:YES];
}

- (void)modelDidStartAdBreak:(Model *)model {
    [self setStatus:@"Ad break detected! Playing ad(s)..." fading:NO];
    [self enableSkipButton:YES animated:YES];
}

- (void)modelDidEndAdBreak:(Model *)model {
    [self setStatus:@"Ad break ended!" fading:NO];
    [self enableSkipButton:NO animated:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setStatus:@"Playing stream..." fading:YES];
    });
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
