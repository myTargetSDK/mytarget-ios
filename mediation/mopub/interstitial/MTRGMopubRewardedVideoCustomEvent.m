//
//  MTRGMopubRewardedVideoCustomEvent.m
//  myTargetSDKMopubMediation
//
//  Created by Andrey Seredkin on 05.10.16.
//  Copyright (c) 2016 Mail.ru Group. All rights reserved.
//

@import MyTargetSDK;

#import "MTRGMopubRewardedVideoCustomEvent.h"
#import <MoPubSDKFramework/MPRewardedVideoReward.h>

@interface MTRGMopubRewardedVideoCustomEvent () <MTRGInterstitialAdDelegate>

@end

@implementation MTRGMopubRewardedVideoCustomEvent
{
	MTRGInterstitialAd *_interstitialAd;
	BOOL _hasAdAvailable;
}

#pragma mark - override MPRewardedVideoCustomEvent methods

- (void)requestRewardedVideoWithCustomEventInfo:(NSDictionary *)info
{
	_hasAdAvailable = NO;
	NSUInteger slotId = [self parseSlotIdFromInfo:info];
	id <MPRewardedVideoCustomEventDelegate> delegate = self.delegate;

	if (slotId > 0)
	{
		_interstitialAd = [[MTRGInterstitialAd alloc] initWithSlotId:slotId];
		_interstitialAd.delegate = self;
		[_interstitialAd.customParams setCustomParam:kMTRGCustomParamsMediationMopub forKey:kMTRGCustomParamsMediationKey];
		[_interstitialAd load];
	}
	else if (delegate)
	{
		NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : @"Options are not correct: slotId not found" };
		NSError *error = [NSError errorWithDomain:@"MyTargetMediation" code:1000 userInfo:userInfo];
		[delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
	}
}

- (BOOL)hasAdAvailable
{
	return _hasAdAvailable;
}

- (void)presentRewardedVideoFromViewController:(UIViewController *)viewController
{
	[_interstitialAd showWithController:viewController];
	id <MPRewardedVideoCustomEventDelegate> delegate = self.delegate;
	if (!delegate) return;
	[delegate rewardedVideoWillAppearForCustomEvent:self];
}

- (BOOL)enableAutomaticImpressionAndClickTracking
{
	return NO;
}

#pragma mark - MTRGInterstitialAdDelegate

- (void)onLoadWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd
{
	_hasAdAvailable = YES;
	id <MPRewardedVideoCustomEventDelegate> delegate = self.delegate;
	if (!delegate) return;
	[delegate rewardedVideoDidLoadAdForCustomEvent:self];
}

- (void)onNoAdWithReason:(NSString *)reason interstitialAd:(MTRGInterstitialAd *)interstitialAd
{
	id <MPRewardedVideoCustomEventDelegate> delegate = self.delegate;
	if (!delegate) return;
	NSString *errorTitle = reason ? [NSString stringWithFormat:@"No ad: %@", reason] : @"No ad";
	NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : errorTitle };
	NSError *error = [NSError errorWithDomain:@"MyTargetMediation" code:1001 userInfo:userInfo];
	[delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
}

- (void)onClickWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd
{
	id <MPRewardedVideoCustomEventDelegate> delegate = self.delegate;
	if (!delegate) return;
	[delegate trackClick];
}

- (void)onCloseWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd
{
	id <MPRewardedVideoCustomEventDelegate> delegate = self.delegate;
	if (!delegate) return;
	[delegate rewardedVideoDidDisappearForCustomEvent:self];
}

- (void)onVideoCompleteWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd
{
	id <MPRewardedVideoCustomEventDelegate> delegate = self.delegate;
	if (!delegate) return;
	NSNumber *amount = [NSNumber numberWithInteger:kMPRewardedVideoRewardCurrencyAmountUnspecified];
	MPRewardedVideoReward *reward = [[MPRewardedVideoReward alloc] initWithCurrencyType:kMPRewardedVideoRewardCurrencyTypeUnspecified amount:amount];
	[delegate rewardedVideoShouldRewardUserForCustomEvent:self reward:reward];
}

- (void)onDisplayWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd
{
	id <MPRewardedVideoCustomEventDelegate> delegate = self.delegate;
	if (!delegate) return;
	[delegate rewardedVideoDidAppearForCustomEvent:self];
	[delegate trackImpression];
}

- (void)onLeaveApplicationWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd
{
	id <MPRewardedVideoCustomEventDelegate> delegate = self.delegate;
	if (!delegate) return;
	[delegate rewardedVideoWillLeaveApplicationForCustomEvent:self];
}

#pragma mark - helpers

- (NSUInteger)parseSlotIdFromInfo:(nullable NSDictionary *)info
{
	if (!info) return 0;

	id slotIdValue = [info valueForKey:@"slotId"];
	if (!slotIdValue) return 0;

	NSUInteger slotId = 0;
	if ([slotIdValue isKindOfClass:[NSString class]])
	{
		NSNumberFormatter *formatString = [[NSNumberFormatter alloc] init];
		NSNumber *slotIdNumber = [formatString numberFromString:slotIdValue];
		slotId = (slotIdNumber && slotIdNumber.integerValue > 0) ? slotIdNumber.unsignedIntegerValue : 0;
	}
	else if ([slotIdValue isKindOfClass:[NSNumber class]])
	{
		NSNumber *slotIdNumber = (NSNumber *)slotIdValue;
		slotId = (slotIdNumber && slotIdNumber.integerValue > 0) ? slotIdNumber.unsignedIntegerValue : 0;
	}
	return slotId;
}

@end
