//
//  MTRGAdSize.h
//  myTargetSDK 5.11.0
//
//  Created by Andrey Seredkin on 01.07.2020.
//  Copyright © 2020 Mail.ru Group. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger
{
	MTRGAdSizeType320x50,
	MTRGAdSizeType300x250,
	MTRGAdSizeType728x90,
	MTRGAdSizeTypeAdaptive
} MTRGAdSizeType;

@interface MTRGAdSize : NSObject

@property(nonatomic, readonly) CGSize size;
@property(nonatomic, readonly) MTRGAdSizeType type;

+ (instancetype)adSize320x50;
+ (instancetype)adSize300x250;
+ (instancetype)adSize728x90;
+ (instancetype)adSizeForCurrentOrientation;
+ (instancetype)adSizeForCurrentOrientationForWidth:(CGFloat)width;
+ (instancetype)adSizeForCurrentOrientationForWidth:(CGFloat)width maxHeight:(CGFloat)maxHeight;

@end

NS_ASSUME_NONNULL_END
