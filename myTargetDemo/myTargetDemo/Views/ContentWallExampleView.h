//
// Created by Anton Bulankin on 01.07.16.
// Copyright (c) 2016 Mail.ru Group. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ContentWallExampleView : UIView

- (instancetype)initWithController:(UIViewController *)controller slotId:(NSUInteger)slotId;

- (void)reloadAd;

@end