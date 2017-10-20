//
//  MTRGAdmobNativeCustomEvent.m
//  MyTargetMediationApp
//
//  Created by Andrey Seredkin on 13.03.17.
//  Copyright © 2017 Mail.ru Group. All rights reserved.
//

@import GoogleMobileAds;
@import MyTargetSDK;

#import "MTRGAdmobNativeCustomEvent.h"
#import "MTRGMediatedNativeAd.h"

@interface MTRGAdmobNativeCustomEvent () <GADCustomEventNativeAd, MTRGNativeAdDelegate, GADMediatedNativeAdDelegate>

@end

@implementation MTRGAdmobNativeCustomEvent
{
	MTRGNativeAd *_nativeAd;
	id<GADMediatedNativeAd> _mediatedNativeAd;
	__weak id<GADCustomEventNativeAdDelegate> _delegate;
}

- (id <GADCustomEventNativeAdDelegate>)delegate
{
	return _delegate;
}

- (void)setDelegate:(id <GADCustomEventNativeAdDelegate>)delegate
{
	_delegate = delegate;
}

- (void)requestNativeAdWithParameter:(NSString *)serverParameter
							 request:(GADCustomEventRequest *)request
							 adTypes:(NSArray *)adTypes
							 options:(NSArray *)options
				  rootViewController:(UIViewController *)rootViewController
{
	if (![adTypes containsObject:kGADAdLoaderAdTypeNativeContent] && ![adTypes containsObject:kGADAdLoaderAdTypeNativeAppInstall])
	{
		NSString *errorDescription = [NSString stringWithFormat:@"Invalid request: [%@]", [adTypes componentsJoinedByString:@", "]];
		NSError *error = [NSError errorWithDomain:@"MyTargetMediation" code:kGADErrorInvalidRequest userInfo:@{NSLocalizedDescriptionKey : errorDescription}];
		[_delegate customEventNativeAd:self didFailToLoadWithError:error];
		return;
	}

	BOOL shouldDownloadImages = NO;
	for (GADNativeAdImageAdLoaderOptions *imageOptions in options)
	{
		if ([imageOptions isKindOfClass:[GADNativeAdImageAdLoaderOptions class]] && !imageOptions.disableImageLoading)
		{
			shouldDownloadImages = YES;
			break;
		}
	}

	NSString *jsonString = [serverParameter copy];
	NSUInteger slotId = [self parseSlotIdFromJsonString:jsonString];

	if (slotId > 0)
	{
		_nativeAd = [[MTRGNativeAd alloc] initWithSlotId:slotId];

		if (request)
		{
			_nativeAd.customParams.gender = [self genderWithAdmobGender:request.userGender];
			_nativeAd.customParams.age = [self ageFromBirthday:request.userBirthday];
		}
		_nativeAd.delegate = self;
		_nativeAd.autoLoadImages = shouldDownloadImages;
		[_nativeAd.customParams setCustomParam:kMTRGCustomParamsMediationAdmob forKey:kMTRGCustomParamsMediationKey];
		[_nativeAd load];
	}
	else
	{
		NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"Options are not correct: slotId not found"};
		NSError *error = [NSError errorWithDomain:@"MyTargetMediation" code:1000 userInfo:userInfo];
		[_delegate customEventNativeAd:self didFailToLoadWithError:error];
	}
}

- (BOOL)handlesUserClicks
{
	return YES;
}

- (BOOL)handlesUserImpressions
{
	return YES;
}

#pragma mark - MTRGNativeAdDelegate

- (void)onLoadWithNativePromoBanner:(MTRGNativePromoBanner *)promoBanner nativeAd:(MTRGNativeAd *)nativeAd
{
	_mediatedNativeAd = [MTRGMediatedNativeAd mediatedNativeAdWithNativePromoBanner:promoBanner delegate:self];
	if (_mediatedNativeAd)
	{
		[_delegate customEventNativeAd:self didReceiveMediatedNativeAd:_mediatedNativeAd];
	}
	else
	{
		NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"Mediated Native Ad is invalid"};
		NSError *error = [NSError errorWithDomain:@"MyTargetMediation" code:1001 userInfo:userInfo];
		[_delegate customEventNativeAd:self didFailToLoadWithError:error];
	}
}

