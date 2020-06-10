//
//  MTRGMopubRewardedVideoCustomEvent.m
//  myTargetSDKMopubMediation
//
//  Created by Andrey Seredkin on 05.10.16.
//  Copyright (c) 2016 Mail.ru Group. All rights reserved.
//

#import <MyTargetSDK/MyTargetSDK.h>
#import "MTRGMopubRewardedVideoCustomEvent.h"
#import "MTRGMyTargetAdapterUtils.h"

#if __has_include("MoPub.h")
    #import "MPRewardedVideoReward.h"
#endif

@interface MTRGMopubRewardedVideoCustomEvent () <MTRGInterstitialAdDelegate>

@end

@implementation MTRGMopubRewardedVideoCustomEvent
{
	MTRGInterstitialAd *_interstitialAd;
	BOOL _hasAdAvailable;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"
- (void)requestRewardedVideoWithCustomEventInfo:(NSDictionary *)info
{
	[self requestRewardedVideoWithCustomEventInfo:info adMarkup:@""];
}
#pragma clang diagnostic pop

- (void)requestRewardedVideoWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup
{
	_hasAdAvailable = NO;
	NSUInteger slotId = [MTRGMyTargetAdapterUtils parseSlotIdFromInfo:info];
	id <MPRewardedVideoCustomEventDelegate> delegate = self.delegate;

	if (slotId > 0)
	{
		[MTRGMyTargetAdapterUtils setupConsent];
		
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

@end
