//
//  MTRGMopubNativeAdAdapter.m
//  myTargetSDKMopubMediation
//
//  Created by Anton Bulankin on 27.01.15.
//  Copyright (c) 2015 Mail.ru Group. All rights reserved.
//

#import <MyTargetSDK/MyTargetSDK.h>
#import "MTRGMopubNativeAdAdapter.h"

#if __has_include("MoPub.h")
	#import "MPNativeAdConstants.h"
#endif

@interface MTRGNativeAd ()

- (void)handleShow;

- (void)handleClickWithController:(UIViewController *)viewController;

@end

@interface MTRGMopubNativeAdAdapter ()

@property(strong, nonatomic) MTRGNativePromoBanner *promoBanner;
@property(strong, nonatomic) MTRGNativeAd *nativeAd;

@end

@implementation MTRGMopubNativeAdAdapter
{
	NSDictionary<NSString *, NSString *> *_properties;
	__weak id <MPNativeAdAdapterDelegate> _delegate;
}

- (instancetype)initWithPromoBanner:(MTRGNativePromoBanner *)promoBanner nativeAd:(MTRGNativeAd *)nativeAd
{
	self = [super init];
	if (self)
	{
		_nativeAd = nativeAd;
		_promoBanner = promoBanner;
		_properties = [MTRGMopubNativeAdAdapter propertiesWithBanner:promoBanner];
	}
	return self;
}

- (void)setDelegate:(id <MPNativeAdAdapterDelegate>)delegate
{
	_delegate = delegate;
}

- (id <MPNativeAdAdapterDelegate>)delegate
{
	return _delegate;
}

- (void)trackClick
{
	// is called when the user interacts with an ad, and allows for manual click tracking for the mediated ad
}

- (NSDictionary *)properties
{
	return _properties;
}

- (NSURL *)defaultActionURL
{
	// the URL the user is taken to when they interact with the ad. If the native ad automatically opens it then this can be nil
	return nil;
}

- (void)displayContentForURL:(NSURL *)URL rootViewController:(UIViewController *)controller
{
	// This method is called when the user interacts with your ad,
	// and can either forward the call to a corresponding method on the mediated ad,
	// or you can implement URL-opening yourself.
	// You do not need to implement this method if your ad network automatically handles taps on your ad.

	[_nativeAd handleClickWithController:controller];

	// Клик в mopub не отправляем, так как его отправляет mopub.

	// Уведомляем приложение, что уходим в модальный режим (всегда, даже если на самом деле пойдем в бразуер)
	// Обратный метод не вызываем, так как наше СДК его наверх не предоставляет.
	id <MPNativeAdAdapterDelegate> delegate = _delegate;
	if (!delegate) return;
	[delegate nativeAdWillPresentModalForAdapter:self];
}

- (void)willAttachToView:(UIView *)view
{
	// is called when the ad content is loaded into its container view, and passes back that view.
	// Native ads that automatically track impressions should implement this method

	[_nativeAd handleShow];

	// Отправляем показ в mopub
	id <MPNativeAdAdapterDelegate> delegate = _delegate;
	if (!delegate || ![delegate respondsToSelector:@selector(nativeAdWillLogImpression:)]) return;
	[delegate nativeAdWillLogImpression:self];
}

#pragma mark - helpers

+ (nullable NSDictionary<NSString *, NSString *> *)propertiesWithBanner:(nullable MTRGNativePromoBanner *)promoBanner
{
	if (!promoBanner) return nil;

	NSMutableDictionary<NSString *, NSString *> *properties = [NSMutableDictionary<NSString *, NSString *> new];
	if (promoBanner.title)
	{
		NSString *key = [kAdTitleKey copy];
		properties[key] = promoBanner.title;
	}
	if (promoBanner.descriptionText)
	{
		NSString *key = [kAdTextKey copy];
		properties[key] = promoBanner.descriptionText;
	}
	if (promoBanner.icon)
	{
		NSString *key = [kAdIconImageKey copy];
		properties[key] = promoBanner.icon.url;
	}
	if (promoBanner.image)
	{
		NSString *key = [kAdMainImageKey copy];
		properties[key] = promoBanner.image.url;
	}
	if (promoBanner.ctaText)
	{
		NSString *key = [kAdCTATextKey copy];
		properties[key] = promoBanner.ctaText;
	}
	if (promoBanner.rating)
	{
		NSString *key = [kAdStarRatingKey copy];
		properties[key] = promoBanner.rating.stringValue;
	}
	return properties;
}

@end
