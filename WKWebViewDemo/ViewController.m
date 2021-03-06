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
#import "WkWebViewURLProtocol.h"

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
    [NSURLProtocol registerClass:[WkWebViewURLProtocol class]];
    
    Class cls = NSClassFromString(@"WKBrowsingContextController");
    SEL sel = NSSelectorFromString(@"registerSchemeForCustomProtocol:");
    if ([(id)cls respondsToSelector:sel]) {
        // 注册http(s) scheme, 把 http和https请求交给 NSURLProtocol处理
        [(id)cls performSelector:sel withObject:@"http"];
        [(id)cls performSelector:sel withObject:@"https"];
    }
    
    _configuration = [WKWebViewConfiguration new];
    [_configuration.userContentController addScriptMessageHandler:[[XLWeakScriptMessageDelegate alloc]initWithDelegate:self] name:@"showSendMsg"];
    _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) configuration:_configuration];
    _webView.UIDelegate = self;
    _webView.navigationDelegate = self;
    [self.view addSubview:_webView];
    NSMutableURLRequest *requesst = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://192.168.2.134:8018/Home/Page1"]];;
    [_webView  loadRequest:requesst];
    
    /* NSMutableURLRequest *requesst = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://192.168.2.134:8018/Home/Page1"]];
//    [requesst setHTTPMethod:@"POST"];
//    NSDictionary *dic = @{@"data1":@"data1",@"data2":@"data2"};
//    [requesst setHTTPBody:[NSJSONSerialization dataWithJSONObject:dic options:kNilOptions error:nil]];
    UIWebView *webView = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    webView.delegate = self;
    [webView loadRequest:requesst];
    [self.view addSubview:webView];*/
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    //拦截到js的调用参数
    NSString *bodyStr =   [[NSString  alloc] initWithData:webView.request.HTTPBody encoding:NSUTF8StringEncoding];
    NSLog(@"bodyStr = %@",bodyStr);
    
    _context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];  //获取js上下文
    //OC吊起JS函数
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

-(void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    //针对wkwebView的请求体被清空的问题 现在目前为止还没寻求到解决方案，待解决.在UIwebView中请求体中的信息在进行post请求的时候是不会被丢失的
    NSString *bodyStr =   [[NSString  alloc] initWithData:navigationAction.request.HTTPBody encoding:NSUTF8StringEncoding];
    NSLog(@"bodyStr = %@",bodyStr);
    
    NSMutableURLRequest *mutableRequest = [navigationAction.request mutableCopy];
    NSString *urlStr = mutableRequest.URL.absoluteString;
    NSLog(@"requestURL = %@",urlStr);
    NSDictionary *requestHeaders = navigationAction.request.allHTTPHeaderFields;
    /*if (requestHeaders[@"Chan111"] && requestHeaders[@"Chan222"]) {
        decisionHandler(WKNavigationActionPolicyAllow);
    } else {
        [mutableRequest addValue:@"Chan111" forHTTPHeaderField:@"Chan111"];
        [mutableRequest addValue:@"Chan222" forHTTPHeaderField:@"Chan222"];
        [webView loadRequest:mutableRequest];
        decisionHandler(WKNavigationActionPolicyAllow);
    }*/
    if ([navigationAction.request.HTTPMethod isEqualToString:@"GET"]) {
        decisionHandler(WKNavigationActionPolicyAllow);
    } else {
        //POST
        /*NSString*url = navigationAction.request.URL.absoluteString;
        NSString *newUrl =  [url stringByReplacingOccurrencesOfString:@"http" withString:@"POST"];
        NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:newUrl]];
        postRequest.HTTPBody = [@"Chan" dataUsingEncoding:NSUTF8StringEncoding];
        [webView loadRequest:postRequest];*/
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    id body  = message.body;
    //获取body信息window.webkit.messageHandlers.showSendMsg.postMessage([$("#Username1").val(), $("#Password1").val()]);
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
    [NSURLProtocol unregisterClass:[WkWebViewURLProtocol class]];
}
@end
