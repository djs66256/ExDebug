//
//  DDRunLoopDurationObserver.h
//  Meixue
//
//  Created by hzduanjiashun on 2017/1/13.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DDRunLoopDurationObserverProtocol;
@interface DDRunLoopDurationObserver : NSObject

+ (instancetype)sharedInstance;
@property (strong, readonly, nonatomic) NSSet *observers;

- (void)addObserver:(id<DDRunLoopDurationObserverProtocol>)observer;
- (void)removeObserver:(id<DDRunLoopDurationObserverProtocol>)observer;
- (void)removeAllObservers;

- (BOOL)isObserving;
- (void)beginObserver;
- (void)stopObserver;

@end

@protocol DDRunLoopDurationObserverProtocol <NSObject>

- (void)runloopWithDuration:(NSTimeInterval)duration;

@end
