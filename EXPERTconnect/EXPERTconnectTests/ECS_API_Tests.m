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
    //configuration.clientID      = @"mktwebextc";
    //configuration.clientSecret  = @"secret123";
    
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
         
         if(error)
         {
             XCTFail(@"Error reported: %@", error.description);
         }
         else
         {
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
         }
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
	 [self setUp];   // Test setup
	 [self initSDK]; // SDK setup
	 
	 XCTestExpectation *expectation = [self expectationWithDescription:@"testGetNavigationContextWithName"];
	 
	 ECSURLSessionManager *sessionManager = [[EXPERTconnect shared] urlSession];
	 
	 [sessionManager getNavigationContextWithName:@"personas" completion:^(ECSNavigationContext *context,NSError *error)
	  {
		   NSLog(@"Details: %@", context);
		   
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

//Get Answer Engine Top Quetions without Context
- (void)testGetAnswerEngineTopQuestions
{
	 [self setUp];   // Test setup
	 [self initSDK]; // SDK setup
	 
	 XCTestExpectation *expectation = [self expectationWithDescription:@"testGetAnswerEngineTopQuestions"];
	 
	 ECSURLSessionManager *sessionManager = [[EXPERTconnect shared] urlSession];
	 
	 [sessionManager getAnswerEngineTopQuestions:10
								  withCompletion:^(NSArray *answers, NSError *error)
	  {
		   NSLog(@"Details: %@", answers);
		   
		   if(error)
		   {
				XCTFail(@"Error reported: %@", error.description);
		   }
		   else
		   {
			   XCTAssert(answers != nil && answers.count != 0 ,@"No Questions found.");
		   }
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
	 
	 [sessionManager getAnswerEngineTopQuestions:10
									  forContext:@"All"
								  withCompletion:^(NSArray *answers, NSError *error)
	  {
		   NSLog(@"Details: %@", answers);
		   
		   if(error)
		   {
				XCTFail(@"Error reported: %@", error.description);
		   }
		   else
		   {
				XCTAssert(answers != nil && answers.count != 0 ,@"No Questions found.");
		   }
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
	 [self setUp];   // Test setup
	 [self initSDK]; // SDK setup
	 
	 XCTestExpectation *expectation = [self expectationWithDescription:@"testGetAnswerEngineTopQuestions"];
	 
	 ECSURLSessionManager *sessionManager = [[EXPERTconnect shared] urlSession];
	 
	 [sessionManager startAnswerEngineWithTopQuestions:10
									  forContext:@"Park"
								  withCompletion:^(NSArray *answers, NSError *error)
	  {
		   NSLog(@"Details: %@", answers);
		   
		   if(error)
		   {
				XCTFail(@"Error reported: %@", error.description);
		   }
		   else
		   {
				XCTAssert(answers != nil && answers.count != 0 ,@"No Questions found.");
		   }
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
	 [self setUp];   // Test setup
	 [self initSDK]; // SDK setup
	 
	 XCTestExpectation *expectation = [self expectationWithDescription:@"testGetAnswerEngineTopQuestionsForKeyword"];
	 
	 ECSURLSessionManager *sessionManager = [[EXPERTconnect shared] urlSession];
	 
	 [sessionManager getAnswerEngineTopQuestionsForKeyword:@"How Does Sharing Work?" withOptionalContext:@"All" completion:^(ECSAnswerEngineResponse *response, NSError *error)
	  {
		   NSLog(@"Details: %@", response);
		   
		   if(error)
		   {
				XCTFail(@"Error reported: %@", error.description);
		   }
		   else{
				XCTAssert(response.suggestedQuestions.count>0,@"Not returned some suggested questions.");
				XCTAssert(response.actions.count>0,@"Not returned some actions.");
				XCTAssert(response.answerContent,@"Missing answerContent field.");
				XCTAssert(response.answerId,@"Missing answerId field.");
				XCTAssert(response.inquiryId,@"Missing inquiryId field.");
				XCTAssert(response.requestRating > 0,@"Missing requestRating field.");
				XCTAssert(![response.answer isEqualToString:@"ANSWER_ENGINE_NO_QUESTION"],@"Answer not found.");
		   }
		   [expectation fulfill];
	  }];
	 
	 [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
		  if (error) {
			   XCTFail(@"Timeout error (15 seconds). Error=%@", error);
		  }
	 }];
}

- (void)testGetAnswerForQuestion
{
	 [self setUp];   // Test setup
	 [self initSDK]; // SDK setup
	 
	 XCTestExpectation *expectation = [self expectationWithDescription:@"testGetAnswerForQuestion"];
	 
	 ECSURLSessionManager *sessionManager = [[EXPERTconnect shared] urlSession];
	 
	 [sessionManager getAnswerForQuestion:@"How Does Borrow Work?" inContext:@"" customData:nil completion:^(ECSAnswerEngineResponse *response, NSError *error)
	  {
		   NSLog(@"Details: %@", response);
		   
		   if(error)
		   {
				XCTFail(@"Error reported: %@", error.description);
		   }
		   else{
				XCTAssert(response.suggestedQuestions.count>0,@"Not returned some suggested questions.");
				XCTAssert(response.actions.count>0,@"Not returned some actions.");
				XCTAssert(response.answerContent,@"Missing answerContent field.");
				XCTAssert(response.answerId,@"Missing answerId field.");
				XCTAssert(response.inquiryId,@"Missing inquiryId field.");
				XCTAssert(response.requestRating > 0,@"Missing requestRating field.");
				XCTAssert(![response.answer isEqualToString:@"ANSWER_ENGINE_NO_QUESTION"],@"Answer not found.");
		   }
		   [expectation fulfill];
	  }];
	 
	 [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
		  if (error) {
			   XCTFail(@"Timeout error (15 seconds). Error=%@", error);
		  }
	 }];
}

- (void)testGetAnswerForQuestionWithQuetionCount
{
	 [self setUp];   // Test setup
	 [self initSDK]; // SDK setup
	 
	 XCTestExpectation *expectation = [self expectationWithDescription:@"testGetAnswerForQuestionWithQuetionCount"];
	 
	 ECSURLSessionManager *sessionManager = [[EXPERTconnect shared] urlSession];
	 
	 [sessionManager getAnswerForQuestion:@"How Does Borrow Work?" inContext:@"" parentNavigator:@"" actionId:@"" questionCount:0 customData:nil completion:^(ECSAnswerEngineResponse *response, NSError *error)
	  {
		   NSLog(@"Details: %@", response);
		   
		   if(error)
		   {
				XCTFail(@"Error reported: %@", error.description);
		   }
		   else{
				XCTAssert(response.suggestedQuestions.count>0,@"Not returned some suggested questions.");
				XCTAssert(response.actions.count>0,@"Not returned some actions.");
				XCTAssert(response.answerContent,@"Missing answerContent field.");
				XCTAssert(response.answerId,@"Missing answerId field.");
				XCTAssert(response.inquiryId,@"Missing inquiryId field.");
				XCTAssert(response.requestRating > 0,@"Missing requestRating field.");
				XCTAssert(![response.answer isEqualToString:@"ANSWER_ENGINE_NO_QUESTION"],@"Answer not found.");
		   }
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
	 [self setUp];   // Test setup
	 [self initSDK]; // SDK setup
	 
	 XCTestExpectation *expectation = [self expectationWithDescription:@"rateAnswerWithAnswerID"];
	 
	 ECSURLSessionManager *sessionManager = [[EXPERTconnect shared] urlSession];
	 
	 [sessionManager rateAnswerWithAnswerID:@""
								  inquiryID:@"146495165541271"
									 rating:1
										min:-1
										max:1
							  questionCount:1
								 completion:^(ECSAnswerEngineRateResponse *response, NSError *error)
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

- (void)testGetResponseFromEndpoint
{
	 [self setUp];   // Test setup
	 [self initSDK]; // SDK setup
	 
	 XCTestExpectation *expectation = [self expectationWithDescription:@"GetResponseFromEndpoint"];
	 
	 ECSURLSessionManager *sessionManager = [[EXPERTconnect shared] urlSession];
	 [sessionManager getResponseFromEndpoint:@"/appconfig/v1/read_rconfig?like=appconfig.mktwebextc.default.answerengine" withCompletion:^(NSString *response,NSError *error)
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
				//Test username and firstname fields.
				XCTAssert([profile.username isEqualToString:_username]);
				XCTAssert([profile.firstName isEqualToString:_firstname]);
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
	 [sessionManager submitUserProfile:profile withCompletion:^(NSString *response, NSError *error)
	 {
		   NSLog(@"Details: %@", response);
		   
		   if(error)
		   {
				XCTFail(@"Error reported: %@", error.description);
		   }
		   else{
				//Test username and firstname fields.
				XCTAssert([profile.username isEqualToString:_username]);
				XCTAssert([profile.firstName isEqualToString:_firstname]);
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
	 [self setUp];   // Test setup
	 [self initSDK]; // SDK setup
	 
	 XCTestExpectation *expectation = [self expectationWithDescription:@"testGetFormNames"];
	 
	 ECSURLSessionManager *sessionManager = [[EXPERTconnect shared] urlSession];
	 
	 [sessionManager getFormNamesWithCompletion:^(NSArray *formNames, NSError *error)
	  {
		   NSLog(@"Details: %@", formNames);
		   
		   if(error)
		   {
				XCTFail(@"Error reported: %@", error.description);
		   }
		   else
		   {
				XCTAssert(formNames != nil && formNames.count != 0 ,@"No form names found.");
		   }
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
	 [self setUp];   // Test setup
	 [self initSDK]; // SDK setup
	 
	 XCTestExpectation *expectation = [self expectationWithDescription:@"testGetFormNames"];
	 
	 ECSURLSessionManager *sessionManager = [[EXPERTconnect shared] urlSession];
	 
	 [sessionManager getFormByName:@"userprofile" withCompletion:^(ECSForm *form, NSError *error)
	  {
		   NSLog(@"Details: %@", form);
		   
		   if(error)
		   {
				XCTFail(@"Error reported: %@", error.description);
		   }
		   else
		   {
				XCTAssert(form.formData.count == 3 ,@"No form data found.");

				for (ECSFormItem *formItem in form.formData)
				{
					 XCTAssert(formItem.treatment,@"Missing treatment field.");
					 XCTAssert(formItem.formValue,@"Missing formValue field.");
					 if ([formItem.treatment isEqualToString:@"email"]) {
						  XCTAssert([formItem.formValue isEqualToString:_username]);
					 }
					 else if ([formItem.treatment isEqualToString:@"full name"])
					 {
						  XCTAssert([formItem.formValue isEqualToString:_fullname]);
					 }
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


-(void)testNetworkReachable {
    ECSURLSessionManager *session = [[EXPERTconnect shared] urlSession];
    
    BOOL retVal = [session networkReachable];
    
    XCTAssert(retVal, @"Network not reachable.");
}

@end
