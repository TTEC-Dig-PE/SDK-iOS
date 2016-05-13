//
//  ECS_DceDev_Henry_Tests.m
//  EXPERTconnect
//
//  Created by Michael Schmoyer on 4/11/16.
//  Copyright © 2016 Humanify, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <EXPERTconnect/EXPERTconnect.h>
#import "ECSConversationCreateResponse.h"

@interface ECS_DceDev_Henry_Tests : XCTestCase <ECSAuthenticationTokenDelegate>

@end

@implementation ECS_DceDev_Henry_Tests

NSURL *_testAuthURL;
NSString *_testTenant;

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)initSDK {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    ECSConfiguration *configuration = [ECSConfiguration new];
    
    configuration.appName       = @"EXPERTconnect UnitTester";
    configuration.appVersion    = @"1.0";
    configuration.appId         = @"12345";
    
    configuration.host          = @"https://api.dce1.humanify.com";
    //configuration.clientID      = @"mktwebextc";
    //configuration.clientSecret  = @"secret123";
    
    [[EXPERTconnect shared] initializeWithConfiguration:configuration];
    //[[EXPERTconnect shared] initializeVideoComponents]; // CafeX initialization.
    
    _testTenant = @"henry";
    // A GOOD auth URL
    _testAuthURL = [[NSURL alloc] initWithString:
                    [NSString stringWithFormat:@"https://api.dce1.humanify.com/authServerProxy/v1/tokens/ust?username=%@&client_id=%@",
                     @"expertconnect_unit_test",
                     _testTenant]];
    [[EXPERTconnect shared] setAuthenticationTokenDelegate:self];
    
    [[EXPERTconnect shared] setDebugLevel:5];
}

-(void) fetchAuthenticationToken:(void (^)(NSString *, NSError *))completion {
    // add /ust for new method
    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:_testAuthURL]
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         
         long statusCode = (long)((NSHTTPURLResponse*)response).statusCode;
         NSString *returnToken = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
         
         if(!error && (statusCode == 200 || statusCode == 201))
         {
             NSLog(@"Successfully fetched authToken: %@", returnToken);
             completion([NSString stringWithFormat:@"%@", returnToken], nil);
         }
         else
         {
             NSError *myError = [NSError errorWithDomain:@"com.humanify"
                                                    code:statusCode
                                                userInfo:[NSDictionary dictionaryWithObject:returnToken forKey:@"errorJson"]];
             completion(nil, myError);
         }
     }];
}




- (void)testAstute {
    [self initSDK];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"getExperts"];
    ECSURLSessionManager* sessionManager = [[EXPERTconnect shared] urlSession];
    
    // Start a new journey
    [[EXPERTconnect shared] startJourneyWithCompletion:^(NSString *journeyID, NSError *error)
     {
         XCTAssert(journeyID.length>0,@"Response contains a journeyID");
         XCTAssert(!error, @"Response does not contain an error");
         
         // Same as high level answer engine, start a conversation.
         ECSActionType *actionType = [[ECSActionType alloc] init];
         actionType.type = @"answerengine";
         
         [sessionManager startConversationForAction:actionType
                                    andAlwaysCreate:YES
                                     withCompletion:^(ECSConversationCreateResponse *response, NSError *error)
          {
              XCTAssert(response.journeyID.length>0,@"Response contains a journeyID");
              XCTAssert(response.conversationID.length>0,@"Response has a conversationID");
              XCTAssert(response.channelLink.length>0,@"Response has a channelLink");
              XCTAssert(!error, @"Response does not contain an error");
              
              // Simulate a type-ahead search on word "parking"
              [sessionManager getAnswerEngineTopQuestionsForKeyword:@"parking"
                                                withOptionalContext:@"all"
                                                         completion:^(ECSAnswerEngineResponse *response, NSError *error)
               {
                   XCTAssert(response.suggestedQuestions.count>0,@"Returned some suggested questions.");
                   XCTAssert(!error, @"Response does not contain an error");
                   
                   // Simulate asking for an answer for a specific article.
                   [sessionManager getAnswerForQuestion:@"Focus Electric Vehicle"
                                              inContext:@"Park"
                                        parentNavigator:@""
                                               actionId:@""
                                          questionCount:1
                                             customData:nil
                                             completion:^(ECSAnswerEngineResponse *response, NSError *error)
                    {
                        
                        XCTAssert(response.answer.length > 0 || response.answerContent.length > 0, @"Response has answer engine content.");
                        XCTAssert(response.inquiryId>0,@"Response has inquiryID");
                        XCTAssert(!error, @"Response does not contain an error");
                        
                        // Happy path finished.
                        [expectation fulfill];
                    }];
               }];
          }];
     }];
    
    [self waitForExpectationsWithTimeout:25.0 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Timeout error (25 seconds). Error=%@", error);
        }
    }];
}


@end
