//
//  MTRGInstreamAd.h
//  myTargetSDK 5.11.0
//
// Created by Timur on 5/4/18.
// Copyright (c) 2018 Mail.Ru Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MyTargetSDK/MTRGBaseAd.h>

@protocol MTRGInstreamAdPlayer;
@class MTRGInstreamAd;
@class AVPlayer;

NS_ASSUME_NONNULL_BEGIN

@interface MTRGInstreamAdBanner : NSObject

@property(nonatomic, readonly) NSTimeInterval duration;
@property(nonatomic, readonly) BOOL allowPause;
@property(nonatomic, readonly) BOOL allowClose;
@property(nonatomic, readonly) NSTimeInterval allowCloseDelay;
@property(nonatomic, readonly) CGSize size;
@property(nonatomic, readonly, copy, nullable) NSString *ctaText;
@property(nonatomic, readonly) NSString *bannerId;

- (instancetype)init NS_UNAVAILABLE;

@end

@protocol MTRGInstreamAdDelegate <NSObject>

- (void)onLoadWithInstreamAd:(MTRGInstreamAd *)instreamAd;

- (void)onNoAdWithReason:(NSString *)reason instreamAd:(MTRGInstreamAd *)instreamAd;

@optional

- (void)onErrorWithReason:(NSString *)reason instreamAd:(MTRGInstreamAd *)instreamAd;

- (void)onBannerStart:(MTRGInstreamAdBanner *)banner instreamAd:(MTRGInstreamAd *)instreamAd;

- (void)onBannerComplete:(MTRGInstreamAdBanner *)banner instreamAd:(MTRGInstreamAd *)instreamAd;

- (void)onBannerTimeLeftChange:(NSTimeInterval)timeLeft duration:(NSTimeInterval)duration instreamAd:(MTRGInstreamAd *)instreamAd;

- (void)onCompleteWithSection:(NSString *)section instreamAd:(MTRGInstreamAd *)instreamAd;

- (void)onShowModalWithInstreamAd:(MTRGInstreamAd *)instreamAd;

- (void)onDismissModalWithInstreamAd:(MTRGInstreamAd *)instreamAd;

- (void)onLeaveApplicationWithInstreamAd:(MTRGInstreamAd *)instreamAd;

@end

@interface MTRGInstreamAd : MTRGBaseAd

@property(nonatomic, weak, nullable) id <MTRGInstreamAdDelegate> delegate;
@property(nonatomic, nullable) id <MTRGInstreamAdPlayer> player;
@property(nonatomic, readonly, copy) NSArray<NSNumber *> *midpoints;
@property(nonatomic, readonly) NSArray<NSString *> *videoSectionNames;
@property(nonatomic, readonly, nullable) AVPlayer *avPlayer;
@property(nonatomic) NSUInteger videoQuality;
@property(nonatomic) NSUInteger loadingTimeout;
@property(nonatomic) BOOL fullscreen;
@property(nonatomic) float volume;

+ (instancetype)instreamAdWithSlotId:(NSUInteger)slotId;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithSlotId:(NSUInteger)slotId;

- (void)load;

- (void)pause;

- (void)resume;

- (void)stop;

- (void)skip;

- (void)skipBanner;

- (void)handleClickWithController:(UIViewController *)controller;

- (void)startPreroll;

- (void)startPostroll;

- (void)startPauseroll;

- (void)startMidrollWithPoint:(NSNumber *)point;

- (void)useDefaultPlayer;

- (void)configureMidpointsP:(nullable NSArray<NSNumber *> *)midpointsP forVideoDuration:(NSTimeInterval)videoDuration;

- (void)configureMidpoints:(nullable NSArray<NSNumber *> *)midpoints forVideoDuration:(NSTimeInterval)videoDuration;

- (void)configureMidpointsForVideoDuration:(NSTimeInterval)videoDuration;

@end

NS_ASSUME_NONNULL_END
