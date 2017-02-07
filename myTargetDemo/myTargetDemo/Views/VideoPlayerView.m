//
//  VideoPlayerView.m
//  myTargetDemo
//
//  Created by Andrey Seredkin on 18.01.17.
//  Copyright © 2017 Mail.ru Group. All rights reserved.
//

#import "VideoPlayerView.h"
#import <AVFoundation/AVFoundation.h>

static void *VideoPlayerViewStatusObservationContext = &VideoPlayerViewStatusObservationContext;
static void *VideoPlayerViewRateObservationContext = &VideoPlayerViewRateObservationContext;
static void *VideoPlayerViewExternalPlaybackActiveObservationContext = &VideoPlayerViewExternalPlaybackActiveObservationContext;

@implementation VideoPlayerView
{
	AVPlayer *_player;
	AVPlayerItem *_playerItem;

	AVURLAsset *_asset;
	BOOL _isPaused;
	NSURL * _url;
	float _volume;
	NSTimeInterval _position;
}

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
	{
		_volume = 1;
		_isPaused = NO;
		_position = 0;
	}
	return self;
}

- (void)dealloc
{
	[self stop];
	NSLog(@"VideoPlayerView - dealloc");
}

#pragma mark - delegates

- (void)delegateOnVideoStartedWithUrl:(NSURL *)url
{
	if (!_delegate) return;
	if (![_delegate respondsToSelector:@selector(onVideoStarted:)])return;
	[_delegate onVideoStarted:url];
}

- (void)delegateOnVideoFinishedSuccess
{
	if (!_delegate) return;
	if (![_delegate respondsToSelector:@selector(onVideoFinishedSuccess)])return;
	[_delegate onVideoFinishedSuccess];
}

- (void)delegateOnVideoFinishedWithError:(NSString *)error
{
	[self stop];
	if (!_delegate) return;
	if (![_delegate respondsToSelector:@selector(onVideoFinishedWithError:)])return;
	[_delegate onVideoFinishedWithError:[NSString stringWithFormat:@"VideoPlayerView: %@", error]];
}

#pragma mark - getters

- (NSTimeInterval)currentTime
{
	return _player ? CMTimeGetSeconds([_player currentTime]) : 0.0;
}

- (float)volume
{
	return _player ? _player.volume : _volume;
}

#pragma mark - setters

- (void)setCurrentTime:(NSTimeInterval)currentTime
{
	[_player seekToTime:CMTimeMakeWithSeconds(currentTime, 1)];
}

- (void)setVolume:(float)volume
{
	_volume = volume;
	if (_player)
	{
		_player.volume = volume;
	}
}

#pragma mark - AV player stuff

+ (Class)layerClass
{
	return [AVPlayerLayer class];
}

- (AVPlayer *)player
{
	return [(AVPlayerLayer *) [self layer] player];
}

- (void)setPlayer:(AVPlayer *)player
{
	[(AVPlayerLayer *) [self layer] setPlayer:player];
}

// Specifies how the video is displayed within a player layer’s bounds. AVLayerVideoGravityResizeAspect is default
- (void)setVideoFillMode:(NSString *)fillMode
{
	AVPlayerLayer *playerLayer = (AVPlayerLayer *) [self layer];
	playerLayer.videoGravity = fillMode;
}

#pragma mark - playback

- (void)startWithUrl:(NSURL *)url position:(NSTimeInterval)position
{
	_position = position;
	if (_player && _isPaused && url && _url && [url.absoluteString isEqualToString:_url.absoluteString])
	{
		[_player play];
		return;
	}
	_isPaused = NO;
	_url = url;
	_asset = [AVURLAsset URLAssetWithURL:url options:nil];
	NSArray *requestedKeys = @[@"playable"];

	// Tells the asset to load the values of any of the specified keys that are not already loaded.
	[_asset loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:^
	{
		dispatch_async(dispatch_get_main_queue(),^
		{
			[self prepareToPlayAsset:_asset withKeys:requestedKeys];
		});
	}];
}

- (void)pause
{
	if (!_player) return;
	[_player pause];
	_isPaused = YES;
}

- (void)resume
{
	if (!_player) return;
	_isPaused = NO;
	[_player play];
}

- (void)stop
{
	[_player pause];
	[self deletePlayerItem];
	[self deletePlayer];
}

- (void)finish
{
	[self stop];
	[self delegateOnVideoFinishedSuccess];
}

