//
//  MTRGMopubNativeAdRenderer.m
//  MediationMopubApp
//
//  Created by Andrey Seredkin on 25.06.2020.
//  Copyright © 2020 Mail.ru Group. All rights reserved.
//

#import "MTRGMopubNativeAdRenderer.h"
#import <MyTargetSDK/MyTargetSDK.h>

#if __has_include("MoPub.h")
	#import "MPLogging.h"
	#import "MPNativeAdAdapter.h"
	#import "MPNativeAdConstants.h"
	#import "MPNativeAdError.h"
	#import "MPNativeAdRendererConfiguration.h"
	#import "MPNativeAdRendererImageHandler.h"
	#import "MPNativeAdRendering.h"
	#import "MPNativeAdRenderingImageLoader.h"
	#import "MPStaticNativeAdRendererSettings.h"
#endif

#import "MTRGMopubNativeAdAdapter.h"

@implementation MTRGMopubNativeAdRendererSettings

@end

@interface MTRGMopubNativeAdRenderer () <MPNativeAdRendererImageHandlerDelegate>

@end

@implementation MTRGMopubNativeAdRenderer
{
	Class _renderingViewClass;
	UIView<MPNativeAdRendering> *_Nullable _adView;
	MTRGMopubNativeAdAdapter *_Nullable _adapter;
	MPNativeAdRendererImageHandler *_rendererImageHandler;
	BOOL _adViewInViewHierarchy;
	BOOL _hasMediaView;
	BOOL _hasIconView;
}

+ (MPNativeAdRendererConfiguration *)rendererConfigurationWithRendererSettings:(id <MPNativeAdRendererSettings>)rendererSettings
{
	MPNativeAdRendererConfiguration *config = [[MPNativeAdRendererConfiguration alloc] init];
	config.rendererClass = [self class];
	config.rendererSettings = rendererSettings;
	config.supportedCustomEvents = @[@"MTRGMopubNativeCustomEvent"];
	return config;
}

- (instancetype)initWithRendererSettings:(id<MPNativeAdRendererSettings>)rendererSettings
{
	self = [super init];
	if (self)
	{
		if ([rendererSettings isKindOfClass:[MPStaticNativeAdRendererSettings class]])
		{
			MPStaticNativeAdRendererSettings *settings = (MPStaticNativeAdRendererSettings *)rendererSettings;
			_renderingViewClass = settings.renderingViewClass;
		}
		if ([rendererSettings respondsToSelector:@selector(viewSizeHandler)])
		{
			_viewSizeHandler = [rendererSettings.viewSizeHandler copy];
		}
		_rendererImageHandler = [MPNativeAdRendererImageHandler new];
		_rendererImageHandler.delegate = self;
	}
	return self;
}

