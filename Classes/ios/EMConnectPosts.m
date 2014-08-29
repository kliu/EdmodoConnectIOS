//
//  EMConnectDataStore.m
//  EdmodoTestMobile
//
//  Created by Luca Prasso on 12/17/13.
//  Copyright (c) 2013 Luca Prasso Edmodo. All rights reserved.
//

#import "EMConnectPosts.h"
#import "EMBlockTypes.h"
#import "EMErrorHelper.h"

static NSString* const EDMODO_CONNECT_MESSAGES = @"https://api.edmodo.com/write_messages?access_token=%@";


@implementation EMConnectPosts
{
    NSString* _accessToken;
}


+(id)sharedInstance {
    
    static dispatch_once_t once_token = 0;
    
    __strong static id _sharedObject = nil;
    
    dispatch_once(&once_token, ^{
        _sharedObject = [[self alloc] init];
    });
    
    return _sharedObject;
}

- (id)init {
    self =[super init];
    if (self) {
        _accessToken = nil;
    }
    return self;
}


-(void) setAccessToken: (NSString*)at
{
    _accessToken = at;
}


- (void) postMessage: (NSString*)message
           linkTitle: (NSString*)linkTitle
             linkURL: (NSString*)linkURL
             toGroup: (EMGroup*)group
           onSuccess: (EMDictionaryResultBlock_t)successHandler
             onError: (EMNSErrorBlock_t)errorHandler
{
    // No access token, error.
    if (_accessToken == nil) {
        [EMErrorHelper callErrorHandler:errorHandler
                            withMessage:@"No access token"];
        return;
    }
    
    NSDictionary* mainDictionary = [self __createJsonDictionaryWithMessage:message
                                                                 linkTitle:linkTitle
                                                                   linkURL:linkURL
                                                                   toGroup:group];
    //convert object to data
    NSError* jsonSerlializeError;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:mainDictionary
                                                       options:NSJSONWritingPrettyPrinted error:&jsonSerlializeError];
    if (!jsonData) {
        errorHandler(jsonSerlializeError);
        return;
    }
    
    NSString *urlAsString = [NSString stringWithFormat:EDMODO_CONNECT_MESSAGES,
                             _accessToken];
    NSURL *url = [NSURL URLWithString:[urlAsString
                                       stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod: @"POST"];
    [request setHTTPBody:jsonData];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (error) {
                                   errorHandler(error);
                                   return;
                               } else {
                                   NSError* jsonParseError;
                                   NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:data
                                                                                            options:NSJSONReadingAllowFragments
                                                                                              error:&jsonParseError];
                                   if (jsonParseError != nil) {
                                       NSLog(@"Error: %@", jsonParseError);
                                       errorHandler(jsonParseError);
                                   } else {
                                       successHandler(jsonDict);
                                   }
                               }
                           }];
    
    
}


- (NSDictionary*) __createJsonDictionaryWithMessage:(NSString *)message
                                                             linkTitle:(NSString *) linkTitle
                                                               linkURL:(NSString *) linkURL
                                                               toGroup:(EMGroup*) group
{
    NSDictionary* linkDictionary = [[NSDictionary alloc] initWithObjects:@[
                                                                           linkTitle,
                                                                           linkURL]
                                                                 forKeys:@[
                                                                           @"title",
                                                                           @"url"]];
    NSArray* links = @[linkDictionary];
    NSDictionary* attachmentsDictionary = [[NSDictionary alloc] initWithObjects:@[links]
                                                                        forKeys:@[@"links"]];
    
    NSDictionary* contentDictionary = [[NSDictionary alloc] initWithObjects:@[
                                                                              message,
                                                                              attachmentsDictionary]
                                                                    forKeys:@[
                                                                              @"text",
                                                                              @"attachments"]];
    
    NSDictionary* groupDictionary = [[NSDictionary alloc] initWithObjects:@[
                                                                            group.groupID]
                                                                  forKeys:@[
                                                                            @"id"]];
    NSArray* groupsArray = @[groupDictionary];
    
    NSDictionary* recipientsDictionary = [[NSDictionary alloc] initWithObjects:@[
                                                                                 groupsArray]
                                                                       forKeys:@[
                                                                                 @"groups"]];
    
    
    NSDictionary* mainDictionary = [[NSDictionary alloc] initWithObjects:@[@"note",
                                                                           contentDictionary,
                                                                           recipientsDictionary]
                                                                 forKeys:@[@"content_type",
                                                                           @"content",
                                                                           @"recipients"]];
    return mainDictionary;
}


@end
