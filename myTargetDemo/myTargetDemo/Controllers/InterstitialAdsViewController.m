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

static const float kHeightForFooterInSection = 50.0f;

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

@interface CheckboxView : UIView

@property (nonatomic, assign) BOOL canShowModal;

@end

@implementation CheckboxView
{
	UILabel *_checkboxLabel;
	UISwitch *_checkboxSwitch;
}

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
	{
		self.canShowModal = NO;

		_checkboxLabel = [[UILabel alloc] init];
		_checkboxLabel.text = @"Open fullscreen in Modal view instead of Сontroller";
		_checkboxLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
		_checkboxLabel.textColor = [UIColor grayColor];
		[self addSubview:_checkboxLabel];

		_checkboxSwitch = [[UISwitch alloc] init];
		[_checkboxSwitch addTarget:self action:@selector(checkboxTapped:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_checkboxSwitch];
	}
	return self;
}

- (void)checkboxTapped:(UISwitch *)sender
{
	self.canShowModal = sender.isOn;
}

- (void)layoutSubviews
{
	[super layoutSubviews];

	CGFloat padding = 8.0f;
	CGFloat width = CGRectGetWidth(self.frame);
	CGFloat height = CGRectGetHeight(self.frame);

	CGFloat checkboxWidth = CGRectGetWidth(_checkboxSwitch.frame);
	CGFloat checkboxHeight = CGRectGetHeight(_checkboxSwitch.frame);
	_checkboxSwitch.frame = CGRectMake(width - checkboxWidth - padding, 0.5 * (height - checkboxHeight), checkboxWidth, checkboxHeight);

	[_checkboxLabel sizeToFit];
	CGFloat labelHeight = CGRectGetHeight(_checkboxLabel.frame);
	_checkboxLabel.frame = CGRectMake(padding, 0.5 * (height - labelHeight), _checkboxSwitch.frame.origin.x - 2 * padding, labelHeight);
}

@end


@interface InterstitialAdsViewController () <MTRGInterstitialAdDelegate>

@end

@implementation InterstitialAdsViewController
{
	CheckboxView *_checkboxView;
}

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
		if (_checkboxView.canShowModal)
		{
			[interstitialAdItem.ad showModalWithController:self];
		}
		else
		{
			[interstitialAdItem.ad showWithController:self];
			[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
		}
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

	CGRect frame = CGRectMake(0, 0, self.tableView.frame.size.width, kHeightForFooterInSection);
	_checkboxView = [[CheckboxView alloc] initWithFrame:frame];
	
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

#pragma mark - TableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	return kHeightForFooterInSection;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
	return _checkboxView;
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
