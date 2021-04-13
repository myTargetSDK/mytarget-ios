//
//  MTRGMopubRewardedVideoCustomEvent.h
//  MediationMopubApp
//
//  Created by Andrey Seredkin on 05.10.16.
//  Copyright (c) 2016 Mail.ru Group. All rights reserved.
//

#if __has_include(<MoPub/MoPub.h>)
	#import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDK/MoPub.h>)
	#import <MoPubSDK/MoPub.h>
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
	#import <MoPubSDKFramework/MoPub.h>
#else
	#import "MPFullscreenAdAdapter.h"
#endif

NS_ASSUME_NONNULL_BEGIN

__attribute__((objc_subclassing_restricted))
@interface MTRGMopubRewardedVideoCustomEvent : MPFullscreenAdAdapter <MPThirdPartyFullscreenAdAdapter>

@end

NS_ASSUME_NONNULL_END
