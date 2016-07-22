//
// Created by Anton Bulankin on 01.07.16.
// Copyright (c) 2016 Mail.ru Group. All rights reserved.
//

#import "StandardBannersViewController.h"
#import "SimpleTextView.h"
#import <MyTargetSDK/MyTargetSDK.h>

static NSString *kStandardBannersViewControllerTextCellId = @"TextCellId";

@interface StandardBannersViewController () <UITableViewDelegate, UITableViewDataSource, MTRGAdViewDelegate>
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
}

- (instancetype)initWithTitle:(NSString *)title slotId:(NSUInteger)slotId
{
	self = [super init];
	if (self)
	{
		_title = title;
		_slotId = slotId;
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
	UIBarButtonItem *updateButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
	                                                                              target:self action:@selector(updateTapped:)];
	self.navigationItem.rightBarButtonItems = @[updateButton];


	for (int i = 0; i < 10; ++i)
	{
		[_views addObject:[[SimpleTextView alloc] init]];
	}

	_tableView = [[UITableView alloc] init];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview:_tableView];

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
			@"tableView" : _tableView,
			@"adContainerView" : _adContainerView
	};

	NSString *layoutString;
	layoutString = @"H:|-0-[tableView]-0-|";
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:layoutString options:0 metrics:nil views:views]];
	layoutString = @"V:|-0-[tableView]-0-|";
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:layoutString options:0 metrics:nil views:views]];

	layoutString = @"H:|-0-[adContainerView]-0-|";
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:layoutString options:0 metrics:nil views:views]];
	layoutString = @"V:|-(>=0)-[adContainerView(50)]-0-|";
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:layoutString options:0 metrics:nil views:views]];

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
	_adView.translatesAutoresizingMaskIntoConstraints = NO;
	[_adContainerView addSubview:_adView];
	_adContainerView.hidden = NO;

	NSDictionary *views = @{@"adView" : _adView};
	[_adConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[adView]-0-|"
	                                                                            options:0 metrics:nil views:views]];
	[_adConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[adView]-0-|"
	                                                                            options:0 metrics:nil views:views]];
	[_adContainerView addConstraints:_adConstraints];
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
	_adView = [[MTRGAdView alloc] initWithSlotId:_slotId];
	_adView.delegate = self;
	[_adView load];
	_adView.viewController = self;
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
	UIView *view = _views[(NSUInteger) indexPath.row];
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kStandardBannersViewControllerTextCellId];
	if (!cell)
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kStandardBannersViewControllerTextCellId];
	[cell.contentView addSubview:view];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	SimpleTextView *view = (SimpleTextView *) (_views[(NSUInteger) indexPath.row]);
	CGFloat width = tableView.frame.size.width;
	CGSize size = [view calculateSizeForWidth:width];
	CGFloat height = size.height;
	view.frame = CGRectMake(0, 0, width, size.height);
	return height;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	UIView *view = _views[(NSUInteger) indexPath.row];
	[view removeFromSuperview];
}

@end