//
//  MTRGAdmobInterstitialCustomEvent.m
//  myTargetSDKAdmobMediation
//
//  Created by Anton Bulankin on 20.02.15.
//  Copyright (c) 2015 Mail.ru Group. All rights reserved.
//

#import "MTRGAdmobInterstitialCustomEvent.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <MyTargetSDK/MyTargetSDK.h>

@interface MTRGAdmobInterstitialCustomEvent () <GADCustomEventInterstitial>
@end

@interface MTRGAdmobInterstitialCustomEvent () <MTRGInterstitialAdDelegate>
@end

@implementation MTRGAdmobInterstitialCustomEvent
{
	id <GADCustomEventInterstitialDelegate> _delegate;
	MTRGInterstitialAd *_interstitialAd;
	BOOL _allowShow;
	BOOL _isStarted;
}

- (instancetype)init
{
	self = [super init];
	if (self)
	{
		_allowShow = NO;
		_isStarted = NO;
	}
	return self;
}

- (MTRGGender)MTRGGenderWithAdmobGender:(GADGender)admobGender
{
	if (admobGender == kGADGenderMale) return MTRGGenderMale;
	if (admobGender == kGADGenderFemale) return MTRGGenderFemale;
	return MTRGGenderUnspecified;
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

- (NSNumber *)ageFromBirthday:(NSDate *)birthday
{
	if (!birthday) return nil;

	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *components = [calendar components:NSYearCalendarUnit
	                                           fromDate:birthday
	                                             toDate:[NSDate date]
	                                            options:0];
	return [NSNumber numberWithInteger:components.year];
}

- (void)requestInterstitialAdWithParameter:(NSString *)serverParameter
                                     label:(NSString *)serverLabel
                                   request:(GADCustomEventRequest *)request
{
	_allowShow = NO;
	NSString *jsonString = [serverParameter copy];
	NSUInteger slotId;
	if (jsonString && [jsonString isKindOfClass:[NSString class]])
	{

		NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
		NSError *error;
		NSDictionary *info = [NSJSONSerialization JSONObjectWithData:jsonData
		                                                     options:0
		                                                       error:&error];
		if (info)
		{
			id slotIdValue = [info valueForKey:@"slotId"];
			slotId = [self parseSlotId:slotIdValue];
		}
	}
	if (slotId)
	{
		_interstitialAd = [[MTRGInterstitialAd alloc] initWithSlotId:slotId];
		_interstitialAd.delegate = self;
		if (request)
		{
			_interstitialAd.customParams.gender = [self MTRGGenderWithAdmobGender:request.userGender];
			_interstitialAd.customParams.age = [self ageFromBirthday:request.userBirthday];
		}
		[_interstitialAd.customParams setCustomParam:kMTRGCustomParamsMediationAdmob forKey:kMTRGCustomParamsMediationKey];
		[_interstitialAd load];
	}
	else
	{
		NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"Options is not correct: slotId not found"};
		NSError *error = [NSError errorWithDomain:@"MyTargetMediation" code:1000 userInfo:userInfo];
		[self.delegate customEventInterstitial:self didFailAd:error];
	}
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController
{
	if (!_allowShow) return;
	[self.delegate customEventInterstitialWillPresent:self];
	[_interstitialAd showWithController:rootViewController];
	_isStarted = YES;
}

- (id <GADCustomEventInterstitialDelegate>)delegate
{
	return _delegate;
}

- (void)setDelegate:(id <GADCustomEventInterstitialDelegate>)delegate
{
	_delegate = delegate;
}

#pragma mark -- MTRGInterstitialAdDelegate

- (void)onLoadWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd
{
	_allowShow = YES;
	[self.delegate customEventInterstitialDidReceiveAd:self];
}

- (void)onNoAdWithReason:(NSString *)reason interstitialAd:(MTRGInterstitialAd *)interstitialAd
{
	NSString *errorTitle = reason ? [NSString stringWithFormat:@"No ad: %@", reason] : @"No ad";
	NSDictionary *userInfo = @{NSLocalizedDescriptionKey : errorTitle};
	NSError *error = [NSError errorWithDomain:@"MyTargetMediation" code:1001 userInfo:userInfo];
	[self.delegate customEventInterstitial:self didFailAd:error];
}

- (void)onClickWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd
{
	[self.delegate customEventInterstitialWasClicked:self];
}

- (void)onCloseWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd
{
	[self.delegate customEventInterstitialDidDismiss:self];
}

- (void)onVideoCompleteWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd
{
	// empty
}

- (void)onDisplayWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd
{
	// empty
}

- (void)onLeaveApplicationWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd
{
	[self.delegate customEventInterstitialWillLeaveApplication:self];
}

@end
