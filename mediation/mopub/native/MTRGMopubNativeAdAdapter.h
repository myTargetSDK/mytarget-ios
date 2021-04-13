//
//  MTRGMopubNativeAdAdapter.h
//  MediationMopubApp
//
//  Created by Anton Bulankin on 27.01.15.
//  Copyright (c) 2015 Mail.ru Group. All rights reserved.
//

#if __has_include(<MoPub/MoPub.h>)
	#import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDK/MoPub.h>)
	#import <MoPubSDK/MoPub.h>
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
	#import <MoPubSDKFramework/MoPub.h>
#else
	#import "MPNativeAdAdapter.h"
#endif

@class MTRGNativeAd;
@class MTRGNativeBannerAd;
@class MTRGNativeBanner;
@class MTRGNativePromoBanner;

NS_ASSUME_NONNULL_BEGIN

__attribute__((objc_subclassing_restricted))
@interface MTRGMopubNativeAdAdapter : NSObject <MPNativeAdAdapter>

@property (nonatomic, weak) id <MPNativeAdAdapterDelegate> delegate;
@property (nonatomic, readonly, nullable) MTRGNativeAd *nativeAd;
@property (nonatomic, readonly, nullable) MTRGNativeBannerAd *nativeBannerAd;

+ (instancetype)adapterWithPromoBanner:(MTRGNativePromoBanner *)promoBanner
							  nativeAd:(MTRGNativeAd *)nativeAd
						   placementId:(nullable NSString *)placementId;

+ (instancetype)adapterWithBanner:(MTRGNativeBanner *)banner
				   nativeBannerAd:(MTRGNativeBannerAd *)nativeBannerAd
					  placementId:(nullable NSString *)placementId;

+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
