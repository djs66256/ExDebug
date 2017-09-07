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

#import "DDDebugSocketManager.h"
#import "DDDebugSocketClient.h"
#import "DDDebugSocketDeviceInfoService.h"
#import "DDDebugSocketLoggerService.h"
#import "DDDebugSocketFileService.h"
#import "DDDebugSocketHotfixService.h"
#import "DDDebugSocketSytemInfoService.h"
#import "DDDebugSocketRequestInfoService.h"
#import "DDDebugSocketRunloopService.h"

@interface DDDebugSocketManager () <DDDebugSocketServiceProtocol, DDDebugSocketClientDelegate> {
    NSMutableArray *_services;
}

@property (nonatomic, strong) DDDebugSocketClient *socketClient;

@end

@implementation DDDebugSocketManager

+ (instancetype)sharedInstance {
    static DDDebugSocketManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[DDDebugSocketManager alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _socketClient = [[DDDebugSocketClient alloc] init];
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
                              DDDebugSocketDeviceInfoService.class,
                              DDDebugSocketLoggerService.class,
                              DDDebugSocketFileService.class,
                              DDDebugSocketHotfixService.class,
                              DDDebugSocketSytemInfoService.class,
                              DDDebugSocketRunloopService.class,
                              DDDebugSocketRequestInfoService.class
                              ];
    
    @synchronized (_services) {
        for (Class cls in serviceNames) {
            [_services addObject:[[cls alloc] initWithProxyService:self]];
        }
    }
}

- (DDDebugSocketService *)registerService:(Class)cls {
    DDDebugSocketService *service = [[cls alloc] initWithProxyService:self];
    @synchronized (_services) {
        [_services addObject:service];
    }
    return service;
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

- (void)sendMessage:(DDDebugSocketMessage *)message {
    if (_socketClient.connected) {
        [_socketClient sendMessage:message];
    }
}

- (void)receiveMessage:(DDDebugSocketMessage *)message {
    for (DDDebugSocketService *service in _services) {
        if ([service validateMessage:message]) {
            [service receiveMessage:message];
        }
    }
}

- (void)debugSocketClientDidConnectToServer:(DDDebugSocketClient *)client {
    for (DDDebugSocketService *service in _services) {
        [service didConnectToServer];
    }
}

- (void)debugSocketClientDidDisconnectToServer:(DDDebugSocketClient *)client {
    for (DDDebugSocketService *service in _services) {
        [service didDisconnectToServer];
    }
}

- (void)debugSocketClient:(DDDebugSocketClient *)client didReceiveMessage:(DDDebugSocketMessage *)message {
    [self receiveMessage:message];
}

@end
