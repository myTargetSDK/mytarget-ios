//
//  InstreamAdsViewController.m
//  myTargetDemo
//
//  Created by Andrey Seredkin on 18.01.17.
//  Copyright © 2017 Mail.ru Group. All rights reserved.
//

#import "InstreamAdsViewController.h"
#import "ScrollMenuView.h"
#import "VideoPlayerView.h"
#import "VideoProgressView.h"

#import <MyTargetSDK/MyTargetSDK.h>

static NSString * const kInstreamAdMainVideoUrl = @"https://r.mradx.net/img/8D/548043.mp4";
static double const kInstreamAdMainVideoDuration = 25.612;

@interface InstreamAdsViewController () <MTRGInstreamAdDelegate, ScrollMenuViewDelegate, VideoPlayerViewDelegate>

@end

@implementation InstreamAdsViewController
{
	UIView *_adContainerView;
	NSString *_title;
	MTRGInstreamAd *_instreamAd;
	NSUInteger _slotId;
	ScrollMenuView *_scrollMenu;
	NSUInteger _selectedIndex;

	UILabel *_statusLabel;
	VideoPlayerView *_mainVideoView;
	VideoProgressView *_videoProgressView;

	UIButton *_ctaButton;
	UIButton *_skipButton;
	UIButton *_skipAllButton;

	NSTimer *_timer;
	NSTimeInterval _mainVideoDuration;
	NSTimeInterval _mainVideoPosition;

	BOOL _isStartedMainVideo;
	BOOL _isActiveMainVideo;
	BOOL _isFinihedMainVideo;
	BOOL _isModalActive;

	BOOL _isActivePreroll;
	BOOL _isActiveMidroll;
	BOOL _isActivePostroll;
	BOOL _isActivePauseroll;

	BOOL _skipAll;

	NSArray <NSNumber *> *_customMidPoints;
	NSArray <NSNumber *> *_customMidPointsP;
	NSArray <NSNumber *> *_midpoints;
	NSMutableArray <NSNumber *> *_activeMidpoints;
}

