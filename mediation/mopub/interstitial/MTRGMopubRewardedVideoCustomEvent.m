//
//  MTRGMopubRewardedVideoCustomEvent.m
//  MediationMopubApp
//
//  Created by Andrey Seredkin on 05.10.16.
//  Copyright (c) 2016 Mail.ru Group. All rights reserved.
//

#import <MyTargetSDK/MyTargetSDK.h>
#import "MTRGMopubRewardedVideoCustomEvent.h"
#import "MTRGMyTargetAdapterUtils.h"

#if __has_include("MoPub.h")
	#import "MPReward.h"
	#import "MPLogging.h"
	#import "MPError.h"
#endif

static NSString * const kMoPubRewardedAdapter = @"MTRGMopubRewardedVideoCustomEvent";

@interface MTRGMopubRewardedVideoCustomEvent () <MTRGRewardedAdDelegate>

@end

@implementation MTRGMopubRewardedVideoCustomEvent
{
	MTRGRewardedAd *_Nullable _rewardedAd;
	NSString *_Nullable _placementId;
	BOOL _hasAdAvailable;
}

- (BOOL)hasAdAvailable
{
	return _hasAdAvailable;
}

- (BOOL)isRewardExpected
{
	return YES;
}

- (BOOL)enableAutomaticImpressionAndClickTracking
{
	return NO;
}

- (void)handleDidPlayAd
{
	// Handle when an ad was played for this network, but under a different ad unit ID.
	// This method will only be called if your adapter has reported that an ad had successfully loaded.
	// If the adapter no longer has an ad available, report back up to the application that this ad has expired.
	if (_rewardedAd && _hasAdAvailable)
	{
		MPLogDebug(@"Rewarded ad is not available");
		return;
	}
	_hasAdAvailable = NO;
	[self delegateOnExpireWithReason:@"Rewarded ad is no longer available"];
}

- (void)handleDidInvalidateAd
{
	// Handle when the adapter itself is no longer needed.
	if (!_rewardedAd)
	{
		MPLogDebug(@"Rewarded ad is not available");
		return;
	}
	_rewardedAd.delegate = nil;
	_rewardedAd = nil;
}

- (void)requestAdWithAdapterInfo:(NSDictionary *)info adMarkup:(NSString * _Nullable)adMarkup
{
	NSUInteger slotId = [MTRGMyTargetAdapterUtils parseSlotIdFromInfo:info];
	_placementId = [NSString stringWithFormat:@"%zd", slotId];

	if (slotId == 0)
	{
		MPLogDebug(@"Failed to load, slotId not found");
		[self delegateOnNoAdWithReason:@"Failed to load, slotId not found"];
		return;
	}

	[MTRGMyTargetAdapterUtils setupConsent];

	_rewardedAd = [MTRGRewardedAd rewardedAdWithSlotId:slotId];
	_rewardedAd.delegate = self;
	
	[MTRGMyTargetAdapterUtils fillCustomParams:_rewardedAd.customParams dictionary:self.localExtras];

	MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:kMoPubRewardedAdapter dspCreativeId:nil dspName:nil], _placementId);
	if (adMarkup)
	{
		MPLogInfo(@"Loading Rewarded ad from bid");
		[_rewardedAd loadFromBid:adMarkup];
	}
	else
	{
		MPLogInfo(@"Loading Rewarded ad");
		[_rewardedAd load];
	}
}

- (void)presentAdFromViewController:(UIViewController *)viewController
{
	if (!_rewardedAd || !_hasAdAvailable)
	{
		_hasAdAvailable = NO;
		MPLogDebug(@"Rewarded ad is not available");
		[self delegateOnShowFailedWithReason:@"Failed to show Rewarded ad"];
		return;
	}

	MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:kMoPubRewardedAdapter], _placementId);
	MPLogAdEvent([MPLogEvent adWillAppearForAdapter:kMoPubRewardedAdapter], _placementId);

	[_rewardedAd showWithController:viewController];

	id <MPFullscreenAdAdapterDelegate> delegate = self.delegate;
	if (!delegate) return;
	[delegate fullscreenAdAdapterAdWillAppear:self]; // legacy since 5.17.0 but not deprecated yet and must be called
	[delegate fullscreenAdAdapterAdWillPresent:self];
	[delegate fullscreenAdAdapterDidTrackImpression:self];
}

#pragma mark - private

- (void)delegateOnNoAdWithReason:(NSString *)reason
{
	NSError *error = [NSError errorWithCode:MOPUBErrorNoNetworkData localizedDescription:reason];
	MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:kMoPubRewardedAdapter error:error], _placementId);
	id <MPFullscreenAdAdapterDelegate> delegate = self.delegate;
	if (!delegate) return;
	[delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
}

