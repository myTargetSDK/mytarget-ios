//
//  MTRGMopubRewardedVideoCustomEvent.m
//  myTargetSDKMopubMediation
//
//  Created by Andrey Seredkin on 05.10.16.
//  Copyright (c) 2016 Mail.ru Group. All rights reserved.
//

#import "MTRGMopubRewardedVideoCustomEvent.h"
#import <MyTargetSDK/MyTargetSDK.h>
#import "MPRewardedVideoReward.h"

@interface MTRGMopubRewardedVideoCustomEvent () <MTRGInterstitialAdDelegate>

@end

@implementation MTRGMopubRewardedVideoCustomEvent
{
	MTRGInterstitialAd *_interstitialAd;
	BOOL _isAdAvailable;
}

#pragma mark - override MPRewardedVideoCustomEvent methods

- (void)requestRewardedVideoWithCustomEventInfo:(NSDictionary *)info
{
	_isAdAvailable = NO;
	NSUInteger slotId = [self parseSlotIdFromInfo:info];

	if (slotId > 0)
	{
		_interstitialAd = [[MTRGInterstitialAd alloc] initWithSlotId:slotId];
		_interstitialAd.delegate = self;
		[_interstitialAd.customParams setCustomParam:kMTRGCustomParamsMediationMopub forKey:kMTRGCustomParamsMediationKey];
		[_interstitialAd load];
	}
	else
	{
		NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"Options are not correct: slotId not found"};
		NSError *error = [NSError errorWithDomain:@"MyTargetMediation" code:1000 userInfo:userInfo];
		[self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
	}
}

- (BOOL)hasAdAvailable
{
	return _isAdAvailable;
}

- (void)presentRewardedVideoFromViewController:(UIViewController *)viewController
{
	[self.delegate rewardedVideoWillAppearForCustomEvent:self];
	[_interstitialAd showWithController:viewController];
}

- (BOOL)enableAutomaticImpressionAndClickTracking
{
	return NO;
}


#pragma mark - MTRGInterstitialAdDelegate

- (void)onLoadWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd
{
	_isAdAvailable = YES;
	[self.delegate rewardedVideoDidLoadAdForCustomEvent:self];
}

- (void)onNoAdWithReason:(NSString *)reason interstitialAd:(MTRGInterstitialAd *)interstitialAd
{
	NSString *errorTitle = reason ? [NSString stringWithFormat:@"No ad: %@", reason] : @"No ad";
	NSDictionary *userInfo = @{NSLocalizedDescriptionKey : errorTitle};
	NSError *error = [NSError errorWithDomain:@"MyTargetMediation" code:1001 userInfo:userInfo];
	[self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
}

- (void)onClickWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd
{
	[self.delegate trackClick];
}

- (void)onCloseWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd
{
	[self.delegate rewardedVideoDidDisappearForCustomEvent:self];
}

- (void)onVideoCompleteWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd
{
	MPRewardedVideoReward *rewardAmount = [[MPRewardedVideoReward alloc] initWithCurrencyType:kMPRewardedVideoRewardCurrencyTypeUnspecified
																					   amount:[NSNumber numberWithInteger:kMPRewardedVideoRewardCurrencyAmountUnspecified]];
	[self.delegate rewardedVideoShouldRewardUserForCustomEvent:self reward:rewardAmount];
}

- (void)onDisplayWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd
{
	[self.delegate rewardedVideoDidAppearForCustomEvent:self];
	[self.delegate trackImpression];
}

- (void)onLeaveApplicationWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd
{
	[self.delegate rewardedVideoWillLeaveApplicationForCustomEvent:self];
}

#pragma mark - helpers

- (NSUInteger)parseSlotIdFromInfo:(NSDictionary *)info
{
	NSUInteger slotId = 0;
	if (info)
	{
		id slotIdValue = [info valueForKey:@"slotId"];

		if ([slotIdValue isKindOfClass:[NSString class]])
		{
			NSNumberFormatter *formatString = [[NSNumberFormatter alloc] init];
			NSNumber *slotIdNum = [formatString numberFromString:slotIdValue];
			slotId = slotIdNum ? [slotIdNum unsignedIntegerValue] : 0;
		}
		else if ([slotIdValue isKindOfClass:[NSNumber class]])
		{
			slotId = [((NSNumber *) slotIdValue) unsignedIntegerValue];
		}
	}
	return slotId;
}

@end
