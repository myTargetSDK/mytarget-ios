//
//  MTRGPromoCardViewProtocol.h
//  myTargetSDK 5.11.0
//
//  Created by Andrey Seredkin on 20.10.16.
//  Copyright © 2016 Mail.Ru Group. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MTRGMediaAdView;

@protocol MTRGPromoCardViewProtocol <NSObject>

@required

@property(nonatomic, readonly) UILabel *titleLabel;
@property(nonatomic, readonly) UILabel *descriptionLabel;
@property(nonatomic, readonly) UILabel *ctaButtonLabel;
@property(nonatomic, readonly) MTRGMediaAdView *mediaAdView;

- (CGFloat)heightWithCardWidth:(CGFloat)width;

@end

NS_ASSUME_NONNULL_END
