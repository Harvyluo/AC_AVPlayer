//
//  AC_AVPlayerViewController.m
//  AC_AVPlayer
//
//  Created by FM-13 on 16/6/12.
//  Copyright © 2016年 cong. All rights reserved.
//

#import "AC_AVPlayerViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "AC_AVPlayerView.h"
#import "AC_ProgressSlider.h"

@implementation AC_VideoModel

- (instancetype)initWithName:(NSString *)name url:(NSURL *)url
{
    self = [super init];
    if (self) {
        _name = [name copy];
        _url = [url copy];
    }
    return self;
}

@end

@interface AC_AVPlayerViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) AVPlayer *avPlayer;
@property (strong, nonatomic) AVPlayerItem *avPlayerItem;
@property (strong, nonatomic) AVPlayerLayer *avPlayerLayer;

@property (strong, nonatomic) UIView *videoBackView;

@property (strong, nonatomic) UIView *topView;
@property (strong, nonatomic) UIButton *backButton;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UITableView *listTableView;


@property (strong, nonatomic) UIView *bottmView;
@property (strong, nonatomic) UIButton *playButton;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) AC_ProgressSlider *slider;

@property (nonatomic, strong) UIActivityIndicatorView *activity;
@property (nonatomic, strong) CADisplayLink *link;
@property (nonatomic, assign) NSTimeInterval lastTime;

@property (assign, nonatomic) BOOL isHidenTabView;
@property (assign, nonatomic) BOOL isHidenListView;


@property (strong, nonatomic) UIView *faildView;


@property (strong, nonatomic) AC_VideoModel *videoModel;

@property (strong, nonatomic) NSArray *videoArr;

@end

@implementation AC_AVPlayerViewController

- (instancetype)initWithVideoList:(NSArray<AC_VideoModel *> *)videoList {
    NSAssert(videoList.count, @"The playlist can not be empty!");
    self = [super init];
    if (self) {
        self.videoArr = [videoList mutableCopy];
        self.videoModel = self.videoArr[0];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self ac_initPlayer];
    
    [self ac_initSubViews];
    
    //播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayDidEnd)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:nil];
    
}

- (void)ac_initPlayer
{
    
    self.videoBackView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width*9/16)];
    [self.view addSubview:self.videoBackView];
    
    
    self.avPlayerItem = [AVPlayerItem playerItemWithURL:self.videoModel.url];
    [self addObserveWithPlayerItem:self.avPlayerItem];
    
    self.avPlayer = [AVPlayer playerWithPlayerItem:self.avPlayerItem];
    self.avPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
    
    //AC_AVPlayerView *avPlayerView = [[AC_AVPlayerView alloc] initWithMoviePlayerLayer:self.avPlayerLayer frame:self.view.bounds];
    AC_AVPlayerView *avPlayerView= [[AC_AVPlayerView alloc] initWithMoviePlayerLayer:self.avPlayerLayer frame:self.videoBackView.bounds];
    //avPlayerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.videoBackView addSubview:avPlayerView];
    
    
//    __weak __typeof(self) weakSelf = self;
//    [self.avPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
//        //当前播放的时间
//        NSTimeInterval current = CMTimeGetSeconds(time);
//        //视频的总时间
//        NSTimeInterval total = CMTimeGetSeconds(weakSelf.avPlayer.currentItem.duration);
//        
//        weakSelf.slider.sliderPercent = current/total;
//        NSLog(@"%f", weakSelf.slider.sliderPercent);
//        weakSelf.timeLabel.text = [NSString stringWithFormat:@"%@/%@", [weakSelf formatPlayTime:current], [weakSelf formatPlayTime:total]];
//    }];

    self.link = [CADisplayLink displayLinkWithTarget:self selector:@selector(upadte)];
    [self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
}

