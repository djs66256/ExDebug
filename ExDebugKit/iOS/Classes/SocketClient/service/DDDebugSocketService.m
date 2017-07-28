//
//  DDDebugSocketService.m
//  Meixue
//
//  Created by daniel on 2017/1/29.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import "DDDebugSocketService.h"

@implementation DDDebugSocketService {
    __weak id<DDDebugSocketServiceProtocol> _proxyService;
}

- (instancetype)initWithProxyService:(id<DDDebugSocketServiceProtocol>)service
{
    self = [super init];
    if (self) {
        _proxyService = service;
    }
    return self;
}

- (void)didConnectToServer { }
- (void)didDisconnectToServer { }

- (BOOL)validateMessage:(DDDebugSocketMessage *)message {
    return YES;
}

- (void)sendMessage:(DDDebugSocketMessage *)message {
    [_proxyService sendMessage:message];
}

- (void)receiveMessage:(DDDebugSocketMessage *)message {
    
}

- (void)on:(NSString *)expr dispatch:(void (^)(DDDebugSocketMessage *, NSDictionary *))block {
    
}

- (NSString *)rootDirectory {
    NSString *root = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"debugSocket"];
    [self checkDirectory:root];
    return root;
}

- (void)checkDirectory:(NSString *)dir {
    if (![[NSFileManager defaultManager] fileExistsAtPath:dir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

@end

@implementation DDDebugSocketRequestService

- (void)requestWithPath:(NSString *)path {
    [self sendMessage:[DDDebugSocketMessage requestWithPath:path]];
}

@end

@implementation DDDebugSocketRegisterService

- (void)registerWithPath:(NSString *)path {
    [self sendMessage:[DDDebugSocketMessage registerWithPath:path]];
}

@end
