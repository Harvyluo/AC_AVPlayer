//
//  AC_AVPlayerViewController.h
//  AC_AVPlayer
//
//  Created by FM-13 on 16/6/12.
//  Copyright © 2016年 cong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AC_VideoModel : NSObject

@property (nonatomic,strong,readonly) NSURL *url;
@property (nonatomic,copy,readonly) NSString *name;

- (instancetype)initWithName:(NSString *)name url:(NSURL *)url;

@end

@interface AC_AVPlayerViewController : UIViewController

- (instancetype)initWithVideoList:(NSArray <AC_VideoModel *> *)videoList;



@end
