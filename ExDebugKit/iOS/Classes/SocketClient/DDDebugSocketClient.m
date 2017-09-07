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

#import "DDDebugSocketClient.h"
#import "DDDebugSocketMessage.h"

@interface DDDebugSocketPackageData : NSObject
@property (nonatomic, strong) NSData *data;
@property (nonatomic, assign) CFIndex offset;
@end
@implementation DDDebugSocketPackageData

@end

@interface DDDebugSocketClient () {
    CFWriteStreamRef writeStream;
    CFReadStreamRef readStream;
    NSThread *thread;
    NSCondition *condition;
    NSTimer *retryTimer;
    NSRunLoop *runloop;
    
    NSMutableArray *writePackageDatas;
    NSMutableData *readBuffer;
}

- (void)_receiveData:(NSData *)data;
- (void)_beginRetryTimer;

- (void)_connectToServer;
- (void)_disconnectToServer;
- (void)_writeNextData;

@end

#define BufferSize 1024

static void DebugSocketClientReadStreamClientCallBack(CFReadStreamRef stream, CFStreamEventType type, void *clientCallBackInfo) {
    if ([(__bridge id)clientCallBackInfo isKindOfClass:[DDDebugSocketClient class]]) {
        DDDebugSocketClient *client = (__bridge DDDebugSocketClient *)clientCallBackInfo;
        switch (type) {
            case kCFStreamEventOpenCompleted: {
                [client _connectToServer];
            }
                break;
            case kCFStreamEventEndEncountered: {
                [client _disconnectToServer];
                [client _beginRetryTimer];
            }
                break;
            case kCFStreamEventCanAcceptBytes:
            case kCFStreamEventHasBytesAvailable: {
                NSMutableData *data = [[NSMutableData alloc] init];
                char buf[BufferSize] = {0};
                CFIndex index = 0;
                do {
                    index = CFReadStreamRead(stream, (UInt8 *)buf, BufferSize);
                    if (index > 0) {
                        [data appendBytes:buf length:index];
                    }
                } while (index >= BufferSize);
                
                [client _receiveData:data];
            }
                break;
            default:
                [client _beginRetryTimer];
                break;
        }
    }
}

static void DebugSocketClientWriteStreamClientCallBack(CFWriteStreamRef stream, CFStreamEventType type, void *clientCallBackInfo) {
    if ([(__bridge id)clientCallBackInfo isKindOfClass:[DDDebugSocketClient class]]) {
        DDDebugSocketClient *client = (__bridge DDDebugSocketClient *)clientCallBackInfo;
        switch (type) {
            case kCFStreamEventOpenCompleted: {
                [client _connectToServer];
            }
                break;
            case kCFStreamEventEndEncountered: {
                [client _disconnectToServer];
                [client _beginRetryTimer];
            }
                break;
            case kCFStreamEventCanAcceptBytes:
            case kCFStreamEventHasBytesAvailable: {
                [client _writeNextData];
            }
                break;
            default:
                [client _beginRetryTimer];
                break;
        }
    }
}

static void *TelnetRetain(void *info) {
    if (info) CFRetain(info);
    return info;
}

static void TelnetRelease(void *info) {
    if (info) CFRelease(info);
}


@implementation DDDebugSocketClient

/*
+ (instancetype)sharedInstance {
    static DDDebugSocketClient *client = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        client = [DDDebugSocketClient new];
    });
    return client;
}
 */

- (void)dealloc
{
    [self stop];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        writePackageDatas = [[NSMutableArray alloc] init];
        condition = [[NSCondition alloc] init];
        thread = [[NSThread alloc] initWithTarget:self selector:@selector(threadMain) object:nil];
        [condition lock];
        [thread start];
        [condition wait]; // 保证线程已经完全准备好
        [condition unlock];
        [self performSelector:@selector(_start) onThread:thread withObject:nil waitUntilDone:NO];
    }
    return self;
}

- (void)threadMain {
    [[NSRunLoop currentRunLoop] addPort:[NSPort port] forMode:NSDefaultRunLoopMode];
    runloop = [NSRunLoop currentRunLoop];
    [condition lock];
    [condition signal];
    [condition unlock];
    [runloop run];
    [condition lock];
    [condition signal];
    [condition unlock];
}

- (void)restart {
    [self performSelector:@selector(_restart) onThread:thread withObject:nil waitUntilDone:NO];
}

- (void)start {
    [self performSelector:@selector(_start) onThread:thread withObject:nil waitUntilDone:NO];
}

- (void)stop {
    [self performSelector:@selector(_stop) onThread:thread withObject:nil waitUntilDone:NO];
}

- (void)_beginRetryTimer {
    if (retryTimer == nil || ![retryTimer isValid]) {
        __weak typeof(self) weakSelf = self;
        @synchronized (self) {
            if (retryTimer) [retryTimer invalidate];
            retryTimer = [NSTimer timerWithTimeInterval:5.f target:self.class selector:@selector(_retryConnect:) userInfo:@{@"block":^{
                [weakSelf _retryConnect];
            }} repeats:YES];
        }
        [runloop addTimer:retryTimer forMode:NSDefaultRunLoopMode];
    }
}

