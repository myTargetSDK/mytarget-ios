//
//  MTRGMopubNativeAdAdapter.m
//  myTargetSDKMopubMediation
//
//  Created by Anton Bulankin on 27.01.15.
//  Copyright (c) 2015 Mail.ru Group. All rights reserved.
//

#import "MTRGMopubNativeAdAdapter.h"
#import "MPNativeAdConstants.h"

@interface MTRGNativeAd ()

- (void)handleShow;

- (void)handleClick;

- (void)handleClickWithController:(UIViewController *)viewController;

@end


@interface MTRGMopubNativeAdAdapter ()

@property(strong, nonatomic) MTRGNativePromoBanner *promoBanner;
@property(strong, nonatomic) MTRGNativeAd *nativeAd;

@end


@implementation MTRGMopubNativeAdAdapter
{
	NSDictionary *_properties;
	UIViewController *_viewController;
	__weak id <MPNativeAdAdapterDelegate> _delegate;
}

- (instancetype)initWithPromoBanner:(MTRGNativePromoBanner *)promoBanner nativeAd:(MTRGNativeAd *)nativeAd
{
	self = [super init];
	if (self)
	{
		_nativeAd = nativeAd;
		_promoBanner = promoBanner;
		_properties = [MTRGMopubNativeAdAdapter createPropertiesWithBanner:_promoBanner];
	}
	return self;
}

+ (NSDictionary *)createPropertiesWithBanner:(MTRGNativePromoBanner *)promoBanner
{
	if (!promoBanner) return nil;
	NSMutableDictionary *dict = [NSMutableDictionary new];
	if (promoBanner.title)
	{
		[dict setValue:promoBanner.title forKey:[kAdTitleKey copy]];
	}
	if (promoBanner.descriptionText)
	{
		[dict setValue:promoBanner.descriptionText forKey:[kAdTextKey copy]];
	}
	if (promoBanner.icon)
	{
		[dict setValue:promoBanner.icon.url forKey:[kAdIconImageKey copy]];
	}
	if (promoBanner.image)
	{
		[dict setValue:promoBanner.image.url forKey:[kAdMainImageKey copy]];
	}
	if (promoBanner.ctaText)
	{
		[dict setValue:promoBanner.ctaText forKey:[kAdCTATextKey copy]];
	}
	if (promoBanner.rating)
	{
		[dict setValue:promoBanner.rating forKey:[kAdStarRatingKey copy]];
	}
	return dict;
}


- (NSDictionary *)properties
{
	return _properties;
}

- (NSURL *)defaultActionURL
{
	return nil;
}

- (void)displayContentForURL:(NSURL *)URL rootViewController:(UIViewController *)controller
{
	_viewController = controller;
	[_nativeAd handleClickWithController:_viewController];

	//Клик в mopub не отправляем, так как его отправляет mopub.

	//Уведомляем приложение, что уходим в модальный режим(всегда, даже если на самом деле пойдем в бразуер)
	//Обратный метод не вызываем, так как наше СДК его наверх не предоставляет.
	if (self.delegate && [self.delegate respondsToSelector:@selector(nativeAdWillPresentModalForAdapter:)])
	{
		[self.delegate nativeAdWillPresentModalForAdapter:self];
	}
}

- (void)willAttachToView:(UIView *)view
{
	[_nativeAd handleShow];

	//Отправляем показ в mopub
	if (self.delegate && [self.delegate respondsToSelector:@selector(nativeAdWillLogImpression:)])
	{
		[self.delegate nativeAdWillLogImpression:self];
	}
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
	//пусто
}

@end
