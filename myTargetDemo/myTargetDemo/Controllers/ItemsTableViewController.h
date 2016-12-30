//
//  ItemsTableViewController.h
//  myTargetDemo
//
//  Created by Anton Bulankin on 23.06.16.
//  Copyright © 2016 Mail.ru Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdItem.h"

@interface ItemsTableViewController : UITableViewController

@property(nonatomic, readonly) NSArray<AdItem *> *adItems;

- (instancetype)initWithTitle:(NSString *)title;

- (void)addAdItem:(AdItem *)adItem;

- (void)itemClick:(AdItem *)adItem;

- (void)updateStatusForAdItem:(AdItem *)adItem;

- (void)reload;

- (void)clearItems;

@end
