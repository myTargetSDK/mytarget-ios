//
//  MTRGInterstitialAd.h
//  myTargetSDK 5.11.0
//
// Created by Timur on 3/5/18.
// Copyright (c) 2018 MailRu Group. All rights reserved.
//

#import <MyTargetSDK/MTRGBaseInterstitialAd.h>

@class MTRGInterstitialAd;

NS_ASSUME_NONNULL_BEGIN

@protocol MTRGInterstitialAdDelegate <NSObject>

- (void)onLoadWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd;

- (void)onNoAdWithReason:(NSString *)reason interstitialAd:(MTRGInterstitialAd *)interstitialAd;

@optional

- (void)onClickWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd;

- (void)onCloseWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd;

- (void)onVideoCompleteWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd;

- (void)onDisplayWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd;

- (void)onLeaveApplicationWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd;

@end

@interface MTRGInterstitialAd : MTRGBaseInterstitialAd

@property(nonatomic, weak, nullable) id <MTRGInterstitialAdDelegate> delegate;

+ (instancetype)interstitialAdWithSlotId:(NSUInteger)slotId;

- (instancetype)initWithSlotId:(NSUInteger)slotId;

@end

NS_ASSUME_NONNULL_END
