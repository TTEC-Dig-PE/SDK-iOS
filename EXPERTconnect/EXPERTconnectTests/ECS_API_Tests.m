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

@interface ECS_API_Tests : XCTestCase <ECSAuthenticationTokenDelegate>

@end

@implementation ECS_API_Tests

NSURL *_testAuthURL;
NSString *_testTenant;

- (void)initSDK {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    ECSConfiguration *configuration = [ECSConfiguration new];
    
    configuration.appName       = @"EXPERTconnect UnitTester";
    configuration.appVersion    = @"1.0";
    configuration.appId         = @"12345";
    
    configuration.host          = @"https://api.dce1.humanify.com";
    
    [[EXPERTconnect shared] initializeWithConfiguration:configuration];
    
    if(!_testTenant) _testTenant = @"mktwebextc";
    // A GOOD auth URL
    _testAuthURL = [[NSURL alloc] initWithString:
                    [NSString stringWithFormat:@"https://api.dce1.humanify.com/authServerProxy/v1/tokens/ust?username=%@&client_id=%@",
                     @"expertconnect_unit_test",
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

- (void)testMakeDecision {
    
    [self setUp];
    [self initSDK];
    
    ECSURLSessionManager *session = [[EXPERTconnect shared] urlSession];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"testMakeDecision"]; // Define a new expectation
    
    [session makeDecision:[NSDictionary dictionaryWithObject:@"test" forKey:@"test"]
               completion:^(NSDictionary *response, NSError *error)
    {
        if(error) XCTFail(@"Error: %@", error.description);
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
    XCTestExpectation *expectation = [self expectationWithDescription:@"rateAnswerWithAnswerID"];

    ECSURLSessionManager *sessionManager = [[EXPERTconnect shared] urlSession];

    // First, ask a question (this is what we will rate)
    [sessionManager getAnswerForQuestion:@"How Does Borrow Work?"
                               inContext:@""
                              customData:nil
                              completion:^(ECSAnswerEngineResponse *response, NSError *error)
    {
        NSLog(@"Details: %@", response);
        if(error) XCTFail(@"Error: %@", error.description);
        
        // Now rate the response...
        [sessionManager rateAnswerWithAnswerID:response.answerId
                                     inquiryID:response.inquiryId
                                        rating:1
                                           min:-1
                                           max:1
                                 questionCount:1
                                    completion:^(ECSAnswerEngineRateResponse *response, NSError *error)
        {
            NSLog(@"Details: %@", response);
            if(error) XCTFail(@"Error: %@", error.description);

            // Specific Tests:
            XCTAssert(response.constrainedRating == 5, @"ConstraintedRating should be 5 for an answer of positive (1)");
            /* Response: 
             actions =     (
             );
             answer = "<null>";
             answerContent = "<null>";
             answerID = "<null>";
             answersQuestion = "<null>";
             constrainedRating = 5;
             inquiryID = "<null>";
             requestRating = "<null>";
             suggestedQuestions = "<null>";
             }
             */
            [expectation fulfill];
        }];
    }];

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

    [EXPERTconnect shared].userName = @"gwen@email.com";
    
    ECSURLSessionManager *sessionManager = [[EXPERTconnect shared] urlSession];
    [sessionManager getUserProfileWithCompletion:^(ECSUserProfile *profile, NSError *error)
    {
        NSLog(@"Details: %@", profile);
        if(error) XCTFail(@"Error: %@", error.description);

        XCTAssert([profile.username isEqualToString:[EXPERTconnect shared].userName],@"Expected username to match input.");
        // Specific Tests:
        
        /* Response: 
         address = "2020 39th Street";
         alternativeEmail = "gwen@email.com";
         city = Anchorville;
         country = "United States";
         customData =     {
         affinity =         {
         expertId = "chris_horizon";
         "sat_score" = 9;
         skill = "financial advisor";
         };
         clv = 250000;
         demographics =         {
         age = 29;
         education = bachelors;
         ethnicity = white;
         gender = female;
         income = high;
         married = no;
         profession = other;
         };
         interaction =         {
         intent = "mutual funds";
         "nps_score" = 2;
         };
         interests =         (
         running,
         skiing
         );
         klout = 60;
         nps = 4;
         region = midatlantic;
         };
         firstName = Gwen;
         fullName = "Gwen Email";
         homePhone = "333-778-8791";
         lastName = Email;
         mobilePhone = "";
         postalCode = 48004;
         "profile_was_updated" = "<null>";
         state = Michigan;
         username = "gwen@email.com";
         */

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
	 
	 profile.firstName = @"yasar3";
	 profile.lastName = @"yasar";
	 profile.username = @"yasar.arafath3@agiliztech.com";
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
	 [sessionManager submitUserProfile:profile withCompletion:^(NSString *response, NSError *error)
	 {
		   NSLog(@"Details: %@", response);
		   
		   if(error)
		   {
				XCTFail(@"Error reported: %@", error.description);
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

- (void)testSubmitForm
{
	 [self setUp];   // Test setup
	 [self initSDK]; // SDK setup
	 
	 XCTestExpectation *expectation = [self expectationWithDescription:@"testSubmitForm"];
	 
	 ECSURLSessionManager *sessionManager = [[EXPERTconnect shared] urlSession];
	 
	 ECSForm *form = [ECSForm new];

	 [sessionManager submitForm:form completion:^(ECSFormSubmitResponse *response, NSError *error) {
		  
		  NSLog(@"Details: %@", response);
		  
		  if(error)
		  {
			   XCTFail(@"Error reported: %@", error.description);
		  }
		  [expectation fulfill];
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
