//
//  MTRGMediationInterstitialAdAdapter.h
//  myTargetSDK 5.11.0
//
// Copyright (c) 2019 Mail.Ru Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MyTargetSDK/MTRGMediationAdapter.h>

@class MTRGMediationAdConfig;
@protocol MTRGMediationInterstitialAdAdapter;

NS_ASSUME_NONNULL_BEGIN

@protocol MTRGMediationInterstitialAdDelegate <NSObject>

- (void)onLoadWithAdapter:(id <MTRGMediationInterstitialAdAdapter>)adapter;

- (void)onNoAdWithReason:(NSString *)reason adapter:(id <MTRGMediationInterstitialAdAdapter>)adapter;

- (void)onClickWithAdapter:(id <MTRGMediationInterstitialAdAdapter>)adapter;

- (void)onCloseWithAdapter:(id <MTRGMediationInterstitialAdAdapter>)adapter;

- (void)onVideoCompleteWithAdapter:(id <MTRGMediationInterstitialAdAdapter>)adapter;

- (void)onDisplayWithAdapter:(id <MTRGMediationInterstitialAdAdapter>)adapter;

- (void)onLeaveApplicationWithAdapter:(id <MTRGMediationInterstitialAdAdapter>)adapter;

@end

@protocol MTRGMediationInterstitialAdAdapter <MTRGMediationAdapter>

@property(nonatomic, weak, nullable) id <MTRGMediationInterstitialAdDelegate> delegate;

- (void)loadWithMediationAdConfig:(MTRGMediationAdConfig *)mediationAdConfig;

- (void)showWithController:(UIViewController *)controller;

- (void)close;

@end

NS_ASSUME_NONNULL_END
