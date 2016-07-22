//
// Created by Anton Bulankin on 04.07.16.
// Copyright (c) 2016 Mail.ru Group. All rights reserved.
//

#import "CustomAdItem.h"

@implementation CustomAdItem

- (instancetype)initWithType:(NSUInteger)adType slotId:(NSUInteger)slotId title:(NSString *)title
{
	self = [super init];
	if (self)
	{
		_adType = adType;
		_slotId = slotId;
		_title = title;
	}
	return self;
}

+ (NSString *)fileName
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	return [paths[0] stringByAppendingPathComponent:@"custom_ads"];
}

+ (NSMutableArray <CustomAdItem *> *)loadCustomAdItemsFromStorage
{
	NSMutableArray <CustomAdItem *> *customItems = [NSMutableArray new];
	NSData *data = [NSData dataWithContentsOfFile:[self fileName]];
	if (data)
	{
		NSError *error;
		NSDictionary *dict = (NSDictionary *) [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
		NSArray *itemsArray = dict[@"items"];
		for (NSDictionary *item in itemsArray)
		{
			NSNumber *slotId = item[@"slotId"];
			NSString *title = item[@"title"];
			NSNumber *type = item[@"type"];
			if (slotId && type)
			{
				CustomAdItem *adItem = [[CustomAdItem alloc] initWithType:type.unsignedLongValue slotId:slotId.unsignedLongValue title:title];
				[customItems addObject:adItem];
			}
		}
	}
	return customItems;
}

+ (void)saveAdItemsToStorage:(NSArray <CustomAdItem *> *)customAdItems
{
	NSMutableDictionary *dict = [NSMutableDictionary new];
	NSMutableArray *itemsArray = [NSMutableArray new];
	dict[@"items"] = itemsArray;
	for (CustomAdItem *item in customAdItems)
	{
		[itemsArray addObject:@{
				@"type" : @(item.adType),
				@"title" : item.title,
				@"slotId" : @(item.slotId)
		}];
	}
	NSError *error;
	NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
	if (data)
	{
		[data writeToFile:[self fileName] atomically:YES];
	}
}

@end
