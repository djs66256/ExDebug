//
//  CADisplayLink+Block.h
//  Meixue
//
//  Created by hzduanjiashun on 2016/11/16.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CADisplayLink(Block)

@property (strong, nonatomic) NSDictionary *dd_userInfo;

+ (CADisplayLink *)dd_displayLinkWithBlock:(void(^)(CADisplayLink *))block;

@end
