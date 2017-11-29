//
//  ECS_API_Tests.m
//  EXPERTconnect
//
//  Created by Michael Schmoyer on 6/1/16.
//  Copyright © 2016 Humanify, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <EXPERTconnect/EXPERTconnect.h>
#import <EXPERTconnect/ECSNavigationContext.h>
#import <EXPERTconnect/ECSAnswerEngineResponse.h>
#import <EXPERTconnect/ECSUserProfile.h>
#import <EXPERTconnect/ECSFormItem.h>
#import <EXPERTconnect/ECSMediaInfoHelpers.h>
#import <EXPERTconnect/ECSInjector.h>
#import <EXPERTconnect/ECSTheme.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIImage+ECSBundle.h"
#import "ECSHistoryList.h"
#import "ECSChatHistoryResponse.h"
#import "ECSHistoryListItem.h"
#import "ECSConversationCreateResponse.h"
#import "ECSCafeXController.h"

@interface ECS_API_Tests : XCTestCase <ECSAuthenticationTokenDelegate> {
    NSURL *_testAuthURL;
    NSString *_testTenant;
    NSString *_username;
    NSString *_fullname;
    NSString *_firstname;
}

@end

@implementation ECS_API_Tests

- (void)initSDKwithEnvironment:(NSString *)env organization:(NSString *)org {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    ECSConfiguration *configuration = [ECSConfiguration new];
    
    configuration.appName       = @"EXPERTconnect UnitTester";
    configuration.appVersion    = @"1.0";
    configuration.appId         = @"12345";
    
    configuration.host          = [NSString stringWithFormat:@"https://api.%@.humanify.com", env];
    
    configuration.defaultAnswerEngineContext = @"1004791351";
    
    [[EXPERTconnect shared] initializeWithConfiguration:configuration];
    //[[EXPERTconnect shared] initializeVideoComponents]; // CafeX initialization.
    _username = @"yasar.arafath@agiliztech.com";
    _fullname = @"yasar yasar";
    _firstname = @"yasar";
    
    if(!_testTenant) _testTenant = @"mktwebextc_test";
    // A GOOD auth URL
    _testAuthURL = [[NSURL alloc] initWithString:
                    [NSString stringWithFormat:@"%@/authServerProxy/v1/tokens/ust?username=%@&client_id=%@",
                     configuration.host,
                     @"yasar.arafath@agiliztech.com",
                     org]];
    
    [[EXPERTconnect shared] setAuthenticationTokenDelegate:self];
    
    [[EXPERTconnect shared] setDebugLevel:5];
    [[EXPERTconnect shared] overrideDeviceLocale:@"en-US"];
    
    
    [[EXPERTconnect shared] setLoggingCallback:^(ECSLogLevel level, NSString *message) {
        NSString *levelString = ^NSString *() {
            switch (level)
            {
                case ECSLogLevelError:
                    return @"Error";
                case ECSLogLevelWarning:
                    return @"Warning";
                case ECSLogLevelDebug:
                    return @"Debug";
                case ECSLogLevelVerbose:
                    return @"Info";
                case ECSLogLevelNone:
                    return @"None";
            }
        }();
        
        NSLog(@"[iOS SDK]: (%@): %@", levelString, message);
    }];
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
             //NSLog(@"Successfully fetched authToken: %@", returnToken);
             completion([NSString stringWithFormat:@"%@", returnToken], nil);
         }
         else
         {
             completion(nil, error);
         }
     }];
}

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

/**
 NOTE: This test is failing in v5.4. Config required on server. @kenwashington is contact for information.
 */
- (void)testMakeDecision {
    
    [self setUp];
    
    _testTenant = @"henry";
    [self initSDKwithEnvironment:@"tce1" organization:@"mktwebextc_test"];
    
    ECSURLSessionManager *session = [[EXPERTconnect shared] urlSession];
    XCTestExpectation *expectation = [self expectationWithDescription:@"testMakeDecision"]; // Define a new expectation
    
    // TODO: Change to "validateDE"
    NSMutableDictionary *decisionDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                               @"henry",@"name",
                                               @"henryRule",@"projectServiceName",
                                               @"determineRule",@"eventId",
                                               @"henry",@"ceTenant",
                                               @"EN",@"userLanguage",
                                               @"US",@"userCountry",
                                               @"My Vehicles",@"service",
                                               @"mktwebextc",@"clientRequestId",
                                               @"current local page",@"function",
                                               nil];
    
    [session makeDecision:decisionDictionary
               completion:^(NSDictionary *response, NSError *error)
     {
         XCTAssert(!error,@"API call had an error.");
         
         NSLog(@"Response JSON = %@", response);
         
         XCTAssert([response[@"eventId"] isEqualToString:@"determineRule"], @"Expected eventId matching input.");
         
         [expectation fulfill]; // Tell the loop to stop waiting - test is finished.
     }];
    
    // Goes at bottom of test function
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Timeout error (15 seconds). Error=%@", error);
        }
    }];
}

/*- (void)testGetDetailsForSkill {
 
 [self setUp];   // Test setup
 [self initSDK]; // SDK setup
 
 XCTestExpectation *expectation = [self expectationWithDescription:@"getDetailsForSkill"];
 
 NSString *skillName = @"CE_Mobile_Chat";
 
 // Should throw a deprecation warning but still work against 5.3 and later (until officially deprecated).
 [[EXPERTconnect shared] getDetailsForSkill:skillName
 completion:^(NSDictionary *details, NSError *error)
 {
 
 NSLog(@"Details: %@", details);
 if(error) XCTFail(@"Error: %@", error.description);
 
 // Check each of the JSON response fields to make sure they are there.
 XCTAssert(details[@"chatEnabledAgentsLoggedOn"],@"Missing chatEnabledAgentsLoggedOn field.");
 XCTAssert(details[@"estimatedWait"],@"Missing estimatedWait field.");
 XCTAssert(details[@"inQueue"],@"Missing inQueue field.");
 XCTAssert(details[@"escalationVoiceAvailability"],@"Missing escalationVoiceAvailability field.");
 XCTAssert(details[@"escalationChatAvailability"],@"Missing escalationChatAvailability field.");
 XCTAssert(details[@"voiceAvailability"],@"Missing voiceAvailability field.");
 XCTAssert(details[@"chatAvailability"],@"Missing chatAvailability field.");
 XCTAssert(details[@"escalationSkill"],@"Missing escalationSkill field.");
 XCTAssert(details[@"escalationAgentsLoggedOn"],@"Missing escalationAgentsLoggedOn field.");
 XCTAssert(details[@"connectedToAgent"],@"Missing connectedToAgent field.");
 XCTAssert(details[@"escalationSkillOpen"],@"Missing escalationSkillOpen field.");
 XCTAssert(details[@"escalationChatEnabledAgentsLoggedOn"],@"Missing escalationChatEnabledAgentsLoggedOn field.");
 XCTAssert(details[@"tenant"],@"Missing tenant field.");
 XCTAssert(details[@"skillName"],@"Missing skillName field.");
 XCTAssert(details[@"agentsLoggedOn"],@"Missing agentsLoggedOn field.");
 XCTAssert(details[@"open"],@"Missing open field.");
 XCTAssert(details[@"_links"],@"Missing _links field.");
 
 XCTAssert([details[@"skillName"] isEqualToString:skillName], @"skillName does not match.");
 
 [expectation fulfill];
 }];
 
 [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
 if (error) {
 XCTFail(@"Timeout error (15 seconds). Error=%@", error);
 }
 }];
 }*/