- (void)prepareToPlayAsset:(AVURLAsset *)asset withKeys:(NSArray *)requestedKeys
{
	/* Make sure that the value of each key has loaded successfully. */
	for (NSString *thisKey in requestedKeys)
	{
		NSError *error = nil;
		AVKeyValueStatus keyStatus = [asset statusOfValueForKey:thisKey error:&error];
		if (keyStatus == AVKeyValueStatusFailed)
		{
			[self delegateOnVideoFinishedWithError:@"Item cannot be played, status failed"];
			return;
		}
		/* If you are also implementing -[AVAsset cancelLoading], add your code here to bail out properly in the case of cancellation. */
	}

	if (!asset.playable)
	{
		[self delegateOnVideoFinishedWithError:@"Item cannot be played"];
		return;
	}

	[self createPlayerItemForAsset:asset];

	[self deletePlayer];
	[self createPlayer];

	[_player seekToTime:CMTimeMakeWithSeconds(_position, 1)];
	[_player play];
}

- (void)createPlayerItemForAsset:(AVURLAsset *)asset
{
	[self deletePlayerItem];
	_playerItem = [AVPlayerItem playerItemWithAsset:asset];

	[_playerItem addObserver:self
				  forKeyPath:@"status"
					 options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
					 context:VideoPlayerViewStatusObservationContext];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(playerItemDidReachEnd:)
												 name:AVPlayerItemDidPlayToEndTimeNotification
											   object:_playerItem];
}

- (void)deletePlayerItem
{
	if (_playerItem)
	{
		[_playerItem removeObserver:self forKeyPath:@"status"];

		[[NSNotificationCenter defaultCenter] removeObserver:self
														name:AVPlayerItemDidPlayToEndTimeNotification
													  object:_playerItem];
		_playerItem = nil;
	}
}

- (void)createPlayer
{
	[self deletePlayer];

	_player = [AVPlayer playerWithPlayerItem:_playerItem];
	_player.volume = _volume;

	[self setPlayer:_player];

	[_player addObserver:self
			  forKeyPath:@"rate"
				 options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
				 context:VideoPlayerViewRateObservationContext];

	[_player addObserver:self
			  forKeyPath:@"externalPlaybackActive"
				 options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
				 context:VideoPlayerViewExternalPlaybackActiveObservationContext];
}

- (void)deletePlayer
{
	[self setPlayer:nil];
	if (_player)
	{
		[_player removeObserver:self forKeyPath:@"rate"];
		[_player removeObserver:self forKeyPath:@"externalPlaybackActive"];
		[_player pause];
		_player = nil;
	}
}

#pragma mark - Observers

- (void)playerItemDidReachEnd:(NSNotification *)notification
{
	if (notification.object != _playerItem) return;
	[self stop];
	[self delegateOnVideoFinishedSuccess];
}

- (void)observeValueForKeyPath:(NSString *)path
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context
{
	/* AVPlayerItem "status" property value observer. */
	if (context == VideoPlayerViewStatusObservationContext)
	{
		AVPlayerItemStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
		[self playerItemStatusChanged:status];
	}
	else if (context == VideoPlayerViewRateObservationContext)
	{
		float rate = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
		[self playerRateChanged:rate];
	}
	else if (context == VideoPlayerViewExternalPlaybackActiveObservationContext)
	{
		BOOL externalPlaybackActive = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
		[self externalPlaybackActiveChanged:externalPlaybackActive];
	}
	else
	{
		[super observeValueForKeyPath:path ofObject:object change:change context:context];
	}
}

- (void)playerItemStatusChanged:(AVPlayerItemStatus)status
{
	if (status == AVPlayerItemStatusUnknown)
	{
		NSLog(@"Player item status ---> Unknown");
	}
	else if (status == AVPlayerItemStatusReadyToPlay)
	{
		_duration = [self durationForPlayerItem:_playerItem];
		if (_duration == 0)
		{
			[self delegateOnVideoFinishedWithError:@"Player item duration = 0"];
		}
		else
		{
			// Success
			[self delegateOnVideoStartedWithUrl:_url];
		}
		NSLog(@"Player item status ---> Ready, duration = %.2f", _duration);
	}
	else if (status == AVPlayerItemStatusFailed)
	{
		NSLog(@"Player item status ---> Failed");
		[self delegateOnVideoFinishedWithError:@"Player item status is failed"];
	}
}

- (void)playerRateChanged:(float)rate
{
	NSLog(@"Player rate ---> %.2f", rate);
}

- (void)externalPlaybackActiveChanged:(BOOL)externalPlaybackActive
{
	NSLog(@"AirPlay ---> %@", externalPlaybackActive ? @"YES" : @"NO");
}

#pragma mark - helpers

- (NSTimeInterval)durationForPlayerItem:(AVPlayerItem *)playerItem
{
	if (playerItem && playerItem.status == AVPlayerItemStatusReadyToPlay)
	{
		CMTime playerDuration = [playerItem duration];
		if (CMTIME_IS_INVALID(playerDuration))
		{
			return 0;
		}
		double duration = CMTimeGetSeconds(playerDuration);
		if (isfinite(duration))
		{
			return duration;
		}
		else
		{
			return 0;
		}
	}
	else
	{
		return 0;
	}
}

@end
