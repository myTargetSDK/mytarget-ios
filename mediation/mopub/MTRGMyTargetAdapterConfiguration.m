//
//  MTRGMyTargetAdapterConfiguration.m
//  MediationMopubApp
//
//  Created by Andrey Seredkin on 31/05/2019.
//  Copyright © 2019 Mail.ru Group. All rights reserved.
//

#import <MyTargetSDK/MyTargetSDK.h>
#import "MTRGMyTargetAdapterConfiguration.h"
#import "MTRGMyTargetAdapterUtils.h"

#if __has_include("MoPub.h")
	#import "MPLogging.h"
#endif

static NSString * const kNetworkName = @"mytarget";
static NSString * const kNetworkVersion = @"5.9.2";
static NSString * const kAdapterRevision = @"0";

static BOOL _isNativeBanner = NO;

@implementation MTRGMyTargetAdapterConfiguration

+ (void)setDebugMode:(BOOL)debugMode
{
	[MTRGBaseAd setDebugMode:debugMode];
}

+ (BOOL)debugMode
{
	return [MTRGBaseAd isDebugMode];
}

+ (BOOL)isNativeBanner
{
	return _isNativeBanner;
}

- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *, id> * _Nullable)configuration complete:(void(^ _Nullable)(NSError * _Nullable))complete
{

	_isNativeBanner = [MTRGMyTargetAdapterUtils isNativeBannerWithDictionary:configuration];

	// myTargetSDK doesn't require initialization
	MPLogInfo(@"myTargetSDK %@ initialized succesfully.", [MTRGVersion currentVersion]);
	if (complete)
	{
		complete(nil);
	}
}

- (NSString *)adapterVersion
{
	return [NSString stringWithFormat:@"%@.%@", kNetworkVersion, kAdapterRevision];
}

- (nullable NSString *)biddingToken
{
	return nil; // if ad network does not support Advanced Bidding
}

- (NSString *)moPubNetworkName
{
	return kNetworkName; // lowercase String that represents your ad network name
}

- (NSString *)networkSdkVersion
{
	return kNetworkVersion;
}

@end
