//
//  VideoProgressView.m
//  myTargetDemo
//
//  Created by Andrey Seredkin on 19.01.17.
//  Copyright © 2017 Mail.ru Group. All rights reserved.
//

#import "VideoProgressView.h"

static CGFloat const kAdvertisingPointWidth = 3.0;

@interface AdvertisingPoint : NSObject

@property (nonatomic) NSNumber *point;
@property (nonatomic) UIView *view;

@end

@implementation AdvertisingPoint

@end


@implementation VideoProgressView
{
	NSTimeInterval _duration;
	NSTimeInterval _position;
	NSMutableArray<AdvertisingPoint *> *_advertisingPoints;

	UIView *_progressView;
}

- (instancetype)initWithDuration:(NSTimeInterval)duration
{
	self = [super init];
	if (self)
	{
		_duration = duration;
		_position = 0;
		[self setupView];
	}
	return self;
}

- (void)setPosition:(NSTimeInterval)position
{
	_position = position;

	[self setNeedsLayout];
	[self layoutIfNeeded];
}

- (void)setAdPoints:(NSArray<NSNumber *> *)points
{
	for (AdvertisingPoint *advertisingPoint in _advertisingPoints)
	{
		[advertisingPoint.view removeFromSuperview];
	}
	_advertisingPoints = [NSMutableArray new];

	for (NSNumber *point in points)
	{
		if (0 <= point.floatValue && point.floatValue <= _duration)
		{
			UIView *view = [[UIView alloc] init];
			view.backgroundColor = [[UIColor yellowColor] colorWithAlphaComponent:0.4];

			AdvertisingPoint *advertisingPoint = [[AdvertisingPoint alloc] init];
			advertisingPoint.point = point;
			advertisingPoint.view = view;

			[_advertisingPoints addObject:advertisingPoint];
			[self addSubview:advertisingPoint.view];
		}
	}

	[self setNeedsLayout];
	[self layoutIfNeeded];
}

- (void)setupView
{
	self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];

	_progressView = [[UIView alloc] init];
	_progressView.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.4];
	[self addSubview:_progressView];
}

#pragma mark - layout

- (void)layoutSubviews
{
	[super layoutSubviews];

	CGFloat width = CGRectGetWidth(self.frame);
	CGFloat height = CGRectGetHeight(self.frame);

	CGFloat progressWidth = (_duration > 0) ? width * _position / _duration : 0;
	_progressView.frame = CGRectMake(0, 0, progressWidth, height);

	for (AdvertisingPoint *advertisingPoint in _advertisingPoints)
	{
		CGFloat pointValue = advertisingPoint.point.floatValue;
		if (0 <= pointValue && pointValue <= _duration)
		{
			CGFloat offsetX = (_duration > 0) ? width * pointValue / _duration : 0;
			advertisingPoint.view.frame = CGRectMake(offsetX, 0, kAdvertisingPointWidth, height);
		}
	}
}

@end
