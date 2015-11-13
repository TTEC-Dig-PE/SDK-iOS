//
//  ECSURLSessionManager.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSURLSessionManager.h"

@import SystemConfiguration;
#import <netinet/in.h>

#import "ECSActionType.h"
#import "ECSActionTypeClassTransformer.h"
#import "ECSAnswerEngineResponse.h"
#import "ECSAnswerEngineTopQuestionsResponse.h"
#import "ECSAnswerEngineRateResponse.h"
#import "ECSCafeXController.h"
#import "ECSCallbackSetupResponse.h"
#import "ECSChannelConfiguration.h"
#import "ECSChannelCreateResponse.h"
#import "ECSChatHistoryMessage.h"
#import "ECSChatHistoryResponse.h"
#import "ECSConfiguration.h"
#import "ECSConversationCreateResponse.h"
#import "ECSStartJourneyResponse.h"
#import "ECSAgentAvailableResponse.h"
#import "ECSForm.h"
#import "ECSFormSubmitResponse.h"
#import "ECSSelectExpertsResponse.h"
#import "ECSUserProfile.h"
#import "ECSInjector.h"
#import "ECSHistoryList.h"
#import "ECSKeychainSupport.h"
#import "ECSLog.h"
#import "ECSRequestSerializer.h"
#import "ECSResponseSerializer.h"
#import "ECSHistoryResponse.h"
#import "ECSJSONResponseSerializer.h"
#import "ECSJSONRequestSerializer.h"
#import "ECSJSONSerializer.h"
#import "ECSActionType.h"
#import "ECSActionTypeClassTransformer.h"
#import "ECSNavigationContext.h"
#import "ECSUserManager.h"

NSString *const ECSReachabilityChangedNotification = @"ECSNetworkReachabilityChangedNotification";

typedef void (^ECSSessionManagerSuccess)(id result, NSURLResponse *response);
typedef void (^ECSSessionManagerFailure)(id result, NSURLResponse *response, NSError *error);

@interface ECSURLSessionManager() <NSURLSessionDelegate, NSURLSessionTaskDelegate>
{
    SCNetworkReachabilityRef _reachabilityRef;
}

@property (strong, nonatomic) NSURL *baseURL;
@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) ECSRequestSerializer *requestSerializer;
@property (strong, nonatomic) ECSResponseSerializer *responseSerializer;

@end

static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info)
{
#pragma unused (target, flags)
    NSCAssert(info != NULL, @"info was NULL in ReachabilityCallback");
    NSCAssert([(__bridge NSObject*) info isKindOfClass: [ECSURLSessionManager class]], @"info was wrong class in ReachabilityCallback");
    
    ECSURLSessionManager* sessionObject = (__bridge ECSURLSessionManager *)info;
    // Post a notification to notify the client that the network reachability changed.
    [[NSNotificationCenter defaultCenter] postNotificationName:ECSReachabilityChangedNotification object:sessionObject];
}

@implementation ECSURLSessionManager

- (instancetype)initWithHost:(NSString*)host
{
    self = [super init];
    if (self)
    {
        self.hostName = host;
        self.responseSerializer = [ECSJSONResponseSerializer new];
        self.requestSerializer = [ECSJSONRequestSerializer new];
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        self.session = [NSURLSession sessionWithConfiguration:sessionConfig
                                                     delegate:self
                                                delegateQueue:[NSOperationQueue new]];

        [self startReachability];
    }
    
    return self;
}

- (void)dealloc
{
    [self stopReachability];
    
    ECSCafeXController *cafeXController = [[ECSInjector defaultInjector] objectForClass:[ECSCafeXController class]];
    if ([cafeXController hasCafeXSession]) {
        [cafeXController endCafeXSession];
    }
    
    [self.session invalidateAndCancel];
}

- (void)setHostName:(NSString *)hostName
{
    _hostName = hostName;
    self.baseURL = [NSURL URLWithString:hostName];
}

- (void)startReachability
{
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    // Recover reachability flags
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    if (reachability != NULL)
    {
        _reachabilityRef = reachability;
        SCNetworkReachabilityContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
        
        if (SCNetworkReachabilitySetCallback(_reachabilityRef, ReachabilityCallback, &context))
        {
            SCNetworkReachabilityScheduleWithRunLoop(_reachabilityRef, CFRunLoopGetMain(), kCFRunLoopDefaultMode);
        }
    }
}

- (void)stopReachability
{
    if (_reachabilityRef != NULL)
    {
        SCNetworkReachabilityUnscheduleFromRunLoop(_reachabilityRef, CFRunLoopGetMain(), kCFRunLoopDefaultMode);
        CFRelease(_reachabilityRef);
    }
}

