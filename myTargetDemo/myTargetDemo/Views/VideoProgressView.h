//
//  VideoProgressView.h
//  myTargetDemo
//
//  Created by Andrey Seredkin on 19.01.17.
//  Copyright © 2017 Mail.ru Group. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoProgressView : UIView

- (instancetype)initWithDuration:(NSTimeInterval)duration;

- (void)setPosition:(NSTimeInterval)position;

- (void)setAdPoints:(NSArray<NSNumber *> *)points;

@end
