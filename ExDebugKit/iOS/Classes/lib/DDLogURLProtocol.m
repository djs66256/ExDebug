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
