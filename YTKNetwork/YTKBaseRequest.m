//
//  YTKBaseRequest.m
//
//  Copyright (c) 2012-2014 YTKNetwork https://github.com/yuantiku
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "YTKBaseRequest.h"
#import "YTKNetworkAgent.h"
#import "YTKNetworkPrivate.h"

static NSString *kAFNetworkingLockName = @"YCFAFNetworkingLockName";

@interface YTKBaseRequest()

@property (readwrite, nonatomic, strong) NSRecursiveLock *lock;

@end

@implementation YTKBaseRequest

- (instancetype)init
{
    if (self = [super init])
    {
        _lock = [[NSRecursiveLock alloc] init];
        _lock.name = kAFNetworkingLockName;
    }
    
    return self;
}

/// for subclasses to overwrite
- (void)requestCompleteFilter {
}

- (void)requestFailedFilter {
}

- (NSString *)requestUrl {
    return @"";
}

- (NSString *)cdnUrl {
    return @"";
}

- (NSString *)baseUrl {
    return @"";
}

- (NSTimeInterval)requestTimeoutInterval {
    return 60;
}

- (id)requestArgument {
    return nil;
}

- (id)cacheFileNameFilterForRequestArgument:(id)argument {
    return argument;
}

- (YTKRequestMethod)requestMethod {
    return YTKRequestMethodGet;
}

- (YTKRequestSerializerType)requestSerializerType {
    return YTKRequestSerializerTypeHTTP;
}

- (Class)requestSerializerClass {
   return nil;
}

- (Class)responseSerializerClass {
    return nil;
}

- (NSArray *)requestAuthorizationHeaderFieldArray {
    return nil;
}

- (NSDictionary *)requestHeaderFieldValueDictionary {
    return nil;
}

- (NSURLRequest *)buildCustomUrlRequest {
    return nil;
}

- (BOOL)useCDN {
    return NO;
}

- (id)jsonValidator {
    return nil;
}

- (BOOL)statusCodeValidator {
    NSInteger statusCode = [self responseStatusCode];
    if (statusCode >= 200 && statusCode <=299) {
        return YES;
    } else {
        return NO;
    }
}

- (AFConstructingBlock)constructingBodyBlock {
    return nil;
}

- (NSString *)resumableDownloadPath {
    return nil;
}

- (void (^)(NSProgress *downloadProgress))resumableDownloadProgressBlock {
    return nil;
}

/// append self to request queue
- (void)start {
    [self toggleAccessoriesWillStartCallBack];
    [[YTKNetworkAgent sharedInstance] addRequest:self];
}

/// remove self from request queue
- (void)stop {
    [self toggleAccessoriesWillStopCallBack];
    self.delegate = nil;
    [[YTKNetworkAgent sharedInstance] cancelRequest:self];
    [self toggleAccessoriesDidStopCallBack];
}

- (BOOL)isCancelled
{
#warning 自测
    return self.requestOperation.state == NSURLSessionTaskStateCanceling;
}

- (BOOL)isExecuting
{
#warning 自测
    return self.requestOperation.state == NSURLSessionTaskStateRunning;
}

- (void)startWithCompletionBlockWithSuccess:(YTKRequestCompletionBlock)success
                                    failure:(YTKRequestCompletionBlock)failure
{
    [self setCompletionBlockWithSuccess:success failure:failure];
    [self start];
}

- (void)setCompletionBlockWithSuccess:(YTKRequestCompletionBlock)success
                              failure:(YTKRequestCompletionBlock)failure
{
    self.successCompletionBlock = success;
    self.failureCompletionBlock = failure;
}

- (void)clearCompletionBlock
{
    // nil out to break the retain cycle.
    self.successCompletionBlock = nil;
    self.failureCompletionBlock = nil;
}

- (NSInteger)responseStatusCode
{
    if ([self.requestOperation.response isKindOfClass:[NSHTTPURLResponse class]])
    {
        NSHTTPURLResponse *httpURLResponse  = (NSHTTPURLResponse *)self.requestOperation.response;
        return httpURLResponse.statusCode;
    }
    
    return 0;
}

- (NSDictionary *)responseHeaders
{
    if ([self.requestOperation.response isKindOfClass:[NSHTTPURLResponse class]])
    {
        NSHTTPURLResponse *httpURLResponse  = (NSHTTPURLResponse *)self.requestOperation.response;
        return httpURLResponse.allHeaderFields;
    }
    
    return nil;
}

- (NSError *)requestOperationError
{
    return self.requestOperation.error;
}

#pragma mark - Request Accessories

- (void)addAccessory:(id<YTKRequestAccessory>)accessory {
    if (!self.requestAccessories) {
        self.requestAccessories = [NSMutableArray array];
    }
    [self.requestAccessories addObject:accessory];
}





@end
