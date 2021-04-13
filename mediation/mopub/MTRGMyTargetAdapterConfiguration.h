//
//  MTRGMyTargetAdapterConfiguration.h
//  MediationMopubApp
//
//  Created by Andrey Seredkin on 31/05/2019.
//  Copyright © 2019 Mail.ru Group. All rights reserved.
//

#import <Foundation/Foundation.h>

#if __has_include(<MoPub/MoPub.h>)
	#import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDK/MoPub.h>)
	#import <MoPubSDK/MoPub.h>
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
	#import <MoPubSDKFramework/MoPub.h>
#else
	#import "MPBaseAdapterConfiguration.h"
#endif

NS_ASSUME_NONNULL_BEGIN

__attribute__((objc_subclassing_restricted))
@interface MTRGMyTargetAdapterConfiguration : MPBaseAdapterConfiguration

@property (class, nonatomic, readonly) BOOL isNativeBanner;

@property (nonatomic, copy, readonly) NSString *adapterVersion;
@property (nonatomic, copy, readonly, nullable) NSString *biddingToken;
@property (nonatomic, copy, readonly) NSString *moPubNetworkName;
@property (nonatomic, copy, readonly) NSString *networkSdkVersion;

+ (void)setDebugMode:(BOOL)debugMode;

- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *, id> * _Nullable)configuration complete:(void(^ _Nullable)(NSError * _Nullable))complete;

@end

NS_ASSUME_NONNULL_END
