//
//  MTRGNativeBannerAdView.h
//  myTargetSDK 5.11.0
//
//  Created by Anton Bulankin on 05.12.14.
//  Copyright (c) 2014 Mail.ru Group. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MTRGNativeBanner;
@class MTRGStarsRatingLabel;

@class MTRGIconAdView;

NS_ASSUME_NONNULL_BEGIN

@interface MTRGNativeBannerAdView : UIView

@property(nonatomic, nullable) MTRGNativeBanner *banner;
@property(nonatomic, nullable) UIColor *backgroundColor;
@property(nonatomic, readonly, nullable) UILabel *ageRestrictionsLabel;
@property(nonatomic, readonly, nullable) UILabel *adLabel;

@property(nonatomic, readonly, nullable) MTRGIconAdView *iconAdView;
@property(nonatomic, readonly, nullable) UILabel *domainLabel;
@property(nonatomic, readonly, nullable) UILabel *disclaimerLabel;
@property(nonatomic, readonly, nullable) MTRGStarsRatingLabel *ratingStarsLabel;
@property(nonatomic, readonly, nullable) UILabel *votesLabel;
@property(nonatomic, readonly, nullable) UIView *buttonView;
@property(nonatomic, readonly, nullable) UILabel *buttonToLabel;
@property(nonatomic, readonly, nullable) UILabel *titleLabel;

@property(nonatomic) UIEdgeInsets contentMargins;
@property(nonatomic) UIEdgeInsets adLabelMargins;
@property(nonatomic) UIEdgeInsets ageRestrictionsMargins;
@property(nonatomic) UIEdgeInsets titleMargins;
@property(nonatomic) UIEdgeInsets domainMargins;
@property(nonatomic) UIEdgeInsets disclaimerMargins;
@property(nonatomic) UIEdgeInsets iconMargins;
@property(nonatomic) UIEdgeInsets ratingStarsMargins;
@property(nonatomic) UIEdgeInsets votesMargins;
@property(nonatomic) UIEdgeInsets buttonMargins;
@property(nonatomic) UIEdgeInsets buttonCaptionMargins;

+ (instancetype)create;

@end

NS_ASSUME_NONNULL_END
