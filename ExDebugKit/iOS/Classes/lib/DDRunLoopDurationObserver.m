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

#import "DDRunLoopDurationObserver.h"

@implementation DDRunLoopDurationObserver {
    NSMutableSet *_observers;
    CFRunLoopObserverRef observer;
    NSLock *_lock;
    
    struct {
        CFTimeInterval time;
        CFRunLoopActivity activity;
    } beginTime;
}
@synthesize observers = _observers;

static void DDRunLoopDurationObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    DDRunLoopDurationObserver *self = [DDRunLoopDurationObserver sharedInstance];
    if (activity == kCFRunLoopAfterWaiting) {
        self->beginTime.time = CFAbsoluteTimeGetCurrent();
        self->beginTime.activity = kCFRunLoopAfterWaiting;
    }
    else if (activity == kCFRunLoopBeforeWaiting) {
        if (self->beginTime.activity == kCFRunLoopAfterWaiting) {
            NSTimeInterval duration = CFAbsoluteTimeGetCurrent() - self->beginTime.time;
            [self notifyWithDuration:duration];
            self->beginTime.activity = 0;
        }
    }
}

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static DDRunLoopDurationObserver *ob = nil;
    dispatch_once(&onceToken, ^{
        ob = [DDRunLoopDurationObserver new];
    });
    return ob;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _observers = [[NSMutableSet alloc] init];
        _lock = [[NSLock alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [self stopObserver];
}

- (BOOL)isObserving {
    return observer != nil;
}

- (void)beginObserver {
    if (observer) {
        [self stopObserver];
    }
    observer = CFRunLoopObserverCreate(NULL, kCFRunLoopAfterWaiting|kCFRunLoopBeforeWaiting, YES, 0, DDRunLoopDurationObserverCallBack, NULL);
    CFRunLoopRef mainRunloop = CFRunLoopGetMain();
    CFRunLoopAddObserver(mainRunloop, observer, kCFRunLoopCommonModes);
}

- (void)stopObserver {
    if (observer) {
        CFRunLoopRemoveObserver(CFRunLoopGetMain(), observer, kCFRunLoopCommonModes);
        observer = nil;
    }
}

- (void)addObserver:(id<DDRunLoopDurationObserverProtocol>)ob {
    [_lock lock];
    [_observers addObject:ob];
    [_lock unlock];
    [self beginObserver];
}

- (void)removeObserver:(id<DDRunLoopDurationObserverProtocol>)ob {
    if (ob) {
        [_lock lock];
        [_observers removeObject:ob];
        [_lock unlock];
        if (_observers.count == 0) {
            [self stopObserver];
        }
    }
}

- (void)removeAllObservers {
    [_lock lock];
    [_observers removeAllObjects];
    [_lock unlock];
    [self stopObserver];
}

- (void)notifyWithDuration:(NSTimeInterval)duration {
    [_lock lock];
    for (id<DDRunLoopDurationObserverProtocol> ob in _observers) {
        [ob runloopWithDuration:duration];
    }
    [_lock unlock];
}

@end
