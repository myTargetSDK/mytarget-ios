//
//  MTRGMopubInterstitialCustomEvent.m
//  myTargetSDKMopubMediation
//
//  Created by Anton Bulankin on 16.02.15.
//  Copyright (c) 2015 Mail.ru Group. All rights reserved.
//

@import MyTargetSDK;

#import "MTRGMopubInterstitialCustomEvent.h"

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
	NSUInteger slotId = [self parseSlotIdFromInfo:info];
	id <MPInterstitialCustomEventDelegate> delegate = self.delegate;

	if (slotId > 0)
	{
		_interstitialAd = [[MTRGInterstitialAd alloc] initWithSlotId:slotId];
		_interstitialAd.delegate = self;
		[_interstitialAd.customParams setCustomParam:kMTRGCustomParamsMediationMopub forKey:kMTRGCustomParamsMediationKey];
		[_interstitialAd load];
	}
	else if (delegate)
	{
		NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : @"Options is not correct: slotId not found" };
		NSError *error = [NSError errorWithDomain:@"MyTargetMediation" code:1000 userInfo:userInfo];
		[delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
	}
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController
{
	[_interstitialAd showWithController:rootViewController];
	id <MPInterstitialCustomEventDelegate> delegate = self.delegate;
	if (!delegate) return;
	[delegate trackImpression];
}

- (BOOL)enableAutomaticImpressionAndClickTracking
{
	return NO;
}

- (void)disappear
{
	if (_alreadyDisappear) return;
	_alreadyDisappear = YES;
	id <MPInterstitialCustomEventDelegate> delegate = self.delegate;
	if (!delegate) return;
	[delegate interstitialCustomEventDidDisappear:self];
}

#pragma mark - MTRGInterstitialAdDelegate

- (void)onLoadWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd
{
	id <MPInterstitialCustomEventDelegate> delegate = self.delegate;
	if (!delegate) return;
	[delegate interstitialCustomEvent:self didLoadAd:nil];
}

- (void)onNoAdWithReason:(NSString *)reason interstitialAd:(MTRGInterstitialAd *)interstitialAd
{
	id <MPInterstitialCustomEventDelegate> delegate = self.delegate;
	if (!delegate) return;
	NSString *errorTitle = reason ? [NSString stringWithFormat:@"No ad: %@", reason] : @"No ad";
	NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : errorTitle };
	NSError *error = [NSError errorWithDomain:@"MyTargetMediation" code:1001 userInfo:userInfo];
	[delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)onClickWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd
{
	[self disappear];
	id <MPInterstitialCustomEventDelegate> delegate = self.delegate;
	if (!delegate) return;
	[delegate trackClick];
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
	id <MPInterstitialCustomEventDelegate> delegate = self.delegate;
	if (!delegate) return;
	[delegate interstitialCustomEventDidAppear:self];
}

- (void)onLeaveApplicationWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd
{
	id <MPInterstitialCustomEventDelegate> delegate = self.delegate;
	if (!delegate) return;
	[delegate interstitialCustomEventWillLeaveApplication:self];
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
