//
//  ItemsTableViewController.h
//  myTargetDemo
//
//  Created by Anton Bulankin on 23.06.16.
//  Copyright © 2016 Mail.ru Group. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomAdItem;

@interface AdItem : NSObject

@property(nonatomic) NSString *title;
@property(nonatomic) NSString *info;
@property(nonatomic) UIColor *color;
@property(nonatomic) UIImage *image;
@property(nonatomic) NSUInteger tag;
@property(nonatomic) BOOL isLoading;
@property(nonatomic) NSUInteger slotId;
@property(nonatomic) NSUInteger slotIdVideo;
@property(nonatomic) NSUInteger slotIdCarousel;
@property(nonatomic) CustomAdItem *customItem;
@property(nonatomic) BOOL canRemove;

- (instancetype)initWithTitle:(NSString *)title info:(NSString *)info;

@end

@interface ItemsTableViewController : UITableViewController

@property(nonatomic, readonly) NSArray<AdItem *> *adItems;

- (instancetype)initWithTitle:(NSString *)title;

- (void)addAdItem:(AdItem *)adItem;

- (void)itemClick:(AdItem *)adItem;

- (void)updateStatusForAdItem:(AdItem *)adItem;

- (void)reload;

- (void)clearItems;

@end
