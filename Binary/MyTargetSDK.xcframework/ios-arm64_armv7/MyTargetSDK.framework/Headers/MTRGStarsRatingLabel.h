//
//  MTRGStarsRatingLabel.h
//  myTargetSDK 5.11.0
//
//  Created by Andrey Seredkin on 27.01.17.
//  Copyright © 2017 Mail.Ru Group. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

IB_DESIGNABLE
@interface MTRGStarsRatingLabel : UILabel

@property (nonatomic, nullable) IBInspectable NSNumber *rating;

+ (instancetype)ratingLabelWithRating:(NSNumber *)rating;

- (instancetype)initWithRating:(NSNumber *)rating;

@end

NS_ASSUME_NONNULL_END
