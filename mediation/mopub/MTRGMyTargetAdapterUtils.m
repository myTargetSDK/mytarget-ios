//
//  MTRGMyTargetAdapterUtils.m
//  MediationMopubApp
//
//  Created by Andrey Seredkin on 08/06/2020.
//  Copyright © 2020 Mail.ru Group. All rights reserved.
//

#import "MTRGMyTargetAdapterUtils.h"
#import <MyTargetSDK/MTRGPrivacy.h>
#import <MyTargetSDK/MTRGCustomParams.h>

#if __has_include(<MoPub/MoPub.h>)
	#import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDK/MoPub.h>)
	#import <MoPubSDK/MoPub.h>
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
	#import <MoPubSDKFramework/MoPub.h>
#else
	#import "MoPub.h"
#endif

static NSString * const kSlotIdKey = @"slotId";
static NSString * const kNativeBannerKey = @"mytarget_native_banner";
static NSString * const kGenderKey = @"mytarget_gender";
static NSString * const kAgeKey = @"mytarget_age";
static NSString * const kVkIdKey = @"mytarget_vk_id";
static NSString * const kOkIdKey = @"mytarget_ok_id";

@implementation MTRGMyTargetAdapterUtils

+ (void)setupConsent
{
	switch (MoPub.sharedInstance.currentConsentStatus)
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

	id slotIdValue = [info valueForKey:kSlotIdKey];
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

+ (BOOL)isNativeBannerWithDictionary:(nullable NSDictionary *)dictionary
{
	if (!dictionary || dictionary.count == 0) return NO;
	return [MTRGMyTargetAdapterUtils boolForKey:kNativeBannerKey dictionary:dictionary];
}

+ (void)fillCustomParams:(MTRGCustomParams *)customParams dictionary:(nullable NSDictionary *)dictionary
{
	[customParams setCustomParam:kMTRGCustomParamsMediationMopub forKey:kMTRGCustomParamsMediationKey];
	
	if (!dictionary || dictionary.count == 0) return;

	NSNumber *gender = [MTRGMyTargetAdapterUtils numberForKey:kGenderKey dictionary:dictionary];
	if (gender)
	{
		switch (gender.integerValue)
		{
			case 0:
				customParams.gender = MTRGGenderUnknown;
				break;
			case 1:
				customParams.gender = MTRGGenderMale;
				break;
			case 2:
				customParams.gender = MTRGGenderFemale;
				break;
			default:
				customParams.gender = MTRGGenderUnspecified;
				break;
		}
	}

	NSNumber *age = [MTRGMyTargetAdapterUtils numberForKey:kAgeKey dictionary:dictionary];
	if (age && age.integerValue > 0)
	{
		customParams.age = age;
	}
	NSString *vkId = [MTRGMyTargetAdapterUtils stringForKey:kVkIdKey dictionary:dictionary];
	if (vkId && vkId.length > 0)
	{
		customParams.vkId = vkId;
	}
	NSString *okId = [MTRGMyTargetAdapterUtils stringForKey:kOkIdKey dictionary:dictionary];
	if (okId && okId.length > 0)
	{
		customParams.okId = okId;
	}
}

#pragma mark - private

+ (nullable NSNumber *)numberForKey:(NSString *)key dictionary:(NSDictionary *)dictionary
{
	id value = dictionary[key];
	return (value && [value isKindOfClass:[NSNumber class]]) ? (NSNumber *)value : nil;
}

+ (nullable NSString *)stringForKey:(NSString *)key dictionary:(NSDictionary *)dictionary
{
	id value = dictionary[key];
	return (value && [value isKindOfClass:[NSString class]]) ? (NSString *)value : nil;
}

+ (BOOL)boolForKey:(NSString *)key dictionary:(NSDictionary *)dictionary
{
	id value = [dictionary objectForKey:key];
	if (!value) return NO;

	if ([value isKindOfClass:[NSNumber class]])
	{
		NSNumber *numberValue = (NSNumber *)value;
		return numberValue.boolValue;
	}
	if ([value isKindOfClass:[NSString class]])
	{
		NSString *stringValue = (NSString *)value;
		return stringValue.boolValue;
	}
	return NO;
}

@end
