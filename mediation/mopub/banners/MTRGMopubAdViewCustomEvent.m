//
//  MTRGMopubAdViewCustomEvent.m
//  myTargetSDKMopubMediation
//
//  Created by Anton Bulankin on 12.03.15.
//  Copyright (c) 2015 Mail.ru Group. All rights reserved.
//

#import <MyTargetSDK/MyTargetSDK.h>
#import "MTRGMopubAdViewCustomEvent.h"
#import "MTRGMyTargetAdapterUtils.h"

@interface MTRGMopubAdViewCustomEvent () <MTRGAdViewDelegate>

@end

@implementation MTRGMopubAdViewCustomEvent
{
	MTRGAdView *_adView;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"
- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info
{
	[self requestAdWithSize:size customEventInfo:info adMarkup:@""];
}
#pragma clang diagnostic pop

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup
{
	id <MPBannerCustomEventDelegate> delegate = self.delegate;
	UIViewController *ownerViewController = delegate ? [delegate viewControllerForPresentingModalView] : nil;
	NSUInteger slotId = [MTRGMyTargetAdapterUtils parseSlotIdFromInfo:info];

	if (slotId > 0)
	{
		[MTRGMyTargetAdapterUtils setupConsent];
		
		MTRGAdSize adSize = MTRGAdSize_320x50;
		if (size.width == 300 && size.height == 250)
		{
			adSize = MTRGAdSize_300x250;
		}
		else if (size.width == 728 && size.height == 90)
		{
			adSize = MTRGAdSize_728x90;
		}

		_adView = [[MTRGAdView alloc] initWithSlotId:slotId withRefreshAd:NO adSize:adSize];
		_adView.viewController = ownerViewController;
		_adView.delegate = self;
		[_adView.customParams setCustomParam:kMTRGCustomParamsMediationMopub forKey:kMTRGCustomParamsMediationKey];
		[_adView load];
	}
	else if (delegate)
	{
		NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : @"Options is not correct: slotId not found" };
		NSError *error = [NSError errorWithDomain:@"MyTargetMediation" code:1000 userInfo:userInfo];
		[delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
	}
}

#pragma mark - MTRGAdViewDelegate

- (void)onLoadWithAdView:(MTRGAdView *)adView
{
	id <MPBannerCustomEventDelegate> delegate = self.delegate;
	if (!delegate) return;
	[delegate bannerCustomEvent:self didLoadAd:adView];
	[delegate trackImpression];
}

- (void)onNoAdWithReason:(NSString *)reason adView:(MTRGAdView *)adView
{
	id <MPBannerCustomEventDelegate> delegate = self.delegate;
	if (!delegate) return;
	NSString *errorTitle = reason ? [NSString stringWithFormat:@"No ad: %@", reason] : @"No ad";
	NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : errorTitle };
	NSError *error = [NSError errorWithDomain:@"MyTargetMediation" code:1001 userInfo:userInfo];
	[delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)onAdClickWithAdView:(MTRGAdView *)adView
{
	id <MPBannerCustomEventDelegate> delegate = self.delegate;
	if (!delegate) return;
	[delegate trackClick];
}

- (void)onShowModalWithAdView:(MTRGAdView *)adView
{
	id <MPBannerCustomEventDelegate> delegate = self.delegate;
	if (!delegate) return;
	[delegate bannerCustomEventWillBeginAction:self];
}

- (void)onDismissModalWithAdView:(MTRGAdView *)adView
{
	id <MPBannerCustomEventDelegate> delegate = self.delegate;
	if (!delegate) return;
	[delegate bannerCustomEventDidFinishAction:self];
}

- (void)onLeaveApplicationWithAdView:(MTRGAdView *)adView
{
	id <MPBannerCustomEventDelegate> delegate = self.delegate;
	if (!delegate) return;
	[delegate bannerCustomEventWillLeaveApplication:self];
}

@end
