//
//  DDDebugSocketServiceProtocol.h
//  Meixue
//
//  Created by daniel on 2017/1/29.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDDebugSocketMessage.h"

@protocol DDDebugSocketServiceProtocol

- (void)sendMessage:(DDDebugSocketMessage *)message;
- (void)receiveMessage:(DDDebugSocketMessage *)message;

@end
