//
//  MTRGImageData.h
//  myTargetSDK 5.11.0
//
// Created by Timur on 2/9/18.
// Copyright (c) 2018 Mail.Ru Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MyTargetSDK/MTRGMediaData.h>

NS_ASSUME_NONNULL_BEGIN

@interface MTRGImageData : MTRGMediaData

@property(nonatomic, readonly, nullable) UIImage *image;
@property(nonatomic) BOOL useCache;

+ (void)setCacheCapacity:(NSUInteger)capacityInBytes;

+ (instancetype)imageDataWithUrl:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
