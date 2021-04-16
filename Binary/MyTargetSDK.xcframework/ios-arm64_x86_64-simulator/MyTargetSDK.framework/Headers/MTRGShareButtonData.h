//
//  MTRGShareButtonData.h
//  myTargetSDK 5.11.0
//
//  Created by Andrey Seredkin on 16/01/2019.
//  Copyright © 2019 Mail.Ru Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MTRGShareButtonData : NSObject

@property(nonatomic, readonly) NSString *name;
@property(nonatomic, readonly) NSString *url;
@property(nonatomic, readonly) NSString *imageUrl;

+ (instancetype)shareButtonWithName:(NSString *)name url:(NSString *)url imageUrl:(NSString *)imageUrl;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
