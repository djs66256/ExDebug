//
//  DDLogURLProtocol.m
//  Pods
//
//  Created by hzduanjiashun on 2017/3/6.
//
//

#import "DDLogURLProtocol.h"

NSString * const DDLogURLProtocolNotification = @"DDLogURLProtocolNotification";

@interface DDLogURLProtocol () <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (strong, nonatomic) NSURLConnection *connection;
@property (assign, nonatomic) NSInteger uploadByteCount;
@property (assign, nonatomic) NSInteger downloadByteCount;
@property (strong, nonatomic) NSDate *startTime;
@property (strong, nonatomic) NSDate *endTime;

@end

@implementation DDLogURLProtocol
static NSString * const onceKey = @"DDLogURLProtocol";

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    if ([self propertyForKey:onceKey inRequest:request]) {
        return NO;
    }
    else {
        return YES;
    }
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    NSMutableURLRequest *newReq = request.mutableCopy;
    [self setProperty:@(YES) forKey:onceKey inRequest:newReq];

    return newReq;
}

- (void)startLoading {
    self.startTime = [NSDate date];
    self.connection = [[NSURLConnection alloc] initWithRequest:self.request
                                                      delegate:self
                                              startImmediately:YES];
}

- (void)stopLoading {
    [self.connection cancel];
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    self.uploadByteCount += bytesWritten;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.client URLProtocol:self didFailWithError:error];
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection {
    return YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [self.client URLProtocol:self didReceiveAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [self.client URLProtocol:self didCancelAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    self.downloadByteCount += data.length;
    [self.client URLProtocol:self didLoadData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.client URLProtocolDidFinishLoading:self];
    self.endTime = [NSDate date];
    NSDictionary *userInfo = @{ @"method": self.request.HTTPMethod ?: @"",
                                @"url": self.request.URL.absoluteString ?: @"",
                                @"startTime": self.startTime,
                                @"endTime": self.endTime,
                                @"uploadByteCount": @(self.uploadByteCount),
                                @"downloadByteCount": @(self.downloadByteCount) };
    [[NSNotificationCenter defaultCenter] postNotificationName:DDLogURLProtocolNotification object:nil userInfo:userInfo];
}

@end
