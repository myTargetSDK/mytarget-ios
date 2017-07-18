//
//  AdItem.h
//  myTargetDemo
//
//  Created by Andrey Seredkin on 29.12.16.
//  Copyright © 2016 Mail.ru Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomAdItem.h"

typedef enum : NSUInteger
{
	AdItemSlotIdTypeDefault,
	AdItemSlotIdTypeNativeVideo,
	AdItemSlotIdTypeNativeCarousel,
	AdItemSlotIdTypeStandard300x250,
	AdItemSlotIdTypeStandard728x90
} AdItemSlotIdType;

@interface AdItem : NSObject

@property(nonatomic) NSString *title;
@property(nonatomic) NSString *info;
@property(nonatomic) UIColor *color;
@property(nonatomic) UIImage *image;
@property(nonatomic) NSUInteger tag;
@property(nonatomic) BOOL isLoading;
@property(nonatomic) NSUInteger slotId;
@property(nonatomic) CustomAdItem *customItem;
@property(nonatomic) BOOL canRemove;

- (instancetype)initWithTitle:(NSString *)title info:(NSString *)info;

- (void)setSlotId:(NSInteger)slotId type:(AdItemSlotIdType)type;

- (NSInteger)slotIdForType:(AdItemSlotIdType)type;

@end
