//
//  MTRGMopubNativeCustomEvent.m
//  myTargetSDKMopubMediation
//
//  Created by Anton Bulankin on 27.01.15.
//  Copyright (c) 2015 Mail.ru Group. All rights reserved.
//

#import <MyTargetSDK/MyTargetSDK.h>
#import "MTRGMopubNativeCustomEvent.h"
#import "MTRGMopubNativeAdAdapter.h"

#if __has_include("MoPub.h")
	#import "MPNativeAd.h"
#endif

@interface MTRGMopubNativeCustomEvent () <MTRGNativeAdDelegate>

@end

@implementation MTRGMopubNativeCustomEvent

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"
- (void)requestAdWithCustomEventInfo:(NSDictionary *)info
{
	[self requestAdWithCustomEventInfo:info adMarkup:@""];
}
#pragma clang diagnostic pop

- (void)requestAdWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup
{
	NSUInteger slotId = [self parseSlotIdFromInfo:info];
	id <MPNativeCustomEventDelegate> delegate = self.delegate;

	if (slotId > 0)
	{
		MTRGNativeAd *nativeAd = [[MTRGNativeAd alloc] initWithSlotId:slotId];
		nativeAd.delegate = self;
		[nativeAd.customParams setCustomParam:kMTRGCustomParamsMediationMopub forKey:kMTRGCustomParamsMediationKey];
		[nativeAd load];
	}
	else if (delegate)
	{
		NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"Options is not correct: slotId not found"};
		NSError *error = [NSError errorWithDomain:@"MyTargetMediation" code:1000 userInfo:userInfo];
		[delegate nativeCustomEvent:self didFailToLoadAdWithError:error];
	}
}

#pragma mark - MTRGNativeAdDelegate

- (void)onLoadWithNativePromoBanner:(MTRGNativePromoBanner *)promoBanner nativeAd:(MTRGNativeAd *)nativeAd
{
	MTRGMopubNativeAdAdapter *adapter = [[MTRGMopubNativeAdAdapter alloc] initWithPromoBanner:promoBanner nativeAd:nativeAd];
	MPNativeAd *interfaceAd = [[MPNativeAd alloc] initWithAdAdapter:adapter];

	NSMutableArray<NSURL *> *images = [NSMutableArray<NSURL *> new];
	if (promoBanner.icon)
	{
		NSURL *icon = [NSURL URLWithString:promoBanner.icon.url];
		[images addObject:icon];
	}
	if (promoBanner.image)
	{
		NSURL *image = [NSURL URLWithString:promoBanner.image.url];
		[images addObject:image];
	}

	[self precacheImagesWithURLs:images completionBlock:^(NSArray *errors)
	{
		id <MPNativeCustomEventDelegate> delegate = self.delegate;
		if (!delegate) return;
		[delegate nativeCustomEvent:self didLoadAd:interfaceAd];
	}];
}

- (void)onNoAdWithReason:(NSString *)reason nativeAd:(MTRGNativeAd *)nativeAd
{
	id <MPNativeCustomEventDelegate> delegate = self.delegate;
	if (!delegate) return;
	NSString *errorTitle = reason ? [NSString stringWithFormat:@"No ad: %@", reason] : @"No ad";
	NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : errorTitle };
	NSError *error = [NSError errorWithDomain:@"MyTargetMediation" code:1001 userInfo:userInfo];
	[delegate nativeCustomEvent:self didFailToLoadAdWithError:error];
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

#pragma mark - helpers

- (NSUInteger)parseSlotIdFromInfo:(nullable NSDictionary *)info
{
	if (!info) return 0;

	id slotIdValue = [info valueForKey:@"slotId"];
	if (!slotIdValue) return 0;

	NSUInteger slotId = 0;
	if ([slotIdValue isKindOfClass:[NSString class]])
	{
		NSNumberFormatter *formatString = [[NSNumberFormatter alloc] init];
		NSNumber *slotIdNumber = [formatString numberFromString:slotIdValue];
		slotId = (slotIdNumber && slotIdNumber.integerValue > 0) ? slotIdNumber.unsignedIntegerValue : 0;
	}
	else if ([slotIdValue isKindOfClass:[NSNumber class]])
	{
		NSNumber *slotIdNumber = (NSNumber *)slotIdValue;
		slotId = (slotIdNumber && slotIdNumber.integerValue > 0) ? slotIdNumber.unsignedIntegerValue : 0;
	}
	return slotId;
}

@end
