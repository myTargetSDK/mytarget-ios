//
//  MTRGMyTargetAdapterUtils.m
//  MyTargetMediationApp
//
//  Created by Andrey Seredkin on 08/06/2020.
//  Copyright © 2020 Mail.ru Group. All rights reserved.
//

#import "MTRGMyTargetAdapterUtils.h"
#import <MyTargetSDK/MTRGPrivacy.h>

#if __has_include(<MoPub/MoPub.h>)
	#import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
	#import <MoPubSDKFramework/MoPub.h>
#else
	#import "MoPub.h"
#endif

@implementation MTRGMyTargetAdapterUtils

+ (void)setupConsent
{
	switch ([MoPub sharedInstance].currentConsentStatus)
	{
		case MPConsentStatusConsented:
			[MTRGPrivacy setUserConsent:YES];
			break;
		case MPConsentStatusDenied:
		case MPConsentStatusDoNotTrack:
			[MTRGPrivacy setUserConsent:NO];
			break;

		default:
			break;
	}
}

+ (NSUInteger)parseSlotIdFromInfo:(nullable NSDictionary *)info
{
	if (!info) return 0;

	id slotIdValue = [info valueForKey:@"slotId"];
	if (!slotIdValue) return 0;

	NSUInteger slotId = 0;
	if ([slotIdValue isKindOfClass:[NSString class]])
	{
		NSNumberFormatter *formatString = [[NSNumberFormatter alloc] init];
		NSNumber *slotIdNumber = [formatString numberFromString:slotIdValue];
		slotId = (slotIdNumber && slotIdNumber.integerValue > 0) ? slotIdNumber.unsignedIntegerValue : 0;
	}
	else if ([slotIdValue isKindOfClass:[NSNumber class]])
	{
		NSNumber *slotIdNumber = (NSNumber *)slotIdValue;
		slotId = (slotIdNumber && slotIdNumber.integerValue > 0) ? slotIdNumber.unsignedIntegerValue : 0;
	}
	return slotId;
}

@end
