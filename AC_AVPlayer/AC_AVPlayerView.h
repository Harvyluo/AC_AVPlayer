//
//  AC_AVPlayerView.h
//  AC_AVPlayer
//
//  Created by FM-13 on 16/6/12.
//  Copyright © 2016年 cong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface AC_AVPlayerView : UIView

- (instancetype)initWithMoviePlayerLayer:(AVPlayerLayer *)playerLayer frame:(CGRect)frame;

@end
