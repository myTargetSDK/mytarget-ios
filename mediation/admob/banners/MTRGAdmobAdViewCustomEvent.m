//
//  MTRGAdmobAdViewCustomEvent.m
//  myTargetSDKAdmobMediation
//
//  Created by Anton Bulankin on 13.03.15.
//  Copyright (c) 2015 Mail.ru Group. All rights reserved.
//

@import GoogleMobileAds;
@import MyTargetSDK;

#import "MTRGAdmobAdViewCustomEvent.h"

@interface MTRGAdmobAdViewCustomEvent () <GADCustomEventBanner, MTRGAdViewDelegate>

@end

@implementation MTRGAdmobAdViewCustomEvent
{
	id <GADCustomEventBannerDelegate> _delegate;
	MTRGAdView *_adView;
}

- (MTRGGender)MTRGGenderWithAdmobGender:(GADGender)admobGender
{
	if (admobGender == kGADGenderMale) return MTRGGenderMale;
	if (admobGender == kGADGenderFemale) return MTRGGenderFemale;
	return MTRGGenderUnspecified;
}

- (NSNumber *)ageFromBirthday:(NSDate *)birthday
{
	if (!birthday) return nil;

	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
	NSDateComponents *components = [calendar components:NSCalendarUnitYear
	                                           fromDate:birthday
	                                             toDate:[NSDate date]
	                                            options:0];
	return [NSNumber numberWithInteger:components.year];
}

- (void)requestBannerAd:(GADAdSize)adSize
              parameter:(NSString *)serverParameter
                  label:(NSString *)serverLabel
                request:(GADCustomEventRequest *)request
{

	NSString *jsonString = [serverParameter copy];
	NSUInteger slotId = [self parseSlotIdFromJsonString:jsonString];

	UIViewController *ownerViewController = [_delegate viewControllerForPresentingModalView];

	if (slotId > 0)
	{
		MTRGAdSize adViewSize = MTRGAdSize_320x50;
		if (CGSizeEqualToSize(adSize.size, kGADAdSizeMediumRectangle.size))
		{
			adViewSize = MTRGAdSize_300x250;
		}
		else if (CGSizeEqualToSize(adSize.size, kGADAdSizeLeaderboard.size))
		{
			adViewSize = MTRGAdSize_728x90;
		}

		//Создаем вьюшку
		_adView = [[MTRGAdView alloc] initWithSlotId:slotId withRefreshAd:NO adSize:adViewSize];
		_adView.viewController = ownerViewController;
		if (request)
		{
			_adView.customParams.gender = [self MTRGGenderWithAdmobGender:request.userGender];
			_adView.customParams.age = [self ageFromBirthday:request.userBirthday];
		}
		_adView.delegate = self;
		[_adView.customParams setCustomParam:kMTRGCustomParamsMediationAdmob forKey:kMTRGCustomParamsMediationKey];
		[_adView load];
	}
	else
	{
		NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"Options is not correct: slotId not found"};
		NSError *error = [NSError errorWithDomain:@"MyTargetMediation" code:1000 userInfo:userInfo];
		[_delegate customEventBanner:self didFailAd:error];
	}
}

- (id <GADCustomEventBannerDelegate>)delegate
{
	return _delegate;
}

- (void)setDelegate:(id <GADCustomEventBannerDelegate>)delegate
{
	_delegate = delegate;
}

#pragma mark --- MTRGAdViewDelegate

- (void)onLoadWithAdView:(MTRGAdView *)adView
{
	[_adView start];
	[_delegate customEventBanner:self didReceiveAd:_adView];
}

- (void)onNoAdWithReason:(NSString *)reason adView:(MTRGAdView *)adView
{
	NSString *errorTitle = reason ? [NSString stringWithFormat:@"No ad: %@", reason] : @"No ad";
	NSDictionary *userInfo = @{NSLocalizedDescriptionKey : errorTitle};
	NSError *error = [NSError errorWithDomain:@"MyTargetMediation" code:1001 userInfo:userInfo];
	[_delegate customEventBanner:self didFailAd:error];
}

- (void)onAdClickWithAdView:(MTRGAdView *)adView
{
	[_delegate customEventBannerWasClicked:self];
}

- (void)onShowModalWithAdView:(MTRGAdView *)adView
{
	[_delegate customEventBannerWillPresentModal:self];
}

- (void)onDismissModalWithAdView:(MTRGAdView *)adView
{
	[_delegate customEventBannerDidDismissModal:self];
}

- (void)onLeaveApplicationWithAdView:(MTRGAdView *)adView
{
	[_delegate customEventBannerWillLeaveApplication:self];
}

#pragma mark - helpers

- (NSUInteger)parseSlotIdFromJsonString:(NSString *)jsonString
{
	NSUInteger slotId = 0;

	NSError *error;
	NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
	NSDictionary *info = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
	if (info)
	{
		id slotIdValue = [info valueForKey:@"slotId"];
		if (slotIdValue && [slotIdValue isKindOfClass:[NSString class]])
		{
			NSNumberFormatter *formatString = [[NSNumberFormatter alloc] init];
			NSNumber *slotIdNum = [formatString numberFromString:slotIdValue];
			slotId = slotIdNum ? [slotIdNum unsignedIntegerValue] : 0;
		}
		else if ([slotIdValue isKindOfClass:[NSNumber class]])
		{
			slotId = [((NSNumber *) slotIdValue) unsignedIntegerValue];
		}
	}
	return slotId;
}

@end
