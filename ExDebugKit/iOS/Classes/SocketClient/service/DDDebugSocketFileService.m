// MIT License
//
// Copyright (c) 2016 Daniel (djs66256@163.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#import <CommonCrypto/CommonDigest.h>
#import "DDDebugSocketFileService.h"

@implementation DDDebugSocketFileService

- (void)receiveMessage:(DDDebugSocketMessage *)message {
    if ([message.path hasPrefix:@"listdir"]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *path = [[message.path substringFromIndex:@"listdir".length] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/\\ "]];
            NSString *dir = [NSHomeDirectory() stringByAppendingPathComponent:path];
            NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dir error:nil];
            NSMutableArray *fileInfoArray = [NSMutableArray new];
            for (NSString *fn in files) {
                NSDictionary *dict = [[NSFileManager defaultManager] attributesOfItemAtPath:[dir stringByAppendingPathComponent:fn] error:nil];
                if (dict) {
                    NSMutableDictionary *fileInfo = [NSMutableDictionary new];
                    fileInfo[@"name"] = fn;
                    if ([dict[NSFileType] isEqualToString:NSFileTypeDirectory]) {
                        fileInfo[@"isDirectory"] = @YES;
                    }
                    fileInfo[@"createTime"] = @([dict.fileCreationDate timeIntervalSince1970]);
                    fileInfo[@"modifyTime"] = @([dict.fileModificationDate timeIntervalSince1970]);
                    fileInfo[@"fileSize"] = @([dict[NSFileSize] integerValue]);
                    [fileInfoArray addObject:fileInfo];
                }
            }
            DDDebugSocketMessage *reply = message.makeReplyMessage;
            reply.body = fileInfoArray;
            [self sendMessage:reply];
        });
    }
    else if ([message.path hasPrefix:@"file/"]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *path = [[message.path substringFromIndex:@"file".length] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/\\ "]];
            NSString *fullPath = [NSHomeDirectory() stringByAppendingPathComponent:path];
            if ([[NSFileManager defaultManager] isReadableFileAtPath:fullPath]) {
                NSInteger offset = [message.head[@"offset"] integerValue];
                NSInteger length = [message.head[@"length"] integerValue];
                
                NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:fullPath];
                [fileHandle seekToFileOffset:offset];
                DDDebugSocketMessage *reply = nil;
                if (length > 0) {
                    reply = [message buildReply:^(DDDebugSocketMessage *reply) {
                        reply.body = [fileHandle readDataOfLength:length];
                    }];
                }
                else {
                    reply = [message buildReply:^(DDDebugSocketMessage *reply) {
                        reply.body = [fileHandle readDataToEndOfFile];
                    }];
                }
                [self sendMessage:reply];
                [fileHandle closeFile];
            }
            else {
                [self sendMessage:[message buildReply:^(DDDebugSocketMessage *reply) {
                    [reply setHead:@(-1) forKey:@"code"];
                }]];
            }
        });
    }
    else if ([message.path hasPrefix:@"fileinfo/"]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *path = [[message.path substringFromIndex:@"fileinfo".length] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/\\ "]];
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
                DDDebugSocketMessage *reply = [message buildReply:^(DDDebugSocketMessage *reply) {
                    reply.body = @{ @"md5": fileMD5, @"fileSize": @(dict.fileSize) };
                }];
                [self sendMessage:reply];
                [fileHandle closeFile];
            }
            else {
                [self sendMessage:[message buildReply:^(DDDebugSocketMessage *reply) {
                    [reply setHead:@(-1) forKey:@"code"];
                }]];
            }
        });
    }
}

@end
