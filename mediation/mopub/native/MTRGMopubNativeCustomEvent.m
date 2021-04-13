//
//  MTRGMopubNativeCustomEvent.m
//  MediationMopubApp
//
//  Created by Anton Bulankin on 27.01.15.
//  Copyright (c) 2015 Mail.ru Group. All rights reserved.
//

#import <MyTargetSDK/MyTargetSDK.h>
#import "MTRGMopubNativeCustomEvent.h"
#import "MTRGMopubNativeAdAdapter.h"
#import "MTRGMyTargetAdapterUtils.h"
#import "MTRGMyTargetAdapterConfiguration.h"

#if __has_include("MoPub.h")
	#import "MPNativeAd.h"
	#import "MPNativeAdError.h"
	#import "MPLogging.h"
#endif

static NSString * const kMoPubNativeCustomEvent = @"MTRGMopubNativeCustomEvent";
static MTRGAdChoicesPlacement _adChoicesPlacement = MTRGAdChoicesPlacementTopRight;

@interface MTRGMopubNativeCustomEvent () <MTRGNativeAdDelegate, MTRGNativeBannerAdDelegate>

@end

@implementation MTRGMopubNativeCustomEvent
{
	MTRGMopubNativeAdAdapter *_Nullable _adapter;
	MTRGNativeAd *_Nullable _nativeAd;
	MTRGNativeBannerAd *_Nullable _nativeBannerAd;
	NSString *_Nullable _placementId;
	BOOL _isNativeBanner;
}

+ (void)setAdChoicesPlacement:(MTRGAdChoicesPlacement)adChoicesPlacement
{
	@synchronized([self class])
	{
		_adChoicesPlacement = adChoicesPlacement;
	}
}
- (void)requestAdWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup
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

	MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:kMoPubNativeCustomEvent dspCreativeId:nil dspName:nil], _placementId);
	BOOL isNativeBanner = MTRGMyTargetAdapterConfiguration.isNativeBanner;
	_isNativeBanner = isNativeBanner || [MTRGMyTargetAdapterUtils isNativeBannerWithDictionary:self.localExtras];
	if (_isNativeBanner)
	{
		_nativeBannerAd = [MTRGNativeBannerAd nativeBannerAdWithSlotId:slotId];
		_nativeBannerAd.adChoicesPlacement = _adChoicesPlacement;
		_nativeBannerAd.cachePolicy = MTRGCachePolicyNone;
		_nativeBannerAd.delegate = self;

		[MTRGMyTargetAdapterUtils fillCustomParams:_nativeBannerAd.customParams dictionary:self.localExtras];

		if (adMarkup)
		{
			MPLogInfo(@"Loading native banner ad from bid");
			[_nativeBannerAd loadFromBid:adMarkup];
		}
		else
		{
			MPLogInfo(@"Loading native banner ad");
			[_nativeBannerAd load];
		}
	}
	else
	{
		_nativeAd = [MTRGNativeAd nativeAdWithSlotId:slotId];
		_nativeAd.adChoicesPlacement = _adChoicesPlacement;
		_nativeAd.cachePolicy = MTRGCachePolicyNone;
		_nativeAd.delegate = self;

		[MTRGMyTargetAdapterUtils fillCustomParams:_nativeAd.customParams dictionary:self.localExtras];

		if (adMarkup)
		{
			MPLogInfo(@"Loading native ad from bid");
			[_nativeAd loadFromBid:adMarkup];
		}
		else
		{
			MPLogInfo(@"Loading native ad");
			[_nativeAd load];
		}
	}
}

- (void)dealloc
{
	MPLogInfo(@"MTRGMopubNativeCustomEvent.dealloc()");
}

#pragma mark - private

- (BOOL)isNativeAdValid:(MTRGNativeAd *)nativeAd
{
	MTRGNativePromoBanner *banner = nativeAd.banner;
	return (banner && banner.title && banner.icon && banner.image && banner.ctaText);
}

- (BOOL)isNativeBannerAdValid:(MTRGNativeBannerAd *)nativeBannerAd
{
	MTRGNativeBanner *banner = nativeBannerAd.banner;
	return (banner && banner.title && banner.icon && banner.ctaText);
}

#pragma mark - delegates

