//
//  MTRGMediationNativeAdAdapter.h
//  myTargetSDK 5.11.0
//
// Copyright (c) 2019 Mail.Ru Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MyTargetSDK/MTRGMediationAdapter.h>
#import <MyTargetSDK/MTRGNativeAd.h>

@class MTRGMediationNativeAdConfig;
@protocol MTRGMediationNativeAdAdapter;

NS_ASSUME_NONNULL_BEGIN

@protocol MTRGMediationNativeAdDelegate <NSObject>

- (void)onLoadWithNativePromoBanner:(MTRGNativePromoBanner *)promoBanner adapter:(id <MTRGMediationNativeAdAdapter>)adapter;

- (void)onNoAdWithReason:(NSString *)reason adapter:(id <MTRGMediationNativeAdAdapter>)adapter;

- (void)onAdShowWithAdapter:(id <MTRGMediationNativeAdAdapter>)adapter;

- (void)onAdClickWithAdapter:(id <MTRGMediationNativeAdAdapter>)adapter;

- (void)onShowModalWithAdapter:(id <MTRGMediationNativeAdAdapter>)adapter;

- (void)onDismissModalWithAdapter:(id <MTRGMediationNativeAdAdapter>)adapter;

- (void)onLeaveApplicationWithAdapter:(id <MTRGMediationNativeAdAdapter>)adapter;

- (void)onVideoPlayWithAdapter:(id <MTRGMediationNativeAdAdapter>)adapter;

- (void)onVideoPauseWithAdapter:(id <MTRGMediationNativeAdAdapter>)adapter;

- (void)onVideoCompleteWithAdapter:(id <MTRGMediationNativeAdAdapter>)adapter;

@end

@protocol MTRGMediationNativeAdAdapter <MTRGMediationAdapter>

@property(nonatomic, weak, nullable) id <MTRGMediationNativeAdDelegate> delegate;

- (void)loadWithMediationAdConfig:(MTRGMediationNativeAdConfig *)mediationAdConfig;

- (void)registerView:(UIView *)containerView
	  withController:(UIViewController *)controller
  withClickableViews:(nullable NSArray<UIView *> *)clickableViews
  adChoicesPlacement:(MTRGAdChoicesPlacement)adChoicesPlacement;

- (void)unregisterView;

- (nullable UIView *)mediaView;

@end

NS_ASSUME_NONNULL_END
