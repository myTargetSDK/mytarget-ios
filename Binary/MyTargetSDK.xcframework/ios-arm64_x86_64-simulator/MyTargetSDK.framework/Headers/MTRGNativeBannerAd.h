//
//  MTRGNativeBannerAd.h
//  myTargetSDK 5.11.0
//
//  Created by Andrey Seredkin on 10/02/2020.
//  Copyright © 2020 Mail.Ru Group. All rights reserved.
//

#import <MyTargetSDK/MTRGBaseAd.h>
#import <MyTargetSDK/MTRGNativeAdProtocol.h>

@class MTRGNativeBannerAd;
@class MTRGNativeBanner;
@class MTRGImageData;

NS_ASSUME_NONNULL_BEGIN

@protocol MTRGNativeBannerAdDelegate <NSObject>

- (void)onLoadWithNativeBanner:(MTRGNativeBanner *)banner nativeBannerAd:(MTRGNativeBannerAd *)nativeBannerAd;

- (void)onNoAdWithReason:(NSString *)reason nativeBannerAd:(MTRGNativeBannerAd *)nativeBannerAd;

@optional

- (void)onAdShowWithNativeBannerAd:(MTRGNativeBannerAd *)nativeBannerAd;

- (void)onAdClickWithNativeBannerAd:(MTRGNativeBannerAd *)nativeBannerAd;

- (void)onShowModalWithNativeBannerAd:(MTRGNativeBannerAd *)nativeBannerAd;

- (void)onDismissModalWithNativeBannerAd:(MTRGNativeBannerAd *)nativeBannerAd;

- (void)onLeaveApplicationWithNativeBannerAd:(MTRGNativeBannerAd *)nativeBannerAd;

@end

@protocol MTRGNativeBannerAdMediaDelegate <NSObject>

- (void)onIconLoadWithNativeBannerAd:(MTRGNativeBannerAd *)nativeBannerAd;

@end

@interface MTRGNativeBannerAd : MTRGBaseAd <MTRGNativeAdProtocol>

@property(nonatomic) MTRGAdChoicesPlacement adChoicesPlacement;
@property(nonatomic, weak, nullable) id <MTRGNativeBannerAdDelegate> delegate;
@property(nonatomic, weak, nullable) id <MTRGNativeBannerAdMediaDelegate> mediaDelegate;
@property(nonatomic, readonly, nullable) MTRGNativeBanner *banner;

+ (instancetype)nativeBannerAdWithSlotId:(NSUInteger)slotId;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithSlotId:(NSUInteger)slotId;

- (void)load;

- (void)loadFromBid:(NSString *)bidId;

- (void)registerView:(UIView *)containerView withController:(UIViewController *)controller;

- (void)registerView:(UIView *)containerView withController:(UIViewController *)controller withClickableViews:(nullable NSArray<UIView *> *)clickableViews;

- (void)unregisterView;

@end

NS_ASSUME_NONNULL_END
