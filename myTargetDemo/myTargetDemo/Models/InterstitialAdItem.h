//
//  InterstitialAdItem.h
//  myTargetDemo
//
//  Created by Andrey Seredkin on 08.08.17.
//  Copyright © 2017 Mail.ru Group. All rights reserved.
//

#import "AdItem.h"
#import <MyTargetSDK/MyTargetSDK.h>

@interface InterstitialAdItem : AdItem

@property(nonatomic) MTRGInterstitialAd *ad;
@property(nonatomic) BOOL isLoadedSuccess;

@end
