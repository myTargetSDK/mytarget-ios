//
// Created by Anton Bulankin on 01.07.16.
// Copyright (c) 2016 Mail.ru Group. All rights reserved.
//

#import "StandardBannersViewController.h"
#import "SimpleTextView.h"
#import "ScrollMenuView.h"

#import <MyTargetSDK/MyTargetSDK.h>

static NSString *kStandardBannersViewControllerTextCellId = @"TextCellId";
static NSString *kStandardBannersViewControllerAdCellId = @"AdCellId";
static NSUInteger kStandardBannersViewControllerAdIndex = 1;

@interface StandardBannersViewController () <UITableViewDelegate, UITableViewDataSource, MTRGAdViewDelegate, ScrollMenuViewDelegate>
@end

@implementation StandardBannersViewController
{
	UITableView *_tableView;
	UIView *_adContainerView;
	NSMutableArray *_views;
	NSString *_title;
	MTRGAdView *_adView;
	NSMutableArray *_adConstraints;
	NSUInteger _slotId;
	NSUInteger _slotId300x250;
	ScrollMenuView *_scrollMenu;
	MTRGAdSize _adSize;
	NSUInteger _selectedIndex;
}

- (instancetype)initWithAdItem:(AdItem *)adItem
{
	self = [super init];
	if (self)
	{
		_adSize = MTRGAdSize_320x50;
		_selectedIndex = 0;
		
		_title = adItem.title;
		_slotId = [adItem slotIdForType:AdItemSlotIdTypeDefault];
		_slotId300x250 = [adItem slotIdForType:AdItemSlotIdTypeStandard300x250];
		_views = [NSMutableArray new];
		_adConstraints = [NSMutableArray new];
	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	self.view.backgroundColor = [UIColor whiteColor];
	self.navigationItem.title = _title;
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(updateTapped:)];

	for (int i = 0; i < 10; ++i)
	{
		[_views addObject:[[SimpleTextView alloc] init]];
	}

	_scrollMenu = [[ScrollMenuView alloc] init];
	_scrollMenu.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview:_scrollMenu];

	_scrollMenu.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.5];
	_scrollMenu.tabTitleColor = [UIColor whiteColor];
	_scrollMenu.backgroundColor = [UIColor colorWithRed:248 / 255.f green:48 / 255.f blue:63 / 255.f alpha:1];
	_scrollMenu.tabTitleFont = [UIFont fontWithName:@"Helvetica-Bold" size:14];
	_scrollMenu.layer.shadowColor = [UIColor grayColor].CGColor;
	_scrollMenu.layer.shadowRadius = 5.0;
	_scrollMenu.layer.shadowOpacity = 0.6;
	_scrollMenu.layer.shadowOffset = CGSizeMake(0, 5.0);
	_scrollMenu.delegate = self;

	NSMutableArray *menuItems = [NSMutableArray new];
	[menuItems addObject:[[ScrollMenuItem alloc] initWithTitle:@"320x50"]];
	[menuItems addObject:[[ScrollMenuItem alloc] initWithTitle:@"300x250"]];

	[_scrollMenu setMenuItems:menuItems];
	[_scrollMenu setSelectedIndex:0];
	[_scrollMenu reloadData];
	[_scrollMenu setSelectedIndex:0 animated:YES calledDelegate:NO];

	_tableView = [[UITableView alloc] init];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview:_tableView];

	[_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kStandardBannersViewControllerTextCellId];
	[_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kStandardBannersViewControllerAdCellId];

	_adContainerView = [[UIView alloc] init];
	_adContainerView.hidden = YES;
	_adContainerView.translatesAutoresizingMaskIntoConstraints = NO;
	_adContainerView.backgroundColor = [UIColor whiteColor];
	_adContainerView.layer.zPosition = 100;
	_adContainerView.layer.shadowColor = [UIColor whiteColor].CGColor;
	_adContainerView.layer.shadowRadius = 5.0;
	_adContainerView.layer.shadowOpacity = 1;
	_adContainerView.layer.shadowOffset = CGSizeMake(0, -5);

	[self.view addSubview:_adContainerView];

	NSDictionary *views = @{
			@"scrollMenu" : _scrollMenu,
			@"tableView" : _tableView,
			@"adContainerView" : _adContainerView
	};

	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[scrollMenu]-0-|" options:0 metrics:nil views:views]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[tableView]-0-|" options:0 metrics:nil views:views]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[scrollMenu(50)]-0-[tableView]-0-|" options:0 metrics:nil views:views]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[adContainerView]-0-|" options:0 metrics:nil views:views]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[adContainerView(50)]-0-|" options:0 metrics:nil views:views]];

	[_tableView reloadData];
	[self reloadAd];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.navigationController.navigationBar.topItem.title = @"";
	self.navigationItem.title = _title;
}

