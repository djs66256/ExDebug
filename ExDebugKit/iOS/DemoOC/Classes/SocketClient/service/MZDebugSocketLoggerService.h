//
//  MZDebugSocketLoggerService.h
//  Meixue
//
//  Created by daniel on 2017/1/29.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import "MZDebugSocketService.h"

@interface MZDebugSocketLoggerService : MZDebugSocketRegisterService

- (void)sendLog:(NSString *)log;

@end