- (void)testGetDetailsForExpertSkill {
    
    [self setUp];
    [self initSDKwithEnvironment:@"dce1" organization:@"mktwebextc"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"getDetailsForSkill"];
    
    NSString *skillName = @"CE_Mobile_Chat";
    
    // TEST #1 - Testing a valid skill
    [[EXPERTconnect shared] getDetailsForExpertSkill:skillName
                                          completion:^(ECSSkillDetail *details, NSError *error)
     {
         NSLog(@"Details: %@", details);
         if(error) XCTFail(@"Error: %@", error.description);
         
         // Specific Tests
         XCTAssert(details.description.length>0, @"Missing description text.");
         XCTAssert(details.active == 1 || details.active == 0, @"Active must be 1 or 0");
         XCTAssert([details.skillName containsString:skillName], @"Missing skill name");
         XCTAssertGreaterThanOrEqual(details.estWait, -1, @"Bad estimated wait value");
         
         // TEST #2 - NULL input value
         [[EXPERTconnect shared] getDetailsForExpertSkill:nil
                                               completion:^(ECSSkillDetail *details, NSError *error)
          {
              NSLog(@"Details: %@", details);
              
              XCTAssert([error.userInfo[@"NSLocalizedFailureReason"] isEqualToString:@"experts.error.failedRetrievingExpertSkill"],
                        @"Expected failed retrieving expert skill error");
              XCTAssert([error.userInfo[@"NSLocalizedDescription"] isEqualToString:@"404 Not Found"],
                        @"Expected 404 not found.");
              XCTAssert(error, @"Expected an error");
              
              [expectation fulfill];
          }];
     }];
    
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Timeout error (15 seconds). Error=%@", error);
        }
    }];
}

// TODO: IS this obsolete?
- (void)testGetNavigationContextWithName
{
    [self setUp];
    [self initSDKwithEnvironment:@"tce1" organization:@"mktwebextc_test"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"testGetNavigationContextWithName"];
    
    ECSURLSessionManager *sessionManager = [[EXPERTconnect shared] urlSession];
    
    [sessionManager getNavigationContextWithName:@"personas"
                                      completion:^(ECSNavigationContext *context,NSError *error)
     {
         NSLog(@"Details: %@", context);
         if(error) XCTFail(@"Error: %@", error.description);
         
         [expectation fulfill];
     }];
    
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Timeout error (15 seconds). Error=%@", error);
        }
    }];
}

//Get Answer Engine Top Quetions without Context
- (void)testGetAnswerEngineTopQuestions
{
    [self setUp];   // Test setup
    [self initSDKwithEnvironment:@"tce1" organization:@"mktwebextc_test"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"testGetAnswerEngineTopQuestions"];
    
    ECSURLSessionManager *sessionManager = [[EXPERTconnect shared] urlSession];
    
    // Test 1: Test the API with an expected count of 2 results.
    [sessionManager getAnswerEngineTopQuestions:2
                                 withCompletion:^(NSArray *answers, NSError *error)
     {
         if(error) XCTFail(@"Error: %@", error.description);
         XCTAssert(answers.count == 2, @"Expected 2 answers in ALL context.");
         
         // Test 2: Failure case - input of 0.
         [sessionManager getAnswerEngineTopQuestions:0
                                      withCompletion:^(NSArray *answers, NSError *error)
          {
              XCTAssert([error.userInfo[@"NSLocalizedFailureReason"] isEqualToString:@"Bad Request"],
                        @"Expected bad request.");
              XCTAssert([error.userInfo[@"NSLocalizedDescription"] isEqualToString:@"Required int parameter 'num' is not present"],
                        @"Expected required param num missing error.");
              XCTAssert(error, @"Expected an error");
              [expectation fulfill];
          }];
         
     }];
    
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Timeout error (15 seconds). Error=%@", error);
        }
    }];
}

//Get Answer Engine Top Quetions with Context
- (void)testGetAnswerEngineTopQuestionsWithContext
{
    [self setUp];   // Test setup
    [self initSDKwithEnvironment:@"tce1" organization:@"mktwebextc_test"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"testGetAnswerEngineTopQuestionsWithContext"];
    
    ECSURLSessionManager *sessionManager = [[EXPERTconnect shared] urlSession];
    
    // Test 1: Test the API with an expected count of 2 results
    // answerengine/v1/questions?num=X&context=Y
    [sessionManager getAnswerEngineTopQuestions:2
                                     forContext:@"Park"
                                 withCompletion:^(NSArray *answers, NSError *error)
     {
         NSLog(@"Details: %@", answers);
         if(error) XCTFail(@"Error: %@", error.description);
         
         // Specific tests here.
         XCTAssert(answers.count==2,@"Expecting 2 results.");
         
         // Test 2: Missing context case.
         [sessionManager getAnswerEngineTopQuestions:2
                                          forContext:nil
                                      withCompletion:^(NSArray *answers, NSError *error)
          {
              XCTAssert([error.userInfo[@"NSLocalizedFailureReason"] isEqualToString:@"Input parameter 'context' required."],
                        @"Expected bad request.");
              XCTAssert(error.code==ECS_ERROR_MISSING_PARAM,@"Expected SDK error 1002");
              XCTAssert(error, @"Expected an error");
              
              [expectation fulfill];
          }];
     }];
    
    [self waitForExpectationsWithTimeout:60.0 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Timeout error (15 seconds). Error=%@", error);
        }
    }];
}

- (void)testStartAnswerEngineWithTopQuestions
{
    [self setUp];
    [self initSDKwithEnvironment:@"tce1" organization:@"mktwebextc_test"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"testGetAnswerEngineTopQuestions"];
    
    ECSURLSessionManager *sessionManager = [[EXPERTconnect shared] urlSession];
    
    [sessionManager startAnswerEngineWithTopQuestions:2
                                           forContext:@"Park"
                                       withCompletion:^(NSArray *answers, NSError *error)
     {
         NSLog(@"Details: %@", answers);
         if(error) XCTFail(@"Error: %@", error.description);
         
         // Specific tests here.
         XCTAssert(answers.count==2,@"Expecting 2 results.");
         
         [sessionManager startAnswerEngineWithTopQuestions:2
                                                forContext:nil
                                            withCompletion:^(NSArray *answers, NSError *error)
          {
              XCTAssert([error.userInfo[@"NSLocalizedFailureReason"] isEqualToString:@"Input parameter 'context' required."],
                        @"Expected bad request.");
              XCTAssert(error.code==ECS_ERROR_MISSING_PARAM,@"Expected SDK error");
              XCTAssert(error, @"Expected an error");
              [expectation fulfill];
          }];
     }];
    
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Timeout error (15 seconds). Error=%@", error);
        }
    }];
}

// This is testing our typeahead function.
- (void)testGetAnswerEngineTopQuestionsForKeyword
{
    [self setUp];
    [self initSDKwithEnvironment:@"tce1" organization:@"mktwebextc_test"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"testGetAnswerEngineTopQuestionsForKeyword"];
    
    ECSURLSessionManager *sessionManager = [[EXPERTconnect shared] urlSession];
    
    // Test 1: A question expecting a real answer
    [sessionManager getAnswerEngineTopQuestionsForKeyword:@"parking"
                                      withOptionalContext:@"Park"
                                               completion:^(ECSAnswerEngineResponse *response, NSError *error)
     {
         NSLog(@"Details: %@", response);
         if(error) XCTFail(@"Error: %@", error.description);
         
         XCTAssert(response.suggestedQuestions.count > 0, @"Expected some suggested questions.");
         
         // Test 2: A bogus question expecting no answer
         [sessionManager getAnswerEngineTopQuestionsForKeyword:@"Non-Valid-Answer-Schmo"
                                           withOptionalContext:@"Park"
                                                    completion:^(ECSAnswerEngineResponse *response, NSError *error)
          {
              NSLog(@"Details: %@", response);
              if(error) XCTFail(@"Error: %@", error.description);
              
              //Specific Tests
              XCTAssert([response.answer isEqualToString:@"ANSWER_ENGINE_NO_ANSWER"], "Expected invalid question");
              XCTAssert(!response.answerContent,@"Expected empty content.");
              XCTAssert(response.inquiryId.length==0,@"Expected missing inquiryID");
              XCTAssert([response.answersQuestion intValue] != 1, @"Expected to not answer question.");
              XCTAssert(response.suggestedQuestions.count == 0, @"Expected no suggested content.");
              
              // Test 3: NULL Values
              [sessionManager getAnswerEngineTopQuestionsForKeyword:nil
                                                withOptionalContext:nil
                                                         completion:^(ECSAnswerEngineResponse *response, NSError *error)
               {
                   XCTAssert([error.userInfo[@"NSLocalizedFailureReason"] isEqualToString:@"Keyword parameter must be 3 or more characters."],
                             @"Expected 3 or more keyword length error.");
                   XCTAssert(error.code==1002, @"Expected SDK error 1002");
                   XCTAssert(error, @"Expected an error");
                   
                   [expectation fulfill];
               }];
          }];
     }];
    
    [self waitForExpectationsWithTimeout:30.0 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Timeout error (15 seconds). Error=%@", error);
        }
    }];
}

