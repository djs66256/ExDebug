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

#import "MZRunloopService.h"
#import "MZRunLoopDurationObserver.h"

@interface MZRunloopService () <MZRunLoopDurationObserverProtocol>

@end

@implementation MZRunloopService

- (void)didConnectToServer {
    [[MZRunLoopDurationObserver sharedInstance] addObserver:self];
}

- (void)didDisconnectToServer {
    [[MZRunLoopDurationObserver sharedInstance] removeObserver:self];
}

- (void)runloopWithDuration:(NSTimeInterval)duration {
    if (duration > 1./60) {
        MZDebugSocketMessage *msg = [MZDebugSocketMessage registerWithPath:@"runloop"];
        msg.body = @{@"duration": @(duration),
                     @"time": @(CFAbsoluteTimeGetCurrent())
                     };
        [self sendMessage:msg];
    }
}

@end
