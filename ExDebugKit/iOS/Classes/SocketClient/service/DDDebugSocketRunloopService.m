//
//  DDRunloopService.m
//  Meixue
//
//  Created by hzduanjiashun on 2017/2/9.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import "DDDebugSocketRunloopService.h"
#import "DDRunLoopDurationObserver.h"

@interface DDDebugSocketRunloopService () <DDRunLoopDurationObserverProtocol>
@property (assign, nonatomic) NSTimeInterval lastTime;
@property (assign, nonatomic) NSTimeInterval snapshotDuration;

@end

@implementation DDDebugSocketRunloopService

- (instancetype)init
{
    self = [super init];
    if (self) {
        _snapshotDuration = 1;
    }
    return self;
}

- (void)didConnectToServer {
    [[DDRunLoopDurationObserver sharedInstance] addObserver:self];
}

- (void)didDisconnectToServer {
    [[DDRunLoopDurationObserver sharedInstance] removeObserver:self];
}

- (NSString *)runloopDir {
    NSString *rl = [self.rootDirectory stringByAppendingPathComponent:@"runloop"];
    [self checkDirectory:rl];
    return rl;
}

- (void)runloopWithDuration:(NSTimeInterval)duration {
    if (duration > 1./60) {
        if (duration > 1 && (CFAbsoluteTimeGetCurrent() - _lastTime) > 5) {
            _lastTime = CFAbsoluteTimeGetCurrent();
            CGRect rect = [UIScreen mainScreen].bounds;
            UIGraphicsBeginImageContext(rect.size);
            [[UIApplication sharedApplication].keyWindow drawViewHierarchyInRect:rect afterScreenUpdates:YES];
            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            NSString *imageName = [NSString stringWithFormat:@"%ld.png", (NSInteger)CFAbsoluteTimeGetCurrent()];
            NSString *imagePath = [self.runloopDir stringByAppendingPathComponent:imageName];
            [UIImagePNGRepresentation(image) writeToFile:imagePath atomically:YES];
            
            DDDebugSocketMessage *msg = [DDDebugSocketMessage registerWithPath:@"runloop"];
            msg.body = @{@"duration": @(duration),
                         @"time": @(CFAbsoluteTimeGetCurrent()),
                         @"image": [imagePath stringByReplacingOccurrencesOfString:NSHomeDirectory() withString:@""]
                         };
            [self sendMessage:msg];
        }
        else {
            DDDebugSocketMessage *msg = [DDDebugSocketMessage registerWithPath:@"runloop"];
            msg.body = @{@"duration": @(duration),
                         @"time": @(CFAbsoluteTimeGetCurrent())
                         };
            [self sendMessage:msg];
        }
    }
}

@end
