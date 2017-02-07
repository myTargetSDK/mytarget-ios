//
//  VideoPlayerView.h
//  myTargetDemo
//
//  Created by Andrey Seredkin on 18.01.17.
//  Copyright © 2017 Mail.ru Group. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VideoPlayerViewDelegate <NSObject>

- (void)onVideoStarted:(NSURL *)url;

- (void)onVideoFinishedSuccess;

- (void)onVideoFinishedWithError:(NSString *)error;

@end

@interface VideoPlayerView : UIView

@property(nonatomic, weak) id<VideoPlayerViewDelegate> delegate;

@property(nonatomic) NSTimeInterval currentTime;
@property(nonatomic, readonly) NSTimeInterval duration;
@property(nonatomic) float volume;

- (void)startWithUrl:(NSURL *)url position:(NSTimeInterval)position;

- (void)pause;

- (void)resume;

- (void)stop;

- (void)finish;

@end
