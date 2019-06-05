//
//  MTRGMyTargetAdapterConfiguration.m
//  MyTargetMediationApp
//
//  Created by Andrey Seredkin on 31/05/2019.
//  Copyright © 2019 Mail.ru Group. All rights reserved.
//

#import "MTRGMyTargetAdapterConfiguration.h"

@import MyTargetSDK;

static NSUInteger const kAdapterRevision = 0;
static NSString * const kNetworkName = @"myTarget";

@implementation MTRGMyTargetAdapterConfiguration

+ (void)updateInitializationParameters:(NSDictionary *)parameters
{
	[MTRGMyTargetAdapterConfiguration setCachedInitializationParameters:parameters];
}

- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *, id> *)configuration complete:(void(^)(NSError *))complete
{
	complete(nil);
}

- (NSString *)adapterVersion
{
	return [NSString stringWithFormat:@"%@.%tu", [MTRGVersion currentVersion], kAdapterRevision];
}

- (NSString *)biddingToken
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

@end
