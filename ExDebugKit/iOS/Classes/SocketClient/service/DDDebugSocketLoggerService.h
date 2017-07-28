//
//  DDDebugSocketLoggerService.h
//  Meixue
//
//  Created by daniel on 2017/1/29.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import "DDDebugSocketService.h"

@interface DDDebugSocketLoggerService : DDDebugSocketRegisterService

- (void)sendLog:(NSString *)log;

@end
