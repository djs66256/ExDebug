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

#import "DDDebugSocketService.h"

@implementation DDDebugSocketService {
    __weak id<DDDebugSocketServiceProtocol> _proxyService;
}

- (instancetype)initWithProxyService:(id<DDDebugSocketServiceProtocol>)service
{
    self = [super init];
    if (self) {
        _proxyService = service;
    }
    return self;
}

- (void)didConnectToServer { }
- (void)didDisconnectToServer { }

- (BOOL)validateMessage:(DDDebugSocketMessage *)message {
    return YES;
}

- (void)sendMessage:(DDDebugSocketMessage *)message {
    [_proxyService sendMessage:message];
}

- (void)receiveMessage:(DDDebugSocketMessage *)message {
    
}

- (void)on:(NSString *)expr dispatch:(void (^)(DDDebugSocketMessage *, NSDictionary *))block {
    
}

- (NSString *)rootDirectory {
    NSString *root = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"debugSocket"];
    [self checkDirectory:root];
    return root;
}

- (void)checkDirectory:(NSString *)dir {
    if (![[NSFileManager defaultManager] fileExistsAtPath:dir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

@end

@implementation DDDebugSocketRequestService

- (void)requestWithPath:(NSString *)path {
    [self sendMessage:[DDDebugSocketMessage requestWithPath:path]];
}

@end

@implementation DDDebugSocketRegisterService

- (void)registerWithPath:(NSString *)path {
    [self sendMessage:[DDDebugSocketMessage registerWithPath:path]];
}

@end
