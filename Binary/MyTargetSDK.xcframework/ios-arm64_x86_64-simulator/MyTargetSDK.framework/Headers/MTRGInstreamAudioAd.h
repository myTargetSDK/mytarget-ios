//
//  MTRGInstreamAudioAd.h
//  myTargetSDK 5.11.0
//
// Created by Timur on 5/25/18.
// Copyright (c) 2018 Mail.Ru Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MyTargetSDK/MTRGBaseAd.h>

@class MTRGInstreamAudioAd;
@class MTRGShareButtonData;
@protocol MTRGInstreamAudioAdPlayer;

NS_ASSUME_NONNULL_BEGIN

@interface MTRGInstreamAdCompanionBanner : NSObject

@property(nonatomic, readonly) NSUInteger width;
@property(nonatomic, readonly) NSUInteger height;
@property(nonatomic, readonly) NSUInteger assetWidth;
@property(nonatomic, readonly) NSUInteger assetHeight;
@property(nonatomic, readonly) NSUInteger expandedWidth;
@property(nonatomic, readonly) NSUInteger expandedHeight;

@property(nonatomic, readonly) BOOL isClickable;

@property(nonatomic, readonly, copy, nullable) NSString *staticResource;
@property(nonatomic, readonly, copy, nullable) NSString *iframeResource;
@property(nonatomic, readonly, copy, nullable) NSString *htmlResource;
@property(nonatomic, readonly, copy, nullable) NSString *apiFramework;
@property(nonatomic, readonly, copy, nullable) NSString *adSlotID;
@property(nonatomic, readonly, copy, nullable) NSString *required;

- (instancetype)init NS_UNAVAILABLE;

@end

@interface MTRGInstreamAudioAdBanner : NSObject

@property(nonatomic, readonly) NSTimeInterval duration;
@property(nonatomic, readonly) BOOL allowSeek;
@property(nonatomic, readonly) BOOL allowSkip;
@property(nonatomic, readonly) BOOL allowPause;
@property(nonatomic, readonly) BOOL allowTrackChange;
@property(nonatomic, readonly, copy, nullable) NSString *adText;
@property(nonatomic, readonly) NSArray<MTRGInstreamAdCompanionBanner *> *companionBanners;
@property(nonatomic, readonly) NSArray<MTRGShareButtonData *> *shareButtons;

- (instancetype)init NS_UNAVAILABLE;

@end

@protocol MTRGInstreamAudioAdDelegate <NSObject>

- (void)onLoadWithInstreamAudioAd:(MTRGInstreamAudioAd *)instreamAudioAd;

- (void)onNoAdWithReason:(NSString *)reason instreamAudioAd:(MTRGInstreamAudioAd *)instreamAudioAd;

@optional

- (void)onErrorWithReason:(NSString *)reason instreamAudioAd:(MTRGInstreamAudioAd *)instreamAudioAd;

- (void)onBannerStart:(MTRGInstreamAudioAdBanner *)banner instreamAudioAd:(MTRGInstreamAudioAd *)instreamAudioAd;

- (void)onBannerComplete:(MTRGInstreamAudioAdBanner *)banner instreamAudioAd:(MTRGInstreamAudioAd *)instreamAudioAd;

- (void)onBannerTimeLeftChange:(NSTimeInterval)timeLeft duration:(NSTimeInterval)duration instreamAudioAd:(MTRGInstreamAudioAd *)instreamAudioAd;

- (void)onCompleteWithSection:(NSString *)section instreamAudioAd:(MTRGInstreamAudioAd *)instreamAudioAd;

- (void)onShowModalWithInstreamAudioAd:(MTRGInstreamAudioAd *)instreamAudioAd;

- (void)onDismissModalWithInstreamAudioAd:(MTRGInstreamAudioAd *)instreamAudioAd;

- (void)onLeaveApplicationWithInstreamAudioAd:(MTRGInstreamAudioAd *)instreamAudioAd;

@end

@interface MTRGInstreamAudioAd : MTRGBaseAd

@property(nonatomic, weak, nullable) id <MTRGInstreamAudioAdDelegate> delegate;
@property(nonatomic, nullable) id <MTRGInstreamAudioAdPlayer> player;
@property(nonatomic, readonly, nullable) MTRGInstreamAudioAdBanner *currentBanner;
@property(nonatomic, readonly, copy) NSArray<NSNumber *> *midpoints;
@property(nonatomic) NSUInteger loadingTimeout;
@property(nonatomic) float volume;

+ (instancetype)instreamAudioAdWithSlotId:(NSUInteger)slotId;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithSlotId:(NSUInteger)slotId;

- (void)load;

- (void)pause;

- (void)resume;

- (void)stop;

- (void)skip;

- (void)skipBanner;

- (void)handleCompanionClick:(MTRGInstreamAdCompanionBanner *)companionBanner withController:(UIViewController *)controller;

- (void)handleCompanionShow:(MTRGInstreamAdCompanionBanner *)companionBanner;

- (void)startPreroll;

- (void)startPostroll;

- (void)startPauseroll;

- (void)startMidrollWithPoint:(NSNumber *)point;

- (void)configureMidpointsP:(nullable NSArray<NSNumber *> *)midpointsP forAudioDuration:(NSTimeInterval)audioDuration;

- (void)configureMidpoints:(nullable NSArray<NSNumber *> *)midpoints forAudioDuration:(NSTimeInterval)audioDuration;

- (void)configureMidpointsForAudioDuration:(NSTimeInterval)audioDuration;

@end

NS_ASSUME_NONNULL_END
