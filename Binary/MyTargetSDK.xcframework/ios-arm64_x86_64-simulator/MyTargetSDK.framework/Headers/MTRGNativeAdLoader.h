//
//  MTRGNativeAdLoader.h
//  myTargetSDK 5.11.0
//
//  Created by Andrey Seredkin on 31.05.2018.
//  Copyright © 2018 Mail.Ru Group. All rights reserved.
//

#import <MyTargetSDK/MTRGNativeAd.h>

NS_ASSUME_NONNULL_BEGIN

@interface MTRGNativeAdLoader : MTRGBaseAd

@property(nonatomic) MTRGCachePolicy cachePolicy;
@property(nonatomic) MTRGAdChoicesPlacement adChoicesPlacement;

+ (instancetype)loaderForCount:(NSUInteger)count slotId:(NSUInteger)slotId;

- (instancetype)init NS_UNAVAILABLE;

- (void)loadWithCompletionBlock:(void (^)(NSArray<MTRGNativeAd *> *nativeAds))completionBlock;

@end

NS_ASSUME_NONNULL_END
