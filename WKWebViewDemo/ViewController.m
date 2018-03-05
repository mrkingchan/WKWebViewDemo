//
//  ViewController.m
//  WKWebViewDemo
//
//  Created by Macx on 2018/3/1.
//  Copyright © 2018年 Chan. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import <WebKit/WKScriptMessageHandler.h>
#import "XLWeakScriptMessageDelegate.h"
#import <JavaScriptCore/JavaScriptCore.h>

@interface ViewController () <WKUIDelegate,WKNavigationDelegate,WKScriptMessageHandler,UIWebViewDelegate> {
    WKWebView *_webView;
    WKWebViewConfiguration *_configuration;
    JSContext *_context;
}

@end

@implementation ViewController

#pragma mark  -- lifeCircle
- (void)viewDidLoad {
    [super viewDidLoad];
    //webView初始化
    _configuration = [WKWebViewConfiguration new];
    //注册信息
    [_configuration.userContentController addScriptMessageHandler:[[XLWeakScriptMessageDelegate alloc]initWithDelegate:self] name:@"showSendMsg"];
    //初始化UI
    _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) configuration:_configuration];
    _webView.UIDelegate = self;
    _webView.navigationDelegate = self;
//    [self.view addSubview:_webView];
    //加载网页
    NSMutableURLRequest *requesst = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://192.168.2.134:8018/Home/Page1"]];
    //添加请求头信息
    [_webView  loadRequest:requesst];
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    webView.delegate = self;
    [webView loadRequest:requesst];
    [self.view addSubview:webView];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    //拦截到js的调用参数
    _context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];  //获取js上下文
    //iOS吊起JS函数
    [_context evaluateScript:@"alert('I AM A SEXY GUY!')"];
    //拦截js的调用函数
    _context[@"function1"] = ^ (NSString *param1,NSString *param2) {
        NSArray *argus = [JSContext currentArguments];
        for (id argu in argus) {
            NSLog(@"argu = %@",argu);
        }
    };
    [_context  evaluateScript:@"function1('1111','2222')"];
    

    _context[@"function2"] = ^ (NSString *param1,NSString *param2) {
        NSArray *paramArray = [JSContext currentArguments];
        for (id param in paramArray) {
            NSLog(@"param = %@",param);
        }
    };
    [_context evaluateScript:@"function2('Chan1111','Chan2222')"];
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    NSLog(@"message = %@",message);
    completionHandler();
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:message message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertVC addAction:action];
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *urlStr = request.URL.absoluteString;
    if ([urlStr rangeOfString:@"ios:gotoLogin"].length) {
        //跳转登录
    }
    //提交表单
    if (navigationType == UIWebViewNavigationTypeFormSubmitted) {
        return YES;
    }
    return YES;
}

-(void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSMutableURLRequest *mutableRequest = [navigationAction.request mutableCopy];
    NSString *urlStr = mutableRequest.URL.absoluteString;
    NSLog(@"requestURL = %@",urlStr);
    NSDictionary *requestHeaders = navigationAction.request.allHTTPHeaderFields;
    if (requestHeaders[@"Chan111"] && requestHeaders[@"Chan222"]) {
        decisionHandler(WKNavigationActionPolicyAllow);
    } else {
        [mutableRequest addValue:@"Chan111" forHTTPHeaderField:@"Chan111"];
        [mutableRequest addValue:@"Chan222" forHTTPHeaderField:@"Chan222"];
        [webView loadRequest:mutableRequest];
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    id body  = message.body;
    //获取body信息
    if ([message.name rangeOfString:@"showSendMsg"].length) {
        UIAlertAction *aciton = [UIAlertAction actionWithTitle:@"ok" style:0 handler:^(UIAlertAction * _Nonnull action) {
        }];
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:[self jsonToStrWithjson:body] message:[self jsonToStrWithjson:body] preferredStyle:UIAlertControllerStyleAlert];
        [alertVC addAction:aciton];
        [self presentViewController:alertVC animated:YES completion:nil];
        
        NSString *methodStr = @"function1('Chan1','Chan2')";
        [_webView evaluateJavaScript:methodStr completionHandler:^(id _Nullable response, NSError * _Nullable error) {
            NSLog(@"response = %@",response);
        }];
    }
}

#pragma mark  -- private Method
- (NSString *)jsonToStrWithjson:(id)json {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:kNilOptions error:nil];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}


- (id)jsonAndStrRotateWithValue:(id)value {
    id returnValue = nil;
    if ([value isKindOfClass:[NSString class]]) {
        NSData *jsonData = [((NSString *) value) dataUsingEncoding:NSUTF8StringEncoding];
        returnValue = [NSJSONSerialization JSONObjectWithData:jsonData
                                                      options:kNilOptions error:nil];
    } else if ([value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSArray class]]) {
     NSData *jsonData = [NSJSONSerialization dataWithJSONObject:value
                                                        options:kNilOptions
                                                          error:nil];
        returnValue =  [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return returnValue == nil ?@{}:returnValue;
}

- (void)dealloc {
    [_configuration.userContentController removeScriptMessageHandlerForName:@"showSendMsg"];
}
@end