- (void)onNoAdWithReason:(NSString *)reason nativeAd:(MTRGNativeAd *)nativeAd
{
	NSString *errorTitle = reason ? [NSString stringWithFormat:@"No ad: %@", reason] : @"No ad";
	NSDictionary *userInfo = @{NSLocalizedDescriptionKey : errorTitle};
	NSError *error = [NSError errorWithDomain:@"MyTargetMediation" code:1001 userInfo:userInfo];
	[_delegate customEventNativeAd:self didFailToLoadWithError:error];
}

- (void)onAdShowWithNativeAd:(MTRGNativeAd *)nativeAd
{
	if (!_mediatedNativeAd) return;
	[GADMediatedNativeAdNotificationSource mediatedNativeAdDidRecordImpression:_mediatedNativeAd];
}

- (void)onAdClickWithNativeAd:(MTRGNativeAd *)nativeAd
{
	if (!_mediatedNativeAd) return;
	[GADMediatedNativeAdNotificationSource mediatedNativeAdDidRecordClick:_mediatedNativeAd];
}

- (void)onShowModalWithNativeAd:(MTRGNativeAd *)nativeAd
{
	if (!_mediatedNativeAd) return;
	[GADMediatedNativeAdNotificationSource mediatedNativeAdWillPresentScreen:_mediatedNativeAd];
}

- (void)onDismissModalWithNativeAd:(MTRGNativeAd *)nativeAd
{
	if (!_mediatedNativeAd) return;
	[GADMediatedNativeAdNotificationSource mediatedNativeAdDidDismissScreen:_mediatedNativeAd];
}

- (void)onLeaveApplicationWithNativeAd:(MTRGNativeAd *)nativeAd
{
	if (!_mediatedNativeAd) return;
	[GADMediatedNativeAdNotificationSource mediatedNativeAdWillLeaveApplication:_mediatedNativeAd];
}

#pragma mark - GADMediatedNativeAdDelegate

- (void)mediatedNativeAd:(id<GADMediatedNativeAd>)mediatedNativeAd didRenderInView:(UIView *)view viewController:(UIViewController *)viewController
{
	if (!_nativeAd) return;
	[_nativeAd registerView:view withController:viewController];
}

- (void)mediatedNativeAdDidRecordImpression:(id<GADMediatedNativeAd>)mediatedNativeAd
{
	//
}

- (void)mediatedNativeAd:(id<GADMediatedNativeAd>)mediatedNativeAd didRecordClickOnAssetWithName:(NSString *)assetName view:(UIView *)view viewController:(UIViewController *)viewController
{
	//
}

- (void)mediatedNativeAd:(id<GADMediatedNativeAd>)mediatedNativeAd didUntrackView:(UIView *)view
{
	if (!_nativeAd) return;
	[_nativeAd unregisterView];
}

#pragma mark - helpers

- (MTRGGender)genderWithAdmobGender:(GADGender)admobGender
{
	if (admobGender == kGADGenderMale) return MTRGGenderMale;
	if (admobGender == kGADGenderFemale) return MTRGGenderFemale;
	return MTRGGenderUnspecified;
}

- (NSUInteger)parseSlotIdFromJsonString:(NSString *)jsonString
{
	if (!jsonString || ![jsonString isKindOfClass:[NSString class]]) return 0;

	NSError *error = nil;
	NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
	NSDictionary *info = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
	if (!info || error) return 0;

	id slotIdValue = [info valueForKey:@"slotId"];
	if (!slotIdValue) return 0;

	NSUInteger slotId = 0;
	if ([slotIdValue isKindOfClass:[NSString class]])
	{
		NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
		NSString *slotIdString = (NSString *)slotIdValue;
		NSNumber *slotIdNumber = [numberFormatter numberFromString:slotIdString];
		slotId = slotIdNumber ? [slotIdNumber unsignedIntegerValue] : 0;
	}
	else if ([slotIdValue isKindOfClass:[NSNumber class]])
	{
		NSNumber *slotIdNumber = (NSNumber *)slotIdValue;
		slotId = [slotIdNumber unsignedIntegerValue];
	}
	return slotId;
}

- (NSNumber *)ageFromBirthday:(NSDate *)birthday
{
	if (!birthday) return nil;
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
	NSDateComponents *components = [calendar components:NSCalendarUnitYear fromDate:birthday toDate:[NSDate date] options:0];
	return [NSNumber numberWithInteger:components.year];
}

@end
