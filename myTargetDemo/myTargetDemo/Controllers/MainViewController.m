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
#import "NewAdUnitController.h"
#import "AdTypes.h"
#import "CustomAdItem.h"
#import "DefaultSlots.h"

@interface MainViewController ()

@end

const int kMainViewControllerItemBanners320x50 = 1;
const int kMainViewControllerItemInterstitialAds = 2;
const int kMainViewControllerItemNativeAds = 3;
const int kMainViewControllerItemAddUnit = 4;


@interface MainViewController () <NewAdUnitControllerDelegate>
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

	adItem = [[AdItem alloc] initWithTitle:@"Banners 320x50" info:@"Standard 320x50 banners"];
	adItem.tag = kMainViewControllerItemBanners320x50;
	adItem.slotId = kSlotStandardBanner;
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
	adItem.slotId = kSlotNativeAd;
	adItem.slotIdVideo = kSlotNativeAdVideo;
	[self addAdItem:adItem];

	for (CustomAdItem *customItem in _customAdItems)
	{
		adItem = nil;

		if (customItem.adType == kAdTypeStandard)
		{
			adItem = [[AdItem alloc] initWithTitle:@"Banners 320x50" info:customItem.title];
			adItem.tag = kMainViewControllerItemBanners320x50;
		}
		if (customItem.adType == kAdTypeInterstitial)
		{
			adItem = [[AdItem alloc] initWithTitle:@"Interstitial Ads" info:customItem.title];
			adItem.tag = kMainViewControllerItemInterstitialAds;
		}
		if (customItem.adType == kAdTypeNative)
		{
			adItem = [[AdItem alloc] initWithTitle:@"Native Ads" info:customItem.title];
			adItem.tag = kMainViewControllerItemNativeAds;
		}

		if (adItem)
		{
			adItem.slotId = customItem.slotId;
			adItem.slotIdVideo = customItem.slotId;
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
		case kMainViewControllerItemBanners320x50:
		{
			StandardBannersViewController *controller = [[StandardBannersViewController alloc] initWithTitle:adItem.title slotId:adItem.slotId];
			[self.navigationController pushViewController:controller animated:YES];
			break;
		}
		case kMainViewControllerItemInterstitialAds:
		{
			InterstitialAdsViewController *controller = [[InterstitialAdsViewController alloc] initWithAdItem:adItem];
			[self.navigationController pushViewController:controller animated:YES];
			break;
		}
		case kMainViewControllerItemNativeAds:
		{
			NativeAdsViewController *controller = [[NativeAdsViewController alloc] initWithTitle:adItem.title slotId:adItem.slotId slotIdVideo:adItem.slotIdVideo];
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

@end
