// MIT License
//
// Copyright (c) 2016 Daniel (djs66256@163.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

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
