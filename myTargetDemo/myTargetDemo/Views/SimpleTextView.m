//
// Created by Anton Bulankin on 01.07.16.
// Copyright (c) 2016 Mail.ru Group. All rights reserved.
//

#import "SimpleTextView.h"

@implementation SimpleTextView
{
	UILabel *_titleLabel;
	UILabel *_infoLabel;
}

- (instancetype)init
{
	self = [super init];
	if (self)
	{
		_titleLabel = [[UILabel alloc] init];
		_infoLabel = [[UILabel alloc] init];

		_titleLabel.text = @"Lorem ipsum dolor sit amet";
		_titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
		_titleLabel.numberOfLines = 1;
		_titleLabel.textColor = [UIColor blackColor];

		_infoLabel.text = @"Lorem ipsum dolor sit amet, error ceteros ex mea, possim equidem verterem cum no. Eum deleniti detraxit ea. Praesent inciderint at quo, at pro munere facete, libris delenit ei cum. Laoreet argumentum his et, mei ne eros paulo delicata. Porro soluta singulis cum ad, pro ad viderer complectitur. At cum illum veritus. Duo in sanctus splendide disputando, sed case tantas eligendi in.";
		_infoLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
		_infoLabel.textColor = [UIColor grayColor];
		_infoLabel.lineBreakMode = NSLineBreakByTruncatingTail;
		_infoLabel.numberOfLines = 0;

		[self addSubview:_titleLabel];
		[self addSubview:_infoLabel];

	}
	return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	[self doLayoutWithWidth:self.frame.size.width];
}

- (void)doLayoutWithWidth:(CGFloat)width
{
	if (width <= 0) return;
	CGFloat margin = 10;
	CGFloat labelWidth = width - 2 * margin;
	CGSize titleSize = [_titleLabel sizeThatFits:CGSizeMake(labelWidth, 1000)];
	CGSize infoSize = [_infoLabel sizeThatFits:CGSizeMake(labelWidth, 1000)];
	_titleLabel.frame = CGRectMake(margin, margin, labelWidth, titleSize.height);
	_infoLabel.frame = CGRectMake(margin, 2 * margin + titleSize.height, labelWidth, infoSize.height);
}

- (CGSize)calculateSizeForWidth:(CGFloat)width
{
	if (width <= 0) return CGSizeZero;
	[self doLayoutWithWidth:width];
	CGFloat bottomMargin = 10;
	return CGSizeMake(width, _infoLabel.frame.origin.y + _infoLabel.frame.size.height + bottomMargin);
}

@end