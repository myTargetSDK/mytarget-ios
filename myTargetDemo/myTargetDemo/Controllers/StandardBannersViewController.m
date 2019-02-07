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
	NSUInteger _slotId728x90;
	ScrollMenuView *_scrollMenu;
	MTRGAdSize _adSize;
	NSUInteger _selectedIndex;
	NSMutableArray<NSLayoutConstraint *> *_constraints;
}

- (instancetype)initWithAdItem:(AdItem *)adItem
{
	self = [super init];
	if (self)
	{
		_selectedIndex = 0;
		
		_title = adItem.title;
		if (adItem.customItem && adItem.customItem.adType == kAdTypeStandard300x250)
		{
			_slotId = 0;
			_slotId300x250 = [adItem slotIdForType:AdItemSlotIdTypeDefault];
			_slotId728x90 = 0;
			_adSize = MTRGAdSize_300x250;
		}
		else if (adItem.customItem && adItem.customItem.adType == kAdTypeStandard728x90)
		{
			_slotId = 0;
			_slotId300x250 = 0;
			_slotId728x90 = [adItem slotIdForType:AdItemSlotIdTypeDefault];
			_adSize = MTRGAdSize_728x90;
		}
		else
		{
			_slotId = [adItem slotIdForType:AdItemSlotIdTypeDefault];
			_slotId300x250 = [adItem slotIdForType:AdItemSlotIdTypeStandard300x250];
			_slotId728x90 = [adItem slotIdForType:AdItemSlotIdTypeStandard728x90];
			_adSize = MTRGAdSize_320x50;
		}
		_views = [NSMutableArray new];
		_adConstraints = [NSMutableArray new];
		_constraints = [NSMutableArray<NSLayoutConstraint *> new];
	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	BOOL isIPad = [[[UIDevice currentDevice] model] isEqualToString:@"iPad"];

	self.view.backgroundColor = [UIColor whiteColor];
	self.navigationItem.title = _title;
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(updateTapped:)];

	for (int i = 0; i < 10; ++i)
	{
		[_views addObject:[[SimpleTextView alloc] init]];
	}

	_scrollMenu = [[ScrollMenuView alloc] init];
	_scrollMenu.delegate = self;
	_scrollMenu.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview:_scrollMenu];

	NSMutableArray *menuItems = [NSMutableArray new];
	if (_slotId > 0)
	{
		[menuItems addObject:[[ScrollMenuItem alloc] initWithTitle:@"320x50"]];
	}
	if (_slotId300x250 > 0)
	{
		[menuItems addObject:[[ScrollMenuItem alloc] initWithTitle:@"300x250"]];
	}
	if (_slotId728x90 > 0 && isIPad)
	{
		[menuItems addObject:[[ScrollMenuItem alloc] initWithTitle:@"728x90"]];
	}

	if (menuItems.count > 0)
	{
		[_scrollMenu setMenuItems:menuItems];
		[_scrollMenu setSelectedIndex:0];
		[_scrollMenu reloadData];
		[_scrollMenu setSelectedIndex:0 animated:YES calledDelegate:NO];
	}

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

	[self setupConstraints];

	[_tableView reloadData];
	[self reloadAd];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.navigationController.navigationBar.topItem.title = @"";
	self.navigationItem.title = _title;
}

- (void)viewSafeAreaInsetsDidChange
{
	[super viewSafeAreaInsetsDidChange];
	[self setupConstraints];
}

- (void)setupConstraints
{
	if (_constraints.count > 0)
	{
		[NSLayoutConstraint deactivateConstraints:_constraints];
		[_constraints removeAllObjects];
	}

	NSDictionary *views = @{
		@"scrollMenu" : _scrollMenu,
		@"tableView" : _tableView,
		@"adContainerView" : _adContainerView
	};

	UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;
	if (@available(ios 11.0, *))
	{
		safeAreaInsets = self.view.safeAreaInsets;
	}
	NSDictionary<NSString *, NSNumber *> *metrics = @{
		@"topMargin": @(safeAreaInsets.top),
		@"bottomMargin": @(safeAreaInsets.bottom),
		@"leftMargin": @(safeAreaInsets.left),
		@"rightMargin": @(safeAreaInsets.right)
	};

	[_constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-leftMargin-[scrollMenu]-rightMargin-|" options:0 metrics:metrics views:views]];
	[_constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-leftMargin-[tableView]-rightMargin-|" options:0 metrics:metrics views:views]];
	[_constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-topMargin-[scrollMenu(50)]-0-[tableView]-bottomMargin-|" options:0 metrics:metrics views:views]];
	[_constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-leftMargin-[adContainerView]-rightMargin-|" options:0 metrics:metrics views:views]];
	[_constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[adContainerView(50)]-bottomMargin-|" options:0 metrics:metrics views:views]];

	[NSLayoutConstraint activateConstraints:_constraints];
}

- (void)updateTapped:(UIBarButtonItem *)sender
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
		[self adjustContainerHeight:50];
	}
	else if (_adSize == MTRGAdSize_728x90)
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
		[self adjustContainerHeight:90];
	}
}

- (void)adjustContainerHeight:(CGFloat)height
{
	for (NSLayoutConstraint *constraint in _adContainerView.constraints)
	{
		if (constraint.firstItem == _adContainerView && constraint.firstAttribute == NSLayoutAttributeHeight)
		{
			constraint.constant = height;
			break;
		}
	}
}

- (void)reloadAd
{
	if (_adView)
	{
		[_adContainerView removeConstraints:_adConstraints];
		[_adConstraints removeAllObjects];
		[_adView removeFromSuperview];
		_adContainerView.hidden = YES;
		_adView = nil;
	}
	NSUInteger slotId = (_adSize == MTRGAdSize_300x250) ? _slotId300x250 : (_adSize == MTRGAdSize_728x90) ? _slotId728x90 : _slotId;
	_adView = [[MTRGAdView alloc] initWithSlotId:slotId adSize:_adSize];
	_adView.delegate = self;

	[_adView.customParams setAge: @100];
	[_adView.customParams setGender: MTRGGenderUnknown];

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
		case 2:
			_adSize = MTRGAdSize_728x90;
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
