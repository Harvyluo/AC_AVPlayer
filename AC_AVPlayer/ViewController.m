//
//  ViewController.m
//  AC_AVPlayer
//
//  Created by FM-13 on 16/6/12.
//  Copyright © 2016年 cong. All rights reserved.
//

#import "ViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "AC_AVPlayerViewController.h"
#import <AVKit/AVKit.h>

@interface ViewController ()

@property (strong, nonatomic) AVPlayer *avPlayer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //http://10.57.180.184/vod/sample.mp4/playlist.m3u8

    
//    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:@"http://bos.nj.bpc.baidu.com/tieba-smallvideo/11772_3c435014fb2dd9a5fd56a57cc369f6a0.mp4"]];
//    //添加监听
//    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
//    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
//    self.avPlayer = [AVPlayer playerWithPlayerItem:playerItem];
//    
//    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
//    //设置模式
//    playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
//    playerLayer.contentsScale = [UIScreen mainScreen].scale;
//    playerLayer.frame = CGRectMake(0, 100, self.view.bounds.size.width, 200);
//    [self.view.layer addSublayer:playerLayer];
    

    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    button.backgroundColor = [UIColor redColor];
    [button setTitle:@"go to play" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(goToPlay) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];


}

- (void)goToPlay
{
    NSURL *url = [NSURL URLWithString:@"http://bos.nj.bpc.baidu.com/tieba-smallvideo/11772_3c435014fb2dd9a5fd56a57cc369f6a0.mp4"];
    AC_VideoModel *model1 = [[AC_VideoModel alloc] initWithName:@"海贼王德岛剪辑(在线)" url:url];
    
    NSURL *url2 = [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"海贼王精彩剪辑" ofType:@"mp4"]];
    AC_VideoModel *model2 = [[AC_VideoModel alloc] initWithName:@"海贼王精彩剪辑(本地)" url:url2];
    
    
    AC_AVPlayerViewController *ctr = [[AC_AVPlayerViewController alloc] initWithVideoList:@[model1, model2]];
    [self presentViewController:ctr animated:YES completion:^{
        
    }];
}

////监听回调
//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
//{
//    AVPlayerItem *playerItem = (AVPlayerItem *)object;
//    
//    if ([keyPath isEqualToString:@"loadedTimeRanges"]){
//        
//    }else if ([keyPath isEqualToString:@"status"]){
//        if (playerItem.status == AVPlayerItemStatusReadyToPlay){
//            NSLog(@"playerItem is ready");
//            [self.avPlayer play];
//        } else{
//            NSLog(@"load break");
//        }
//    }
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)dealloc
//{
//    [self.avPlayer.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
//    [self.avPlayer.currentItem removeObserver:self forKeyPath:@"status"];
//}

@end
