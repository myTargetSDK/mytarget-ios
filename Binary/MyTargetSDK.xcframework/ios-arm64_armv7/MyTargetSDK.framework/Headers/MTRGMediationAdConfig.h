//
//  MTRGMediationAdConfig.h
//  myTargetSDK 5.11.0
//
// Copyright (c) 2019 Mail.Ru Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MyTargetSDK/MTRGCustomParams.h>

@class MTRGPrivacy;

NS_ASSUME_NONNULL_BEGIN

@interface MTRGMediationAdConfig : NSObject

@property(nonatomic, readonly, copy) NSString *placementId;
@property(nonatomic, readonly, copy, nullable) NSString *payload;
@property(nonatomic, readonly) NSDictionary<NSString *, NSString *> *serverParams;
@property(nonatomic, readonly, nullable) NSNumber *age;
@property(nonatomic, readonly) MTRGGender gender;
@property(nonatomic, readonly) MTRGPrivacy *privacy;

+ (instancetype)configWithPlacementId:(NSString *)placementId
							  payload:(nullable NSString *)payload
						 serverParams:(NSDictionary<NSString *, NSString *> *)serverParams
								  age:(nullable NSNumber *)age
							   gender:(MTRGGender)gender
							  privacy:(MTRGPrivacy *)privacy;

- (instancetype)init NS_UNAVAILABLE;

@end

@interface MTRGMediationAdConfig (MTRGDeprecated)

@property(nonatomic, readonly) BOOL userConsentSpecified;
@property(nonatomic, readonly) BOOL userConsent;
@property(nonatomic, readonly) BOOL userAgeRestricted;

@end

NS_ASSUME_NONNULL_END
