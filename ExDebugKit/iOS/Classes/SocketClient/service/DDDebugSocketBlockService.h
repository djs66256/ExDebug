//
//  DDDebugSocketBlockService.h
//  Pods
//
//  Created by hzduanjiashun on 2017/3/6.
//
//

#import "DDDebugSocketService.h"

@interface DDDebugSocketBlockService : DDDebugSocketService

- (void)setDidConnectBlock:(void(^)())didConnect didDisconnectBlock:(void(^)())disconnectBlock;
- (void)setReceiveBlock:(void(^)(DDDebugSocketMessage *))receve;

@end