- (UIView *)retrieveViewWithAdapter:(id <MPNativeAdAdapter>)adapter error:(NSError **)error
{
	// Return a view that contains the rendered ad elements using the data contained in your adapter class.
	// You should recreate the view each time this is called if possible.
	if (!adapter || ![adapter isKindOfClass:[MTRGMopubNativeAdAdapter class]])
	{
		if (error)
		{
			*error = MPNativeAdNSErrorForRenderValueTypeError();
		}
		return nil;
	}

	_adapter = (MTRGMopubNativeAdAdapter *) adapter;

	_hasIconView = [_adapter respondsToSelector:@selector(iconMediaView)] && _adapter.iconMediaView;
	_hasMediaView = [_adapter respondsToSelector:@selector(mainMediaView)] && _adapter.mainMediaView;

	if (!_renderingViewClass)
	{
		if (_adapter.nativeAd)
		{
			MTRGNativeAdView *adView = [MTRGNativeViewsFactory createNativeAdView];
			adView.banner = _adapter.nativeAd.banner;
			adView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
			return adView;
		}
		else if (_adapter.nativeBannerAd)
		{
			MTRGNativeBannerAdView *adView = [MTRGNativeViewsFactory createNativeBannerAdView];
			adView.banner = _adapter.nativeBannerAd.banner;
			adView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
			return adView;
		}
		return nil;
	}

	if ([_renderingViewClass respondsToSelector:@selector(nibForAd)])
	{
		UINib *nib = [_renderingViewClass nibForAd];
		_adView = (UIView<MPNativeAdRendering> *) [[nib instantiateWithOwner:nil options:nil] firstObject];
	}
	else
	{
		_adView = [[_renderingViewClass alloc] init];
	}

	_adView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

	if ([_adView respondsToSelector:@selector(nativeMainTextLabel)])
	{
		_adView.nativeMainTextLabel.text = [adapter.properties objectForKey:kAdTextKey];
	}

	if ([_adView respondsToSelector:@selector(nativeTitleTextLabel)])
	{
		_adView.nativeTitleTextLabel.text = [adapter.properties objectForKey:kAdTitleKey];
	}

	if ([_adView respondsToSelector:@selector(nativeCallToActionTextLabel)] && _adView.nativeCallToActionTextLabel)
	{
		_adView.nativeCallToActionTextLabel.text = [adapter.properties objectForKey:kAdCTATextKey];
	}

	if (_hasIconView && _adView && [_adView respondsToSelector:@selector(nativeIconImageView)])
	{
		UIView *iconView = [_adapter iconMediaView];
		UIView *iconImageView = [_adView nativeIconImageView];

		if (iconImageView)
		{
			iconView.frame = iconImageView.bounds;
			iconView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
			iconImageView.userInteractionEnabled = YES;
			[iconImageView addSubview:iconView];
		}
	}

	if (_hasMediaView && _adView)
	{
		UIView *superview = nil;
		if ([_adView respondsToSelector:@selector(nativeMainImageView)])
		{
			superview = [_adView nativeMainImageView];
		}

		if (superview)
		{
			UIView *mediaView = [_adapter mainMediaView];
			mediaView.frame = superview.bounds;
			mediaView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
			superview.userInteractionEnabled = YES;
			[superview addSubview:mediaView];
		}
	}

	if ([_adView respondsToSelector:@selector(layoutStarRating:)])
	{
		NSNumber *starRating = [adapter.properties objectForKey:kAdStarRatingKey];
		if (starRating && [starRating isKindOfClass:[NSNumber class]] && starRating.floatValue >= kStarRatingMinValue && starRating.floatValue <= kStarRatingMaxValue)
		{
			[_adView layoutStarRating:starRating];
		}
	}

	return _adView;
}

- (void)adViewWillMoveToSuperview:(UIView *)superview
{
	if (!superview || !_adView)
	{
		_adViewInViewHierarchy = NO;
		MPLogDebug(@"adView is not in views hierarchy");
		return;
	}
	_adViewInViewHierarchy = YES;

	NSString *iconLink = [_adapter.properties objectForKey:kAdIconImageKey];
	if (!_hasIconView && iconLink && [iconLink isKindOfClass:[NSString class]] && [_adView respondsToSelector:@selector(nativeIconImageView)] && _adView.nativeIconImageView)
	{
		NSURL *url = [NSURL URLWithString:iconLink];
		if (url)
		{
			[_rendererImageHandler loadImageForURL:url intoImageView:_adView.nativeIconImageView];
		}
	}

	NSString *imageLink = [_adapter.properties objectForKey:kAdMainImageKey];
	if (!_hasMediaView && imageLink && [imageLink isKindOfClass:[NSString class]] && [_adView respondsToSelector:@selector(nativeMainImageView)] && _adView.nativeMainImageView)
	{
		NSURL *url = [NSURL URLWithString:imageLink];
		if (url)
		{
			[_rendererImageHandler loadImageForURL:url intoImageView:_adView.nativeMainImageView];
		}
	}

	if ([_adView respondsToSelector:@selector(layoutCustomAssetsWithProperties:imageLoader:)])
	{
		MPNativeAdRenderingImageLoader *imageLoader = [[MPNativeAdRenderingImageLoader alloc] initWithImageHandler:_rendererImageHandler];
		[_adView layoutCustomAssetsWithProperties:_adapter.properties imageLoader:imageLoader];
	}
}

#pragma mark - MPNativeAdRendererImageHandlerDelegate

- (BOOL)nativeAdViewInViewHierarchy
{
	return _adViewInViewHierarchy;
}

@end
