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
#import "UIImage+ECSBundle.h"
#import "ECSHistoryList.h"
#import "ECSChatHistoryResponse.h"
#import "ECSHistoryListItem.h"

@interface ECS_API_Tests : XCTestCase <ECSAuthenticationTokenDelegate>

@end

@implementation ECS_API_Tests

NSURL *_testAuthURL;
NSString *_testTenant;
NSString *_username;
NSString *_fullname;
NSString *_firstname;

- (void)initSDK {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    ECSConfiguration *configuration = [ECSConfiguration new];
    
    configuration.appName       = @"EXPERTconnect UnitTester";
    configuration.appVersion    = @"1.0";
    configuration.appId         = @"12345";
    
    configuration.host          = @"https://api.dce1.humanify.com";
    
    [[EXPERTconnect shared] initializeWithConfiguration:configuration];
    //[[EXPERTconnect shared] initializeVideoComponents]; // CafeX initialization.
    _username = @"yasar.arafath@agiliztech.com";
    _fullname = @"yasar yasar";
    _firstname = @"yasar";
	 
    if(!_testTenant) _testTenant = @"mktwebextc";
    // A GOOD auth URL
    _testAuthURL = [[NSURL alloc] initWithString:
                    [NSString stringWithFormat:@"https://api.dce1.humanify.com/authServerProxy/v1/tokens/ust?username=%@&client_id=%@",
                     @"yasar.arafath@agiliztech.com",
                     _testTenant]];
    [[EXPERTconnect shared] setAuthenticationTokenDelegate:self];
    
    [[EXPERTconnect shared] setDebugLevel:5];
    [[EXPERTconnect shared] overrideDeviceLocale:@"en-US"];
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
             NSError *myError = [NSError errorWithDomain:@"com.humanify"
                                                    code:statusCode
                                                userInfo:[NSDictionary dictionaryWithObject:returnToken forKey:@"errorJson"]];
             completion(nil, myError);
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
	 [self initSDK];
	 
	 NSMutableArray *interests = [[NSMutableArray alloc] initWithObjects:@"running", @"skiing", @"hiking", nil];
	 
	 NSMutableDictionary *affinity = [NSMutableDictionary dictionaryWithObjectsAndKeys:
									  @"9", @"sat_score",
									  @"chris_horizon", @"expertId",
									  @"financial advisor", @"skill",
									  nil];
	 
	 NSMutableDictionary *interaction = [NSMutableDictionary dictionaryWithObjectsAndKeys:
										 @"2", @"nps_score",
										 @"mutual funds", @"intent",
										 nil];
	 
	 NSMutableDictionary *customData = [NSMutableDictionary dictionaryWithObjectsAndKeys:
										@"4", @"nps",
										@"60", @"klout",
										@"250000", @"clv",
										interests, @"interests",
										@"midatlantic", @"region",
										affinity, @"affinity",
										interaction, @"interaction",
										nil];
	 
	 NSMutableDictionary *consumerData = [NSMutableDictionary dictionaryWithObjectsAndKeys:
										  @"null", @"userID",
										  @"gwen@email.com", @"username",
										  @"Gwen", @"firstName",
										  @"", @"lastName",
										  @"null", @"address",
										  @"Denver", @"city",
										  @"Colorado", @"state",
										  @"80238", @"postalCode",
										  @"United States", @"country",
										  @"(312) 555-1155", @"homePhone",
										  @"(312) 555-3944", @"mobilePhone",
										  customData, @"customData",
										  @"null", @"alternativeEmail",
										  nil];
	 
	 NSMutableDictionary *decisionDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
												consumerData, @"consumer",
												@"horizon", @"ceTenant",
												@"determineTreatment", @"eventId",
												nil];
	 
	 NSError *error;
	 NSData *decisionData = [NSJSONSerialization dataWithJSONObject:decisionDictionary
															options:NSJSONWritingPrettyPrinted
															  error:&error];
	 NSString* decisionJson = [[NSString alloc] initWithData:decisionData encoding:NSUTF8StringEncoding];
	 
	 NSLog(@"Decision Request Json: %@", decisionJson);
	 
	 ECSURLSessionManager *session = [[EXPERTconnect shared] urlSession];
	 
	 XCTestExpectation *expectation = [self expectationWithDescription:@"testMakeDecision"]; // Define a new expectation
	 
	 [session makeDecision:decisionDictionary
				completion:^(NSDictionary *response, NSError *error)
	  {
		   XCTAssert(!error,@"API call had an error.");
		   
		   NSLog(@"Response JSON = %@", response);
		   
		   XCTAssert(response[@"tenant"], @"Missing tenant field.");
		   
		   [expectation fulfill]; // Tell the loop to stop waiting - test is finished.
	  }];
	 
	 // Goes at bottom of test function
	 [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
		  if (error) {
			   XCTFail(@"Timeout error (15 seconds). Error=%@", error);
		  }
	 }];
}