- (void)testGetAnswerForQuestion
{
    [self setUp];
    [self initSDKwithEnvironment:@"tce1" organization:@"mktwebextc_test"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"testGetAnswerForQuestion"];
    
    ECSURLSessionManager *sessionManager = [[EXPERTconnect shared] urlSession];
    
    // Test good question
    [sessionManager getAnswerForQuestion:@"Remote Start"
                               inContext:@"sdk_unit_test"
                              customData:nil
                              completion:^(ECSAnswerEngineResponse *response, NSError *error)
     {
         NSLog(@"Details: %@", response);
         if(error) XCTFail(@"Error: %@", error.description);
         
         //Specific Tests
         XCTAssert(response.answer.length > 0,@"Expected answer content.");
         XCTAssert(response.inquiryId > 0,@"Expected positive InquiryID value.");
         XCTAssert([response.answersQuestion intValue] == 1, @"Expected answersQuestion=1.");
         // answerContent, suggestedQuestions, and actions could be Nil or populated
         
         // Test 2: Nil values.
         [sessionManager getAnswerForQuestion:nil
                                    inContext:nil
                                   customData:nil
                                   completion:^(ECSAnswerEngineResponse *response, NSError *error)
          {
              XCTAssert(error.domain==ECSErrorDomain,@"Expected Humanify error.");
              XCTAssert(error.code==ECS_ERROR_MISSING_PARAM, @"Expected SDK error");
              XCTAssert(error, @"Expected an error");
              
              [expectation fulfill];
          }];
     }];
    
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Timeout error (15 seconds). Error=%@", error);
        }
    }];
}

- (void)testGetAnswerForQuestion_MissingAnswer
{
    [self setUp];
    [self initSDKwithEnvironment:@"tce1" organization:@"mktwebextc_test"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"testGetAnswerForQuestion_MissingAnswer"];
    
    ECSURLSessionManager *sessionManager = [[EXPERTconnect shared] urlSession];
    
    // Test invalid question
    [sessionManager getAnswerForQuestion:@"asdf"
                               inContext:@"asdf"
                         parentNavigator:@""
                                actionId:@""
                           questionCount:1
                              customData:nil
                              completion:^(ECSAnswerEngineResponse *response, NSError *error)
     {
         //NSLog(@"Response=%@", response);
         XCTAssert(!error,@"API call returned error.");
         if(error)NSLog(@"Error=%@", error);
         //XCTAssert(response.answer.length > 0 || response.answerContent.length > 0, @"Response has answer engine content.");
         //XCTAssert(response.inquiryId>0,@"Response has inquiryID");
         
         [expectation fulfill];
     }];
    
    
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Timeout error (15 seconds). Error=%@", error);
        }
    }];
}

- (void)testGetAnswerForQuestion2
{
    [self setUp];
    [self initSDKwithEnvironment:@"tce1" organization:@"mktwebextc_test"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"getAnswerForQuestion2"];
    
    ECSURLSessionManager *sessionManager = [[EXPERTconnect shared] urlSession];
    
    [sessionManager getAnswerForQuestion:@"How Does Borrow Work?"
                               inContext:@""
                         parentNavigator:@""
                                actionId:@""
                           questionCount:0
                              customData:nil
                              completion:^(ECSAnswerEngineResponse *response, NSError *error)
     {
         NSLog(@"Details: %@", response);
         if(error) XCTFail(@"Error: %@", error.description);
         
         //Specific Tests
         XCTAssert(response.answer.length > 0,@"Expected answer content.");
         XCTAssert(response.inquiryId > 0,@"Expected positive InquiryID value.");
         XCTAssert([response.answersQuestion intValue] == 1, @"Expected answersQuestion=1.");
         // answerContent, suggestedQuestions, and actions could be Nil or populated
         
         [expectation fulfill];
     }];
    
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Timeout error (15 seconds). Error=%@", error);
        }
    }];
}

- (void)testRateAnswerWithAnswerID
{
    [self setUp];
    [self initSDKwithEnvironment:@"tce1" organization:@"mktwebextc_test"];
    
    ECSURLSessionManager *sm = [[EXPERTconnect shared] urlSession];
    XCTestExpectation *expectation = [self expectationWithDescription:@"testRateResponse"];
    
    // Give a thumbs up rating...
    [sm rateAnswerWithAnswerID:@"146012322420964"
                     inquiryID:@"146012322420964"
                        rating:1
                           min:-1
                           max:1
                 questionCount:1
                    completion:^(ECSAnswerEngineRateResponse *response, NSError *error)
     {
         XCTAssert(response.constrainedRating==5, @"Rating was not converted to max for positive.");
         
         // Give a thumbs down rating...
         [sm rateAnswerWithAnswerID:@"146012322420964"
                          inquiryID:@"146012322420964"
                             rating:-1
                                min:-1
                                max:1
                      questionCount:2
                         completion:^(ECSAnswerEngineRateResponse *response, NSError *error)
          {
              XCTAssert(response.constrainedRating==1, @"Rating was not converted to min for negative.");
              
              // Give a rating right in the middle (1-5, rating=3)
              [sm rateAnswerWithAnswerID:@"146012322420964"
                               inquiryID:@"146012322420964"
                                  rating:3
                                     min:1
                                     max:5
                           questionCount:3
                              completion:^(ECSAnswerEngineRateResponse *response, NSError *error)
               {
                   XCTAssert(response.constrainedRating==3,@"Rating does not reflect answer.");
                   
                   // A bogus rating value (15 is higher than the max)
                   [sm rateAnswerWithAnswerID:@"146012322420964"
                                    inquiryID:@"146012322420964"
                                       rating:15
                                          min:1
                                          max:5
                                questionCount:3
                                   completion:^(ECSAnswerEngineRateResponse *response, NSError *error)
                    {
                        XCTAssert(response.constrainedRating==1, @"Rating was not set to min value due to out of bound.");
                        
                        // A bogus rating value (15 is higher than the max)
                        [sm rateAnswerWithAnswerID:@"146012322420964"
                                         inquiryID:@"146012322420964"
                                            rating:15
                                               min:1
                                               max:5
                                     questionCount:3
                                        completion:^(ECSAnswerEngineRateResponse *response, NSError *error)
                         {
                             XCTAssert(response.constrainedRating==1, @"Rating was not set to min value due to out of bound.");
                             
                             [expectation fulfill];
                         }];
                    }];
               }];
          }];
     }];
    
    // Wait for the above code to finish (15 second timeout)...
    [self waitForExpectationsWithTimeout:30.0 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Timeout error (15 seconds). Error=%@", error);
        }
    }];
}

// TODO: Deprecated? Not necessary in the SDK?
/*- (void)testGetResponseFromEndpoint
 {
 [self setUp];
 [self initSDK];
 XCTestExpectation *expectation = [self expectationWithDescription:@"GetResponseFromEndpoint"];
 
 ECSURLSessionManager *sessionManager = [[EXPERTconnect shared] urlSession];
 
 [sessionManager getResponseFromEndpoint:@"/appconfig/v1/read_rconfig?like=appconfig.mktwebextc.default.answerengine"
 withCompletion:^(NSString *response,NSError *error)
 {
 NSLog(@"Details: %@", response);
 if(error) XCTFail(@"Error: %@", error.description);
 
 
 [expectation fulfill];
 }];
 
 [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
 if (error) {
 XCTFail(@"Timeout error (15 seconds). Error=%@", error);
 }
 }];
 }*/

