//
//  DDDebugSocketBlockService.m
//  Pods
//
//  Created by hzduanjiashun on 2017/3/6.
//
//

#import "DDDebugSocketBlockService.h"

@interface DDDebugSocketBlockService ()

@property (copy) void (^didConnectBlock)();
@property (copy) void (^didDisconnectBlock)();
@property (copy) void (^receiveBlock)(DDDebugSocketMessage *);

@end

@implementation DDDebugSocketBlockService

- (void)setDidConnectBlock:(void (^)())didConnect didDisconnectBlock:(void (^)())disconnectBlock {
    self.didConnectBlock = didConnect;
    self.didDisconnectBlock = disconnectBlock;
}

- (void)didConnectToServer {
    if (self.didConnectBlock) {
        self.didConnectBlock();
    }
}

- (void)didDisconnectToServer {
    if (self.didDisconnectBlock) {
        self.didDisconnectBlock();
    }
}

- (void)receiveMessage:(DDDebugSocketMessage *)message {
    if (self.receiveBlock) {
        self.receiveBlock(message);
    }
}

@end
