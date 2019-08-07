//
//  MTRGMopubNativeAdAdapter.h
//  myTargetSDKMopubMediation
//
//  Created by Anton Bulankin on 27.01.15.
//  Copyright (c) 2015 Mail.ru Group. All rights reserved.
//

@import MyTargetSDK;

#import <MoPubSDKFramework/MPNativeAdAdapter.h>

NS_ASSUME_NONNULL_BEGIN

@interface MTRGMopubNativeAdAdapter : NSObject <MPNativeAdAdapter>

- (instancetype)initWithPromoBanner:(MTRGNativePromoBanner *)promoBanner nativeAd:(MTRGNativeAd *)nativeAd;

@end

NS_ASSUME_NONNULL_END
