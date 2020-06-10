//
//  MTRGMyTargetAdapterUtils.h
//  MyTargetMediationApp
//
//  Created by Andrey Seredkin on 08/06/2020.
//  Copyright © 2020 Mail.ru Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MTRGMyTargetAdapterUtils : NSObject

+ (void)setupConsent;

+ (NSUInteger)parseSlotIdFromInfo:(nullable NSDictionary *)info;

@end

NS_ASSUME_NONNULL_END