- (BOOL)networkReachable
{
    NSAssert(_reachabilityRef != NULL, @"currentNetworkStatus called with NULL SCNetworkReachabilityRef");
    SCNetworkReachabilityFlags flags;
    BOOL reachable = NO;
    
    if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags))
    {
        BOOL isReachable = ((flags & kSCNetworkReachabilityFlagsReachable) != 0);
        BOOL needsConnection = ((flags & kSCNetworkReachabilityFlagsConnectionRequired) != 0);
        BOOL canConnectionAutomatically = (((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) || ((flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0));
        BOOL canConnectWithoutUserInteraction = (canConnectionAutomatically && (flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0);
        BOOL isNetworkReachable = (isReachable && (!needsConnection || canConnectWithoutUserInteraction));
        
        return isNetworkReachable;
    }
    
    return reachable;
}

- (NSURLSessionTask *)authenticateAPIWithClientID:(NSString*)clientID
                                        andSecret:(NSString*)clientSecret
                                       completion:(void (^)(NSString *authToken, NSError *error))completion;
{
    //NSAssert(clientID.length > 0, @"Client ID must be provided");
    //NSAssert(clientSecret.length > 0, @"Client secret must be provided");
    if (clientID.length == 0 || clientSecret.length == 0) {
        NSError *err = [[NSError alloc] initWithDomain:@"ClientID/Secret or userIdentityToken must be provided."
                                                  code:-2000
                                              userInfo:nil];
        completion(nil, err);
    }
    
    NSURL *url = [self URLByAppendingPathComponent:@"authserver/oauth/token"];
    NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:url];
    [mutableRequest setHTTPMethod:@"POST"];
    [mutableRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    NSData *authData = [[NSString stringWithFormat:@"%@:%@", clientID, clientSecret] dataUsingEncoding:NSUTF8StringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:0]];
    [mutableRequest setValue:authValue forHTTPHeaderField:@"Authorization"];

    [mutableRequest setHTTPBody:[[NSString stringWithFormat:@"grant_type=client_credentials"] dataUsingEncoding:NSUTF8StringEncoding]];

    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *task = [self dataTaskWithRequest:mutableRequest
                                  success:^(id result, NSURLResponse *response) {
                                      
                                      if ([result isKindOfClass:[NSDictionary class]])
                                      {
                                          weakSelf.authToken = [result objectForKey:@"access_token"];
                                      }
                                      if (completion)
                                      {
                                          completion(result, nil);
                                      }
                                  } failure:^(id result, NSURLResponse *response, NSError *error) {
                                      if (completion)
                                      {
                                          completion(nil, error);
                                      }
                                  }];
    [task resume];
    
    return task;

}


- (NSURLSessionDataTask *)makeDecision:(NSDictionary*)decisionJson
                                            completion:(void (^)(NSDictionary *decisionResponse, NSError *error))completion;
{
    return [self POST:@"decision/v1/makeDecision"
          parameters:decisionJson
             success:[self successWithExpectedType:[NSDictionary class] completion:completion]
             failure:[self failureWithCompletion:completion]];
    
}

- (NSURLSessionDataTask *)getNavigationContextWithName:(NSString*)name
                          completion:(void (^)(ECSNavigationContext *context, NSError *error))completion;
{
    NSDictionary *parameters = nil;
    
    if (name)
    {
        parameters = @{@"name": name};
    }
    
    /*
    if (self.conversation && self.conversation.journeyID.length > 0) {
        // Added to track breadcrumb of every navigation in the system
        NSString *actionType = @"Navigation";
        NSString *actionDescription = @"API Called everytime user navigates in ExpertConnect Demo";
        NSString *actionSource = @"Navigation";
        NSString *actionDestination = name;
    
        [[EXPERTconnect shared] breadcrumbsAction:actionType
                            actionDescription:actionDescription
                            actionSource:actionSource
                            actionDestination:actionDestination];
    }
     */
    
    
    
    return [self GET:@"appconfig/v1/navigation"
          parameters:parameters
             success:[self successWithExpectedType:[ECSNavigationContext class] completion:completion]
             failure:[self failureWithCompletion:completion]];

}

- (NSURLSessionDataTask *)getAnswerEngineTopQuestions:(NSNumber*)num
                                       withCompletion:(void (^)(NSArray *context, NSError *error))completion;
{
    NSDictionary *parameters = nil;
    
    if (num)
    {
        parameters = @{@"num": num};
    }
    return [self GET:@"answerengine/v1/questions"
          parameters:parameters
             success:[self successWithExpectedType:[NSArray class] completion:completion]
             failure:[self failureWithCompletion:completion]];
    
}


- (NSURLSessionDataTask *)getAnswerEngineTopQuestions:(NSNumber*)num
                                           forContext:(NSString*)context
                                       withCompletion:(void (^)(NSArray *context, NSError *error))completion;
{
    NSDictionary *parameters = nil;
    
    if (num)
    {
        parameters = @{@"num": num, @"context": context};
    }
    return [self GET:@"answerengine/v1/questions"
          parameters:parameters
             success:[self successWithExpectedType:[NSArray class] completion:completion]
             failure:[self failureWithCompletion:completion]];
    
}

- (NSURLSessionDataTask *)getAnswerForQuestion:(NSString*)question
                                     inContext:(NSString*)answerEngineContext
                               parentNavigator:(NSString*)parentNavigator
                                      actionId:(NSString*)actionId
                                 questionCount:(NSUInteger)questionCount
                                    customData:(NSDictionary *)customData
                                    completion:(void (^)(ECSAnswerEngineResponse *response, NSError *error))completion
{
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    
    [parameters addEntriesFromDictionary:@{
                                           @"question": question,
                                           @"context": answerEngineContext,
                                           @"navContext": parentNavigator,
                                           @"action_id": actionId,
                                           @"questionCount": [NSNumber numberWithUnsignedInteger:questionCount],
                                           }];
    
    if (customData)
    {
        [parameters setObject:customData forKey:@"customData"];
    }
    else
    {
        [parameters setObject:[NSNull null] forKey:@"customData"];
    }

    ECSLogVerbose(@"Get Answer with parameters %@", parameters);
    return [self POST:@"answerengine/v1/answers"
          parameters:parameters
             success:[self successWithExpectedType:[ECSAnswerEngineResponse class] completion:completion]
             failure:[self failureWithCompletion:completion]];
}

- (NSURLSessionDataTask *)rateAnswerWithAnswerID:(NSString*)answerID
                                       inquiryID:(NSString*)inquiryID
                                 parentNavigator:(NSString*)parentNavigator
                                        actionId:(NSString*)actionId
                                          rating:(NSNumber*)rating
                                   questionCount:(NSNumber*)questionCount
                                      completion:(void (^)(ECSAnswerEngineRateResponse *response, NSError *error))completion
{
    NSDictionary *parameters = @{
                                 @"inquiryId": inquiryID,
                                 @"navContext": parentNavigator,
                                 @"action_id": actionId,
                                 @"rating": rating,
                                 @"questionCount": questionCount
                                 };
    ECSLogVerbose(@"Rate answer with parameters %@", parameters);
    return [self PUT:[NSString stringWithFormat:@"answerengine/v1/answers/rate/%@", answerID]
           parameters:parameters
              success:[self successWithExpectedType:[ECSAnswerEngineRateResponse class] completion:completion]
              failure:[self failureWithCompletion:completion]];

}

- (NSURLSessionDataTask *)getResponseFromEndpoint:(NSString *)endpoint withCompletion:(void (^)(NSString *, NSError *))completion
{
    ECSLogVerbose(@"Get Results from a known endpoint");
    
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString:[self.baseURL.path stringByAppendingString:endpoint]];
    
    endpoint = urlComponents.path;
    NSArray *query = urlComponents.queryItems;
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
    for(NSURLQueryItem *item in query)
    {
        [parameters setObject:item.value forKey:item.name];
    }

    return [self GET:endpoint
          parameters:parameters
             success:[self successWithExpectedType:[NSString class] completion:completion]
             failure:[self failureWithCompletion:completion]];
}