+ (void)_retryConnect:(NSTimer *)timer {
    void (^block)() = timer.userInfo[@"block"];
    if (block) {
        block();
    }
}

- (void)_endRetryTimer {
    @synchronized (retryTimer) {
        [retryTimer invalidate];
        retryTimer = nil;
    }
}

static inline bool DebugSocketClientStreamIsOpen(CFStreamStatus sts) {
    return sts != kCFStreamStatusError && sts != kCFStreamStatusNotOpen && sts != kCFStreamStatusClosed && sts != kCFStreamStatusAtEnd;
}

- (void)_retryConnect {
    CFStreamStatus readStatus = CFReadStreamGetStatus(readStream);
    CFStreamStatus writeStatus = CFWriteStreamGetStatus(writeStream);
    if (DebugSocketClientStreamIsOpen(readStatus) && DebugSocketClientStreamIsOpen(writeStatus)) {
        [self _endRetryTimer];
    }
    else {
        [self restart];
    }
}

- (void)_restart {
    [self _stop];
    [self _start];
}

- (void)_start {
    if (writeStream == nil && readStream == nil) {
        CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)self.host, self.port, &readStream, &writeStream);
        
        CFStreamClientContext ctx = {
            0, (__bridge void *)self, TelnetRetain, TelnetRelease, NULL
        };
        CFWriteStreamSetClient(writeStream, 0xff, &DebugSocketClientWriteStreamClientCallBack, &ctx);
        CFReadStreamSetClient(readStream, 0xff, &DebugSocketClientReadStreamClientCallBack, &ctx);
        CFWriteStreamScheduleWithRunLoop(writeStream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        CFReadStreamScheduleWithRunLoop(readStream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        CFWriteStreamOpen(writeStream);
        CFReadStreamOpen(readStream);
        
        [self _beginRetryTimer];
    }
}

- (void)_stop {
    [self _endRetryTimer];
    if (writeStream) {
        CFWriteStreamClose(writeStream);
        writeStream = nil;
    }
    if (readStream) {
        CFReadStreamClose(readStream);
        readStream = nil;
    }
    [writePackageDatas removeAllObjects];
}

- (void)_connectToServer {
    if (!_connected) {
        _connected = YES;
        [self.delegate debugSocketClientDidConnectToServer:self];
    }
}

- (void)_disconnectToServer {
    if (_connected) {
        _connected = NO;
        [self.delegate debugSocketClientDidDisconnectToServer:self];
    }
}

- (void)_receiveData:(NSData *)data {
    if (readBuffer) {
        [readBuffer appendData:data];
        data = readBuffer;
    }
    NSInteger offset = 0;
    do {
        int code = 0;
        DDDebugSocketMessage *msg = [DDDebugSocketMessage readFromData:data offset:&offset errorCode:&code];
        if (msg) {
            readBuffer = nil;
            [self.delegate debugSocketClient:self didReceiveMessage:msg];
        }
        else if (code == -1) {
            if (readBuffer == nil) {
                readBuffer = [[NSMutableData alloc] init];
            }
            [readBuffer appendBytes:data.bytes+offset length:data.length-offset];
            return;
        }
        else {
            readBuffer = nil;
            return;
        }
    } while (offset < data.length);
}

- (void)_sendMessage:(DDDebugSocketMessage *)message {
    if (self.connected) {
        NSData *data = message.NSDataValue;
        [self _writeData:data];
    }
}

- (void)_writeData:(NSData *)data {
    if (writePackageDatas.count == 0 && CFWriteStreamCanAcceptBytes(writeStream)) {
        CFIndex index = CFWriteStreamWrite(writeStream, data.bytes, data.length);
        if (index == -1) {
            // error
            [self _restart];
        }
        else if (index < data.length) {
            DDDebugSocketPackageData *package = [DDDebugSocketPackageData new];
            package.data = data;
            package.offset = index;
            [writePackageDatas addObject:package];
        }
    }
    else if (writePackageDatas.count > 20) {
        // 丢包策略，防止网络阻塞
        return;
    }
    else {
        DDDebugSocketPackageData *package = [DDDebugSocketPackageData new];
        package.data = data;
        package.offset = 0;
        [writePackageDatas addObject:package];
    }
}

- (void)_writeNextData {
    if (writePackageDatas.count > 0) {
        DDDebugSocketPackageData *package = writePackageDatas.firstObject;
        package.offset += CFWriteStreamWrite(writeStream, package.data.bytes + package.offset, package.data.length - package.offset);
        if (package.offset >= package.data.length) {
            [writePackageDatas removeObjectAtIndex:0];
        }
    }
}

- (void)sendMessage:(DDDebugSocketMessage *)message {
    [self performSelector:@selector(_sendMessage:) onThread:thread withObject:message waitUntilDone:NO];
}

@end
