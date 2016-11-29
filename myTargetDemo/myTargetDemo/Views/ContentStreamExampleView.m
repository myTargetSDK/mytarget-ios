//
// Created by Anton Bulankin on 01.07.16.
// Copyright (c) 2016 Mail.ru Group. All rights reserved.
//

#import "ContentStreamExampleView.h"
#import <MyTargetSDK/MyTargetSDK.h>
#import "SimpleTextView.h"
#import "BorderCollectionViewCell.h"


static NSString *kContentStreamExampleViewTextCellId = @"TextCellId";
static NSString *kContentStreamExampleViewAdCellId = @"AdCellId";
static NSUInteger kContentStreamExampleViewAdIndex = 3;

@interface ContentStreamExampleView () <MTRGNativeAdDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@end

@implementation ContentStreamExampleView
{
	UIViewController *_controller;
	UICollectionView *_collectionView;
	NSMutableArray *_views;
	UICollectionViewFlowLayout *_flowLayout;

	NSUInteger _slotId;
	MTRGNativeAd *_nativeAd;
	MTRGContentStreamAdView *_adView;
}

- (instancetype)initWithController:(UIViewController *)controller slotId:(NSUInteger)slotId
{
	self = [super init];
	if (self)
	{
		_controller = controller;
		_slotId = slotId;

		_flowLayout = [[UICollectionViewFlowLayout alloc] init];
		[_flowLayout setItemSize:CGSizeMake(200, 200)];
		[_flowLayout setEstimatedItemSize:CGSizeMake(200, 200)];
		[_flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];

		_collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_flowLayout];
		_collectionView.delegate = self;
		_collectionView.dataSource = self;
		_collectionView.backgroundColor = [UIColor whiteColor];
		[_collectionView registerClass:[BorderCollectionViewCell class] forCellWithReuseIdentifier:kContentStreamExampleViewTextCellId];
		[_collectionView registerClass:[BorderCollectionViewCell class] forCellWithReuseIdentifier:kContentStreamExampleViewAdCellId];
		[self addSubview:_collectionView];

		_views = [NSMutableArray new];
		for (int i = 0; i < 10; ++i)
		{
			[_views addObject:[[SimpleTextView alloc] init]];
		}
	}
	return self;
}

- (void)reloadAd
{
	if (_adView)
	{
		_nativeAd.delegate = nil;
		[_nativeAd unregisterView];
		[_adView removeFromSuperview];
		[_views removeObject:_adView];
		_adView = nil;
	}
	[_collectionView reloadData];
	[_flowLayout invalidateLayout];

	_nativeAd = [[MTRGNativeAd alloc] initWithSlotId:_slotId];
	_nativeAd.delegate = self;
	[_nativeAd load];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	_collectionView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

- (UIView *)viewForIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row < _views.count)
		return _views[(NSUInteger) indexPath.row];
	else
		return nil;
}

#pragma mark -- MTRGNativeAdDelegate

- (void)onLoadWithNativePromoBanner:(MTRGNativePromoBanner *)promoBanner nativeAd:(MTRGNativeAd *)nativeAd
{
	if (nativeAd != _nativeAd) return;

	//Created view for banner
	_adView = [MTRGNativeViewsFactory createContentStreamViewWithBanner:promoBanner];
	[_adView loadImages];
	[_nativeAd registerView:_adView withController:_controller];

	[_views insertObject:_adView atIndex:kContentStreamExampleViewAdIndex];
	[_collectionView reloadData];
}

- (void)onNoAdWithReason:(NSString *)reason nativeAd:(MTRGNativeAd *)nativeAd
{
	NSLog(@"Loading failed: %@", reason);
}

- (void)onAdClickWithNativeAd:(MTRGNativeAd *)nativeAd
{

}

#pragma mark - Collection view

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return _views.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	UIView *view = [self viewForIndexPath:indexPath];
	UICollectionViewCell *cell;
	if (indexPath.row == kContentStreamExampleViewAdIndex)
	{
		cell = [collectionView dequeueReusableCellWithReuseIdentifier:kContentStreamExampleViewAdCellId forIndexPath:indexPath];
		if (!cell)
			cell = [[BorderCollectionViewCell alloc] init];
		[cell.contentView addSubview:view];
	}
	else
	{
		cell = [collectionView dequeueReusableCellWithReuseIdentifier:kContentStreamExampleViewTextCellId forIndexPath:indexPath];
		if (!cell)
			cell = [[BorderCollectionViewCell alloc] init];
		[cell.contentView addSubview:view];
	}

	return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
	UIView *view = [self viewForIndexPath:indexPath];

	CGFloat height;
	if ([view isKindOfClass:[MTRGContentStreamAdView class]])
	{
		CGFloat padding = 6;
		MTRGContentStreamAdView *adView = (MTRGContentStreamAdView *) view;
		CGFloat adWidth = collectionView.frame.size.width - 2 * padding;
		CGSize adViewSize = [adView sizeThatFits:CGSizeMake(adWidth, CGFLOAT_MAX)];
		adView.frame = CGRectMake(padding, padding, adViewSize.width, adViewSize.height);
		height = adView.frame.size.height + 2 * padding;
	}
	else
	{
		SimpleTextView *textView = (SimpleTextView *) view;
		CGFloat width = collectionView.frame.size.width;
		CGSize size = [textView calculateSizeForWidth:width];
		height = size.height;
		view.frame = CGRectMake(0, 0, width, size.height);
	}
	return CGSizeMake(collectionView.frame.size.width, height);
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
	UIView *view = [self viewForIndexPath:indexPath];
	[view removeFromSuperview];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
	return 0.f;
}

@end