- (NSURLSessionDataTask *)getUserProfileWithCompletion:(void (^)(ECSUserProfile *, NSError *))completion
{
    ECSLogVerbose(@"Get User's Profile");
    
    return [self GET:@"registration/v1/profile"
          parameters:nil
             success:[self successWithExpectedType:[ECSUserProfile class] completion:completion]
             failure:[self failureWithCompletion:completion]];
}

- (NSURLSessionDataTask *)submitUserProfile:(ECSUserProfile *)profile withCompletion:(void (^)(NSString *, NSError *))completion
{
    ECSLogVerbose(@"Submit User Profile");
    
    return [self POST:@"registration/v1/profile"
          parameters:[ECSJSONSerializer jsonDictionaryFromObject:profile]
             success:[self successWithExpectedType:[NSString class] completion:completion]
             failure:[self failureWithCompletion:completion]];
}

- (NSURLSessionDataTask *)getExpertsWithCompletion:(void (^)(ECSSelectExpertsResponse *, NSError *))completion
{
    ECSLogVerbose(@"Get Experts matching by User");
    
    return [self GET:@"registration/v1/experts"
          parameters:nil
             success:[self successWithExpectedType:[ECSSelectExpertsResponse class] completion:completion]
             failure:[self failureWithCompletion:completion]];
}

- (NSURLSessionDataTask *)getFormNamesWithCompletion:(void (^)(NSArray *, NSError *))completion;
{
    ECSLogVerbose(@"Get form names");
    return [self GET:@"forms/v1/"
          parameters:nil
             success:^(id result, NSURLResponse *response) {
                 if (completion)
                 {
                     if ([result isKindOfClass:[NSArray class]])
                     {
                         completion(result, nil);
                     }
                     else
                     {
                         completion(nil, nil);
                     }
                 }
             }
             failure:[self failureWithCompletion:completion]];
}

- (NSURLSessionDataTask *)getFormByName:(NSString*)formName withCompletion:(void (^)(ECSForm *, NSError *))completion
{
    NSAssert(formName != nil && formName.length > 0, @"formName must be specified");
    ECSLogVerbose(@"Get form %@", formName);
    return [self GET:[NSString stringWithFormat:@"forms/v1/%@", formName]
          parameters:nil
             success:[self successWithExpectedType:[ECSForm class] completion:completion]
             failure:[self failureWithCompletion:completion]];
}


- (NSURLSessionDataTask *)submitForm:(ECSForm*)form
                          completion:(void (^)(ECSFormSubmitResponse *response, NSError *error))completion
{
    ECSLogVerbose(@"Submit form %@", form);
    return [self POST:[NSString stringWithFormat:@"forms/v1/%@", form.name]
           parameters:[ECSJSONSerializer jsonDictionaryFromObject:form]
              success:[self successWithExpectedType:[ECSFormSubmitResponse class] completion:completion]
              failure:[self failureWithCompletion:completion]];
}

- (NSURLSessionDataTask *)submitForm:(ECSForm*)form
                              intent:(NSString*)intent
                   navigationContext:(NSString*)navigationContext
                      withCompletion:(void (^)(ECSFormSubmitResponse *response, NSError *error))completion
{
    NSMutableDictionary *formWithIntentAndNavContext = [[ECSJSONSerializer jsonDictionaryFromObject:form] mutableCopy];
    
    // kwashington: Moving away from Navigation and navigationContext, so check for null
    //
    if(intent == nil || navigationContext == nil) {
        return [self submitForm:form completion:completion];
    }
    
    [formWithIntentAndNavContext setObject:@"intent" forKey:intent];
    [formWithIntentAndNavContext setObject:@"navigationContext" forKey:navigationContext];

    ECSLogVerbose(@"Submit form %@", formWithIntentAndNavContext);
    
    return [self POST:[NSString stringWithFormat:@"forms/v1/%@", form.name]
           parameters:formWithIntentAndNavContext
              success:[self successWithExpectedType:[ECSFormSubmitResponse class] completion:completion]
              failure:[self failureWithCompletion:completion]];
}

- (NSURLSessionDataTask*)performLoginWithUsername:(NSString*)username
                                         password:(NSString*)password
                                       completion:(void (^)(id userData, NSError* error))completion
{
    NSDictionary *parameters = @{ @"username": username, @"password": password };
    
    ECSLogVerbose(@"Login with parameters %@", parameters);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        ECSUserManager *userManager = [[ECSInjector defaultInjector] objectForClass:[ECSUserManager class]];
        userManager.userToken = username;
        completion(username, nil);
        
    });
    
    return nil;

}

