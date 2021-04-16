//
//  MTRGManager.h
//  myTargetSDK 5.11.0
//
//  Created by Anton Bulankin on 18.09.15.
//  Copyright © 2015 Mail.ru. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MTRGConfig;

NS_ASSUME_NONNULL_BEGIN

@interface MTRGManager : NSObject

@property(class, nonatomic, nonnull) MTRGConfig *sdkConfig;

+ (void)initSdk;

+ (void)setDebugMode:(BOOL)enabled;

+ (NSString *)getBidderToken; // this method should be called on background thread

@end

NS_ASSUME_NONNULL_END
