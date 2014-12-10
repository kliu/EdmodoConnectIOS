//
//  EMConnectLoginViewController.m
//  EdmodoTestMobile
//
//  Created by Luca Prasso on 12/16/13.
//  Copyright (c) 2013 Luca Prasso Edmodo. All rights reserved.
//

#import <CoreFoundation/CFURL.h>

#import "EMObjects.h"
#import "EMConnectDataStore.h"

#import "EMConnectLoginView.h"

#define EDMODO_COLOR_R 0.93
#define EDMODO_COLOR_G 0.93
#define EDMODO_COLOR_B 0.95
#define EDMODO_COLOR_ALPHA 0.7

@interface EMConnectLoginView ()

@end

@implementation EMConnectLoginView {
  NSString* _clientID;
  NSString* _redirectURI;
  NSArray* _scopes;
  BOOL _responsive;
  EMStringResultBlock_t _successHandler;
  EMVoidResultBlock_t _cancelHandler;
  EMNSErrorBlock_t _errorHandler;
}


static NSString* const EDMODO_CONNECT_LOGIN_BEGINNING = @"https://api.edmodo.com/oauth/authorize?nr=1&";
static NSString* const EDMODO_CONNECT_LOGIN_BEGINNING_RESPONSIVE = @"https://api.edmodo.com/oauth/authorize?";

- (id)initWithFrame:(CGRect)rect
       withClientID:(NSString*)clientID
    withRedirectURI:(NSString*)redirectURI
         withScopes:(NSArray*)scopes
          onSuccess:(EMStringResultBlock_t)successHandler
           onCancel:(EMVoidResultBlock_t)cancelHandler
            onError:(EMNSErrorBlock_t)errorHandler {
  return [self initWithFrame:rect
                withClientID:clientID
             withRedirectURI:redirectURI
                  withScopes:scopes
                  responsive:NO
                   onSuccess:successHandler
                    onCancel:cancelHandler
                     onError:errorHandler];
}
- (id)initWithFrame:(CGRect)rect
       withClientID:(NSString*)clientID
    withRedirectURI:(NSString*)redirectURI
         withScopes:(NSArray*)scopes
         responsive:(BOOL)responsive
          onSuccess:(EMStringResultBlock_t)successHandler
           onCancel:(EMVoidResultBlock_t)cancelHandler
            onError:(EMNSErrorBlock_t)errorHandler {
  self = [super initWithFrame:rect];
  if (self) {
    [self __internalInitWithClientID:clientID
                     withRedirectURI:redirectURI
                          withScopes:scopes
                          responsive: responsive
                           onSuccess:successHandler
                            onCancel:cancelHandler
                             onError:errorHandler];
  }
  return self;
}

- (void) __internalInitWithClientID:(NSString*)clientID
                    withRedirectURI:(NSString*)redirectURI
                         withScopes:(NSArray*)scopes
                         responsive:(BOOL)responsive
                          onSuccess:(EMStringResultBlock_t)successHandler
                           onCancel:(EMVoidResultBlock_t)cancelHandler
                            onError:(EMNSErrorBlock_t)errorHandler {
  _clientID = clientID;
  _redirectURI = redirectURI;
  _scopes = scopes;
  _responsive = responsive;
  _successHandler = successHandler;
  _cancelHandler = cancelHandler;
  _errorHandler = errorHandler;

  [self __createWidgets];
}

- (NSString *) __urlEscapeString:(NSString*)string
{
  return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                               NULL,
                                                                               (__bridge CFStringRef) string,
                                                                               NULL,
                                                                               CFSTR("!*'();:@&=+$,/?%#[]\" "),
                                                                               kCFStringEncodingUTF8));
}

- (NSString*) __createUrlParamsString:(NSDictionary*)params
{
  NSMutableString* str = [NSMutableString stringWithString:@""];

  BOOL first = YES;
  for (NSString *key in [params allKeys]) {
    NSString *escapedValue = [self __urlEscapeString:[params objectForKey:key]];
    if (!first) {
      [str appendString:@"&"];
    }
    first = NO;

    [str appendString:key];
    [str appendString:@"="];
    [str appendString:escapedValue];
  }
  return [NSString stringWithString:str];
}

