//
//  MZDebugSocketLoggerService.m
//  Meixue
//
//  Created by daniel on 2017/1/29.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import "MZDebugSocketLoggerService.h"
#import "MZLogFormatter.h"
#import <DDLog.h>

@interface MZDebugSocketLogger : DDAbstractLogger

@property (nonatomic, weak) MZDebugSocketLoggerService *delegate;

@end

@implementation MZDebugSocketLogger

- (void)logMessage:(DDLogMessage *)logMessage {
    NSString *message = nil;
    if (_logFormatter) {
        message = [_logFormatter formatLogMessage:logMessage];
    }
    else {
        message = [[MZTTYLogFormatter new] formatLogMessage:logMessage];
    }
    [_delegate sendLog:message];
}

@end

@implementation MZDebugSocketLoggerService {
    MZDebugSocketLogger *_logger;
}

- (instancetype)initWithProxyService:(id<MZDebugSocketServiceProtocol>)service
{
    self = [super initWithProxyService:service];
    if (self) {
        _logger = [MZDebugSocketLogger new];
        _logger.delegate = self;
        [[DDLog sharedInstance] addLogger:_logger];
    }
    return self;
}

- (void)didDisconnectToServer {
    //[[DDLog sharedInstance] removeLogger:_logger];
}

- (void)receiveMessage:(MZDebugSocketMessage *)message {
    /*
    if ([message.path hasPrefix:@"logger"]) {
        if ([message.path isEqualToString:@"logger/on"]) {
            [[DDLog sharedInstance] addLogger:_logger];
            MZLogDebug(@"[DSS] logger on by service!");
            MZDebugSocketMessage *reply = message.makeReplyMessage;
            reply.body = @{@"code": @0, @"message": @"OK"};
            [self sendMessage:reply];
        }
        else if ([message.path isEqualToString:@"logger/off"]) {
            MZLogDebug(@"[DSS] logger off by service!");
            [[DDLog sharedInstance] removeLogger:_logger];
            MZDebugSocketMessage *reply = message.makeReplyMessage;
            reply.body = @{@"code": @0, @"message": @"OK"};
            [self sendMessage:reply];
        }
    }
    */
}

- (void)sendLog:(NSString *)log {
    MZDebugSocketMessage *msg = [MZDebugSocketMessage registerWithPath:@"logger"];
    msg.body = log;
    [self sendMessage:msg];
}

@end
