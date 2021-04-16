//
//  MTRGMediationNativeAdBanner.h
//  myTargetSDK 5.11.0
//
//  Created by Andrey Seredkin on 18/04/2019.
//  Copyright © 2019 Mail.Ru Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MyTargetSDK/MTRGNavigationType.h>

@class MTRGImageData;
@class MTRGNativePromoCard;
@class MTRGNativePromoBanner;
@class MTRGNativeBanner;

NS_ASSUME_NONNULL_BEGIN

@interface MTRGMediationNativeAdBanner : NSObject

@property(nonatomic, copy, nullable) NSString *advertisingLabel;
@property(nonatomic, copy, nullable) NSString *ageRestrictions;
@property(nonatomic, copy, nullable) NSString *title;
@property(nonatomic, copy, nullable) NSString *descriptionText;
@property(nonatomic, copy, nullable) NSString *disclaimer;
@property(nonatomic, copy, nullable) NSString *category;
@property(nonatomic, copy, nullable) NSString *subcategory;
@property(nonatomic, copy, nullable) NSString *domain;
@property(nonatomic, copy, nullable) NSString *ctaText;
@property(nonatomic, nullable) NSNumber *rating;
@property(nonatomic) NSUInteger votes;
@property(nonatomic) MTRGNavigationType navigationType;
@property(nonatomic, nullable) MTRGImageData *icon;
@property(nonatomic, nullable) MTRGImageData *image;
@property(nonatomic) NSMutableArray<MTRGNativePromoCard *> *cards;
@property(nonatomic) BOOL hasVideo;

- (MTRGNativePromoBanner *)createNativePromoBanner;

- (MTRGNativeBanner *)createNativeBanner;

@end

NS_ASSUME_NONNULL_END
