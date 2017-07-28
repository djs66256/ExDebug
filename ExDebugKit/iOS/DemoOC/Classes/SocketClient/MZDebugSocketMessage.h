//
//  MZDebugSocketMessage.h
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
