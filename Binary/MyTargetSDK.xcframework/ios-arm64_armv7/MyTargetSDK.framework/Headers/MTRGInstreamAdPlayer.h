//
//  MTRGInstreamAdPlayer.h
//  myTargetSDK 5.11.0
//
//  Created by Anton Bulankin on 21.09.16.
//  Copyright © 2016 Mail.ru. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MTRGInstreamAdPlayerDelegate <NSObject>

- (void)onAdVideoStart;

- (void)onAdVideoPause;

- (void)onAdVideoResume;

- (void)onAdVideoStop;

- (void)onAdVideoErrorWithReason:(NSString *)reason;

- (void)onAdVideoComplete;

@end

@protocol MTRGInstreamAdPlayer <NSObject>

@property(nonatomic, readonly) NSTimeInterval adVideoDuration;
@property(nonatomic, readonly) NSTimeInterval adVideoTimeElapsed;
@property(nonatomic, weak, nullable) id <MTRGInstreamAdPlayerDelegate> adPlayerDelegate;
@property(nonatomic, readonly) UIView *adPlayerView;
@property(nonatomic) float volume;

- (void)playAdVideoWithUrl:(NSURL *)url;

- (void)pauseAdVideo;

- (void)resumeAdVideo;

- (void)stopAdVideo;

@end

NS_ASSUME_NONNULL_END
