//
//  MZDebugSocketMessage.m
//  Meixue
//
//  Created by daniel on 2017/1/28.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import "MZDebugSocketMessage.h"

@implementation MZDebugSocketMessage
@synthesize head = _head;

+ (MZDebugSocketMessage *)requestWithPath:(NSString *)path {
    return [[MZDebugSocketMessage alloc] initWithType:MZDebugSocketMessageTypeRequest path:path head:nil body:nil];
}

+ (MZDebugSocketMessage *)registerWithPath:(NSString *)path {
    return [[MZDebugSocketMessage alloc] initWithType:MZDebugSocketMessageTypeRegister path:path head:nil body:nil];
}

+ (MZDebugSocketMessage *)readFromData:(NSData *)data offset:(inout NSInteger *)offsetPtr errorCode:(out int *)code {
    NSInteger offset = *offsetPtr;
    NSString *sipc = [data readStringWithLength:4 offset:offset];
    offset += 4;
    if ([sipc isEqualToString:@"SIPC"]) {
        MZDebugSocketMessage *msg = [[MZDebugSocketMessage alloc] init];
        // type
        msg.type = [data readInt32WithOffset:offset];
        offset += sizeof(int32_t);
        // id
        msg.id = [data readInt32WithOffset:offset];
        offset += sizeof(int32_t);
        // path
        int pathLength = [data readInt32WithOffset:offset];
        offset += sizeof(int32_t);
        msg.path = [data readStringWithLength:pathLength offset:offset];
        offset += pathLength;
        // head
        int headLength = [data readInt32WithOffset:offset];
        offset += sizeof(int32_t);
        msg.head = [data readJsonWithLength:headLength offset:offset];
        offset += headLength;
        // body
        int bodyLength = [data readInt32WithOffset:offset];
        offset += sizeof(int32_t);
        if (offset + bodyLength > data.length) {
            if (code) *code = -1;
            return nil;
        }
        if ([msg.head[@"contentType"] isEqualToString:@"json"]) {
            msg.body = [data readJsonWithLength:bodyLength offset:offset];
        }
        else {
            msg.body = [data readStringWithLength:bodyLength offset:offset];
        }
        offset += bodyLength;
        *offsetPtr = offset;
        if (code) *code = 0;
        return msg;
    }
    else {
        if (code) *code = -2;
    }
    return nil;
}

- (instancetype)initWithType:(MZDebugSocketMessageType)type path:(NSString *)path head:(NSDictionary *)head body:(NSDictionary *)body
{
    self = [super init];
    if (self) {
        self.type = type;
        self.path = path;
        self.head = head.mutableCopy ?: [NSMutableDictionary dictionary];
        self.body = body;
    }
    return self;
}

- (NSData *)NSDataValue {
    if (self.body.contentType) {
        [_head setObject:self.body.contentType forKey:@"contentType"];
    }
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:@"SIPC".NSDataValue];
    [data appendInt32:self.type];
    [data appendInt32:self.id];
    [data appendLengthAndDataValue:self.path];
    [data appendLengthAndDataValue:self.head];
    [data appendLengthAndDataValue:self.body];
    
    return data;
}

- (void)setHead:(id)object forKey:(NSString *)key {
    if (object) {
        [_head setObject:object forKey:key];
    }
    else {
        [_head removeObjectForKey:key];
    }
}

- (MZDebugSocketMessage *)makeReplyMessage {
    MZDebugSocketMessage *reply = [[MZDebugSocketMessage alloc] initWithType:self.type path:self.path head:self.head body:nil];
    reply.id = self.id;
    return reply;
}

- (MZDebugSocketMessage *)buildReply:(void (^)(MZDebugSocketMessage *))block {
    MZDebugSocketMessage *reply = [[MZDebugSocketMessage alloc] initWithType:self.type path:self.path head:self.head body:nil];
    reply.id = self.id;
    block(reply);
    return reply;
}

- (NSString *)debugDescription {
    NSData *headData = [NSJSONSerialization dataWithJSONObject:self.head options:NSJSONWritingPrettyPrinted error:nil];
    NSString *headString = nil;
    if (headData) {
        headString = [[NSString alloc] initWithData:headData encoding:NSUTF8StringEncoding];
    }
    NSString *bodyString = nil;
    if ([self.body isKindOfClass:[NSString class]]) {
        bodyString = (NSString *)self.body;
    }
    else if (self.body) {
        NSData *bodyData = [NSJSONSerialization dataWithJSONObject:self.body options:NSJSONWritingPrettyPrinted error:nil];
        if (bodyData) {
            bodyString = [[NSString alloc] initWithData:bodyData encoding:NSUTF8StringEncoding];
        }
    }
    return [NSString stringWithFormat:@"<SIPC Message> %@ %d (%@)\n head: %@\n body: %@",
            self.type == MZDebugSocketMessageTypeRequest ? @"REQUEST" : @"RESPONSE",
            self.id, self.path,
            headString, bodyString];
}

@end

@implementation NSString (MZDebugSocketMessageDataValue)
- (NSString *)contentType {
    return @"string";
}
- (NSData *)NSDataValue {
    return [self dataUsingEncoding:NSUTF8StringEncoding];
}
@end

@implementation NSDictionary (MZDebugSocketMessageDataValue)
- (NSString *)contentType {
    return @"json";
}
- (NSData *)NSDataValue {
    return [NSJSONSerialization dataWithJSONObject:self options:0 error:nil];
}
@end

@implementation NSArray (MZDebugSocketMessageDataValue)
- (NSString *)contentType {
    return @"json";
}
- (NSData *)NSDataValue {
    return [NSJSONSerialization dataWithJSONObject:self options:0 error:nil];
}
@end

@implementation NSMutableData (MZDebugSocketMessage)

- (void)appendInt32:(int32_t)num {
    int32_t bigNum = NSSwapHostIntToBig(num);
    [self appendBytes:&bigNum length:sizeof(int32_t)];
}

- (void)appendLengthAndDataValue:(id<MZDebugSocketMessageDataValue>)value {
    NSData *data = value.NSDataValue;
    if (data) {
        [self appendInt32:(int)data.length];
        if (data.length > 0) {
            [self appendData:data];
        }
    }
    else {
        [self appendInt32:0];
    }
}

@end

@implementation NSData (MZDebugSocketMessage)

- (NSString *)contentType {
    return @"data";
}
- (NSData *)NSDataValue {
    return self;
}

- (NSData *)readDataWithLength:(NSInteger)len offset:(NSInteger)offset {
    if (len + offset <= self.length) {
        return [self subdataWithRange:NSMakeRange(offset, len)];
    }
    return nil;
}

- (NSString *)readStringWithLength:(NSInteger)len offset:(NSInteger)offset {
    NSData *data = [self readDataWithLength:len offset:offset];
    if (data) {
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return nil;
}

- (id)readJsonWithLength:(NSInteger)len offset:(NSInteger)offset {
    NSData *data = [self readDataWithLength:len offset:offset];
    if (data) {
        return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    }
    return nil;
}

- (int)readInt32WithOffset:(NSInteger)offset {
    int32_t i = 0;
    if (offset + sizeof(int32_t) <= self.length) {
        [self getBytes:&i range:NSMakeRange(offset, sizeof(int32_t))];
    }
    return NSSwapBigIntToHost(i);
}

@end
