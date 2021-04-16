//
//  MTRGMediationStandardAdAdapter.h
//  myTargetSDK 5.11.0
//
// Copyright (c) 2019 Mail.Ru Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MyTargetSDK/MTRGMediationAdapter.h>
#import <MyTargetSDK/MTRGAdView.h>

@protocol MTRGMediationStandardAdAdapter;
@class MTRGMediationAdConfig;

NS_ASSUME_NONNULL_BEGIN

@protocol MTRGMediationStandardAdDelegate <NSObject>

- (void)onLoadWithAdView:(UIView *)adView adapter:(id <MTRGMediationStandardAdAdapter>)adapter;

- (void)onNoAdWithReason:(NSString *)reason adapter:(id <MTRGMediationStandardAdAdapter>)adapter;

- (void)onAdClickWithAdapter:(id <MTRGMediationStandardAdAdapter>)adapter;

- (void)onAdShowWithAdapter:(id <MTRGMediationStandardAdAdapter>)adapter;

- (void)onShowModalWithAdapter:(id <MTRGMediationStandardAdAdapter>)adapter;

- (void)onDismissModalWithAdapter:(id <MTRGMediationStandardAdAdapter>)adapter;

- (void)onLeaveApplicationWithAdapter:(id <MTRGMediationStandardAdAdapter>)adapter;

@end

@protocol MTRGMediationStandardAdAdapter <MTRGMediationAdapter>

@property(nonatomic, weak, nullable) id <MTRGMediationStandardAdDelegate> delegate;
@property(nonatomic, weak, nullable) UIViewController *viewController;

- (void)loadWithMediationAdConfig:(MTRGMediationAdConfig *)mediationAdConfig adSize:(MTRGAdSize *)adSize;

@end

NS_ASSUME_NONNULL_END
