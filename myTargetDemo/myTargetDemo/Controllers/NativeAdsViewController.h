//
//  NativeAdsViewController.h
//  myTargetDemo
//
//  Created by Anton Bulankin on 27.06.16.
//  Copyright © 2016 Mail.ru Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScrollMenuViewController.h"

@interface NativeAdsViewController : ScrollMenuViewController

- (instancetype)initWithTitle:(NSString *)title slotId:(NSUInteger)slotId slotIdVideo:(NSUInteger)slotIdVideo;

@end
