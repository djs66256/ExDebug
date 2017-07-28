//
//  MZRunloopService.m
//  Meixue
//
//  Created by hzduanjiashun on 2017/2/9.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import "MZRunloopService.h"
#import "MZRunLoopDurationObserver.h"

@interface MZRunloopService () <MZRunLoopDurationObserverProtocol>

@end

@implementation MZRunloopService

- (void)didConnectToServer {
    [[MZRunLoopDurationObserver sharedInstance] addObserver:self];
}

- (void)didDisconnectToServer {
    [[MZRunLoopDurationObserver sharedInstance] removeObserver:self];
}

- (void)runloopWithDuration:(NSTimeInterval)duration {
    if (duration > 1./60) {
        MZDebugSocketMessage *msg = [MZDebugSocketMessage registerWithPath:@"runloop"];
        msg.body = @{@"duration": @(duration),
                     @"time": @(CFAbsoluteTimeGetCurrent())
                     };
        [self sendMessage:msg];
    }
}

@end
