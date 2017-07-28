//
//  MZDebugSocketManager.m
//  Meixue
//
//  Created by daniel on 2017/1/28.
//  Copyright © 2017年 NetEase. All rights reserved.
//

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
