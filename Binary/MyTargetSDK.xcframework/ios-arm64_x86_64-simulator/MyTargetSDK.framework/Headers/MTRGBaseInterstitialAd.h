//
//  MTRGBaseInterstitialAd.h
//  myTargetSDK 5.11.0
//
//  Created by Andrey Seredkin on 31.07.2020.
//  Copyright © 2020 Mail.ru Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MyTargetSDK/MTRGBaseAd.h>

NS_ASSUME_NONNULL_BEGIN

@interface MTRGBaseInterstitialAd : MTRGBaseAd

@property(nonatomic) BOOL mediationEnabled;
@property(nonatomic, readonly, nullable) NSString *adSource;
@property(nonatomic, readonly) float adSourcePriority;

+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)init NS_UNAVAILABLE;

- (void)load;

- (void)loadFromBid:(NSString *)bidId;

- (void)showWithController:(UIViewController *)controller;

- (void)close;

@end

NS_ASSUME_NONNULL_END
