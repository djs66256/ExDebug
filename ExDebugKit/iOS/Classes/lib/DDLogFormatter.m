//
//  DDLogFormatter.m
//  Meixue
//
//  Created by hzduanjiashun on 2016/12/21.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "DDLogFormatter.h"


static inline NSString * DDLogFormatterLevelString(DDLogFlag flag) {
    NSDictionary *map = @{@(DDLogFlagError): @"❤️ERROR💥",
                          @(DDLogFlagDebug): @"💙DEBUG🐞",
                          @(DDLogFlagWarning): @"💛WARNING⚠️",
                          @(DDLogFlagInfo): @"💚INFOℹ️",
                          @(DDLogFlagVerbose): @"💜VERBOSE"
                          };
    return map[@(flag)] ?: @"UNKNOWN";
}

static inline NSString *DDLogFormatterTimeStamp(NSDate *date) {
    int len;
    char ts[24] = "";
    
    // Calculate timestamp.
    // The technique below is faster than using NSDateFormatter.
    if (date) {
        NSDateComponents *components = [[NSCalendar autoupdatingCurrentCalendar] components:0xff fromDate:date];
        
        NSTimeInterval epoch = [date timeIntervalSinceReferenceDate];
        int milliseconds = (int)((epoch - floor(epoch)) * 1000);
        
        len = snprintf(ts, 24, "%04ld-%02ld-%02ld %02ld:%02ld:%02ld:%03d", // yyyy-MM-dd HH:mm:ss:SSS
                       (long)components.year,
                       (long)components.month,
                       (long)components.day,
                       (long)components.hour,
                       (long)components.minute,
                       (long)components.second, milliseconds);
    }
    return [[NSString alloc] initWithUTF8String:ts];
}

@implementation DDSocketVerboseLogFormatter

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage {
    return [NSString stringWithFormat:@"%@ [BEAUTY] [%@] [thread:%@ %@] \n%@ line:%zd \n%@\n\n", DDLogFormatterTimeStamp(logMessage.timestamp), DDLogFormatterLevelString(logMessage.flag), logMessage.threadID, logMessage.threadName, logMessage.function, logMessage.line, logMessage.message];
}

@end

@implementation DDSocketLogFormatter

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage {
    return [NSString stringWithFormat:@"%@ [%@] %@", DDLogFormatterTimeStamp(logMessage.timestamp), DDLogFormatterLevelString(logMessage.flag), logMessage.message];
}

@end
