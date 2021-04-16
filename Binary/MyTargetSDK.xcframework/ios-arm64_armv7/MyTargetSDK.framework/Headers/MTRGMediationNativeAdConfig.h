//
//  MTRGMediationNativeAdConfig.h
//  myTargetSDK 5.11.0
//
// Copyright (c) 2019 Mail.Ru Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MyTargetSDK/MTRGMediationAdConfig.h>
#import <MyTargetSDK/MTRGNativeAd.h>

NS_ASSUME_NONNULL_BEGIN

@interface MTRGMediationNativeAdConfig : MTRGMediationAdConfig

@property(nonatomic, readonly) MTRGCachePolicy cachePolicy;
@property(nonatomic, readonly) MTRGAdChoicesPlacement adChoicesPlacement;

+ (instancetype)configWithPlacementId:(NSString *)placementId
							  payload:(nullable NSString *)payload
						 serverParams:(NSDictionary<NSString *, NSString *> *)serverParams
								  age:(nullable NSNumber *)age
							   gender:(MTRGGender)gender
							  privacy:(MTRGPrivacy *)privacy
						  cachePolicy:(MTRGCachePolicy)cachePolicy
				   adChoicesPlacement:(MTRGAdChoicesPlacement)adChoicesPlacement;

@end

@interface MTRGMediationNativeAdConfig (MTRGDeprecated)

@property(nonatomic, readonly) BOOL autoLoadImages;
@property(nonatomic, readonly) BOOL autoLoadVideo;

@end

NS_ASSUME_NONNULL_END
