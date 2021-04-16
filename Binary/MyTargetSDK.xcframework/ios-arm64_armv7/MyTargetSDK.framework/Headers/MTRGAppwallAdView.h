//
//  MTRGAppwallAdView.h
//  myTargetSDK 5.11.0
//
// Created by Timur on 4/12/18.
// Copyright (c) 2018 Mail.Ru Group. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MTRGNativeAppwallBanner;

NS_ASSUME_NONNULL_BEGIN

@protocol MTRGAppwallAdViewDelegate <NSObject>

- (void)appwallAdViewOnClickWithBanner:(MTRGNativeAppwallBanner *)banner;

- (void)appwallAdViewOnSlideToBanners:(NSArray<MTRGNativeAppwallBanner *> *)banners;

@end

@interface MTRGAppwallAdView : UIView

@property(nonatomic, weak, nullable) id <MTRGAppwallAdViewDelegate> delegate;

+ (instancetype)appwallAdViewWithBanners:(NSArray<MTRGNativeAppwallBanner *> *)banners;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