- (NSURLSessionDataTask*)performRegistrationWithFullName:(NSString*)fullName
                                            emailAddress:(NSString*)email
                                            mobileNumber:(NSString*)mobileNumber
                                              completion:(void (^)(id userData, NSError* error))completion
{
    NSDictionary *parameters = @{ @"name": fullName, @"email": email, @"mobileNumber": mobileNumber };
    
    ECSLogVerbose(@"Register with parameters %@", parameters);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        ECSUserManager* user = [ECSUserManager new];
        user.userToken = email;
        completion(user, nil);
    });
    
    return nil;
}

- (NSURLSessionDataTask*)startConversationForAction:(ECSActionType*)actionType
                                    andAlwaysCreate:(BOOL)alwaysCreate
                                     withCompletion:(void (^)(ECSConversationCreateResponse *conversation, NSError *error))completion
{
    if ([actionType.journeybegin boolValue] || alwaysCreate)
    {
        if ([actionType.journeybegin boolValue] && self.conversation)
        {
            self.conversation = nil;
        }
        
        if (!self.conversation)
        {
            __weak typeof(self) weakSelf = self;
            return [self setupConversationWithLocation:@"home" completion:^(ECSConversationCreateResponse *createResponse, NSError *error) {
                if (createResponse.conversationID && createResponse.conversationID.length > 0)
                {
                    weakSelf.conversation = createResponse;
                }
                
                if (completion)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(weakSelf.conversation, error);
                    });
                }
                
            }];
        }
        else if (completion)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(self.conversation, nil);
            });
        }
    }
    else
    {
        if (completion)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(self.conversation, nil);
            });
        }
    }
    
    return nil;
}

- (NSURLSessionDataTask*)setupConversationWithLocation:(NSString*)location
                                            completion:(void (^)(ECSConversationCreateResponse *response, NSError* error))completion
{
    NSAssert(location, @"Location must be specified");

    ECSKeychainSupport *support = [ECSKeychainSupport new];
    
    NSDictionary *parameters;
    if([EXPERTconnect shared].journeyID)
    {
        // Send the journeyID if startJourney() has been called.
        parameters = @{
                     @"location": location,
                     @"deviceId": [support deviceId],
                     @"journeyId": [EXPERTconnect shared].journeyID
                     };
    } else {
        parameters = @{
                     @"location": location,
                     @"deviceId": [support deviceId]
                     };
    }
    
    return [self POST:@"conversationengine/v1/conversations"
           parameters:parameters
              success:[self successWithExpectedType:[ECSConversationCreateResponse class] completion:completion]
              failure:[self failureWithCompletion:completion]];
}

- (NSURLSessionDataTask*)setupChannel:(ECSChannelConfiguration*)channelConfig inConversation:(NSString*)conversation
                                            completion:(void (^)(ECSChannelCreateResponse *response, NSError* error))completion
{
    
    NSDictionary *parameters = [ECSJSONSerializer jsonDictionaryFromObject:channelConfig];
    
    
    return [self POST:conversation
           parameters:parameters
              success:[self successWithExpectedType:[ECSChannelCreateResponse class] completion:completion]
              failure:[self failureWithCompletion:completion]];
}

- (NSURLSessionDataTask*)closeChannelAtURL:(NSString*)closeChannelURL
                                withReason:(NSString*)reason
                     agentInteractionCount:(NSInteger)interactionCount
                                  actionId:(NSString *)actionId
                                completion:(void (^)(id result, NSError* error))completion
{
    NSDictionary *parameters = nil;
    if (reason)
    {
        parameters = @{ @"reason": reason,
                        @"agentInteractionCount": [NSNumber numberWithInteger:interactionCount],
                        @"action_id": actionId };
    }
    
    return [self POST:closeChannelURL
            parameters:parameters
              success:^(id result, NSURLResponse *response) {
                  if (completion)
                  {
                      completion(result, nil);
                  }
              } failure:[self failureWithCompletion:completion]];
}

- (NSURLSessionDataTask*)getEndChatActionsForConversationId:(NSString*)conversationId
                                  withAgentInteractionCount:(NSInteger)interactionCount
                                          navigationContext:(NSString*)navigationContext
                                                   actionId:(NSString*)actionId
                                                 completion:(void (^)(NSArray* result, NSError* error))completion
{
    NSString *endChatActionsURL = [NSString stringWithFormat:@"conversationengine/v1/conversations/%@/actions", conversationId];
    NSDictionary *parameters = nil;

    parameters = @{
                   @"questionsAsked": [NSNull null],
                   @"questionsAnswered": [NSNull null],
                   @"agentInteractionCount": [NSNumber numberWithInteger:interactionCount],
                   @"navigationContext": navigationContext ? navigationContext : [NSNull null],
                   @"action_id": actionId ? actionId : [NSNull null],
                   };
    
    return [self POST:endChatActionsURL
           parameters:parameters
              success:^(id result, NSURLResponse *response) {
                  if (completion)
                  {
                      if ([result isKindOfClass:[NSDictionary class]])
                      {
                          NSArray *actionArray = [result objectForKey:@"actions"];
                          
                          if (actionArray)
                          {
                              NSArray *ecsActionArray = [ECSJSONSerializer arrayFromJSONArray:actionArray withClass:[ECSActionTypeClassTransformer class]];
                              completion(ecsActionArray, nil);
                              return;
                          }
                      }
                      
                      completion(nil, [NSError errorWithDomain:@"com.humanify" code:-1 userInfo:nil]);
                  }
              } failure:[self failureWithCompletion:completion]];
}

