//
//  MTRGNativePromoCard.h
//  myTargetSDK 5.11.0
//
//  Created by Andrey Seredkin on 18.10.16.
//  Copyright © 2016 Mail.ru. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MyTargetSDK/MTRGImageData.h>

NS_ASSUME_NONNULL_BEGIN

@interface MTRGNativePromoCard : NSObject

@property(nonatomic, readonly, copy, nullable) NSString *title;
@property(nonatomic, readonly, copy, nullable) NSString *descriptionText;
@property(nonatomic, readonly, copy, nullable) NSString *ctaText;
@property(nonatomic, readonly, nullable) MTRGImageData *image;

@end

NS_ASSUME_NONNULL_END
