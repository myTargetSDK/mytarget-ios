//
//  AdItem.m
//  myTargetDemo
//
//  Created by Andrey Seredkin on 29.12.16.
//  Copyright © 2016 Mail.ru Group. All rights reserved.
//

#import "AdItem.h"

static NSString * const kAdItemSlotIdTypeDefault = @"Default";
static NSString * const kAdItemSlotIdTypeNativeVideo = @"NativeVideo";
static NSString * const kAdItemSlotIdTypeNativeCarousel = @"NativeCarousel";
static NSString * const kAdItemSlotIdTypeStandard300x250 = @"Standard300x250";

@implementation AdItem
{
	NSMutableDictionary<NSString *, NSNumber *> *_slotIds;
}

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
		_slotIds = [NSMutableDictionary<NSString *, NSNumber *> new];
	}
	return self;
}

- (NSString *)slotIdKeyByType:(AdItemSlotIdType)type
{
	NSString *slotIdKey = nil;
	switch (type)
	{
		case AdItemSlotIdTypeNativeVideo:
			slotIdKey = kAdItemSlotIdTypeNativeVideo;
			break;
		case AdItemSlotIdTypeNativeCarousel:
			slotIdKey = kAdItemSlotIdTypeNativeCarousel;
			break;
		case AdItemSlotIdTypeStandard300x250:
			slotIdKey = kAdItemSlotIdTypeStandard300x250;
			break;

		default:
			slotIdKey = kAdItemSlotIdTypeDefault;
			break;
	}
	return slotIdKey;
}

- (void)setSlotId:(NSInteger)slotId type:(AdItemSlotIdType)type
{
	if (slotId <= 0) return;

	if (type == AdItemSlotIdTypeDefault)
	{
		_slotId = slotId;
	}

	NSString *slotIdKey = [self slotIdKeyByType:type];
	NSNumber *slotIdValue = [NSNumber numberWithInteger:slotId];
	if (slotIdKey && slotIdValue)
	{
		[_slotIds setObject:slotIdValue forKey:slotIdKey];
	}
}

- (NSInteger)slotIdForType:(AdItemSlotIdType)type
{
	NSInteger slotId = (type == AdItemSlotIdTypeDefault) ? _slotId : 0;
	NSString *slotIdKey = [self slotIdKeyByType:type];
	if (slotIdKey)
	{
		NSNumber *slotIdValue = [_slotIds objectForKey:slotIdKey];
		if (slotIdValue)
		{
			slotId = slotIdValue.integerValue;
		}
	}
	return slotId;
}

@end
