//
//  MTRGMediatedNativeAd.m
//  MyTargetMediationApp
//
//  Created by Andrey Seredkin on 13.03.17.
//  Copyright © 2017 Mail.ru Group. All rights reserved.
//

#import "MTRGMediatedNativeAd.h"

@interface MTRGMediatedNativeContentAd : NSObject <GADMediatedNativeContentAd>

@end

@implementation MTRGMediatedNativeContentAd
{
	MTRGNativePromoBanner *_promoBanner;
	__weak id<GADMediatedNativeAdDelegate> _delegate;
}

- (instancetype)initWithPromoBanner:(MTRGNativePromoBanner *)promoBanner delegate:(id<GADMediatedNativeAdDelegate>)delegate
{
	self = [super init];
	if (self)
	{
		_promoBanner = promoBanner;
		_delegate = delegate;
	}
	return self;
}

- (id<GADMediatedNativeAdDelegate>)mediatedNativeAdDelegate
{
	return _delegate;
}

- (NSDictionary *)extraAssets
{
	return nil;
}

- (NSString *)headline
{
	return _promoBanner.title;
}

- (NSString *)body
{
	return _promoBanner.descriptionText;
}

- (NSArray *)images
{
	GADNativeAdImage *image = [MTRGMediatedNativeAd nativeAdImageWithImageData:_promoBanner.image];
	return (image != nil) ? @[image] : nil;
}

- (GADNativeAdImage *)logo
{
	return [MTRGMediatedNativeAd nativeAdImageWithImageData:_promoBanner.icon];
}

- (NSString *)callToAction
{
	return _promoBanner.ctaText;
}

- (NSString *)advertiser
{
	return _promoBanner.advertisingLabel;
}

- (UIView *)adChoicesView
{
	return nil;
}

@end

@interface MTRGMediatedNativeAppInstallAd : NSObject <GADMediatedNativeAppInstallAd>

@end

@implementation MTRGMediatedNativeAppInstallAd
{
	MTRGNativePromoBanner *_promoBanner;
	__weak id<GADMediatedNativeAdDelegate> _delegate;
}

- (instancetype)initWithPromoBanner:(MTRGNativePromoBanner *)promoBanner delegate:(id<GADMediatedNativeAdDelegate>)delegate
{
	self = [super init];
	if (self)
	{
		_promoBanner = promoBanner;
		_delegate = delegate;
	}
	return self;
}

- (id<GADMediatedNativeAdDelegate>)mediatedNativeAdDelegate
{
	return _delegate;
}

- (NSDictionary *)extraAssets
{
	return nil;
}

- (NSString *)headline
{
	return _promoBanner.title;
}

- (NSArray *)images
{
	GADNativeAdImage *image = [MTRGMediatedNativeAd nativeAdImageWithImageData:_promoBanner.image];
	return (image != nil) ? @[image] : nil;
}

- (NSString *)body
{
	return _promoBanner.descriptionText;
}

- (GADNativeAdImage *)icon
{
	return [MTRGMediatedNativeAd nativeAdImageWithImageData:_promoBanner.icon];
}

- (NSString *)callToAction
{
	return _promoBanner.ctaText;
}

- (NSDecimalNumber *)starRating
{
	return [NSDecimalNumber decimalNumberWithDecimal:_promoBanner.rating.decimalValue];
}

- (NSString *)store
{
	return nil;
}

- (NSString *)price
{
	return nil;
}

- (UIView *)adChoicesView
{
	return nil;
}

@end


@implementation MTRGMediatedNativeAd

+ (id<GADMediatedNativeAd>)mediatedNativeAdWithNativePromoBanner:(MTRGNativePromoBanner *)promoBanner delegate:(id<GADMediatedNativeAdDelegate>)delegate
{
	if (promoBanner.navigationType == MTRGNavigationTypeWeb)
	{
		MTRGMediatedNativeContentAd *mediatedNativeContentAd = [[MTRGMediatedNativeContentAd alloc] initWithPromoBanner:promoBanner delegate:delegate];
		return mediatedNativeContentAd;
	}
	else if (promoBanner.navigationType == MTRGNavigationTypeStore)
	{
		MTRGMediatedNativeAppInstallAd *mediatedNativeAppInstallAd = [[MTRGMediatedNativeAppInstallAd alloc] initWithPromoBanner:promoBanner delegate:delegate];
		return mediatedNativeAppInstallAd;
	}
	return nil;
}

+ (GADNativeAdImage *)nativeAdImageWithImageData:(MTRGImageData *)imageData
{
	if (!imageData) return nil;

	GADNativeAdImage *nativeAdImage = nil;
	if (imageData.image)
	{
		nativeAdImage = [[GADNativeAdImage alloc] initWithImage:imageData.image];
	}
	else if (imageData.url)
	{
		NSURL *url = [NSURL URLWithString:imageData.url];
		nativeAdImage = [[GADNativeAdImage alloc] initWithURL:url scale:1.0];
	}
	return nativeAdImage;
}

@end
