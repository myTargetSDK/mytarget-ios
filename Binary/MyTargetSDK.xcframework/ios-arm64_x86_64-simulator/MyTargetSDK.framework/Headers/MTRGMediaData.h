//
//  MTRGMediaData.h
//  myTargetSDK 5.11.0
//
// Created by Timur on 2/9/18.
// Copyright (c) 2018 Mail.Ru Group. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MTRGMediaData : NSObject

@property(nonatomic, readonly, copy) NSString *url;
@property(nonatomic, nullable) id data;
@property(nonatomic) CGSize size;

- (instancetype)initWithUrl:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
