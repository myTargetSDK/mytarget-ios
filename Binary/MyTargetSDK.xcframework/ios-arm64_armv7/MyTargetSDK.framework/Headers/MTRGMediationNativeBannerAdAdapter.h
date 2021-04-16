//
//  MTRGMediationNativeBannerAdAdapter.h
//  myTargetSDK 5.11.0
//
//  Created by Andrey Seredkin on 11/06/2020.
//  Copyright © 2020 Mail.ru Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MyTargetSDK/MTRGMediationAdapter.h>
#import <MyTargetSDK/MTRGAdChoicesPlacement.h>

@class MTRGNativeBanner;
@class MTRGMediationNativeBannerAdConfig;
@protocol MTRGMediationNativeBannerAdAdapter;

NS_ASSUME_NONNULL_BEGIN

@protocol MTRGMediationNativeBannerAdDelegate <NSObject>

- (void)onLoadWithNativeBanner:(MTRGNativeBanner *)banner adapter:(id <MTRGMediationNativeBannerAdAdapter>)adapter;

- (void)onNoAdWithReason:(NSString *)reason adapter:(id <MTRGMediationNativeBannerAdAdapter>)adapter;

- (void)onAdShowWithAdapter:(id <MTRGMediationNativeBannerAdAdapter>)adapter;

- (void)onAdClickWithAdapter:(id <MTRGMediationNativeBannerAdAdapter>)adapter;

- (void)onShowModalWithAdapter:(id <MTRGMediationNativeBannerAdAdapter>)adapter;

- (void)onDismissModalWithAdapter:(id <MTRGMediationNativeBannerAdAdapter>)adapter;

- (void)onLeaveApplicationWithAdapter:(id <MTRGMediationNativeBannerAdAdapter>)adapter;

@end

@protocol MTRGMediationNativeBannerAdAdapter <MTRGMediationAdapter>

@property(nonatomic, weak, nullable) id <MTRGMediationNativeBannerAdDelegate> delegate;

- (void)loadWithMediationAdConfig:(MTRGMediationNativeBannerAdConfig *)mediationAdConfig;

- (void)registerView:(UIView *)containerView
	  withController:(UIViewController *)controller
  withClickableViews:(nullable NSArray<UIView *> *)clickableViews
  adChoicesPlacement:(MTRGAdChoicesPlacement)adChoicesPlacement;

- (void)unregisterView;

- (nullable UIView *)iconView;

@end

NS_ASSUME_NONNULL_END
