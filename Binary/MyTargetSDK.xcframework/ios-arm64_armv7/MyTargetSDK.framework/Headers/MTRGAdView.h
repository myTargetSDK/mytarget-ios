//
//  MTRGAdView.h
//  myTargetSDK 5.11.0
//
// Created by Timur on 3/22/18.
// Copyright (c) 2018 Mail.Ru Group. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MTRGAdView;
@class MTRGAdSize;
@class MTRGCustomParams;

NS_ASSUME_NONNULL_BEGIN

@protocol MTRGAdViewDelegate <NSObject>

- (void)onLoadWithAdView:(MTRGAdView *)adView;

- (void)onNoAdWithReason:(NSString *)reason adView:(MTRGAdView *)adView;

@optional

- (void)onAdClickWithAdView:(MTRGAdView *)adView;

- (void)onAdShowWithAdView:(MTRGAdView *)adView;

- (void)onShowModalWithAdView:(MTRGAdView *)adView;

- (void)onDismissModalWithAdView:(MTRGAdView *)adView;

- (void)onLeaveApplicationWithAdView:(MTRGAdView *)adView;

@end

@interface MTRGAdView : UIView

@property(nonatomic, weak, nullable) id <MTRGAdViewDelegate> delegate;
@property(nonatomic, weak, nullable) UIViewController *viewController;
@property(nonatomic, readonly) MTRGCustomParams *customParams;
@property(nonatomic) BOOL mediationEnabled;
@property(nonatomic) MTRGAdSize *adSize;
@property(nonatomic, readonly) NSUInteger slotId;
@property(nonatomic, readonly) BOOL shouldRefreshAd;
@property(nonatomic, readonly, nullable) NSString *adSource;
@property(nonatomic, readonly) float adSourcePriority;

+ (instancetype)adViewWithSlotId:(NSUInteger)slotId;

+ (instancetype)adViewWithSlotId:(NSUInteger)slotId shouldRefreshAd:(BOOL)shouldRefreshAd;

- (void)load;

- (void)loadFromBid:(NSString *)bidId;

@end

NS_ASSUME_NONNULL_END