- (NSURLSessionDataTask*)agentAvailabilityWithSkills:(NSArray *)skills
                                          completion:(void(^)(ECSAgentAvailableResponse *response, NSError *error))completion {
    
    NSDictionary *parameters = @{ @"filter": [skills componentsJoinedByString:@","] };
    
    return [self GET:@"/conversationengine/v1/skills"
           parameters:parameters
              success:[self successWithExpectedType:[ECSAgentAvailableResponse class] completion:completion]
              failure:[self failureWithCompletion:completion]];
}

- (NSURLSessionDataTask*)setupJourneyWithCompletion:(void (^)(ECSStartJourneyResponse *response, NSError* error))completion
{
    //ECSKeychainSupport *support = [ECSKeychainSupport new];
    NSDictionary *parameters = @{};
    
    return [self POST:@"conversationengine/v1/journeys"
           parameters:parameters
              success:[self successWithExpectedType:[ECSStartJourneyResponse class] completion:completion]
              failure:[self failureWithCompletion:completion]];
}

#pragma mark - Media Upload
- (NSURLSessionUploadTask*)uploadFileData:(NSData*)data
                               withName:(NSString*)name
                        fileContentType:(NSString*)fileContentType
                             completion:(void (^)(id *response, NSError* error))completion
{
    NSString *path = @"/utils/v1/media";
    
    ECSLogVerbose(@"Upload file named %@", name);
    
    NSURL *url = [self URLByAppendingPathComponent:path];

    // Build a custom multipart/form-data request as we only have to do this in one place
    NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *boundaryString = @"----WebKitFormBoundary8jO6QksZdF1yvWl7";
    [mutableRequest setHTTPMethod:@"POST"];
    [mutableRequest setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundaryString]
          forHTTPHeaderField:@"Content-Type"];
    [self  setCommonHTTPHeadersForRequest:mutableRequest];
    
    // Build form body
    NSMutableData *body = [NSMutableData data];
    
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundaryString] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"\r\n", name] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", fileContentType] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundaryString] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"name\"\r\n\r\n%@", name] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundaryString] dataUsingEncoding:NSUTF8StringEncoding]];

    
//    NSString *string = [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding];
//    NSLog(@"Body is %@", string);
    
    NSURLSessionUploadTask *task = [self uploadTaskWithRequest:mutableRequest fromData:body
                                    success:^(id result, NSURLResponse *response) {
                                        if (completion)
                                        {
                                            completion(nil, nil);
                                        }
                                        
                                    } failure:^(id result, NSURLResponse *response, NSError *error) {
                                        if (completion)
                                        {
                                            completion(nil, error);
                                        }
                                    }];
    

    [task resume];
    
    return task;
}

- (NSURLRequest*)urlRequestForMediaWithName:(NSString*)name
{
    NSString *path = [NSString stringWithFormat:@"/utils/v1/media/files"];
    
    ECSLogVerbose(@"Upload file named %@", name);
    
    NSURL *url = [self URLByAppendingPathComponent:path];
    NSURLRequest *request = [self requestWithMethod:@"GET" URL:url parameters:@{@"name": name} error:nil];
   
    return request;
}

- (NSURLSessionDataTask *)getMediaFileNamesWithCompletion:(void (^)(NSArray *, NSError *))completion;
{
    ECSLogVerbose(@"Get Media File names");
    return [self GET:@"utils/v1/media"
          parameters:nil
             success:^(id result, NSURLResponse *response) {
                 if (completion)
                 {
                     if ([result isKindOfClass:[NSArray class]])
                     {
                         completion(result, nil);
                     }
                     else
                     {
                         completion(nil, nil);
                     }
                 }
             }
             failure:[self failureWithCompletion:completion]];
}


#pragma mark - History
- (NSURLSessionDataTask*)getAnswerEngineHistoryWithCompletion:(void (^)(ECSHistoryList *response, NSError* error))completion
{
    NSString *path = @"/conversationhistory/v1/";
    return [self GET:path
          parameters:@{@"type": @"answers"}
              success:[self successWithExpectedType:[ECSHistoryList class] completion:completion]
                                            failure:[self failureWithCompletion:completion]];
}

- (NSURLSessionDataTask*)getChatHistoryWithCompletion:(void (^)(ECSHistoryList *response, NSError* error))completion
{
    NSString *path = @"/conversationhistory/v2";
    return [self GET:path
          parameters:@{@"type": @"chat"}
             success:[self successWithExpectedType:[ECSHistoryList class] completion:completion]
             failure:[self failureWithCompletion:completion]];
}

- (NSURLSessionDataTask*)getChatHistoryDetailsForJourneyId:(NSString*)journeyId
                                            withCompletion:(void (^)(ECSChatHistoryResponse *response, NSError* error))completion
{
    NSString *path = @"/conversationhistory/v2";
    return [self GET:path
          parameters:@{
                       @"type": @"chat",
                       @"journeyId": journeyId
                       }
             success:[self successWithExpectedType:[ECSChatHistoryResponse class] completion:completion]
             failure:[self failureWithCompletion:completion]];
}




#pragma mark - Common Helpers
- (id)getClassOfType:(Class)aClass withJSON:(id)result {
    if ([result isKindOfClass:[NSDictionary class]]) {
        if ([aClass conformsToProtocol:@protocol(ECSJSONClassTransformer)] ||
            [aClass conformsToProtocol:@protocol(ECSJSONSerializing)]) {
            return [ECSJSONSerializer objectFromJSONDictionary:result withClass:aClass];
        }
    }
    return nil;
}