- (void)testGetUserProfile
{
    [self setUp];   // Test setup
    [self initSDKwithEnvironment:@"tce1" organization:@"mktwebextc_test"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"GetUserProfile"];
    
    ECSURLSessionManager *sessionManager = [[EXPERTconnect shared] urlSession];
    [sessionManager getUserProfileWithCompletion:^(ECSUserProfile *profile, NSError *error)
     {
         NSLog(@"Details: %@", profile);
         
         if(error)
         {
             XCTFail(@"Error reported: %@", error.description);
         }
         else
         {
             XCTAssert(profile.city,@"Missing city field.");
             XCTAssert(profile.username,@"Missing username field.");
             XCTAssert(profile.firstName,@"Missing firstname field.");
             XCTAssert(profile.lastName,@"Missing lastname field.");
             XCTAssert(profile.mobilePhone,@"Missing mobilephone field.");
             XCTAssert(profile.city,@"Missing address field.");
             XCTAssert(profile.state,@"Missing state field.");
             XCTAssert(profile.homePhone,@"Missing homephone field.");
             XCTAssert(profile.alternativeEmail,@"Missing alternativeemail field.");
             XCTAssert(profile.country,@"Missing country field.");
             XCTAssert(profile.postalCode,@"Missing postalcode field.");
             XCTAssert(profile.customData != nil && profile.customData != 0, @"Missing customdata fields");
         }
         [expectation fulfill];
     }];
    
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Timeout error (15 seconds). Error=%@", error);
        }
    }];
}

- (void)testSubmitUserProfile
{
    [self setUp];   // Test setup
    [self initSDKwithEnvironment:@"tce1" organization:@"mktwebextc_test"];
    
    NSString *testString = @"test";
    NSError *error = nil;
    NSData *jsonData = [testString dataUsingEncoding:NSUTF8StringEncoding];
    
    ECSUserProfile * profile = [ECSUserProfile new];
    
    profile.firstName = @"yasar";
    profile.lastName = @"yasar";
    profile.username = @"yasar.arafath@agiliztech.com";
    profile.city = @"Chennai";
    profile.state = @"Tamil Nadu";
    profile.postalCode = @"600028";
    profile.country = @"";
    profile.homePhone = @"8870071996";
    profile.mobilePhone = @"";
    profile.alternativeEmail = @"";
    profile.customData = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"testSubmitUserProfile"];
    
    ECSURLSessionManager *sessionManager = [[EXPERTconnect shared] urlSession];
    [sessionManager submitUserProfile:profile withCompletion:^(NSDictionary *response, NSError *error)
     {
         NSLog(@"Details: %@", response);
         
         if(error)
         {
             XCTFail(@"Error reported: %@", error.description);
         }
         else{
             XCTAssert(response[@"city"],@"Missing city field.");
             XCTAssert(response[@"username"],@"Missing username field.");
             XCTAssert(response[@"fullName"],@"Missing fullname field.");
             XCTAssert(response[@"postalCode"],@"Missing postalcode field.");
             XCTAssert(response[@"firstName"],@"Missing firstname field.");
             XCTAssert(response[@"lastName"],@"Missing lastname field.");
             XCTAssert(response[@"mobilePhone"],@"Missing mobilephone field.");
             XCTAssert(response[@"address"],@"Missing address field.");
             XCTAssert(response[@"state"],@"Missing state field.");
             XCTAssert(response[@"homePhone"],@"Missing homephone field.");
             XCTAssert(response[@"alternativeEmail"],@"Missing alternativeemail field.");
             XCTAssert(response[@"country"],@"Missing country field.");
             XCTAssert(response[@"profile_was_updated"],@"Missing profile was updated field.");
             XCTAssert(response[@"customData"]!= nil && response[@"customData"] != 0, @"Missing customdata fields");
         }
         [sessionManager submitUserProfile:nil withCompletion:^(NSDictionary *response, NSError *error)
          {
              XCTAssert(error.domain==ECSErrorDomain, @"Expected Humanify error.");
              XCTAssert(error.code==ECS_ERROR_MISSING_PARAM, @"Expected error code not thrown.");
              XCTAssert(error, @"Expected an error");
              [expectation fulfill];
          }];
     }];
    
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Timeout error (15 seconds). Error=%@", error);
        }
    }];
}

- (void)testGetFormNames
{
    [self setUp];
    [self initSDKwithEnvironment:@"tce1" organization:@"mktwebextc_test"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"testGetFormNames"];
    
    ECSURLSessionManager *sessionManager = [[EXPERTconnect shared] urlSession];
    
    [sessionManager getFormNamesWithCompletion:^(NSArray *formNames, NSError *error)
     {
         NSLog(@"Details: %@", formNames);
         if(error) XCTFail(@"Error: %@", error.description);
         
         // Specific tests
         XCTAssert(formNames.count>0,@"Expected more than 0 forms returned.");
         
         [expectation fulfill];
     }];
    
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Timeout error (15 seconds). Error=%@", error);
        }
    }];
}

- (void)testGetFormNamesV2
{
    [self setUp];
    [self initSDKwithEnvironment:@"dce1" organization:@"mktwebextc"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"testGetFormNames"];
    
    ECSURLSessionManager *sessionManager = [[EXPERTconnect shared] urlSession];
    
    [sessionManager getFormNamesWithCompletion:^(NSArray *formNames, NSError *error)
     {
         NSLog(@"Details: %@", formNames);
         if(error) XCTFail(@"Error: %@", error.description);
         
         // Specific tests
         XCTAssert(formNames.count>0,@"Expected more than 0 forms returned.");
         
         [expectation fulfill];
     }];
    
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Timeout error (15 seconds). Error=%@", error);
        }
    }];
}

- (void)testGetFormV2
{
    [self setUp];
    [self initSDKwithEnvironment:@"dce1" organization:@"mktwebextc"];
    
    __block NSString *inputFormName = @"rate_agent_form";
    XCTestExpectation *expectation = [self expectationWithDescription:@"testGetFormNames2"];
    
    ECSURLSessionManager *sessionManager = [[EXPERTconnect shared] urlSession];
    
    [sessionManager getFormByName:inputFormName
                   withCompletion:^(ECSForm *form, NSError *error)
     {
         NSLog(@"Details: %@", form);
         if(error) XCTFail(@"Error: %@", error.description);
         
         // Specific tests
         XCTAssert(form.formData.count>0,@"Expected some form items");
         
         [expectation fulfill];
     }];
    
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Timeout error (15 seconds). Error=%@", error);
        }
    }];
}

- (void)testGetFormByName
{
    [self setUp];
    [self initSDKwithEnvironment:@"dce1" organization:@"mktwebextc"];
    
    __block NSString *inputFormName = @"rate_agent_form";
    XCTestExpectation *expectation = [self expectationWithDescription:@"testGetFormNames"];
    
    ECSURLSessionManager *sessionManager = [[EXPERTconnect shared] urlSession];
    
    [sessionManager getFormByName:inputFormName
                   withCompletion:^(ECSForm *form, NSError *error)
     {
         NSLog(@"Details: %@", form);
         if(error) XCTFail(@"Error: %@", error.description);
         
         // Specific tests
         XCTAssert(form.formData.count>0,@"Expected some form items");
         XCTAssert([form isKindOfClass:[ECSForm class]],@"Expected a form class for response.");
         XCTAssert(form.isInline == 1 || form.isInline == 0, @"Expected a 1 or 0 for isInline");
         XCTAssert([form.name isEqualToString:inputFormName],@"Expected name field to be same as input form name.");
         
         XCTAssert(form.submitCompleteText.length>0,@"Expected submitCompleteText");
         XCTAssert(form.submitCompleteHeaderText.length>0,@"Expected submitCompleteHeaderText");
         XCTAssert(form.submitText.length>0,@"Expected submitText");
         
         // Test 2 - NULL value
         [sessionManager getFormByName:nil
                        withCompletion:^(ECSForm *form, NSError *error)
          {
              XCTAssert(error.domain==ECSErrorDomain, @"Expected Humanify error.");
              XCTAssert(error.code==ECS_ERROR_MISSING_PARAM, @"Expected error code not thrown.");
              XCTAssert(error, @"Expected an error");
              
              [expectation fulfill];
          }];
     }];
    
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Timeout error (15 seconds). Error=%@", error);
        }
    }];
}

