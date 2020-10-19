//
//  MTRGMyTargetAdapterUtils.h
//  MediationMopubApp
//
//  Created by Andrey Seredkin on 08/06/2020.
//  Copyright © 2020 Mail.ru Group. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef MTRG_MOPUB_CGFLOAT_EQUALS
	#if defined(__LP64__) && __LP64__
		#define MTRG_MOPUB_CGFLOAT_EQUALS(a, b) fabs(a - b) < DBL_EPSILON
	#else
		#define MTRG_MOPUB_CGFLOAT_EQUALS(a, b) fabsf(a - b) < FLT_EPSILON
	#endif
#endif

@class MTRGCustomParams;

NS_ASSUME_NONNULL_BEGIN

__attribute__((objc_subclassing_restricted))
@interface MTRGMyTargetAdapterUtils : NSObject

+ (void)setupConsent;

+ (NSUInteger)parseSlotIdFromInfo:(nullable NSDictionary *)info;

+ (BOOL)isNativeBannerWithDictionary:(nullable NSDictionary *)dictionary;

+ (void)fillCustomParams:(MTRGCustomParams *)customParams dictionary:(nullable NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
