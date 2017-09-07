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

#import "DDDebugSocketDeviceInfoService.h"
#import <UIKit/UIKit.h>
#import <SAMKeychain/SAMKeychain.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>


#define UNIFIED_DEVICD_ID_SERVICE @"com.moredebug.device.uuid"

@implementation DDDebugSocketDeviceInfoService

- (NSUUID *)deviceUUID
{
    static NSUUID * __deviceUUID = nil;
    if (!__deviceUUID) {
        NSData *data = [SAMKeychain passwordDataForService:UNIFIED_DEVICD_ID_SERVICE
                                                   account:@"CURRENT_DEVICE"];
        if (data) {
            __deviceUUID = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        }
        if (!__deviceUUID) {
            __deviceUUID = [NSUUID UUID];
            data = [NSKeyedArchiver archivedDataWithRootObject:__deviceUUID];
            NSError *error = nil;
            [SAMKeychain setPasswordData:data
                              forService:UNIFIED_DEVICD_ID_SERVICE
                                 account:@"CURRENT_DEVICE"
                                   error:&error];
            if (error) {
                NSLog(@"UUID saving: %@", error);
            }
        }
    }
    return __deviceUUID;
}

- (NSString *)deviceID
{
    return self.deviceUUID.UUIDString;
}

+ (NSString *)appVersion __attribute__((const))
{
    return [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
}

+ (NSString *)buildNumber __attribute__((const))
{
    return [NSBundle mainBundle].infoDictionary[@"CFBundleVersion"];
}

+ (NSString *)displayName __attribute__((const))
{
    return NSBundle.mainBundle.infoDictionary[@"CFBundleDisplayName"];
}

+ (NSString *)distributionChannel __attribute__((const))
{
    return NSBundle.mainBundle.infoDictionary[@"AppChannel"];
}

+ (NSString *)protocolVersion __attribute__((const))
{
    return NSBundle.mainBundle.infoDictionary[@"MZProtocolVersion"];
}

+ (NSString *)resolutionString __attribute__((const))
{
    return [NSString stringWithFormat:@"%dx%d", (int)[UIScreen mainScreen].nativeBounds.size.width, (int)[UIScreen mainScreen].nativeBounds.size.height];
}

+ (NSString *)CTCarrier __attribute__((const))
{
    CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netinfo subscriberCellularProvider];
    return carrier.carrierName ?: @"Unknown";
}

- (NSDictionary *)deviceInfo {
    NSDictionary *dict = @{@"platform":@"phone",
                           @"os":@"iOS",
                           @"osVersion": [[UIDevice currentDevice] systemVersion],
                           @"deviceModel": [[UIDevice currentDevice] model],
                           @"deviceId": self.deviceID ?: @"",
                           @"appVersion": DDDebugSocketDeviceInfoService.appVersion,
                           @"buildNumber": DDDebugSocketDeviceInfoService.buildNumber,
                           @"protocolVersion":DDDebugSocketDeviceInfoService.protocolVersion ?: [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"],
                           @"carrier":DDDebugSocketDeviceInfoService.CTCarrier,
//                           @"isJail":@(MZApplication.isJ_a_ilB_reak),
                           @"resolution": DDDebugSocketDeviceInfoService.resolutionString
                           };
    return dict;
}

- (void)receiveMessage:(DDDebugSocketMessage *)message {
    if ([message.path isEqualToString:@"deviceInfo"]) {
        DDDebugSocketMessage *reply = message.makeReplyMessage;
        reply.body = self.deviceInfo;
        [self sendMessage:reply];
    }
}

@end
