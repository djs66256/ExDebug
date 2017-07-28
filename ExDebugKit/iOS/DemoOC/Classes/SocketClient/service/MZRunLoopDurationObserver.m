//
//  MZRunLoopDurationObserver.m
//  Meixue
//
//  Created by hzduanjiashun on 2017/1/13.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import "MZRunLoopDurationObserver.h"

@implementation MZRunLoopDurationObserver {
    NSMutableSet *_observers;
    CFRunLoopObserverRef observer;
    NSLock *_lock;
    
    struct {
        CFTimeInterval time;
        CFRunLoopActivity activity;
    } beginTime;
}
@synthesize observers = _observers;

static void MZRunLoopDurationObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    MZRunLoopDurationObserver *self = [MZRunLoopDurationObserver sharedInstance];
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
    static MZRunLoopDurationObserver *ob = nil;
    dispatch_once(&onceToken, ^{
        ob = [MZRunLoopDurationObserver new];
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
    observer = CFRunLoopObserverCreate(NULL, kCFRunLoopAfterWaiting|kCFRunLoopBeforeWaiting, YES, 0, MZRunLoopDurationObserverCallBack, NULL);
    CFRunLoopRef mainRunloop = CFRunLoopGetMain();
    CFRunLoopAddObserver(mainRunloop, observer, kCFRunLoopCommonModes);
}

- (void)stopObserver {
    if (observer) {
        CFRunLoopRemoveObserver(CFRunLoopGetMain(), observer, kCFRunLoopCommonModes);
        observer = nil;
    }
}

- (void)addObserver:(id<MZRunLoopDurationObserverProtocol>)ob {
    [_lock lock];
    [_observers addObject:ob];
    [_lock unlock];
    [self beginObserver];
}

- (void)removeObserver:(id<MZRunLoopDurationObserverProtocol>)ob {
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
    for (id<MZRunLoopDurationObserverProtocol> ob in _observers) {
        [ob runloopWithDuration:duration];
    }
    [_lock unlock];
}

@end
