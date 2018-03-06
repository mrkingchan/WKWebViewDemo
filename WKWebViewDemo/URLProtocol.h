//
//  URLProtocol.h
//  WKWebViewDemo
//
//  Created by Macx on 2018/3/5.
//  Copyright © 2018年 胡斌. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface URLProtocol : NSURLProtocol<NSURLConnectionDataDelegate,NSURLSessionDataDelegate>

@property(nonatomic,strong)NSURLSessionDataTask *task;

@property(nonatomic,strong)NSURLConnection *connection;

@property(nonatomic,strong)NSURLSession *session;

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request;


@end
