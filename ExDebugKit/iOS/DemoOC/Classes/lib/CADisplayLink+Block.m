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

#import <objc/runtime.h>
#import "CADisplayLink+Block.h"

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
