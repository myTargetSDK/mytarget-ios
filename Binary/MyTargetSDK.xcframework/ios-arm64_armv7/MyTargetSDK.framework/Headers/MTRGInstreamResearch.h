//
//  MTRGInstreamResearch.h
//  myTargetSDK 5.11.0
//
//  Created by Andrey Seredkin on 19/02/2019.
//  Copyright © 2019 Mail.Ru Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MyTargetSDK/MTRGBaseAd.h>

@class MTRGInstreamResearch;

NS_ASSUME_NONNULL_BEGIN

@protocol MTRGInstreamResearchDelegate <NSObject>

- (void)onLoadWithInstreamResearch:(MTRGInstreamResearch *)instreamResearch;

- (void)onNoDataWithReason:(NSString *)reason instreamResearch:(MTRGInstreamResearch *)instreamResearch;

@end

@interface MTRGInstreamResearch : MTRGBaseAd

@property(nonatomic, weak, nullable) id <MTRGInstreamResearchDelegate> delegate;

+ (instancetype)instreamResearchWithSlotId:(NSUInteger)slotId duration:(NSTimeInterval)duration;

- (instancetype)init NS_UNAVAILABLE;

- (void)load;

- (void)registerPlayerView:(UIView *)view;

- (void)unregisterPlayerView;

- (void)trackProgress:(NSTimeInterval)progress;

- (void)trackPause;

- (void)trackResume;

- (void)trackMute:(BOOL)isMuted;

- (void)trackFullscreen:(BOOL)isFullscreen;

@end

NS_ASSUME_NONNULL_END
