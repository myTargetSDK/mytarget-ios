//
//  MTRGNativeBanner.h
//  myTargetSDK 5.11.0
//
//  Created by Andrey Seredkin on 10/02/2020.
//  Copyright © 2020 Mail.Ru Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MyTargetSDK/MTRGNavigationType.h>

@class MTRGImageData;

NS_ASSUME_NONNULL_BEGIN

@interface MTRGNativeBanner : NSObject

@property(nonatomic, readonly, copy, nullable) NSString *advertisingLabel;
@property(nonatomic, readonly, copy, nullable) NSString *ageRestrictions;
@property(nonatomic, readonly, copy, nullable) NSString *title;
@property(nonatomic, readonly, copy, nullable) NSString *descriptionText;
@property(nonatomic, readonly, copy, nullable) NSString *disclaimer;
@property(nonatomic, readonly, copy, nullable) NSString *domain;
@property(nonatomic, readonly, copy, nullable) NSString *ctaText;
@property(nonatomic, readonly, nullable) NSNumber *rating;
@property(nonatomic, readonly) NSUInteger votes;
@property(nonatomic, readonly) MTRGNavigationType navigationType;
@property(nonatomic, readonly, nullable) MTRGImageData *icon;

@end

NS_ASSUME_NONNULL_END
