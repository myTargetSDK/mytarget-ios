//
//  MTRGMopubNativeCustomEvent.h
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
	#import "MPNativeCustomEvent.h"
#endif

#import <MyTargetSDK/MTRGAdChoicesPlacement.h>

NS_ASSUME_NONNULL_BEGIN

__attribute__((objc_subclassing_restricted))
@interface MTRGMopubNativeCustomEvent : MPNativeCustomEvent

+ (void)setAdChoicesPlacement:(MTRGAdChoicesPlacement)adChoicesPlacement;

@end

NS_ASSUME_NONNULL_END
