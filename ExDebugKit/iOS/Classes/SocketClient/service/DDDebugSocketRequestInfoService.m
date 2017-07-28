//
//  DDDebugSocketRequestService.m
//  Pods
//
//  Created by hzduanjiashun on 2017/3/6.
//
//

#import "DDDebugSocketRequestInfoService.h"
#import "DDLogURLProtocol.h"

@implementation DDDebugSocketRequestInfoService

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithProxyService:(id<DDDebugSocketServiceProtocol>)service
{
    self = [super initWithProxyService:service];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logURLProtocolNotification:) name:DDLogURLProtocolNotification object:nil];
    }
    return self;
}

//- (void)didConnectToServer {
//    [NSURLProtocol registerClass:[DDLogURLProtocol class]];
//}
//
//- (void)didDisconnectToServer {
//    [NSURLProtocol unregisterClass:[DDLogURLProtocol class]];
//}

- (void)logURLProtocolNotification:(NSNotification *)noti {
    NSMutableDictionary *info = noti.userInfo.mutableCopy;
    NSDate *startTime = info[@"startTime"];
    info[@"startTime"] = @(startTime.timeIntervalSince1970);
    NSDate *endTime = info[@"endTime"];
    info[@"endTime"] = @(endTime.timeIntervalSince1970);
    
    DDDebugSocketMessage *message = [DDDebugSocketMessage registerWithPath:@"request"];
    message.body = info;
    [self sendMessage:message];
}

@end
