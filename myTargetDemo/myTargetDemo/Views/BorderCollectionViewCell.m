//
// Created by Anton Bulankin on 05.07.16.
// Copyright (c) 2016 Mail.ru Group. All rights reserved.
//

#import "BorderCollectionViewCell.h"

@implementation BorderCollectionViewCell
{
	CALayer *_lineLayer;
}

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
	{
		_lineLayer = [[CALayer alloc] init];
		_lineLayer.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.5].CGColor;
		[self.layer addSublayer:_lineLayer];
	}
	return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	_lineLayer.frame = CGRectMake(0, self.frame.size.height - 1, self.frame.size.width, 0.6f);
}

@end