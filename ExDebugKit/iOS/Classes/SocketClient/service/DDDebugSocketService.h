//
//  DDDebugSocketService.h
//  Meixue
//
//  Created by daniel on 2017/1/29.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDDebugSocketMessage.h"
#import "DDDebugSocketServiceProtocol.h"

@interface DDDebugSocketService : NSObject<DDDebugSocketServiceProtocol>

- (instancetype)initWithProxyService:(id<DDDebugSocketServiceProtocol>)service;

- (void)didConnectToServer;
- (void)didDisconnectToServer;

- (BOOL)validateMessage:(DDDebugSocketMessage *)message;

- (void)sendMessage:(DDDebugSocketMessage *)message;
- (void)receiveMessage:(DDDebugSocketMessage *)message;

- (void)on:(NSString *)expr dispatch:(void(^)(DDDebugSocketMessage *msg, NSDictionary *params))block;

- (NSString *)rootDirectory;
- (void)checkDirectory:(NSString *)dir;

@end

@interface DDDebugSocketRequestService : DDDebugSocketService

- (void)requestWithPath:(NSString *)path;

@end

@interface DDDebugSocketRegisterService : DDDebugSocketService

- (void)registerWithPath:(NSString *)path;

@end
