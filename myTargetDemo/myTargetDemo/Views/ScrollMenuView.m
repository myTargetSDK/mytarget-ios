//
//  ScrollMenuView.m
//  myTargetDemo
//
//  Created by Anton Bulankin on 28.06.16.
//  Copyright © 2016 Mail.ru Group. All rights reserved.
//

#import "ScrollMenuView.h"

@implementation ScrollMenuItem

- (instancetype)initWithTitle:(NSString *)title
{
	self = [super init];
	if (self)
	{
		_title = title;
	}
	return self;
}

@end

@interface ScrollMenuView () <UIScrollViewDelegate>

@end

@implementation ScrollMenuView
{
	UIView *_indicatorView;
	CGFloat _indicatorHeight;
	NSMutableArray *_menuButtons;
	CGFloat _buttonFirstX;
	CGFloat _buttonsInterval;
}

- (void)menuButtonSelected:(UIButton *)sender
{
	NSUInteger index = 0;
	NSUInteger i = 0;
	for (UIButton *menuButton in _menuButtons)
	{
		menuButton.selected = sender == menuButton;
		if (sender == menuButton) index = i;
		++i;
	}
	[self setSelectedIndex:index animated:YES calledDelegate:YES];
}


- (void)layoutSubviews
{
	[super layoutSubviews];
	_scrollView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

- (CGRect)calcIndicatorForButtonFrame:(CGRect)buttonFrame
{
	return CGRectMake(buttonFrame.origin.x, 50 - _indicatorHeight, buttonFrame.size.width, _indicatorHeight);
}

- (UIButton *)createButtonForItem:(ScrollMenuItem *)menuItem
{
	UIButton *button = [[UIButton alloc] init];
	button.titleLabel.textAlignment = NSTextAlignmentCenter;
	button.titleLabel.font = self.tabTitleFont;
	[button setTitle:menuItem.title forState:UIControlStateNormal];
	if (self.tabTitleColor)
		[button setTitleColor:self.tabTitleColor forState:UIControlStateNormal];
	if (self.tabtitleHighlightedColor)
		[button setTitleColor:self.tabtitleHighlightedColor forState:UIControlStateHighlighted];
	if (self.tabTitleSelectedColor)
		[button setTitleColor:self.tabTitleSelectedColor forState:UIControlStateSelected];
	[button addTarget:self action:@selector(menuButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
	return button;
}

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
	{
		_menuButtons = [NSMutableArray new];
		_selectedIndex = 0;
		_indicatorHeight = 3;
		_buttonFirstX = 8;
		_buttonsInterval = 30;

		_scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
		[_scrollView setScrollsToTop:NO];
		_scrollView.showsVerticalScrollIndicator = NO;
		_scrollView.showsHorizontalScrollIndicator = NO;
		_scrollView.delegate = self;

		_indicatorView = [[UIView alloc] init];
		_indicatorView.backgroundColor = [UIColor colorWithRed:248 / 255.f green:48 / 255.f blue:63 / 255.f alpha:1];
		_indicatorView.frame = CGRectMake(0, 0, 0, 3);
		_indicatorView.alpha = 0;
		[_scrollView addSubview:_indicatorView];

		[self addSubview:self.scrollView];
		[self sendSubviewToBack:self.scrollView];

		[self setupView];
	}
	return self;
}

- (void)setupView
{
	self.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.5];
	self.tabTitleColor = [UIColor whiteColor];
	self.backgroundColor = [UIColor colorWithRed:248 / 255.f green:48 / 255.f blue:63 / 255.f alpha:1];
	self.tabTitleFont = [UIFont fontWithName:@"Helvetica-Bold" size:14];
	self.layer.shadowColor = [UIColor grayColor].CGColor;
	self.layer.shadowRadius = 5.0;
	self.layer.shadowOpacity = 0.6;
	self.layer.shadowOffset = CGSizeMake(0, 5.0);
}

- (void)setTabTitleColor:(UIColor *)tabTitleColor
{
	_tabTitleColor = tabTitleColor;
	if (_tabTitleColor)
	{
		_indicatorView.backgroundColor = _tabTitleColor;
	}
}

#pragma mark - Public

- (void)moveToCenter:(UIButton *)menuButton
{
	CGRect visibleRect = menuButton.frame;
	CGRect centeredRect = CGRectMake(visibleRect.origin.x + visibleRect.size.width / 2.0f - self.frame.size.width / 2.0f,
			visibleRect.origin.y + visibleRect.size.height / 2.0f - self.frame.size.height / 2.0f,
			self.frame.size.width,
			self.frame.size.height);
	[_scrollView scrollRectToVisible:centeredRect animated:NO];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)aniamted calledDelegate:(BOOL)calledDelgate
{
	UIButton *towardsButton = _menuButtons[selectedIndex];
	towardsButton.selected = YES;
	UIButton *prousButton = _menuButtons[_selectedIndex];
	prousButton.selected = (_selectedIndex == selectedIndex && !selectedIndex);

	_selectedIndex = selectedIndex;
	UIButton *selectedMenuButton = _menuButtons[_selectedIndex];
	[UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^
	{
		[self moveToCenter:selectedMenuButton];

	}
					 completion:^(BOOL finished)
	{
		if (aniamted)
		{
			[UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveLinear animations:^
			{
				_indicatorView.frame = [self calcIndicatorForButtonFrame:selectedMenuButton.frame];
			}
							 completion:^(BOOL finished)
			{
				if (calledDelgate)
				{
					if ([self.delegate respondsToSelector:@selector(scrollMenuDidSelected:menuIndex:)])
					{
						[self.delegate scrollMenuDidSelected:self menuIndex:self.selectedIndex];
					}
				}
			}];
		}
		else
		{
			_indicatorView.frame = [self calcIndicatorForButtonFrame:selectedMenuButton.frame];
		}
	}];
}

- (void)reloadData
{
	for (UIButton *button in _menuButtons)
	{
		[button removeFromSuperview];
	}
	[_menuButtons removeAllObjects];
	CGFloat viewHeight = 50;

	CGFloat nextButtonX = _buttonFirstX;

	for (ScrollMenuItem *menu in self.menuItems)
	{
		NSUInteger index = [self.menuItems indexOfObject:menu];
		UIButton *menuButton = [self createButtonForItem:menu];
		CGFloat buttonWidth = [menuButton sizeThatFits:CGSizeMake(1000, viewHeight)].width;
		CGRect menuButtonFrame = CGRectMake(nextButtonX, 0, buttonWidth, viewHeight);
		menuButton.frame = menuButtonFrame;
		[self.scrollView addSubview:menuButton];
		nextButtonX += menuButtonFrame.size.width + _buttonsInterval;
		[_menuButtons addObject:menuButton];
		if (self.selectedIndex == index)
		{
			menuButton.selected = YES;
			_indicatorView.alpha = 1.0;
			_indicatorView.frame = [self calcIndicatorForButtonFrame:menuButtonFrame];
		}
	}

	[self.scrollView setContentSize:CGSizeMake(nextButtonX, viewHeight)];
	[self setSelectedIndex:self.selectedIndex animated:NO calledDelegate:YES];
}

@end
