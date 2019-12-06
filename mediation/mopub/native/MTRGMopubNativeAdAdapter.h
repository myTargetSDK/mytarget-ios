//
//  MTRGMopubNativeAdAdapter.h
//  myTargetSDKMopubMediation
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

@class MTRGNativeAd;
@class MTRGNativePromoBanner;

NS_ASSUME_NONNULL_BEGIN

@interface MTRGMopubNativeAdAdapter : NSObject <MPNativeAdAdapter>

- (instancetype)initWithPromoBanner:(MTRGNativePromoBanner *)promoBanner nativeAd:(MTRGNativeAd *)nativeAd;

@end

NS_ASSUME_NONNULL_END
