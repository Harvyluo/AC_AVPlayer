//
//  AC_AVPlayerView.m
//  AC_AVPlayer
//
//  Created by FM-13 on 16/6/12.
//  Copyright © 2016年 cong. All rights reserved.
//

#import "AC_AVPlayerView.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface AC_AVPlayerView()

{
    AVPlayerLayer *_playerLayer;
}

@end

@implementation AC_AVPlayerView


- (instancetype)initWithMoviePlayerLayer:(AVPlayerLayer *)playerLayer frame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _playerLayer = playerLayer;
        playerLayer.backgroundColor = [UIColor blackColor].CGColor;
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        _playerLayer.contentsScale = [UIScreen mainScreen].scale;
        [self.layer addSublayer:_playerLayer];
    }
    return self;
}


- (void)layoutSublayersOfLayer:(CALayer *)layer
{
    [super layoutSublayersOfLayer:layer];
    
    _playerLayer.bounds = self.layer.bounds;
    _playerLayer.position = self.layer.position;
}



@end
