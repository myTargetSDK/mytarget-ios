//
//  ItemsTableViewController.m
//  myTargetDemo
//
//  Created by Anton Bulankin on 23.06.16.
//  Copyright © 2016 Mail.ru Group. All rights reserved.
//

#import "ItemsTableViewController.h"
#import "CustomAdItem.h"

@implementation AdItem

- (instancetype)initWithTitle:(NSString *)title info:(NSString *)info
{
	self = [super init];
	if (self)
	{
		_title = title;
		_info = info;
		_tag = 0;
		_isLoading = NO;
		_canRemove = NO;
	}
	return self;
}

@end


@class AdItemView;

@protocol AdItemViewDelegate <NSObject>

- (BOOL)itemViewTouchBegin:(AdItemView *)itemView;

- (void)itemViewTouchEnd:(AdItemView *)itemView;

- (void)itemViewTouchCancel:(AdItemView *)itemView;

- (void)itemViewRemoveButtonClick:(AdItemView *)itemView;


@end

@interface ItemsTableViewController () <AdItemViewDelegate>

@end


@interface AdItemView : UIView

- (void)setItem:(AdItem *)adItem;

- (void)updateStatus;

@end

@implementation AdItemView
{
	id <AdItemViewDelegate> _delegate;
	__weak AdItem *_adItem;

	UILabel *_titleLabel;
	UILabel *_infoLabel;
	UIImageView *_imageView;
	UIView *_colorView;
	UIActivityIndicatorView *_progressView;
	BOOL _touchDown;
	UILabel *_mainTextLabel;
	UIButton *_removeButton;
}

- (instancetype)initWithDelegate:(id <AdItemViewDelegate>)delegate
{
	self = [super init];
	if (self)
	{
		_delegate = delegate;

		_touchDown = NO;
		_titleLabel = [[UILabel alloc] init];
		[self addSubview:_titleLabel];
		_titleLabel.numberOfLines = 1;
		_titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];

		_infoLabel = [[UILabel alloc] init];
		_infoLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
		_infoLabel.textColor = [UIColor grayColor];
		[self addSubview:_infoLabel];
		_infoLabel.numberOfLines = 2;

		_colorView = [[UIView alloc] init];
		[self addSubview:_colorView];

		_imageView = [[UIImageView alloc] init];
		[_colorView addSubview:_imageView];

		_progressView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		_progressView.frame = CGRectMake(5, 5, 20, 20);
		[self addSubview:_progressView];

		_mainTextLabel = [[UILabel alloc] init];
		_mainTextLabel.backgroundColor = [UIColor clearColor];
		_mainTextLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
		_mainTextLabel.font = [UIFont fontWithName:@"Helvetica" size:32];
		_mainTextLabel.textAlignment = NSTextAlignmentCenter;

		[self addSubview:_mainTextLabel];

		self.backgroundColor = [UIColor whiteColor];
		self.layer.cornerRadius = 4;
		self.layer.borderColor = [UIColor grayColor].CGColor;
		self.layer.borderWidth = 0.5;
		self.clipsToBounds = YES;

		_removeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[_removeButton setTitle:@"\U000000D7" forState:UIControlStateNormal];
		_removeButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:32];
		//274C
		[_removeButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
		_removeButton.hidden = YES;
		[self addSubview:_removeButton];
		_removeButton.backgroundColor = [UIColor clearColor];
		[_removeButton addTarget:self action:@selector(removeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

	}
	return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];

	CGSize size = self.frame.size;
	CGFloat margin = 6;
	CGFloat textsHeight = 80;
	_colorView.frame = CGRectMake(0, 0, size.width, size.height - textsHeight);
	_mainTextLabel.frame = CGRectMake(0, 0, _colorView.frame.size.width, _colorView.frame.size.height);

	CGSize titleSize = [_titleLabel sizeThatFits:CGSizeMake(size.width - 2 * margin, 100)];
	_titleLabel.frame = CGRectMake(margin, _colorView.frame.origin.y + _colorView.frame.size.height + margin,
			titleSize.width, titleSize.height);
	CGSize infoSize = [_infoLabel sizeThatFits:CGSizeMake(size.width - 2 * margin, 100)];
	_infoLabel.frame = CGRectMake(margin, _titleLabel.frame.origin.y + _titleLabel.frame.size.height + margin,
			infoSize.width, infoSize.height);
	CGFloat imageMargin = 10;
	CGFloat imageHeight = _colorView.frame.size.height - 2 * imageMargin;
	CGFloat imageWidth = (int) (_imageView.image.size.width / _imageView.image.size.height * imageHeight);
	_imageView.frame = CGRectMake(0.5f * (_colorView.frame.size.width - imageWidth), imageMargin, imageWidth, imageHeight);

	_removeButton.frame = CGRectMake(size.width - 40, 0, 40, 40);

}

