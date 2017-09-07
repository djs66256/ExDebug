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

#import <Foundation/Foundation.h>
#import "DDDebugSocketMessage.h"
#import "DDDebugSocketServiceProtocol.h"

@interface DDDebugSocketService : NSObject<DDDebugSocketServiceProtocol>

- (instancetype)initWithProxyService:(id<DDDebugSocketServiceProtocol>)service;

- (void)didConnectToServer;
- (void)didDisconnectToServer;

- (BOOL)validateMessage:(DDDebugSocketMessage *)message;

- (void)sendMessage:(DDDebugSocketMessage *)message;
- (void)receiveMessage:(DDDebugSocketMessage *)message;

- (void)on:(NSString *)expr dispatch:(void(^)(DDDebugSocketMessage *msg, NSDictionary *params))block;

- (NSString *)rootDirectory;
- (void)checkDirectory:(NSString *)dir;

@end

@interface DDDebugSocketRequestService : DDDebugSocketService

- (void)requestWithPath:(NSString *)path;

@end

@interface DDDebugSocketRegisterService : DDDebugSocketService

- (void)registerWithPath:(NSString *)path;

@end