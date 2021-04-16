//
//  MTRGBaseAd.h
//  myTargetSDK 5.11.0
//
// Created by Timur on 2/1/18.
// Copyright (c) 2018 Mail.Ru Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MTRGCustomParams;

NS_ASSUME_NONNULL_BEGIN

@interface MTRGBaseAd : NSObject

@property(nonatomic, readonly) MTRGCustomParams *customParams;

+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
