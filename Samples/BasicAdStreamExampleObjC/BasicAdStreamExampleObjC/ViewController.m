//
//  ViewController.m
//  BasicAdStreamExampleObjC
//
//  Created by Teodor Cristea on 17/09/2019.
//  Copyright © 2020 Inc, AdsWizz. All rights reserved.
//

#import "ViewController.h"
#import "Model.h"
#import <AVFoundation/AVFoundation.h>

// Private interface
@interface ViewController () <AASDKAdCompanionViewDelegate, ModelAdBreakDelegate, ModelStreamingDelegate>

// Model
@property (nonatomic, strong) Model *model;

// Views
@property (nonatomic, strong) UIStackView *horizontalStackView;
@property (nonatomic, strong) UIStackView *verticalStackView;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UILabel *companionViewLabel;
@property (nonatomic, strong) UIButton *playStopButton;
@property (nonatomic, strong) UIButton *pauseResumeButton;
@property (nonatomic, strong) UIButton *skipAdButton;
@property (nonatomic, strong) AASDKAdCompanionView *companionView;

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
    self.title = @"Ad streaming";
    
    self.model = [Model new];
    self.model.adBreakDelegate = self;
    self.model.streamDelegate = self;

    // Stack views
    self.verticalStackView = [UIStackView new];
    self.verticalStackView.translatesAutoresizingMaskIntoConstraints = NO;
    self.verticalStackView.axis = UILayoutConstraintAxisVertical;
    self.verticalStackView.alignment = UIStackViewAlignmentFill;
    self.verticalStackView.distribution = UIStackViewDistributionFill;
    self.verticalStackView.spacing = UIStackViewSpacingUseSystem;
    
    self.horizontalStackView = [UIStackView new];
    self.horizontalStackView.translatesAutoresizingMaskIntoConstraints = NO;
    self.horizontalStackView.axis = UILayoutConstraintAxisHorizontal;
    self.horizontalStackView.alignment = UIStackViewAlignmentFill;
    self.horizontalStackView.distribution = UIStackViewDistributionFillEqually;
    self.horizontalStackView.spacing = UIStackViewSpacingUseSystem;

    // Action buttons
    self.playStopButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.playStopButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.playStopButton.backgroundColor = [UIColor clearColor];
    self.playStopButton.titleLabel.adjustsFontForContentSizeCategory = YES;
    self.playStopButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.playStopButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.playStopButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [self.playStopButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.playStopButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.playStopButton setTitle:@"Play stream" forState:UIControlStateNormal];
    [self.playStopButton setTitle:@"Stop stream" forState:UIControlStateSelected];
    [self.playStopButton addTarget:self action:@selector(playStopStream:) forControlEvents:UIControlEventTouchUpInside];
    
    self.pauseResumeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.pauseResumeButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.pauseResumeButton.backgroundColor = [UIColor clearColor];
    self.pauseResumeButton.titleLabel.adjustsFontForContentSizeCategory = YES;
    self.pauseResumeButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.pauseResumeButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.pauseResumeButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [self.pauseResumeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.pauseResumeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.pauseResumeButton setTitle:@"Pause stream" forState:UIControlStateNormal];
    [self.pauseResumeButton setTitle:@"Resume stream" forState:UIControlStateSelected];
    [self.pauseResumeButton addTarget:self action:@selector(pauseResumeStream:) forControlEvents:UIControlEventTouchUpInside];
    
    self.skipAdButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.skipAdButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.skipAdButton.backgroundColor = [UIColor clearColor];
    self.skipAdButton.titleLabel.adjustsFontForContentSizeCategory = YES;
    self.skipAdButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.skipAdButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.skipAdButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [self.skipAdButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.skipAdButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.skipAdButton setTitle:@"Skip ad" forState:UIControlStateNormal];
    [self.skipAdButton setTitle:@"Skip ad" forState:UIControlStateSelected];
    self.skipAdButton.selected = YES;
    self.skipAdButton.hidden = YES;
    [self.skipAdButton addTarget:self action:@selector(skipAd:) forControlEvents:UIControlEventTouchUpInside];

    // Status
    self.statusLabel = [UILabel new];
    self.statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.statusLabel.backgroundColor = [UIColor clearColor];
    self.statusLabel.font = [UIFont systemFontOfSize:18.0];
    self.statusLabel.textColor = [UIColor blackColor];
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.adjustsFontForContentSizeCategory = YES;
    self.statusLabel.adjustsFontSizeToFitWidth = YES;
    self.statusLabel.text = @"Tap 'Play stream' to start...";

    // Companion view label
    self.companionViewLabel = [UILabel new];
    self.companionViewLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.companionViewLabel.backgroundColor = [UIColor clearColor];
    self.companionViewLabel.font = [UIFont systemFontOfSize:12.0];
    self.companionViewLabel.textColor = [UIColor blackColor];
    self.companionViewLabel.textAlignment = NSTextAlignmentCenter;
    self.companionViewLabel.adjustsFontForContentSizeCategory = YES;
    self.companionViewLabel.adjustsFontSizeToFitWidth = YES;
    self.companionViewLabel.text = @"Ad companion view";
    
    // Companion ad view
    self.companionView = [AASDKAdCompanionView new];
    self.companionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.companionView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.1];
    self.companionView.delegate = self;
    
    
    // Arrange buttons
    [self.horizontalStackView addArrangedSubview:self.playStopButton];
    [self.horizontalStackView addArrangedSubview:self.skipAdButton];
    [self.horizontalStackView addArrangedSubview:self.pauseResumeButton];
    
    // Arrange all content
    [self.verticalStackView addArrangedSubview:self.statusLabel];
    [self.verticalStackView addArrangedSubview:self.companionView];
    [self.verticalStackView addArrangedSubview:self.horizontalStackView];

    [self.view addSubview:self.companionViewLabel];
    [self.view addSubview:self.verticalStackView];
    
    // Set constraints
    [NSLayoutConstraint activateConstraints:@[
        [self.companionViewLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.companionViewLabel.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [self.companionView.heightAnchor constraintEqualToAnchor:self.companionView.widthAnchor],
        [self.verticalStackView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.verticalStackView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.verticalStackView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor]
    ]];    
}

#pragma mark - Actions

- (void)playStopStream:(UIButton *)button {
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

- (void)pauseResumeStream:(UIButton *)button {
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

- (void)skipAd:(UIButton *)button {
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