- (void)delegateOnNoAdWithReason:(NSString *)reason
{
	NSError *error = MPNativeAdNSErrorForInvalidAdServerResponse(reason);
	MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:kMoPubNativeCustomEvent error:error], _placementId);
	id <MPNativeCustomEventDelegate> delegate = self.delegate;
	if (!delegate) return;
	[delegate nativeCustomEvent:self didFailToLoadAdWithError:error];
}

#pragma mark - MTRGNativeAdDelegate

- (void)onLoadWithNativePromoBanner:(MTRGNativePromoBanner *)promoBanner nativeAd:(MTRGNativeAd *)nativeAd
{
	if (![self isNativeAdValid:nativeAd])
	{
		MPLogInfo(@"NativeAd is missing one or more required assets");
		[self delegateOnNoAdWithReason:@"Missing one or more required assets."];
		return;
	}
	MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:kMoPubNativeCustomEvent], _placementId);
	_adapter = [MTRGMopubNativeAdAdapter adapterWithPromoBanner:promoBanner
													   nativeAd:nativeAd
													placementId:_placementId];
	MPNativeAd *moPubNativeAd = [[MPNativeAd alloc] initWithAdAdapter:_adapter];

	NSMutableArray<NSURL *> *images = [NSMutableArray<NSURL *> new];
	if (promoBanner.icon)
	{
		NSURL *icon = [NSURL URLWithString:promoBanner.icon.url];
		[images addObject:icon];
	}
	if (promoBanner.image)
	{
		NSURL *image = [NSURL URLWithString:promoBanner.image.url];
		[images addObject:image];
	}

	NSString *placementId = _placementId;
	[self precacheImagesWithURLs:images completionBlock:^(NSArray *errors)
	{
		id <MPNativeCustomEventDelegate> delegate = self.delegate;
		if (!delegate) return;
		if (errors)
		{
			MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:kMoPubNativeCustomEvent error:MPNativeAdNSErrorForImageDownloadFailure()], placementId);
			[delegate nativeCustomEvent:self didFailToLoadAdWithError:MPNativeAdNSErrorForImageDownloadFailure()];
		}
		else
		{
			[delegate nativeCustomEvent:self didLoadAd:moPubNativeAd];
		}
	}];
}

- (void)onNoAdWithReason:(NSString *)reason nativeAd:(MTRGNativeAd *)nativeAd
{
	[self delegateOnNoAdWithReason:reason];
}

#pragma mark - MTRGNativeBannerAdDelegate

- (void)onLoadWithNativeBanner:(MTRGNativeBanner *)banner nativeBannerAd:(MTRGNativeBannerAd *)nativeBannerAd
{
	if (![self isNativeBannerAdValid:nativeBannerAd])
	{
		MPLogInfo(@"NativeBannerAd is missing one or more required assets");
		[self delegateOnNoAdWithReason:@"Missing one or more required assets."];
		return;
	}
	MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:kMoPubNativeCustomEvent], _placementId);
	_adapter = [MTRGMopubNativeAdAdapter adapterWithBanner:banner
											nativeBannerAd:nativeBannerAd
											   placementId:_placementId];
	MPNativeAd *moPubNativeAd = [[MPNativeAd alloc] initWithAdAdapter:_adapter];

	NSMutableArray<NSURL *> *images = [NSMutableArray<NSURL *> new];
	if (banner.icon)
	{
		NSURL *icon = [NSURL URLWithString:banner.icon.url];
		[images addObject:icon];
	}

	NSString *placementId = _placementId;
	[self precacheImagesWithURLs:images completionBlock:^(NSArray *errors)
	{
		id <MPNativeCustomEventDelegate> delegate = self.delegate;
		if (!delegate) return;
		if (errors)
		{
			MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:kMoPubNativeCustomEvent error:MPNativeAdNSErrorForImageDownloadFailure()], placementId);
			[delegate nativeCustomEvent:self didFailToLoadAdWithError:MPNativeAdNSErrorForImageDownloadFailure()];
		}
		else
		{
			[delegate nativeCustomEvent:self didLoadAd:moPubNativeAd];
		}
	}];
}

- (void)onNoAdWithReason:(NSString *)reason nativeBannerAd:(MTRGNativeBannerAd *)nativeBannerAd
{
	[self delegateOnNoAdWithReason:reason];
}

@end
