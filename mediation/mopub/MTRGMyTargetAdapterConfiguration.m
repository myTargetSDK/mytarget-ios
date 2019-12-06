//
//  MTRGMyTargetAdapterConfiguration.m
//  MyTargetMediationApp
//
//  Created by Andrey Seredkin on 31/05/2019.
//  Copyright © 2019 Mail.ru Group. All rights reserved.
//

#import <MyTargetSDK/MyTargetSDK.h>
#import "MTRGMyTargetAdapterConfiguration.h"

static NSUInteger const kAdapterRevision = 0;
static NSString * const kNetworkName = @"myTarget";

@implementation MTRGMyTargetAdapterConfiguration

+ (void)updateInitializationParameters:(NSDictionary *)parameters
{
	[MTRGMyTargetAdapterConfiguration setCachedInitializationParameters:parameters];
}

- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *, id> * _Nullable)configuration complete:(void(^ _Nullable)(NSError * _Nullable))complete
{
	complete(nil);
}

- (NSString *)adapterVersion
{
	return [NSString stringWithFormat:@"%@.%tu", [MTRGVersion currentVersion], kAdapterRevision];
}

- (nullable NSString *)biddingToken
{
	return nil;
}

- (NSString *)moPubNetworkName
{
	return kNetworkName;
}

- (NSString *)networkSdkVersion
{
	return [MTRGVersion currentVersion];
}

- (nullable NSDictionary<NSString *,NSString *> *)moPubRequestOptions
{
	return nil;
}

@end
