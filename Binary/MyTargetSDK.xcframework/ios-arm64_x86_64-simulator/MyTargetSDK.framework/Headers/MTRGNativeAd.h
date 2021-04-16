//
//  MTRGNativeAd.h
//  myTargetSDK 5.11.0
//
// Created by Timur on 2/1/18.
// Copyright (c) 2018 Mail.Ru Group. All rights reserved.
//

#import <MyTargetSDK/MTRGBaseAd.h>
#import <MyTargetSDK/MTRGNativeAdProtocol.h>

@class MTRGNativeAd;
@class MTRGNativePromoBanner;
@class MTRGImageData;

NS_ASSUME_NONNULL_BEGIN

@protocol MTRGNativeAdDelegate <NSObject>

- (void)onLoadWithNativePromoBanner:(MTRGNativePromoBanner *)promoBanner nativeAd:(MTRGNativeAd *)nativeAd;

- (void)onNoAdWithReason:(NSString *)reason nativeAd:(MTRGNativeAd *)nativeAd;

@optional

- (void)onAdShowWithNativeAd:(MTRGNativeAd *)nativeAd;

- (void)onAdClickWithNativeAd:(MTRGNativeAd *)nativeAd;

- (void)onShowModalWithNativeAd:(MTRGNativeAd *)nativeAd;

- (void)onDismissModalWithNativeAd:(MTRGNativeAd *)nativeAd;

- (void)onLeaveApplicationWithNativeAd:(MTRGNativeAd *)nativeAd;

- (void)onVideoPlayWithNativeAd:(MTRGNativeAd *)nativeAd;

- (void)onVideoPauseWithNativeAd:(MTRGNativeAd *)nativeAd;

- (void)onVideoCompleteWithNativeAd:(MTRGNativeAd *)nativeAd;

@end

@protocol MTRGNativeAdMediaDelegate <NSObject>

- (void)onIconLoadWithNativeAd:(MTRGNativeAd *)nativeAd;

- (void)onImageLoadWithNativeAd:(MTRGNativeAd *)nativeAd;

@end

@interface MTRGNativeAd : MTRGBaseAd <MTRGNativeAdProtocol>

@property(nonatomic) MTRGAdChoicesPlacement adChoicesPlacement;
@property(nonatomic, weak, nullable) id <MTRGNativeAdDelegate> delegate;
@property(nonatomic, weak, nullable) id <MTRGNativeAdMediaDelegate> mediaDelegate;
@property(nonatomic, readonly, nullable) MTRGNativePromoBanner *banner;

+ (instancetype)nativeAdWithSlotId:(NSUInteger)slotId;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithSlotId:(NSUInteger)slotId;

- (void)load;

- (void)loadFromBid:(NSString *)bidId;

- (void)registerView:(UIView *)containerView withController:(UIViewController *)controller;

- (void)registerView:(UIView *)containerView withController:(UIViewController *)controller withClickableViews:(nullable NSArray<UIView *> *)clickableViews;

- (void)unregisterView;

@end

NS_ASSUME_NONNULL_END
