//
//  DDDebugSocketManager.m
//  Meixue
//
//  Created by daniel on 2017/1/28.
//  Copyright © 2017年 NetEase. All rights reserved.
//

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
