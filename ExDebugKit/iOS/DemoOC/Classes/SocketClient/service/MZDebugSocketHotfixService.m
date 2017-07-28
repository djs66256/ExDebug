//
//  MZDebugSocketHotfixService.m
//  Meixue
//
//  Created by daniel on 2017/1/31.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import <MZHotfix/MZHotfix.h>
#import "MZDebugSocketHotfixService.h"

@implementation MZDebugSocketHotfixService

- (void)receiveMessage:(MZDebugSocketMessage *)message {
    if ([message.path hasPrefix:@"hotfix"]) {
        NSString *patchPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"hotfix.js"];
        if ([message.path isEqualToString:@"hotfix/run"]) {
            if ([message.body isKindOfClass:[NSString class]]) {
                NSString *hotfixCode = (NSString *)message.body;
                [hotfixCode writeToFile:patchPath atomically:YES encoding:NSUTF8StringEncoding error:NULL];
                @weakify(self);
                [MZHotfix updatePatchWithURL:[NSURL fileURLWithPath:patchPath]
                                        hash:hotfixCode.hotfix_digest
                                    complete:^(NSError *error) {
                                        @strongify(self);
                                        if (!error) {
                                            [MZHotfix applyPatch];
                                            
                                            MZDebugSocketMessage *reply = message.makeReplyMessage;
                                            reply.body = @{@"message": @"OK"};
                                            [self sendMessage:reply];
                                        }
                                        else {
                                            MZDebugSocketMessage *reply = message.makeReplyMessage;
                                            reply.body = @{@"message": error.localizedDescription, @"code": @(-1)};
                                            [self sendMessage:reply];
                                        }
                                    }];
            }
        }
        else if ([message.path isEqualToString:@"hotfix/clear"]) {
            [MZHotfix clearPatch];
            [[NSFileManager defaultManager] removeItemAtPath:patchPath error:nil];
            
            MZDebugSocketMessage *reply = message.makeReplyMessage;
            reply.body = @{@"message": @"OK"};
            [self sendMessage:reply];
        }
    }
}

@end
