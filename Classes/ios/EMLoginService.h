//
//  EMLoginService.h
//  ProtoComicApp
//
//  Created by Doug Banks on 5/9/14.
//  Copyright (c) 2014 Luca Prasso Edmodo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIAlertView.h>
#import "EMDataStore.h"

// Valid 'scope' values.
#define EM_BASIC_SCOPE              @"basic"
#define EM_READ_GROUPS_SCOPE        @"read_groups"
#define EM_READ_USER_EMAIL_SCOPE    @"read_user_email"
#define EM_READ_CONNECTIONS_SCOPE   @"read_connections"

/**
 Handles login/logout of Edmodo User, including UI/UX componments.
 If user logs in properly, we configure EMObjects shared instance with
 authentication info.
 */
@interface EMLoginService : NSObject<UIAlertViewDelegate>

+ (id)sharedInstance;

/** 
 Step 1.
 Configuration.
 Set the scopes you will use to communicate with Edmodo.
 Defaults to 'basic, read_groups'.
 */
- (void) setScopes:(NSArray*)scopes;

/**
 Step 2.
 If we successfully logged in before and have not since logged out, 
 we have stored keys in local storage: we can pull those out, 
 configure a data store and have OMObjects ready to go without 
 requesting more authentication.
 
 Return YES if we success in restoring.
 */
- (BOOL) restoreLogin;

/**
 Step 3.
 If restore login fails, go ahead and let the user authenticate.
 
 Get user 'key' so we can talk to datastore as some authenticated user.
 
 Use key to create a data store and configure OM Objects with that
 data store.
 
 Anywhere along the way we might get cancelled or find an error.
 
 It is an error to call this
 */
-(void) initiateLoginInParentView:(UIView*)parentView
                     withClientID:(NSString*)clientID
                  withRedirectURI:(NSString*)redirectURI
                        onSuccess:(EMVoidResultBlock_t)successHandler
                         onCancel:(EMVoidResultBlock_t)cancelHandler
                          onError:(EMNSErrorBlock_t)errorHandler;


/**
 Clear out currently logged in user.
 Clear OMObjects of data store and all loaded data.
 Clear stored keys in local storage (restoreLogin won't do anything).
 */
-(void) logout;


// If YES, initiateLoginInParentView will offer a choice between real and mock
// login, and restoreLogin will restore a stored mock login.
@property BOOL debugEnabled;

@end
