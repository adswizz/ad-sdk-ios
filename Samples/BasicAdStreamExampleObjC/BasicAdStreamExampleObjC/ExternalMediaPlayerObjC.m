//
//  ExternalMediaPlayerObjC.m
//  BasicAdStreamExampleObjC
//
//  Created by Adrian Manolache on 15.07.2022.
//  Copyright © 2022 Inc, AdsWizz. All rights reserved.
//

#import "ExternalMediaPlayerObjC.h"

@interface ExternalMediaPlayerObjC () <AVPlayerItemMetadataOutputPushDelegate>
@property (nonatomic, strong) id timeObserverToken;
@property (nonatomic, strong) AVPlayerItemMetadataOutput *metadataOutput;
@end

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

- (void) dealloc {
    [self stopPlayheadObserver];
}

- (void) play: (NSURL*) url {
    self.receivedPlayerDidFinishPlaying = NO;
    AVPlayerItem* item = [[AVPlayerItem alloc] initWithURL: url];
    [self.avPlayer replaceCurrentItemWithPlayerItem: item];
    [self startObserving];
    [self startPlayheadObserver];
    [self.avPlayer play];
    [self newStatus: AASDKMediaPlayerStatusPlaying];
}

- (void) stop {
    self.receivedPlayerDidFinishPlaying = true;
    [self newStatus: AASDKMediaPlayerStatusFinished];
    [self.avPlayer pause];
    [self stopPlayheadObserver];
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
    [self detachMetadataOutputFrom:self.avPlayer.currentItem];
    if (self.observingCurrentItem) {
        [self.avPlayer removeObserver:self forKeyPath:@"currentItem"];
    }
    self.observingCurrentItem = false;
}

- (void) currentItemChanged: (AVPlayerItem*) oldItem andNewItem: (AVPlayerItem*) newItem {
    [self detachMetadataOutputFrom:oldItem];
    [newItem addObserver:self forKeyPath: @"status" options: NSKeyValueObservingOptionNew context: NULL];
    [self attachMetadataOutputTo:newItem];

    if (newItem == nil) {
        if (oldItem.status != AVPlayerItemStatusFailed) {
            [self newStatus: AASDKMediaPlayerStatusInitialized];
        }
    }
}

- (void) newStatus: (AASDKMediaPlayerStatus) newStatus {
    if (newStatus != self.playerStatus) {
        // Fire KVO manually so AdswizzSDK is notified the status changed.
        [self willChangeValueForKey:@"playerStatus"];
        _playerStatus = newStatus;
        [self didChangeValueForKey:@"playerStatus"];
    }
}

- (NSTimeInterval) currentDuration {
    AVPlayerItem *item = self.avPlayer.currentItem;
    if (item == nil) {
        return 0;
    }
    NSTimeInterval seconds = CMTimeGetSeconds(item.duration);
    return isnan(seconds) ? 0 : seconds;
}

- (NSTimeInterval) currentPlayhead {
    AVPlayerItem *item = self.avPlayer.currentItem;
    if (item == nil) {
        return 0;
    }
    NSTimeInterval time = CMTimeGetSeconds(item.currentTime);
    if (isnan(time) || time < 0) {
        return 0;
    }
    NSTimeInterval duration = self.currentDuration;
    return duration > 0 ? MIN(time, duration) : time;
}

- (void) startPlayheadObserver {
    if (self.timeObserverToken != nil) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    CMTime interval = CMTimeMakeWithSeconds(1, (int32_t)NSEC_PER_SEC);
    self.timeObserverToken = [self.avPlayer addPeriodicTimeObserverForInterval:interval
                                                                         queue:dispatch_get_main_queue()
                                                                    usingBlock:^(CMTime time) {
        // Fire KVO so the SDK re-reads currentPlayhead (must be reported ascending).
        [weakSelf willChangeValueForKey:@"currentPlayhead"];
        [weakSelf didChangeValueForKey:@"currentPlayhead"];
    }];
}

- (void) stopPlayheadObserver {
    if (self.timeObserverToken != nil) {
        [self.avPlayer removeTimeObserver:self.timeObserverToken];
        self.timeObserverToken = nil;
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
}

// AVPlayerItemMetadataOutput replaces the deprecated `AVPlayerItem.timedMetadata` KVO.
- (void) attachMetadataOutputTo:(AVPlayerItem *)item {
    if (item == nil) {
        return;
    }
    if (self.metadataOutput == nil) {
        self.metadataOutput = [[AVPlayerItemMetadataOutput alloc] init];
        [self.metadataOutput setDelegate:self queue:dispatch_get_main_queue()];
    }
    [item addOutput:self.metadataOutput];
}

- (void) detachMetadataOutputFrom:(AVPlayerItem *)item {
    if (item != nil && self.metadataOutput != nil) {
        [item removeOutput:self.metadataOutput];
    }
}

- (void)metadataOutput:(AVPlayerItemMetadataOutput *)output
didOutputTimedMetadataGroups:(NSArray<AVTimedMetadataGroup *> *)groups
   fromPlayerItemTrack:(AVPlayerItemTrack *)track {
    NSMutableArray<AVMetadataItem *> *items = [NSMutableArray array];
    for (AVTimedMetadataGroup *group in groups) {
        [items addObjectsFromArray:group.items];
    }
    if (items.count == 0) {
        return;
    }
    // Fire KVO so AdswizzSDK is notified the metadata changed.
    [self willChangeValueForKey:@"metadataItem"];
    _metadataItem = [items copy];
    [self didChangeValueForKey:@"metadataItem"];
}

@end
