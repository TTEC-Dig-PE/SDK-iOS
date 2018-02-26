//
//  AppConfig.m
//  EXPERTconnectDemo
//
//  Created by Michael Schmoyer on 2/9/16.
//  Copyright © 2016 Humanify, Inc. All rights reserved.
//

#import "AppConfig.h"

@implementation AppConfig

@synthesize organization;

#pragma mark Singleton Methods

+ (id)sharedAppConfig {
    static AppConfig *sharedAppConfig = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedAppConfig = [[self alloc] init];
    });
    return sharedAppConfig;
}

- (id)init {
    if (self = [super init]) {
        //someProperty = [[NSString alloc] initWithString:@"Default Property Value"];
        
        NSString *curEnv = [[NSUserDefaults standardUserDefaults] objectForKey:@"environmentName"];
        organization = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_organization", curEnv]];
    }
    return self;
}

#pragma mark Config Functions

-(void) startBreadcrumbSession {
    // Start a new journey, then send an "app launch" breadcrumb.
    
    ECSBreadcrumb *bc = [[ECSBreadcrumb alloc] initWithAction:@"ECDemo Started"
                                                  description:@""
                                                       source:@"ECDemo"
                                                  destination:@"Humanify" ];
    [[EXPERTconnect shared] breadcrumbSendOne:bc
                               withCompletion:^(ECSBreadcrumbResponse *response, NSError *error)
    {
        NSString *savedContext = [[NSUserDefaults standardUserDefaults] valueForKey:@"ECDJourneyManagerContextKey"];
        if(savedContext)
        {
            [[EXPERTconnect shared] setJourneyContext:savedContext withCompletion:nil];
        }
    }];
}