- (void)testGetDetailsForSkill {
	 
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
}

- (void)testGetDetailsForExpertSkill {
    
    [self setUp];
    [self initSDK];
    XCTestExpectation *expectation = [self expectationWithDescription:@"getDetailsForSkill"];
    
    NSString *skillName = @"CE_Mobile_Chat";
    
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
         
         [expectation fulfill];
     }];
    
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Timeout error (15 seconds). Error=%@", error);
        }
    }];
}

- (void)testGetNavigationContextWithName
{
    [self setUp];
    [self initSDK];
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
    [self initSDK]; // SDK setup

    XCTestExpectation *expectation = [self expectationWithDescription:@"testGetAnswerEngineTopQuestions"];

    ECSURLSessionManager *sessionManager = [[EXPERTconnect shared] urlSession];

    // Test 1: Test the API with an expected count of 2 results.
    [sessionManager getAnswerEngineTopQuestions:2
                                 withCompletion:^(NSArray *answers, NSError *error)
    {
         if(error) XCTFail(@"Error: %@", error.description);
      
         //Specific tests
         XCTAssert(answers.count == 2, @"Expected 2 answers in ALL context.");
         
        [expectation fulfill];
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
    [self initSDK]; // SDK setup

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

        [expectation fulfill];
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
    [self initSDK];
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

        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Timeout error (15 seconds). Error=%@", error);
        }
    }];
}

- (void)testGetAnswerEngineTopQuestionsForKeyword
{
    [self setUp];
    [self initSDK];
    XCTestExpectation *expectation = [self expectationWithDescription:@"testGetAnswerEngineTopQuestionsForKeyword"];

    ECSURLSessionManager *sessionManager = [[EXPERTconnect shared] urlSession];
    __block int expectedResponses = 2; // Set to number of tests in this block

    // Test 1: A question expecting a real answer
    [sessionManager getAnswerEngineTopQuestionsForKeyword:@"parking"
                                      withOptionalContext:@"Park"
                                               completion:^(ECSAnswerEngineResponse *response, NSError *error)
    {
        NSLog(@"Details: %@", response);
        if(error) XCTFail(@"Error: %@", error.description);

        expectedResponses--;
        if(expectedResponses<=0)[expectation fulfill];
    }];
    
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
         
         expectedResponses--;
         if(expectedResponses<=0)[expectation fulfill];
     }];

    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Timeout error (15 seconds). Error=%@", error);
        }
    }];
}

- (void)testGetAnswerForQuestion
{
    [self setUp];
    [self initSDK];
    XCTestExpectation *expectation = [self expectationWithDescription:@"testGetAnswerForQuestion"];

    ECSURLSessionManager *sessionManager = [[EXPERTconnect shared] urlSession];

    // Test good question
    [sessionManager getAnswerForQuestion:@"How Does Borrow Work?"
                               inContext:@""
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

- (void)testGetAnswerForQuestion_MissingAnswer
{
    [self setUp];
    [self initSDK];
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
    [self initSDK];
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
    [self initSDK];
    
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
                        
                        [expectation fulfill];
                    }];
               }];
          }];
     }];
    
    // Wait for the above code to finish (15 second timeout)...
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Timeout error (15 seconds). Error=%@", error);
        }
    }];
}

// TODO: Deprecated? Not necessary in the SDK?
- (void)testGetResponseFromEndpoint
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
}

