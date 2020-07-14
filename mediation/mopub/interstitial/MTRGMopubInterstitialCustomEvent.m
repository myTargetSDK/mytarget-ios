//
//  MTRGMopubInterstitialCustomEvent.m
//  myTargetSDKMopubMediation
//
//  Created by Anton Bulankin on 16.02.15.
//  Copyright (c) 2015 Mail.ru Group. All rights reserved.
//

#import <MyTargetSDK/MyTargetSDK.h>
#import "MTRGMopubInterstitialCustomEvent.h"
#import "MTRGMyTargetAdapterUtils.h"

#if __has_include("MoPub.h")
    #import "MPLogging.h"
#endif

static NSString * const kMoPubInterstitialAdapter = @"MTRGMopubInterstitialCustomEvent";

@interface MTRGMopubInterstitialCustomEvent () <MTRGInterstitialAdDelegate>

@end

@implementation MTRGMopubInterstitialCustomEvent
{
	MTRGInterstitialAd *_Nullable _interstitialAd;
	NSString *_Nullable _placementId;
}

- (BOOL)isRewardExpected
{
	return NO;
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
	[self delegateOnExpireWithReason:@"Interstitial ad is no longer available"];
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

	MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:kMoPubInterstitialAdapter dspCreativeId:nil dspName:nil], _placementId);
	if (adMarkup)
	{
        MPLogInfo(@"Loading interstitial ad from bid");
        [_interstitialAd loadFromBid:adMarkup];
    }
	else
	{
		MPLogInfo(@"Loading interstitial ad");
		[_interstitialAd load];
	}
}

- (void)presentAdFromViewController:(UIViewController *)viewController
{
	if (!_interstitialAd || !self.hasAdAvailable)
	{
		self.hasAdAvailable = NO;
		[self delegateOnShowFailedWithReason:@"Failed to show interstitial ad"];
		return;
	}

	MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:kMoPubInterstitialAdapter], _placementId);
	MPLogAdEvent([MPLogEvent adWillAppearForAdapter:kMoPubInterstitialAdapter], _placementId);

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
	MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:kMoPubInterstitialAdapter error:error], _placementId);
	id <MPFullscreenAdAdapterDelegate> delegate = self.delegate;
	if (!delegate) return;
	[delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
}

- (void)delegateOnShowFailedWithReason:(NSString *)reason
{
	NSError *error = [NSError errorWithCode:MOPUBErrorAdapterInvalid localizedDescription:reason];
	MPLogAdEvent([MPLogEvent adShowFailedForAdapter:kMoPubInterstitialAdapter error:error], _placementId);
	id <MPFullscreenAdAdapterDelegate> delegate = self.delegate;
	if (!delegate) return;
	[delegate fullscreenAdAdapter:self didFailToShowAdWithError:error];
}

- (void)delegateOnExpireWithReason:(NSString *)reason
{
	NSError *error = [NSError errorWithCode:MOPUBErrorAdapterInvalid localizedDescription:reason];
	MPLogAdEvent([MPLogEvent adShowFailedForAdapter:kMoPubInterstitialAdapter error:error], _placementId);
	id <MPFullscreenAdAdapterDelegate> delegate = self.delegate;
	if (!delegate) return;
	[delegate fullscreenAdAdapterDidExpire:self];
}

#pragma mark - MTRGInterstitialAdDelegate

- (void)onLoadWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd
{
	MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:kMoPubInterstitialAdapter], _placementId);
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
	MPLogAdEvent([MPLogEvent adTappedForAdapter:kMoPubInterstitialAdapter], _placementId);
	id <MPFullscreenAdAdapterDelegate> delegate = self.delegate;
	if (!delegate) return;
	[delegate fullscreenAdAdapterDidTrackClick:self];
	[delegate fullscreenAdAdapterDidReceiveTap:self];
}

- (void)onCloseWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd
{
	MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:kMoPubInterstitialAdapter], _placementId);
	MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:kMoPubInterstitialAdapter], _placementId);
	id <MPFullscreenAdAdapterDelegate> delegate = self.delegate;
	if (!delegate) return;
	[delegate fullscreenAdAdapterAdWillDisappear:self];
	[delegate fullscreenAdAdapterAdDidDisappear:self];
}

- (void)onVideoCompleteWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd
{
	MPLogInfo(@"Video has finished playing successfully");
}

- (void)onDisplayWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd
{
	MPLogAdEvent([MPLogEvent adDidAppearForAdapter:kMoPubInterstitialAdapter], _placementId);
	MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:kMoPubInterstitialAdapter], _placementId);
	id <MPFullscreenAdAdapterDelegate> delegate = self.delegate;
	if (!delegate) return;
	[delegate fullscreenAdAdapterAdDidAppear:self];
}

- (void)onLeaveApplicationWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd
{
	MPLogAdEvent([MPLogEvent adWillLeaveApplicationForAdapter:kMoPubInterstitialAdapter], _placementId);
	id <MPFullscreenAdAdapterDelegate> delegate = self.delegate;
	if (!delegate) return;
	[delegate fullscreenAdAdapterWillLeaveApplication:self];
}

@end
