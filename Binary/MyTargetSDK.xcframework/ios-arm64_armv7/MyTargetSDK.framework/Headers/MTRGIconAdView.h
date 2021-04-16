//
//  MTRGIconAdView.h
//  myTargetSDK 5.11.0
//
//  Created by Andrey Seredkin on 18/02/2020.
//  Copyright © 2020 Mail.ru Group. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MTRGIconAdView : UIView

@property(nonatomic, readonly) UIImageView *imageView;

+ (instancetype)create;

@end

NS_ASSUME_NONNULL_END
