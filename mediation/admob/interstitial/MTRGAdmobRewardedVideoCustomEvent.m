//
//  MTRGAdmobRewardedVideoCustomEvent.m
//  myTargetSDKAdmobMediation
//
//  Created by Andrey Seredkin on 06.10.16.
//  Copyright © 2016 Mail.ru Group. All rights reserved.
//

@import GoogleMobileAds;
@import MyTargetSDK;

#import "MTRGAdmobRewardedVideoCustomEvent.h"

@interface MTRGAdmobRewardedVideoCustomEvent () <GADMRewardBasedVideoAdNetworkAdapter, MTRGInterstitialAdDelegate>

@property (weak) id<GADMRewardBasedVideoAdNetworkConnector> connector;

@end

@implementation MTRGAdmobRewardedVideoCustomEvent
{
	MTRGInterstitialAd *_interstitialAd;
}

#pragma mark - GADMRewardBasedVideoAdNetworkAdapter

+ (NSString *)adapterVersion
{
	return @"20161006";
}

+ (Class<GADAdNetworkExtras>)networkExtrasClass
{
	return nil;
}

- (instancetype)initWithRewardBasedVideoAdNetworkConnector:(id<GADMRewardBasedVideoAdNetworkConnector>)connector
{
	if (!connector) return nil;

	self = [super init];
	if (self)
	{
		self.connector = connector;
	}
	return self;
}

- (void)setUp
{
	NSDictionary *credentials = self.connector.credentials;
	NSString *parameter = [credentials objectForKey:@"parameter"]; //GADCustomEventParametersServer
	NSUInteger slotId = [self parseSlotIdFromJsonString:parameter];

	if (slotId > 0)
	{
		_interstitialAd = [[MTRGInterstitialAd alloc] initWithSlotId:slotId];
		_interstitialAd.delegate = self;
		[_interstitialAd.customParams setCustomParam:kMTRGCustomParamsMediationAdmob forKey:kMTRGCustomParamsMediationKey];
		[self.connector adapterDidSetUpRewardBasedVideoAd:self];
	}
	else
	{
		NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"Options are not correct: slotId not found"};
		NSError *error = [NSError errorWithDomain:@"MyTargetMediation" code:1000 userInfo:userInfo];
		[self.connector adapter:self didFailToSetUpRewardBasedVideoAdWithError:error];
	}
}

- (void)requestRewardBasedVideoAd
{
	[_interstitialAd load];
}

- (void)presentRewardBasedVideoAdWithRootViewController:(UIViewController *)viewController
{
	[_interstitialAd showWithController:viewController];
}

- (void)stopBeingDelegate
{
	_interstitialAd.delegate = nil;
}

#pragma mark - MTRGInterstitialAdDelegate

- (void)onLoadWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd
{
	[self.connector adapterDidReceiveRewardBasedVideoAd:self];
}

- (void)onNoAdWithReason:(NSString *)reason interstitialAd:(MTRGInterstitialAd *)interstitialAd
{
	NSString *errorTitle = reason ? [NSString stringWithFormat:@"No ad: %@", reason] : @"No ad";
	NSDictionary *userInfo = @{NSLocalizedDescriptionKey : errorTitle};
	NSError *error = [NSError errorWithDomain:@"MyTargetMediation" code:1001 userInfo:userInfo];
	[self.connector adapter:self didFailToLoadRewardBasedVideoAdwithError:error];
}

- (void)onClickWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd
{
	[self.connector adapterDidGetAdClick:self];
}

- (void)onCloseWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd
{
	[self.connector adapterDidCloseRewardBasedVideoAd:self];
}

- (void)onVideoCompleteWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd
{
	NSNumber *amount = @0; //must not be nil
	NSString *rewardType = @""; //must not be nil
	NSDecimalNumber *rewardAmount = [NSDecimalNumber decimalNumberWithDecimal:[amount decimalValue]];
	GADAdReward *adReward = [[GADAdReward alloc] initWithRewardType:rewardType rewardAmount:rewardAmount];
	[self.connector adapter:self didRewardUserWithReward:adReward];
}

- (void)onDisplayWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd
{
	[self.connector adapterDidOpenRewardBasedVideoAd:self];
	[self.connector adapterDidStartPlayingRewardBasedVideoAd:self];
}

- (void)onLeaveApplicationWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd
{
	[self.connector adapterWillLeaveApplication:self];
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
