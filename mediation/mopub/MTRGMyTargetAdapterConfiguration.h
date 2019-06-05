//
//  MTRGMyTargetAdapterConfiguration.h
//  MyTargetMediationApp
//
//  Created by Andrey Seredkin on 31/05/2019.
//  Copyright © 2019 Mail.ru Group. All rights reserved.
//

#import "MPBaseAdapterConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@interface MTRGMyTargetAdapterConfiguration : MPBaseAdapterConfiguration

@property (nonatomic, copy, readonly) NSString * adapterVersion;
@property (nonatomic, copy, readonly) NSString * biddingToken;
@property (nonatomic, copy, readonly) NSString * moPubNetworkName;
@property (nonatomic, copy, readonly) NSString * networkSdkVersion;

+ (void)updateInitializationParameters:(NSDictionary *)parameters;

- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *, id> * _Nullable)configuration complete:(void(^ _Nullable)(NSError * _Nullable))complete;

@end

NS_ASSUME_NONNULL_END
