//
//  MTRGMopubNativeCustomEvent.m
//  myTargetSDKMopubMediation
//
//  Created by Anton Bulankin on 27.01.15.
//  Copyright (c) 2015 Mail.ru Group. All rights reserved.
//

#import "MTRGMopubNativeCustomEvent.h"
#import "MTRGNativeAd.h"
#import "MTRGMopubNativeAdAdapter.h"
#import "MPNativeAd.h"
#import "MTRGError.h"

@interface MTRGMopubNativeCustomEvent () <MTRGNativeAdDelegate>

@end

@implementation MTRGMopubNativeCustomEvent

- (void)requestAdWithCustomEventInfo:(NSDictionary *)info
{
    NSUInteger slotId;
    if (info){
        id slotIdValue = [info valueForKey:@"slotId"];
        slotId = [self parseSlotId:slotIdValue];
    }
	MTRGNativeAd *nativeAd = [[MTRGNativeAd alloc] initWithSlotId:slotId];
	nativeAd.delegate = self;
	[nativeAd load];
}

-(NSUInteger) parseSlotId:(id)slotIdValue{
    if ([slotIdValue isKindOfClass:[NSString class]])
    {
        NSNumberFormatter *formatString = [[NSNumberFormatter alloc] init];
        NSNumber * slotIdNum = [formatString numberFromString:slotIdValue];
        return slotIdNum ? [slotIdNum unsignedIntegerValue] : 0;
    }
    else if ([slotIdValue isKindOfClass:[NSNumber class]])
        return[((NSNumber*)slotIdValue) unsignedIntegerValue];
    return 0;
}

- (void)onLoadWithNativePromoBanner:(MTRGNativePromoBanner *)promoBanner nativeAd:(MTRGNativeAd *)nativeAd
{
	MTRGMopubNativeAdAdapter *adapter = [[MTRGMopubNativeAdAdapter alloc] initWithPromoBanner:promoBanner nativeAd:nativeAd];
	MPNativeAd *interfaceAd = [[MPNativeAd alloc] initWithAdAdapter:adapter];

	NSMutableArray *imagesUrl = [NSMutableArray new];
	if (promoBanner.icon)
	{
		NSURL *iconUrl = [NSURL URLWithString:promoBanner.icon.url];
		[imagesUrl addObject:iconUrl];
	}
	if (promoBanner.image)
	{
		NSURL *imageUrl = [NSURL URLWithString:promoBanner.image.url];
		[imagesUrl addObject:imageUrl];
	}

	[self precacheImagesWithURLs:imagesUrl completionBlock:^(NSArray *errors)
	{
		[self.delegate nativeCustomEvent:self didLoadAd:interfaceAd];
	}];
}

- (void)onNoAdWithReason:(NSString *)reason nativeAd:(MTRGNativeAd *)nativeAd
{
	NSError *error = nil;
	if (reason)
	{
		MTRGError *mtrgError = [MTRGError errorWithTitle:@"No ad" desc:reason];
		error = [mtrgError asError];
	}
	[self.delegate nativeCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)onAdClickWithNativeAd:(MTRGNativeAd *)nativeAd
{
	//Ничего не делаем
}


@end
