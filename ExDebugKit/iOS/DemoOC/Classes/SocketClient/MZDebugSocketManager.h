//
//  MZDebugSocketManager.h
//  Meixue
//
//  Created by daniel on 2017/1/28.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MZDebugSocketManager : NSObject

+ (instancetype)sharedInstance;

@property (strong, atomic) NSString *host;
@property (assign, atomic) int port;
@property (readonly, nonatomic) BOOL connected;

- (void)connect;
- (void)disconnect;

@end
