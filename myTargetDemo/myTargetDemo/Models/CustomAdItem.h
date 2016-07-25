//
// Created by Anton Bulankin on 04.07.16.
// Copyright (c) 2016 Mail.ru Group. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "AdTypes.h"

@interface CustomAdItem : NSObject

@property(nonatomic) NSUInteger adType;
@property(nonatomic) NSUInteger slotId;
@property(nonatomic) NSString *title;

- (instancetype)initWithType:(NSUInteger)adType slotId:(NSUInteger)slotId title:(NSString *)title;

+ (NSMutableArray <CustomAdItem *> *)loadCustomAdItemsFromStorage;

+ (void)saveAdItemsToStorage:(NSArray <CustomAdItem *> *)customAdItems;

@end
