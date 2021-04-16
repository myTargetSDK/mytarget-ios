//
//  MTRGPrivacy.h
//  myTargetSDK 5.11.0
//
//  Created by Andrey Seredkin on 28.05.2018.
//  Copyright © 2018 Mail.Ru Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MTRGPrivacy : NSObject

@property(nonatomic, readonly) BOOL isConsent;
@property(nonatomic, readonly) BOOL userAgeRestricted;
@property(nonatomic, readonly, nullable) NSNumber *userConsent;
@property(nonatomic, readonly, nullable) NSNumber *ccpaUserConsent;
@property(nonatomic, readonly, nullable) NSNumber *iABUserConsent;

+ (instancetype)currentPrivacy;

+ (void)setUserConsent:(BOOL)isConsent;

+ (void)setCcpaUserConsent:(BOOL)isConsent;

+ (void)setIABUserConsent:(BOOL)isConsent;

+ (void)setUserAgeRestricted:(BOOL)isAgeRestricted;

+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
