//
//  ScrollMenuViewController.h
//  myTargetDemo
//
//  Created by Anton Bulankin on 28.06.16.
//  Copyright © 2016 Mail.ru Group. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScrollMenuViewController : UIViewController

- (instancetype)initWithTitle:(NSString *)title;

- (void)addPageWithTitle:(NSString *)title view:(UIView *)view;

@end
