//
//  MTRGMopubAdViewCustomEvent.m
//  myTargetSDKMopubMediation
//
//  Created by Anton Bulankin on 12.03.15.
//  Copyright (c) 2015 Mail.ru Group. All rights reserved.
//

#import "MTRGMopubAdViewCustomEvent.h"
#import <MyTargetSDK/MyTargetSDK.h>

@interface MTRGMopubAdViewCustomEvent () <MTRGAdViewDelegate>

@end

@implementation MTRGMopubAdViewCustomEvent
{
	MTRGAdView *_adView;
}

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info
{
	NSUInteger slotId;
	if (info)
	{
		id slotIdValue = [info valueForKey:@"slotId"];
		slotId = [self parseSlotId:slotIdValue];

		if ([slotIdValue isKindOfClass:[NSString class]])
		{
			slotId = [slotIdValue integerValue];
		}
	}

	UIViewController *ownerViewController = [self.delegate viewControllerForPresentingModalView];

	if (slotId)
	{
		//Создаем вьюшку
		_adView = [[MTRGAdView alloc] initWithSlotId:slotId withRefreshAd:NO];
		_adView.viewController = ownerViewController;
		_adView.delegate = self;
		[_adView.customParams setCustomParam:kMTRGCustomParamsMediationMopub forKey:kMTRGCustomParamsMediationKey];
		[_adView load];
	}
	else
	{
		NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"Options is not correct: slotId not found"};
		NSError *error = [NSError errorWithDomain:@"MyTargetMediation" code:1000 userInfo:userInfo];
		[self.delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
	}

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

#pragma mark --- MTRGAdViewDelegate

- (void)onLoadWithAdView:(MTRGAdView *)adView
{
	[_adView start];
	[self.delegate bannerCustomEvent:self didLoadAd:_adView];
	[self.delegate trackImpression];
}

- (void)onNoAdWithReason:(NSString *)reason adView:(MTRGAdView *)adView
{
	NSString *errorTitle = reason ? [NSString stringWithFormat:@"No ad: %@", reason] : @"No ad";
	NSDictionary *userInfo = @{NSLocalizedDescriptionKey : errorTitle};
	NSError *error = [NSError errorWithDomain:@"MyTargetMediation" code:1001 userInfo:userInfo];
	[self.delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)onAdClickWithAdView:(MTRGAdView *)adView
{
	[self.delegate trackClick];
}

- (void)onShowModalWithAdView:(MTRGAdView *)adView
{
	[self.delegate bannerCustomEventWillBeginAction:self];
}

- (void)onDismissModalWithAdView:(MTRGAdView *)adView
{
	[self.delegate bannerCustomEventDidFinishAction:self];
}

- (void)onLeaveApplicationWithAdView:(MTRGAdView *)adView
{
	[self.delegate bannerCustomEventWillLeaveApplication:self];
}

@end
