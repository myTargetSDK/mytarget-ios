//
//  MTRGUtils.h
//  myTargetSDK 5.11.0
//
//  Created by Andrey Seredkin on 29/05/2020.
//  Copyright © 2020 Mail.ru Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MTRGUtils : NSObject

+ (NSDictionary<NSString *, NSString *> *)getFingerprintParams; // this method should be called on background thread

+ (void)trackUrl:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
