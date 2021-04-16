//
//  MTRGCustomParams.h
//  myTargetSDK 5.11.0
//
//  Created by Anton Bulankin on 22.12.14.
//  Copyright (c) 2014 Mail.ru Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const kMTRGCustomParamsMediationKey;
extern NSString *const kMTRGCustomParamsMediationAdmob;
extern NSString *const kMTRGCustomParamsMediationMopub;

typedef enum
{
	MTRGGenderUnspecified = -1,
	MTRGGenderUnknown,
	MTRGGenderMale,
	MTRGGenderFemale
} MTRGGender;

@interface MTRGCustomParams : NSObject

@property(nullable) NSNumber *age;
@property(nonatomic) MTRGGender gender;
@property(nonatomic) BOOL isCarPlay;
@property(copy, nullable) NSString *language;

@property(copy, nullable) NSString *email;
@property(copy, nullable) NSString *phone;
@property(copy, nullable) NSString *icqId;
@property(copy, nullable) NSString *okId;
@property(copy, nullable) NSString *vkId;
@property(copy, nullable) NSString *customUserId;

@property(copy, nullable) NSString *mrgsAppId;
@property(copy, nullable) NSString *mrgsUserId;
@property(copy, nullable) NSString *mrgsDeviceId;

+ (instancetype)create;

- (NSDictionary<NSString *, NSString *> *)asDictionary;

- (void)setCustomParam:(nullable NSString *)param forKey:(NSString *)key;

- (nullable NSString *)customParamForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