- (void)testGetFormbyName_NoForm {
    
    [self setUp];
    [self initSDKwithEnvironment:@"tce1" organization:@"mktwebextc_test"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"getExperts"];
    ECSURLSessionManager* sessionManager = [[EXPERTconnect shared] urlSession];
    
    
    [sessionManager getFormByName:@"not_real"
                   withCompletion:^(ECSForm *form, NSError *error)
     {
         //NSLog(@"Response=%@", response);
         XCTAssert(error, @"Expected a missing form error.");
         if(error) {
             NSLog(@"Error=%@", error);
             XCTAssert(error.domain == ECSErrorDomain, @"Expected humanify domain error.");
             XCTAssert(error.code == 500, @"Expected a HTTP 500 error");
             
             NSString *desc = [NSString stringWithFormat:@"%@", error.userInfo[NSLocalizedDescriptionKey]];
             XCTAssert(desc.length > 0, @"Expected an error description.");
         }
         
         [expectation fulfill];
     }];
    
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Timeout error (15 seconds). Error=%@", error);
        }
    }];
    
}

- (void)testSubmitForm
{
    [self setUp];   // Test setup
    [self initSDKwithEnvironment:@"tce1" organization:@"mktwebextc_test"];
    
    ECSForm *form = [ECSForm new];
    NSMutableArray *formData = [NSMutableArray new];
    
    // The "text" form field.
    ECSFormItemText *text1 = [ECSFormItemText new];
    XCTAssert(!text1.answered,@"Empty form value. Answered should be false.");
    text1.formValue = @"John Smith";
    XCTAssert(text1.answered,@"Form value populated. Answered shold be true.");
    ECSFormItemText *text2 = [text1 copy]; // Test copy mechanism
    XCTAssert(text2.formValue==text1.formValue&&text2.answered==text1.answered,@"Copy should have copied all fields/values.");
    [formData addObject:text1];
    
    // The "textarea" form field.
    ECSFormItemTextArea *textArea1 = [ECSFormItemTextArea new];
    textArea1.hint = @"This is a name field.";
    XCTAssert(!textArea1.answered,@"Empty form value. Answered should be false.");
    textArea1.formValue = @"John Smith";
    XCTAssert(textArea1.answered,@"Form value populated. Answered shold be true.");
    ECSFormItemTextArea *textArea2 = [textArea1 copy]; // Test copy mechanism
    XCTAssert(textArea2.formValue==textArea1.formValue&&textArea2.answered==textArea1.answered,@"Copy should have copied all fields/values.");
    [formData addObject:textArea1];
    
    // The "rating" form field.
    ECSFormItemRating *rating1 = [ECSFormItemRating new];
    XCTAssert(!rating1.answered,@"Empty form value. Answered should be false.");
    rating1.maxValue = [NSNumber numberWithInt:5];
    XCTAssert(rating1.maxValue==[NSNumber numberWithInt:5],@"MaxValue setter not working.");
    rating1.formValue = @"6";
    XCTAssert(!rating1.answered,@"Form value populated outside of max. Value is false.");
    rating1.formValue = @"2";
    XCTAssert(rating1.answered,@"Form value is a good value inside of max. Should be true.");
    ECSFormItemRating *rating2 = [rating1 copy]; // Test copy mechanism
    XCTAssert(rating2.formValue==rating1.formValue&&rating2.answered==rating1.answered,@"Copy should have copied all fields/values.");
    [formData addObject:rating1];
    
    // The "Checkbox" form field.
    ECSFormItemCheckbox *checkbox1 = [ECSFormItemCheckbox new];
    XCTAssert(!checkbox1.answered,@"Empty form value. Answered should be false.");
    checkbox1.formValue = @"Option 3";
    XCTAssert(checkbox1.answered,@"Form value populated. Answered shold be true.");
    checkbox1.options = @[@"Option1", @"Option2", @"Option3"];
    XCTAssert(checkbox1.options.count==3&&[[checkbox1.options objectAtIndex:2] isEqualToString:@"Option3"],@"Options array not populated properly.");
    ECSFormItemCheckbox *checkbox2 = [checkbox1 copy]; // Test copy mechanism
    XCTAssert(checkbox2.formValue==checkbox1.formValue&&checkbox2.answered==checkbox1.answered,@"Copy should have copied all fields/values.");
    [formData addObject:checkbox1];
    
    // The "Radio" form field.
    ECSFormItemRadio *radio1 = [ECSFormItemRadio new];
    XCTAssert(!radio1.answered,@"Empty form value. Answered should be false.");
    radio1.formValue = @"Option2";
    XCTAssert(radio1.answered,@"Form value populated. Answered shold be true.");
    radio1.options = @[@"Option1", @"Option2", @"Option3"];
    XCTAssert(radio1.options.count==3&&[[radio1.options objectAtIndex:2] isEqualToString:@"Option3"],@"Options array not populated properly.");
    ECSFormItemRadio *radio2 = [radio1 copy]; // Test copy mechanism
    XCTAssert(radio2.formValue==radio1.formValue&&radio2.answered==radio1.answered,@"Copy should have copied all fields/values.");
    [formData addObject:radio1];
    
    // The "Slider" form field.
    ECSFormItemSlider *slider1 = [ECSFormItemSlider new];
    slider1.minLabel = @"Smallest";
    slider1.maxLabel = @"Largest";
    slider1.minValue = [NSNumber numberWithDouble:-20.5];
    slider1.maxValue = [NSNumber numberWithDouble:500.5];
    XCTAssert(!slider1.answered,@"Empty form value. Answered should be false.");
    slider1.formValue = @"John Smith";
    XCTAssert(!slider1.answered,@"Form value is not valid number. Should be false.");
    slider1.formValue = @"120.234";
    XCTAssert(slider1.answered,@"Form value is valid number within range. Should be true.");
    ECSFormItemSlider *slider2 = [slider1 copy]; // Test copy mechanism
    XCTAssert(slider2.formValue==slider1.formValue&&slider2.answered==slider1.answered,@"Copy should have copied all fields/values.");
    [formData addObject:slider1];
    
    form.name = @"adhoc_sdk_demo";     // matches name in Forms Designer!!!
    form.formData = formData;
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"testSubmitForm"];
    
    ECSURLSessionManager *sessionManager = [[EXPERTconnect shared] urlSession];
    
    [sessionManager submitForm:form completion:^(ECSFormSubmitResponse *response, NSError *error) {
        
        NSLog(@"Details: %@", response);
        
        if(error)
        {
            XCTFail(@"Error reported: %@", error.description);
        }
        else
        {
            // identityToken would only be expected if we passed in user profile metadata fields.
//            XCTAssert(response.identityToken, @"Missing identityToken field");
            //XCTAssert(response.action,@"Missing action field");
            XCTAssert(response.profileUpdated, @"Missing profileUpdated field");
            XCTAssert(response.submitted, @"Missing submitted field");
        }
        
        // Test 2 - NULL value
        [sessionManager submitForm:nil completion:^(ECSFormSubmitResponse *response, NSError *error)
         {
             XCTAssert(error.domain == ECSErrorDomain, @"Expected a Humanify error domain.");
             XCTAssert(error.code == ECS_ERROR_MISSING_PARAM, @"Expected error code not thrown.");
             XCTAssert(error, @"Expected an error");
             [expectation fulfill];
         }];
    }];
    
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Timeout error (15 seconds). Error=%@", error);
        }
    }];
}

