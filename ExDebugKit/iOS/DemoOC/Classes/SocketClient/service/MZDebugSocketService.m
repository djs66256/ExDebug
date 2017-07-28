//
//  MZDebugSocketService.m
//  Meixue
//
//  Created by daniel on 2017/1/29.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import "MZDebugSocketService.h"

@implementation MZDebugSocketService {
    __weak id<MZDebugSocketServiceProtocol> _proxyService;
}

- (instancetype)initWithProxyService:(id<MZDebugSocketServiceProtocol>)service
{
    self = [super init];
    if (self) {
        _proxyService = service;
    }
    return self;
}

- (void)didConnectToServer { }
- (void)didDisconnectToServer { }

- (BOOL)validateMessage:(MZDebugSocketMessage *)message {
    return YES;
}

- (void)sendMessage:(MZDebugSocketMessage *)message {
    [_proxyService sendMessage:message];
}

- (void)receiveMessage:(MZDebugSocketMessage *)message {
    
}

- (void)on:(NSString *)expr dispatch:(void (^)(MZDebugSocketMessage *, NSDictionary *))block {
    
}

@end

@implementation MZDebugSocketRequestService

- (void)requestWithPath:(NSString *)path {
    [self sendMessage:[MZDebugSocketMessage requestWithPath:path]];
}

@end

@implementation MZDebugSocketRegisterService

- (void)registerWithPath:(NSString *)path {
    [self sendMessage:[MZDebugSocketMessage registerWithPath:path]];
}

@end
