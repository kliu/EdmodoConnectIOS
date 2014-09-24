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

@property UIWebView* webView;

/**
 Put up a web view for login to Edmodo.
 
 rect: frame for web view.
 clientID: the Edmodo Connect client ID for your app.
 redirectURI: the page to navigate to once logged into Edmodo.
   This must match the page listed when you created the app in Edmodo Connect.
 scopes: one or more of the Edmodo Connect scopes.  This must be a subset of 
   the scopes listen when you created the app in Edmodo Connect.
 successHandler: if login is successful, this will be called with the 
   Edmodo Connect access token as argument.
 cancelHandler: the user bailed out of trying to log in.
 errorHandler: user tried to log in and something went wrong.
 
 Note that this is a 'token authentication flow', as described here:
 https://developers.edmodo.com/edmodo-connect/docs/

 So:
 - UIWebView hits edmodo connect authentication.
 - User enters credentials and permission.
 - On success, EdmodoConnect then redirects to the given redirectURI, appending 
   a hash fragment including the auth token.
 - This class, the EMConnectLoginView, watches for that redirect, picks out the auth
   token, and hands it back through successHandler.
 
 So the redirectURI, in this case, doesn't really matter.  As long as
 <your redirect uri>#<our hash fragment info>
 gets loaded in the webview (i.e. that doesn't redirect to something else again), 
 the actual content at <your redirct uri> is irrelevant.
 */

- (id)initWithFrame:(CGRect)rect
       withClientID:(NSString*)clientID
    withRedirectURI:(NSString*)redirectURI
         withScopes:(NSArray*)scopes
          onSuccess:(EMStringResultBlock_t)successHandler
           onCancel:(EMVoidResultBlock_t)cancelHandler
            onError:(EMNSErrorBlock_t)errorHandler;


@end
