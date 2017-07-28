//
//  DDDebugSocketClient.h
//  Meixue
//
//  Created by daniel on 2017/1/28.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDDebugSocketMessage.h"

@protocol DDDebugSocketClientDelegate;
@interface DDDebugSocketClient : NSObject

@property (weak, nonatomic) id<DDDebugSocketClientDelegate> delegate;
@property (strong, atomic) NSString *host;
@property (assign, atomic) UInt16 port;
@property (assign, nonatomic) NSTimeInterval timeout;
@property (assign, readonly, nonatomic) BOOL connected;

//+ (instancetype)sharedInstance;

- (void)start;
- (void)restart;
- (void)stop;

- (void)sendMessage:(DDDebugSocketMessage *)message;

@end

@protocol DDDebugSocketClientDelegate <NSObject>

- (void)debugSocketClientDidConnectToServer:(DDDebugSocketClient *)client;
- (void)debugSocketClientDidDisconnectToServer:(DDDebugSocketClient *)client;
- (void)debugSocketClient:(DDDebugSocketClient *)client didReceiveMessage:(DDDebugSocketMessage *)message;

@end