- (void)ac_initSubViews
{
    self.view.backgroundColor = [UIColor whiteColor];
    //topBar
    self.topView = [[UIView alloc] initWithFrame:CGRectZero];
    self.topView.backgroundColor = [UIColor blackColor];
    self.topView.alpha = .5;
    [self.videoBackView addSubview:self.topView];
    
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.videoBackView);
        make.top.equalTo(self.videoBackView);
        make.right.equalTo(self.videoBackView);
        make.height.mas_equalTo(60);
    }];
    
    //返回按钮
    self.backButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [self.backButton setImage:[UIImage imageNamed:@"gobackBtn"] forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:self.backButton];
    
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.topView).offset(10);
        make.top.equalTo(self.topView).offset(10);
        make.bottom.equalTo(self.topView).offset(-10);
        make.width.mas_equalTo(self.backButton.mas_height);
    }];
    
    //标题
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.text = self.videoModel.name;
    [self.topView addSubview:self.titleLabel];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.topView);
        make.size.mas_equalTo(CGSizeMake(self.view.frame.size.width - 100, 40));
    }];
    
    //list按钮
    UIButton *listButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [listButton setImage:[UIImage imageNamed:@"player_fit"] forState:UIControlStateNormal];
    [listButton addTarget:self action:@selector(showOrHideListTableViewAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:listButton];
    
    [listButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.topView).offset(-10);
        make.top.equalTo(self.topView).offset(10);
        make.bottom.equalTo(self.topView).offset(-10);
        make.width.mas_equalTo(self.backButton.mas_height);
    }];
    
    self.listTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.listTableView.delegate = self;
    self.listTableView.dataSource = self;
    self.listTableView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.55];
    self.listTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.videoBackView addSubview:self.listTableView];
    
    [self.listTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.videoBackView).offset(300);
        make.top.equalTo(self.videoBackView).offset(60);
        make.bottom.equalTo(self.videoBackView).offset(-60);
        make.width.mas_equalTo(300);
    }];
    
    self.isHidenListView = YES;
    
    
    //bottonBar
    self.bottmView = [[UIView alloc] initWithFrame:CGRectZero];
    self.bottmView.backgroundColor = [UIColor blackColor];
    self.bottmView.alpha = .5;
    [self.videoBackView addSubview:self.bottmView];
    
    [self.bottmView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.videoBackView);
        make.left.equalTo(self.videoBackView);
        make.right.equalTo(self.videoBackView);
        make.height.mas_equalTo(60);
    }];
    
    //播放按钮
    self.playButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [self.playButton setImage:[UIImage imageNamed:@"pauseBtn"] forState:UIControlStateNormal];
    [self.playButton setImage:[UIImage imageNamed:@"playBtn"] forState:UIControlStateSelected];
    [self.playButton addTarget:self action:@selector(playOrPauseAction:) forControlEvents:UIControlEventTouchUpInside];
    self.playButton.enabled = NO;
    [self.bottmView addSubview:self.playButton];
    
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottmView).offset(10);
        make.top.equalTo(self.bottmView).offset(10);
        make.bottom.equalTo(self.bottmView).offset(-10);
        make.width.mas_equalTo(self.backButton.mas_height);
    }];
    
    //时间
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.timeLabel.text = @"00:00:00/00:00:00";
    self.timeLabel.textColor = [UIColor whiteColor];
    self.timeLabel.textAlignment = NSTextAlignmentRight;
    [self.bottmView addSubview:self.timeLabel];
    CGSize size = CGSizeMake(1000,10000);
    //计算实际frame大小，并将label的frame变成实际大小
    NSDictionary *attribute = @{NSFontAttributeName:self.timeLabel.font};
    CGSize labelsize = [self.timeLabel.text boundingRectWithSize:size options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.bottmView).offset(-10);
        make.top.equalTo(self.bottmView).offset(10);
        make.bottom.equalTo(self.bottmView).offset(-10);
        make.width.mas_equalTo(labelsize.width + 5);
    }];
    
    //滑块
    self.slider = [[AC_ProgressSlider alloc] initWithFrame:CGRectZero direction:AC_SliderDirectionHorizonal];
    [self.bottmView addSubview:self.slider];
    self.slider.enabled = NO;
    
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.playButton.mas_right).offset(10);
        make.right.equalTo(self.timeLabel.mas_left).offset(-10);
        make.height.mas_equalTo(40);
        make.centerY.equalTo(self.bottmView);
    }];
    
    
    [self.slider addTarget:self action:@selector(progressValueChange:) forControlEvents:UIControlEventValueChanged];
    
    
    //菊花
    self.activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activity.color = [UIColor redColor];
    [self.activity setCenter:self.videoBackView.center];//指定进度轮中心点
    [self.activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];//设置进度轮显示类型
    [self.videoBackView addSubview:self.activity];
    [self.activity mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(30, 30));
        make.center.equalTo(self.videoBackView);
    }];
    
    
    //加载失败
    self.faildView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.videoBackView addSubview:self.faildView];
    self.faildView.backgroundColor = [UIColor redColor];
    self.faildView.hidden = YES;
    
    [self.faildView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.videoBackView);
    }];
    
    //
    UIButton *reLoadButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [reLoadButton setTitle:@"视频加载失败，点击重新加载" forState:UIControlStateNormal];
    [reLoadButton addTarget:self action:@selector(reloadAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.faildView addSubview:reLoadButton];
    
    [reLoadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.faildView);
    }];
}

