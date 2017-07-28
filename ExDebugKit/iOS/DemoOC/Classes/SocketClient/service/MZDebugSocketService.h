//
//  MZDebugSocketService.h
//  Meixue
//
//  Created by daniel on 2017/1/29.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MZDebugSocketMessage.h"
#import "MZDebugSocketServiceProtocol.h"

@interface MZDebugSocketService : NSObject<MZDebugSocketServiceProtocol>

- (instancetype)initWithProxyService:(id<MZDebugSocketServiceProtocol>)service;

- (void)didConnectToServer;
- (void)didDisconnectToServer;

- (BOOL)validateMessage:(MZDebugSocketMessage *)message;

- (void)sendMessage:(MZDebugSocketMessage *)message;
- (void)receiveMessage:(MZDebugSocketMessage *)message;

- (void)on:(NSString *)expr dispatch:(void(^)(MZDebugSocketMessage *msg, NSDictionary *params))block;

@end

@interface MZDebugSocketRequestService : MZDebugSocketService

- (void)requestWithPath:(NSString *)path;

@end

@interface MZDebugSocketRegisterService : MZDebugSocketService

- (void)registerWithPath:(NSString *)path;

@end
