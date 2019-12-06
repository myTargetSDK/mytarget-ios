//
//  MTRGMopubAdViewCustomEvent.h
//  myTargetSDKMopubMediation
//
//  Created by Anton Bulankin on 12.03.15.
//  Copyright (c) 2015 Mail.ru Group. All rights reserved.
//

#if __has_include(<MoPub/MoPub.h>)
	#import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
	#import <MoPubSDKFramework/MoPub.h>
#else
	#import "MPBannerCustomEvent.h"
#endif

@interface MTRGMopubAdViewCustomEvent : MPBannerCustomEvent

@end
