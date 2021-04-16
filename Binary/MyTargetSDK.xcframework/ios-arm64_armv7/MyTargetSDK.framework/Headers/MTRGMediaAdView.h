//
//  MTRGMediaAdView.h
//  myTargetSDK 5.11.0
//
//  Created by Andrey Seredkin on 19.08.16.
//  Copyright © 2016 Mail.ru. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MTRGMediaAdView;

NS_ASSUME_NONNULL_BEGIN

@protocol MTRGMediaAdViewDelegate <NSObject>

- (void)onImageSizeChanged:(MTRGMediaAdView *)mediaAdView;

@end

@interface MTRGMediaAdView : UIView

@property(nonatomic, weak, nullable) id <MTRGMediaAdViewDelegate> delegate;
@property(nonatomic, readonly) CGFloat aspectRatio;
@property(nonatomic, readonly) UIImageView *imageView;
@property(nonatomic, readonly) UIImageView *playImageView;
@property(nonatomic, readonly) UIActivityIndicatorView *activityIndicatorView;

+ (instancetype)create;

@end

NS_ASSUME_NONNULL_END
