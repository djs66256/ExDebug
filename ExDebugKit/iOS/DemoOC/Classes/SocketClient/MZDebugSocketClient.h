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
#import "MZDebugSocketMessage.h"

@protocol MZDebugSocketClientDelegate;
@interface MZDebugSocketClient : NSObject

@property (weak, nonatomic) id<MZDebugSocketClientDelegate> delegate;
@property (strong, atomic) NSString *host;
@property (assign, atomic) UInt16 port;
@property (assign, nonatomic) NSTimeInterval timeout;
@property (assign, readonly, nonatomic) BOOL connected;

//+ (instancetype)sharedInstance;

- (void)start;
- (void)restart;
- (void)stop;

- (void)sendMessage:(MZDebugSocketMessage *)message;

@end

@protocol MZDebugSocketClientDelegate <NSObject>

- (void)debugSocketClientDidConnectToServer:(MZDebugSocketClient *)client;
- (void)debugSocketClientDidDisconnectToServer:(MZDebugSocketClient *)client;
- (void)debugSocketClient:(MZDebugSocketClient *)client didReceiveMessage:(MZDebugSocketMessage *)message;

@end