- (void)testUploadDownloadMediaFile
{
    // TODO: decide how this test should work
    
    [self setUp];   // Test setup
    [self initSDKwithEnvironment:@"tce1" organization:@"mktwebextc_test"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"testUploadMediaFile"];
    
    ECSURLSessionManager *sessionManager = [[EXPERTconnect shared] urlSession];
    __block NSString *fileName = @"GermanÄäÖöÜüßé";
    
    // Use this to get the auth token setup correctly.
    [[EXPERTconnect shared] startJourneyWithCompletion:^(NSString *journeyId, NSError *error)
     {
         ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
         
         /*
          NSString *const UIImagePickerControllerMediaType;
          NSString *const UIImagePickerControllerOriginalImage;
          NSString *const UIImagePickerControllerEditedImage;
          NSString *const UIImagePickerControllerCropRect;
          NSString *const UIImagePickerControllerMediaURL;
          NSString *const UIImagePickerControllerReferenceURL;
          NSString *const UIImagePickerControllerMediaMetadata;
          NSString *const UIImagePickerControllerLivePhoto;
          */
         NSMutableDictionary *mediaInfo = [[NSMutableDictionary alloc] init];
         mediaInfo[UIImagePickerControllerOriginalImage] = theme.chatBubbleTailsImage;
         mediaInfo[UIImagePickerControllerMediaType] = (NSString *)kUTTypeImage;
         
         [sessionManager uploadFileData:[ECSMediaInfoHelpers uploadDataForMedia:mediaInfo]
                               withName:fileName
                        fileContentType:@"image/jpg"
                             completion:^(__autoreleasing id *response, NSError *error)
          {
              
              // Response is nothing.
              
              if(error)
              {
                  XCTFail(@"Error reported: %@", error.description);
              }
              else
              {
                  NSLog(@"File uploaded.");
                  
                  // TODO: uploaded file. Now let's download it.
                  //fileName = [fileName stringByAppendingString:@".jpg"];
                  NSURLRequest *request = [sessionManager urlRequestForMediaWithName:fileName];
                  NSLog(@"Request is: %@", request);
                  NSError *error;
                  NSData *imageData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
                  NSLog(@"Data is %ld", imageData.length);
                  NSLog(@"Error: %@", error);
                  
                  NSString *strData = [[NSString alloc] initWithData:imageData encoding:NSUTF8StringEncoding];
                  NSLog(@"String data is %@", strData);
                  
                  UIImage *image = [UIImage imageWithData:imageData];
                  NSLog(@"Image is: %@", image);
              }
              
              [sessionManager uploadFileData:nil
                                    withName:nil
                             fileContentType:@"image/jpg"
                                  completion:^(__autoreleasing id *response, NSError *error)
               {
                   XCTAssert(error.domain == ECSErrorDomain, @"Expected Humanify error domain.");
                   XCTAssert(error.code==ECS_ERROR_MISSING_PARAM, @"Expected error code not thrown.");
                   XCTAssert(error, @"Expected an error");
                   
                   [expectation fulfill];
               }];
          }];
     }];
    
    
    
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Timeout error (15 seconds). Error=%@", error);
        }
    }];
}

- (void)testGetMediaFileNames
{
    [self setUp];   // Test setup
    [self initSDKwithEnvironment:@"tce1" organization:@"mktwebextc_test"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"testGetMediaFileNames"];
    
    ECSURLSessionManager *sessionManager = [[EXPERTconnect shared] urlSession];
    
    [sessionManager getMediaFileNamesWithCompletion:^(NSArray *fileNames, NSError *error) {
        
        NSLog(@"Details: %@", fileNames);
        
        if(error)
        {
            XCTFail(@"Error reported: %@", error.description);
        }
        else
        {
            // Specific tests
            XCTAssert(fileNames.count > 0 ,@"Expected more than 0 filenames returned.");
        }
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Timeout error (15 seconds). Error=%@", error);
        }
    }];
}

#pragma mark - History
- (void)testGetAnswerEngineHistory
{
    [self setUp];   // Test setup
    [self initSDKwithEnvironment:@"tce1" organization:@"mktwebextc_test"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"testGetAnswerEngineHistory"];
    
    ECSURLSessionManager *sessionManager = [[EXPERTconnect shared] urlSession];
    
    [sessionManager getAnswerEngineHistoryWithCompletion:^(ECSHistoryList *response, NSError *error) {
        
        NSLog(@"Details: %@", response);
        
        if(error)
        {
            XCTFail(@"Error reported: %@", error.description);
        }
        else
        {
            XCTAssert(response.journeys,@"Missing journeys field.");
            ECSHistoryListItem *listItem = [response.journeys objectAtIndex:0];
            XCTAssert(listItem.active,@"Missing active field.");
            XCTAssert(listItem.dateString,@"Missing datestring field.");
            XCTAssert(listItem.details,@"Missing details field.");
            XCTAssert(listItem.title,@"Missing titles field.");
            XCTAssert(listItem.journeyId,@"Missing journeyID field.");
            NSDictionary *dictionary = listItem.details;
            NSLog(@"%@",dictionary);
            if (dictionary)
            {
                XCTAssert([dictionary valueForKey:@"actionId"],@"Missing actionId field.");
                XCTAssert([dictionary valueForKey:@"context"],@"Missing context field.");
                XCTAssert([dictionary valueForKey:@"date"],@"Missing date field.");
                XCTAssert([dictionary valueForKey:@"id"],@"Missing id field.");
                XCTAssert([dictionary valueForKey:@"journeyId"],@"Missing journeyId field.");
                XCTAssert([dictionary valueForKey:@"request"],@"Missing request field.");
                XCTAssert([dictionary valueForKey:@"response"],@"Missing response field.");
                XCTAssert([dictionary valueForKey:@"title"],@"Missing title field.");
                XCTAssert([dictionary valueForKey:@"type"],@"Missing type field.");
            }
        }
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Timeout error (15 seconds). Error=%@", error);
        }
    }];
}

// TODO - Solve crash when there is zero chat history in the response (duplicated on TCE1)
- (void)testGetChatHistory
{
    [self setUp];   // Test setup
    [self initSDKwithEnvironment:@"tce1" organization:@"mktwebextc_test"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"testGetChatHistory"];
    
    ECSURLSessionManager *sessionManager = [[EXPERTconnect shared] urlSession];
    
    // Test 1: Get Chat history (record of chat starts for this user)
    [sessionManager getChatHistoryWithCompletion:^(ECSHistoryList *response, NSError *error)
     {
         NSLog(@"Details: %@", response);
         
         if(error) XCTFail(@"Error reported: %@", error.description);
         
         XCTAssert(response, @"Missing any history data on this journey.");
         
         if( response && !error ) {
             
             XCTAssert(response.journeys, @"Missing journeys field.");
             
             // Test 2: Analyze the first item closely.
             ECSHistoryList *list = [[ECSHistoryList alloc] init];
             list.journeys = response.journeys;
             
             XCTAssert(list.journeys.count>0, @"No journey data found.");
             
             if( list.journeys.count > 0 ) {
                 
                 ECSHistoryListItem *listItem = [list.journeys firstObject];
                 NSString *journeyId = [listItem valueForKey:@"journeyId"];
                 
                 XCTAssert(listItem.active,         @"Missing active field.");
                 XCTAssert(listItem.dateString,     @"Missing datestring field.");
                 XCTAssert(listItem.title,          @"Missing titles field.");
                 XCTAssert(listItem.journeyId,      @"Missing journeyID field.");
                 XCTAssert([listItem.active intValue]==0||[listItem.active intValue]==1, @"Active must be boolean (0 or 1)");
                 
                 //NSDictionary *firstItem = listItem.details
                 
                 [sessionManager getChatHistoryDetailsForJourneyId:journeyId
                                                    withCompletion:^(ECSChatHistoryResponse *response, NSError *error)
                  {
                      NSLog(@"Details: %@", response);
                      if(error) XCTFail(@"Error reported: %@", error.description);
                      
                      XCTAssert(response.journeys,@"Missing journeys field.");
                      
                      NSDictionary *listItem = [response.journeys objectAtIndex:0];
                      XCTAssert([listItem valueForKey:@"active"],       @"Missing active field.");
                      XCTAssert([listItem valueForKey:@"date"],         @"Missing date field.");
                      XCTAssert([listItem valueForKey:@"details"],      @"Missing details field.");
                      XCTAssert([listItem valueForKey:@"title"],        @"Missing titles field.");
                      XCTAssert([listItem valueForKey:@"journeyId"],    @"Missing journeyID field.");
                      
                      for (NSDictionary *dictionary in [listItem valueForKey:@"details"])
                      {
                          XCTAssert([dictionary valueForKey:@"actionId"],   @"Missing actionId field.");
                          XCTAssert([dictionary valueForKey:@"context"],    @"Missing context field.");
                          XCTAssert([dictionary valueForKey:@"date"],       @"Missing date field.");
                          XCTAssert([dictionary valueForKey:@"id"],         @"Missing id field.");
                          XCTAssert([dictionary valueForKey:@"journeyId"],  @"Missing journeyId field.");
                          XCTAssert([dictionary valueForKey:@"title"],      @"Missing title field.");
                          XCTAssert([dictionary valueForKey:@"type"],       @"Missing type field.");
                          XCTAssert([dictionary valueForKey:@"request"]|| [dictionary valueForKey:@"response"],@"Missing request/reponse field.");
                      }
                      
                      [expectation fulfill];
                      
                  
                  }];
             }
         }
     }];
    
    [self waitForExpectationsWithTimeout:30.0 handler:^(NSError *error)
     {
         if (error) XCTFail(@"Timeout error (15 seconds). Error=%@", error);
     }];
}

