//
//  MZDebugSocketDeviceInfoService.m
//  Meixue
//
//  Created by daniel on 2017/1/29.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import "MZDebugSocketDeviceInfoService.h"
#import "MZAppRunInfo.h"

@implementation MZDebugSocketDeviceInfoService

- (void)receiveMessage:(MZDebugSocketMessage *)message {
    if ([message.path isEqualToString:@"deviceInfo"]) {
        MZDebugSocketMessage *reply = message.makeReplyMessage;
        reply.body = [MZAppConfig defaultConfig].mz_appDeviceInfo;
        [self sendMessage:reply];
    }
}

@end
