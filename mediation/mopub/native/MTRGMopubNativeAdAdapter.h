//
//  MTRGMopubNativeAdAdapter.h
//  MediationMopubApp
//
//  Created by Anton Bulankin on 27.01.15.
//  Copyright (c) 2015 Mail.ru Group. All rights reserved.
//

#if __has_include(<MoPub/MoPub.h>)
	#import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
	#import <MoPubSDKFramework/MoPub.h>
#else
	#import "MPNativeAdAdapter.h"
#endif

#import "MTRGMopubNativeCustomEvent.h"

@class MTRGNativeAd;
@class MTRGNativeBannerAd;
@class MTRGNativeBanner;
@class MTRGNativePromoBanner;

NS_ASSUME_NONNULL_BEGIN

__attribute__((objc_subclassing_restricted))
@interface MTRGMopubNativeAdAdapter : NSObject <MPNativeAdAdapter, MTRGMopubNativeCustomEventDelegate>

@property (nonatomic, weak) id <MPNativeAdAdapterDelegate> delegate;
@property (nonatomic, readonly, nullable) MTRGNativeAd *nativeAd;
@property (nonatomic, readonly, nullable) MTRGNativeBannerAd *nativeBannerAd;

+ (instancetype)adapterWithPromoBanner:(MTRGNativePromoBanner *)promoBanner nativeAd:(MTRGNativeAd *)nativeAd;

+ (instancetype)adapterWithBanner:(MTRGNativeBanner *)banner nativeBannerAd:(MTRGNativeBannerAd *)nativeBannerAd;

+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