// Test the select experts endpoint.
- (void)testGetExpertsWithInteractionItems {
    
    //_testTenant = @"mktwebextc";
    [self setUp];
    [self initSDKwithEnvironment:@"tce1" organization:@"mktwebextc_test"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"getExperts"];
    
    ECSURLSessionManager *session = [[EXPERTconnect shared] urlSession];
    
    [session getExpertsWithInteractionItems:nil
                                 completion:^(NSArray *experts, NSError *error)
     {
         //NSLog(@"Experts Array: %@", experts);
         XCTAssert(experts.count && experts.count>0,@"No experts returned.");
         if(experts.count && experts.count>0)
         {
             NSArray *expertsArray = [ECSJSONSerializer arrayFromJSONArray:experts withClass:[ECSExpertDetail class]];
             if(expertsArray && expertsArray.count>0)
             {
                 ECSExpertDetail *expert1 = expertsArray[0];
                 XCTAssert(expert1.status.length>0,@"No status found.");
                 XCTAssert(expert1.chatsToRejectVoice == YES || expert1.chatsToRejectVoice == NO,@"chatToRejectVoice invalid value.");
             }
             XCTAssert(expertsArray, @"Missing experts array.");
         }
         
         [expectation fulfill];
     }];
    
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Timeout error (15 seconds). Error=%@", error);
        }
    }];
}

- (void)testStartConversation
{
    [self setUp];
    [self initSDKwithEnvironment:@"tce1" organization:@"mktwebextc_test"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"testStartConversation"];
    
    ECSVideoChatActionType *chatAction = [ECSVideoChatActionType new];
    chatAction.actionId = @"";
    chatAction.agentSkill = @"CE_Mobile_Chat";
    chatAction.displayName = @"Test screen";
    chatAction.shouldTakeSurvey = NO;
    //chatAction.journeybegin = [NSNumber numberWithInt:1];
    
    
    ECSCafeXController *cafeXController = [[ECSInjector defaultInjector] objectForClass:[ECSCafeXController class]];
    // Do a login if there's no session:
    if (![cafeXController hasCafeXSession]) {
        [cafeXController setupCafeXSession];
    }
    chatAction.cafexmode = @"videocapable,voicecapable,cobrowsecapable";
    chatAction.cafextarget = [cafeXController cafeXUsername];
    ECSActionType *actionType = [[ECSActionType alloc] init];
    actionType = chatAction;
    ECSURLSessionManager *session = [[EXPERTconnect shared] urlSession];
    // Start a new journey
    [[EXPERTconnect shared] startJourneyWithCompletion:^(NSString *journeyID, NSError *error)
     {
         XCTAssert(journeyID.length>0,@"Response contains a journeyID");
         XCTAssert(!error, @"Response does not contain an error");
         
         // Same as high level chat, start a conversation.
         [session startConversationForAction:actionType
                             andAlwaysCreate:YES
                              withCompletion:^(ECSConversationCreateResponse *response, NSError *error)
          {
              // MAS - This currently fails because of apple bug. Requires any one "capability" to be enabled to work in a simulator.
              // Problem is, unit tests cannot edit the host app's "capabilities". No known workaround. The code is fine. Test disabled.
              // SEE: http://stackoverflow.com/questions/38456471/secitemadd-always-returns-error-34018-in-xcode-8-in-ios-10-simulator
              XCTAssert(response.journeyID.length>0,@"Response contains a journeyID");
              XCTAssert(response.conversationID.length>0,@"Response has a conversationID");
              XCTAssert(response.channelLink.length>0,@"Response has a channelLink");
              XCTAssert(!error, @"Response does not contain an error");
              
              [session startConversationForAction:nil
                                  andAlwaysCreate:YES
                                   withCompletion:^(ECSConversationCreateResponse *response, NSError *error)
               {
                   XCTAssert(error.domain == ECSErrorDomain, @"Expected Humanify error domain");
                   XCTAssert(error.code==ECS_ERROR_MISSING_PARAM, @"Expected error code not thrown.");
                   XCTAssert(error, @"Expected an error");
                   [expectation fulfill];
               }];
          }];
     }];
    
    [self waitForExpectationsWithTimeout:30.0 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Timeout error (25 seconds). Error=%@", error);
        }
    }];
}

/*
 Functionality: Setting a journey context changes how the journey behaves. It changes which rules will
 get called and changes whether we create a new journey or resume an old one.
 */
- (void)testSetJourneyContext {
    
    [self setUp];
    _testTenant = @"mktwebextc";
    [self initSDKwithEnvironment:@"dce1" organization:_testTenant];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"getDetailsForSkill"];
    
    // Let's set some of these values so we can check them in the response
    [EXPERTconnect shared].journeyManagerContext = @"DevTest";
    [EXPERTconnect shared].pushNotificationID = @"aaaa-bbbb-cccc-dddd";
    
    // Step 1: Start a new journey (prerequesite)
    [[EXPERTconnect shared] startJourneyWithCompletion:^(NSString *journeyId, NSError *error)
     {
         NSLog(@"Journey response=%@", journeyId);
         
         __weak ECSURLSessionManager *session = [[EXPERTconnect shared] urlSession];
         
         // Test 1: Attempt to attach to a non-existant context.
         [session setJourneyContext:@"non_existant_context"
                         completion:^(ECSJourneyAttachResponse *response, NSError *error)
          {
              XCTAssert(error,@"Expecting an error (not found) here.");
              XCTAssert(!response,@"Expecting nil response due to error.");
              XCTAssert([error.userInfo[NSLocalizedFailureReasonErrorKey] isEqualToString:@"common.error.contextNotFound"],@"Expecting a common.error.contextNotFound error.");
              
              // Test 2: Attempt to attach to an existing, good context
              [session setJourneyContext:@"SDK Baseline"
                              completion:^(ECSJourneyAttachResponse *response, NSError *error)
               {
                   XCTAssert(!error,@"Not expecting an error.");
                   XCTAssert(response,@"Expecting response.");
                   XCTAssert([response.tenantId isEqualToString:_testTenant], @"Expecting input tenant.");
                   XCTAssert([response.deviceType isEqualToString:@"ios"], @"Expecting ios as devicetype.");
                   XCTAssert([response.pushNotificationId isEqualToString:@"aaaa-bbbb-cccc-dddd"],@"Expecting input pushID.");
                   XCTAssert(response.contextId.length>0, @"Expecting populated contextID");
                   XCTAssert(response.lastActivityTime, @"Expecting lastActivityTime");
                   XCTAssert(response.creationTime, @"Expecting lastActivityTime");
                   
                   NSLog(@"Response=%@", response);
                   
                   // Test 3: nil context.
                   [session setJourneyContext:nil
                                   completion:^(ECSJourneyAttachResponse *response, NSError *error)
                    {
                        XCTAssert(error.domain == ECSErrorDomain, @"Expected Humanify error domain.");
                        XCTAssert(error.code==ECS_ERROR_MISSING_PARAM, @"Expected error code not thrown.");
                        XCTAssert(error, @"Expected an error");
                        [expectation fulfill];
                    }];
               }];
          }];
     }];
    
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Timeout error (15 seconds). Error=%@", error);
        }
    }];
}

