//
//  MZDebugSocketServiceProtocol.h
//  Meixue
//
//  Created by daniel on 2017/1/29.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MZDebugSocketMessage.h"

@protocol MZDebugSocketServiceProtocol

- (void)sendMessage:(MZDebugSocketMessage *)message;
- (void)receiveMessage:(MZDebugSocketMessage *)message;

@end
