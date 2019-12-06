//
//  MTRGMopubRewardedVideoCustomEvent.h
//  myTargetSDKMopubMediation
//
//  Created by Andrey Seredkin on 05.10.16.
//  Copyright (c) 2016 Mail.ru Group. All rights reserved.
//

#if __has_include(<MoPub/MoPub.h>)
	#import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
	#import <MoPubSDKFramework/MoPub.h>
#else
	#import "MPRewardedVideoCustomEvent.h"
#endif

@interface MTRGMopubRewardedVideoCustomEvent : MPRewardedVideoCustomEvent

@end