- (void (^)(id result, NSURLResponse *response))successWithExpectedType:(Class)aClass
                                                             completion:(void (^)(id resultObject, NSError *error))completion
{
    return ^(id result, NSURLResponse *response) {
        ECSLogVerbose(@"API: Success with response %@ and object %@", response, result);
        if (completion)
        {
            if ([result isKindOfClass:[NSDictionary class]])
            {
                // mas - 13-oct-2015 - Check for conforming object beforehand. If not,
                // allow it to be passed back as a regular NSDictionary object. 
                if ([aClass conformsToProtocol:@protocol(ECSJSONClassTransformer)] ||
                    [aClass conformsToProtocol:@protocol(ECSJSONSerializing)]) {
                    id resultObject = [ECSJSONSerializer objectFromJSONDictionary:result
                                                                        withClass:aClass];
                    
                    completion(resultObject, nil);
                }
                else {
                    // Simple JSON NSDictionary
                    //
                    id resultObject = result;
                    completion(resultObject, nil);
                }
                
            }
            else if ([result isKindOfClass:[NSArray class]])
            {
                if([aClass conformsToProtocol:@protocol(ECSJSONClassTransformer)] ||
                   [aClass conformsToProtocol:@protocol(ECSJSONSerializing)])  {
                    id resultObject = [ECSJSONSerializer arrayFromJSONArray:result
                                                                  withClass:aClass];
                    completion(resultObject, nil);
                }
                else  {
                    // Simple JSON Array ["", "", "", ""]
                    //
                    id resultObject = result;
                    completion(resultObject, nil);
                }
            }
            else if ([result isKindOfClass:[NSNumber class]])
            {
                NSNumber *tfbool = (NSNumber *)result;
                NSString *truefalse = @"true";
                
                if([tfbool isEqual:@0]) {
                    truefalse = @"false";
                }
                
                id resultObject = truefalse;
                completion(resultObject, nil);
            }
            else if ([result isKindOfClass:[NSString class]])
            {
                id resultObject = result;
                completion(resultObject, nil);
            }
            else
            {
                completion(nil, nil);
            }
        }
    };
}

- (void (^)(id result, NSURLResponse *response, NSError *error))failureWithCompletion:(void (^)(id resultObject, NSError *error))completion
{
    return ^(id result, NSURLResponse *response, NSError *error) {
        ECSLogVerbose(@"API: Request failure %@ with error %@ and object %@", response, error, result);
        if (completion)
        {
            completion(nil, error);
        }
    };
}

- (NSURL *)URLByAppendingPathComponent:(NSString *)component
{
    return [[self baseURL] URLByAppendingPathComponent:component];
}


- (NSURLSessionDataTask *)GET:(NSString *)path parameters:(id)parameters
                      success:(ECSSessionManagerSuccess)success
                      failure:(ECSSessionManagerFailure)failure
{
    return [self performRequestWithMethod:@"GET" path:path parameters:parameters success:success failure:failure];
}

- (NSURLSessionDataTask *)PUT:(NSString *)path parameters:(id)parameters
                      success:(ECSSessionManagerSuccess)success
                      failure:(ECSSessionManagerFailure)failure
{
    return [self performRequestWithMethod:@"PUT" path:path parameters:parameters success:success failure:failure];
}

- (NSURLSessionDataTask *)POST:(NSString *)path parameters:(id)parameters
                       success:(ECSSessionManagerSuccess)success
                       failure:(ECSSessionManagerFailure)failure
{
    return [self performRequestWithMethod:@"POST" path:path parameters:parameters success:success failure:failure];
}

- (NSURLSessionDataTask *)DELETE:(NSString *)path parameters:(id)parameters
                         success:(ECSSessionManagerSuccess)success
                         failure:(ECSSessionManagerFailure)failure
{
    return [self performRequestWithMethod:@"DELETE" path:path parameters:parameters success:success failure:failure];
}

- (NSURLSessionDataTask *)externalRequestWithMethod:(NSString *)method
                                                     path:(NSString *)path
                                               parameters:(id)parameters
                                                  success:(void(^)(id result, NSURLResponse *response))success
                                                  failure:(void(^)(id result, NSURLResponse *response, NSError *error))failure

{
    NSURL *url = nil;
    
    if ([path hasPrefix:@"http"])
    {
        url = [NSURL URLWithString:path];
    }
    else
    {
        url = [self URLByAppendingPathComponent:path];
    }
    NSURLRequest *request = [self requestWithMethod:method URL:url parameters:parameters error:nil];
    
    ECSLogVerbose(@"%@: %@ \n headers %@\n parameters %@", method, path, request.allHTTPHeaderFields, parameters);
    
    //__weak typeof(self) weakSelf = self;
    
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSError *retError = error;
        
        id result = nil;
        
        if (error == nil)
        {
            result = [[self responseSerializer] responseObjectForResponse:response data:data error:&retError];
            
            // Allow for an empty reponse if the response code was 200.
            if ((((NSHTTPURLResponse*)response).statusCode == 200) && retError.code == 3840)
            {
                retError = nil;
            }
        }
        
        if ((error.code != NSURLErrorCancelled) &&
                 (((NSHTTPURLResponse*)response).statusCode != 200) &&
                 (((NSHTTPURLResponse*)response).statusCode != 201))
        {
            ECSLogVerbose(@"API Error %@", error);
            NSMutableDictionary *userInfo = [NSMutableDictionary new];
            
            if ([result isKindOfClass:[NSDictionary class]])
            {
                if (result[@"error"])
                {
                    userInfo[NSLocalizedFailureReasonErrorKey] = result[@"error"];
                }
                
                if (result[@"message"])
                {
                    userInfo[NSLocalizedDescriptionKey] = result[@"message"];
                }
            }
            
            retError = [NSError errorWithDomain:@"com.humanify" code:-1 userInfo:userInfo];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (retError == nil)
            {
                success(result, response);
            }
            else
            {
                failure(result, response, retError);
            }
        });
    }];
    
    [task resume];
    
    return task;
}