- (instancetype)initWithAdItem:(AdItem *)adItem
{
	self = [super init];
	if (self)
	{
		_selectedIndex = 0;
		_title = adItem.title;
		_slotId = [adItem slotIdForType:AdItemSlotIdTypeDefault];

		_mainVideoDuration = kInstreamAdMainVideoDuration;

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
	[self doPause];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
	[self doResume];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.view.backgroundColor = [UIColor whiteColor];
	self.navigationItem.title = _title;
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(updateTapped:)];

	_scrollMenu = [[ScrollMenuView alloc] init];
	_scrollMenu.delegate = self;
	_scrollMenu.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview:_scrollMenu];

	NSMutableArray *menuItems = [NSMutableArray new];
	[menuItems addObject:[[ScrollMenuItem alloc] initWithTitle:@"Video"]];

	[_scrollMenu setMenuItems:menuItems];
	[_scrollMenu setSelectedIndex:0];
	[_scrollMenu reloadData];
	[_scrollMenu setSelectedIndex:0 animated:YES calledDelegate:NO];

	_adContainerView = [[UIView alloc] init];
	_adContainerView.translatesAutoresizingMaskIntoConstraints = NO;
	_adContainerView.backgroundColor = [UIColor whiteColor];
	[self.view addSubview:_adContainerView];

	_statusLabel = [[UILabel alloc] init];
	_statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
	_statusLabel.textColor = [UIColor redColor];
	_statusLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
	[_adContainerView addSubview:_statusLabel];

	_mainVideoView = [[VideoPlayerView alloc] init];
	_mainVideoView.hidden = YES;
	_mainVideoView.translatesAutoresizingMaskIntoConstraints = NO;
	_mainVideoView.delegate = self;
	[_adContainerView addSubview:_mainVideoView];

	_videoProgressView = [[VideoProgressView alloc] initWithDuration:_mainVideoDuration];
	_videoProgressView.translatesAutoresizingMaskIntoConstraints = NO;
	[_adContainerView addSubview:_videoProgressView];

	_ctaButton = [[UIButton alloc] init];
	[_ctaButton addTarget:self action:@selector(ctaButtonClick:) forControlEvents:UIControlEventTouchUpInside];
	_ctaButton.translatesAutoresizingMaskIntoConstraints = NO;
	[self configureButton:_ctaButton withTitle:@"Proceed"];
	[_adContainerView addSubview:_ctaButton];

	_skipButton = [[UIButton alloc] init];
	[_skipButton addTarget:self action:@selector(skipButtonClick:) forControlEvents:UIControlEventTouchUpInside];
	_skipButton.translatesAutoresizingMaskIntoConstraints = NO;
	[self configureButton:_skipButton withTitle:@"Skip"];
	[_adContainerView addSubview:_skipButton];

	_skipAllButton = [[UIButton alloc] init];
	[_skipAllButton addTarget:self action:@selector(skipAllButtonClick:) forControlEvents:UIControlEventTouchUpInside];
	_skipAllButton.translatesAutoresizingMaskIntoConstraints = NO;
	[self configureButton:_skipAllButton withTitle:@"Skip All"];
	[_adContainerView addSubview:_skipAllButton];

	NSDictionary *views = @{
							@"scrollMenu" : _scrollMenu,
							@"statusLabel" : _statusLabel,
							@"mainVideoView" : _mainVideoView,
							@"videoProgressView" : _videoProgressView,
							@"adContainerView" : _adContainerView
							};

	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[scrollMenu]-0-|" options:0 metrics:nil views:views]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[adContainerView]-0-|" options:0 metrics:nil views:views]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[scrollMenu(0)]-0-[adContainerView]-0-|" options:0 metrics:nil views:views]];

	[_adContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[statusLabel]-5-|" options:0 metrics:nil views:views]];
	[_adContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[mainVideoView]-5-|" options:0 metrics:nil views:views]];
	[_adContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[videoProgressView]-5-|" options:0 metrics:nil views:views]];
	[_adContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[statusLabel(30)]-1-[mainVideoView(200)]-1-[videoProgressView(6)]" options:0 metrics:nil views:views]];
	
	[_adContainerView addConstraint:[NSLayoutConstraint constraintWithItem:_mainVideoView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_adContainerView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];

	[self setStatus:@"Ready"];
	[self doStart];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.navigationController.navigationBar.topItem.title = @"";
	self.navigationItem.title = _title;
}

- (void)viewWillDisappear:(BOOL)animated
{
	if (!_isModalActive)
	{
		[self doStop];
	}
}

- (void)setupAdPlayer
{
	UIView *adPlayerView = _instreamAd.player.adPlayerView;
	if (!adPlayerView) return;

	adPlayerView.translatesAutoresizingMaskIntoConstraints = NO;
	[_adContainerView addSubview:adPlayerView];

	[_adContainerView addConstraint:[NSLayoutConstraint constraintWithItem:adPlayerView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_mainVideoView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
	[_adContainerView addConstraint:[NSLayoutConstraint constraintWithItem:adPlayerView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_mainVideoView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
	[_adContainerView addConstraint:[NSLayoutConstraint constraintWithItem:adPlayerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_mainVideoView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
	[_adContainerView addConstraint:[NSLayoutConstraint constraintWithItem:adPlayerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_mainVideoView attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
}

- (void)setupButtons
{
	UIView *adPlayerView = _instreamAd.player.adPlayerView;
	if (!adPlayerView) return;

	[_ctaButton removeFromSuperview];
	[_skipButton removeFromSuperview];
	[_skipAllButton removeFromSuperview];

	[adPlayerView addSubview:_ctaButton];
	[adPlayerView addSubview:_skipButton];
	[adPlayerView addSubview:_skipAllButton];

	NSDictionary *views = @{
							@"ctaButton" : _ctaButton,
							@"skipButton" : _skipButton,
							@"skipAllButton" : _skipAllButton
							};

	[adPlayerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[ctaButton]-(>=10)-|" options:0 metrics:nil views:views]];
	[adPlayerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[ctaButton(30)]" options:0 metrics:nil views:views]];

	[adPlayerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[skipButton(75)]" options:0 metrics:nil views:views]];
	[adPlayerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[skipButton(30)]-10-|" options:0 metrics:nil views:views]];

	[adPlayerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[skipAllButton(75)]-10-|" options:0 metrics:nil views:views]];
	[adPlayerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[skipAllButton(30)]-10-|" options:0 metrics:nil views:views]];
}

- (void)configureButton:(UIButton *)button withTitle:(NSString *)title
{
	[button setTitle:title forState:UIControlStateNormal];
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[button.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:12]];

	button.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
	button.contentEdgeInsets = UIEdgeInsetsMake(5, 10, 5, 10);

	button.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
	button.layer.borderWidth = 1;
	button.layer.borderColor = [UIColor whiteColor].CGColor;
	button.layer.cornerRadius = 5;
}

- (void)configureMidrolls
{
	if (!_instreamAd) return;

	if (_customMidPoints)
	{
		[_instreamAd configureMidpoints:_customMidPoints forVideoDuration:_mainVideoDuration];
	}
	else if (_customMidPointsP)
	{
		[_instreamAd configureMidpointsP:_customMidPointsP forVideoDuration:_mainVideoDuration];
	}
	else
	{
		[_instreamAd configureMidpointsForVideoDuration:_mainVideoDuration];
	}
}

- (BOOL)isActiveAd
{
	return _isActivePreroll || _isActivePostroll || _isActiveMidroll || _isActivePauseroll;
}

#pragma mark - actions

- (void)doStart
{
	if (_isStartedMainVideo)
	{
		[_mainVideoView stop];
	}

	if (_instreamAd)
	{
		[_instreamAd stop];
		[_instreamAd.player.adPlayerView removeFromSuperview];
		_instreamAd = nil;
	}

	[self setStatus:@"Loading"];

	_mainVideoPosition = 0;

	_isStartedMainVideo = NO;
	_isActiveMainVideo = NO;
	_isFinihedMainVideo = NO;
	_isModalActive = NO;

	_isActivePreroll = NO;
	_isActiveMidroll = NO;
	_isActivePostroll = NO;
	_isActivePauseroll = NO;

	_skipAll = NO;

	[_ctaButton removeFromSuperview];
	[_skipButton removeFromSuperview];
	[_skipAllButton removeFromSuperview];

	_instreamAd = [[MTRGInstreamAd alloc] initWithSlotId:_slotId];
	[_instreamAd useDefaultPlayer];
	[_instreamAd setDelegate:self];

	[self configureMidrolls];

	[_instreamAd.customParams setAge: @100];
	[_instreamAd.customParams setGender: MTRGGenderUnknown];

	[_instreamAd load];
}

- (void)doPause
{
	if (_isStartedMainVideo && _isActiveMainVideo)
	{
		[self playPauseroll];
	}
	else if ([self isActiveAd])
	{
		if (_instreamAd)
		{
			[_instreamAd pause];
		}
	}
}

- (void)doResume
{
	if (_isStartedMainVideo && _isActiveMainVideo)
	{
		[_mainVideoView resume];
	}
	else if ([self isActiveAd])
	{
		if (_instreamAd)
		{
			[_instreamAd resume];
		}
	}
}

- (void)doStop
{
	if (_isStartedMainVideo && _isActiveMainVideo)
	{
		[_mainVideoView stop];
	}
	else if ([self isActiveAd])
	{
		if (_instreamAd)
		{
			[_instreamAd stop];
		}
	}
	[self stopTimer];
}

- (void)doFullscreen:(BOOL)isFullscreen
{
	if (_instreamAd)
	{
		[_instreamAd setFullscreen:isFullscreen];
	}
}

- (void)doSkip
{
	if ([self isActiveAd])
	{
		if (_instreamAd)
		{
			[_instreamAd skipBanner];
		}
	}
}

- (void)doSkipAll
{
	_skipAll = YES;
	_activeMidpoints = [NSMutableArray <NSNumber *> new];

	if ([self isActiveAd])
	{
		if (_instreamAd)
		{
			[_instreamAd skip];
		}
	}
}

- (void)doBannerClick
{
	if ([self isActiveAd])
	{
		if (_instreamAd)
		{
			[_instreamAd handleClickWithController:self];
		}
	}
}

#pragma mark - buttons

- (void)updateTapped:(UIBarButtonItem *)sender
{
	[self doStart];
}

- (void)ctaButtonClick:(UIButton *)sender
{
	[self doBannerClick];
}

- (void)skipButtonClick:(UIButton *)sender
{
	[self doSkip];
}

- (void)skipAllButtonClick:(UIButton *)sender
{
	[self doSkipAll];
}

#pragma mark - video

- (void)playMainVideo
{
	[self setMainPlayerVisible:YES adPlayerVisible:NO];
	[self setStatus:@"Main video"];

	_isActiveMainVideo = YES;
	_mainVideoView.hidden = NO;

	[_mainVideoView startWithUrl:[NSURL URLWithString:kInstreamAdMainVideoUrl] position:_mainVideoPosition];
}

- (void)playPreroll
{
	_isActivePreroll = YES;
	[self setStatus:@"Preroll"];

	[self setMainPlayerVisible:NO adPlayerVisible:YES];
	[_instreamAd startPreroll];
}

- (void)playPauseroll
{
	_mainVideoPosition = _mainVideoView.currentTime;
	[_mainVideoView pause];
	[self setMainPlayerVisible:NO adPlayerVisible:YES];

	_isActivePauseroll = YES;
	_isActiveMainVideo = NO;
	[self setStatus:@"Pauseroll"];

	[_instreamAd startPauseroll];
}

- (void)playMidroll:(NSNumber *)midpoint
{
	_mainVideoPosition = _mainVideoView.currentTime;
	[_mainVideoView pause];
	[self setMainPlayerVisible:NO adPlayerVisible:YES];

	_isActiveMidroll = YES;
	_isActiveMainVideo = NO;
	[self setStatus:@"Midroll"];

	[_instreamAd startMidrollWithPoint:midpoint];
}

- (void)playPostroll
{
	_isActivePostroll = YES;
	[self setStatus:@"Postroll"];

	[self setMainPlayerVisible:NO adPlayerVisible:YES];
	[_instreamAd startPostroll];
}

- (void)setMainPlayerVisible:(BOOL)mainPlayerVisible adPlayerVisible:(BOOL)adPlayerVisible
{
	_mainVideoView.hidden = !mainPlayerVisible;
	_ctaButton.hidden = !adPlayerVisible;
	_skipButton.hidden = !adPlayerVisible;
	_skipAllButton.hidden = !adPlayerVisible;
	_videoProgressView.hidden = !mainPlayerVisible && !adPlayerVisible;

	if (_instreamAd && _instreamAd.player && _instreamAd.player.adPlayerView)
	{
		_instreamAd.player.adPlayerView.hidden = !adPlayerVisible;
	}
}

#pragma mark - VideoPlayerViewDelegate

- (void)onVideoStarted:(NSURL *)url
{
	if (_isActiveMainVideo)
	{
		_isStartedMainVideo = YES;
		_mainVideoDuration = _mainVideoView.duration;
		[self startTimer];
	}
}

- (void)onVideoFinishedSuccess
{
	if (_isActiveMainVideo)
	{
		[self stopTimer];
		_isActiveMainVideo = NO;

		if (_skipAll)
		{
			[self setStatus:@"Complete"];
			[self setMainPlayerVisible:NO adPlayerVisible:NO];
		}
		else
		{
			[self playPostroll];
		}
	}
}

- (void)onVideoFinishedWithError:(NSString *)error
{
	[self setError:error];

	if (_isActiveMainVideo)
	{
		_isActiveMainVideo = NO;
	}
}

#pragma mark -- ScrollMenuViewDelegate

- (void)scrollMenuDidSelected:(ScrollMenuView *)scrollMenu menuIndex:(NSUInteger)selectIndex
{
	if (_selectedIndex == selectIndex) return;
	_selectedIndex = selectIndex;

	switch (_selectedIndex)
	{
		case 1:
			break;

		default:
			break;
	}
	[self doStart];
}

#pragma mark - MTRGInstreamAdDelegate

- (void)onLoadWithInstreamAd:(MTRGInstreamAd *)instreamAd
{
	[self setStatus:@"Loaded"];

	_midpoints = _instreamAd.midpoints;
	_activeMidpoints = [NSMutableArray <NSNumber *> new];
	if (_midpoints)
	{
		[_activeMidpoints addObjectsFromArray:_midpoints];
	}
	[_videoProgressView setAdPoints:_activeMidpoints];

	[self setupAdPlayer];
	[self playPreroll];
}

- (void)onNoAdWithReason:(NSString *)reason instreamAd:(MTRGInstreamAd *)instreamAd
{
	[self setError:@"No ad"];
	_instreamAd = nil;
	[self playMainVideo];
}

- (void)onErrorWithReason:(NSString *)reason instreamAd:(MTRGInstreamAd *)instreamAd
{
	[self setError:reason];
	[self playMainVideo];
}

- (void)onBannerStart:(MTRGInstreamAdBanner *)banner instreamAd:(MTRGInstreamAd *)instreamAd
{
	[_ctaButton setTitle:banner.ctaText forState:UIControlStateNormal];
	[self setupButtons];
}

- (void)onBannerComplete:(MTRGInstreamAdBanner *)banner instreamAd:(MTRGInstreamAd *)instreamAd
{
	//
}

- (void)onBannerTimeLeftChange:(NSTimeInterval)timeLeft duration:(NSTimeInterval)duration instreamAd:(MTRGInstreamAd *)instreamAd
{
	//
}

- (void)onCompleteWithSection:(NSString *)section instreamAd:(MTRGInstreamAd *)instreamAd
{
	if (_isActivePreroll)
	{
		_isActivePreroll = NO;
		[self playMainVideo];
	}

	if (_isActiveMidroll)
	{
		_isActiveMidroll = NO;
		[self startTimer];
		[self playMainVideo];
	}

	if (_isActivePauseroll)
	{
		_isActivePauseroll = NO;
		[self startTimer];
		[self playMainVideo];
	}

	if (_isActivePostroll)
	{
		_isActivePostroll = NO;
		[self setStatus:@"Complete"];
		[self setMainPlayerVisible:NO adPlayerVisible:NO];
	}
}

- (void)onShowModalWithInstreamAd:(MTRGInstreamAd *)instreamAd
{
	_isModalActive = YES;
	[self doPause];
}

- (void)onDismissModalWithInstreamAd:(MTRGInstreamAd *)instreamAd
{
	_isModalActive = NO;
	[self doResume];
}

- (void)onLeaveApplicationWithInstreamAd:(MTRGInstreamAd *)instreamAd
{
	//
}

#pragma mark -- main video timer

- (NSNumber *)midPointForVideoTime:(NSTimeInterval)videoTime
{
	if (_activeMidpoints && _activeMidpoints.count > 0)
	{
		NSNumber *first = _activeMidpoints.firstObject;
		if (videoTime >= first.floatValue)
		{
			[_activeMidpoints removeObjectAtIndex:0];
			return first;
		}
	}
	return nil;
}

- (void)updateStateByTimer
{
	if (_isActiveMainVideo)
	{
		NSTimeInterval currentTime = _mainVideoView.currentTime;
		if (currentTime > _mainVideoDuration)
		{
			[self stopTimer];
			[_mainVideoView stop];
			return;
		}
		[_videoProgressView setPosition:currentTime];

		NSNumber *midpoint = [self midPointForVideoTime:currentTime];
		if (midpoint)
		{
			[self playMidroll:midpoint];
			[self stopTimer];
		}
		else
		{
			[self startTimer];
		}
	}
}

#pragma mark - timer

- (void)startTimer
{
	[self stopTimer];
	_timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerTick) userInfo:nil repeats:NO];
}

- (void)stopTimer
{
	if (_timer && [_timer isValid])
	{
		[_timer invalidate];
	}
	_timer = nil;
}

- (void)timerTick
{
	[self stopTimer];
	[self updateStateByTimer];
}

#pragma mark - helpers

- (void)setStatus:(NSString *)status
{
	_statusLabel.text = [NSString stringWithFormat:@"Status: %@", status];
}

- (void)setError:(NSString *)error
{
	_statusLabel.text = [NSString stringWithFormat:@"Error: %@", error];
}

@end
