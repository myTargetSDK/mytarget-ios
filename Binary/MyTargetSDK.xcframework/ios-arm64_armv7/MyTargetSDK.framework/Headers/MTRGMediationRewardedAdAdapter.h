//
//  MTRGMediationRewardedAdAdapter.h
//  myTargetSDK 5.11.0
//
//  Created by Andrey Seredkin on 13.08.2020.
//  Copyright © 2020 Mail.ru Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MyTargetSDK/MTRGMediationAdapter.h>

@class MTRGReward;
@class MTRGMediationAdConfig;
@protocol MTRGMediationRewardedAdAdapter;

NS_ASSUME_NONNULL_BEGIN

@protocol MTRGMediationRewardedAdDelegate <NSObject>

- (void)onLoadWithAdapter:(id <MTRGMediationRewardedAdAdapter>)adapter;

- (void)onNoAdWithReason:(NSString *)reason adapter:(id <MTRGMediationRewardedAdAdapter>)adapter;

- (void)onClickWithAdapter:(id <MTRGMediationRewardedAdAdapter>)adapter;

- (void)onCloseWithAdapter:(id <MTRGMediationRewardedAdAdapter>)adapter;

- (void)onReward:(MTRGReward *)reward adapter:(id <MTRGMediationRewardedAdAdapter>)adapter;

- (void)onDisplayWithAdapter:(id <MTRGMediationRewardedAdAdapter>)adapter;

- (void)onLeaveApplicationWithAdapter:(id <MTRGMediationRewardedAdAdapter>)adapter;

@end

@protocol MTRGMediationRewardedAdAdapter <MTRGMediationAdapter>

@property(nonatomic, weak, nullable) id <MTRGMediationRewardedAdDelegate> delegate;

- (void)loadWithMediationAdConfig:(MTRGMediationAdConfig *)mediationAdConfig;

- (void)showWithController:(UIViewController *)controller;

- (void)close;

@end

NS_ASSUME_NONNULL_END
