//
//  ExternalMediaPlayerObjC.m
//  BasicAdStreamExampleObjC
//
//  Created by Adrian Manolache on 15.07.2022.
//  Copyright © 2022 Inc, AdsWizz. All rights reserved.
//

#import "ExternalMediaPlayerObjC.h"

@implementation ExternalMediaPlayerObjC

- (id) init {
    if (self = [super init]) {
        self.receivedPlayerDidFinishPlaying = false;
        self.receivedPlayerPlaying = false;
        self.observingCurrentItem = false;
        self.avPlayer = [[AVPlayer alloc] init];
    }
    return self;
}

- (void) play: (NSURL*) url {
    self.receivedPlayerDidFinishPlaying = NO;
    AVPlayerItem* item = [[AVPlayerItem alloc] initWithURL: url];
    [self.avPlayer replaceCurrentItemWithPlayerItem: item];
    [self startObserving];
    [self.avPlayer play];
    [self newStatus: AASDKMediaPlayerStatusPlaying];
}

- (void) stop {
    self.receivedPlayerDidFinishPlaying = true;
    [self newStatus: AASDKMediaPlayerStatusFinished];
    [self.avPlayer pause];
    [self stopObserving];
    [self.avPlayer replaceCurrentItemWithPlayerItem: NULL];
}

- (void) pause {
    [self newStatus: AASDKMediaPlayerStatusPaused];
    [self.avPlayer pause];
}

- (void) resume {
    [self newStatus: AASDKMediaPlayerStatusPlaying];
    [self.avPlayer play];
}

- (void) startObserving {
    if (self.observingCurrentItem) {
        return;
    }
    [self.avPlayer addObserver: self
                    forKeyPath: @"currentItem"
                       options: (NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew |
                                 NSKeyValueObservingOptionOld)
                       context: nil];
    self.observingCurrentItem = true;
}

- (void) stopObserving {
    [self.avPlayer.currentItem removeObserver:self forKeyPath:@"timedMetadata"];
    if (self.observingCurrentItem) {
        [self.avPlayer removeObserver:self forKeyPath:@"currentItem"];
    }
    self.observingCurrentItem = false;
}

- (void) currentItemChanged: (AVPlayerItem*) oldItem andNewItem: (AVPlayerItem*) newItem {
    [oldItem removeObserver:self forKeyPath: @"timedMetadata"];
    [newItem addObserver:self forKeyPath: @"status" options: NSKeyValueObservingOptionNew context: NULL];
    [newItem addObserver:self forKeyPath: @"timedMetadata" options: (NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew) context: NULL];
    
    if (newItem == nil) {
        if (oldItem.status != AVPlayerItemStatusFailed) {
            [self newStatus: AASDKMediaPlayerStatusInitialized];
        }
    }
}

- (void) newStatus: (AASDKMediaPlayerStatus) newStatus {
    if (newStatus != self.playerStatus) {
        _playerStatus = newStatus;
    }
}


- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{

    if ([keyPath isEqualToString: @"currentItem"]) {
        [self currentItemChanged:change[NSKeyValueChangeOldKey] andNewItem:change[NSKeyValueChangeNewKey]];
    }
    
    if ([keyPath isEqualToString: @"timedMetadata"]) {
        [self timedMetadataChanged];
    }
}

- (void) timedMetadataChanged {
    NSArray<AVMetadataItem *> *metadata = self.avPlayer.currentItem.timedMetadata;
    if (metadata == nil) {
        return;
    }
    _metadataItem = metadata;
}

@end
