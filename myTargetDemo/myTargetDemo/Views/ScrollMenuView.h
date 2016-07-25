//
//  ScrollMenuView.h
//  myTargetDemo
//
//  Created by Anton Bulankin on 28.06.16.
//  Copyright © 2016 Mail.ru Group. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ScrollMenuView;

@interface ScrollMenuItem : NSObject

@property(nonatomic, copy) NSString *title;

@end

@protocol ScrollMenuViewDelegate <NSObject>

- (void)scrollMenuDidSelected:(ScrollMenuView *)scrollMenu menuIndex:(NSUInteger)selectIndex;

@end

@interface ScrollMenuView : UIView

@property(nonatomic) id <ScrollMenuViewDelegate> delegate;
@property(nonatomic) UIScrollView *scrollView;
@property(nonatomic) UIFont *tabTitleFont;
@property(nonatomic) UIColor *tabTitleColor;
@property(nonatomic) UIColor *tabTitleSelectedColor;
@property(nonatomic) UIColor *tabtitleHighlightedColor;
@property(nonatomic) NSArray <ScrollMenuItem *> *menuItems;
@property(nonatomic) NSUInteger selectedIndex;

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)aniamted calledDelegate:(BOOL)calledDelgate;

- (void)reloadData;

@end
