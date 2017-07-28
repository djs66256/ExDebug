//
//  MZRunLoopDurationObserver.h
//  Meixue
//
//  Created by hzduanjiashun on 2017/1/13.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MZRunLoopDurationObserverProtocol;
@interface MZRunLoopDurationObserver : NSObject

+ (instancetype)sharedInstance;
@property (strong, readonly, nonatomic) NSSet *observers;

- (void)addObserver:(id<MZRunLoopDurationObserverProtocol>)observer;
- (void)removeObserver:(id<MZRunLoopDurationObserverProtocol>)observer;
- (void)removeAllObservers;

- (BOOL)isObserving;
- (void)beginObserver;
- (void)stopObserver;

@end

@protocol MZRunLoopDurationObserverProtocol <NSObject>

- (void)runloopWithDuration:(NSTimeInterval)duration;

@end
