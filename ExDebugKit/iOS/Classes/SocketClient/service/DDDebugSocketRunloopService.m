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

#import "DDDebugSocketRunloopService.h"
#import "DDRunLoopDurationObserver.h"

@interface DDDebugSocketRunloopService () <DDRunLoopDurationObserverProtocol>
@property (assign, nonatomic) NSTimeInterval lastTime;
@property (assign, nonatomic) NSTimeInterval snapshotDuration;

@end

@implementation DDDebugSocketRunloopService

- (instancetype)init
{
    self = [super init];
    if (self) {
        _snapshotDuration = 1;
    }
    return self;
}

- (void)didConnectToServer {
    [[DDRunLoopDurationObserver sharedInstance] addObserver:self];
}

- (void)didDisconnectToServer {
    [[DDRunLoopDurationObserver sharedInstance] removeObserver:self];
}

- (NSString *)runloopDir {
    NSString *rl = [self.rootDirectory stringByAppendingPathComponent:@"runloop"];
    [self checkDirectory:rl];
    return rl;
}

- (void)runloopWithDuration:(NSTimeInterval)duration {
    if (duration > 1./60) {
        if (duration > 1 && (CFAbsoluteTimeGetCurrent() - _lastTime) > 5) {
            _lastTime = CFAbsoluteTimeGetCurrent();
            CGRect rect = [UIScreen mainScreen].bounds;
            UIGraphicsBeginImageContext(rect.size);
            [[UIApplication sharedApplication].keyWindow drawViewHierarchyInRect:rect afterScreenUpdates:YES];
            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            NSString *imageName = [NSString stringWithFormat:@"%ld.png", (NSInteger)CFAbsoluteTimeGetCurrent()];
            NSString *imagePath = [self.runloopDir stringByAppendingPathComponent:imageName];
            [UIImagePNGRepresentation(image) writeToFile:imagePath atomically:YES];
            
            DDDebugSocketMessage *msg = [DDDebugSocketMessage registerWithPath:@"runloop"];
            msg.body = @{@"duration": @(duration),
                         @"time": @(CFAbsoluteTimeGetCurrent()),
                         @"image": [imagePath stringByReplacingOccurrencesOfString:NSHomeDirectory() withString:@""]
                         };
            [self sendMessage:msg];
        }
        else {
            DDDebugSocketMessage *msg = [DDDebugSocketMessage registerWithPath:@"runloop"];
            msg.body = @{@"duration": @(duration),
                         @"time": @(CFAbsoluteTimeGetCurrent())
                         };
            [self sendMessage:msg];
        }
    }
}

@end