- (void) getCustomizedThemeSettings {
    
    bool showAvatars = [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%@", ECDShowAvatarImagesKey]];
    [EXPERTconnect shared].theme.showAvatarImages = showAvatars;
    
    bool showBubbleTails = [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%@", ECDShowChatBubbleTailsKey]];
    [EXPERTconnect shared].theme.showChatBubbleTails = showBubbleTails;
    
    bool chatTimestamps = [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%@", ECDShowChatTimeStampKey]];
    [EXPERTconnect shared].theme.showChatTimeStamp = chatTimestamps;
    
    //[EXPERTconnect shared].theme.chatSendButtonUseImage = YES;
}

// mas - 16-oct-2015 - Fetch available environments and clientID's from a JSON file hosted on our server.
- (void) fetchEnvironmentJSON {
    
    //NSURL *url = [[NSURL alloc] initWithString:@"https://tce1.humanify.com/humanify_sdk_orgs.json"];
    NSURL *url = [[NSURL alloc] initWithString:@"https://dce1.humanify.com/humanify_sdk_orgs.json"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url
                                            completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
    {
 
         // The server request has completed. Parse file and store it in user defaults.
         if (!error) {
             
             NSError *serializeError;
             NSMutableDictionary *orgDictionary = [NSJSONSerialization
                                                   JSONObjectWithData:data
                                                   options:NSJSONReadingMutableContainers
                                                   error:&serializeError];
             
             //NSLog(@"Env/Org Json: %@", orgDictionary);
             
             if ([orgDictionary objectForKey:@"environment_config"]) {
                 
                 NSDictionary *envConfig = [orgDictionary objectForKey:@"environment_config"];
                 
                 [[NSUserDefaults standardUserDefaults] setObject:envConfig forKey:@"environmentConfig"];
                 [[NSUserDefaults standardUserDefaults] synchronize];
                 
                 //NSLog(@"Saving environment config from JSON successful.");
                 
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"ECDEnvironmentJsonFileUpdated" object:nil];
             }
             
         } else {
             NSLog(@"Error fetching env/org JSON file. Error=%@", error);
         }
     }];
    
    [dataTask resume]; 
}

// Assigns this object to be the delegate for login retry requests.
-(void) setupAuthenticationDelegate {
    [[EXPERTconnect shared] setAuthenticationTokenDelegate:self];
}

- (NSString *)getHostURL {
    
    NSString *url = [[NSUserDefaults standardUserDefaults] objectForKey:@"serverURL"];
    
    if(!url || url.length == 0) {
        url = @"localhost"; // Default
    }
    if ([url isEqualToString:@"http://api.dce1.humanify.com"])
    {
        url = @"https://api.dce1.humanify.com";
    }
    
    return [url stringByAppendingString:@"/"];
    //return url;
}

// Attempt to grab organization (clientid) from user defaults. Defaults otherwise.
- (NSString *)getClientID {
    
    NSString *currentOrganization = nil;
    NSString *currentEnv = [[NSUserDefaults standardUserDefaults]
                            objectForKey:@"environmentName"];
    
    if (currentEnv) {
        currentOrganization = [[NSUserDefaults standardUserDefaults]
                               objectForKey:[NSString stringWithFormat:@"%@_%@", currentEnv, @"organization"]];
    }
    
    return ( currentOrganization ? currentOrganization : @"mktwebextc" );
}

-(NSString *)getUserName {
    return ([EXPERTconnect shared].userName ? [EXPERTconnect shared].userName : @"Guest");
    //return [EXPERTconnect shared].userName;
    //return self.userName;
    //return (self.userName ? self.userName : @"Guest");
}

// This function is called by both this app (host app) and the SDK as the official auth token fetch function.
- (void)fetchAuthenticationToken:(void (^)(NSString *authToken, NSError *error))completion {
    
    // add /ust for new method
    NSString *hostURL = [self getHostURL];
    
    if( ![hostURL hasSuffix:@"/"] ) hostURL = [hostURL stringByAppendingString:@"/"];

    // Return a hardcoded token for servers that don't have an authServerProxy.
    
    if( [hostURL containsString:@"ce03"] ) {
        
        // expires 2020-09-28, user=devtest@humanify.com
        NSString *ce03_token = @"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodW1hbmlmeS5jb20iLCJpYXQiOjE1MDY2MzE5ODYsImV4cCI6MTYwMTMyNjQxMSwiYXVkIjoid3cxLmh1bWFuaWZ5LmNvbSIsInN1YiI6ImRldnRlc3RAaHVtYW5pZnkuY29tIiwiYXBpS2V5IjoiMTEyODhmMDFlODc1NGM1Njk3N2M0MDhjZmEwNjQ2OTEiLCJjbGllbnRfaWQiOiJ3dzEifQ.ofRWHn2mW0SWbapP3K_S0kH1VHOrsH7q5fuCHUqp1wo";
        
        completion(ce03_token, nil);
        
        return;
        
    } else {
        
        // Fetch the token from authServerProxy on the selected host.
    
        NSString *urlString = [NSString stringWithFormat:@"%@authServerProxy/v1/tokens/ust?username=%@&client_id=%@",
                               hostURL,
                               [[self getUserName] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]],
                               organization];
        
        NSURL *url = [[NSURL alloc] initWithString:urlString];
        
        NSLog(@"Test Harness::AppConfig.m - fetchAuthenticationToken - AuthToken URL: %@", url);
        
        NSURLSession *session = [NSURLSession sharedSession];
        [[session dataTaskWithURL:url
                completionHandler:^(NSData *data,
                                    NSURLResponse *response,
                                    NSError *error) {
                    // handle response
                    long statusCode = (long)((NSHTTPURLResponse*)response).statusCode;
                    NSString *returnToken = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    
                    if(!error && (statusCode == 200 || statusCode == 201))
                    {
                        NSString *abbrevToken = [NSString stringWithFormat:@"%@...%@",
                                                 [returnToken substringToIndex:4],
                                                 [returnToken substringFromIndex:returnToken.length-4]];
                        NSLog(@"Test Harness::AppConfig.m - fetchAuthenticationToken - Successfully fetched authToken: %@", abbrevToken);
                        completion([NSString stringWithFormat:@"%@", returnToken], nil);
                    }
                    else
                    {
                        // If the new way didn't work, try the old way once.
                        NSLog(@"Test Harness::AppConfig.m - fetchAuthenticationToken - ERROR FETCHING AUTHENTICATION TOKEN! StatusCode=%ld, Payload=%@", statusCode, returnToken);
                        //[self fetchOldAuthenticationToken:completion];
                        NSError *myError = [NSError errorWithDomain:@"com.humanify"
                                                               code:statusCode
                                                           userInfo:[NSDictionary dictionaryWithObject:returnToken forKey:@"errorJson"]];
                        completion(nil, myError);
                    }
                }] resume];
        
//        [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url]
//                                           queue:[[NSOperationQueue alloc] init]
//                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
//         {
//             
//             long statusCode = (long)((NSHTTPURLResponse*)response).statusCode;
//             NSString *returnToken = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//             
//             if(!error && (statusCode == 200 || statusCode == 201))
//             {
//                 NSString *abbrevToken = [NSString stringWithFormat:@"%@...%@",
//                                          [returnToken substringToIndex:4],
//                                          [returnToken substringFromIndex:returnToken.length-4]];
//                 NSLog(@"Test Harness::AppConfig.m - fetchAuthenticationToken - Successfully fetched authToken: %@", abbrevToken);
//                 completion([NSString stringWithFormat:@"%@", returnToken], nil);
//             }
//             else
//             {
//                 // If the new way didn't work, try the old way once.
//                 NSLog(@"Test Harness::AppConfig.m - fetchAuthenticationToken - ERROR FETCHING AUTHENTICATION TOKEN! StatusCode=%ld, Payload=%@", statusCode, returnToken);
//                 //[self fetchOldAuthenticationToken:completion];
//                 NSError *myError = [NSError errorWithDomain:@"com.humanify"
//                                                        code:statusCode
//                                                    userInfo:[NSDictionary dictionaryWithObject:returnToken forKey:@"errorJson"]];
//                 completion(nil, myError);
//             }
//         }];
    }
}

// This function is called by both this app (host app) and the SDK as the official auth token fetch function.
/*- (void)fetchOldAuthenticationToken:(void (^)(NSString *authToken, NSError *error))completion {
    
    // add /ust for new method
    NSURL *url = [[NSURL alloc] initWithString:
                  [NSString stringWithFormat:@"%@/authServerProxy/v1/tokens?username=%@&client_id=%@",
                   [self getHostURL],
                   [self getUserName],
                   [self getClientID]]];
    
    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url]
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         
         long statusCode = (long)((NSHTTPURLResponse*)response).statusCode;
         NSString *returnToken = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
         
         if(!error && (statusCode == 200 || statusCode == 201))
         {
             NSLog(@"Successfullyyy fetched authToken: %@", returnToken);
             completion([NSString stringWithFormat:@"%@", returnToken], nil);
         }
         else
         {
             NSLog(@"ERROR FETCHING OLD AUTHENTICATION TOKEN! StatusCode=%ld, Payload=%@", statusCode, returnToken);
             
         }
     }];
}*/

@end