- (void)testGetUserProfile
{
	 [self setUp];   // Test setup
	 [self initSDK]; // SDK setup
	 
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
	 [self initSDK]; // SDK setup
	 
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
		   [expectation fulfill];
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
    [self initSDK];
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

- (void)testGetFormByName
{
    [self setUp];
    [self initSDK];
    __block int expectedResponses = 1;
    __block NSString *inputFormName = @"agentperformance";
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
        
        expectedResponses--;
        if(expectedResponses <= 0)[expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Timeout error (15 seconds). Error=%@", error);
        }
    }];
}

- (void)testGetFormbyName_NoForm {
    [self initSDK];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"getExperts"];
    ECSURLSessionManager* sessionManager = [[EXPERTconnect shared] urlSession];
    
    
    [sessionManager getFormByName:@"not_real"
                   withCompletion:^(ECSForm *form, NSError *error)
     {
         //NSLog(@"Response=%@", response);
         XCTAssert(error, @"Expected a missing form error.");
         if(error) {
            NSLog(@"Error=%@", error);
             XCTAssert([error.domain isEqualToString:@"com.humanify"],@"Expected humanify domain error.");
             XCTAssert([error.userInfo[NSLocalizedFailureReasonErrorKey] isEqualToString:@"forms.error.failedRetrievingFormFromLegacySystem"],
                       @"Expected form retreival error.");
             
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
	 [self initSDK]; // SDK setup
	 
	 NSMutableArray *formData = [NSMutableArray new];
	 
	 ECSForm *form = [ECSForm new];
	 ECSFormItem *fI1 = [ECSFormItem new];
	 ECSFormItem *fI2 = [ECSFormItem new];
	 ECSFormItem *fI3 = [ECSFormItem new];
	 
	 [formData addObject:fI1];
	 [formData addObject:fI2];
	 [formData addObject:fI3];
	 
	 form.name = @"adhoc_sdk_demo";     // matches name in Forms Designer!!!
	 form.formData = formData;
	 
	 fI1.label = @"Email Address";
	 fI2.label = @"Agent Rating";
	 fI3.label = @"Comments";
	 
	 fI1.formValue = @"yasar.arafath@agiliztech.com";
	 fI2.formValue = @"8";
	 fI3.formValue = @"No comments";

	 
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
			   XCTAssert(response.identityToken, @"Missing identityToken field");
			   XCTAssert(response.action,@"Missing action field");
			   XCTAssert(response.profileUpdated, @"Missing profileUpdated field");
			   XCTAssert(response.submitted, @"Missing submitted field");
		  }
		  [expectation fulfill];
	 }];
	 
	 [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
		  if (error) {
			   XCTFail(@"Timeout error (15 seconds). Error=%@", error);
		  }
	 }];
}

- (void)testUploadMediaFile
{
     // TODO: decide how this test should work
     
//	 [self setUp];   // Test setup
//	 [self initSDK]; // SDK setup
//	 
//	 XCTestExpectation *expectation = [self expectationWithDescription:@"testUploadMediaFile"];
//	 
//	 ECSURLSessionManager *sessionManager = [[EXPERTconnect shared] urlSession];
//	 
//	 ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
//
//	 [sessionManager uploadFileData:[ECSMediaInfoHelpers uploadDataForMedia:theme.chatBubbleTailsImage]
//					withName:@""
//			 fileContentType:@"image/jpg"
//				  completion:^(__autoreleasing id *response, NSError *error)
//	  {
//		  
//		  NSLog(@"Details: %@", fileNames);
//		  
//		  if(error)
//		  {
//			   XCTFail(@"Error reported: %@", error.description);
//		  }
//		  else
//		  {
//			   XCTAssert(fileNames != nil && fileNames.count != 0 ,@"No media file names found.");
//		  }
//		  [expectation fulfill];
//	 }];
//	 
//	 [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
//		  if (error) {
//			   XCTFail(@"Timeout error (15 seconds). Error=%@", error);
//		  }
//	 }];
}

- (void)testDownloadMediaFile
{
	// TODO: decide how this test should work
}

