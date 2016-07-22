//
//  InterstitialAdsViewController.m
//  myTargetDemo
//
//  Created by Anton Bulankin on 24.06.16.
//  Copyright © 2016 Mail.ru Group. All rights reserved.
//

#import "InterstitialAdsViewController.h"
#import "DefaultSlots.h"
#import <MyTargetSDK/MyTargetSDK.h>

@interface InterstitialAdItem : AdItem

@property(nonatomic) MTRGInterstitialAd *ad;
@property(nonatomic) BOOL isLoadedSuccess;

@end

@implementation InterstitialAdItem

- (instancetype)initWithTitle:(NSString *)title info:(NSString *)info
{
	self = [super initWithTitle:title info:info];
	if (self)
	{
		_isLoadedSuccess = NO;
	}
	return self;
}

@end


@interface InterstitialAdsViewController () <MTRGInterstitialAdDelegate>

@end

@implementation InterstitialAdsViewController

- (instancetype)initWithAdItem:(AdItem *)adItem
{
	self = [super initWithTitle:adItem.title];
	if (self)
	{
		InterstitialAdItem *subItem;

		if (adItem.customItem == nil)
		{
			subItem = [[InterstitialAdItem alloc] initWithTitle:@"Promo" info:@"Fullscreen promo advertisement"];
			subItem.image = [UIImage imageNamed:@"myTarget-fullscreen-promo.png"];
			subItem.slotId = kSlotIntertitialAdPromo;
			[self addAdItem:subItem];

			subItem = [[InterstitialAdItem alloc] initWithTitle:@"Promo video" info:@"Fullscreen advertisement with video element"];
			subItem.image = [UIImage imageNamed:@"myTarget-fullscreen-promo-video.png"];
			subItem.slotId = kSlotIntertitialAdPromoVideo;
			[self addAdItem:subItem];

			subItem = [[InterstitialAdItem alloc] initWithTitle:@"Image" info:@"Fullscreen image banner"];
			subItem.image = [UIImage imageNamed:@"myTarget-fullscreen-image.png"];
			subItem.slotId = kSlotIntertitialAdImage;
			[self addAdItem:subItem];

			subItem = [[InterstitialAdItem alloc] initWithTitle:@"Video" info:@"Fullscreen video advertisement"];
			subItem.image = [UIImage imageNamed:@"myTarget-fullscreen-video.png"];
			subItem.slotId = kSlotIntertitialAdPromoVideoStyle;
			[self addAdItem:subItem];
		}
		else
		{
			NSString *info = adItem.title ? adItem.title : @"Fullscreen advertisement";
			subItem = [[InterstitialAdItem alloc] initWithTitle:@"Custom" info:info];
			subItem.slotId = adItem.slotId;
			subItem.customItem = adItem.customItem;
			[self addAdItem:subItem];
		}

		UIBarButtonItem *updateButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
		                                                                              target:self action:@selector(updateTapped:)];
		self.navigationItem.rightBarButtonItems = @[updateButton];
	}
	return self;
}

- (void)updateTapped:(id)sender
{
	[self reloadAds];
}

- (void)itemClick:(AdItem *)adItem
{
	InterstitialAdItem *interstitialAdItem = (InterstitialAdItem *) adItem;
	if (interstitialAdItem.isLoadedSuccess)
	{
		[interstitialAdItem.ad showWithController:self];
		[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
	}
}

- (void)reloadAds
{
	for (InterstitialAdItem *adItem in self.adItems)
	{
		adItem.ad = [[MTRGInterstitialAd alloc] initWithSlotId:adItem.slotId];
		adItem.ad.delegate = self;
		[adItem.ad load];
		adItem.isLoadedSuccess = NO;
		adItem.isLoading = YES;
		[self updateStatusForAdItem:adItem];
	}
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self reloadAds];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

- (InterstitialAdItem *)adItemForAd:(MTRGInterstitialAd *)interstitialAd
{
	for (AdItem *adItem in self.adItems)
		if (((InterstitialAdItem *) adItem).ad == interstitialAd)
			return (InterstitialAdItem *) adItem;
	return nil;
}

#pragma mark -- MTRGInterstitialAdDelegate

- (void)onLoadWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd
{
	InterstitialAdItem *adItem = [self adItemForAd:interstitialAd];
	if (adItem)
	{
		adItem.isLoadedSuccess = YES;
		adItem.isLoading = NO;
		[self updateStatusForAdItem:adItem];
	}
}

- (void)onNoAdWithReason:(NSString *)reason interstitialAd:(MTRGInterstitialAd *)interstitialAd
{
	InterstitialAdItem *adItem = [self adItemForAd:interstitialAd];
	if (adItem)
	{
		adItem.isLoading = NO;
		[self updateStatusForAdItem:adItem];
	}
}

- (void)onClickWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd
{

}

- (void)onCloseWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd
{
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

- (void)onVideoCompleteWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd
{

}

- (void)onDisplayWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd
{

}

@end