-(void)testNetworkReachable {
    ECSURLSessionManager *session = [[EXPERTconnect shared] urlSession];
    
    BOOL retVal = [session networkReachable];
    
    XCTAssert(retVal, @"Network not reachable.");
}


//-(void)testTopTenReturnHTMLForFord {
//    
//    XCTestExpectation *expectation = [self expectationWithDescription:@"gettopten"];
//    
//    [self setUp];
//    [self initSDKwithEnvironment:@"dce1" organization:@"mktwebextc"];
//    
//    
//    // Code Pivotal can implement for contextual top-10 from Astute.
//    
//    // For Ford: Where will this intendID come from?
//    [[EXPERTconnect shared] setJourneyManagerContext:@"1004791351"]; // Sets answer engine context. (IntentID)
//    
//    NSString *endpointPathComponent = @"answerengine/v1/top10?num=5";
//    
//    // Caveat -- only does a HTTP GET (not capable of doing a POST)
//    [[[EXPERTconnect shared] urlSession] getResponseFromEndpoint:endpointPathComponent
//                                                  withCompletion:^(NSString *response, NSError *error)
//     {
//         
//         NSLog(@"Response = %@, Error=%@", response, error);
//         if(error) {
//             XCTFail(@"Error occurred. Error=%@", error);
//         }
//         
//         XCTAssert([response rangeOfString:@"agent-utterance"].location != NSNotFound, @"Contains an ASTUTE response template.");
//         XCTAssert([response rangeOfString:@"topicLink"].location != NSNotFound, @"Contains at least one ASTUTE topic.");
//         
//         [expectation fulfill];
//     }];
//    
//    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
//        if (error) {
//            XCTFail(@"Timeout error (15 seconds). Error=%@", error);
//        }
//    }];
//}

-(void)testDynamicTopTenForFord {
    
    [self setUp];
    [self initSDKwithEnvironment:@"dce1" organization:@"henry"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"gettopten"];
    
    NSString *service = @"My Wallet"; // Or "applet"
    
    [[[EXPERTconnect shared] urlSession] makeDecision:@{@"eventId"      : @"determineRule",
                                                        @"userLanguage" : @"EN",
                                                        @"userCountry"  : @"US",
                                                        @"service"      : service}
                                           completion:^(NSDictionary *dr, NSError *error)
     {

         // This rule is used by Ford. All we are concerned with is the intentId it returns.
         XCTAssert(dr[@"responseData"] || dr[@"responseData"][@"intentId"], @"Intended directory structure was not intact.");
         
         NSString *intentId = dr[@"responseData"][@"intentId"];
         
         XCTAssert(intentId.length > 7, @"We did get an intentId and it is a long number.");
         
         // Now we take that intentId and set it in the JM context.
         [[EXPERTconnect shared] setJourneyManagerContext:intentId];
     
         // We are making a custom call to an undocumented answerengine top10 endpoint.
         NSString *endpointPathComponent = [NSString stringWithFormat:@"answerengine/v1/top10?num=5&service=%@", service];
     
         // Make our call.
         [[[EXPERTconnect shared] urlSession] getResponseFromEndpoint:endpointPathComponent
                                                       withCompletion:^(id response, NSError *error)
          {
              if(error) XCTFail(@"Error occurred. Error=%@", error);
              
              XCTAssert([response isKindOfClass:[NSDictionary class]], @"Expecting a dictionary of topics.");

              if( [response isKindOfClass:[NSDictionary class]] ) {
                  
                  NSDictionary *responseDic = (NSDictionary *)response;
                  
                  XCTAssert([responseDic[@"topics"] isKindOfClass:[NSArray class]], @"Expected a dictionary of topics");
                  
                  NSArray *responseTopics = responseDic[@"topics"];
                  
                  for (NSDictionary *item in responseTopics) {
                      
                      XCTAssert(item[@"intentId"], @"Expecting an intentID");
                      XCTAssert(item[@"topic"], @"Expecting a topic");
                      
                      // An intentId and a topic are the two values we need an array of. These will be used to display the top10.
                      NSLog(@"Intent=%@, Topic=%@", item[@"intentId"], item[@"topic"]);
                  }
              }
     
              [expectation fulfill];
          }];
     }];
    
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Timeout error (15 seconds). Error=%@", error);
        }
    }];
}

/**
 NOTE: This test is failing in v5.4. Config required on server. @kenwashington is contact for information.
 */
- (void)testFordDecisionRule {
    
    [self setUp];
    
    _testTenant = @"henry";
    [self initSDKwithEnvironment:@"tce1" organization:@"mktwebextc_test"];
    
    ECSURLSessionManager *session = [[EXPERTconnect shared] urlSession];
    XCTestExpectation *expectation = [self expectationWithDescription:@"testMakeDecision"]; // Define a new expectation
    
    // TODO: Change to "validateDE"
    NSMutableDictionary *decisionDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                               @"henry",@"name",
                                               @"henryRule",@"projectServiceName",
                                               @"determineRule",@"eventId",
                                               @"henry",@"ceTenant",
                                               @"EN",@"userLanguage",
                                               @"US",@"userCountry",
                                               @"My Vehicles",@"service",
                                               @"mktwebextc",@"clientRequestId",
                                               @"current local page",@"function",
                                               nil];
    
    [session makeDecision:decisionDictionary
               completion:^(NSDictionary *response, NSError *error)
     {
         XCTAssert(!error,@"API call had an error.");
         
         NSLog(@"Response JSON = %@", response);
         
         XCTAssert([response[@"eventId"] isEqualToString:@"determineRule"], @"Expected eventId matching input.");
         
         [expectation fulfill]; // Tell the loop to stop waiting - test is finished.
     }];
    
    // Goes at bottom of test function
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Timeout error (15 seconds). Error=%@", error);
        }
    }];
}

-(void)testJourneyManagerConfigEndpoint {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"getjmconfig"];
    
    [self setUp];
    [self initSDKwithEnvironment:@"dce1" organization:@"mktwebextc"];
    
    // Code Pivotal can implement for contextual top-10 from Astute.
    
    // For Ford: Where will this intendID come from?
    [[EXPERTconnect shared] setJourneyManagerContext:@"WeightWatchers"];
    
    
    
    [[EXPERTconnect shared] startJourneyWithName:@"unitTestWW"
                              pushNotificationId:nil
                                         context:@"WeightWatchers"
                                      completion:^(NSString *journeyID, NSError *error)
     {

         NSString *endpointPathComponent = @"appconfig/v1/navigation?page=support";
         
         [[[EXPERTconnect shared] urlSession] getResponseFromEndpoint:endpointPathComponent
                                                       withCompletion:^(NSString *response, NSError *error)
          {
              
              NSLog(@"Response = %@, Error=%@", response, error);
              if(error) {
                  XCTFail(@"Error occurred. Error=%@", error);
              }
              
              [expectation fulfill];
          }];
         
     }];
    
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Timeout error (15 seconds). Error=%@", error);
        }
    }];
}


@end
