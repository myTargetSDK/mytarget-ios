//
//  MTRGReward.h
//  myTargetSDK 5.11.0
//
//  Created by Andrey Seredkin on 31.07.2020.
//  Copyright © 2020 Mail.ru Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MTRGReward : NSObject

@property(nonatomic, readonly) NSString *type;

+ (instancetype)create;

@end

NS_ASSUME_NONNULL_END
