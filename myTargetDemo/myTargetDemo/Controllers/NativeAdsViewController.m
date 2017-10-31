//
//  NativeAdsViewController.m
//  myTargetDemo
//
//  Created by Anton Bulankin on 27.06.16.
//  Copyright © 2016 Mail.ru Group. All rights reserved.
//

#import "NativeAdsViewController.h"

#import "ContentStreamExampleView.h"
#import "NewsFeedExampleView.h"
#import "ChatListExampleView.h"
#import "ContentWallExampleView.h"
#import "DefaultSlots.h"

@interface NativeAdsViewController ()

@end

@implementation NativeAdsViewController
{
	ContentStreamExampleView *_contentStreamExampleView;
	ContentStreamExampleView *_contentStreamVideoExampleView;
	ContentStreamExampleView *_contentStreamCarouselExampleView;
	NewsFeedExampleView *_newsFeedExampleView;
	ChatListExampleView *_chatListExampleView;
	ContentWallExampleView *_contentWallExampleView;
	ContentWallExampleView *_contentWallVideoExampleView;
	NSUInteger _slotId;
	NSUInteger _slotIdVideo;
	NSUInteger _slotIdCarousel;
}

- (instancetype)initWithAdItem:(AdItem *)adItem
{
	self = [super initWithTitle:adItem.title];
	if (self)
	{
		if (adItem.customItem && adItem.customItem.adType == kAdTypeNativeVideo)
		{
			_slotId = 0;
			_slotIdVideo = [adItem slotIdForType:AdItemSlotIdTypeDefault];
			_slotIdCarousel = 0;
		}
		else if (adItem.customItem && adItem.customItem.adType == kAdTypeNativeCarousel)
		{
			_slotId = 0;
			_slotIdVideo = 0;
			_slotIdCarousel = [adItem slotIdForType:AdItemSlotIdTypeDefault];
		}
		else
		{
			_slotId = [adItem slotIdForType:AdItemSlotIdTypeDefault];
			_slotIdVideo = [adItem slotIdForType:AdItemSlotIdTypeNativeVideo];
			_slotIdCarousel = [adItem slotIdForType:AdItemSlotIdTypeNativeCarousel];
		}

		if (_slotId > 0)
		{
			_contentStreamExampleView = [[ContentStreamExampleView alloc] initWithController:self slotId:_slotId];
			[self addPageWithTitle:@"CONTENT STREAM" view:_contentStreamExampleView adType:NativeAdTypeStatic];

			_newsFeedExampleView = [[NewsFeedExampleView alloc] initWithController:self slotId:_slotId];
			[self addPageWithTitle:@"NEWS FEED" view:_newsFeedExampleView adType:NativeAdTypeStatic];

			_chatListExampleView = [[ChatListExampleView alloc] initWithController:self slotId:_slotId];
			[self addPageWithTitle:@"CHAT LIST" view:_chatListExampleView adType:NativeAdTypeStatic];

			_contentWallExampleView = [[ContentWallExampleView alloc] initWithController:self slotId:_slotId];
			[self addPageWithTitle:@"CONTENT WALL" view:_contentWallExampleView adType:NativeAdTypeStatic];
		}

		if (_slotIdVideo > 0)
		{
			_contentStreamVideoExampleView = [[ContentStreamExampleView alloc] initWithController:self slotId:_slotIdVideo];
			[self addPageWithTitle:@"CONTENT STREAM VIDEO" view:_contentStreamVideoExampleView adType:NativeAdTypeVideo];

			_contentWallVideoExampleView = [[ContentWallExampleView alloc] initWithController:self slotId:_slotIdVideo];
			[self addPageWithTitle:@"CONTENT WALL VIDEO" view:_contentWallVideoExampleView adType:NativeAdTypeVideo];
		}

		if (_slotIdCarousel > 0)
		{
			_contentStreamCarouselExampleView = [[ContentStreamExampleView alloc] initWithController:self slotId:_slotIdCarousel];
			[self addPageWithTitle:@"CONTENT STREAM CAROUSEL" view:_contentStreamCarouselExampleView adType:NativeAdTypeCarousel];
		}
	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	UIBarButtonItem *updateButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(updateTapped:)];
	updateButton.accessibilityIdentifier = @"updateButton";
	self.navigationItem.rightBarButtonItems = @[updateButton];

	[self reloadAds];
}

- (void)reloadAds
{
	[_contentStreamExampleView reloadAd];
	[_contentStreamVideoExampleView reloadAd];
	[_newsFeedExampleView reloadAd];
	[_chatListExampleView reloadAd];
	[_contentWallExampleView reloadAd];
	[_contentWallVideoExampleView reloadAd];
	[_contentStreamCarouselExampleView reloadAd];
}

- (void)updateTapped:(id)sender
{
	[self reloadAds];
}

@end
