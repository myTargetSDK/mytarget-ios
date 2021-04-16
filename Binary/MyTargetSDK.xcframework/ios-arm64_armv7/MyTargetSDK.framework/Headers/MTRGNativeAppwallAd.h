//
//  MTRGNativeAppwallAd.h
//  myTargetSDK 5.11.0
//
// Created by Timur on 4/12/18.
// Copyright (c) 2018 Mail.Ru Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MyTargetSDK/MTRGBaseAd.h>

@class MTRGNativeAppwallAd;
@class MTRGImageData;
@class MTRGNativeAppwallBanner;
@class MTRGAppwallAdView;

NS_ASSUME_NONNULL_BEGIN

@protocol MTRGNativeAppwallAdDelegate <NSObject>

- (void)onLoadWithBanners:(NSArray<MTRGNativeAppwallBanner *> *)banners appwallAd:(MTRGNativeAppwallAd *)appwallAd;

- (void)onNoAdWithReason:(NSString *)reason appwallAd:(MTRGNativeAppwallAd *)appwallAd;

@optional

- (void)onAdClickWithNativeAppwallAd:(MTRGNativeAppwallAd *)appwallAd banner:(MTRGNativeAppwallBanner *)banner;

- (void)onShowModalWithNativeAppwallAd:(MTRGNativeAppwallAd *)appwallAd;

- (void)onDismissModalWithNativeAppwallAd:(MTRGNativeAppwallAd *)appwallAd;

- (void)onLeaveApplicationWithNativeAppwallAd:(MTRGNativeAppwallAd *)appwallAd;

@end

@interface MTRGNativeAppwallAd : MTRGBaseAd

@property(nonatomic, weak, nullable) id <MTRGNativeAppwallAdDelegate> delegate;
@property(nonatomic, readonly) NSArray<MTRGNativeAppwallBanner *> *banners;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *closeButtonTitle;
@property(nonatomic) NSTimeInterval cachePeriodInSec;
@property(nonatomic) BOOL autoLoadImages;

+ (void)loadImage:(MTRGImageData *)imageData toView:(UIImageView *)imageView;

+ (instancetype)nativeAppwallAdWithSlotId:(NSUInteger)slotId;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithSlotId:(NSUInteger)slotId;

- (void)load;

- (void)showWithController:(UIViewController *)controller;

- (void)close;

- (void)registerAppwallAdView:(MTRGAppwallAdView *)appwallAdView withController:(UIViewController *)controller;

- (void)unregisterAppwallAdView;

- (BOOL)hasNotifications;

- (void)handleBannerShow:(MTRGNativeAppwallBanner *)banner;

- (void)handleBannersShow:(NSArray<MTRGNativeAppwallBanner *> *)banners;

- (void)handleBannerClick:(MTRGNativeAppwallBanner *)banner withController:(UIViewController *)controller;

@end

NS_ASSUME_NONNULL_END
