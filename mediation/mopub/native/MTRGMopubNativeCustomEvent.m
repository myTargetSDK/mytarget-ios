//
//  MTRGMopubNativeCustomEvent.m
//  myTargetSDKMopubMediation
//
//  Created by Anton Bulankin on 27.01.15.
//  Copyright (c) 2015 Mail.ru Group. All rights reserved.
//

#import "MTRGMopubNativeCustomEvent.h"
#import <MyTargetSDK/MyTargetSDK.h>
#import "MTRGMopubNativeAdAdapter.h"
#import "MPNativeAd.h"


@interface MTRGMopubNativeCustomEvent () <MTRGNativeAdDelegate>

@end

@implementation MTRGMopubNativeCustomEvent

- (void)requestAdWithCustomEventInfo:(NSDictionary *)info
{
	NSUInteger slotId;
	if (info)
	{
		id slotIdValue = [info valueForKey:@"slotId"];
		slotId = [self parseSlotId:slotIdValue];
	}
	MTRGNativeAd *nativeAd = [[MTRGNativeAd alloc] initWithSlotId:slotId];
	nativeAd.delegate = self;
	[nativeAd.customParams setCustomParam:kMTRGCustomParamsMediationMopub forKey:kMTRGCustomParamsMediationKey];
	[nativeAd load];
}

- (NSUInteger)parseSlotId:(id)slotIdValue
{
	if ([slotIdValue isKindOfClass:[NSString class]])
	{
		NSNumberFormatter *formatString = [[NSNumberFormatter alloc] init];
		NSNumber *slotIdNum = [formatString numberFromString:slotIdValue];
		return slotIdNum ? [slotIdNum unsignedIntegerValue] : 0;
	}
	else if ([slotIdValue isKindOfClass:[NSNumber class]])
		return [((NSNumber *) slotIdValue) unsignedIntegerValue];
	return 0;
}

#pragma marl - MTRGNativeAdDelegate

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
	NSString *errorTitle = reason ? [NSString stringWithFormat:@"No ad: %@", reason] : @"No ad";
	NSDictionary *userInfo = @{NSLocalizedDescriptionKey : errorTitle};
	NSError *error = [NSError errorWithDomain:@"MyTargetMediation" code:1001 userInfo:userInfo];

	[self.delegate nativeCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)onAdClickWithNativeAd:(MTRGNativeAd *)nativeAd
{
	// empty
}

- (void)onShowModalWithNativeAd:(MTRGNativeAd *)nativeAd
{
	// empty
}

- (void)onDismissModalWithNativeAd:(MTRGNativeAd *)nativeAd
{
	// empty
}

- (void)onLeaveApplicationWithNativeAd:(MTRGNativeAd *)nativeAd
{
	// empty
}

@end