- (void) __createWidgets
{
  self.backgroundColor = [UIColor colorWithRed:EDMODO_COLOR_R green:EDMODO_COLOR_G blue:EDMODO_COLOR_B alpha:EDMODO_COLOR_ALPHA];

  // create UIWebview at some nice size, centered.
  // Caller can overload if they want.
  CGFloat x = (self.frame.size.width - EM_WebViewWidth)/2;
  // Scoot it up above center to make room for keyboard
  CGFloat y = (self.frame.size.height - EM_WebViewHeight)/2;

  CGRect wvFrame = CGRectMake(x, y, EM_WebViewWidth, EM_WebViewHeight);

  self.webView = [[UIWebView alloc]initWithFrame:wvFrame];
  self.webView.delegate = self;
  self.webView.scrollView.bounces = NO;
  self.webView.suppressesIncrementalRendering = YES;
  self.webView.scrollView.scrollEnabled = NO;

  self.webView.layer.borderColor = [UIColor blackColor].CGColor;
  self.webView.layer.borderWidth = EM_WebViewBorderWidth;
  self.webView.layer.shadowColor = [[UIColor grayColor] CGColor];
  self.webView.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
  self.webView.layer.shadowRadius = 2.0f;
  self.webView.layer.shadowOpacity = 1.0f;
  self.webView.layer.shouldRasterize = YES;
  self.webView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.7];
  [self addSubview:self.webView];

  UIButton* closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
  closeButton.frame = CGRectMake(x+EM_WebViewWidth-14, y-14, 28, 29);
  [closeButton setBackgroundImage:[UIImage imageNamed:@"button-close"] forState:UIControlStateNormal];
  [closeButton addTarget:self action:@selector(quitLogin:) forControlEvents:UIControlEventTouchUpInside];
  [self addSubview:closeButton];


//  UITapGestureRecognizer *tapRecognizer =
//  [[UITapGestureRecognizer alloc] initWithTarget:self
//                                          action:@selector(quitLogin:)];
//  [tapRecognizer setNumberOfTapsRequired:1];
//  [tapRecognizer setDelegate:self];
//  [self addGestureRecognizer:tapRecognizer];


  // load preview html while the real content is loading because it's very slow
  [self.webView loadHTMLString:@"<html><head><style>h1{text-align:center;font-family:'Helvetica Neue';font-size:40px;}.outer {display: table; position: absolute;height: 100%;width: 100%;}.middle {display: table-cell;vertical-align: middle;}.inner {margin-left: auto;margin-right: auto;width:80%;}</style><body><div class='outer'><div class='middle'><div class='inner'><h1>Loading ...</h1></div></div></div></body></html>" baseURL:nil];
  [self performSelector:@selector(__loadURL:) withObject:nil afterDelay:0.2];
}

-(void) quitLogin:(id)sender
{
  if (self.webView.isLoading) {
    [self.webView stopLoading];
  }
  _cancelHandler();
}


-(void)__loadURL:(id)sender{
  [self.webView stopLoading]; //added this line to stop the previous request
  NSString* scopesString = [_scopes componentsJoinedByString:@" "];

  NSDictionary* params = [[NSDictionary alloc] initWithObjects: @[
                                                                  _clientID,
                                                                  @"token",
                                                                  scopesString,
                                                                  _redirectURI,
                                                                  ]
                                                       forKeys: @[
                                                                  @"client_id",
                                                                  @"response_type",
                                                                  @"scope",
                                                                  @"redirect_uri",
                                                                  ]];


 	NSString* loginBeginning = _responsive ? EDMODO_CONNECT_LOGIN_BEGINNING_RESPONSIVE : EDMODO_CONNECT_LOGIN_BEGINNING;
  NSString* fullURL = [loginBeginning stringByAppendingString:[self __createUrlParamsString:params]];
  NSURL *url = [NSURL URLWithString:fullURL];
  NSURLRequest *requestURL = [NSURLRequest requestWithURL:url];
  [self.webView loadRequest:requestURL];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
  [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void) logCookies {
  NSHTTPCookie *cookie;
  NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
  for (cookie in [cookieJar cookies]) {
    KTCLOG(@" Cookie [%@]", [cookie name]);
  }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

  if (webView.scrollView.contentSize.width > webView.frame.size.width) {
    CGFloat newContentOffsetX = (webView.scrollView.contentSize.width/2) - (webView.bounds.size.width/2);
    [webView.scrollView setContentOffset:CGPointMake(newContentOffsetX, 0)];
  }

  if ([[webView.request.URL absoluteString] isEqualToString: @"about:blank"]) {
    return;
  }
  //[self logCookies];
  [self handleCallback:webView.request.URL];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)handleCallback:(NSURL*)url {
  NSString *fragment = [url fragment];
  if ([fragment length] && [fragment rangeOfString:@"access_token="].location != NSNotFound) {
    NSArray *fragmentComponents = [fragment componentsSeparatedByString:@"&"];
    for (int i = 0; i < [fragmentComponents count]; i++) {
      NSString *component = [fragmentComponents objectAtIndex:i];
      if ([component rangeOfString:@"access_token="].location != NSNotFound) {
        NSString *accessToken = [component stringByReplacingOccurrencesOfString:@"access_token=" withString:@""];
        if ([accessToken length]) {
          return _successHandler(accessToken);
        }
      }
    }
  } else if ([url.host isEqualToString: @"api.edmodo.com"] && [url.path hasPrefix: @"/oauth/authorize/"]) {
    NSString* accessToken = [url.path substringFromIndex: [@"/oauth/authorize/" length]];
    if ([accessToken length]) {
      return _successHandler(accessToken);
    }
  }

  // unless it's the first pageload, we're done
  // TODO: use NSURLRequest to detect status, and call callback unless status is 3xx
  if (![url.host isEqualToString: @"api.edmodo.com"] || ![url.path isEqualToString: @"/login"]) {
  		_cancelHandler();
  }
}

@end
