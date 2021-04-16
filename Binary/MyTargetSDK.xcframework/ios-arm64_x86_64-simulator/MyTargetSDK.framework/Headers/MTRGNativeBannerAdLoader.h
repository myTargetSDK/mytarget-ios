//
//  MTRGNativeBannerAdLoader.h
//  myTargetSDK 5.11.0
//
//  Created by Andrey Seredkin on 03/03/2020.
//  Copyright © 2020 Mail.ru Group. All rights reserved.
//

#import <MyTargetSDK/MTRGNativeBannerAd.h>

NS_ASSUME_NONNULL_BEGIN

@interface MTRGNativeBannerAdLoader : MTRGBaseAd

@property(nonatomic) MTRGCachePolicy cachePolicy;
@property(nonatomic) MTRGAdChoicesPlacement adChoicesPlacement;

+ (instancetype)loaderForCount:(NSUInteger)count slotId:(NSUInteger)slotId;

- (instancetype)init NS_UNAVAILABLE;

- (void)loadWithCompletionBlock:(void (^)(NSArray<MTRGNativeBannerAd *> *nativeBannerAds))completionBlock;

@end

NS_ASSUME_NONNULL_END
