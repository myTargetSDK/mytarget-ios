//
//  MTRGMopubInterstitialCustomEvent.m
//  myTargetSDKMopubMediation
//
//  Created by Anton Bulankin on 16.02.15.
//  Copyright (c) 2015 Mail.ru Group. All rights reserved.
//

#import "MTRGMopubInterstitialCustomEvent.h"
#import <MyTargetSDK/MyTargetSDK.h>

@interface MTRGMopubInterstitialCustomEvent () <MTRGInterstitialAdDelegate>

@end

@implementation MTRGMopubInterstitialCustomEvent
{
	MTRGInterstitialAd *_interstitialAd;
	BOOL _alreadyDisappear;
}

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
	_alreadyDisappear = NO;
	NSUInteger slotId;

	if (info)
	{
		id slotIdValue = [info valueForKey:@"slotId"];
		slotId = [self parseSlotId:slotIdValue];
	}

	if (slotId)
	{
		_interstitialAd = [[MTRGInterstitialAd alloc] initWithSlotId:slotId];
		_interstitialAd.delegate = self;
		[_interstitialAd.customParams setCustomParam:kMTRGCustomParamsMediationMopub forKey:kMTRGCustomParamsMediationKey];
		[_interstitialAd load];
	}
	else
	{
		NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"Options is not correct: slotId not found"};
		NSError *error = [NSError errorWithDomain:@"MyTargetMediation" code:1000 userInfo:userInfo];
		[self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];

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

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController
{
	[_interstitialAd showWithController:rootViewController];
	[self.delegate trackImpression];
}

- (BOOL)enableAutomaticImpressionAndClickTracking
{
	return NO;
}

- (void)disappear
{
	if (!_alreadyDisappear)
	{
		[self.delegate interstitialCustomEventDidDisappear:self];
		_alreadyDisappear = YES;
	}
}

#pragma mark - MTRGInterstitialAdDelegate

- (void)onLoadWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd
{
	[self.delegate interstitialCustomEvent:self didLoadAd:nil];
}

- (void)onNoAdWithReason:(NSString *)reason interstitialAd:(MTRGInterstitialAd *)interstitialAd
{
	NSString *errorTitle = reason ? [NSString stringWithFormat:@"No ad: %@", reason] : @"No ad";
	NSDictionary *userInfo = @{NSLocalizedDescriptionKey : errorTitle};
	NSError *error = [NSError errorWithDomain:@"MyTargetMediation" code:1001 userInfo:userInfo];
	[self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)onClickWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd
{
	[self.delegate trackClick];
	[self disappear];
}

- (void)onCloseWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd
{
	[self disappear];
}

- (void)onVideoCompleteWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd
{
	// empty
}

- (void)onDisplayWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd
{
	[self.delegate interstitialCustomEventDidAppear:self];
}

- (void)onLeaveApplicationWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd
{
	[self.delegate interstitialCustomEventWillLeaveApplication:self];
}

@end
