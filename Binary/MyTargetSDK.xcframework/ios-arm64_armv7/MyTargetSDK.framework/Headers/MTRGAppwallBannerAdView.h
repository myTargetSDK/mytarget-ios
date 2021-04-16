//
//  MTRGAppwallBannerAdView.h
//  myTargetSDK 5.11.0
//
//  Created by Anton Bulankin on 15.01.15.
//  Copyright (c) 2015 Mail.ru Group. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MTRGNativeAppwallBanner;

NS_ASSUME_NONNULL_BEGIN

@class MTRGAppwallBannerAdView;

@protocol MTRGAppwallBannerAdViewDelegate <NSObject>

- (void)appwallBannerAdViewOnClickWithView:(MTRGAppwallBannerAdView *)bannerAdView;

- (void)appwallBannerAdViewOnCancelSelectWithView:(MTRGAppwallBannerAdView *)bannerAdView;

@optional

- (BOOL)appwallBannerAdViewAllowStartSelect:(MTRGAppwallBannerAdView *)bannerAdView;

@end


@interface MTRGAppwallBannerAdView : UIView

@property(nonatomic, weak, nullable) id <MTRGAppwallBannerAdViewDelegate> delegate;
@property(nonatomic, nullable) MTRGNativeAppwallBanner *appwallBanner;

@property(nonatomic) UIEdgeInsets titleMargins;
@property(nonatomic) UIEdgeInsets descriptionMargins;
@property(nonatomic) UIEdgeInsets iconMargins;
@property(nonatomic) UIEdgeInsets ratingStarsMargins;
@property(nonatomic) UIEdgeInsets votesMargins;
@property(nonatomic) UIEdgeInsets gotoAppMargins;
@property(nonatomic) UIEdgeInsets crossNotifMargins;
@property(nonatomic) UIEdgeInsets coinsViewMargins;
@property(nonatomic) UIEdgeInsets coinsTextMargins;

@property(nonatomic) UIEdgeInsets paddings;

@property(nonatomic, nullable) UIColor *touchColor;
@property(nonatomic, nullable) UIColor *normalColor;

@property(nonatomic) CGSize iconSize;
@property(nonatomic) CGSize ratingSize;
@property(nonatomic) CGSize coinViewSize;
@property(nonatomic) CGSize coinSize;
@property(nonatomic) CGSize gotoAppSize;
@property(nonatomic) CGSize statusImageSize;
@property(nonatomic) CGSize bubbleSize;
@property(nonatomic) CGSize crossNotifIconSize;

@property(nonatomic) CGPoint bubblePosition;

@property(nonatomic, nullable) UIFont *titleFont;
@property(nonatomic, nullable) UIFont *descriptionFont;
@property(nonatomic, nullable) UIFont *votesFont;
@property(nonatomic, nullable) UIFont *coinFont;

@property(nonatomic) NSInteger descriptionNumberOfLines;
@property(nonatomic) NSLineBreakMode descriptionLineBreakMode;

@property(nonatomic, nullable) UIColor *titleColor UI_APPEARANCE_SELECTOR;
@property(nonatomic, nullable) UIColor *descriptionColor UI_APPEARANCE_SELECTOR;
@property(nonatomic, nullable) UIColor *votesColor UI_APPEARANCE_SELECTOR;

@property(nonatomic) BOOL showTopBorder;
@property(nonatomic) BOOL showGotoAppIcon;
@property(nonatomic) BOOL showRating;
@property(nonatomic) BOOL showStatusIcon;
@property(nonatomic) BOOL showBubbleIcon;
@property(nonatomic) BOOL showCoins;
@property(nonatomic) BOOL showCrossNotifIcon;

+ (instancetype)create;

- (instancetype)init NS_UNAVAILABLE;

- (void)setAppwallBanner:(MTRGNativeAppwallBanner *)appwallBanner;

- (void)setFixedWidth:(CGFloat)width;

- (void)removeNotification;

@end

NS_ASSUME_NONNULL_END
