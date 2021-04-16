//
//  MTRGAudioData.h
//  myTargetSDK 5.11.0
//
// Created by Timur on 2/9/18.
// Copyright (c) 2018 Mail.Ru Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MyTargetSDK/MTRGMediaData.h>

NS_ASSUME_NONNULL_BEGIN

@interface MTRGAudioData : MTRGMediaData

@property(nonatomic, readonly) NSUInteger bitrate;

+ (instancetype)audioDataWithUrl:(NSString *)url bitrate:(NSUInteger)bitrate;

@end

NS_ASSUME_NONNULL_END
