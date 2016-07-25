//
// Created by Anton Bulankin on 03.07.16.
// Copyright (c) 2016 Mail.ru Group. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomAdItem;

@protocol NewAdUnitControllerDelegate <NSObject>

@required

- (void)newAdUnitControllerNewCustomAdItem:(CustomAdItem *)newCustomAdItem;

@end

@interface NewAdUnitController : UIViewController

- (instancetype)initWithDelegate:(id <NewAdUnitControllerDelegate>)delegate;

@end