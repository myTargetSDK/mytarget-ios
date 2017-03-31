//
// Created by Anton Bulankin on 29.06.16.
// Copyright (c) 2016 Mail.ru Group. All rights reserved.
//

#import "ScrollView.h"

@implementation ScrollView
{
	NSMutableArray *_tabViews;
	NSUInteger _activePageIndex;
	CGSize _selfSize;
}

- (instancetype)init
{
	self = [super init];
	if (self)
	{
		_tabViews = [NSMutableArray new];
		_activePageIndex = 0;
		_selfSize = CGSizeZero;
	}
	return self;
}

- (void)addTabView:(UIView *)view
{
	[_tabViews addObject:view];
	[self addSubview:view];
}

- (void)removeTabViews
{
	for (NSInteger index = _tabViews.count - 1; index >= 0; index--)
	{
		UIView *view = [_tabViews objectAtIndex:index];
		[view removeFromSuperview];
		[_tabViews removeObjectAtIndex:index];
	}
	_activePageIndex = 0;
}

- (NSUInteger)tabsCount
{
	return _tabViews.count;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	CGSize size = self.frame.size;
	NSUInteger i = 0;
	for (UIView *view in _tabViews)
	{
		view.frame = CGRectMake(i * size.width, 0, size.width, size.height);
		++i;
	}
	if (CGSizeEqualToSize(_selfSize, CGSizeZero))
	{
		_selfSize = self.frame.size;
	}

	CGSize newContentSize = CGSizeMake(size.width * _tabViews.count, size.height);
	if (!CGSizeEqualToSize(self.contentSize, newContentSize))
	{
		self.contentSize = newContentSize;
	}

	if (!CGSizeEqualToSize(size, _selfSize))
	{
		CGRect frame = [self frameForPage:_activePageIndex];
		[self scrollRectToVisible:frame animated:NO];
		_selfSize = size;
	}
}

- (CGRect)frameForPage:(NSUInteger)pageIndex
{
	CGSize size = self.frame.size;
	return CGRectMake(pageIndex * size.width, 0, size.width, size.height);
}

- (void)scrollToIndex:(NSUInteger)pageIndex completion:(void (^)())completion
{
	CGRect visibleRect = [self frameForPage:pageIndex];
	_activePageIndex = pageIndex;
	[UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^
	{
		[self scrollRectToVisible:visibleRect animated:NO];
	}                completion:^(BOOL finished)
	{
		if (completion)
		{
			completion();
		}
	}];
}

@end