//更新方法
- (void)upadte
{
    NSTimeInterval current = CMTimeGetSeconds(self.avPlayer.currentTime);
    NSTimeInterval total = CMTimeGetSeconds(self.avPlayer.currentItem.duration);
    //如果用户在手动滑动滑块，则不对滑块的进度进行设置重绘
    if (!self.slider.isSliding) {
        self.slider.sliderPercent = current/total;
    }
    
    if (current!=self.lastTime) {
        [self.activity stopAnimating];
        self.timeLabel.text = [NSString stringWithFormat:@"%@/%@", [self formatPlayTime:current], isnan(total)?@"00:00:00":[self formatPlayTime:total]];
    }else{
        [self.activity startAnimating];
    }
    self.lastTime = current;
    
}
//切换当前播放的内容
- (void)changeCurrentplayerItemWithAC_VideoModel:(AC_VideoModel *)model
{
    if (self.avPlayer) {
        
        //由暂停状态切换时候 开启定时器，将暂停按钮状态设置为播放状态
        self.link.paused = NO;
        self.playButton.selected = NO;
        
        //移除当前AVPlayerItem对"loadedTimeRanges"和"status"的监听
        [self removeObserveWithPlayerItem:self.avPlayer.currentItem];
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:model.url];
        [self addObserveWithPlayerItem:playerItem];
        self.avPlayerItem = playerItem;
        //更换播放的AVPlayerItem
        [self.avPlayer replaceCurrentItemWithPlayerItem:playerItem];
        
        self.playButton.enabled = NO;
        self.slider.enabled = NO;
    }
}

#pragma mark 监听视频缓冲和加载状态
//注册观察者监听状态和缓冲
- (void)addObserveWithPlayerItem:(AVPlayerItem *)playerItem
{
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
}

