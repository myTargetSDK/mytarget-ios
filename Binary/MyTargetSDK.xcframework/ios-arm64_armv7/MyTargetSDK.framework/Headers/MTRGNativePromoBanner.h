//
//  MTRGNativePromoBanner.h
//  myTargetSDK 5.11.0
//
// Created by Timur on 2/12/18.
// Copyright (c) 2018 Mail.Ru Group. All rights reserved.
//

#import <MyTargetSDK/MTRGNativeBanner.h>

@class MTRGNativePromoCard;

NS_ASSUME_NONNULL_BEGIN

@interface MTRGNativePromoBanner : MTRGNativeBanner

@property(nonatomic, readonly, copy, nullable) NSString *category;
@property(nonatomic, readonly, copy, nullable) NSString *subcategory;
@property(nonatomic, readonly, nullable) MTRGImageData *image;
@property(nonatomic, readonly) NSArray<MTRGNativePromoCard *> *cards;
@property(nonatomic, readonly) BOOL hasVideo;

@end

NS_ASSUME_NONNULL_END
