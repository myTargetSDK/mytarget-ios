//
//  MTRGMediatedNativeAd.h
//  MyTargetMediationApp
//
//  Created by Andrey Seredkin on 13.03.17.
//  Copyright © 2017 Mail.ru Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <MyTargetSDK/MyTargetSDK.h>

@interface MTRGMediatedNativeAd : NSObject

+ (id<GADMediatedNativeAd>)mediatedNativeAdWithNativePromoBanner:(MTRGNativePromoBanner *)promoBanner delegate:(id<GADMediatedNativeAdDelegate>)delegate;

+ (GADNativeAdImage *)nativeAdImageWithImageData:(MTRGImageData *)imageData;

@end
