//
//  CADisplayLink+Block.m
//  Meixue
//
//  Created by hzduanjiashun on 2016/11/16.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import <objc/runtime.h>
#import "CADisplayLink+DDBlock.h"

static NSString * const DDDisplayLinkBlockKey = @"DDDisplayLinkBlockKey";
static void *DDDisplayLinkUserInfoKey = &DDDisplayLinkUserInfoKey;

@implementation CADisplayLink (Block)

- (void)setDd_userInfo:(NSDictionary *)dd_userInfo {
    objc_setAssociatedObject(self, &DDDisplayLinkUserInfoKey, dd_userInfo, OBJC_ASSOCIATION_RETAIN);
}

- (NSDictionary *)dd_userInfo {
    id obj = objc_getAssociatedObject(self, &DDDisplayLinkUserInfoKey);
    return obj;
}

+ (CADisplayLink *)dd_displayLinkWithBlock:(void (^)(CADisplayLink *))block {
    CADisplayLink *displayLink = [self displayLinkWithTarget:self selector:@selector(dd_displayLinkInvoke:)];
    displayLink.dd_userInfo = @{DDDisplayLinkBlockKey: [block copy]};
    return displayLink;
}

+ (void)dd_displayLinkInvoke:(CADisplayLink *)displayLink {
    void (^block)(CADisplayLink *) = displayLink.dd_userInfo[DDDisplayLinkBlockKey];
    if (block) {
        block(displayLink);
    }
}

@end
