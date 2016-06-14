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
				XCTAssert(profile.city,@"Missing city field.");
				XCTAssert(profile.username,@"Missing username field.");
				XCTAssert(profile.firstName,@"Missing firstname field.");
				XCTAssert(profile.lastName,@"Missing lastname field.");
				XCTAssert(profile.mobilePhone,@"Missing mobilephone field.");
				XCTAssert(profile.address,@"Missing address field.");
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

-(void)testNetworkReachable {
    ECSURLSessionManager *session = [[EXPERTconnect shared] urlSession];
    
    BOOL retVal = [session networkReachable];
    
    XCTAssert(retVal, @"Network not reachable.");
}

@end