/* NO JSON SERIALIZATION!! */
- (NSURLSessionDataTask *)externalStringRequestWithMethod:(NSString *)method
                                               path:(NSString *)path
                                         parameters:(id)parameters
                                            success:(void(^)(NSURLResponse *response, NSString *data))success
                                            failure:(void(^)(NSURLResponse *response, NSError *error))failure

{
    NSURL *url = nil;
    
    if ([path hasPrefix:@"http"])
    {
        url = [NSURL URLWithString:path];
    }
    else
    {
        url = [self URLByAppendingPathComponent:path];
    }
    NSURLRequest *request = [self requestWithMethod:method URL:url parameters:parameters error:nil];
    
    ECSLogVerbose(@"%@: %@ \n headers %@\n parameters %@", method, path, request.allHTTPHeaderFields, parameters);

    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error == nil)
            {
                NSString *stringData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                success(response, stringData);
            }
            else
            {
                failure(response, error);
            }
        });
    }];
    
    [task resume];
    
    return task;
}

- (NSURLSessionDataTask *)performRequestWithMethod:(NSString *)method
                                              path:(NSString *)path
                                        parameters:(id)parameters
                                           success:(ECSSessionManagerSuccess)success
                                           failure:(ECSSessionManagerFailure)failure
{
    
    
    NSURL *url = nil;
    
    if ([path hasPrefix:@"http"])
    {
        url = [NSURL URLWithString:path];
    }
    else
    {
        url = [self URLByAppendingPathComponent:path];
    }
    NSURLRequest *request = [self requestWithMethod:method URL:url parameters:parameters error:nil];
    
    ECSLogVerbose(@"%@: %@ \n headers %@\n parameters %@", method, path, request.allHTTPHeaderFields, parameters);
    NSURLSessionDataTask *task = [self dataTaskWithRequest:request
                                                   success:success failure:failure];
    [task resume];
    
    return task;
}

- (NSURLSessionTask *)authenticateAPIAndContinueCallWithRequest:(NSURLRequest *)request
                                                            success:(ECSSessionManagerSuccess)success
                                                            failure:(ECSSessionManagerFailure)failure
{
    __weak typeof(self) weakSelf = self;
    ECSConfiguration *configuration = [[ECSInjector defaultInjector] objectForClass:[ECSConfiguration class]];
    
    if (configuration.clientID.length == 0) {
        NSError *err = [[NSError alloc] initWithDomain:@"ClientID/Secret or userIdentityToken must be provided."
                                                  code:-2000
                                              userInfo:nil];
        ECSLogError(@"Error: %@", err);
        return nil;
    }
    
    ECSLogVerbose(@"Authenticating with server. ClientID=%@. Host=%@", configuration.clientID, configuration.host);
    return [self authenticateAPIWithClientID:configuration.clientID andSecret:configuration.clientSecret completion:^(NSString *authToken, NSError *error) {
        if (!error && authToken)
        {
            ECSLogVerbose(@"Authentication successful");
            NSMutableURLRequest *mutableRequest = [request mutableCopy];
            [self setCommonHTTPHeadersForRequest:mutableRequest];
            NSURLSessionTask *task = [weakSelf dataTaskWithRequest:mutableRequest allowAuthorization:NO success:success failure:failure];
            [task resume];
        }
        else
        {
            ECSLogVerbose(@"Authentication failed.");
        }
    }];
}

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                           allowAuthorization:(BOOL)allowAuthorization
                                      success:(ECSSessionManagerSuccess)success
                                      failure:(ECSSessionManagerFailure)failure
{
    __weak typeof(self) weakSelf = self;

    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSError *retError = error;
        
        id result = nil;
        BOOL retryingWithAuthorization = NO;
        
        if (error == nil)
        {
            result = [[self responseSerializer] responseObjectForResponse:response data:data error:&retError];
            
            // Allow for an empty reponse if the response code was 200.
            if ((((NSHTTPURLResponse*)response).statusCode == 200) && retError.code == 3840)
            {
                retError = nil;
            }
        }
        
        if (allowAuthorization && (((NSHTTPURLResponse*)response).statusCode == 401) )
        {
            ECSLogVerbose(@"Authentication error. Attempting to generate new key..."); 
            [weakSelf authenticateAPIAndContinueCallWithRequest:request success:success failure:failure];
            retryingWithAuthorization = YES;
        }
        else if ((error.code != NSURLErrorCancelled) &&
                 (((NSHTTPURLResponse*)response).statusCode != 200) &&
                 (((NSHTTPURLResponse*)response).statusCode != 201))
        {
            if (error) {
                ECSLogVerbose(@"API Error: %@", error);
            }
            
            NSMutableDictionary *userInfo = [NSMutableDictionary new];
            
            if ([result isKindOfClass:[NSDictionary class]])
            {
                if (result[@"error"])
                {
                    userInfo[NSLocalizedFailureReasonErrorKey] = result[@"error"];
                }
                
                if (result[@"message"])
                {
                    userInfo[NSLocalizedDescriptionKey] = result[@"message"];
                }
            }
            
            retError = [NSError errorWithDomain:@"com.humanify" code:-1 userInfo:userInfo];
        }
        
        // Only return if we are not trying to reauthenticate with the API.
        if (!retryingWithAuthorization)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (retError == nil)
                {
                    success(result, response);
                }
                else
                {
                    failure(result, response, retError);
                }
            });
        }
    }];
    
    return task;
}

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                                      success:(ECSSessionManagerSuccess)success
                                      failure:(ECSSessionManagerFailure)failure
{
    return [self dataTaskWithRequest:request allowAuthorization:YES success:success failure:failure];
}

- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request
                                         fromData:(NSData *)bodyData
                                          success:(ECSSessionManagerSuccess)success
                                          failure:(ECSSessionManagerFailure)failure
{
    NSURLSessionUploadTask *task = [self.session uploadTaskWithRequest:request fromData:bodyData completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSError *retError = error;
        id result = nil;
        
        if ((error.code != NSURLErrorCancelled) && (((NSHTTPURLResponse*)response).statusCode != 200) && (((NSHTTPURLResponse*)response).statusCode != 201))
        {
            NSMutableDictionary *userInfo = [NSMutableDictionary new];
            
            if ([result isKindOfClass:[NSDictionary class]])
            {
                if (result[@"error"])
                {
                    userInfo[NSLocalizedFailureReasonErrorKey] = result[@"error"];
                }
                
                if (result[@"message"])
                {
                    userInfo[NSLocalizedDescriptionKey] = result[@"message"];
                }
            }
            
            retError = [NSError errorWithDomain:@"com.humanify" code:((NSHTTPURLResponse*)response).statusCode userInfo:userInfo];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (retError == nil)
            {
                success(result, response);
            }
            else
            {
                failure(result, response, retError);
            }
        });
    }];
    
    return task;
}


- (NSURLSessionDownloadTask *)downloadTaskWithRequest:(NSURLRequest *)request session:(NSURLSession *)session {
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request];
    return downloadTask;
}

- (NSURLSessionDownloadTask *)downloadTaskWithRequest:(NSURLRequest *)request {
    NSURLSessionDownloadTask *downloadTask = [self.session downloadTaskWithRequest:request];
    return downloadTask;
}

- (void)setCommonHTTPHeadersForRequest:(NSMutableURLRequest*)mutableRequest
{
    ECSConfiguration *configuration = [[ECSInjector defaultInjector] objectForClass:[ECSConfiguration class]];
    ECSUserManager *userManager = [[ECSInjector defaultInjector] objectForClass:[ECSUserManager class]];
    
    if (self.authToken.length > 0)
    {
        NSString *authValue = self.authToken;
        if(self.authToken.length == 36) // 36 digits is the length of Humanify's bearer tokens
        {
            authValue = [NSString stringWithFormat:@"Bearer %@", self.authToken];
        }
        [mutableRequest setValue:authValue forHTTPHeaderField:@"Authorization"];
    }
    
    if (userManager.userToken.length > 0)
    {
        [mutableRequest setValue:userManager.userToken forHTTPHeaderField:@"x-ia-userid"];
    }
    
    if (userManager.deviceID.length > 0)
    {
        [mutableRequest setValue:userManager.deviceID forHTTPHeaderField:@"x-ia-deviceuuid"];
    }
    
    if (configuration.appName.length > 0)
    {
        [mutableRequest setValue:configuration.appName forHTTPHeaderField:@"x-ia-appname"];
    }
    
    if (configuration.appVersion.length > 0)
    {
        [mutableRequest setValue:configuration.appVersion forHTTPHeaderField:@"x-ia-appversion"];
    }
    
    if (self.conversation && self.conversation.conversationID.length > 0)
    {
        [mutableRequest setValue:self.conversation.conversationID forHTTPHeaderField:@"x-ia-conversation-id"];
    }
    
    // mas - 20-oct-2015 - First, try to grab journeyID from the global area. If not found, we may have one in the
    // conversation, use that instead.
    if ([EXPERTconnect shared].journeyID && [EXPERTconnect shared].journeyID.length > 0)
    {
        [mutableRequest setValue:[EXPERTconnect shared].journeyID forHTTPHeaderField:@"x-ia-journey-id"];
    }
    else if (self.conversation && self.conversation.journeyID.length > 0)
    {
        [mutableRequest setValue:self.conversation.journeyID forHTTPHeaderField:@"x-ia-journey-id"];
    }

    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSString *locale = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    
    NSString *languageLocale = [NSString stringWithFormat:@"%@_%@", language, locale];
   
    [mutableRequest setValue:languageLocale forHTTPHeaderField:@"x-ia-locale"];

}

- (NSURLRequest *)requestWithMethod:(NSString *)method
                                URL:(NSURL *)url
                         parameters:(id)parameters
                              error:(NSError **)error
{
    NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:url];
    [mutableRequest setHTTPMethod:method];
    [self setCommonHTTPHeadersForRequest:mutableRequest];
    NSURLRequest *request = [[self requestSerializer] requestBySerializingRequest:mutableRequest
                                                                       parameters:parameters
                                                                            error:error];
    return request;
}

- (NSString *) getJourneyID {
    
    if ([EXPERTconnect shared].journeyID && [EXPERTconnect shared].journeyID.length > 0)
    {
        return [EXPERTconnect shared].journeyID;
    }
    else if (self.conversation && self.conversation.journeyID.length > 0)
    {
        return self.conversation.journeyID;
    }
    return @"-1";
}

- (NSString *) getConversationID {
    
    if (self.conversation && self.conversation.conversationID.length > 0)
        return self.conversation.conversationID;
    return @"-1";
    
}

- (NSURLSessionDataTask *)breadcrumbsAction:(id)actionJson
                                 completion:(void (^)(NSDictionary *decisionResponse, NSError *error))completion;
{
    
    return [self POST:@"breadcrumb/v1/actions/bulk"
           parameters:actionJson
              success:[self successWithExpectedType:[NSDictionary class] completion:completion]
              failure:[self failureWithCompletion:completion]];
    
}

- (NSURLSessionDataTask *)breadcrumbsSession:(id)actionJson
                                  completion:(void (^)(NSDictionary *decisionResponse, NSError *error))completion;
{
    return [self POST:@"breadcrumb/v1/sessions"
           parameters:actionJson
              success:[self successWithExpectedType:[NSDictionary class] completion:completion]
              failure:[self failureWithCompletion:completion]];
}

@end
