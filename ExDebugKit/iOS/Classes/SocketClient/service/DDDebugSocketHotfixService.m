//
//  DDDebugSocketHotfixService.m
//  Meixue
//
//  Created by daniel on 2017/1/31.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#if HOTFIX
#import <MZHotfix/MZHotfix.h>
#endif

#import "DDDebugSocketHotfixService.h"

@implementation DDDebugSocketHotfixService

- (void)receiveMessage:(DDDebugSocketMessage *)message {
    if ([message.path hasPrefix:@"hotfix"]) {
#if HOTFIX
        NSString *patchPath = [self.rootDirectory stringByAppendingPathComponent:@"hotfix.js"];
        if ([message.path isEqualToString:@"hotfix/run"]) {
            if ([message.body isKindOfClass:[NSString class]]) {
                NSString *hotfixCode = (NSString *)message.body;
                [hotfixCode writeToFile:patchPath atomically:YES encoding:NSUTF8StringEncoding error:NULL];
                __weak typeof(self) weakSelf = self;
                [MZHotfix updatePatchWithURL:[NSURL fileURLWithPath:patchPath]
                                        hash:hotfixCode.hotfix_digest
                                    complete:^(NSError *error) {
                                        typeof(weakSelf) self = weakSelf;
                                        if (!error) {
                                            [MZHotfix applyPatch];
                                            
                                            DDDebugSocketMessage *reply = message.makeReplyMessage;
                                            reply.body = @{@"message": @"OK"};
                                            [self sendMessage:reply];
                                        }
                                        else {
                                            DDDebugSocketMessage *reply = message.makeReplyMessage;
                                            reply.body = @{@"message": error.localizedDescription, @"code": @(-1)};
                                            [self sendMessage:reply];
                                        }
                                    }];
            }
        }
        else if ([message.path isEqualToString:@"hotfix/clear"]) {
            [MZHotfix clearPatch];
            [[NSFileManager defaultManager] removeItemAtPath:patchPath error:nil];
            
            DDDebugSocketMessage *reply = message.makeReplyMessage;
            reply.body = @{@"message": @"OK"};
            [self sendMessage:reply];
        }
#else
        DDDebugSocketMessage *reply = message.makeReplyMessage;
        reply.body = @{@"message": @"Do not support hotfix",
                       @"code": @-1};
        [self sendMessage:reply];
#endif
    }
}

@end
