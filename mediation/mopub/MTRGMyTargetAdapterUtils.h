//
//  MTRGMyTargetAdapterUtils.h
//  MyTargetMediationApp
//
//  Created by Andrey Seredkin on 08/06/2020.
//  Copyright © 2020 Mail.ru Group. All rights reserved.
//

#import <Foundation/Foundation.h>

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
