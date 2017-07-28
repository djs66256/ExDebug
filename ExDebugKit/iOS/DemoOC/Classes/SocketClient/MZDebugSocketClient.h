//
//  MZDebugSocketClient.h
//  Meixue
//
//  Created by daniel on 2017/1/28.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MZDebugSocketMessage.h"

@protocol MZDebugSocketClientDelegate;
@interface MZDebugSocketClient : NSObject

@property (weak, nonatomic) id<MZDebugSocketClientDelegate> delegate;
@property (strong, atomic) NSString *host;
@property (assign, atomic) UInt16 port;
@property (assign, nonatomic) NSTimeInterval timeout;
@property (assign, readonly, nonatomic) BOOL connected;

//+ (instancetype)sharedInstance;

- (void)start;
- (void)restart;
- (void)stop;

- (void)sendMessage:(MZDebugSocketMessage *)message;

@end

@protocol MZDebugSocketClientDelegate <NSObject>

- (void)debugSocketClientDidConnectToServer:(MZDebugSocketClient *)client;
- (void)debugSocketClientDidDisconnectToServer:(MZDebugSocketClient *)client;
- (void)debugSocketClient:(MZDebugSocketClient *)client didReceiveMessage:(MZDebugSocketMessage *)message;

@end
