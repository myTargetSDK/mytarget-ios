//
//  ScrollMenuViewController.m
//  myTargetDemo
//
//  Created by Anton Bulankin on 28.06.16.
//  Copyright © 2016 Mail.ru Group. All rights reserved.
//

#import "ScrollMenuViewController.h"

#import "ScrollMenuView.h"
#import "ScrollView.h"

@interface ScrollMenuViewController () <ScrollMenuViewDelegate, UIScrollViewDelegate>
@property(nonatomic) BOOL shouldObserving;
@end

@implementation ScrollMenuViewController
{
	NSMutableArray *_menuItems;
	NSMutableArray *_menuViews;
	NSString *_title;
	ScrollView *_scrollView;
	ScrollMenuView *_scrollMenu;
}

- (instancetype)initWithTitle:(NSString *)title
{
	self = [super init];
	if (self)
	{
		_title = title;
		_menuItems = [NSMutableArray new];
		_menuViews = [NSMutableArray new];
	}
	return self;
}

- (void)addPageWithTitle:(NSString *)title view:(UIView *)view
{
	ScrollMenuItem *menu = [[ScrollMenuItem alloc] init];
	menu.title = title;
	[_menuItems addObject:menu];
	[_menuViews addObject:view];
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	_shouldObserving = YES;

	self.view.backgroundColor = [UIColor whiteColor];
	self.navigationItem.title = _title;

	_scrollView = [[ScrollView alloc] init];
	_scrollView.showsHorizontalScrollIndicator = NO;
	_scrollView.showsVerticalScrollIndicator = NO;
	_scrollView.delegate = self;
	_scrollView.pagingEnabled = YES;
	_scrollView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview:_scrollView];

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
	_scrollMenu.menuItems = _menuItems;
	[_scrollMenu reloadData];

	for (UIView *view in _menuViews)
	{
		[_scrollView addTabView:view];
	}

	[self constrainsInit];

}

- (void)constrainsInit
{
	NSDictionary *views = @{
			@"menu" : _scrollMenu,
			@"scrollView" : _scrollView
	};
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[menu]-0-|" options:0 metrics:nil views:views]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[scrollView]-0-|" options:0 metrics:nil views:views]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[menu(50)]-0-[scrollView]-0-|" options:0 metrics:nil views:views]];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.navigationController.navigationBar.topItem.title = @"";
	self.navigationItem.title = _title;
}

#pragma mark -- ScrollMenuViewDelegate

- (void)scrollMenuDidSelected:(ScrollMenuView *)scrollMenu menuIndex:(NSUInteger)selectIndex
{
	_shouldObserving = NO;
	[self menuSelectedIndex:selectIndex];
}

- (void)menuSelectedIndex:(NSUInteger)index
{
	[_scrollView scrollToIndex:index completion:^
	{
		self.shouldObserving = YES;
	}];
}

#pragma mark - ScrollView delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	CGFloat pageWidth = scrollView.frame.size.width;
	NSUInteger currentPage = (NSUInteger) (floor((scrollView.contentOffset.x - pageWidth * 0.5) / pageWidth) + 1);
	[_scrollMenu setSelectedIndex:currentPage animated:YES calledDelegate:NO];
}

@end
