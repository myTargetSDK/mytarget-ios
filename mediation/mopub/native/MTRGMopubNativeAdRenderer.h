//
//  MTRGMopubNativeAdRenderer.h
//  MediationMopubApp
//
//  Created by Andrey Seredkin on 25.06.2020.
//  Copyright © 2020 Mail.ru Group. All rights reserved.
//

#import <Foundation/Foundation.h>

#if __has_include(<MoPub/MoPub.h>)
	#import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDK/MoPub.h>)
	#import <MoPubSDK/MoPub.h>
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
	#import <MoPubSDKFramework/MoPub.h>
#else
	#import "MPNativeAdRenderer.h"
	#import "MPNativeAdRendererSettings.h"
#endif

NS_ASSUME_NONNULL_BEGIN

__attribute__((objc_subclassing_restricted))
@interface MTRGMopubNativeAdRendererSettings : NSObject <MPNativeAdRendererSettings>

@property (nonatomic, readwrite, copy) MPNativeViewSizeHandler viewSizeHandler;

@end

__attribute__((objc_subclassing_restricted))
@interface MTRGMopubNativeAdRenderer : NSObject <MPNativeAdRenderer>

@property (nonatomic, readonly) MPNativeViewSizeHandler viewSizeHandler;

@end

NS_ASSUME_NONNULL_END
