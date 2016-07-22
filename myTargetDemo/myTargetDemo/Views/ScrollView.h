//
// Created by Anton Bulankin on 29.06.16.
// Copyright (c) 2016 Mail.ru Group. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScrollView : UIScrollView

- (void)addTabView:(UIView *)view;

- (void)scrollToIndex:(NSUInteger)pageIndex completion:(void (^)())completion;

@end
