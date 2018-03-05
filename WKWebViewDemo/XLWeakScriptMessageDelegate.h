//
//  XLWeakScriptMessageDelegate.h
//  WKWebViewDemo
//
//  Created by Macx on 2018/3/2.
//  Copyright © 2018年 Chan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WKScriptMessageHandler.h>

@interface XLWeakScriptMessageDelegate : NSObject<WKScriptMessageHandler>

@property (nonatomic,weak)id<WKScriptMessageHandler> scriptDelegate;

- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate;


@end
