//
//  MTRGMopubAdViewCustomEvent.m
//  MediationMopubApp
//
//  Created by Anton Bulankin on 12.03.15.
//  Copyright (c) 2015 Mail.ru Group. All rights reserved.
//

#import <MyTargetSDK/MyTargetSDK.h>
#import "MTRGMopubAdViewCustomEvent.h"
#import "MTRGMyTargetAdapterUtils.h"

#if __has_include("MoPub.h")
    #import "MPLogging.h"
	#import "MPError.h"
#endif

static NSString * const kMoPubStandardAdapter = @"MTRGMopubAdViewCustomEvent";

@interface MTRGMopubAdViewCustomEvent () <MTRGAdViewDelegate>

@end

@implementation MTRGMopubAdViewCustomEvent
{
	MTRGAdView *_Nullable _adView;
	NSString *_Nullable _placementId;
}

- (BOOL)enableAutomaticImpressionAndClickTracking
{
	return NO;
}

- (void)requestAdWithSize:(CGSize)size adapterInfo:(NSDictionary *)info adMarkup:(NSString * _Nullable)adMarkup
{
	NSUInteger slotId = [MTRGMyTargetAdapterUtils parseSlotIdFromInfo:info];
	_placementId = [NSString stringWithFormat:@"%zd", slotId];

	if (slotId == 0)
	{
		MPLogDebug(@"Failed to load, slotId not found");
		[self delegateOnNoAdWithReason:@"Failed to load, slotId not found"];
		return;
	}

	MTRGAdSize *adSize = [self adSizeWithWidth:size.width height:size.height];
	if (!adSize) return;

	[MTRGMyTargetAdapterUtils setupConsent];

	id <MPInlineAdAdapterDelegate> delegate = self.delegate;
	UIViewController *viewController = delegate ? [delegate inlineAdAdapterViewControllerForPresentingModalView:self] : nil;

	_adView = [MTRGAdView adViewWithSlotId:slotId shouldRefreshAd:NO];
	_adView.adSize = adSize;
	_adView.viewController = viewController;
	_adView.delegate = self;

	[MTRGMyTargetAdapterUtils fillCustomParams:_adView.customParams dictionary:self.localExtras];

	MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:kMoPubStandardAdapter dspCreativeId:nil dspName:nil], _placementId);
	if (adMarkup)
	{
		MPLogInfo(@"Loading banner ad from bid");
		[_adView loadFromBid:adMarkup];
	}
	else
	{
		MPLogInfo(@"Loading banner ad");
		[_adView load];
	}
}

- (void)dealloc
{
	if (!_adView) return;
	_adView.delegate = nil;
}

#pragma mark - private

- (nullable MTRGAdSize *)adSizeWithWidth:(CGFloat)width height:(CGFloat)height
{
	if (MTRG_MOPUB_CGFLOAT_EQUALS(height, 50))
	{
		return [MTRGAdSize adSize320x50];
	}
	else if (MTRG_MOPUB_CGFLOAT_EQUALS(height, 250))
	{
		return [MTRGAdSize adSize300x250];
	}
	else if (MTRG_MOPUB_CGFLOAT_EQUALS(height, 90))
	{
		return [MTRGAdSize adSize728x90];
	}
	else if (MTRG_MOPUB_CGFLOAT_EQUALS(height, 1) && width > 1)
	{
		return [MTRGAdSize adSizeForCurrentOrientationForWidth:width];
	}
	else if (MTRG_MOPUB_CGFLOAT_EQUALS(height, 1) && MTRG_MOPUB_CGFLOAT_EQUALS(width, 1))
	{
		return [MTRGAdSize adSizeForCurrentOrientation];
	}
	else
	{
		MPLogDebug(@"Failed to load, invalid ad size: %.fx%.f", width, height);
		NSString *reason = [NSString stringWithFormat:@"Failed to load, invalid ad size: %.fx%.f", width, height];
		[self delegateOnNoAdWithReason:reason];
		return nil;
	}
}

- (void)delegateOnNoAdWithReason:(NSString *)reason
{
	NSError *error = [NSError errorWithCode:MOPUBErrorNoNetworkData localizedDescription:reason];
	MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:kMoPubStandardAdapter error:error], _placementId);
	id <MPInlineAdAdapterDelegate> delegate = self.delegate;
	if (!delegate) return;
	[delegate inlineAdAdapter:self didFailToLoadAdWithError:error];
}

#pragma mark - MTRGAdViewDelegate

- (void)onLoadWithAdView:(MTRGAdView *)adView
{
	MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:kMoPubStandardAdapter], _placementId);
	MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:kMoPubStandardAdapter], _placementId);
	MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:kMoPubStandardAdapter], _placementId);

	CGRect frame = adView.frame;
	frame.size = adView.adSize.size;
	adView.frame = frame;

	id <MPInlineAdAdapterDelegate> delegate = self.delegate;
	if (!delegate) return;
	[delegate inlineAdAdapter:self didLoadAdWithAdView:adView];
	[delegate inlineAdAdapterDidTrackImpression:self];
}

- (void)onNoAdWithReason:(NSString *)reason adView:(MTRGAdView *)adView
{
	[self delegateOnNoAdWithReason:reason];
}

- (void)onAdClickWithAdView:(MTRGAdView *)adView
{
	MPLogAdEvent([MPLogEvent adTappedForAdapter:kMoPubStandardAdapter], _placementId);

	id <MPInlineAdAdapterDelegate> delegate = self.delegate;
	if (!delegate) return;
	[delegate inlineAdAdapterDidTrackClick:self];
}

- (void)onShowModalWithAdView:(MTRGAdView *)adView
{
	MPLogAdEvent([MPLogEvent adWillPresentModalForAdapter:kMoPubStandardAdapter], _placementId);

	id <MPInlineAdAdapterDelegate> delegate = self.delegate;
	if (!delegate) return;
	[delegate inlineAdAdapterWillBeginUserAction:self];
}

- (void)onDismissModalWithAdView:(MTRGAdView *)adView
{
	MPLogAdEvent([MPLogEvent adDidDismissModalForAdapter:kMoPubStandardAdapter], _placementId);
	
	id <MPInlineAdAdapterDelegate> delegate = self.delegate;
	if (!delegate) return;
	[delegate inlineAdAdapterDidEndUserAction:self];
}

- (void)onLeaveApplicationWithAdView:(MTRGAdView *)adView
{
	MPLogAdEvent([MPLogEvent adWillLeaveApplicationForAdapter:kMoPubStandardAdapter], _placementId);

	id <MPInlineAdAdapterDelegate> delegate = self.delegate;
	if (!delegate) return;
	[delegate inlineAdAdapterWillLeaveApplication:self];
}

@end
