//
//  MZDebugListdirService.m
//  Meixue
//
//  Created by daniel on 2017/1/30.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import <YYModel.h>
#import <CommonCrypto/CommonDigest.h>
#import "MZDebugListdirService.h"

@interface MZDebugListdirFileInfo : NSObject <YYModel>
@property (strong, nonatomic) NSString *name;
@property (assign, nonatomic) BOOL isDirectory;
@property (strong, nonatomic) NSDate *createTime;
@property (strong, nonatomic) NSDate *modifyTime;
@property (assign, nonatomic) NSInteger fileSize;
@end

@implementation MZDebugListdirFileInfo

@end

@implementation MZDebugListdirService

- (void)receiveMessage:(MZDebugSocketMessage *)message {
    if ([message.path hasPrefix:@"listdir"]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *path = [[message.path substringFromIndex:@"listdir".length] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/\\ "]];
            NSString *dir = [NSHomeDirectory() stringByAppendingPathComponent:path];
            NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dir error:nil];
            NSMutableArray *fileInfoArray = [NSMutableArray new];
            for (NSString *fn in files) {
                NSDictionary *dict = [[NSFileManager defaultManager] attributesOfItemAtPath:[dir stringByAppendingPathComponent:fn] error:nil];
                if (dict) {
                    MZDebugListdirFileInfo *fileInfo = [MZDebugListdirFileInfo new];
                    fileInfo.name = fn;
                    if ([dict[NSFileType] isEqualToString:NSFileTypeDirectory]) {
                        fileInfo.isDirectory = YES;
                    }
                    fileInfo.createTime = dict[NSFileCreationDate];
                    fileInfo.modifyTime = dict[NSFileModificationDate];
                    fileInfo.fileSize = [dict[NSFileSize] integerValue];
                    [fileInfoArray addObject:fileInfo];
                }
            }
            MZDebugSocketMessage *reply = message.makeReplyMessage;
            reply.body = fileInfoArray.yy_modelToJSONObject;
            [self sendMessage:reply];
        });
    }
    else if ([message.path hasPrefix:@"file"]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *path = [[message.path substringFromIndex:@"file".length] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/\\ "]];
            NSString *fullPath = [NSHomeDirectory() stringByAppendingPathComponent:path];
            if ([[NSFileManager defaultManager] isReadableFileAtPath:fullPath]) {
                NSInteger offset = [message.head[@"offset"] integerValue];
                NSInteger length = [message.head[@"length"] integerValue];
                
                NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:fullPath];
                [fileHandle seekToFileOffset:offset];
                MZDebugSocketMessage *reply = nil;
                if (length > 0) {
                    reply = [message buildReply:^(MZDebugSocketMessage *reply) {
                        reply.body = [fileHandle readDataOfLength:length];
                    }];
                }
                else {
                    reply = [message buildReply:^(MZDebugSocketMessage *reply) {
                        reply.body = [fileHandle readDataToEndOfFile];
                    }];
                }
                [self sendMessage:reply];
                [fileHandle closeFile];
            }
            else {
                [self sendMessage:[message buildReply:^(MZDebugSocketMessage *reply) {
                    [reply setHead:@(-1) forKey:@"code"];
                }]];
            }
        });
    }
    else if ([message.path hasPrefix:@"fileinfo"]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *path = [[message.path substringFromIndex:@"file".length] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/\\ "]];
            NSString *fullPath = [NSHomeDirectory() stringByAppendingPathComponent:path];
            if ([[NSFileManager defaultManager] isReadableFileAtPath:fullPath]) {
                NSDictionary *dict = [[NSFileManager defaultManager] attributesOfItemAtPath:fullPath error:nil];
                NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:fullPath];
                CC_MD5_CTX md5;
                CC_MD5_Init(&md5);
                BOOL done = NO;
                while (!done) {
                    NSData *fileData = [fileHandle readDataOfLength:256];
                    CC_MD5_Update(&md5, fileData.bytes, (CC_LONG)fileData.length);
                    if (fileData.length < 256) done = YES;
                }
                unsigned char digest[CC_MD5_DIGEST_LENGTH];
                CC_MD5_Final(digest, &md5);
                NSString *fileMD5 = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                                digest[0], digest[1],
                                digest[2], digest[3],
                                digest[4], digest[5],
                                digest[6], digest[7],
                                digest[8], digest[9],
                                digest[10], digest[11],
                                digest[12], digest[13],
                                digest[14], digest[15]];
                MZDebugSocketMessage *reply = [message buildReply:^(MZDebugSocketMessage *reply) {
                    reply.body = @{ @"md5": fileMD5, @"fileSize": @(dict.fileSize) };
                }];
                [self sendMessage:reply];
                [fileHandle closeFile];
            }
            else {
                [self sendMessage:[message buildReply:^(MZDebugSocketMessage *reply) {
                    [reply setHead:@(-1) forKey:@"code"];
                }]];
            }
        });
    }
}

@end
