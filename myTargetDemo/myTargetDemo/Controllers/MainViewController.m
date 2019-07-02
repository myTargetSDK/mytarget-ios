//
//  MainViewController.m
//  myTargetDemo
//
//  Created by Anton Bulankin on 23.06.16.
//  Copyright © 2016 Mail.ru Group. All rights reserved.
//

#import "MainViewController.h"
#import "InterstitialAdsViewController.h"
#import "NativeAdsViewController.h"
#import "StandardBannersViewController.h"
#import "InstreamAdsViewController.h"
#import "NewAdUnitController.h"
#import "AdTypes.h"
#import "CustomAdItem.h"
#import "DefaultSlots.h"

#import <MyTargetSDK/MyTargetSDK.h>

@interface MainViewController ()

@end

const int kMainViewControllerItemBanners = 1;
const int kMainViewControllerItemInterstitialAds = 2;
const int kMainViewControllerItemNativeAds = 3;
const int kMainViewControllerItemInstreamAds = 4;
const int kMainViewControllerItemAddUnit = 5;


@interface MainViewController () <NewAdUnitControllerDelegate, MTRGInterstitialAdDelegate>
@end

@implementation MainViewController
{
	NSMutableArray <CustomAdItem *> *_customAdItems;
}

- (instancetype)init
{
	self = [super initWithTitle:@"myTarget Demo"];
	if (self)
	{
		_customAdItems = [CustomAdItem loadCustomAdItemsFromStorage];
	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	[MTRGAdView setDebugMode:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self updateItems];
	[self reload];
}

- (void)didRemoveItem:(AdItem *)adItem
{
	if (adItem.customItem)
	{
		[_customAdItems removeObject:adItem.customItem];
		[CustomAdItem saveAdItemsToStorage:_customAdItems];
	}
}

- (void)updateItems
{
	[self clearItems];

	AdItem *adItem;

	BOOL isIPad = [[[UIDevice currentDevice] model] isEqualToString:@"iPad"];
	NSString *bannersSubtitle = isIPad ? @"320x50, 300x250 and 728x90 banners" : @"320x50 and 300x250 banners";

	adItem = [[AdItem alloc] initWithTitle:@"Banners" info:bannersSubtitle];
	adItem.tag = kMainViewControllerItemBanners;
	[adItem setSlotId:kSlotStandardBanner320x50 type:AdItemSlotIdTypeDefault];
	[adItem setSlotId:kSlotStandardBanner300x250 type:AdItemSlotIdTypeStandard300x250];
	[adItem setSlotId:kSlotStandardBanner728x90 type:AdItemSlotIdTypeStandard728x90];
	adItem.image = [UIImage imageNamed:@"myTarget-banners-320x50.png"];
	[self addAdItem:adItem];

	adItem = [[AdItem alloc] initWithTitle:@"Interstitial Ads" info:@"Fullscreen banners"];
	adItem.tag = kMainViewControllerItemInterstitialAds;
	adItem.image = [UIImage imageNamed:@"myTarget-fullscreen.png"];
	adItem.slotId = 0;
	[self addAdItem:adItem];

	adItem = [[AdItem alloc] initWithTitle:@"Native Ads" info:@"Advertisement inside app's content"];
	adItem.tag = kMainViewControllerItemNativeAds;
	adItem.image = [UIImage imageNamed:@"myTarget-native.png"];
	[adItem setSlotId:kSlotNativeAd type:AdItemSlotIdTypeDefault];
	[adItem setSlotId:kSlotNativeAdVideo type:AdItemSlotIdTypeNativeVideo];
	[adItem setSlotId:kSlotNativeAdCarousel type:AdItemSlotIdTypeNativeCarousel];
	[self addAdItem:adItem];

	adItem = [[AdItem alloc] initWithTitle:@"Instream Ads" info:@"Instream video ads"];
	adItem.tag = kMainViewControllerItemInstreamAds;
	adItem.image = [UIImage imageNamed:@"myTarget-instream.png"];
	adItem.slotId = kSlotInstreamVideo;
	[self addAdItem:adItem];

	for (CustomAdItem *customItem in _customAdItems)
	{
		adItem = nil;

		if (customItem.adType == kAdTypeStandard)
		{
			adItem = [[AdItem alloc] initWithTitle:@"Banner 320x50" info:customItem.title];
			adItem.tag = kMainViewControllerItemBanners;
		}
		else if (customItem.adType == kAdTypeStandard300x250)
		{
			adItem = [[AdItem alloc] initWithTitle:@"Banner 300x250" info:customItem.title];
			adItem.tag = kMainViewControllerItemBanners;
		}
		else if (customItem.adType == kAdTypeStandard728x90 && isIPad)
		{
			adItem = [[AdItem alloc] initWithTitle:@"Banner 728x90" info:customItem.title];
			adItem.tag = kMainViewControllerItemBanners;
		}
		else if (customItem.adType == kAdTypeInterstitial)
		{
			adItem = [[InterstitialAdItem alloc] initWithTitle:@"Interstitial Ads" info:customItem.title];
			adItem.tag = kMainViewControllerItemInterstitialAds;
		}
		else if (customItem.adType == kAdTypeNative)
		{
			adItem = [[AdItem alloc] initWithTitle:@"Native Ads" info:customItem.title];
			adItem.tag = kMainViewControllerItemNativeAds;
		}
		else if (customItem.adType == kAdTypeNativeVideo)
		{
			adItem = [[AdItem alloc] initWithTitle:@"Native Video" info:customItem.title];
			adItem.tag = kMainViewControllerItemNativeAds;
		}
		else if (customItem.adType == kAdTypeNativeCarousel)
		{
			adItem = [[AdItem alloc] initWithTitle:@"Native Carousel" info:customItem.title];
			adItem.tag = kMainViewControllerItemNativeAds;
		}
		else if (customItem.adType == kAdTypeInstream)
		{
			adItem = [[AdItem alloc] initWithTitle:@"Instream Ads" info:customItem.title];
			adItem.tag = kMainViewControllerItemInstreamAds;
		}

		if (adItem)
		{
			[adItem setSlotId:customItem.slotId type:AdItemSlotIdTypeDefault];
			adItem.customItem = customItem;
			adItem.canRemove = YES;
			[self addAdItem:adItem];
		}
	}

	adItem = [[AdItem alloc] initWithTitle:@"Ad unit" info:@"Insert your slotId and ad type"];
	adItem.color = [UIColor whiteColor];
	adItem.tag = kMainViewControllerItemAddUnit;
	adItem.image = [UIImage imageNamed:@"plus.png"];

	[self addAdItem:adItem];
}

- (void)itemClick:(AdItem *)adItem
{
	switch (adItem.tag)
	{
		case kMainViewControllerItemBanners:
		{
			StandardBannersViewController *controller = [[StandardBannersViewController alloc] initWithAdItem:adItem];
			[self.navigationController pushViewController:controller animated:YES];
			break;
		}
		case kMainViewControllerItemInterstitialAds:
		{
			if ([adItem isKindOfClass:[InterstitialAdItem class]] && adItem.customItem != nil)
			{
				// Load and open custom item in current controller
				MTRGInterstitialAd *interstitialAd = [[MTRGInterstitialAd alloc] initWithSlotId:adItem.slotId];
				interstitialAd.delegate = self;

				[interstitialAd.customParams setAge: @100];
				[interstitialAd.customParams setGender: MTRGGenderUnknown];

				[interstitialAd load];

				InterstitialAdItem *interstitialAdItem = (InterstitialAdItem *)adItem;
				interstitialAdItem.ad = interstitialAd;
				interstitialAdItem.isLoadedSuccess = NO;
				interstitialAdItem.isLoading = YES;
				[self updateStatusForAdItem:interstitialAdItem];
			}
			else
			{
				InterstitialAdsViewController *controller = [[InterstitialAdsViewController alloc] initWithAdItem:adItem];
				[self.navigationController pushViewController:controller animated:YES];
			}
			break;
		}
		case kMainViewControllerItemNativeAds:
		{
			NativeAdsViewController *controller = [[NativeAdsViewController alloc] initWithAdItem:adItem];
			[self.navigationController pushViewController:controller animated:YES];
			break;
		}
		case kMainViewControllerItemInstreamAds:
		{
			InstreamAdsViewController *controller = [[InstreamAdsViewController alloc] initWithAdItem:adItem];
			[self.navigationController pushViewController:controller animated:YES];
			break;
		}
		case kMainViewControllerItemAddUnit:
		{
			NewAdUnitController *controller = [[NewAdUnitController alloc] initWithDelegate:self];
			[self.navigationController pushViewController:controller animated:YES];
			break;
		}
		default:
			break;
	}
}

#pragma mark -- NewAdUnitControllerDelegate

- (void)newAdUnitControllerNewCustomAdItem:(CustomAdItem *)newCustomAdItem
{
	[_customAdItems addObject:newCustomAdItem];
	[CustomAdItem saveAdItemsToStorage:_customAdItems];
}

#pragma mark -- MTRGInterstitialAdDelegate

- (void)onLoadWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd
{
	InterstitialAdItem *interstitialAdItem = [self adItemForInterstitialAd:interstitialAd];
	if (interstitialAdItem)
	{
		interstitialAdItem.isLoadedSuccess = YES;
		interstitialAdItem.isLoading = NO;
		[self updateStatusForAdItem:interstitialAdItem];

		[interstitialAdItem.ad showWithController:self];
		[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
	}
}

- (void)onNoAdWithReason:(NSString *)reason interstitialAd:(MTRGInterstitialAd *)interstitialAd
{
	InterstitialAdItem *interstitialAdItem = [self adItemForInterstitialAd:interstitialAd];
	if (interstitialAdItem)
	{
		interstitialAdItem.isLoading = NO;
		[self updateStatusForAdItem:interstitialAdItem];
	}
}

- (void)onCloseWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd
{
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

@end