- (void)testGetMediaFileNames
{
	 [self setUp];   // Test setup
	 [self initSDK]; // SDK setup
	 
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
			   XCTAssert(fileNames != nil && fileNames.count != 0 ,@"No media file names found.");
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
	 [self initSDK]; // SDK setup
	 
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

- (void)testGetChatHistory
{
     [self setUp];   // Test setup
     [self initSDK]; // SDK setup
     
     XCTestExpectation *expectation = [self expectationWithDescription:@"testGetChatHistory"];
     
     ECSURLSessionManager *sessionManager = [[EXPERTconnect shared] urlSession];
     
     [sessionManager getChatHistoryWithCompletion:^(ECSHistoryList *response, NSError *error)
      {
           NSLog(@"Details: %@", response);
           
           if(error)
           {
                XCTFail(@"Error reported: %@", error.description);
           }
           else
           {
                XCTAssert(response.journeys,@"Missing journeys field.");
           }
           ECSHistoryListItem *listItem = [response.journeys objectAtIndex:0];
           NSString *journeyId = [listItem valueForKey:@"journeyId"];
           NSLog(@"Details: %@", journeyId);
           XCTAssert(listItem.active,@"Missing active field.");
           XCTAssert(listItem.dateString,@"Missing datestring field.");
           XCTAssert(listItem.details,@"Missing details field.");
           XCTAssert(listItem.title,@"Missing titles field.");
           XCTAssert(listItem.journeyId,@"Missing journeyID field.");
           [sessionManager getChatHistoryDetailsForJourneyId:journeyId
                                              withCompletion:^(ECSChatHistoryResponse *response, NSError *error)
            {
                 NSLog(@"Details: %@", response);
                 if(error)
                 {
                      XCTFail(@"Error reported: %@", error.description);
                 }
                 else
                 {
                      XCTAssert(response.journeys,@"Missing journeys field.");
                      NSDictionary *listItem = [response.journeys objectAtIndex:0];
                      XCTAssert([listItem valueForKey:@"active"],@"Missing active field.");
                      XCTAssert([listItem valueForKey:@"date"],@"Missing date field.");
                      XCTAssert([listItem valueForKey:@"details"],@"Missing details field.");
                      XCTAssert([listItem valueForKey:@"title"],@"Missing titles field.");
                      XCTAssert([listItem valueForKey:@"journeyId"],@"Missing journeyID field.");
                      for (NSDictionary *dictionary in [listItem valueForKey:@"details"]) {
                           
                           XCTAssert([dictionary valueForKey:@"actionId"],@"Missing actionId field.");
                           XCTAssert([dictionary valueForKey:@"context"],@"Missing context field.");
                           XCTAssert([dictionary valueForKey:@"date"],@"Missing date field.");
                           XCTAssert([dictionary valueForKey:@"id"],@"Missing id field.");
                           XCTAssert([dictionary valueForKey:@"journeyId"],@"Missing journeyId field.");
                           XCTAssert([dictionary valueForKey:@"request"]|| [dictionary valueForKey:@"response"],@"Missing request/reponse field.");
                           XCTAssert([dictionary valueForKey:@"title"],@"Missing title field.");
                           XCTAssert([dictionary valueForKey:@"type"],@"Missing type field.");
                      }
                 }
                 [expectation fulfill];
            }];
      }];
     
     [self waitForExpectationsWithTimeout:30.0 handler:^(NSError *error) {
          if (error) {
               XCTFail(@"Timeout error (15 seconds). Error=%@", error);
          }
     }];
}

// Test the select experts endpoint.
- (void)testGetExpertsWithInteractionItems {
    
    _testTenant = @"mktwebextc";
    [self initSDK];
    
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

/*
 Functionality: Setting a journey context changes how the journey behaves. It changes which rules will
 get called and changes whether we create a new journey or resume an old one.
 */
- (void)testSetJourneyContext {
    
    [self setUp];
    [self initSDK];
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

-(void)testNetworkReachable {
    ECSURLSessionManager *session = [[EXPERTconnect shared] urlSession];
    
    BOOL retVal = [session networkReachable];
    
    XCTAssert(retVal, @"Network not reachable.");
}

@end
