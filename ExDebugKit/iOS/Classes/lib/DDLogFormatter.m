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
