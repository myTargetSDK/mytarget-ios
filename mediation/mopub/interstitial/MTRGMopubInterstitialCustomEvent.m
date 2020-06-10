//
//  MTRGMopubInterstitialCustomEvent.m
//  myTargetSDKMopubMediation
//
//  Created by Anton Bulankin on 16.02.15.
//  Copyright (c) 2015 Mail.ru Group. All rights reserved.
//

#import <MyTargetSDK/MyTargetSDK.h>
#import "MTRGMopubInterstitialCustomEvent.h"
#import "MTRGMyTargetAdapterUtils.h"

@interface MTRGMopubInterstitialCustomEvent () <MTRGInterstitialAdDelegate>

@end

@implementation MTRGMopubInterstitialCustomEvent
{
	MTRGInterstitialAd *_interstitialAd;
	BOOL _alreadyDisappear;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"
- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
	[self requestInterstitialWithCustomEventInfo:info adMarkup:@""];
}
#pragma clang diagnostic pop

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup
{
	_alreadyDisappear = NO;
	NSUInteger slotId = [MTRGMyTargetAdapterUtils parseSlotIdFromInfo:info];
	id <MPInterstitialCustomEventDelegate> delegate = self.delegate;

	if (slotId > 0)
	{
		[MTRGMyTargetAdapterUtils setupConsent];
		
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

@end
