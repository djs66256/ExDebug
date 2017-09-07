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

#import "MZDebugSocketManager.h"
#import "MZDebugSocketClient.h"
#import "MZDebugSocketDeviceInfoService.h"
#import "MZDebugSocketLoggerService.h"
#import "MZDebugListdirService.h"
#import "MZDebugSocketHotfixService.h"
#import "MZDebugSocketSytemInfoService.h"
#import "MZRunloopService.h"

@interface MZDebugSocketManager () <MZDebugSocketServiceProtocol, MZDebugSocketClientDelegate> {
    NSMutableArray *_services;
}

@property (nonatomic, strong) MZDebugSocketClient *socketClient;

@end

@implementation MZDebugSocketManager

+ (instancetype)sharedInstance {
    static MZDebugSocketManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[MZDebugSocketManager alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _socketClient = [[MZDebugSocketClient alloc] init];
        _socketClient.delegate = self;
        _host = @"localhost";
        _port = 9000;
        
        _services = [[NSMutableArray alloc] init];
        [self prepareServices];
    }
    return self;
}

- (void)prepareServices {
    NSArray *serviceNames = @[
                              MZDebugSocketDeviceInfoService.class,
                              MZDebugSocketLoggerService.class,
                              MZDebugListdirService.class,
                              MZDebugSocketHotfixService.class,
                              MZDebugSocketSytemInfoService.class,
                              MZRunloopService.class
                              ];
    
    for (Class cls in serviceNames) {
        [_services addObject:[[cls alloc] initWithProxyService:self]];
    }
}

- (BOOL)connected {
    return _socketClient.connected;
}

- (void)connect {
    _socketClient.host = self.host;
    _socketClient.port = self.port;
    [_socketClient start];
}

- (void)disconnect {
    if (_socketClient.connected) {
        [_socketClient stop];
    }
}

- (void)sendMessage:(MZDebugSocketMessage *)message {
    if (_socketClient.connected) {
        [_socketClient sendMessage:message];
    }
}

- (void)receiveMessage:(MZDebugSocketMessage *)message {
    for (MZDebugSocketService *service in _services) {
        if ([service validateMessage:message]) {
            [service receiveMessage:message];
        }
    }
}

- (void)debugSocketClientDidConnectToServer:(MZDebugSocketClient *)client {
    for (MZDebugSocketService *service in _services) {
        [service didConnectToServer];
    }
}

- (void)debugSocketClientDidDisconnectToServer:(MZDebugSocketClient *)client {
    for (MZDebugSocketService *service in _services) {
        [service didDisconnectToServer];
    }
}

- (void)debugSocketClient:(MZDebugSocketClient *)client didReceiveMessage:(MZDebugSocketMessage *)message {
    [self receiveMessage:message];
}

@end
