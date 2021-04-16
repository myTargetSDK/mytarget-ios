//
//  MTRGConfig.h
//  myTargetSDK 5.11.0
//
//  Created by Andrey Seredkin on 19.01.2021.
//  Copyright © 2021 Mail.ru Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MTRGConfig;

NS_ASSUME_NONNULL_BEGIN

@interface MTRGConfigBuilder : NSObject

+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)withTrackingLocation:(BOOL)trackingLocation NS_SWIFT_NAME(withTrackingLocation(_:));

- (instancetype)withTestDevices:(nullable NSArray<NSString *> *)testDevices NS_SWIFT_NAME(withTestDevices(_:));

- (MTRGConfig *)build NS_SWIFT_NAME(build());

@end

@interface MTRGConfig : NSObject

@property(nonatomic, readonly) BOOL isTrackLocationEnabled;
@property(nonatomic, readonly, nullable) NSArray<NSString *> *testDevices;

+ (MTRGConfigBuilder *)newBuilder NS_SWIFT_NAME(newBuilder());

+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
