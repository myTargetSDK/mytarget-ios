//
//  MTRGNativeAdProtocol.h
//  myTargetSDK 5.11.0
//
//  Created by Andrey Seredkin on 10/02/2020.
//  Copyright © 2020 Mail.Ru Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MyTargetSDK/MTRGCachePolicy.h>
#import <MyTargetSDK/MTRGAdChoicesPlacement.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MTRGNativeAdProtocol <NSObject>

@property(nonatomic) MTRGCachePolicy cachePolicy;
@property(nonatomic) MTRGAdChoicesPlacement adChoicesPlacement;
@property(nonatomic) BOOL mediationEnabled;
@property(nonatomic, readonly, nullable) NSString *adSource;
@property(nonatomic, readonly) float adSourcePriority;

- (instancetype)initWithSlotId:(NSUInteger)slotId;

- (void)handleData:(NSString *)data;

- (void)load;

- (void)loadFromBid:(NSString *)bidId;

- (void)registerView:(UIView *)containerView withController:(UIViewController *)controller;

- (void)registerView:(UIView *)containerView withController:(UIViewController *)controller withClickableViews:(nullable NSArray<UIView *> *)clickableViews;

- (void)unregisterView;

@end

NS_ASSUME_NONNULL_END
