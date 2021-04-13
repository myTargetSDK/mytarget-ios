//
//  MTRGMopubAdViewCustomEvent.h
//  MediationMopubApp
//
//  Created by Anton Bulankin on 12.03.15.
//  Copyright (c) 2015 Mail.ru Group. All rights reserved.
//

#if __has_include(<MoPub/MoPub.h>)
	#import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDK/MoPub.h>)
	#import <MoPubSDK/MoPub.h>
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
	#import <MoPubSDKFramework/MoPub.h>
#else
	#import "MPInlineAdAdapter.h"
#endif

NS_ASSUME_NONNULL_BEGIN

__attribute__((objc_subclassing_restricted))
@interface MTRGMopubAdViewCustomEvent : MPInlineAdAdapter <MPThirdPartyInlineAdAdapter>

@end

NS_ASSUME_NONNULL_END
