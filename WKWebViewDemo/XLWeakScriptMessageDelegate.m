//
//  XLWeakScriptMessageDelegate.m
//  WKWebViewDemo
//
//  Created by Macx on 2018/3/2.
//  Copyright © 2018年 Chan. All rights reserved.
//

#import "XLWeakScriptMessageDelegate.h"

@implementation XLWeakScriptMessageDelegate

- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate{
    self = [super init];
    if (self) {
        _scriptDelegate = scriptDelegate;
    }
    return self;
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    [self.scriptDelegate userContentController:userContentController didReceiveScriptMessage:message];
}

@end
