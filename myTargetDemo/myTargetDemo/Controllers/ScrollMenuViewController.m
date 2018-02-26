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

@interface ScrollMenuPage : NSObject

@property (nonatomic) ScrollMenuItem *menuItem;
@property (nonatomic) UIView *menuView;
@property (nonatomic) NativeAdType adType;

@end

@implementation ScrollMenuPage

@end


@interface ScrollMenuViewController () <ScrollMenuViewDelegate, UIScrollViewDelegate, UITabBarDelegate>

@property(nonatomic) BOOL shouldObserving;

@end

@implementation ScrollMenuViewController
{
	NSMutableArray <ScrollMenuPage *> *_menuPages;
	NSString *_title;
	ScrollView *_scrollView;
	ScrollMenuView *_scrollMenu;
	UITabBar *_tabBar;
	UIView *_tabBarView;

	UITabBarItem *_tabBarItemStatic;
	UITabBarItem *_tabBarItemVideo;
	UITabBarItem *_tabBarItemCarousel;
	NSMutableArray<NSLayoutConstraint *> *_constraints;
}

- (instancetype)initWithTitle:(NSString *)title
{
	self = [super init];
	if (self)
	{
		_title = title;
		_menuPages = [NSMutableArray new];
		_constraints = [NSMutableArray<NSLayoutConstraint *> new];
	}
	return self;
}

