//
//  NSTimer+DDBlock.m
//  Pods
//
//  Created by hzduanjiashun on 2017/3/24.
//
//

#import "NSTimer+DDBlock.h"

@implementation NSTimer (DDBlock)

+ (id)dd_scheduledTimerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(void (^)(NSTimer *timer))block repeats:(BOOL)inRepeats
{
    NSParameterAssert(block != nil);
    return [self scheduledTimerWithTimeInterval:inTimeInterval target:self selector:@selector(dd_executeBlockFromTimer:) userInfo:[block copy] repeats:inRepeats];
}

+ (id)dd_timerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(void (^)(NSTimer *timer))block repeats:(BOOL)inRepeats
{
    NSParameterAssert(block != nil);
    return [self timerWithTimeInterval:inTimeInterval target:self selector:@selector(dd_executeBlockFromTimer:) userInfo:[block copy] repeats:inRepeats];
}

+ (void)dd_executeBlockFromTimer:(NSTimer *)aTimer {
    void (^block)(NSTimer *) = [aTimer userInfo];
    if (block) block(aTimer);
}

@end
