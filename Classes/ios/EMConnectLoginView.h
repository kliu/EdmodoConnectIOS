//
//  EMConnectLoginViewController
//  EdmodoTestMobile
//
//  Created by Luca Prasso on 12/16/13.
//  Copyright (c) 2013 Luca Prasso Edmodo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMDataStore.h"
#import "EMConnectDataStore.h"
#import "EMMockDataStore.h"

// web view controller to connect to Edmodo Connect
// and allow Edmodo user login
//


#define EM_WebViewContentWidth      450
#define EM_WebViewContentHeight     440
#define EM_WebViewBorderWidth       5

#define EM_WebViewWidth     (EM_WebViewContentWidth + 2 * EM_WebViewBorderWidth)
#define EM_WebViewHeight    (EM_WebViewContentHeight + 2 * EM_WebViewBorderWidth)


@interface EMConnectLoginView : UIView  <UIWebViewDelegate,
UIGestureRecognizerDelegate>

- (id)initWithFrame:(CGRect)rect
       withClientID:(NSString*)clientID
    withRedirectURI:(NSString*)redirectURI
         withScopes:(NSArray*)scopes
          onSuccess:(EMStringResultBlock_t)successHandler
           onCancel:(EMVoidResultBlock_t)cancelHandler
            onError:(EMNSErrorBlock_t)errorHandler;

@end