- (void)delegateOnShowFailedWithReason:(NSString *)reason
{
	NSError *error = [NSError errorWithCode:MOPUBErrorUnknown localizedDescription:reason];
	MPLogAdEvent([MPLogEvent adShowFailedForAdapter:kMoPubRewardedAdapter error:error], _placementId);
	id <MPFullscreenAdAdapterDelegate> delegate = self.delegate;
	if (!delegate) return;
	[delegate fullscreenAdAdapter:self didFailToShowAdWithError:error];
}

- (void)delegateOnExpireWithReason:(NSString *)reason
{
	NSError *error = [NSError errorWithCode:MOPUBErrorUnknown localizedDescription:reason];
	MPLogAdEvent([MPLogEvent adShowFailedForAdapter:kMoPubRewardedAdapter error:error], _placementId);
	id <MPFullscreenAdAdapterDelegate> delegate = self.delegate;
	if (!delegate) return;
	[delegate fullscreenAdAdapterDidExpire:self];
}

#pragma mark - MTRGRewardedAdDelegate

- (void)onLoadWithRewardedAd:(MTRGRewardedAd *)rewardedAd
{
	MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:kMoPubRewardedAdapter], _placementId);
	_hasAdAvailable = YES;
	id <MPFullscreenAdAdapterDelegate> delegate = self.delegate;
	if (!delegate) return;
	[delegate fullscreenAdAdapterDidLoadAd:self];
}

- (void)onNoAdWithReason:(NSString *)reason rewardedAd:(MTRGRewardedAd *)rewardedAd
{
	_hasAdAvailable = NO;
	[self delegateOnNoAdWithReason:reason];
}

- (void)onClickWithRewardedAd:(MTRGRewardedAd *)rewardedAd
{
	MPLogAdEvent([MPLogEvent adTappedForAdapter:kMoPubRewardedAdapter], _placementId);
	id <MPFullscreenAdAdapterDelegate> delegate = self.delegate;
	if (!delegate) return;
	[delegate fullscreenAdAdapterDidTrackClick:self];
	[delegate fullscreenAdAdapterDidReceiveTap:self];
}

- (void)onCloseWithRewardedAd:(MTRGRewardedAd *)rewardedAd
{
	MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:kMoPubRewardedAdapter], _placementId);
	MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:kMoPubRewardedAdapter], _placementId);
	id <MPFullscreenAdAdapterDelegate> delegate = self.delegate;
	if (!delegate) return;
	[delegate fullscreenAdAdapterAdWillDisappear:self];
	[delegate fullscreenAdAdapterAdDidDisappear:self];
	
	if ([delegate respondsToSelector:@selector(fullscreenAdAdapterAdDidDismiss:)])
	{
		// When an ad has has been dismissed.
		// Call this after the adapter has called fullscreenAdAdapterAdDidDisappear:self.
		// Introduced in v5.15.0 of the MoPub iOS SDK
		[delegate fullscreenAdAdapterAdDidDismiss:self];
	}
}

- (void)onReward:(MTRGReward *)reward rewardedAd:(MTRGRewardedAd *)rewardedAd
{
	MPReward *mpReward = MPReward.unspecifiedReward;
	MPLogAdEvent([MPLogEvent adShouldRewardUserWithReward:mpReward], _placementId);
	id <MPFullscreenAdAdapterDelegate> delegate = self.delegate;
	if (!delegate) return;
	[delegate fullscreenAdAdapter:self willRewardUser:mpReward];
}

- (void)onDisplayWithRewardedAd:(MTRGRewardedAd *)rewardedAd
{
	MPLogAdEvent([MPLogEvent adDidAppearForAdapter:kMoPubRewardedAdapter], _placementId);
	MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:kMoPubRewardedAdapter], _placementId);
	id <MPFullscreenAdAdapterDelegate> delegate = self.delegate;
	if (!delegate) return;
	[delegate fullscreenAdAdapterAdDidAppear:self]; // legacy since 5.17.0 but not deprecated yet and must be called
	[delegate fullscreenAdAdapterAdDidPresent:self];
}

- (void)onLeaveApplicationWithRewardedAd:(MTRGRewardedAd *)rewardedAd
{
	MPLogAdEvent([MPLogEvent adWillLeaveApplicationForAdapter:kMoPubRewardedAdapter], _placementId);
	id <MPFullscreenAdAdapterDelegate> delegate = self.delegate;
	if (!delegate) return;
	[delegate fullscreenAdAdapterWillLeaveApplication:self];
}

@end
