//
//  URLProtocol.m
//  WKWebViewDemo
//
//  Created by Macx on 2018/3/5.
//  Copyright © 2018年 胡斌. All rights reserved.
//

#import "URLProtocol.h"
#import <UIKit/UIKit.h>

@implementation URLProtocol

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    
    //在这里可以自定义追加一些请求头信息
    [mutableRequest setValue:@"Chan" forHTTPHeaderField:@"token"];
    
    return mutableRequest;
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    //只处理http和https请求
    NSString *schme = request.URL.scheme;
    if ([schme caseInsensitiveCompare:@"http"] == NSOrderedSame || [schme caseInsensitiveCompare:@"https"] == NSOrderedSame) {
        //防止无线递归循环
        if ([NSURLProtocol propertyForKey:NSStringFromClass([self class]) inRequest:request]) {
            //处理过了
            return NO;
        } else {
            return YES;
        }
    }
    return YES;
}

#pragma mark  -- 开始加载
- (void)startLoading {
    _recieveData = [NSMutableData new];
    NSMutableURLRequest *request = [[self request] mutableCopy];
    [NSURLProtocol setProperty:@(YES) forKey:NSStringFromClass([self class]) inRequest:request];
    if ([UIDevice currentDevice].systemVersion.floatValue >=7.0) {
        NSURLSessionConfiguration *configure = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:configure delegate:self delegateQueue:[NSOperationQueue new]];
        _task = [_session dataTaskWithRequest:request];
        [_task resume];
    } else {
        _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    }
}

- (void)stopLoading {
    if (_task) {
        [_task cancel];
        _task = nil;
    }
    if (_session) {
        [_session invalidateAndCancel];
        _session = nil;
    }
    if (_task) {
        [_task cancel];
        _task = nil;
    }
}

#pragma mark  -- NSURLConnectionDataDelegate

////接收到数据（可能调用多次）
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_recieveData appendData:data];
    [self.client  URLProtocol:self didLoadData:data];
}

///接收到响应
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.client  URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
}

///加载完成
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.client URLProtocolDidFinishLoading:self];
}

///加载失败
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.client URLProtocol:self didFailWithError:error];
}

///重定向
-(NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response {
    if (response !=nil) {
        [self.client  URLProtocol:self wasRedirectedToRequest:request redirectResponse:response];
    }
    return  request;
}

#pragma mark  -- NSURLSessionDataDelegate

///接收到数据（可能调用多次）
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [_recieveData appendData:data];
    
    id json = [NSJSONSerialization JSONObjectWithData:_recieveData
                                              options:kNilOptions
                                                error:nil];
    NSLog(@"json = %@ -- jsonStr = %@",json,[[NSString alloc] initWithData:_recieveData encoding:NSUTF8StringEncoding]);
    [self.client  URLProtocol:self didLoadData:data];
}

///接收到响应
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    [self.client  URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
    //允许接收响应
    completionHandler(NSURLSessionResponseAllow);
}

///加载失败
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (!error) {
        [self.client  URLProtocolDidFinishLoading:self];
    } else {
        [self.client  URLProtocol:self didFailWithError:error];
    }
}



@end