//移除处观察者
- (void)removeObserveWithPlayerItem:(AVPlayerItem *)playerItem
{
    [playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [playerItem removeObserver:self forKeyPath:@"status"];
}

- (NSString *)formatPlayTime:(NSTimeInterval)duration
{
    int minute = 0, hour = 0, secend = duration;
    minute = (secend % 3600)/60;
    hour = secend / 3600;
    secend = secend % 60;
    return [NSString stringWithFormat:@"%02d:%02d:%02d", hour, minute, secend];
}


//视频播放完成
- (void)moviePlayDidEnd
{
    NSLog(@"播放完成");

    NSInteger index = [self.videoArr indexOfObject:self.videoModel];
    if (index!= self.videoArr.count-1) {
        [self.avPlayer pause];
        self.videoModel = self.videoArr[index + 1];
        [self changeCurrentplayerItemWithAC_VideoModel:self.videoModel];
    }else{
        [self.avPlayer pause];
        [self.link invalidate];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark 各种事件点击
- (void)backAction:(UIButton *)button
{
    [self.avPlayer pause];
    [self.link invalidate];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)reloadAction:(UIButton *)button
{
    [self changeCurrentplayerItemWithAC_VideoModel:self.videoModel];
    self.faildView.hidden = YES;
}

- (void)showOrHideListTableViewAction:(UIButton *)button
{
    button.enabled = NO;
    [UIView animateWithDuration:.3 animations:^{
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        
        [self.listTableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.bottmView).offset(self.isHidenListView?0:300);
        }];
        
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        button.enabled = YES;
        self.isHidenListView = !self.isHidenListView;
    }];

}

//播放暂停按钮
- (void)playOrPauseAction:(UIButton *)sender
{
    sender.selected = !sender.selected;
    
    if (self.avPlayer.rate == 1) {
        [self.avPlayer pause];
        self.link.paused = YES;
        [self.activity stopAnimating];
    } else {
        [self.avPlayer play];
        self.link.paused = NO;
    }
}

//处理滑块
- (void)progressValueChange:(AC_ProgressSlider *)slider
{
    if (self.avPlayer.status == AVPlayerStatusReadyToPlay) {
        NSTimeInterval duration = self.slider.sliderPercent* CMTimeGetSeconds(self.avPlayer.currentItem.duration);
        CMTime seekTime = CMTimeMake(duration, 1);

        [self.avPlayer seekToTime:seekTime completionHandler:^(BOOL finished) {

        }];
    }
}

#pragma 手势
- (void)showOrHideBar
{

    if (!self.isHidenListView) {
        self.isHidenListView = YES;
        self.listTableView.hidden = YES;
        [self.listTableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.videoBackView).offset(300);
        }];
    }
    

    [UIView animateWithDuration:.3 animations:^{
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        
        [self.topView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.videoBackView).offset(self.isHidenTabView?0:-60);
        }];
        
        [self.bottmView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.videoBackView).offset(self.isHidenTabView?0:60);
        }];
        
        
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.isHidenTabView = !self.isHidenTabView;
        self.listTableView.hidden = NO;
    }];

}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    AVPlayerItem *playerItem = (AVPlayerItem *)object;

    if ([keyPath isEqualToString:@"loadedTimeRanges"]){
        NSTimeInterval loadedTime = [self availableDurationWithplayerItem:playerItem];
        NSTimeInterval totalTime = CMTimeGetSeconds(playerItem.duration);

        if (!self.slider.isSliding) {
            self.slider.progressPercent = loadedTime/totalTime;
        }
        
    }else if ([keyPath isEqualToString:@"status"]){
        if (playerItem.status == AVPlayerItemStatusReadyToPlay){
            NSLog(@"playerItem is ready");

            [self.avPlayer play];
            self.slider.enabled = YES;
            self.playButton.enabled = YES;
        } else{
            NSLog(@"load break");
            self.faildView.hidden = NO;
        }
    }
}


- (NSTimeInterval)availableDurationWithplayerItem:(AVPlayerItem *)playerItem
{
    NSArray *loadedTimeRanges = [playerItem loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    NSTimeInterval startSeconds = CMTimeGetSeconds(timeRange.start);
    NSTimeInterval durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.videoArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    AC_VideoModel *model = self.videoArr[indexPath.row];
    cell.textLabel.text = model.name;
    
    if (model == _videoModel) {
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:17];
    }
    else {
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:17];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AC_VideoModel *model = self.videoArr[indexPath.row];
    if (model == _videoModel) {
        return;
    }
    self.videoModel = model;
    [self changeCurrentplayerItemWithAC_VideoModel:self.videoModel];
    self.titleLabel.text = model.name;
    
    [self.listTableView reloadData];
}

#pragma mark - rotate control
//- (BOOL)shouldAutorotate
//{
//    return YES;
//}
//
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations
//{
//    return UIInterfaceOrientationMaskLandscape;
//}
//
//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
//{
//    return UIInterfaceOrientationLandscapeRight;
//}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

    [self showOrHideBar];
}


- (void)dealloc
{
    NSLog(@"dead");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeObserveWithPlayerItem:_avPlayerItem];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
