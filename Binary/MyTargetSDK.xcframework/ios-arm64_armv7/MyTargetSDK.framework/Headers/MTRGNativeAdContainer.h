//
//  MTRGNativeAdContainer.h
//  myTargetSDK 5.11.0
//
//  Created by Andrey Seredkin on 21/05/2019.
//  Copyright © 2019 Mail.Ru Group. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MTRGNativeAdContainer : UIView

@property(nonatomic, nullable) UIView *adView;
@property(nonatomic, nullable) UIView *advertisingView;
@property(nonatomic, nullable) UIView *ageRestrictionsView;
@property(nonatomic, nullable) UIView *titleView;
@property(nonatomic, nullable) UIView *descriptionView;
@property(nonatomic, nullable) UIView *categoryView;
@property(nonatomic, nullable) UIView *iconView;
@property(nonatomic, nullable) UIView *mediaView;
@property(nonatomic, nullable) UIView *ratingView;
@property(nonatomic, nullable) UIView *votesView;
@property(nonatomic, nullable) UIView *domainView;
@property(nonatomic, nullable) UIView *disclaimerView;
@property(nonatomic, nullable) UIView *ctaView;

+ (instancetype)createWithAdView:(UIView *)adView;

@end

NS_ASSUME_NONNULL_END
