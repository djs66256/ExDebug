//
//  DDDebugSocketMessage.h
//  Meixue
//
//  Created by daniel on 2017/1/28.
//  Copyright © 2017年 NetEase. All rights reserved.
//

/**
 | 'SIPC' | type |
 | id |
 | length | path |
 | length | head json |
 | length | body |
 */

#import <Foundation/Foundation.h>

typedef NS_ENUM(int, DDDebugSocketMessageType) {
    DDDebugSocketMessageTypeRequest = 1,
    DDDebugSocketMessageTypeRegister = 2
};

@protocol DDDebugSocketMessageDataValue <NSObject>
- (NSString *)contentType;
- (NSData *)NSDataValue;
@end

@interface DDDebugSocketMessage : NSObject {
    NSMutableDictionary *_head;
}

@property (assign, nonatomic) DDDebugSocketMessageType type;
@property (strong, nonatomic) NSString *path;
@property (strong, nonatomic) NSDictionary *head;
@property (assign, nonatomic) int id;
@property (strong, nonatomic) id<DDDebugSocketMessageDataValue> body;

+ (DDDebugSocketMessage *)requestWithPath:(NSString *)path;
+ (DDDebugSocketMessage *)registerWithPath:(NSString *)path;

// -1 未读完； -2数据错误
+ (DDDebugSocketMessage *)readFromData:(NSData *)data offset:(inout NSInteger *)offset errorCode:(out int *)code;

- (instancetype)initWithType:(DDDebugSocketMessageType)type
                        path:(NSString *)path
                        head:(NSDictionary *)head
                        body:(NSDictionary *)body;

- (NSData *)NSDataValue;
- (void)setHead:(id)object forKey:(NSString *)key;

- (DDDebugSocketMessage *)makeReplyMessage;
- (DDDebugSocketMessage *)buildReply:(void(^)(DDDebugSocketMessage *reply))block;

@end

@interface NSString (DDDebugSocketMessageDataValue) <DDDebugSocketMessageDataValue>
@end

@interface NSDictionary (DDDebugSocketMessageDataValue) <DDDebugSocketMessageDataValue>
@end

@interface NSArray (DDDebugSocketMessageDataValue) <DDDebugSocketMessageDataValue>
@end

@interface NSMutableData (DDDebugSocketMessage)
- (void)appendInt32:(int32_t)num;
- (void)appendLengthAndDataValue:(id<DDDebugSocketMessageDataValue>)value;
@end
@interface NSData (DDDebugSocketMessage) <DDDebugSocketMessageDataValue>
- (NSData *)readDataWithLength:(NSInteger)len offset:(NSInteger)offset;
- (NSString *)readStringWithLength:(NSInteger)len offset:(NSInteger)offset;
- (id)readJsonWithLength:(NSInteger)len offset:(NSInteger)offset;
- (int)readInt32WithOffset:(NSInteger)offset;
@end