- (void)setItem:(AdItem *)adItem
{
	_adItem = adItem;
	_titleLabel.text = adItem.title;
	_infoLabel.text = adItem.info;

	if (adItem.customItem)
	{
		_colorView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
		_mainTextLabel.text = [NSString stringWithFormat:@"%@", @(adItem.slotId)];
	}
	else
	{
		_imageView.image = adItem.image;
		_colorView.backgroundColor = adItem.color;
	}
	_mainTextLabel.hidden = !adItem.customItem;
	_imageView.hidden = adItem.customItem != nil;

	_removeButton.hidden = !adItem.canRemove;

	[self updateStatus];
}

- (void)removeButtonTapped:(id)sender
{
	[_delegate itemViewRemoveButtonClick:self];
}

- (void)updateStatus
{
	if (!_adItem)return;
	if (_adItem.isLoading && !_progressView.isAnimating)
	{
		[_progressView startAnimating];
	}
	else if (!_adItem.isLoading && _progressView.isAnimating)
	{
		[_progressView stopAnimating];
	}
	_progressView.hidden = !_adItem.isLoading;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if ([_delegate itemViewTouchBegin:self])
	{
		_touchDown = YES;
		[self doTouchAnimation:YES];
	}
	[super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (_touchDown)
	{
		_touchDown = NO;
		[_delegate itemViewTouchEnd:self];
		[self doTouchAnimation:NO];
	}
	[super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (_touchDown)
	{
		[_delegate itemViewTouchCancel:self];
		[self doTouchAnimation:NO];
		_touchDown = NO;
	}
	[super touchesCancelled:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [[event touchesForView:self] anyObject];
	CGPoint touchLocation = [touch locationInView:self];
	CGRect frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
	if (!CGRectContainsPoint(frame, touchLocation))
	{
		if (_touchDown)
		{
			[_delegate itemViewTouchCancel:self];
			[self doTouchAnimation:NO];
			_touchDown = NO;
		}
	}
	[super touchesMoved:touches withEvent:event];
}

- (void)doTouchAnimation:(BOOL)isActive
{
	if (isActive)
	{
		self.layer.borderColor = [UIColor colorWithRed:0 green:171 / 255.0 blue:242 / 255.0 alpha:1].CGColor;
		self.layer.borderWidth = 1;
	}
	else
	{
		self.layer.borderColor = [UIColor grayColor].CGColor;
		self.layer.borderWidth = 0.5;
	}
}

@end


@interface ItemsTableViewCell : UITableViewCell

@end

@implementation ItemsTableViewCell
{
	NSArray <AdItemView *> *_adItemViews;
	NSUInteger _columns;
}

- (void)setItemViews:(NSArray <AdItemView *> *)adItemViews columns:(NSUInteger)columns
{
	if (_adItemViews)
		for (AdItemView *itemView in _adItemViews)
			[itemView removeFromSuperview];

	_columns = columns;
	_adItemViews = adItemViews;

	for (AdItemView *itemView in _adItemViews)
	{
		[self addSubview:itemView];
	}
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	if (_columns == 0) return;
	if (!_adItemViews) return;
	CGFloat margin = 10;
	CGFloat itemWidth = (self.frame.size.width - (_columns + 1) * margin) / _columns;
	CGFloat itemHeight = self.frame.size.height - margin;
	NSUInteger idx = 0;
	for (AdItemView *itemView  in _adItemViews)
	{
		itemView.frame = CGRectMake((int) (margin * (idx + 1) + idx * itemWidth), margin, itemWidth, itemHeight);
		++idx;
	}
}

@end

@implementation ItemsTableViewController
{
	NSMutableArray<AdItem *> *_adItems;
	NSMutableArray<AdItemView *> *_adItemsViews;
	AdItemView *_activeItemView;
	NSString *_title;
	NSArray<UIColor *> *_colors;
	NSUInteger _columns;
}

static NSString *const reuseIdentifier = @"ItemsTableViewCell";

- (instancetype)initWithTitle:(NSString *)title
{
	self = [super init];
	if (self)
	{
		_title = title;
		_adItemsViews = [NSMutableArray new];
		_adItems = [NSMutableArray new];
		_colors = [ItemsTableViewController itemsColors];
		_columns = 2;

	}
	return self;
}

- (void)addAdItem:(AdItem *)adItem
{
	[_adItems addObject:adItem];
	if (!adItem.color)
	{
		adItem.color = _colors[(_adItems.count - 1) % (_colors.count - 1)];
	}
	AdItemView *adItemView = [[AdItemView alloc] initWithDelegate:self];
	[adItemView setItem:adItem];
	[_adItemsViews addObject:adItemView];
}


- (void)itemClick:(AdItem *)adItem
{
	//override
}

- (void)updateStatusForAdItem:(AdItem *)adItem
{
	if (!adItem) return;
	AdItemView *adItemView = _adItemsViews[[_adItems indexOfObject:adItem]];
	[adItemView updateStatus];
}

- (void)reload
{
	[self.tableView reloadData];
}

- (void)clearItems
{
	[_adItems removeAllObjects];
	[_adItemsViews removeAllObjects];
}

+ (NSArray<UIColor *> *)itemsColors
{
	return @[
			[UIColor colorWithRed:63 / 255.f green:81 / 255.f blue:181 / 255.f alpha:1], //INDIGO
			[UIColor colorWithRed:0 / 255.f green:150 / 255.f blue:136 / 255.f alpha:1], //TEAL
			[UIColor colorWithRed:244 / 255.f green:67 / 255.f blue:54 / 255.f alpha:1], //RED
			[UIColor colorWithRed:76 / 255.f green:175 / 255.f blue:80 / 255.f alpha:1], //GREEN
			[UIColor colorWithRed:156 / 255.f green:139 / 255.f blue:176 / 255.f alpha:1] //PURPLE
	];
}

- (NSArray<AdItem *> *)adItems
{
	return _adItems;
}

#pragma mark - AdItemViewDelegate

- (BOOL)itemViewTouchBegin:(AdItemView *)itemView
{
	if (_activeItemView) return NO;
	_activeItemView = itemView;
	return YES;
}

- (void)itemViewTouchEnd:(AdItemView *)itemView
{
	AdItem *adItem = _adItems[[_adItemsViews indexOfObject:itemView]];
	_activeItemView = nil;
	[self itemClick:adItem];
}

- (void)itemViewTouchCancel:(AdItemView *)itemView
{
	_activeItemView = nil;
}

- (void)itemViewRemoveButtonClick:(AdItemView *)itemView
{
	AdItem *adItem = _adItems[[_adItemsViews indexOfObject:itemView]];
	if (adItem)
	{
		[_adItemsViews removeObject:itemView];
		[_adItems removeObject:adItem];
		[self didRemoveItem:adItem];
		[self.tableView reloadData];
	}
}

#pragma mark

- (void)didRemoveItem:(AdItem *)adItem
{
	// override
}

#pragma mark -

- (void)viewDidLoad
{
	[super viewDidLoad];

	[self.tableView registerClass:[ItemsTableViewCell class] forCellReuseIdentifier:reuseIdentifier];
	self.tableView.allowsSelection = NO;
	[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
	self.tableView.backgroundColor = [UIColor whiteColor];

	[self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:248 / 255.f green:48 / 255.f blue:63 / 255.f alpha:1]];
	[self.navigationController.navigationBar setTranslucent:NO];
	self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

	NSDictionary *attributes = @{
			NSForegroundColorAttributeName : [UIColor whiteColor]
	};
	[self.navigationController.navigationBar setTitleTextAttributes:attributes];

	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

	self.navigationController.navigationBar.topItem.title = @"";
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.navigationItem.title = _title;
}

- (BOOL)prefersStatusBarHidden
{
	return NO;
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return (NSInteger) ceilf(1.0f * _adItems.count / _columns);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	ItemsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
	NSUInteger first = _columns * indexPath.row;
	NSRange range = NSMakeRange(first, first + _columns < _adItemsViews.count ? _columns : _adItemsViews.count - first);
	NSArray *views = [_adItemsViews subarrayWithRange:range];
	[cell setItemViews:views columns:_columns];
	cell.backgroundColor = [UIColor clearColor];
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CGSize size = tableView.frame.size;
	CGFloat height = 280;
	if (size.width > size.height)
	{
		height = 220;
	}
	return height;
}

@end
