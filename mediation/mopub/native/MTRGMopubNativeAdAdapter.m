//
//  MTRGMopubNativeAdAdapter.m
//  MediationMopubApp
//
//  Created by Anton Bulankin on 27.01.15.
//  Copyright (c) 2015 Mail.ru Group. All rights reserved.
//

#import <MyTargetSDK/MyTargetSDK.h>
#import "MTRGMopubNativeAdAdapter.h"

#if __has_include("MoPub.h")
	#import "MPNativeAdConstants.h"
	#import "MPLogging.h"
#endif

@implementation MTRGMopubNativeAdAdapter
{
	MTRGMediaAdView *_Nullable _mediaAdView;
	MTRGIconAdView *_Nullable _iconAdView;
	NSDictionary<NSString *, NSString *> *_properties;
}

+ (instancetype)adapterWithPromoBanner:(MTRGNativePromoBanner *)promoBanner nativeAd:(MTRGNativeAd *)nativeAd
{
	return [[MTRGMopubNativeAdAdapter alloc] initWithPromoBanner:promoBanner nativeAd:nativeAd];
}

+ (instancetype)adapterWithBanner:(MTRGNativeBanner *)banner nativeBannerAd:(MTRGNativeBannerAd *)nativeBannerAd
{
	return [[MTRGMopubNativeAdAdapter alloc] initWithBanner:banner nativeBannerAd:nativeBannerAd];
}

- (instancetype)initWithPromoBanner:(MTRGNativePromoBanner *)promoBanner nativeAd:(MTRGNativeAd *)nativeAd
{
	self = [super init];
	if (self)
	{
		_nativeAd = nativeAd;
		_mediaAdView = [MTRGNativeViewsFactory createMediaAdView];
		_iconAdView = [MTRGNativeViewsFactory createIconAdView];

		NSMutableDictionary *properties = [NSMutableDictionary dictionary];
		properties[kAdTitleKey] = promoBanner.title;
		properties[kAdTextKey] = promoBanner.descriptionText;
		properties[kAdIconImageKey] = promoBanner.icon ? promoBanner.icon.url : nil;
		properties[kAdIconImageViewKey] = _iconAdView;
		properties[kAdMainImageKey] = promoBanner.image ? promoBanner.image.url : nil;
		properties[kAdMainMediaViewKey] = _mediaAdView;
		properties[kAdCTATextKey] = promoBanner.ctaText;
		properties[kAdStarRatingKey] = promoBanner.rating ? promoBanner.rating : nil;
		_properties = properties;
	}
	return self;
}

- (instancetype)initWithBanner:(MTRGNativeBanner *)banner nativeBannerAd:(MTRGNativeBannerAd *)nativeBannerAd
{
	self = [super init];
	if (self)
	{
		_nativeBannerAd = nativeBannerAd;
		_iconAdView = [MTRGNativeViewsFactory createIconAdView];

		NSMutableDictionary *properties = [NSMutableDictionary dictionary];
		properties[kAdTitleKey] = banner.title;
		properties[kAdIconImageKey] = banner.icon ? banner.icon.url : nil;
		properties[kAdIconImageViewKey] = _iconAdView;
		properties[kAdCTATextKey] = banner.ctaText;
		properties[kAdStarRatingKey] = banner.rating ? banner.rating : nil;
		_properties = properties;
	}
	return self;
}

- (UIView *)mainMediaView
{
	// implement this method if your ad supplies its own view for the main media view which is typically an image or video
	return _mediaAdView;
}

- (UIView *)iconMediaView
{
	// implement this method if your ad supplies its own view for the icon view which is typically an image
	return _iconAdView;
}

- (void)trackClick
{
	// Tracks a click for this ad.
	// To avoid reporting discrepancies, you should only implement this method if the third-party ad
	// network requires clicks to be reported manually
}

- (NSDictionary *)properties
{
	// Provides a dictionary of all publicly accessible assets (such as title and text) for the native ad
	return _properties;
}

- (BOOL)enableThirdPartyClickTracking
{
	// Determines whether MPNativeAd should track clicks
	// If not implemented, this will be assumed to return NO, and MPNativeAd will track clicks.
	// If this returns YES, then MPNativeAd will defer to the MPNativeAdAdapterDelegate callbacks to track clicks
	return NO;
}

- (NSURL *)defaultActionURL
{
	// The default click-through URL for the ad.
	// This may safely be set to nil if your network doesn't expose this value
	// (for example, it may only provide a method to handle a click, lacking another for retrieving the URL itself).
	return nil;
}

- (void)displayContentForURL:(NSURL *)URL rootViewController:(UIViewController *)controller
{
	// This method is called when the user interacts with your ad,
	// and can either forward the call to a corresponding method on the mediated ad,
	// or you can implement URL-opening yourself.
	// You do not need to implement this method if your ad network automatically handles taps on your ad.controller
}

- (void)willAttachToView:(UIView *)view
{
	// is called when the ad content is loaded into its container view, and passes back that view.
	// Native ads that automatically track impressions should implement this method
	[self willAttachToView:view withAdContentViews:@[]];
}

- (void)willAttachToView:(UIView *)view withAdContentViews:(NSArray *)adContentViews
{
	// Note: If both this method and `willAttachToView:` are implemented, ONLY this method will be called.

	id <MPNativeAdAdapterDelegate> delegate = self.delegate;
	UIViewController *controller = delegate ? delegate.viewControllerForPresentingModalView : nil;

	// view has no subviews yet, so wait a little before looking for iconAdView and mediaAdView inside
	NSTimeInterval delay = 0.1;
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
	{
		MTRGNativeAd *nativeAd = self.nativeAd;
		if (nativeAd)
		{
			[nativeAd registerView:view withController:controller withClickableViews:adContentViews];
			return;
		}
		MTRGNativeBannerAd *nativeBannerAd = self.nativeBannerAd;
		if (nativeBannerAd)
		{
			[nativeBannerAd registerView:view withController:controller withClickableViews:adContentViews];
		}
	});
}

#pragma mark - MTRGMopubNativeCustomEventDelegate

- (void)onNativeAdShow
{
	id <MPNativeAdAdapterDelegate> delegate = self.delegate;
	if (!delegate || ![delegate respondsToSelector:@selector(nativeAdWillLogImpression:)])
	{
		MPLogInfo(@"Adapter's delegate does not implement impression tracking callback.");
		return;
	}
	[delegate nativeAdWillLogImpression:self];
}

- (void)onNativeAdClick
{
	id <MPNativeAdAdapterDelegate> delegate = self.delegate;
	if (!delegate || ![delegate respondsToSelector:@selector(nativeAdDidClick:)])
	{
		MPLogInfo(@"Adapter's delegate does not implement click tracking callback.");
		return;
	}
	[delegate nativeAdDidClick:self];
}

- (void)onNativeAdShowModal
{
	id <MPNativeAdAdapterDelegate> delegate = self.delegate;
	if (!delegate) return;
	[delegate nativeAdWillPresentModalForAdapter:self];
}

- (void)onNativeAdDismissModal
{
	id <MPNativeAdAdapterDelegate> delegate = self.delegate;
	if (!delegate) return;
	[delegate nativeAdDidDismissModalForAdapter:self];
}

- (void)onNativeAdLeaveApplication
{
	id <MPNativeAdAdapterDelegate> delegate = self.delegate;
	if (!delegate) return;
	[delegate nativeAdWillLeaveApplicationFromAdapter:self];
}

@end
