//
//  MTRGNativeAppwallBanner.h
//  myTargetSDK 5.11.0
//
// Created by Timur on 4/12/18.
// Copyright (c) 2018 Mail.Ru Group. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MTRGImageData;

NS_ASSUME_NONNULL_BEGIN

@interface MTRGNativeAppwallBanner : NSObject

@property(nonatomic, readonly, copy) NSString *bannerId;
@property(nonatomic, readonly, copy, nullable) NSString *status;
@property(nonatomic, readonly, copy, nullable) NSString *title;
@property(nonatomic, readonly, copy, nullable) NSString *descriptionText;
@property(nonatomic, readonly, copy, nullable) NSString *paidType;
@property(nonatomic, readonly, copy, nullable) NSString *mrgsId;
@property(nonatomic, readonly) BOOL subitem;
@property(nonatomic, readonly) BOOL isAppInstalled;
@property(nonatomic, readonly) BOOL main;
@property(nonatomic, readonly) BOOL requireCategoryHighlight;
@property(nonatomic, readonly) BOOL banner;
@property(nonatomic, readonly) BOOL requireWifi;
@property(nonatomic, readonly) BOOL itemHighlight;
@property(nonatomic, readonly, nullable) NSNumber *rating;
@property(nonatomic, readonly) NSUInteger votes;
@property(nonatomic, readonly) NSUInteger coins;
@property(nonatomic, readonly, nullable) UIColor *coinsBgColor;
@property(nonatomic, readonly, nullable) UIColor *coinsTextColor;
@property(nonatomic, readonly, nullable) MTRGImageData *icon;
@property(nonatomic, readonly, nullable) MTRGImageData *statusIcon;
@property(nonatomic, readonly, nullable) MTRGImageData *coinsIcon;
@property(nonatomic, readonly, nullable) MTRGImageData *crossNotifIcon;
@property(nonatomic, readonly, nullable) MTRGImageData *bubbleIcon;
@property(nonatomic, readonly, nullable) MTRGImageData *gotoAppIcon;
@property(nonatomic, readonly, nullable) MTRGImageData *itemHighlightIcon;

@property(nonatomic) BOOL hasNotification;

@end

NS_ASSUME_NONNULL_END
