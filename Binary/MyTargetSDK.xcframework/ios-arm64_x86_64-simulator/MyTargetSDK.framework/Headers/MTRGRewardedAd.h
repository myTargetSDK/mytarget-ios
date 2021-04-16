//
//  MTRGRewardedAd.h
//  myTargetSDK 5.11.0
//
//  Created by Andrey Seredkin on 05.08.2020.
//  Copyright © 2020 Mail.ru Group. All rights reserved.
//

#import <MyTargetSDK/MTRGBaseInterstitialAd.h>

@class MTRGRewardedAd;
@class MTRGReward;

NS_ASSUME_NONNULL_BEGIN

@protocol MTRGRewardedAdDelegate <NSObject>

- (void)onLoadWithRewardedAd:(MTRGRewardedAd *)rewardedAd;

- (void)onNoAdWithReason:(NSString *)reason rewardedAd:(MTRGRewardedAd *)rewardedAd;

- (void)onReward:(MTRGReward *)reward rewardedAd:(MTRGRewardedAd *)rewardedAd;

@optional

- (void)onClickWithRewardedAd:(MTRGRewardedAd *)rewardedAd;

- (void)onCloseWithRewardedAd:(MTRGRewardedAd *)rewardedAd;

- (void)onDisplayWithRewardedAd:(MTRGRewardedAd *)rewardedAd;

- (void)onLeaveApplicationWithRewardedAd:(MTRGRewardedAd *)rewardedAd;

@end

@interface MTRGRewardedAd : MTRGBaseInterstitialAd

@property(nonatomic, weak, nullable) id <MTRGRewardedAdDelegate> delegate;

+ (instancetype)rewardedAdWithSlotId:(NSUInteger)slotId;

- (instancetype)initWithSlotId:(NSUInteger)slotId;

@end

NS_ASSUME_NONNULL_END