- (void)addPageWithTitle:(NSString *)title view:(UIView *)view adType:(NativeAdType)adType
{
	ScrollMenuItem *menuItem = [[ScrollMenuItem alloc] init];
	menuItem.title = title;

	ScrollMenuPage *menuPage = [[ScrollMenuPage alloc] init];
	menuPage.menuItem = menuItem;
	menuPage.menuView = view;
	menuPage.adType = adType;
	[_menuPages addObject:menuPage];
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
	_scrollMenu.delegate = self;
	_scrollMenu.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview:_scrollMenu];

	UIColor *backgroundColor = [UIColor redColor];
	UIColor *selectedColor = [UIColor whiteColor];
	UIColor *unselectedColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7];
	UIFont *barItemFont = [UIFont fontWithName:@"Helvetica" size:14];

	[[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : unselectedColor, NSFontAttributeName : barItemFont } forState:UIControlStateNormal];
	[[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : selectedColor, NSFontAttributeName : barItemFont } forState:UIControlStateSelected];

	// Workaround for UITabBar on iPhone X
	_tabBarView = [[UIView alloc] init];
	_tabBarView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview:_tabBarView];

	_tabBar = [[UITabBar alloc] init];
	_tabBar.delegate = self;
	_tabBar.tintColor = selectedColor;
	_tabBar.barTintColor = backgroundColor;
	_tabBar.translatesAutoresizingMaskIntoConstraints = NO;
	[_tabBarView addSubview:_tabBar];

	[self setupConstraints];

	UIImage *imageStatic = [UIImage imageNamed:@"ic_static"];
	UIImage *imageStaticSelected = [[self imageFromImage:imageStatic withColor:selectedColor] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
	UIImage *imageStaticUnselected = [[self imageFromImage:imageStatic withColor:unselectedColor] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

	UIImage *imageVideo = [UIImage imageNamed:@"ic_video"];
	UIImage *imageVideoSelected = [[self imageFromImage:imageVideo withColor:selectedColor] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
	UIImage *imageVideoUnselected = [[self imageFromImage:imageVideo withColor:unselectedColor] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

	UIImage *imageCarousel = [UIImage imageNamed:@"ic_carousel"];
	UIImage *imageCarouselSelected = [[self imageFromImage:imageCarousel withColor:selectedColor] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
	UIImage *imageCarouselUnselected = [[self imageFromImage:imageCarousel withColor:unselectedColor] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

	_tabBarItemStatic = [[UITabBarItem alloc] initWithTitle:@"Static" image:imageStaticUnselected selectedImage:imageStaticSelected];
	_tabBarItemStatic.accessibilityIdentifier = @"tabBarItemStatic";
	_tabBarItemVideo = [[UITabBarItem alloc] initWithTitle:@"Video" image:imageVideoUnselected selectedImage:imageVideoSelected];
	_tabBarItemVideo.accessibilityIdentifier = @"tabBarItemVideo";
	_tabBarItemCarousel = [[UITabBarItem alloc] initWithTitle:@"Carousel" image:imageCarouselUnselected selectedImage:imageCarouselSelected];
	_tabBarItemCarousel.accessibilityIdentifier = @"tabBarItemCarousel";

	NSMutableOrderedSet<UITabBarItem *> *tabBarItems = [NSMutableOrderedSet new];
	for (ScrollMenuPage *menuPage in _menuPages)
	{
		switch (menuPage.adType) {
			case NativeAdTypeStatic:
				[tabBarItems addObject:_tabBarItemStatic];
				break;
			case NativeAdTypeVideo:
				[tabBarItems addObject:_tabBarItemVideo];
				break;
			case NativeAdTypeCarousel:
				[tabBarItems addObject:_tabBarItemCarousel];
				break;
			default:
				break;
		}
	}
	_tabBar.items = [tabBarItems array];

	if ([tabBarItems containsObject:_tabBarItemStatic])
	{
		[_tabBar setSelectedItem:_tabBarItemStatic];
		[self setupMenuForAdType:NativeAdTypeStatic];
	}
	else if ([tabBarItems containsObject:_tabBarItemVideo])
	{
		[_tabBar setSelectedItem:_tabBarItemVideo];
		[self setupMenuForAdType:NativeAdTypeVideo];
	}
	else if ([tabBarItems containsObject:_tabBarItemCarousel])
	{
		[_tabBar setSelectedItem:_tabBarItemCarousel];
		[self setupMenuForAdType:NativeAdTypeCarousel];
	}
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
		@"menu" : _scrollMenu,
		@"scrollView" : _scrollView,
		@"tabBar" : _tabBar,
		@"tabBarView" : _tabBarView
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

	[_constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-leftMargin-[menu]-rightMargin-|" options:0 metrics:metrics views:views]];
	[_constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-leftMargin-[scrollView]-rightMargin-|" options:0 metrics:metrics views:views]];
	[_constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-leftMargin-[tabBarView]-rightMargin-|" options:0 metrics:metrics views:views]];
	[_constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-topMargin-[menu(50)]-0-[scrollView]-0-[tabBarView(50)]-bottomMargin-|" options:0 metrics:metrics views:views]];

	[_constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[tabBar]-0-|" options:0 metrics:metrics views:views]];
	[_constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[tabBar]-0-|" options:0 metrics:metrics views:views]];

	[NSLayoutConstraint activateConstraints:_constraints];
}

- (UIImage *)imageFromImage:(UIImage *)image withColor:(UIColor *)color
{
	UIImage *newImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	UIGraphicsBeginImageContextWithOptions(image.size, NO, newImage.scale);
	[color set];
	[newImage drawInRect:CGRectMake(0, 0, image.size.width, newImage.size.height)];
	newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}

- (void)setupMenuForAdType:(NativeAdType)adType
{
	NSMutableArray *menuItems = [NSMutableArray new];
	[_scrollView removeTabViews];

	for (ScrollMenuPage *menuPage in _menuPages)
	{
		if (menuPage.adType == adType)
		{
			[menuItems addObject:menuPage.menuItem];
			[_scrollView addTabView:menuPage.menuView];
		}
	}

	if (_scrollView.tabsCount > 0)
	{
		[_scrollView scrollToIndex:0 completion:nil];
	}

	if (menuItems.count > 0)
	{
		[_scrollMenu setMenuItems:menuItems];
		[_scrollMenu setSelectedIndex:0];
		[_scrollMenu reloadData];
		[_scrollMenu setSelectedIndex:0 animated:YES calledDelegate:NO];
	}
}

#pragma mark - UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
	NativeAdType adType = NativeAdTypeStatic;
	if (item == _tabBarItemVideo)
	{
		adType = NativeAdTypeVideo;
	}
	else if (item == _tabBarItemCarousel)
	{
		adType = NativeAdTypeCarousel;
	}
	[self setupMenuForAdType:adType];
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
