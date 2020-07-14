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
	#import "MPReward.h"
	#import "MPLogging.h"
#endif

static NSString * const kMoPubRewardedAdapter = @"MTRGMopubRewardedVideoCustomEvent";

@interface MTRGMopubRewardedVideoCustomEvent () <MTRGInterstitialAdDelegate>

@end

@implementation MTRGMopubRewardedVideoCustomEvent
{
	MTRGInterstitialAd *_Nullable _interstitialAd;
	NSString *_Nullable _placementId;
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
	if (_interstitialAd && self.hasAdAvailable) return;
	self.hasAdAvailable = NO;
	[self delegateOnExpireWithReason:@"Rewarded Video is no longer available"];
}

- (void)handleDidInvalidateAd
{
	// Handle when the adapter itself is no longer needed.
	if (!_interstitialAd) return;
    _interstitialAd.delegate = nil;
	_interstitialAd = nil;
}

- (void)requestAdWithAdapterInfo:(NSDictionary *)info adMarkup:(NSString * _Nullable)adMarkup
{
	NSUInteger slotId = [MTRGMyTargetAdapterUtils parseSlotIdFromInfo:info];
	_placementId = [NSString stringWithFormat:@"%zd", slotId];

	if (slotId == 0)
	{
		[self delegateOnNoAdWithReason:@"Failed to load, slotId not found"];
		return;
	}

	[MTRGMyTargetAdapterUtils setupConsent];

	_interstitialAd = [[MTRGInterstitialAd alloc] initWithSlotId:slotId];
	_interstitialAd.delegate = self;
	
	[MTRGMyTargetAdapterUtils fillCustomParams:_interstitialAd.customParams dictionary:self.localExtras];

	MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:kMoPubRewardedAdapter dspCreativeId:nil dspName:nil], _placementId);
	if (adMarkup)
	{
        MPLogInfo(@"Loading Rewarded Video from bid");
        [_interstitialAd loadFromBid:adMarkup];
    }
	else
	{
		MPLogInfo(@"Loading Rewarded Video");
		[_interstitialAd load];
	}
}

- (void)presentAdFromViewController:(UIViewController *)viewController
{
	if (!_interstitialAd || !self.hasAdAvailable)
	{
		self.hasAdAvailable = NO;
		[self delegateOnShowFailedWithReason:@"Failed to show Rewarded Video"];
		return;
	}

	MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:kMoPubRewardedAdapter], _placementId);
	MPLogAdEvent([MPLogEvent adWillAppearForAdapter:kMoPubRewardedAdapter], _placementId);

	[_interstitialAd showWithController:viewController];

	id <MPFullscreenAdAdapterDelegate> delegate = self.delegate;
	if (!delegate) return;
	[delegate fullscreenAdAdapterAdWillAppear:self];
    [delegate fullscreenAdAdapterDidTrackImpression:self];
}

#pragma mark - private

- (void)delegateOnNoAdWithReason:(NSString *)reason
{
	NSError *error = MPNativeAdNSErrorForInvalidAdServerResponse(reason);
	MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:kMoPubRewardedAdapter error:error], _placementId);
	id <MPFullscreenAdAdapterDelegate> delegate = self.delegate;
	if (!delegate) return;
	[delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
}

- (void)delegateOnShowFailedWithReason:(NSString *)reason
{
	NSError *error = [NSError errorWithCode:MOPUBErrorAdapterInvalid localizedDescription:reason];
	MPLogAdEvent([MPLogEvent adShowFailedForAdapter:kMoPubRewardedAdapter error:error], _placementId);
	id <MPFullscreenAdAdapterDelegate> delegate = self.delegate;
	if (!delegate) return;
	[delegate fullscreenAdAdapter:self didFailToShowAdWithError:error];
}

- (void)delegateOnExpireWithReason:(NSString *)reason
{
	NSError *error = [NSError errorWithCode:MOPUBErrorAdapterInvalid localizedDescription:reason];
	MPLogAdEvent([MPLogEvent adShowFailedForAdapter:kMoPubRewardedAdapter error:error], _placementId);
	id <MPFullscreenAdAdapterDelegate> delegate = self.delegate;
	if (!delegate) return;
	[delegate fullscreenAdAdapterDidExpire:self];
}

#pragma mark - MTRGInterstitialAdDelegate

- (void)onLoadWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd
{
	MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:kMoPubRewardedAdapter], _placementId);
	self.hasAdAvailable = YES;
	id <MPFullscreenAdAdapterDelegate> delegate = self.delegate;
	if (!delegate) return;
	[delegate fullscreenAdAdapterDidLoadAd:self];
}

- (void)onNoAdWithReason:(NSString *)reason interstitialAd:(MTRGInterstitialAd *)interstitialAd
{
	self.hasAdAvailable = NO;
	[self delegateOnNoAdWithReason:reason];
}

- (void)onClickWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd
{
	MPLogAdEvent([MPLogEvent adTappedForAdapter:kMoPubRewardedAdapter], _placementId);
	id <MPFullscreenAdAdapterDelegate> delegate = self.delegate;
	if (!delegate) return;
	[delegate fullscreenAdAdapterDidTrackClick:self];
	[delegate fullscreenAdAdapterDidReceiveTap:self];
}

- (void)onCloseWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd
{
	MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:kMoPubRewardedAdapter], _placementId);
	MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:kMoPubRewardedAdapter], _placementId);
	id <MPFullscreenAdAdapterDelegate> delegate = self.delegate;
	if (!delegate) return;
	[delegate fullscreenAdAdapterAdWillDisappear:self];
	[delegate fullscreenAdAdapterAdDidDisappear:self];
}

- (void)onVideoCompleteWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd
{
	MPLogInfo(@"Rewarded Video has finished playing successfully");
	id <MPFullscreenAdAdapterDelegate> delegate = self.delegate;
	if (!delegate) return;
	[delegate fullscreenAdAdapter:self willRewardUser:MPReward.unspecifiedReward];
}

- (void)onDisplayWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd
{
	MPLogAdEvent([MPLogEvent adDidAppearForAdapter:kMoPubRewardedAdapter], _placementId);
	MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:kMoPubRewardedAdapter], _placementId);
	id <MPFullscreenAdAdapterDelegate> delegate = self.delegate;
	if (!delegate) return;
	[delegate fullscreenAdAdapterAdDidAppear:self];
}

- (void)onLeaveApplicationWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd
{
	MPLogAdEvent([MPLogEvent adWillLeaveApplicationForAdapter:kMoPubRewardedAdapter], _placementId);
	id <MPFullscreenAdAdapterDelegate> delegate = self.delegate;
	if (!delegate) return;
	[delegate fullscreenAdAdapterWillLeaveApplication:self];
}

@end
