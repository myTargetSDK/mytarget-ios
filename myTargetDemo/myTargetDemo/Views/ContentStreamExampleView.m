//
// Created by Anton Bulankin on 01.07.16.
// Copyright (c) 2016 Mail.ru Group. All rights reserved.
//

#import "ContentStreamExampleView.h"
#import <MyTargetSDK/MyTargetSDK.h>
#import "SimpleTextView.h"
#import "BorderCollectionViewCell.h"

static NSString *kContentStreamExampleViewCellReuseIdentifier = @"ReuseIdentifier";
static NSUInteger kContentStreamExampleViewAdIndex = 3;

@interface ContentStreamExampleView () <MTRGNativeAdDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@end

@implementation ContentStreamExampleView
{
	__weak UIViewController *_controller;
	UICollectionView *_collectionView;
	NSMutableArray *_views;
	UICollectionViewFlowLayout *_flowLayout;
	UIEdgeInsets _contentStreamAdViewMargins;

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
		_contentStreamAdViewMargins = UIEdgeInsetsMake(6, 6, 6, 6);

		_flowLayout = [[UICollectionViewFlowLayout alloc] init];
		_flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;

		_collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_flowLayout];
		_collectionView.delegate = self;
		_collectionView.dataSource = self;
		_collectionView.backgroundColor = [UIColor whiteColor];
		[_collectionView registerClass:[BorderCollectionViewCell class] forCellWithReuseIdentifier:kContentStreamExampleViewCellReuseIdentifier];
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

	[_nativeAd.customParams setAge: @100];
	[_nativeAd.customParams setGender: MTRGGenderUnknown];

	[_nativeAd load];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	_collectionView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
	[_flowLayout invalidateLayout];
}

- (UIView *)viewForIndexPath:(NSIndexPath *)indexPath
{
	return (indexPath.row < _views.count) ? _views[(NSUInteger) indexPath.row] : nil;
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
	//
}

#pragma mark - Collection view

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return _views.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kContentStreamExampleViewCellReuseIdentifier forIndexPath:indexPath];
	if (!cell)
	{
		cell = [[BorderCollectionViewCell alloc] init];
	}
	return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(8_0)
{
	UIView *view = [self viewForIndexPath:indexPath];
	[cell.contentView addSubview:view];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
	UIView *view = [self viewForIndexPath:indexPath];

	CGFloat cellWidth = CGRectGetWidth(collectionView.frame);
	CGFloat cellHeight = 0;

	if ([view isKindOfClass:[MTRGContentStreamAdView class]])
	{
		MTRGContentStreamAdView *adView = (MTRGContentStreamAdView *)view;
		CGFloat adWidth = cellWidth - (_contentStreamAdViewMargins.left + _contentStreamAdViewMargins.right);
		CGSize adViewSize = [adView sizeThatFits:CGSizeMake(adWidth, CGFLOAT_MAX)];

		CGRect adViewFrame = CGRectZero;
		adViewFrame.origin.x = _contentStreamAdViewMargins.left;
		adViewFrame.origin.y = _contentStreamAdViewMargins.top;
		adViewFrame.size = adViewSize;
		adView.frame = adViewFrame;

		cellHeight = CGRectGetHeight(adViewFrame) + (_contentStreamAdViewMargins.top + _contentStreamAdViewMargins.bottom);
	}
	else if ([view isKindOfClass:[SimpleTextView class]])
	{
		SimpleTextView *simpleTextView = (SimpleTextView *)view;
		CGSize simpleTextViewSize = [simpleTextView calculateSizeForWidth:cellWidth];

		CGRect simpleTextViewFrame = CGRectZero;
		simpleTextViewFrame.size = simpleTextViewSize;
		simpleTextView.frame = simpleTextViewFrame;

		cellHeight = simpleTextViewSize.height;
	}
	return CGSizeMake(cellWidth, cellHeight);
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