- (void)updateTapped:(id)sender
{
	[self reloadAd];
}

- (void)showAdView
{
	if (_adSize == MTRGAdSize_300x250)
	{
		[_views replaceObjectAtIndex:kStandardBannersViewControllerAdIndex withObject:_adView];
		[_tableView reloadData];
	}
	else if (_adSize == MTRGAdSize_320x50)
	{
		[_views replaceObjectAtIndex:kStandardBannersViewControllerAdIndex withObject:[[SimpleTextView alloc] init]];
		[_tableView reloadData];

		_adView.translatesAutoresizingMaskIntoConstraints = NO;
		[_adContainerView addSubview:_adView];
		_adContainerView.hidden = NO;

		NSDictionary *views = @{@"adView" : _adView};
		[_adConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[adView]-0-|" options:0 metrics:nil views:views]];
		[_adConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[adView]-0-|" options:0 metrics:nil views:views]];
		[_adContainerView addConstraints:_adConstraints];
	}
}

- (void)reloadAd
{
	if (_adView)
	{
		[_adView stop];
		[_adContainerView removeConstraints:_adConstraints];
		[_adConstraints removeAllObjects];
		[_adView removeFromSuperview];
		_adContainerView.hidden = YES;
		_adView = nil;
	}
	NSUInteger slotId = (_adSize == MTRGAdSize_300x250) ? _slotId300x250 : _slotId;
	_adView = [[MTRGAdView alloc] initWithSlotId:slotId adSize:_adSize];
	_adView.delegate = self;
	[_adView load];
	_adView.viewController = self;
}

#pragma mark -- ScrollMenuViewDelegate

- (void)scrollMenuDidSelected:(ScrollMenuView *)scrollMenu menuIndex:(NSUInteger)selectIndex
{
	if (_selectedIndex == selectIndex) return;
	_selectedIndex = selectIndex;

	switch (_selectedIndex)
	{
		case 1:
			_adSize = MTRGAdSize_300x250;
			break;

		default:
			_adSize = MTRGAdSize_320x50;
			break;
	}
	[_tableView reloadData];
	[self reloadAd];
}

#pragma mark -- UITableViewDelegate

- (void)onLoadWithAdView:(MTRGAdView *)adView
{
	[self showAdView];
	[_adView start];
}

- (void)onNoAdWithReason:(NSString *)reason adView:(MTRGAdView *)adView
{
	_adView = nil;
}

- (void)onAdClickWithAdView:(MTRGAdView *)adView
{
	//
}

#pragma mark -- UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return _views.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell;
	UIView *view = _views[(NSUInteger) indexPath.row];
	if ([view isKindOfClass:[SimpleTextView class]])
	{
		cell = [tableView dequeueReusableCellWithIdentifier:kStandardBannersViewControllerTextCellId];
		if (!cell)
		{
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kStandardBannersViewControllerTextCellId];
		}
	}
	else if ([view isKindOfClass:[MTRGAdView class]])
	{
		cell = [tableView dequeueReusableCellWithIdentifier:kStandardBannersViewControllerAdCellId];
		if (!cell)
		{
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kStandardBannersViewControllerAdCellId];
		}
	}

	if (cell)
	{
		[cell.contentView addSubview:view];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UIView *view = _views[(NSUInteger) indexPath.row];
	CGFloat width = tableView.frame.size.width;
	CGRect viewFrame = CGRectZero;

	if ([view isKindOfClass:[SimpleTextView class]])
	{
		SimpleTextView *simpleTextView = (SimpleTextView *)view;
		CGSize size = [simpleTextView calculateSizeForWidth:width];
		viewFrame.size = CGSizeMake(width, size.height);
	}
	else if ([view isKindOfClass:[MTRGAdView class]] && _adSize == MTRGAdSize_300x250)
	{
		viewFrame.size = CGSizeMake(width, 250);
	}

	view.frame = viewFrame;
	return CGRectGetHeight(viewFrame);
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	UIView *view = _views[(NSUInteger) indexPath.row];
	[view removeFromSuperview];
}

@end
