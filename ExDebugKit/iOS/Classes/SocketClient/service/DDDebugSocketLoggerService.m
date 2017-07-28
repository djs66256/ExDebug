//
//  DDDebugSocketLoggerService.m
//  Meixue
//
//  Created by daniel on 2017/1/29.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import "DDDebugSocketLoggerService.h"
#import "DDLogFormatter.h"
#import <CocoaLumberjack/DDLog.h>

@interface DDDebugSocketLogger : DDAbstractLogger

@property (nonatomic, weak) DDDebugSocketLoggerService *delegate;

@end

@implementation DDDebugSocketLogger

- (void)logMessage:(DDLogMessage *)logMessage {
    NSString *message = nil;
    if (_logFormatter) {
        message = [_logFormatter formatLogMessage:logMessage];
    }
    else {
        message = [[DDSocketLogFormatter new] formatLogMessage:logMessage];
    }
    [_delegate sendLog:message];
}

@end

@implementation DDDebugSocketLoggerService {
    DDDebugSocketLogger *_logger;
}

- (instancetype)initWithProxyService:(id<DDDebugSocketServiceProtocol>)service
{
    self = [super initWithProxyService:service];
    if (self) {
        _logger = [DDDebugSocketLogger new];
        _logger.delegate = self;
        [[DDLog sharedInstance] addLogger:_logger];
    }
    return self;
}

- (void)didDisconnectToServer {
    //[[DDLog sharedInstance] removeLogger:_logger];
}

- (void)receiveMessage:(DDDebugSocketMessage *)message {
    /*
    if ([message.path hasPrefix:@"logger"]) {
        if ([message.path isEqualToString:@"logger/on"]) {
            [[DDLog sharedInstance] addLogger:_logger];
            DDLogDebug(@"[DSS] logger on by service!");
            DDDebugSocketMessage *reply = message.makeReplyMessage;
            reply.body = @{@"code": @0, @"message": @"OK"};
            [self sendMessage:reply];
        }
        else if ([message.path isEqualToString:@"logger/off"]) {
            DDLogDebug(@"[DSS] logger off by service!");
            [[DDLog sharedInstance] removeLogger:_logger];
            DDDebugSocketMessage *reply = message.makeReplyMessage;
            reply.body = @{@"code": @0, @"message": @"OK"};
            [self sendMessage:reply];
        }
    }
    */
}

- (void)sendLog:(NSString *)log {
    DDDebugSocketMessage *msg = [DDDebugSocketMessage registerWithPath:@"logger"];
    msg.body = log;
    [self sendMessage:msg];
}

@end
