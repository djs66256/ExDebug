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

/**
 | 'SIPC' | type |
 | id |
 | length | path |
 | length | head json |
 | length | body |
 */

#import <Foundation/Foundation.h>

typedef NS_ENUM(int, MZDebugSocketMessageType) {
    MZDebugSocketMessageTypeRequest = 1,
    MZDebugSocketMessageTypeRegister = 2
};

@protocol MZDebugSocketMessageDataValue <NSObject>
- (NSString *)contentType;
- (NSData *)NSDataValue;
@end

@interface MZDebugSocketMessage : NSObject {
    NSMutableDictionary *_head;
}

@property (assign, nonatomic) MZDebugSocketMessageType type;
@property (strong, nonatomic) NSString *path;
@property (strong, nonatomic) NSDictionary *head;
@property (assign, nonatomic) int id;
@property (strong, nonatomic) id<MZDebugSocketMessageDataValue> body;

+ (MZDebugSocketMessage *)requestWithPath:(NSString *)path;
+ (MZDebugSocketMessage *)registerWithPath:(NSString *)path;

// -1 未读完； -2数据错误
+ (MZDebugSocketMessage *)readFromData:(NSData *)data offset:(inout NSInteger *)offset errorCode:(out int *)code;

- (instancetype)initWithType:(MZDebugSocketMessageType)type
                        path:(NSString *)path
                        head:(NSDictionary *)head
                        body:(NSDictionary *)body;

- (NSData *)NSDataValue;
- (void)setHead:(id)object forKey:(NSString *)key;

- (MZDebugSocketMessage *)makeReplyMessage;
- (MZDebugSocketMessage *)buildReply:(void(^)(MZDebugSocketMessage *reply))block;

@end

@interface NSString (MZDebugSocketMessageDataValue) <MZDebugSocketMessageDataValue>
@end

@interface NSDictionary (MZDebugSocketMessageDataValue) <MZDebugSocketMessageDataValue>
@end

@interface NSArray (MZDebugSocketMessageDataValue) <MZDebugSocketMessageDataValue>
@end

@interface NSMutableData (MZDebugSocketMessage)
- (void)appendInt32:(int32_t)num;
- (void)appendLengthAndDataValue:(id<MZDebugSocketMessageDataValue>)value;
@end
@interface NSData (MZDebugSocketMessage) <MZDebugSocketMessageDataValue>
- (NSData *)readDataWithLength:(NSInteger)len offset:(NSInteger)offset;
- (NSString *)readStringWithLength:(NSInteger)len offset:(NSInteger)offset;
- (id)readJsonWithLength:(NSInteger)len offset:(NSInteger)offset;
- (int)readInt32WithOffset:(NSInteger)offset;
@end
