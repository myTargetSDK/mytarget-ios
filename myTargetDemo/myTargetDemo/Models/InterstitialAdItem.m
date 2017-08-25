//
//  InterstitialAdItem.m
//  myTargetDemo
//
//  Created by Andrey Seredkin on 08.08.17.
//  Copyright © 2017 Mail.ru Group. All rights reserved.
//

#import "InterstitialAdItem.h"

@implementation InterstitialAdItem

- (instancetype)initWithTitle:(NSString *)title info:(NSString *)info
{
	self = [super initWithTitle:title info:info];
	if (self)
	{
		_isLoadedSuccess = NO;
	}
	return self;
}

@end
